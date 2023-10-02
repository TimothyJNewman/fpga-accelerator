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
// File                  : tb_top.v
// Title                 : Test bench for ddr3_sdram_phy
// Dependencies          : 1.
//                       : 2.
// Description           :
// =============================================================================
// =============================================================================

`ifndef TB_TOP
`define TB_TOP

`timescale 1 ps / 1 ps

`include "lscc_clk_rst_gen.v"
`include "lscc_timeout_gen.v"
`include "mem_model.v"
`include "dfi_master.v"

module tb_top();

`include "dut_params.v"
localparam RST_CNTR = 35000;
localparam TIME_OUT = 10000000;

wire                      clk_i;
wire [4*DQS_WIDTH-1:0]    dqs_chk_i;
wire                      rd_override_i;
wire                      rst_w;
wire                      rst_n_w;

// =================================================
// === CLOCK Synchronization module
// =================================================
wire                      eclk_i;
wire                      clk_stable_i;
wire                      dqsbuf_pause_i;
wire                      ddr_rst_i;
wire                      ddrdel_i;
wire                      ddrdel_br_i;
wire                      update_done_i;

wire                      sclk_o;
wire                      dll_update_o;

// =================================================
// === NON-DFI SIGNALS
// =================================================
wire                      mem_rst_n_i;
		                       
wire                      phy_init_act_o;
wire                      wl_act_o;
wire                      wl_err_o;
wire                      rt_err_o;

// =================================================
// === DFI Interface SIGNALS
// =================================================
wire                      dfi_rst_n_i;
wire [ADDR_WIDTH-1:0]     dfi_addr_i;
wire [2:0]                dfi_bank_i;
wire                      dfi_cas_n_i;
wire [CKE_WIDTH-1:0]      dfi_cke_i;
wire [CS_WIDTH-1:0]       dfi_cs_n_i;
wire [CS_WIDTH-1:0]       dfi_odt_i;
wire                      dfi_ras_n_i;
wire                      dfi_we_n_i;
wire [DATA_WIDTH-1:0]     dfi_wrdata_i;
wire                      dfi_wrdataen_i;
wire [BYTE_LANE-1:0]      dfi_wrdata_mask_i;
wire                      dfi_init_start_i;
							   
wire [DATA_WIDTH-1:0]     dfi_rddata_o;
wire                      dfi_init_complete_o;
wire                      dfi_rddata_valid_o;

// =================================================
// === DDR3 Interface SIGNALS
// =================================================
wire                      em_ddr_rst_n_o;
						   
wire [CLKO_WIDTH-1:0]     em_ddr_clk_o;
wire [CKE_WIDTH-1:0]      em_ddr_cke_o;
wire [ADDR_WIDTH-1:0]     em_ddr_addr_o;
wire [2:0]                em_ddr_ba_o;
wire [DDR_CS_WIDTH-1:0]   em_ddr_cs_n_o;
wire [DDR_CS_WIDTH-1:0]   em_ddr_odt_o;
wire                      em_ddr_cas_n_o;
wire                      em_ddr_ras_n_o;
wire                      em_ddr_we_n_o;
wire [DQS_WIDTH-1:0]      em_ddr_dm_o;
							   
wire [DQS_WIDTH-1:0]      em_ddr_dqs_io;
wire [DDR_DATA_WIDTH-1:0] em_ddr_data_io;

assign dfi_rst_n_i = rst_n_w;
assign mem_rst_n_i = rst_n_w;
assign ddr_rst_i   = rst_w;

`include "dut_inst.v"

GSR GSR_INST ( .GSR_N(1'b1), .CLK(1'b0));

lscc_clk_rst_gen # (
    .ECLK     (CLKOP_FREQ),
    .SYN_CLK  (50),
    .RST_CNTR (RST_CNTR)
) ClkRstGen (
    .eclk_o         (eclk_i),
    .sync_clk_o     (clk_i),
    .global_rst_o   (rst_w),
    .global_rst_n_o (rst_n_w)
);

lscc_timeout_gen # (
    .TIMEOUT (TIME_OUT)
) TimeOut (
    .clk_i (clk_i),
    .rst_i (rst_w)
);

wire [DQS_WIDTH-1:0] em_ddr_dqs_n_io = ~em_ddr_dqs_io;

mem_model # (
    .CLKO_WIDTH       (CLKO_WIDTH),
    .CKE_WIDTH        (CKE_WIDTH),
    .DDR_CS_WIDTH     (DDR_CS_WIDTH),
    .BANK_WIDTH       (3),
    .ROW_WIDTH        (ADDR_WIDTH),
    .DDR_DATA_WIDTH   (DDR_DATA_WIDTH),
    .DQS_WIDTH        (DQS_WIDTH),
    .TARGET_FREQUENCY (CLKOP_FREQ),
    .DQSW             (DQSW),
    .WRITE_LEVEL_EN   (WRITE_LEVEL_EN),
    .MEM_TYPE         (MEM_TYPE),
    .GEARING          (GEARING)
) MEM (
    .rst_n       (em_ddr_rst_n_o),
    .ddr_clk     (em_ddr_clk_o),
    .ddr_clk_n   (~em_ddr_clk_o),
    .ddr_cke     (em_ddr_cke_o),
    .ddr_cs_n    (em_ddr_cs_n_o),
    .ddr_odt     (em_ddr_odt_o),
				 
    .ddr_ras_n   (em_ddr_ras_n_o),
    .ddr_cas_n   (em_ddr_cas_n_o),
    .ddr_we_n    (em_ddr_we_n_o),
    .ddr_ba      (em_ddr_ba_o),
    .ddr_ad      (em_ddr_addr_o),
    .ddr_dqs     (em_ddr_dqs_io),
    .ddr_dqs_n   (em_ddr_dqs_n_io),
    .ddr_dq      (em_ddr_data_io),
    .ddr_dm_tdqs (em_ddr_dm_o)
);

dfi_master #(
    .ADDR_WIDTH (ADDR_WIDTH),
    .BA_WIDTH   (3),
    .CKE_WIDTH  (CKE_WIDTH),
    .CS_WIDTH   (CS_WIDTH),
    .DATA_WIDTH (DATA_WIDTH),
    .BYTE_LANE  (BYTE_LANE),
    .CLKOP_FREQ (CLKOP_FREQ),
    .GEARING    (GEARING),
    .MRS1_INIT  (MRS1_INIT),
    .MRS2_INIT  (MRS2_INIT),
    .MRS0_INIT  (MRS0_INIT)
) DFI_Master (
    .clk_i               (clk_i),

    .rst_i               (rst_w),
    .eclk_i              (eclk_i),
					     		    
    .clk_stable_o        (clk_stable_i),
    .dqsbuf_pause_o      (dqsbuf_pause_i),
    .update_done_o       (update_done_i),
					     		    
    .sclk_i              (sclk_o),
    .dll_update_i        (dll_update_o),
	                      				
    .phy_init_act_i      (phy_init_act_o),
    .wl_act_i            (wl_act_o),
    .wl_err_i            (wl_err_o),
    .rt_err_i            (rt_err_o),
					     
    .dfi_addr_o          (dfi_addr_i),
    .dfi_bank_o          (dfi_bank_i),
    .dfi_cas_n_o         (dfi_cas_n_i),
    .dfi_cke_o           (dfi_cke_i),
    .dfi_cs_n_o          (dfi_cs_n_i),
    .dfi_odt_o           (dfi_odt_i),
    .dfi_ras_n_o         (dfi_ras_n_i),
    .dfi_we_n_o          (dfi_we_n_i),
    .dfi_wrdata_o        (dfi_wrdata_i),
    .dfi_wrdataen_o      (dfi_wrdataen_i),
    .dfi_wrdata_mask_o   (dfi_wrdata_mask_i),
    .dfi_init_start_o    (dfi_init_start_i),
							 
    .dfi_rddata_i        (dfi_rddata_o),
    .dfi_init_complete_i (dfi_init_complete_o),
    .dfi_rddata_valid_i  (dfi_rddata_valid_o)    
);
endmodule
`endif