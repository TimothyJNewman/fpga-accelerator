// =============================================================================
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
// -----------------------------------------------------------------------------
//   Copyright (c) 2017 by Lattice Semiconductor Corporation
//   ALL RIGHTS RESERVED
// -----------------------------------------------------------------------------
//
//   Permission:
//
//      Lattice SG Pte. Ltd. grants permission to use this code
//      pursuant to the terms of the Lattice Reference Design License Agreement.
//
//
//   Disclaimer:
//
//      This VHDL or Verilog source code is intended as a design reference
//      which illustrates how these types of functions can be implemented.
//      It is the user's responsibility to verify their design for
//      consistency and functionality through the use of formal
//      verification methods.  Lattice provides no warranty
//      regarding the use or functionality of this code.
//
// -----------------------------------------------------------------------------
//
//                  Lattice SG Pte. Ltd.
//                  101 Thomson Road, United Square #07-02
//                  Singapore 307591
//
//
//                  TEL: 1-800-Lattice (USA and Canada)
//                       +65-6631-2000 (Singapore)
//                       +1-503-268-8001 (other locations)
//
//                  web: http://www.latticesemi.com/
//                  email: techsupport@latticesemi.com
//
// -----------------------------------------------------------------------------
//
// =============================================================================
//                         FILE DETAILS
// Project               :
// File                  : lscc_lmmi2ahbl.v
// Title                 :
// Dependencies          : 1.
//                       : 2.
// Description           :
// =============================================================================
//                        REVISION HISTORY
// Version               : 1.0.0
// Author(s)             :
// Mod. Date             :
// Changes Made          : Initial release.
// =============================================================================

`ifndef LSCC_LMMI2AHBL
`define LSCC_LMMI2AHBL

`timescale 1 ns / 1 ps

module lscc_lmmi2ahbl #
// -----------------------------------------------------------------------------
// Module Parameters
// -----------------------------------------------------------------------------
(
parameter                     DATA_WIDTH = 32,  // 8/16/32/64/128/256/512/1024
parameter                     ADDR_WIDTH = 32,  // 11-32
parameter                     CNT_WIDTH  = 9    // 256B
)
// -----------------------------------------------------------------------------
// Input/Output Ports
// -----------------------------------------------------------------------------
(
input                         clk_i,
input                         rst_n_i,
// ------------------------
// LMMI-Extended Interface
// ------------------------
input                         lmmi_request_i,
input                         lmmi_wr_rdn_i,
input [ADDR_WIDTH-1:0]        lmmi_offset_i,
input [DATA_WIDTH-1:0]        lmmi_wdata_i,

input                         lmmi_start_i,
input [CNT_WIDTH-1:0]         lmmi_cnt_i,

output wire [DATA_WIDTH-1:0]  lmmi_rdata_o,
output wire                   lmmi_rdata_valid_o,
output reg                    lmmi_ready_o,
output reg                    lmmi_error_o,

// ------------------------
// AHB-Lite Interface
// ------------------------
input                         ahbl_hready_i,
input                         ahbl_hresp_i,
input [DATA_WIDTH-1:0]        ahbl_hrdata_i,

output reg [ADDR_WIDTH-1:0]   ahbl_haddr_o,
output reg [2:0]              ahbl_hburst_o,
output reg [2:0]              ahbl_hsize_o,
output reg                    ahbl_hmastlock_o,
output reg [3:0]              ahbl_hprot_o,
output reg [1:0]              ahbl_htrans_o,
output reg                    ahbl_hwrite_o,
output reg [DATA_WIDTH-1:0]   ahbl_hwdata_o
);

// -----------------------------------------------------------------------------
// Local Parameters
// -----------------------------------------------------------------------------
localparam                    ST_WIDTH     = 5;
localparam                    ST_IDLE      = 5'b00001;
localparam                    ST_BURST     = 5'b00010;
localparam                    ST_SINGLE    = 5'b00100;
localparam                    ST_WAIT      = 5'b01000;
localparam                    ST_BUSY      = 5'b10000;

localparam                    BYTES_PER_BEAT = (DATA_WIDTH / 8);

localparam                    WRITE = 1;
localparam                    READ  = 0;

localparam                    IDLE = 2'b00;
localparam                    BUSY = 2'b01;
localparam                    NSEQ = 2'b10;
localparam                    SEQ  = 2'b11;

localparam                    SINGLE = 3'b000;
localparam                    INCR   = 3'b001;

// -----------------------------------------------------------------------------
// Generate Variables
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// Combinatorial Registers
// -----------------------------------------------------------------------------
reg [ST_WIDTH-1:0]            ns_bridge_sm;

reg [1:0]                     ahbl_htrans;
reg                           adv_rd_ptr_last;
reg                           adv_rd_ptr_wait;
reg                           start;
reg                           rd0_wr1;
reg [2:0]                     size;

reg [2:0]                     hsize;

// -----------------------------------------------------------------------------
// Sequential Registers
// -----------------------------------------------------------------------------
reg [ST_WIDTH-1:0]            cs_bridge_sm;

reg                           burst_en;

reg [1:0]                     pipe_cnt;
reg                           pipe_wr_ptr;
reg                           pipe_rd_ptr;
reg [DATA_WIDTH-1:0]          data_pipe_0;
reg [DATA_WIDTH-1:0]          data_pipe_1;
reg [DATA_WIDTH-1:0]          data_pipe_out;
reg [ADDR_WIDTH-1:0]          addr_pipe_0;
reg [ADDR_WIDTH-1:0]          addr_pipe_1;
reg                           burst_start_0;
reg                           burst_start_1;
reg                           rd0_wr1_0;
reg                           rd0_wr1_1;
reg [2:0]                     size_0;
reg [2:0]                     size_1;
reg [3:0]                     rd_wait_cnt;
reg                           rd_wait;

reg [CNT_WIDTH-1:0]           run_xfer_cnt;
reg [CNT_WIDTH-1:0]           run_xfer_valid_cnt;

reg                           lmmi_request_Q;

reg                           adv_rd_ptr_Q;
reg                           adv_rd_ptr_last_en;
reg                           adv_rd_ptr_mask;

reg                           rd0_wr1_Q;

// -----------------------------------------------------------------------------
// Wire Declarations
// -----------------------------------------------------------------------------
wire [7:0]                    bytes_per_beat  = BYTES_PER_BEAT;

wire [CNT_WIDTH-1:0]          minus_sz;
wire                          last_burst;

// -----------------------------------------------------------------------------
// Assign Statements
// -----------------------------------------------------------------------------
assign                        ebt_detected     = (ahbl_hresp_i && ~ahbl_hready_i);
assign                        err_response     =    ebt_detected
                                                 || (ahbl_hresp_i && ahbl_hready_i);

assign                        run_xfer_cnt_eq0  =    (run_xfer_cnt == 0)
                                                  && burst_en;

assign                        pipe_full  = (pipe_cnt == 2'b10);
assign                        pipe_empty = (pipe_cnt == 2'b00);

assign                        rd_wait_full    = (rd_wait_cnt == 2'b10);
assign                        rd_wait_empty   = (rd_wait_cnt == 2'b00);
assign                        rd_wait_cnt_eq1 = (rd_wait_cnt == 2'b01);

assign                        adv_wr_ptr = lmmi_request_i && lmmi_ready_o;
assign                        adv_rd_ptr =    (    ~pipe_empty
                                                && ahbl_hready_i
                                                && ~ahbl_hresp_i);

assign                        ready = err_response ? 1'b0 : ahbl_hready_i && ~pipe_full;

assign                        lmmi_rdata_o       = ahbl_hrdata_i;
assign                        lmmi_rdata_valid_o = ahbl_hready_i && rd_wait;

assign                        minus_sz   = hsize << 1;
assign                        last_burst =     (run_xfer_cnt <= minus_sz)
                                           && ~(run_xfer_cnt == 0);

// -----------------------------------------------------------------------------
// Generate Assign Statements
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// Combinatorial Blocks
// -----------------------------------------------------------------------------
always @* begin
  case (pipe_rd_ptr)
    0: begin
      start    = burst_start_0;
      rd0_wr1  = rd0_wr1_0;
      hsize    = size_0;
    end
    1: begin
      start    = burst_start_1;
      rd0_wr1  = rd0_wr1_1;
      hsize    = size_1;
    end
  endcase // case (pipe_rd_ptr)
end

// -------------------------------
// State Machine
// -------------------------------
always @* begin

  ns_bridge_sm        = cs_bridge_sm;
  lmmi_ready_o        = 1'b1;
  lmmi_error_o        = 1'b0;

  ahbl_htrans         = IDLE;
  adv_rd_ptr_last     = 1'b0;
  adv_rd_ptr_wait     = 1'b0;

  case (cs_bridge_sm)
    // --------------------------------------------------------------------------
    // STATE: IDLE
    // --------------------------------------------------------------------------
    ST_IDLE: begin
      lmmi_ready_o = ready;
      if (adv_rd_ptr) begin
        ahbl_htrans  = NSEQ;
        ns_bridge_sm = start ? ST_BURST : ST_SINGLE;
      end
    end
    // --------------------------------------------------------------------------
    // STATE: BURST
    // --------------------------------------------------------------------------
    ST_BURST: begin
      lmmi_ready_o = rd0_wr1 ? ready && ~rd_wait : ready;
      if (burst_en) begin
        ahbl_htrans = start ? NSEQ : SEQ;
        if (ebt_detected) begin
          ahbl_htrans      = IDLE;
          ns_bridge_sm     = ST_IDLE;
        end
        else begin
          if (~pipe_empty) begin
            if (~ahbl_hready_i) begin
              ahbl_htrans = ahbl_htrans_o;
            end
            ns_bridge_sm  = ~ahbl_hready_i
                            ? ST_WAIT : ST_BURST;
          end
          else begin
            if (run_xfer_cnt_eq0) begin
              if (~ahbl_hready_i) begin
                ahbl_htrans      = ahbl_htrans_o;
                adv_rd_ptr_wait  = 1'b1;
              end
              else begin
                ahbl_htrans  = IDLE;
              end
              adv_rd_ptr_last  = ahbl_hready_i;
              ns_bridge_sm     = ~ahbl_hready_i
                                 ? ST_WAIT : ST_IDLE;
            end
            else begin
              if (~ahbl_hready_i) begin
                ahbl_htrans   = ahbl_htrans_o;
                ns_bridge_sm  = ST_WAIT;
              end
              else begin
                ahbl_htrans   = BUSY;
                ns_bridge_sm  = ST_BUSY;
              end
            end
          end
        end
      end // if (burst_en)
    end // case: ST_BURST
    // --------------------------------------------------------------------------
    // STATE: SINGLE
    // --------------------------------------------------------------------------
    ST_SINGLE: begin
      lmmi_ready_o = ready;
      ahbl_htrans  = ~pipe_empty ? NSEQ : IDLE;
      if (ebt_detected) begin
        lmmi_error_o     = 1'b1;
        ahbl_htrans      = IDLE;
        ns_bridge_sm     = ST_IDLE;
      end
      else begin
        if (~pipe_empty) begin
          ns_bridge_sm = ~ahbl_hready_i ? ST_WAIT : ST_SINGLE;
        end
        else begin
          if (~ahbl_hready_i) begin
            ahbl_htrans      = ahbl_htrans_o;
            adv_rd_ptr_wait  = 1'b1;
          end
          adv_rd_ptr_last  = ahbl_hready_i;
          ns_bridge_sm     = ~ahbl_hready_i
                             ? ST_WAIT : ST_IDLE;
        end
      end
    end
    // --------------------------------------------------------------------------
    // STATE: WAIT
    // --------------------------------------------------------------------------
    ST_WAIT: begin
      lmmi_ready_o  = 1'b0;
      ahbl_htrans   = burst_en ? (start ? NSEQ : SEQ) : NSEQ;
      if (ebt_detected) begin
        ahbl_htrans   = IDLE;
        ns_bridge_sm  = ST_IDLE;
      end
      else begin
        if (ahbl_hready_i) begin
          if (adv_rd_ptr_last_en || (burst_en && run_xfer_cnt_eq0)) begin
            adv_rd_ptr_last  = 1'b1;
            ahbl_htrans      = ~pipe_empty ? NSEQ : IDLE;
            lmmi_ready_o     = ahbl_hready_i;
            ns_bridge_sm     = ~pipe_empty ? (start ? ST_BURST : ST_SINGLE)
                                           : ST_IDLE;
          end
          else begin
            if (pipe_empty) begin
              ahbl_htrans   = BUSY;
            end
            lmmi_ready_o  = 1'b1;
            ns_bridge_sm  = pipe_empty ? ST_BUSY
                                       : burst_en ? ST_BURST : ST_SINGLE;
          end
        end // if (ahbl_hready_i)
      end // else: !if(ebt_detected)
    end
    // --------------------------------------------------------------------------
    // STATE: BUSY
    // You are at this state when there is no outstanding request coming from
    // LMMI master during a burst transfer. For single transfers, there is no
    // scenario that the master needs to insert BUSY state.
    // --------------------------------------------------------------------------
    ST_BUSY: begin
      lmmi_ready_o  = ready;
      ahbl_htrans   = BUSY;
      if (adv_rd_ptr/* || (last_burst && ahbl_hready_i)*/) begin
        ahbl_htrans  = SEQ;
        ns_bridge_sm = burst_en ? ST_BURST : ST_SINGLE;
      end
    end
    default: begin
      ns_bridge_sm = IDLE;
    end
  endcase // case (cs_bridge_sm)
end

// -----------------------------------------------------------------------------
// Generate Combinatorial Blocks
// -----------------------------------------------------------------------------
generate
  if ((DATA_WIDTH == 8) || (DATA_WIDTH == 16) || (DATA_WIDTH == 32)) begin
    always @* begin
      if (lmmi_cnt_i > bytes_per_beat) begin
        case (bytes_per_beat)
          1: size        = 3'b000;
          2: size        = 3'b001;
          4: size        = 3'b010;
          default: size  = 3'b000;
        endcase // case (bytes_per_beat)
      end
      else begin
        case (lmmi_cnt_i)
          1: size        = 3'b000;
          2: size        = 3'b001;
          4: size        = 3'b010;
          default: size  = 3'b000;
        endcase // case (bytes_per_beat)
      end
    end
  end // if ((DATA_WIDTH == 8) || (DATA_WIDTH == 16) || (DATA_WIDTH == 32))
  if (DATA_WIDTH == 64) begin
    always @* begin
      if (lmmi_cnt_i > bytes_per_beat) begin
        size = 3'b011;
      end
      else begin
        case (lmmi_cnt_i)
          1: size        = 3'b000;
          2: size        = 3'b001;
          4: size        = 3'b010;
          8: size        = 3'b011;
          default: size  = 3'b000;
        endcase // case (bytes_per_beat)
      end
    end
  end // if (DATA_WIDTH == 64)
  if (DATA_WIDTH == 128) begin
    always @* begin
      if (lmmi_cnt_i > bytes_per_beat) begin
        size = 3'b100;
      end
      else begin
        case (lmmi_cnt_i)
          1:  size       = 3'b000;
          2:  size       = 3'b001;
          4:  size       = 3'b010;
          8:  size       = 3'b011;
          16: size       = 3'b100;
          default: size  = 3'b000;
        endcase // case (bytes_per_beat)
      end
    end
  end // if (DATA_WIDTH == 128)
  if (DATA_WIDTH == 256) begin
    always @* begin
      if (lmmi_cnt_i > bytes_per_beat) begin
        size = 3'b101;
      end
      else begin
        case (lmmi_cnt_i)
          1:  size       = 3'b000;
          2:  size       = 3'b001;
          4:  size       = 3'b010;
          8:  size       = 3'b011;
          16: size       = 3'b100;
          32: size       = 3'b101;
          default: size  = 3'b000;
        endcase // case (bytes_per_beat)
      end
    end
  end // if (DATA_WIDTH == 256)
  if (DATA_WIDTH == 256) begin
    always @* begin
      if (lmmi_cnt_i > bytes_per_beat) begin
        size = 3'b101;
      end
      else begin
        case (lmmi_cnt_i)
          1:  size       = 3'b000;
          2:  size       = 3'b001;
          4:  size       = 3'b010;
          8:  size       = 3'b011;
          16: size       = 3'b100;
          32: size       = 3'b101;
          default: size  = 3'b000;
        endcase // case (bytes_per_beat)
      end
    end
  end // if (DATA_WIDTH == 256)
  if (DATA_WIDTH == 512) begin
    always @* begin
      if (lmmi_cnt_i > bytes_per_beat) begin
        size = 3'b110;
      end
      else begin
        case (lmmi_cnt_i)
          1:  size       = 3'b000;
          2:  size       = 3'b001;
          4:  size       = 3'b010;
          8:  size       = 3'b011;
          16: size       = 3'b100;
          32: size       = 3'b101;
          64: size       = 3'b110;
          default: size  = 3'b000;
        endcase // case (bytes_per_beat)
      end
    end
  end // if (DATA_WIDTH == 512)
  if (DATA_WIDTH == 1024) begin
    always @* begin
      if (lmmi_cnt_i > bytes_per_beat) begin
        size = 3'b111;
      end
      else begin
        case (lmmi_cnt_i)
          1:   size      = 3'b000;
          2:   size      = 3'b001;
          4:   size      = 3'b010;
          8:   size      = 3'b011;
          16:  size      = 3'b100;
          32:  size      = 3'b101;
          64:  size      = 3'b110;
          128: size      = 3'b111;
          default: size  = 3'b000;
        endcase // case (bytes_per_beat)
      end
    end
  end // if (DATA_WIDTH == 1024)
endgenerate

// -----------------------------------------------------------------------------
// Sequential Blocks
// -----------------------------------------------------------------------------
always @(posedge clk_i or negedge rst_n_i) begin
  if (~rst_n_i) begin
    cs_bridge_sm   <= ST_IDLE;
    lmmi_request_Q <= 1'b0;
  end
  else begin
    cs_bridge_sm   <= ns_bridge_sm;
    lmmi_request_Q <= lmmi_request_i;
  end
end

// ----------------------------------------------------
// Enable burst_en to notify start of a burst transfer
// ----------------------------------------------------
always @(posedge clk_i or negedge rst_n_i) begin
  if (~rst_n_i) begin
    burst_en  <= 1'b0;
  end
  else begin
    if (adv_rd_ptr_last && burst_en) begin
      burst_en <= 1'b0;
    end
    else begin
      if (adv_rd_ptr) begin
        case (pipe_rd_ptr)
          0: burst_en <= ~burst_en ? burst_start_0 : burst_en;
          1: burst_en <= ~burst_en ? burst_start_1 : burst_en;
        endcase // case (pipe_wr_ptr)
      end
    end
  end
end

// --------------------
// Ping Pong Registers
// --------------------
always @(posedge clk_i or negedge rst_n_i) begin
  if (~rst_n_i) begin
    pipe_wr_ptr   <= 1'b0;
    pipe_rd_ptr   <= 1'b0;
    pipe_cnt      <= 2'b0;
    data_pipe_0   <= {DATA_WIDTH{1'b1}};
    data_pipe_1   <= {DATA_WIDTH{1'b1}};
    addr_pipe_0   <= {ADDR_WIDTH{1'b1}};
    addr_pipe_1   <= {ADDR_WIDTH{1'b1}};
    burst_start_0 <= 1'b0;
    burst_start_1 <= 1'b0;
    rd0_wr1_0     <= 1'b0;
    rd0_wr1_1     <= 1'b0;
    size_0        <= 0;
    size_1        <= 0;
    rd_wait_cnt   <= 2'b0;
    rd_wait       <= 0;
  end
  else begin

    if (lmmi_request_i && lmmi_ready_o) begin
      pipe_wr_ptr <= ~pipe_wr_ptr;
      case (pipe_wr_ptr)
        0: begin
          data_pipe_0   <= lmmi_wdata_i[DATA_WIDTH-1:0];
          addr_pipe_0   <= lmmi_offset_i[ADDR_WIDTH-1:0];
          burst_start_0 <= lmmi_start_i;
          rd0_wr1_0     <= lmmi_wr_rdn_i;
          size_0        <= size;
        end
        1: begin
          data_pipe_1   <= lmmi_wdata_i[DATA_WIDTH-1:0];
          addr_pipe_1   <= lmmi_offset_i[ADDR_WIDTH-1:0];
          burst_start_1 <= lmmi_start_i;
          rd0_wr1_1     <= lmmi_wr_rdn_i;
          size_1        <= size;
        end
      endcase // case (pipe_wr_ptr)
    end

    case ({adv_wr_ptr, adv_rd_ptr & ~adv_rd_ptr_mask})
      2'b00,
      2'b11: pipe_cnt <= pipe_cnt;
      2'b01: pipe_cnt <= pipe_cnt - 1;
      2'b10: pipe_cnt <= pipe_cnt + 1;
    endcase // case ({adv_wr_ptr, adv_rd_ptr})
    pipe_rd_ptr <= adv_rd_ptr & ~adv_rd_ptr_mask ? ~pipe_rd_ptr : pipe_rd_ptr;

    if (~rd0_wr1_Q || rd_wait) begin
      case ({adv_rd_ptr_Q, lmmi_rdata_valid_o})
        2'b00,
        2'b11: rd_wait_cnt <= rd_wait_cnt;
        2'b01: rd_wait_cnt <= rd_wait_cnt - 1;
        2'b10: rd_wait_cnt <= rd_wait_cnt + 1;
      endcase // case ({adv_rd_ptr, ahbl_hready_i})
    end
    rd_wait <= (ahbl_hready_i && rd_wait_cnt_eq1) && ~adv_rd_ptr_Q
               ? 1'b0 : (adv_rd_ptr_Q && ~rd0_wr1_Q ? 1'b1 : rd_wait);

  end
end

always @(posedge clk_i or negedge rst_n_i) begin
  if (~rst_n_i) begin
    run_xfer_cnt       <= 0;
    run_xfer_valid_cnt <= 0;
  end
  else begin
    if (lmmi_start_i && lmmi_request_i) begin
      run_xfer_cnt       <= lmmi_cnt_i;
      run_xfer_valid_cnt <= lmmi_cnt_i;
    end
    else begin
      if (start || burst_en) begin
        if (adv_rd_ptr && (run_xfer_cnt != 0)) begin
          run_xfer_cnt <= run_xfer_cnt - minus_sz;
        end
      end

      if (start || burst_en) begin
        if (lmmi_rdata_valid_o && (run_xfer_valid_cnt != 0)) begin
          run_xfer_valid_cnt <= run_xfer_valid_cnt - minus_sz;
        end
      end

    end
  end
end

always @(posedge clk_i or negedge rst_n_i) begin
  if (~rst_n_i) begin
    rd0_wr1_Q <= 0;
  end
  else begin
    rd0_wr1_Q <= rd0_wr1;
  end
end

// -----------------
// AHB-Lite Signals
// -----------------
always @(posedge clk_i or negedge rst_n_i) begin
  if (~rst_n_i) begin
    ahbl_haddr_o       <= 0;
    ahbl_hsize_o       <= 0;
    ahbl_hburst_o      <= SINGLE;
    ahbl_hmastlock_o   <= 0;
    ahbl_hprot_o       <= 4'b1101;
    ahbl_htrans_o      <= IDLE;
    ahbl_hwrite_o      <= WRITE;
    ahbl_hwdata_o      <= 0;
    data_pipe_out      <= {DATA_WIDTH{1'b0}};
    adv_rd_ptr_Q       <= 1'b0;
    adv_rd_ptr_last_en <= 1'b0;
    adv_rd_ptr_mask    <= 1'b0;
  end
  else begin
    adv_rd_ptr_Q  <= adv_rd_ptr;
    ahbl_htrans_o <= ahbl_htrans;

    if (adv_rd_ptr && ~adv_rd_ptr_mask) begin
      ahbl_hburst_o <= start ? INCR : (~burst_en ? SINGLE : ahbl_hburst_o);
    end

    if (adv_rd_ptr && ~adv_rd_ptr_mask) begin
      case (pipe_rd_ptr)
        0: ahbl_hsize_o <= size_0;
        1: ahbl_hsize_o <= size_1;
      endcase // case (pipe_wr_ptr)
    end

    if (adv_rd_ptr && ~adv_rd_ptr_mask) begin
      case (pipe_rd_ptr)
        0: ahbl_hwrite_o <= rd0_wr1_0;
        1: ahbl_hwrite_o <= rd0_wr1_1;
      endcase // case (pipe_wr_ptr)
    end

    if (adv_rd_ptr && ~adv_rd_ptr_mask) begin
      case (pipe_rd_ptr)
        0: ahbl_haddr_o <= addr_pipe_0[ADDR_WIDTH-1:0];
        1: ahbl_haddr_o <= addr_pipe_1[ADDR_WIDTH-1:0];
      endcase // case (pipe_wr_ptr)
    end

    if (adv_rd_ptr && ~adv_rd_ptr_mask) begin
      case (pipe_rd_ptr)
        0: data_pipe_out <= data_pipe_0[DATA_WIDTH-1:0];
        1: data_pipe_out <= data_pipe_1[DATA_WIDTH-1:0];
      endcase // case (pipe_wr_ptr)
    end

    if ((adv_rd_ptr && ~adv_rd_ptr_mask) || adv_rd_ptr_last) begin
      ahbl_hwdata_o <= data_pipe_out[DATA_WIDTH-1:0];
    end

    adv_rd_ptr_last_en <= adv_rd_ptr_last
                          ? 1'b0
                          : adv_rd_ptr_wait ? 1'b1 : adv_rd_ptr_last_en;

    if ((ahbl_htrans == NSEQ) && adv_rd_ptr_mask)  begin
      adv_rd_ptr_mask <= 1'b0;
    end
    else begin
      adv_rd_ptr_mask <= ebt_detected ? 1'b1 : adv_rd_ptr_mask;
    end

  end
end

// -----------------------------------------------------------------------------
// Generate Sequential Blocks
// -----------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Function Definition
//------------------------------------------------------------------------------
// synopsys translate_off
function [31:0] clog2;
  input [31:0] value;
  reg   [31:0] num;
  begin
    num = value - 1;
    for (clog2 = 0; num > 0; clog2 = clog2 + 1) num = num >> 1;
  end
endfunction
// synopsys translate_on

// -----------------------------------------------------------------------------
// Submodule Instantiations
// -----------------------------------------------------------------------------

// synopsys translate_off
reg [8*6-1:0] cs_bridge_sm_msg;
always @* begin
  case (cs_bridge_sm)
    ST_IDLE:   cs_bridge_sm_msg  = "IDLE";
    ST_BURST:  cs_bridge_sm_msg  = "BURST";
    ST_SINGLE: cs_bridge_sm_msg  = "SINGLE";
    ST_WAIT:   cs_bridge_sm_msg  = "WAIT";
    ST_BUSY:   cs_bridge_sm_msg  = "BUSY";
    default:   cs_bridge_sm_msg  = "SH**";
  endcase // case (cs_bridge_sm)
end

reg [4*8-1:0] ahbl_htrans_msg;
always @* begin
  case (ahbl_htrans_o)
    IDLE: ahbl_htrans_msg  = "IDLE";
    BUSY: ahbl_htrans_msg  = "BUSY";
    NSEQ: ahbl_htrans_msg  = "NSEQ";
    SEQ:  ahbl_htrans_msg  = "SEQ";
    default: ahbl_htrans_msg = "SH**";
  endcase
end
// synopsys translate_on

endmodule
//=============================================================================
// lscc_lmmi2ahbl.v
//=============================================================================
`endif
