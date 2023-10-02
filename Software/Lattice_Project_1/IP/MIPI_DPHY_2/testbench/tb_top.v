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
//      reg arding the use or functionality of this code.
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
// Project               : MIPI_DPHY
// File                  : tb_top.v
// Title                 :
// Dependencies          : 1.
//                       : 2.
// Description           :
// =============================================================================

`timescale 1ns/1ps

`ifndef LSCC_MIPI_DPHY_TB
`define LSCC_MIPI_DPHY_TB
module tb_top();

///////////////////////////////////////////////////////////
/// Parameters
///////////////////////////////////////////////////////////
`include"dut_params.v"
// Internal parameters
localparam HEADER_CHK    = "OFF";
localparam LOW           = (INT_TYPE == "TX" && DPHY_IP  == "LATTICE")? 7 : 5;
localparam LDW           = (INT_TYPE == "TX" && DPHY_IP  == "LATTICE")? 8 : 4;
localparam DATA_WIDTH    =  GEAR*NUM_LANE;
localparam LP_RX_DW      = (INT_TYPE == "RX")? NUM_LANE   : 1;
localparam LP_TX_DW      = (INT_TYPE == "TX")? NUM_LANE   : 1;
localparam UI            = 1000.0 / INT_DATA_RATE;
localparam RX_LINE_RATE  = INT_DATA_RATE;
localparam BYTECLK       = RX_LINE_RATE/GEAR;
localparam DPHY_CLK      = 2000.0/(BYTECLK*GEAR);
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Timing Parameters with Minimum and Maximum Values //////////////////////////////////////////////////////////////////////////////
localparam T_CLK_PREPARE = 38;                    //Minimum value is 38ns. Maximum value is 95ns.
localparam T_HS_PREPARE  = (85 + (6*DPHY_CLK/2)); //Minimum value is (40 + (4*DPHY_CLK/2)). Maximum value is (85 + (6*DPHY_CLK/2))
localparam T_HS_TRAIL    = (60 + (4*DPHY_CLK/2)); //Minimum value is (8*DPHY_CLK/2). Maximum value is  (60 + (4*DPHY_CLK/2))
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
localparam TLPX          = 50; 
localparam T_CLK_TERM_EN = 38;
localparam T_CLK_ZERO    = 300 - T_CLK_PREPARE;
localparam T_CLK_PRE     = (8*DPHY_CLK/2);
localparam T_D_TERM_EN   = 35 + (4*DPHY_CLK/2);
localparam T_CLK_POST    = (60 + (52*DPHY_CLK/2));
localparam T_HS_ZERO     = ((145 + (10*DPHY_CLK/2)) - T_HS_PREPARE);
localparam T_CLK_TRAIL   = 60;
localparam T_HS_EXIT     = 100;
localparam TPREPARE      = 40 + 4*UI; 
localparam THSZERO       = 105 + 6*UI;
localparam TTRAIL        = 60;
localparam TSETTLE       = 100;
localparam FRAME_CNT     = 1;
localparam LINE_CNT      = 1;
localparam SYNC_CHAR     = 8'hB8;
/// Frame/line/vsync/hsync start/end
localparam VSYNCSTART    = 6'h01;
localparam VSYNCEND      = 6'h11;
localparam HSYNCSTART    = 6'h21;
localparam HSYNCEND      = 6'h31;
localparam FRAMESTART    = 6'h00;
localparam FRAMEEND      = 6'h01;
localparam LINESTART     = 6'h02;
localparam LINEEND       = 6'h03;
localparam P1DT          = (INTF == "DSI_APP")? 6'h01 : 6'h00; /// Packet 1 data type
localparam P2DT          = (INTF == "DSI_APP")? 6'h11 : 6'h01; /// Packet 2 data type
localparam P3DT          = (INTF == "DSI_APP")? 6'h21 : 6'h02; /// Packet 3 data type
localparam P4DT          = (INTF == "DSI_APP")? 6'h31 : 6'h03; /// Packet 4 data type
localparam DATATYPE      = 6'h3E;
localparam PYLD_WDCNT    = 64;

///////////////////////////////////////////////////////////
/// Test variables
///////////////////////////////////////////////////////////
reg                clk_p_r;
reg                clk_n_r;
reg [NUM_LANE-1:0] data_p_r;
reg [NUM_LANE-1:0] data_n_r;
reg          [5:0] ecc;
reg                test_end;
integer            i;
integer            j;
integer            k;
integer            l;
integer            h;
integer            model_data;
integer            dut_data;

///////////////////////////////////////////////////////////
/// Text files
///////////////////////////////////////////////////////////
initial begin
  model_data = $fopen("model_data.txt","w");
  dut_data   = $fopen("dut_data.txt","w");
  @(posedge test_end);
  $fclose(dut_data);
  $fclose(model_data);
end

///////////////////////////////////////////////////////////
/// Test Variables
///////////////////////////////////////////////////////////
reg [63:0] hs_tx_data_r; /// used for Cil remainder data
reg [12:0] data_cycle_r;
///////////////////////////////////////////////////////////
/// Dut ports
///////////////////////////////////////////////////////////

// Clock and reset
reg                   sync_clk_i;                                        // Clock for mipi_dphy.
reg                   sync_rst_i;                                        // Reset for mipi_dphy.
// LMMI
reg                   lmmi_clk_i;                                        // Clock for LMMI.
reg                   lmmi_resetn_i;                                     // Active low reset.
reg  [LDW-1:0]        lmmi_wdata_i;                                      // Data from user.
reg                   lmmi_wr_rdn_i;                                     // Active hight write, low read.
reg  [LOW-1:0]        lmmi_offset_i;                                     // Offset.
reg                   lmmi_request_i;                                    // Request.
wire                  lmmi_ready_o;                                      // If hight LMMI is ready for communicate.
wire [LDW-1:0]        lmmi_rdata_o;                                      // Data from LMMI.
wire                  lmmi_rdata_valid_o;                                // Valid for data from LMMI.
// HS_TX signals
reg                   hs_tx_en_i;                                        // High speed transmit enable.
reg                   hs_tx_clk_en_i;                                    // High speed clock enable.
reg  [DATA_WIDTH-1:0] hs_tx_data_i;                                      // High speed transmit data.
reg                   hs_tx_data_en_i;                                   // High speed transmit data enable.
// HS_RX signals
reg                   hs_rx_clk_en_i;                                    // High speed receive clock enable(DPHY_IP == HARD_IP).
reg                   hs_rx_data_en_i;                                   // High speed receive data enable (DPHY_IP == HARD_IP).
reg                   hs_rx_en_i;                                        // High speed receive data enable (DPHY_IP == LATTICE).
reg                   hs_data_des_en_i;
wire [DATA_WIDTH-1:0] hs_rx_data_o;                                      // High speed receive data.
wire [NUM_LANE-1:0]   hs_rx_data_en_o;                                   // High speed receive data is synced.
// LP_TX signals
reg                   lp_tx_en_i;                                        // Low power transmit enable.
reg  [LP_TX_DW-1:0]   lp_tx_data_p_i;                                    // Low power transmit data.
reg  [LP_TX_DW-1:0]   lp_tx_data_n_i;                                    // Low power transmit data.
reg                   lp_tx_data_en_i;                                   // Low power transmit data enable.
reg                   lp_tx_clk_p_i;                                     // Low power transmit positive data.
reg                   lp_tx_clk_n_i;                                     // Low power transmit negative data.
// LP_RX signals
reg                   lp_rx_en_i;                                        // Low power receive enable.
wire [LP_RX_DW-1:0]   lp_rx_data_p_o;                                    // Low power receive data.
wire [LP_RX_DW-1:0]   lp_rx_data_n_o;                                    // Low power receive data.
wire                  lp_rx_clk_p_o;                                     // Low power positive clock.
wire                  lp_rx_clk_n_o;                                     // Low power negative clock.
// ExternalPLL for SOFT DPHY_Tx
reg                   pll_clkop_i;                                       // Output clock from PLL
reg                   pll_clkos_i;                                       // Output clock from PLL 90 degree *** then pll_clkop_i
reg                   pll_lock_i;                                        // PLL lock
// DPHY ports
wire                  clk_p_io  = (INT_TYPE == "RX")?  clk_p_r :  'dz;   // Positive part of differential clock.
wire                  clk_n_io  = (INT_TYPE == "RX")?  clk_n_r :  'dz;   // Negative part of differential clock.
wire [NUM_LANE-1:0]   data_p_io = (INT_TYPE == "RX")? data_p_r :  'dz;   // Positive part of differential data.
wire [NUM_LANE-1:0]   data_n_io = (INT_TYPE == "RX")? data_n_r :  'dz;   // Negative part of differential data.
// CIL
wire [NUM_LANE-1:0]   hs_tx_cil_ready_o;                                 // CIL HARD DPHY ready to transmit HS data
wire [NUM_LANE-1:0]   data_lane_ss_o;                                    // CIL HARD DPHY ready to transmit HS data
// Other
reg                   usrstdby_i;                                        // User standby for PLL and DPHY.
reg                   pd_dphy_i;                                         // Power down for DPHY or MIPI.
reg                   txclk_hsgate_i;                                    // High Speed transmitter clock gate signal
wire                  pll_lock_o;                                        // PLL ready.
wire                  clk_byte_o;                                        // Byte clock.
wire                  ready_o;                                           // Ready from DPHY or from PLL.

reg                   clk_test;
reg                   [DATA_WIDTH-1:0] rx_data_o; 
reg                   [31:0] test_cntr = 32'b0;
///////////////////////////////////////////////////////////
/// initial
///////////////////////////////////////////////////////////
initial begin
  lmmi_clk_i      = 'd0;
  lmmi_resetn_i   = 'd0;
  lmmi_wdata_i    = 'd0;
  lmmi_wr_rdn_i   = 'd0;
  lmmi_offset_i   = 'd0;
  lmmi_request_i  = 'd0;
  hs_tx_en_i      = 'd0;
  hs_tx_clk_en_i  = 'd0;
  hs_tx_data_i    = 'd0;
  hs_tx_data_en_i = 'd0;
  hs_rx_en_i	  = 'd0;
  hs_rx_clk_en_i  = 'd0;
  hs_rx_data_en_i = 'd0;
  hs_data_des_en_i= 'd0;
  lp_tx_en_i      = 'd0;
  lp_tx_data_p_i  = 'd1;
  lp_tx_data_n_i  = 'd1;
  lp_tx_data_en_i = 'd1;
  lp_tx_clk_p_i   = 'd1;
  lp_tx_clk_n_i   = 'd1;
  lp_rx_en_i      = 'd0;
  pll_clkop_i     = 'd0;
  pll_clkos_i     = 'd0;
  pll_lock_i      = 'd0;
  usrstdby_i      = 'd0;
  pd_dphy_i       = 'd0; 
  txclk_hsgate_i  = 'd0;
  clk_p_r         = 'd1;
  clk_n_r         = 'd1;
  data_p_r        = 'hF;
  data_n_r        = 'hF;
  ecc             = 'd0;
  hs_tx_data_r    = 'd0;
  clk_test        = 'd0;
end

///////////////////////////////////////////////////////////
/// Clock generations
///////////////////////////////////////////////////////////
localparam real SYNC_CLOCK_PERIOD = 1000.0 / SYNC_CLOCK_FREQ;       /// In ns
localparam real LMMI_CLOCK_PERIOD = 1000.0 / 50;                    /// In ns
localparam real PLL_CLOCK_PERIOD  = 1000.0 / (INT_DATA_RATE/2.0);   /// in ns
initial begin
  sync_clk_i  = 0;
  lmmi_clk_i  = 0;
  pll_clkop_i = 0;
  pll_clkos_i = 0;
  pll_lock_i  = 0;
end

always begin
  #(SYNC_CLOCK_PERIOD / 2.0) sync_clk_i = !sync_clk_i;
end

always begin
  #(LMMI_CLOCK_PERIOD / 2.0) lmmi_clk_i = !lmmi_clk_i;
end

always begin
  #(PLL_CLOCK_PERIOD / 2.0) clk_test = !clk_test;
end

initial begin
  fork
    begin
      @(negedge sync_rst_i);
      repeat (100) begin
        @(posedge pll_clkop_i);
      end
      pll_lock_i  = 1;
    end
    begin
      forever begin
        #(PLL_CLOCK_PERIOD / 2.0)pll_clkop_i = !pll_clkop_i;
      end
    end
    begin
      #(PLL_CLOCK_PERIOD / 4.0)/// For 90 degree delay
      forever begin
        #(PLL_CLOCK_PERIOD / 2.0)pll_clkos_i = !pll_clkos_i;
      end
    end
  join
end

///////////////////////////////////////////////////////////
/// Main proces
///////////////////////////////////////////////////////////
initial begin
  test_end = 0;
  $display("***Test Start***");
  if (INT_TYPE == "TX") begin
    mipi_dphy_tx_task;
  end
  else if (INT_TYPE == "RX") begin
    mipi_dphy_rx_task;
  end
  test_end = 1;
  data_check_t;
end


///////////////////////////////////////////////////////////
/// Checker 
///////////////////////////////////////////////////////////
generate
  if (INT_TYPE == "TX") begin
    initial begin
      while (!ready_o) begin
        @(posedge sync_clk_i);
      end
      mipi_dphy_tx_checker_task;
    end
  end
endgenerate

///////////////////////////////////////////////////////////
/// Submodule Instansation *
///////////////////////////////////////////////////////////
`include "dut_inst.v"

GSR
GSR_INST (
  .GSR_N (1'b1),
  .CLK   (1'b0)
);

///////////////////////////////////////////////////////////
/// Task declaration
///////////////////////////////////////////////////////////
/// **************** Tx ***********************
task mipi_dphy_tx_task(
  );
  begin
    sync_reset_task;
    wait_for_ready_task;
    if (CIL_BYPASS == "CIL_BYPASSED") begin
      for (i = 0; i < FRAME_CNT; i = i + 1) begin
        drive_data_for_tx_task(2'd0,P1DT,i);
        for (j = 0; j < FRAME_CNT; j = j + 1) begin
          drive_data_for_tx_task(2'd0,P2DT,j);
          drive_data_for_tx_task(2'd0,DATATYPE,(PYLD_WDCNT));
          drive_data_for_tx_task(2'd0,P3DT,j);
        end
        drive_data_for_tx_task(2'd0,P4DT,i);
      end
    end
    else begin
      for (i = 0; i < FRAME_CNT; i = i + 1) begin
        drive_data_for_tx_task_cil(2'd0,P1DT,i);
        for (j = 0; j < FRAME_CNT; j = j + 1) begin
          drive_data_for_tx_task_cil(2'd0,P2DT,j);
          drive_data_for_tx_task_cil(2'd0,DATATYPE,(PYLD_WDCNT));
          drive_data_for_tx_task_cil(2'd0,P3DT,j);
        end
        drive_data_for_tx_task_cil(2'd0,P4DT,i);
      end
    end
  end
endtask

task drive_data_for_tx_task( 
  input [ 1:0] vc,
  input [ 5:0] dt,
  input [15:0] wc
);
  reg [2*8-1:0] packet_type;
  reg    [15:0] data_cycle;
  reg    [31:0] header;

  begin
    $display("Start Data Transmition");
    $display("Virtual Chanel is %h,Data Type is %h,Word Count is %h,",vc,dt,wc);
    /// LP sequence
    #(4*TLPX);
    lp_tx_en_i      = 1'd1;
    lp_tx_data_en_i = 1'd1;
    lp_tx_data_p_i  = {NUM_LANE{1'd1}};
    lp_tx_data_n_i  = {NUM_LANE{1'd1}};
    lp_tx_clk_p_i   = 1'd1;
    lp_tx_clk_n_i   = 1'd1;
    #(TLPX);
    lp_tx_clk_p_i   = 1'd0;
    lp_tx_clk_n_i   = 1'd1;
    #(TLPX);
    lp_tx_clk_p_i   = 1'd0;
    lp_tx_clk_n_i   = 1'd0;
    #(TPREPARE);
    lp_tx_clk_p_i   = 1'd0;
    lp_tx_clk_n_i   = 1'd1;
    #(30);
    lp_tx_en_i      = 1'd0;
    hs_tx_clk_en_i  = 1'd1;
    #(THSZERO-30);
    lp_tx_data_p_i  = {NUM_LANE{1'd0}};
    lp_tx_data_n_i  = {NUM_LANE{1'd1}};
    #(TLPX);
    lp_tx_data_p_i  = {NUM_LANE{1'd0}};
    lp_tx_data_n_i  = {NUM_LANE{1'd0}};
    #(TPREPARE);
    lp_tx_data_en_i = 1'd0;
    hs_tx_en_i      = 1'd1;
    hs_tx_data_i    =  'd0;
    hs_tx_data_en_i = 1'd1;
    #(THSZERO);
    /// Sync char and header
    compute_ecc({vc,dt,wc},ecc);
    @(posedge clk_byte_o);
    if (GEAR == 16) begin
      if (NUM_LANE == 4) begin
        hs_tx_data_i = {2'd0,ecc,8'hB8,wc[15:8],8'hB8,wc[7:0],8'hB8,vc,dt,8'hB8};
      end else
      if (NUM_LANE == 2) begin
        hs_tx_data_i = {16'hB800,16'hB800};
        @(posedge clk_byte_o);
        hs_tx_data_i = {2'd0,ecc,wc[7:0],wc[15:8],vc,dt};
      end else
      if (NUM_LANE == 1) begin
        hs_tx_data_i = {16'hB800};
        @(posedge clk_byte_o);
        hs_tx_data_i = {wc[7:0],vc,dt};
        @(posedge clk_byte_o);
        hs_tx_data_i = {2'd0,ecc,wc[15:8]};
      end 
    end else 
    if (GEAR == 8) begin
      if (NUM_LANE == 4) begin
        hs_tx_data_i = {8'hB8,8'hB8,8'hB8,8'hB8};
        @(posedge clk_byte_o);
        hs_tx_data_i = {2'd0,ecc,wc,vc,dt};
      end else
      if (NUM_LANE == 2) begin
        hs_tx_data_i = {8'hB8,8'hB8};
        @(posedge clk_byte_o);
        hs_tx_data_i = {wc[7:0],vc,dt};
        @(posedge clk_byte_o);
        hs_tx_data_i = {2'd0,ecc,wc[15:8]};
      end else
      if (NUM_LANE == 1) begin
        hs_tx_data_i = 8'hB8;
        @(posedge clk_byte_o);
        hs_tx_data_i = {vc,dt};
        @(posedge clk_byte_o);
        hs_tx_data_i = wc[7:0];
        @(posedge clk_byte_o);
        hs_tx_data_i = wc[15:8];
        @(posedge clk_byte_o);
        hs_tx_data_i = {2'd0,ecc};
      end
    end
    /// Write in file header
    header = {2'd0,ecc,wc,vc,dt};
    if (HEADER_CHK == "ON") begin
      $fwrite(dut_data,"%h\n",header);
    end
    /// Detecting LP or SP :)
    if (INTF == "CSI2_APP") begin
      if (dt == 6'h0 | dt == 6'h1 | dt == 6'h2 | dt == 6'h3) begin
        packet_type = "SP";
      end 
      else begin
        packet_type = "LP";
      end
    end else
    if (INTF == "DSI_APP") begin
      if (dt == 6'h1 | dt == 6'h11 | dt == 6'h21 | dt == 6'h31) begin
        packet_type = "SP";
      end
      else begin
        packet_type = "LP";
      end
    end
   /// Byte data if needed
    if (packet_type == "LP") begin
      data_cycle = (wc / (NUM_LANE * GEAR/8));
      repeat (data_cycle) begin
        @(posedge clk_byte_o);
        hs_tx_data_i = $random;
        if (GEAR == 8) begin
          $fwrite(dut_data,"%h\n",hs_tx_data_i);
        end
        else if (GEAR == 16) begin
          if (NUM_LANE == 4) begin
            $fwrite(dut_data,"%h\n%h\n",
            {hs_tx_data_i[55:48],hs_tx_data_i[39:32],hs_tx_data_i[23:16],hs_tx_data_i[ 7:0]},
            {hs_tx_data_i[63:56],hs_tx_data_i[47:40],hs_tx_data_i[31:24],hs_tx_data_i[15:8]});
          end else
          if (NUM_LANE == 2) begin
            $fwrite(dut_data,"%h\n%h\n",{hs_tx_data_i[23:16],hs_tx_data_i[7:0]},{hs_tx_data_i[31:24],hs_tx_data_i[15:8]});
          end else
          if (NUM_LANE == 1) begin
            $fwrite(dut_data,"%h\n%h\n",hs_tx_data_i[7:0],hs_tx_data_i[15:8]);
          end
        end
      end
    end
    /// Trail data
    @(posedge clk_byte_o);
    if (GEAR == 16) begin
      if (NUM_LANE == 4) begin
        hs_tx_data_i  = {{16{!hs_tx_data_i[63]}},{16{!hs_tx_data_i[47]}},{16{!hs_tx_data_i[31]}},{16{!hs_tx_data_i[15]}}};
      end else
      if (NUM_LANE == 2) begin
        hs_tx_data_i  = {{16{!hs_tx_data_i[31]}},{16{!hs_tx_data_i[15]}}};
      end else
      if (NUM_LANE == 1) begin
        hs_tx_data_i  = {16{!hs_tx_data_i[15]}};
      end
    end else
    if (GEAR == 8) begin
      if (NUM_LANE == 4) begin
        hs_tx_data_i  = {{8{!hs_tx_data_i[31]}},{8{!hs_tx_data_i[23]}},{8{!hs_tx_data_i[15]}},{8{!hs_tx_data_i[7]}}};
      end else
      if (NUM_LANE == 2) begin
        hs_tx_data_i  = {{8{!hs_tx_data_i[15]}},{8{!hs_tx_data_i[7]}}};
      end else
      if (NUM_LANE == 1) begin
        hs_tx_data_i  = {8{!hs_tx_data_i[7]}};
      end
    end
    #(1000);
    #(TTRAIL);
    hs_tx_data_en_i = 1'd0;
    hs_tx_en_i      = 1'd0;
    hs_tx_data_i    =  'd0;
    /// End
    lp_tx_en_i      = 1'd1;
    lp_tx_data_en_i = 1'd1;
    lp_tx_data_p_i  = {NUM_LANE{1'd1}};
    lp_tx_data_n_i  = {NUM_LANE{1'd1}};
    #(100);
    hs_tx_clk_en_i  = 1'd0;
    lp_tx_clk_p_i   = 1'd1;
    lp_tx_clk_n_i   = 1'd1;
    $display("Finish Data Transmit");
  end
endtask

task drive_data_for_tx_task_cil( 
  input [ 1:0] vc,
  input [ 5:0] dt,
  input [15:0] wc
);
  reg [2*8-1:0] packet_type;
  reg    [15:0] data_cycle;
  reg    [31:0] header;
  begin    
    $display("Start Data Transmition");
    $display("Virtual Chanel is %h,Data Type is %h,Word Count is %h,",vc,dt,wc);
    compute_ecc({vc,dt,wc},ecc);
    hs_tx_data_en_i = 1'd1;
    if (NUM_LANE == 1 & GEAR ==  8) begin
      hs_tx_data_i  = {vc,dt};
      @(posedge &(hs_tx_cil_ready_o));
      @(posedge clk_byte_o);
      hs_tx_data_i  = wc[7:0];
      @(posedge clk_byte_o);
      hs_tx_data_i  = wc[15:8];
      @(posedge clk_byte_o);
      hs_tx_data_i  = {2'd0,ecc};
      // @(posedge clk_byte_o);
    end else
    if (NUM_LANE == 2 & GEAR ==  8) begin
      hs_tx_data_i  = {wc[7:0],vc,dt};
      @(posedge &(hs_tx_cil_ready_o));
      @(posedge clk_byte_o);
      hs_tx_data_i  = {2'd0,ecc,wc[15:8]};
      // @(posedge clk_byte_o);
    end else
    if (NUM_LANE == 4 & GEAR ==  8) begin
      hs_tx_data_i  = {2'd0,ecc,wc,vc,dt};
      @(posedge &(hs_tx_cil_ready_o));
      // @(posedge clk_byte_o);
    end else
    if (NUM_LANE == 1 & GEAR == 16) begin
      hs_tx_data_i  = {wc[7:0],vc,dt};
      @(posedge &(hs_tx_cil_ready_o));
      @(posedge clk_byte_o);
      hs_tx_data_i  = {2'd0,ecc,wc[15:8]};
      // @(posedge clk_byte_o);
    end else
    if (NUM_LANE == 2 & GEAR == 16) begin
      hs_tx_data_i  = {2'd0,ecc,wc[7:0],wc[15:8],vc,dt};
      @(posedge &(hs_tx_cil_ready_o));
      // @(posedge clk_byte_o);
    end else
    if (NUM_LANE == 4 & GEAR == 16) begin
      hs_tx_data_r  = $random;  
      hs_tx_data_i  = {hs_tx_data_r[56:49],2'd0,ecc,hs_tx_data_r[39:32],wc[15:8],hs_tx_data_r[23:16],wc[7:0],hs_tx_data_r[7:0],vc,dt};
      @(posedge &(hs_tx_cil_ready_o));
      // @(posedge clk_byte_o);
    end
    ///
    header = {2'd0,ecc,wc,vc,dt};
    if (HEADER_CHK == "ON") begin
      $fwrite(dut_data,"%h\n",header);
    end
    /// Detecting LP or SP :)
    if (INTF == "CSI2_APP") begin
      if (dt == 6'h0 | dt == 6'h1 | dt == 6'h2 | dt == 6'h3) begin
        packet_type = "SP";
      end 
      else begin
        packet_type = "LP";
      end
    end else
    if (INTF == "DSI_APP") begin
      if (dt == 6'h1 | dt == 6'h11 | dt == 6'h21 | dt == 6'h31) begin
        packet_type = "SP";
      end
      else begin
        packet_type = "LP";
      end
    end
   /// Byte data if needed
    if (packet_type == "LP") begin
      data_cycle   = (wc / (NUM_LANE * GEAR/8));
      data_cycle_r = (wc / (NUM_LANE * GEAR/8));
      repeat (data_cycle) begin
        @(posedge clk_byte_o);
        hs_tx_data_i = $random;
        if (GEAR == 8) begin
          $fwrite(dut_data,"%h\n",hs_tx_data_i);
        end
        else if (GEAR == 16) begin
          if (NUM_LANE == 4) begin
            if (data_cycle_r == (wc / (NUM_LANE * GEAR/8))) begin
              $fwrite(dut_data,"%h\n%h\n",
              {hs_tx_data_r[55:48],hs_tx_data_r[39:32],hs_tx_data_r[23:16],hs_tx_data_r[ 7:0]},
              {hs_tx_data_i[55:48],hs_tx_data_i[39:32],hs_tx_data_i[23:16],hs_tx_data_i[7:0]});
            end
            else begin
              $fwrite(dut_data,"%h\n%h\n",
              {hs_tx_data_r[63:56],hs_tx_data_r[47:40],hs_tx_data_r[31:24],hs_tx_data_r[15:8]},
              {hs_tx_data_i[55:48],hs_tx_data_i[39:32],hs_tx_data_i[23:16],hs_tx_data_i[7:0]});
            end
              hs_tx_data_r = hs_tx_data_i;
          end else
          if (NUM_LANE == 2) begin
            $fwrite(dut_data,"%h\n%h\n",{hs_tx_data_i[23:16],hs_tx_data_i[7:0]},{hs_tx_data_i[31:24],hs_tx_data_i[15:8]});
          end else
          if (NUM_LANE == 1) begin
            $fwrite(dut_data,"%h\n%h\n",hs_tx_data_i[7:0],hs_tx_data_i[15:8]);
          end
        end
        data_cycle_r = data_cycle_r - 1;
      end
    end
    /// Trail data
    @(posedge clk_byte_o);
    if (GEAR == 16) begin
      if (NUM_LANE == 4) begin
        hs_tx_data_i  = {{16{!hs_tx_data_i[63]}},{16{!hs_tx_data_i[47]}},{16{!hs_tx_data_i[31]}},{16{!hs_tx_data_i[15]}}};
      end else
      if (NUM_LANE == 2) begin
        hs_tx_data_i  = {{16{!hs_tx_data_i[31]}},{16{!hs_tx_data_i[15]}}};
      end else
      if (NUM_LANE == 1) begin
        hs_tx_data_i  = {16{!hs_tx_data_i[15]}};
      end
    end else
    if (GEAR == 8) begin
      if (NUM_LANE == 4) begin
        hs_tx_data_i  = {{8{!hs_tx_data_i[31]}},{8{!hs_tx_data_i[23]}},{8{!hs_tx_data_i[15]}},{8{!hs_tx_data_i[7]}}};
      end else
      if (NUM_LANE == 2) begin
        hs_tx_data_i  = {{8{!hs_tx_data_i[15]}},{8{!hs_tx_data_i[7]}}};
      end else
      if (NUM_LANE == 1) begin
        hs_tx_data_i  = {8{!hs_tx_data_i[7]}};
      end
    end
    #(TTRAIL);
    hs_tx_data_en_i = 1'd0;
    hs_tx_en_i      = 1'd0;
    hs_tx_data_i    =  'd0;
    /// End
    lp_tx_en_i      = 1'd1;
    lp_tx_data_en_i = 1'd1;
    lp_tx_data_p_i  = {NUM_LANE{1'd1}};
    lp_tx_data_n_i  = {NUM_LANE{1'd1}};
    #(100);
    hs_tx_clk_en_i  = 1'd0;
    lp_tx_clk_p_i   = 1'd1;
    lp_tx_clk_n_i   = 1'd1;
    $display("Finish Data Transmit");
    #(500);
  end
endtask

task mipi_dphy_tx_checker_task(
  );
  reg    [ 7:0] line0_deserialaizer;
  reg    [ 7:0] line1_deserialaizer;
  reg    [ 7:0] line2_deserialaizer;
  reg    [ 7:0] line3_deserialaizer;
  reg    [15:0] data_cycle;
  reg    [31:0] header;
  reg [8*2-1:0] packet_type;
  reg           in_process;
  begin
    while (1) begin
      in_process          = 1;
      line0_deserialaizer =  8'd0;
      line1_deserialaizer =  8'd0;
      line2_deserialaizer =  8'd0;
      line3_deserialaizer =  8'd0;
      data_cycle          = 16'd0;
      header              = 32'd0;
      packet_type         = "XX";
      while (data_p_io == {NUM_LANE{1'd1}} && data_n_io == {NUM_LANE{1'd1}}) begin
        @(clk_p_io);
      end
      while (!data_p_io && data_n_io) begin
        @(clk_p_io);
      end
      while (!data_p_io && !data_n_io) begin
        @(clk_p_io);
      end
      while (!data_p_io && data_n_io) begin
        @(clk_p_io);
      end
      /// Sync char
      while (line0_deserialaizer != 8'hB8) begin
        line0_deserialaizer = {data_p_io[0],line0_deserialaizer[7:1]};
        @(clk_p_io);
      end
      /// Header
      if (NUM_LANE == 4) begin
        for (h = 0; h <= 7; h = h + 1) begin
          header[ 7: 0] = {data_p_io[0],header[7:1]};
          header[15: 8] = {data_p_io[1],header[15:9]};
          header[23:16] = {data_p_io[2],header[23:17]};
          header[31:24] = {data_p_io[3],header[31:25]};
          @(clk_p_io);
        end
      end
      else if (NUM_LANE == 2) begin
        for (h = 0; h <= 7; h = h + 1) begin
          header[ 7: 0] = {data_p_io[0],header[7:1]};
          header[15: 8] = {data_p_io[1],header[15:9]};
          @(clk_p_io);
        end
        for (h = 0; h <= 7; h = h + 1) begin
          header[23:16] = {data_p_io[0],header[23:17]};
          header[31:24] = {data_p_io[1],header[31:25]};
          @(clk_p_io);
        end
      end
      else if (NUM_LANE == 1) begin
        for (h = 0; h <= 31; h = h + 1) begin
          header[31: 0] = {data_p_io[0],header[31:1]};
          @(clk_p_io);
        end
      end
      
      if (HEADER_CHK == "ON") begin
        $fwrite(model_data,"%h\n",header);
      end
      
      /// Detecting LP or SP :)
      if (INTF == "CSI2_APP") begin
        if (header[5:0] == 6'h0 | header[5:0] == 6'h1 | header[5:0] == 6'h2 | header[5:0] == 6'h3) begin
          packet_type = "SP";
        end 
        else begin
          packet_type = "LP";
        end
      end else
      if (INTF == "DSI_APP") begin
        if (header[5:0] == 6'h1 | header[5:0] == 6'h11 | header[5:0] == 6'h21 | header[5:0] == 6'h31) begin
          packet_type = "SP";
        end
        else begin
          packet_type = "LP";
        end
      end
      if (packet_type == "LP") begin
        /// Byte data
        data_cycle = header[23:8] / NUM_LANE;
        repeat (data_cycle) begin
          for (l = 0; l <= 7; l = l + 1) begin
            if (NUM_LANE == 4) begin
              line0_deserialaizer = {data_p_io[0],line0_deserialaizer[7:1]};
              line1_deserialaizer = {data_p_io[1],line1_deserialaizer[7:1]};
              line2_deserialaizer = {data_p_io[2],line2_deserialaizer[7:1]};
              line3_deserialaizer = {data_p_io[3],line3_deserialaizer[7:1]};
            end else
            if (NUM_LANE == 2) begin
              line0_deserialaizer = {data_p_io[0],line0_deserialaizer[7:1]};
              line1_deserialaizer = {data_p_io[1],line1_deserialaizer[7:1]};
            end else
            if (NUM_LANE == 1) begin
              line0_deserialaizer = {data_p_io[0],line0_deserialaizer[7:1]};
            end
            @(clk_p_io);
          end
            if (NUM_LANE == 4) begin
              $fwrite(model_data,"%h\n",{line3_deserialaizer[7:0],
                                        line2_deserialaizer[7:0],
                                        line1_deserialaizer[7:0],
                                        line0_deserialaizer[7:0]
                                        });
            end else
            if (NUM_LANE == 2) begin
              $fwrite(model_data,"%h\n",{
                                        line1_deserialaizer[7:0],
                                        line0_deserialaizer[7:0]
                                        });
            end else
            if (NUM_LANE == 1) begin
              $fwrite(model_data,"%h\n",{
                                        line0_deserialaizer[7:0]
                                        });
            end
        end
      end
      
      while (!(data_p_io && data_n_io)) begin
        @(clk_p_io);
      end
      in_process          = 0;
    end 
  end
endtask
/// **************** Rx ***********************
task mipi_dphy_rx_task(
  );
  begin
    sync_reset_task;
    wait_for_ready_task;
    if (CIL_BYPASS == "CIL_BYPASSED" & INT_TYPE == "RX") begin
        for (i = 0; i < FRAME_CNT; i = i + 1) begin
          drive_data_for_rx_cil_bypassed_task(2'd0,P1DT,i);
          for (j = 0; j < FRAME_CNT; j = j + 1) begin
            drive_data_for_rx_cil_bypassed_task(2'd0,P2DT,j);
            drive_data_for_rx_cil_bypassed_task(2'd0,DATATYPE,PYLD_WDCNT);
            drive_data_for_rx_cil_bypassed_task(2'd0,P3DT,j);
          end
          drive_data_for_rx_cil_bypassed_task(2'd0,P4DT,i);
        end
    end
    else begin	
        for (i = 0; i < FRAME_CNT; i = i + 1) begin
          drive_data_for_rx_task(2'd0,P1DT,i);
          for (j = 0; j < FRAME_CNT; j = j + 1) begin
            drive_data_for_rx_task(2'd0,P2DT,j);
            drive_data_for_rx_task(2'd0,DATATYPE,PYLD_WDCNT);
            drive_data_for_rx_task(2'd0,P3DT,j);
          end
          drive_data_for_rx_task(2'd0,P4DT,i);
        end
	end
  end
endtask

task drive_data_for_rx_task( 
  input [ 1:0] vc,
  input [ 5:0] dt,
  input [15:0] wc
);
  reg [2*8-1:0] packet_type;
  reg    [15:0] data_cycle;
  reg           clock_en;
  reg    [31:0] header;
  
  begin
    clock_en = 0;
    header   = 0;
    /// LP sequence
    clk_p_r  = 'd1;
    clk_n_r  = 'd1;
    data_p_r = 'hF;
    data_n_r = 'hF;
    #(4*TLPX);
    clk_p_r  = 1'd0;
    clk_n_r  = 1'd1;
    #(TLPX);
    clk_p_r  = 1'd0;
    clk_n_r  = 1'd0;
    #(TPREPARE);
    clk_p_r  = 1'd0;
    clk_n_r  = 1'd1;
	hs_rx_clk_en_i = 1'd1;
    #(THSZERO); 
    clock_en = 1;
    fork
      begin
        while (clock_en) begin
          clk_p_r = !clk_p_r;
          clk_n_r = !clk_n_r;
          #(PLL_CLOCK_PERIOD/2.0);
        end
      end
      begin
        #(TLPX);
        data_p_r = {NUM_LANE{1'd0}};
        data_n_r = {NUM_LANE{1'd1}};
        #(TLPX);
        data_p_r = {NUM_LANE{1'd0}};
        data_n_r = {NUM_LANE{1'd0}};
        #(TPREPARE);
        data_p_r = {NUM_LANE{1'd0}};
        data_n_r = {NUM_LANE{1'd1}};
		hs_rx_data_en_i = 1;
        hs_rx_en_i = 1;
		#(TSETTLE);
		hs_data_des_en_i = 1;
        #(THSZERO);
        /// Sync char
        #(PLL_CLOCK_PERIOD/4.0); /// For 90 degree delay
        for (k = 0; k < 8; k = k + 1) begin
          data_p_r = {NUM_LANE{ SYNC_CHAR[k]}};
          data_n_r = {NUM_LANE{!SYNC_CHAR[k]}};
          #(PLL_CLOCK_PERIOD/2.0);
        end
        /// Header
        compute_ecc({vc,dt,wc},ecc);
        header = {2'd0,ecc,wc,vc,dt};
        if (NUM_LANE == 4) begin
          for (k = 0; k < 8; k = k + 1) begin
            data_p_r[0] = header[ 0+k];
            data_p_r[1] = header[ 8+k];
            data_p_r[2] = header[16+k];
            data_p_r[3] = header[24+k];
            data_n_r    = ~data_p_r;
            #(PLL_CLOCK_PERIOD/2.0);
          end 
        end else 
        if (NUM_LANE == 2) begin
          for (k = 0; k < 8; k = k + 1) begin
            data_p_r[0] = header[ 0+k];
            data_p_r[1] = header[ 8+k];
            data_n_r    = ~data_p_r;
            #(PLL_CLOCK_PERIOD/2.0);
          end 
          for (k = 0; k < 8; k = k + 1) begin
            data_p_r[0] = header[16+k];
            data_p_r[0] = header[24+k];
            data_n_r    = ~data_p_r;
            #(PLL_CLOCK_PERIOD/2.0);
          end 
        end else 
        if (NUM_LANE == 1) begin
          for (k = 0; k < 31; k = k + 1) begin
            data_p_r[0] = header[ 0+k];
            data_n_r    = ~data_p_r;
            #(PLL_CLOCK_PERIOD/2.0);
          end
        end    
        /// Detecting LP or SP :)
        if (INTF == "CSI2_APP") begin
          if (dt == 6'h0 | dt == 6'h1 | dt == 6'h2 | dt == 6'h3) begin
            packet_type = "SP";
          end 
          else begin
            packet_type = "LP";
          end
        end else
        if (INTF == "DSI_APP") begin
          if (dt == 6'h1 | dt == 6'h11 | dt == 6'h21 | dt == 6'h31) begin
            packet_type = "SP";
          end
          else begin
            packet_type = "LP";
          end
        end
        /// Data if needed
        if (packet_type == "LP") begin
          data_cycle = wc/NUM_LANE;
          repeat (8*data_cycle) begin
            data_p_r = $random;
            data_n_r = ~data_p_r;
          #(PLL_CLOCK_PERIOD/2.0);
          end
        end
        ///Trail
        data_p_r  = ~data_p_r;
        data_n_r  = ~data_n_r;
        #(TTRAIL);  
        data_p_r  = {NUM_LANE{1'd1}};
        data_n_r  = {NUM_LANE{1'd1}};		
        hs_rx_data_en_i = 0;
		hs_data_des_en_i = 0;
        #(TTRAIL);  
        hs_rx_en_i = 0;
        clock_en  = 1'd0;
        clk_p_r   = 1'd1;
        clk_n_r   = 1'd1;		
        hs_rx_clk_en_i = 0;
      end
    join
    
    
  end
endtask

task drive_data_for_rx_cil_bypassed_task( 
  input [ 1:0] vc,
  input [ 5:0] dt,
  input [15:0] wc
);
  reg [2*8-1:0] packet_type;
  reg    [15:0] data_cycle;
  reg           clock_en;
  reg    [31:0] header;
  
  begin
    clock_en = 0;
    header   = 0;
    /// LP sequence
    clk_p_r  = 'd1;
    clk_n_r  = 'd1;
    data_p_r = 'hF;
    data_n_r = 'hF;
    #(100);
    clk_p_r  = 1'd0;
    clk_n_r  = 1'd1;
    #(TLPX);	
    clk_p_r  = 1'd0;
    clk_n_r  = 1'd0;
	#(T_CLK_TERM_EN);
	hs_rx_clk_en_i = 1'd1;
    #(T_CLK_PREPARE-T_CLK_TERM_EN);
    clk_p_r  = 1'd0;
    clk_n_r  = 1'd1;
    #(T_CLK_ZERO); 
    clock_en = 1;
    fork
      begin
        while (clock_en) begin
          clk_p_r = !clk_p_r;
          clk_n_r = !clk_n_r;
          #(PLL_CLOCK_PERIOD/2.0);
        end
      end
      begin
        #(T_CLK_PRE);
        data_p_r = {NUM_LANE{1'd0}};
        data_n_r = {NUM_LANE{1'd1}};
        #(TLPX);
        data_p_r = {NUM_LANE{1'd0}};
        data_n_r = {NUM_LANE{1'd0}};
        #(T_D_TERM_EN);		
		hs_rx_data_en_i = 1;
        #(T_HS_PREPARE-T_D_TERM_EN);
        data_p_r = {NUM_LANE{1'd0}};
        data_n_r = {NUM_LANE{1'd1}};
        hs_rx_en_i = 1;
		#(TSETTLE);
		hs_data_des_en_i = 1;
        #(T_HS_ZERO);
        /// Sync char
        //#(PLL_CLOCK_PERIOD/4.0); /// For 90 degree delay
        for (k = 0; k < 8; k = k + 1) begin
          data_p_r = {NUM_LANE{ SYNC_CHAR[k]}};
          data_n_r = {NUM_LANE{!SYNC_CHAR[k]}};
          #(PLL_CLOCK_PERIOD/2.0);
        end
        /// Header
        compute_ecc({vc,dt,wc},ecc);
        header = {2'd0,ecc,wc,vc,dt};
        if (NUM_LANE == 4) begin
          for (k = 0; k < 8; k = k + 1) begin
            data_p_r[0] = header[ 0+k];
            data_p_r[1] = header[ 8+k];
            data_p_r[2] = header[16+k];
            data_p_r[3] = header[24+k];
            data_n_r    = ~data_p_r;
            #(PLL_CLOCK_PERIOD/2.0);
          end 
        end else 
        if (NUM_LANE == 2) begin
          for (k = 0; k < 8; k = k + 1) begin
            data_p_r[0] = header[ 0+k];
            data_p_r[1] = header[ 8+k];
            data_n_r    = ~data_p_r;
            #(PLL_CLOCK_PERIOD/2.0);
          end 
          for (k = 0; k < 8; k = k + 1) begin
            data_p_r[0] = header[16+k];
            data_p_r[0] = header[24+k];
            data_n_r    = ~data_p_r;
            #(PLL_CLOCK_PERIOD/2.0);
          end 
        end else 
        if (NUM_LANE == 1) begin
          for (k = 0; k < 8; k = k + 1) begin
            data_p_r[0] = header[ 0+k];
            data_n_r    = ~data_p_r;
            #(PLL_CLOCK_PERIOD/2.0);
          end
        end    
        /// Detecting LP or SP :)
        if (INTF == "CSI2_APP") begin
          if (dt == 6'h0 | dt == 6'h1 | dt == 6'h2 | dt == 6'h3) begin
            packet_type = "SP";
          end 
          else begin
            packet_type = "LP";
          end
        end else
        if (INTF == "DSI_APP") begin
          if (dt == 6'h1 | dt == 6'h11 | dt == 6'h21 | dt == 6'h31) begin
            packet_type = "SP";
          end
          else begin
            packet_type = "LP";
          end
        end
        /// Data if needed
        if (packet_type == "LP") begin
          data_cycle = wc/NUM_LANE;
          repeat (8*data_cycle) begin
            data_p_r = $random;
            data_n_r = ~data_p_r;
          #(PLL_CLOCK_PERIOD/2.0);
          end
        end
        ///Trail
        data_p_r  = ~data_p_r;
        data_n_r  = ~data_n_r;
        #(T_HS_TRAIL);  		
        hs_rx_data_en_i = 0;
		hs_data_des_en_i = 0; 			
        data_p_r  = {NUM_LANE{1'd1}};
        data_n_r  = {NUM_LANE{1'd1}};
        hs_rx_en_i = 0;
        #(T_CLK_POST); 
        clock_en  = 1'd0;
        clk_p_r  = ~clk_p_r;
        clk_n_r  = ~clk_n_r;
		#(T_CLK_TRAIL);		
        clk_p_r   = 1'd1;
        clk_n_r   = 1'd1;		
        hs_rx_clk_en_i = 0;
		#(T_HS_EXIT);		
      end
    join    
  end
endtask

/// **************** Common ***********************
task sync_reset_task(
  );
  begin
    sync_rst_i = 1;
    pd_dphy_i  = 1;
    $display("***IP Reset***");
    repeat (100) begin
      @(posedge sync_clk_i);
    end
    $display("***Finish Reset ***");
    pd_dphy_i  = 0;
    sync_rst_i = 0;
  end
endtask

task wait_for_ready_task(
  );
  begin
    $display("Wait for Ready");
    while (!ready_o) begin
      @(posedge sync_clk_i);
    end
    @(posedge sync_clk_i);
    $display("IP Ready");
  end
endtask

task compute_ecc(
  input [23:0] d, 
  output [5:0] ecc_val
  );
  begin
    ecc_val[0] =d[0]^d[1]^d[2]^d[4]^d[5]^d[7]^d[10]^d[11]^d[13]^d[16]^d[20]^d[21]^d[22]^d[23];
    ecc_val[1] = d[0]^d[1]^d[3]^d[4]^d[6]^d[8]^d[10]^d[12]^d[14]^d[17]^d[20]^d[21]^d[22]^d[23];
    ecc_val[2] = d[0]^d[2]^d[3]^d[5]^d[6]^d[9]^d[11]^d[12]^d[15]^d[18]^d[20]^d[21]^d[22];
    ecc_val[3] = d[1]^d[2]^d[3]^d[7]^d[8]^d[9]^d[13]^d[14]^d[15]^d[19]^d[20]^d[21]^d[23];
    ecc_val[4] = d[4]^d[5]^d[6]^d[7]^d[8]^d[9]^d[16]^d[17]^d[18]^d[19]^d[20]^d[22]^d[23];
    ecc_val[5] = d[10]^d[11]^d[12]^d[13]^d[14]^d[15]^d[16]^d[17]^d[18]^d[19]^d[21]^d[22]^d[23];
  end
endtask

task data_check_t();// Task which compare two text files
  reg [63:0] D_true_res;
  reg [63:0] D_false_res;
  reg [63:0] D_file_1_value;
  reg [63:0] D_file_2_value;
  reg [63:0] D_file_1;
  reg [63:0] D_file_2;
  begin
    D_true_res       = 32'd0;
    D_false_res      = 32'd0;
    D_file_1_value   = 32'd0;
    D_file_2_value   = 32'd0;
    D_file_1         = $fopen("model_data.txt","r");
    D_file_2         = $fopen("dut_data.txt","r");
    #1;
    while ((!$feof(D_file_1) | !$feof(D_file_1))) begin
      #1;
      $fscanf(D_file_1,"%h\n",D_file_1_value);
      $fscanf(D_file_2,"%h\n",D_file_2_value);
      #1;
      if (D_file_1_value == D_file_2_value) begin
        D_true_res   = D_true_res + 1;
      end
      else begin
        D_false_res  = D_false_res + 1;
      end
    end
    $fclose(D_file_1);
    $fclose(D_file_2);
    if (D_false_res == 0 && D_true_res != 0 /*&& test_cntr > 32'b1*/) begin
      $display("***SIMULATION PASSED***");
    end
    else begin
      $display("***SIMULATION FAILED***");
    end
    $finish;
  end
endtask


always @ (posedge clk_test) begin
    rx_data_o <= hs_rx_data_o;
	if (hs_rx_data_o != rx_data_o) begin
	    test_cntr <= test_cntr + 32'b1;
	end
	else begin
	    test_cntr <= test_cntr;
	end
end
endmodule
//==============================================================================
// tb_top.v
//==============================================================================
`endif