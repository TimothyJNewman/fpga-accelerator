// =============================================================================
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
// -----------------------------------------------------------------------------
//   Copyright (c) 2019 by Lattice Semiconductor Corporation
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
// Title                 :
// Dependencies          :
// Description           : Simple test for MDDR
// =============================================================================
//                        REVISION HISTORY
// Version               : 1.0.0.
// Author(s)             :
// Mod. Date             : 11.07.2019
// Changes Made          : Initial release.
// =============================================================================

`include "lscc_pll.v"

`timescale 100 fs / 100 fs

module tb_top();

`include "dut_params.v"

`define CLK_PERIOD_400    12500             // 400 mhz
//`define CLK_PERIOD_533     9380             // 533 mhz
`define CLK_PERIOD_533     9375             // 533 mhz
`define SYNC_CLK_PERIOD   100000            //

`define DELAY_00_VAL      0                 //
`define DELAY_01_VAL      8000              //
`define DELAY_10_VAL      16000             //
`define DELAY_11_VAL      24000             //

`define STATE_READ_TRAINING   1
`define STATE_READ_DELAY      2
`define STATE_WRITE_DELAY     3
`define STATE_WRITE_LEVELING  4
`define STATE_READ_DATA       6
`define STATE_WRITE_DATA      7
`define STATE_WR_DATA         8
`define STATE_INIT            9

genvar i;

integer a [NUM_DQS_GROUP-1:0];
integer b [NUM_DQS_GROUP-1:0];
integer c [NUM_DQS_GROUP-1:0];
integer d = 0;
integer k [NUM_DQS_GROUP-1:0];
integer n [NUM_DQS_GROUP-1:0];
integer u = 0;
integer x = 0;
integer z = 0;
integer m = 0;

localparam CLK_PERIOD        = (CLK_FREQ == 400) ? `CLK_PERIOD_400 : `CLK_PERIOD_533;
localparam DDR_CLK_PERIOD    = (CLK_FREQ == 400) ? `CLK_PERIOD_400 : `CLK_PERIOD_533;
localparam CLK_CODE          = (CLK_FREQ == 400) ? 9'd50 : 9'd37;
localparam SCLK_PERIOD       = CLK_PERIOD * GEARING * 2;
//localparam CLK_PERIOD        = `CLK_PERIOD_400;
//localparam DDR_CLK_PERIOD    = `CLK_PERIOD_400;
localparam PLL_REFCLK_PREIOD = 10000000/CLKI_FREQ;

localparam ODT_LEN  = (INTERFACE_TYPE == "LPDDR3") ? (NUM_CS*GEARING/2) : NUM_CS;
localparam CKE_LEN  = ((INTERFACE_TYPE == "LPDDR3") || (INTERFACE_TYPE == "LPDDR2")) ? (NUM_CS*GEARING/2) : NUM_CS;
localparam X4_WIDTH = (GEARING*GEARING/2);

reg                            slow_clk_r;
reg                            slow_clk_90_r;
reg                            slow_clk_180_r;
reg                        ddr_clk_r;
wire                       ddr_clk_w;
reg                            ddr_clk_90_r;
reg                            ddr_clk_180_r;
reg                            ddr_clk_270_r;

reg                     [63:0] exp_rd_dqs_dly_r       [NUM_DQS_GROUP-1:0];

reg                     [63:0] exp_wr_dqs_dly_r       [NUM_DQS_GROUP-1:0];
reg                            wr_del_rdy_r           [NUM_DQS_GROUP-1:0];
reg                      [3:0] wr_del_rdy_cnt_r       [NUM_DQS_GROUP-1:0];
reg                     [63:0] exp_wrlvl_dqs_dly_r    [NUM_DQS_GROUP-1:0];
reg                            wrlvl_del_rdy_r        [NUM_DQS_GROUP-1:0];
reg                      [3:0] wrlvl_del_rdy_cnt_r    [NUM_DQS_GROUP-1:0];
wire                    [63:0] dqswdelaybefore12_5pscell_w [NUM_DQS_GROUP-1:0];
reg                     [63:0] dqswdelaybefore12_5pscell_r [NUM_DQS_GROUP-1:0];

reg                      [3:0] test_case_r;
reg        [NUM_DQS_GROUP-1:0] test_case_done_r;

wire                           eclk_i;
reg                            sync_clk_i;
reg                            sync_rst_i;
wire                           sclk_o;
reg                            pll_refclk_i;
reg                            pll_rst_n_i;
wire                           pll_lock_o;

realtime                       sclk_o_next_period        = 0.0;
realtime                       sclk_o_period             = 0.0;
realtime                       sclk_o_exp_period         = (CLK_PERIOD*2*GEARING);
reg                            sclk_o_rising_edge_count  = 0;


reg                            sync_update_i;
reg                            pll_lock_i;
reg                            pause_i;
reg                            ce_in_i;
reg                            ce_out_i;
reg                            ce_out_i_0_r;
reg                            ce_out_i_1_r;
reg                            ce_out_i_2_r;
reg                            ce_out_i_3_r;
wire                           ce_i;
reg                            sync_done_r;

reg                            selclk_i;

wire                     [7:0] dcnt_o;            //????
wire                           ready_o;
reg                            ready_o_0_r;
reg                            ready_o_1_r;
reg                            ready_o_2_r;
reg                            ready_o_3_r;
reg                            ready_o_4_r;
reg              [GEARING-1:0] dq_outen_n_i;
reg              [GEARING-1:0] dq_outen_n_i_0_r;
reg              [GEARING-1:0] dq_outen_n_i_1_r;
reg              [GEARING-1:0] dq_outen_n_i_2_r;
reg              [GEARING-1:0] dq_outen_n_i_3_r;
reg              [GEARING-1:0] dq_outen_n_i_4_r;
reg              [GEARING-1:0] dq_outen_n_i_5_r;
reg              [GEARING-1:0] dq_outen_n_i_6_r;
reg              [GEARING-1:0] dq_outen_n_i_7_r;
reg              [GEARING-1:0] dq_outen_n_i_8_r;
reg              [GEARING-1:0] dq_outen_n_i_9_r;
reg              [GEARING-1:0] dq_outen_n_i_10_r;
reg              [GEARING-1:0] dq_outen_n_i_11_r;
reg              [GEARING-1:0] dq_outen_n_i_12_r;
reg              [GEARING-1:0] dq_outen_n_i_13_r;
reg              [GEARING-1:0] dq_outen_n_i_14_r;
reg              [GEARING-1:0] dq_outen_n_i_15_r;
reg              [GEARING-1:0] dq_outen_n_i_16_r;
reg              [GEARING-1:0] dq_outen_n_i_17_r;
reg              [GEARING-1:0] dq_outen_n_i_18_r;

reg                            pause_cmd_i;       //????

wire                     [9:0] ca_o;              //MEM_IF
reg         [10*GEARING*2-1:0] ca_i;
reg         [10*GEARING*2-1:0] ca_i_r_0;
reg         [10*GEARING*2-1:0] ca_i_r_1;
reg         [10*GEARING*2-1:0] ca_i_r_2;
reg                      [9:0] exp_ca_o_r;
reg                      [9:0] exp_ca_o_0_r;
reg                      [9:0] exp_ca_o_1_r;
reg                      [9:0] exp_ca_o_2_r;
reg                      [9:0] exp_ca_o_3_r;
reg                      [9:0] exp_ca_o_4_r;
reg                      [9:0] exp_ca_o_5_r;
reg                      [9:0] exp_ca_o_6_r;
reg                      [9:0] exp_ca_o_7_r;
wire                     [9:0] exp_ca_o_w;
reg                      [3:0] ca_counter_r;

wire        [NUM_DDRCLK - 1:0] ck_o;              //MEM_IF
realtime                       ck_o_next_period        = 0.0;
realtime                       ck_o_exp_period         = DDR_CLK_PERIOD*2;
realtime                       ck_o_period             = 0.0;
reg                            ck_o_rising_edge_count  = 0;

reg            [GEARING - 1:0] csn_i[NUM_CS-1:0];
wire            [NUM_CS - 1:0] csn_o;             //MEM_IF
reg            [GEARING - 1:0] csn_i_r_0 [NUM_CS-1:0];
reg            [GEARING - 1:0] csn_i_r_1 [NUM_CS-1:0];
reg            [GEARING - 1:0] csn_i_r_2 [NUM_CS-1:0];
reg            [GEARING - 1:0] csn_i_r_3 [NUM_CS-1:0];
reg                      [3:0] csn_counter_r [NUM_CS-1:0];
wire            [NUM_CS - 1:0] exp_csn_o_w ;
reg             [NUM_CS - 1:0] exp_csn_o_r ;
reg             [NUM_CS - 1:0] exp_csn_o_0_r ;
reg             [NUM_CS - 1:0] exp_csn_o_1_r ;
reg             [NUM_CS - 1:0] exp_csn_o_2_r ;
reg             [NUM_CS - 1:0] exp_csn_o_3_r ;
wire              [NUM_CS-1:0] csn_din0_i;
wire              [NUM_CS-1:0] csn_din1_i;
wire              [NUM_CS-1:0] csn_din2_i;
wire              [NUM_CS-1:0] csn_din3_i;

wire        [ADDR_WIDTH - 1:0] addr_o;            //MEM_IF
reg [X4_WIDTH*ADDR_WIDTH- 1:0] addr_i;
reg [X4_WIDTH*ADDR_WIDTH- 1:0] addr_i_r_0;
reg [X4_WIDTH*ADDR_WIDTH- 1:0] addr_i_r_1;
reg [X4_WIDTH*ADDR_WIDTH- 1:0] addr_i_r_2;
reg                      [3:0] addr_counter_r;
reg         [ADDR_WIDTH - 1:0] exp_addr_o_r;
reg         [ADDR_WIDTH - 1:0] exp_addr_o_0_r;
reg         [ADDR_WIDTH - 1:0] exp_addr_o_1_r;
wire        [ADDR_WIDTH - 1:0] exp_addr_o_w;
wire         [ADDR_WIDTH-1:0] addr_din0_i;
wire         [ADDR_WIDTH-1:0] addr_din1_i;
wire         [ADDR_WIDTH-1:0] addr_din2_i;
wire         [ADDR_WIDTH-1:0] addr_din3_i;
wire         [ADDR_WIDTH-1:0] addr_din4_i;
wire         [ADDR_WIDTH-1:0] addr_din5_i;
wire         [ADDR_WIDTH-1:0] addr_din6_i;
wire         [ADDR_WIDTH-1:0] addr_din7_i;


wire          [BA_WIDTH - 1:0] ba_o;              //MEM_IF
reg  [X4_WIDTH*BA_WIDTH - 1:0] ba_i;
reg  [X4_WIDTH*BA_WIDTH - 1:0] ba_i_r_0;
reg  [X4_WIDTH*BA_WIDTH - 1:0] ba_i_r_1;
reg  [X4_WIDTH*BA_WIDTH - 1:0] ba_i_r_2;
reg                      [3:0] ba_counter_r;
reg           [BA_WIDTH - 1:0] exp_ba_o_r;
reg           [BA_WIDTH - 1:0] exp_ba_o_0_r;
reg           [BA_WIDTH - 1:0] exp_ba_o_1_r;
wire          [BA_WIDTH - 1:0] exp_ba_o_w;
wire            [BA_WIDTH-1:0] ba_din0_i;
wire            [BA_WIDTH-1:0] ba_din1_i;
wire            [BA_WIDTH-1:0] ba_din2_i;
wire            [BA_WIDTH-1:0] ba_din3_i;
wire            [BA_WIDTH-1:0] ba_din4_i;
wire            [BA_WIDTH-1:0] ba_din5_i;
wire            [BA_WIDTH-1:0] ba_din6_i;
wire            [BA_WIDTH-1:0] ba_din7_i;

wire                           casn_o;            //MEM_IF
reg             [X4_WIDTH-1:0] casn_i;
reg             [X4_WIDTH-1:0] casn_i_r_0;
reg             [X4_WIDTH-1:0] casn_i_r_1;
reg             [X4_WIDTH-1:0] casn_i_r_2;
reg                      [3:0] cas_counter_r;
reg                            exp_casn_o_r;
reg                            exp_casn_o_0_r;
reg                            exp_casn_o_1_r;
wire                           exp_casn_o_w;
wire                           casn_din0_i;
wire                           casn_din1_i;
wire                           casn_din2_i;
wire                           casn_din3_i;

wire                           rasn_o;            //MEM_IF
reg             [X4_WIDTH-1:0] rasn_i;
reg             [X4_WIDTH-1:0] rasn_i_r_0;
reg             [X4_WIDTH-1:0] rasn_i_r_1;
reg             [X4_WIDTH-1:0] rasn_i_r_2;
reg                      [3:0] ras_counter_r;
reg                            exp_rasn_o_r;
reg                            exp_rasn_o_0_r;
reg                            exp_rasn_o_1_r;
wire                           exp_rasn_o_w;
wire                           rasn_din0_i;
wire                           rasn_din1_i;

wire                           wen_o;             //MEM_IF
reg             [X4_WIDTH-1:0] wen_i;
reg             [X4_WIDTH-1:0] wen_i_r_0;
reg             [X4_WIDTH-1:0] wen_i_r_1;
reg             [X4_WIDTH-1:0] wen_i_r_2;
reg                      [3:0] wen_counter_r;
reg                            exp_wen_o_r;
reg                            exp_wen_o_0_r;
reg                            exp_wen_o_1_r;
wire                           exp_wen_o_w;
wire                           wen_din0_i;
wire                           wen_din1_i;
wire                           wen_din2_i;
wire                           wen_din3_i;

wire              [NUM_CS-1:0] odt_o;             //MEM_IF
reg      [GEARING*ODT_LEN-1:0] odt_i;
reg      [GEARING*ODT_LEN-1:0] odt_i_r_0;
reg      [GEARING*ODT_LEN-1:0] odt_i_r_1;
reg      [GEARING*ODT_LEN-1:0] odt_i_r_2;
reg                      [3:0] odt_counter_r;
wire              [NUM_CS-1:0] exp_odt_o_w;
reg               [NUM_CS-1:0] exp_odt_o_r;
reg               [NUM_CS-1:0] exp_odt_o_0_r;
reg               [NUM_CS-1:0] exp_odt_o_1_r;
reg               [NUM_CS-1:0] exp_odt_o_2_r;
reg               [NUM_CS-1:0] exp_odt_o_3_r;
reg               [NUM_CS-1:0] exp_odt_o_4_r;
reg               [NUM_CS-1:0] exp_odt_o_5_r;
reg               [NUM_CS-1:0] exp_odt_o_6_r;
reg               [NUM_CS-1:0] exp_odt_o_7_r;
wire             [ODT_LEN-1:0] odt_din0_i;
wire             [ODT_LEN-1:0] odt_din1_i;
wire             [ODT_LEN-1:0] odt_din2_i;
wire             [ODT_LEN-1:0] odt_din3_i;
wire             [ODT_LEN-1:0] odt_din4_i;
wire             [ODT_LEN-1:0] odt_din5_i;
wire             [ODT_LEN-1:0] odt_din6_i;
wire             [ODT_LEN-1:0] odt_din7_i;

wire            [NUM_CS - 1:0] cke_o;             //MEM_IF
reg            [2*CKE_LEN-1:0] cke_i;
reg            [2*CKE_LEN-1:0] cke_i_r_0;
reg            [2*CKE_LEN-1:0] cke_i_r_1;
reg            [2*CKE_LEN-1:0] cke_i_r_2;
reg                      [3:0] cke_counter_r;
wire              [NUM_CS-1:0] exp_cke_o_w;
reg               [NUM_CS-1:0] exp_cke_o_r;
reg               [NUM_CS-1:0] exp_cke_o_0_r;
reg               [NUM_CS-1:0] exp_cke_o_1_r;
reg               [NUM_CS-1:0] exp_cke_o_2_r;
reg               [NUM_CS-1:0] exp_cke_o_3_r;
reg               [NUM_CS-1:0] exp_cke_o_4_r;
reg               [NUM_CS-1:0] exp_cke_o_5_r;
reg               [NUM_CS-1:0] exp_cke_o_6_r;
reg               [NUM_CS-1:0] exp_cke_o_7_r;
wire             [CKE_LEN-1:0] cke_din0_i;
wire             [CKE_LEN-1:0] cke_din1_i;
wire             [CKE_LEN-1:0] cke_din2_i;
wire             [CKE_LEN-1:0] cke_din3_i;
wire             [CKE_LEN-1:0] cke_din4_i;
wire             [CKE_LEN-1:0] cke_din5_i;
wire             [CKE_LEN-1:0] cke_din6_i;
wire             [CKE_LEN-1:0] cke_din7_i;

wire        [16*GEARING - 1:0] data_dqs0_o;
wire        [16*GEARING - 1:0] data_dqs1_o;
wire        [16*GEARING - 1:0] data_dqs2_o;
wire        [16*GEARING - 1:0] data_dqs3_o;
wire        [16*GEARING - 1:0] data_dqs4_o;
wire        [16*GEARING - 1:0] data_dqs5_o;
wire        [16*GEARING - 1:0] data_dqs6_o;
wire        [16*GEARING - 1:0] data_dqs7_o;
wire        [16*GEARING - 1:0] data_dqs8_o;
wire        [16*GEARING - 1:0] data_dqs_o[8:0];

wire        [16*GEARING - 1:0] exp_data_dqs_o_w[8:0];
reg         [16*GEARING - 1:0] exp_data_dqs_o_r[8:0];
reg         [16*GEARING - 1:0] exp_data_dqs_o_r_0[8:0];
reg         [16*GEARING - 1:0] exp_data_dqs_o_r_1[8:0];
reg         [16*GEARING - 1:0] exp_data_dqs_o_r_2[8:0];
reg         [16*GEARING - 1:0] exp_data_dqs_o_r_3[8:0];
reg         [16*GEARING - 1:0] exp_data_dqs_o_r_4[8:0];
reg         [16*GEARING - 1:0] exp_data_dqs_o_r_5[8:0];
reg         [16*GEARING - 1:0] exp_data_dqs_o_r_6[8:0];
reg         [16*GEARING - 1:0] exp_data_dqs_o_r_7[8:0];
reg         [16*GEARING - 1:0] exp_data_dqs_o_r_8[8:0];
reg         [16*GEARING - 1:0] exp_data_dqs_o_r_9[8:0];
reg                      [7:0] exp_data_delay_counter_r[NUM_DQS_GROUP-1:0];
reg                      [7:0] rx_data_counter_r [NUM_DQS_GROUP-1:0];

wire        [16*GEARING - 1:0] data_dqs0_i;
wire        [16*GEARING - 1:0] data_dqs1_i;
wire        [16*GEARING - 1:0] data_dqs2_i;
wire        [16*GEARING - 1:0] data_dqs3_i;
wire        [16*GEARING - 1:0] data_dqs4_i;
wire        [16*GEARING - 1:0] data_dqs5_i;
wire        [16*GEARING - 1:0] data_dqs6_i;
wire        [16*GEARING - 1:0] data_dqs7_i;
wire        [16*GEARING - 1:0] data_dqs8_i;
reg         [16*GEARING - 1:0] data_dqs_i[8:0];

reg         [16*GEARING - 1:0] data_i_r_0[8:0];
reg         [16*GEARING - 1:0] data_i_r_1[8:0];
reg         [16*GEARING - 1:0] data_i_r_2[8:0];
reg         [16*GEARING - 1:0] data_i_r_3[8:0];
reg                      [3:0] data_counter_r[8:0];


wire                           dm_dqs0_o;             //MEM_IF
wire                           dm_dqs1_o;             //MEM_IF
wire                           dm_dqs2_o;             //MEM_IF
wire                           dm_dqs3_o;             //MEM_IF
wire                           dm_dqs4_o;             //MEM_IF
wire                           dm_dqs5_o;             //MEM_IF
wire                           dm_dqs6_o;             //MEM_IF
wire                           dm_dqs7_o;             //MEM_IF
wire                           dm_dqs8_o;             //MEM_IF
wire                           dm_o[8:0];
reg          [2*GEARING - 1:0] dm_i_r_0[8:0];
reg          [2*GEARING - 1:0] dm_i_r_1[8:0];
reg          [2*GEARING - 1:0] dm_i_r_2[8:0];
reg          [2*GEARING - 1:0] dm_i_r_3[8:0];
reg                      [3:0] dm_counter_r[8:0];
wire                           exp_dm_o_w[8:0];
reg                            exp_dm_o_0_r[8:0];
reg                            exp_dm_o_1_r[8:0];
reg                            exp_dm_o_2_r[8:0];
reg                            exp_dm_o_3_r[8:0];
reg                            exp_dm_o_4_r[8:0];
reg                            exp_dm_o_5_r[8:0];
reg                            exp_dm_o_6_r[8:0];
reg                            exp_dm_o_7_r[8:0];
reg                            exp_dm_o_8_r[8:0];
reg                            exp_dm_o_r[8:0];
wire         [2*GEARING - 1:0] data_mask_dqs0_i;
wire         [2*GEARING - 1:0] data_mask_dqs1_i;
wire         [2*GEARING - 1:0] data_mask_dqs2_i;
wire         [2*GEARING - 1:0] data_mask_dqs3_i;
wire         [2*GEARING - 1:0] data_mask_dqs4_i;
wire         [2*GEARING - 1:0] data_mask_dqs5_i;
wire         [2*GEARING - 1:0] data_mask_dqs6_i;
wire         [2*GEARING - 1:0] data_mask_dqs7_i;
wire         [2*GEARING - 1:0] data_mask_dqs8_i;
reg          [2*GEARING - 1:0] data_mask_i[8:0];

wire                     [3:0] rd_clksel_dqs0_i;       //???
wire                     [3:0] rd_clksel_dqs1_i;       //???
wire                     [3:0] rd_clksel_dqs2_i;       //???
wire                     [3:0] rd_clksel_dqs3_i;       //???
wire                     [3:0] rd_clksel_dqs4_i;       //???
wire                     [3:0] rd_clksel_dqs5_i;       //???
wire                     [3:0] rd_clksel_dqs6_i;       //???
wire                     [3:0] rd_clksel_dqs7_i;       //???
wire                     [3:0] rd_clksel_dqs8_i;       //???
reg                      [3:0] rd_clksel_dqs_i [8:0];  //???

wire                          rd_dir_dqs0_i;
wire                          rd_dir_dqs1_i;
wire                          rd_dir_dqs2_i;
wire                          rd_dir_dqs3_i;
wire                          rd_dir_dqs4_i;
wire                          rd_dir_dqs5_i;
wire                          rd_dir_dqs6_i;
wire                          rd_dir_dqs7_i;
wire                          rd_dir_dqs8_i;
reg                           rd_dir_dqs_i[8:0];

wire                          rd_cout_dqs0_o;
wire                          rd_cout_dqs1_o;
wire                          rd_cout_dqs2_o;
wire                          rd_cout_dqs3_o;
wire                          rd_cout_dqs4_o;
wire                          rd_cout_dqs5_o;
wire                          rd_cout_dqs6_o;
wire                          rd_cout_dqs7_o;
wire                          rd_cout_dqs8_o;
wire                          rd_cout_dqs_o[8:0];
reg                           rd_cout_dqs_o_r[8:0];


wire                          rd_loadn_dqs0_i;
wire                          rd_loadn_dqs1_i;
wire                          rd_loadn_dqs2_i;
wire                          rd_loadn_dqs3_i;
wire                          rd_loadn_dqs4_i;
wire                          rd_loadn_dqs5_i;
wire                          rd_loadn_dqs6_i;
wire                          rd_loadn_dqs7_i;
wire                          rd_loadn_dqs8_i;
reg                           rd_loadn_dqs_i[8:0];

wire                    [3:0] rd_dqs0_i;           //???
wire                    [3:0] rd_dqs1_i;           //???
wire                    [3:0] rd_dqs2_i;           //???
wire                    [3:0] rd_dqs3_i;           //???
wire                    [3:0] rd_dqs4_i;           //???
wire                    [3:0] rd_dqs5_i;           //???
wire                    [3:0] rd_dqs6_i;           //???
wire                    [3:0] rd_dqs7_i;           //???
wire                    [3:0] rd_dqs8_i;           //???
reg                     [3:0] rd_i[8:0];           //???

wire                          rd_move_dqs0_i;
wire                          rd_move_dqs1_i;
wire                          rd_move_dqs2_i;
wire                          rd_move_dqs3_i;
wire                          rd_move_dqs4_i;
wire                          rd_move_dqs5_i;
wire                          rd_move_dqs6_i;
wire                          rd_move_dqs7_i;
wire                          rd_move_dqs8_i;
reg                           rd_move_dqs_i[8:0];
reg                           rd_move_dqs_r[8:0];
reg                     [9:0] rd_code_r   [NUM_DQS_GROUP-1:0];
reg                     [9:0] rd_code_r_0 [NUM_DQS_GROUP-1:0];
reg                     [9:0] rd_code_r_1 [NUM_DQS_GROUP-1:0];
reg                     [9:0] rd_code_r_2 [NUM_DQS_GROUP-1:0];
reg                     [9:0] rd_code_r_3 [NUM_DQS_GROUP-1:0];
reg                     [9:0] rd_code_r_4 [NUM_DQS_GROUP-1:0];
reg                     [9:0] rd_code_r_5 [NUM_DQS_GROUP-1:0];
reg                    [10:0] rd_timeout_r[NUM_DQS_GROUP-1:0];


wire                          wr_dir_dqs0_i;
wire                          wr_dir_dqs1_i;
wire                          wr_dir_dqs2_i;
wire                          wr_dir_dqs3_i;
wire                          wr_dir_dqs4_i;
wire                          wr_dir_dqs5_i;
wire                          wr_dir_dqs6_i;
wire                          wr_dir_dqs7_i;
wire                          wr_dir_dqs8_i;
reg                           wr_dir_dqs_i[8:0];

wire                          wr_loadn_dqs0_i;
wire                          wr_loadn_dqs1_i;
wire                          wr_loadn_dqs2_i;
wire                          wr_loadn_dqs3_i;
wire                          wr_loadn_dqs4_i;
wire                          wr_loadn_dqs5_i;
wire                          wr_loadn_dqs6_i;
wire                          wr_loadn_dqs7_i;
wire                          wr_loadn_dqs8_i;
reg                           wr_loadn_dqs_i[8:0];

wire                          wr_cout_dqs0_o;
wire                          wr_cout_dqs1_o;
wire                          wr_cout_dqs2_o;
wire                          wr_cout_dqs3_o;
wire                          wr_cout_dqs4_o;
wire                          wr_cout_dqs5_o;
wire                          wr_cout_dqs6_o;
wire                          wr_cout_dqs7_o;
wire                          wr_cout_dqs8_o;
wire                          wr_cout_dqs_o[8:0];
reg                           wr_cout_dqs_o_r[8:0];

wire                          wr_move_dqs0_i;
wire                          wr_move_dqs1_i;
wire                          wr_move_dqs2_i;
wire                          wr_move_dqs3_i;
wire                          wr_move_dqs4_i;
wire                          wr_move_dqs5_i;
wire                          wr_move_dqs6_i;
wire                          wr_move_dqs7_i;
wire                          wr_move_dqs8_i;
reg                           wr_move_dqs_i[8:0];
reg                           wr_move_dqs_r[8:0];
reg                     [9:0] wr_code_r [NUM_DQS_GROUP-1:0];
reg                     [9:0] wr_code_r_0 [NUM_DQS_GROUP-1:0];
reg                     [9:0] wr_code_r_1 [NUM_DQS_GROUP-1:0];
reg                     [9:0] wr_code_r_2 [NUM_DQS_GROUP-1:0];
reg                     [9:0] wr_code_r_3 [NUM_DQS_GROUP-1:0];
reg                     [9:0] wr_code_r_4 [NUM_DQS_GROUP-1:0];
reg                     [9:0] wr_code_r_5 [NUM_DQS_GROUP-1:0];
reg                     [9:0] wr_code_r_6 [NUM_DQS_GROUP-1:0];
reg                    [10:0] wr_timeout_r[NUM_DQS_GROUP-1:0];


wire                          wrlvl_dir_dqs0_i;
wire                          wrlvl_dir_dqs1_i;
wire                          wrlvl_dir_dqs2_i;
wire                          wrlvl_dir_dqs3_i;
wire                          wrlvl_dir_dqs4_i;
wire                          wrlvl_dir_dqs5_i;
wire                          wrlvl_dir_dqs6_i;
wire                          wrlvl_dir_dqs7_i;
wire                          wrlvl_dir_dqs8_i;
reg                           wrlvl_dir_dqs_i[8:0];

wire                          wrlvl_loadn_dqs0_i;
wire                          wrlvl_loadn_dqs1_i;
wire                          wrlvl_loadn_dqs2_i;
wire                          wrlvl_loadn_dqs3_i;
wire                          wrlvl_loadn_dqs4_i;
wire                          wrlvl_loadn_dqs5_i;
wire                          wrlvl_loadn_dqs6_i;
wire                          wrlvl_loadn_dqs7_i;
wire                          wrlvl_loadn_dqs8_i;
reg                           wrlvl_loadn_dqs_i[8:0];
reg                     [8:0] wrlvl_code_r [NUM_DQS_GROUP-1:0];
reg                     [8:0] wrlvl_code_r_0 [NUM_DQS_GROUP-1:0];
reg                     [8:0] wrlvl_code_r_1 [NUM_DQS_GROUP-1:0];
reg                     [8:0] wrlvl_code_r_2 [NUM_DQS_GROUP-1:0];
reg                     [8:0] wrlvl_code_r_3 [NUM_DQS_GROUP-1:0];
reg                     [8:0] wrlvl_code_r_4 [NUM_DQS_GROUP-1:0];
reg                     [8:0] wrlvl_code_r_5 [NUM_DQS_GROUP-1:0];

wire                          wrlvl_move_dqs0_i;
wire                          wrlvl_move_dqs1_i;
wire                          wrlvl_move_dqs2_i;
wire                          wrlvl_move_dqs3_i;
wire                          wrlvl_move_dqs4_i;
wire                          wrlvl_move_dqs5_i;
wire                          wrlvl_move_dqs6_i;
wire                          wrlvl_move_dqs7_i;
wire                          wrlvl_move_dqs8_i;
reg                           wrlvl_move_dqs_i[8:0];
reg                           wrlvl_move_dqs_r[8:0];
reg                    [10:0] wrlvl_timeout_r[NUM_DQS_GROUP-1:0];

wire                          dqs_rd_section_dqs0_o;
wire                          dqs_rd_section_dqs1_o;
wire                          dqs_rd_section_dqs2_o;
wire                          dqs_rd_section_dqs3_o;
wire                          dqs_rd_section_dqs4_o;
wire                          dqs_rd_section_dqs5_o;
wire                          dqs_rd_section_dqs6_o;
wire                          dqs_rd_section_dqs7_o;
wire                          dqs_rd_section_dqs8_o;
wire                          dqs_rd_section_dqs_o[8:0];

wire                          burst_detect_dqs0_o;
wire                          burst_detect_dqs1_o;
wire                          burst_detect_dqs2_o;
wire                          burst_detect_dqs3_o;
wire                          burst_detect_dqs4_o;
wire                          burst_detect_dqs5_o;
wire                          burst_detect_dqs6_o;
wire                          burst_detect_dqs7_o;
wire                          burst_detect_dqs8_o;
wire                          burst_detect_dqs_o[8:0];

wire                          burst_detect_sclk_dqs0_o;
wire                          burst_detect_sclk_dqs1_o;
wire                          burst_detect_sclk_dqs2_o;
wire                          burst_detect_sclk_dqs3_o;
wire                          burst_detect_sclk_dqs4_o;
wire                          burst_detect_sclk_dqs5_o;
wire                          burst_detect_sclk_dqs6_o;
wire                          burst_detect_sclk_dqs7_o;
wire                          burst_detect_sclk_dqs8_o;
wire                          burst_detect_sclk_dqs_o[8:0];

wire                          data_valid_dqs0_o;
wire                          data_valid_dqs1_o;
wire                          data_valid_dqs2_o;
wire                          data_valid_dqs3_o;
wire                          data_valid_dqs4_o;
wire                          data_valid_dqs5_o;
wire                          data_valid_dqs6_o;
wire                          data_valid_dqs7_o;
wire                          data_valid_dqs8_o;
wire                          data_valid_dqs_o[8:0];



wire                          wrlvl_cout_dqs0_o;
wire                          wrlvl_cout_dqs1_o;
wire                          wrlvl_cout_dqs2_o;
wire                          wrlvl_cout_dqs3_o;
wire                          wrlvl_cout_dqs4_o;
wire                          wrlvl_cout_dqs5_o;
wire                          wrlvl_cout_dqs6_o;
wire                          wrlvl_cout_dqs7_o;
wire                          wrlvl_cout_dqs8_o;
wire                          wrlvl_cout_dqs_o[8:0];
reg                           wrlvl_cout_dqs_o_r[8:0];

wire            [GEARING-1:0] dqs_outen_n_dqs0_i;
wire            [GEARING-1:0] dqs_outen_n_dqs1_i;
wire            [GEARING-1:0] dqs_outen_n_dqs2_i;
wire            [GEARING-1:0] dqs_outen_n_dqs3_i;
wire            [GEARING-1:0] dqs_outen_n_dqs4_i;
wire            [GEARING-1:0] dqs_outen_n_dqs5_i;
wire            [GEARING-1:0] dqs_outen_n_dqs6_i;
wire            [GEARING-1:0] dqs_outen_n_dqs7_i;
wire            [GEARING-1:0] dqs_outen_n_dqs8_i;

reg             [GEARING-1:0] dqs_outen_n_dqs_i   [8:0];
reg             [GEARING-1:0] dqs_outen_n_dqs_i_00[8:0];
reg             [GEARING-1:0] dqs_outen_n_dqs_i_01[8:0];
reg             [GEARING-1:0] dqs_outen_n_dqs_i_02[8:0];
reg             [GEARING-1:0] dqs_outen_n_dqs_i_03[8:0];
reg             [GEARING-1:0] dqs_outen_n_dqs_i_04[8:0];
reg             [GEARING-1:0] dqs_outen_n_dqs_i_05[8:0];
reg             [GEARING-1:0] dqs_outen_n_dqs_i_06[8:0];
reg             [GEARING-1:0] dqs_outen_n_dqs_i_07[8:0];
reg             [GEARING-1:0] dqs_outen_n_dqs_i_08[8:0];
reg             [GEARING-1:0] dqs_outen_n_dqs_i_09[8:0];
reg             [GEARING-1:0] dqs_outen_n_dqs_i_10[8:0];
reg             [GEARING-1:0] dqs_outen_n_dqs_i_11[8:0];
reg             [GEARING-1:0] dqs_outen_n_dqs_i_12[8:0];
reg             [GEARING-1:0] dqs_outen_n_dqs_i_13[8:0];
reg             [GEARING-1:0] dqs_outen_n_dqs_i_14[8:0];
reg             [GEARING-1:0] dqs_outen_n_dqs_i_15[8:0];
reg             [GEARING-1:0] dqs_outen_n_dqs_i_16[8:0];
reg             [GEARING-1:0] dqs_outen_n_dqs_i_17[8:0];
reg             [GEARING-1:0] dqs_outen_n_dqs_i_18[8:0];
reg             [GEARING-1:0] dqs_outen_n_dqs_i_19[8:0];


wire            [GEARING-1:0] dqs0_i;
wire            [GEARING-1:0] dqs1_i;
wire            [GEARING-1:0] dqs2_i;
wire            [GEARING-1:0] dqs3_i;
wire            [GEARING-1:0] dqs4_i;
wire            [GEARING-1:0] dqs5_i;
wire            [GEARING-1:0] dqs6_i;
wire            [GEARING-1:0] dqs7_i;
wire            [GEARING-1:0] dqs8_i;
reg             [GEARING-1:0] dqs_i[8:0];
wire                          dqs0_io;
wire                          dqs1_io;
wire                          dqs2_io;
wire                          dqs3_io;
wire                          dqs4_io;
wire                          dqs5_io;
wire                          dqs6_io;
wire                          dqs7_io;
wire                          dqs8_io;
reg                           dqs_io_i[8:0];
reg                           dqs_io_i_0_r[9:0];
reg                           dqs_io_i_1_r[9:0];
reg                           dqs_io_i_2_r[9:0];
reg                           dqs_io_i_3_r[9:0];
reg                           dqs_io_i_4_r[9:0];
reg                           dqs_io_i_5_r[9:0];
reg                           dqs_io_i_6_r[9:0];
reg                           dqs_io_i_7_r[9:0];
reg                           dqs_io_i_8_r[9:0];
reg                           dqs_io_i_9_r[9:0];
reg                           dqs_io_i_10_r[9:0];
reg                           dqs_io_i_11_r[9:0];
reg                           dqs_io_i_12_r[9:0];
reg                           dqs_io_i_13_r[9:0];
reg                           dqs_io_i_14_r[9:0];
reg                           dqs_io_i_15_r[9:0];
reg                           dqs_io_i_16_r[9:0];
reg                           dqs_io_i_17_r[9:0];


wire                          dqs_io_o[8:0];
wire            [GEARING-1:0] exp_dqs_io_o_w[8:0];
reg             [GEARING-1:0] exp_dqs_io_o_r[8:0];
reg             [GEARING-1:0] exp_dqs_io_o_0_r[8:0];
reg             [GEARING-1:0] exp_dqs_io_o_1_r[8:0];
reg             [GEARING-1:0] exp_dqs_io_o_2_r[8:0];
reg             [GEARING-1:0] exp_dqs_io_o_3_r[8:0];
reg             [GEARING-1:0] exp_dqs_io_o_4_r[8:0];
reg             [GEARING-1:0] exp_dqs_io_o_5_r[8:0];
reg             [GEARING-1:0] exp_dqs_io_o_6_r[8:0];
reg             [GEARING-1:0] exp_dqs_io_o_7_r[8:0];
reg             [GEARING-1:0] exp_dqs_io_o_8_r[8:0];
reg             [GEARING-1:0] exp_dqs_io_o_9_r[8:0];
reg             [GEARING-1:0] exp_dqs_io_o_10_r[8:0];
reg             [GEARING-1:0] exp_dqs_io_o_11_r[8:0];
reg             [GEARING-1:0] exp_dqs_io_o_12_r[8:0];
reg                     [3:0] dqs_counter_r[8:0];
reg             [GEARING-1:0] dqs_i_r_0[8:0];
reg             [GEARING-1:0] dqs_i_r_1[8:0];
reg             [GEARING-1:0] dqs_i_r_2[8:0];


wire                    [7:0] dq_dqs0_io;
wire                    [7:0] dq_dqs1_io;
wire                    [7:0] dq_dqs2_io;
wire                    [7:0] dq_dqs3_io;
wire                    [7:0] dq_dqs4_io;
wire                    [7:0] dq_dqs5_io;
wire                    [7:0] dq_dqs6_io;
wire                    [7:0] dq_dqs7_io;
wire                    [7:0] dq_dqs8_io;

wire                    [7:0] dqwl_dqs0_o;
wire                    [7:0] dqwl_dqs1_o;
wire                    [7:0] dqwl_dqs2_o;
wire                    [7:0] dqwl_dqs3_o;
wire                    [7:0] dqwl_dqs4_o;
wire                    [7:0] dqwl_dqs5_o;
wire                    [7:0] dqwl_dqs6_o;
wire                    [7:0] dqwl_dqs7_o;
wire                    [7:0] dqwl_dqs8_o;

wire                    [7:0] dq_dqs_io_o[8:0];
reg                     [7:0] dq_dqs_io_i[8:0];
reg                     [7:0] dq_dqs_io_i_r[8:0];
reg                     [7:0] dq_dqs_io_i_0_r[8:0];
reg                     [7:0] dq_dqs_io_i_1_r[8:0];
reg                     [7:0] dq_dqs_io_i_2_r[8:0];
reg                     [7:0] dq_dqs_io_i_3_r[8:0];
reg                     [7:0] dq_dqs_io_i_4_r[8:0];
reg                     [7:0] dq_dqs_io_i_5_r[8:0];
reg                     [7:0] dq_dqs_io_i_6_r[8:0];
reg                     [7:0] dq_dqs_io_i_7_r[8:0];
reg                     [7:0] dq_dqs_io_i_8_r[8:0];
reg                     [7:0] dq_dqs_io_i_9_r[8:0];
reg                     [7:0] dq_dqs_io_i_10_r[8:0];
reg                     [7:0] dq_dqs_io_i_11_r[8:0];
reg                     [7:0] dq_dqs_io_i_12_r[8:0];
reg                     [7:0] dq_dqs_io_i_13_r[8:0];
reg                     [7:0] dq_dqs_io_i_14_r[8:0];
reg                     [7:0] dq_dqs_io_i_15_r[8:0];
reg                     [7:0] dq_dqs_io_i_16_r[8:0];
reg                     [7:0] exp_dq_dqs_io_o_r[8:0];
reg                     [7:0] exp_dq_dqs_io_o_r_0[8:0];
reg                     [7:0] exp_dq_dqs_io_o_r_1[8:0];
reg                     [7:0] exp_dq_dqs_io_o_r_2[8:0];
reg                     [7:0] exp_dq_dqs_io_o_r_3[8:0];
reg                     [7:0] exp_dq_dqs_io_o_r_4[8:0];
reg                     [7:0] exp_dq_dqs_io_o_r_5[8:0];
reg                     [7:0] exp_dq_dqs_io_o_r_6[8:0];
reg                     [7:0] exp_dq_dqs_io_o_r_7[8:0];
wire                    [7:0] exp_dq_dqs_io_o_w[8:0];
reg                    [63:0] dq_total_dly_r[8:0];

reg                           rst_w;
//wire                          rst_n_w;
reg                    [63:0] watchdog_r;
reg                    [63:0] timeout_r [NUM_DQS_GROUP-1:0];

reg                           error_clk_r;
reg                           error_sclk_o_r;
reg                           error_ca_o_r;
reg                           error_csn_o_r;
reg                           error_addr_o_r;
reg                           error_casn_o_r;
reg                           error_rasn_o_r;
reg                           error_ba_o_r;
reg                           error_odt_o_r;
reg                           error_cke_o_r;
reg                           error_wen_o_r;
reg                           error_dq_dqs_o_r;
reg                           error_data_dqs_o_r;
reg                           error_dqs_o_r;
reg                           error_dm_o_r;
reg                           error_global_r;

reg                           error_print_flag_clk_r;
reg                           error_print_flag_ca_o_r;
reg                           error_print_flag_sclk_o_r;
reg                           error_print_flag_csn_o_r;
reg                           error_print_flag_addr_o_r;
reg                           error_print_flag_casn_o_r;
reg                           error_print_flag_rasn_o_r;
reg                           error_print_flag_ba_o_r;
reg                           error_print_flag_odt_o_r;
reg                           error_print_flag_cke_o_r;
reg                           error_print_flag_wen_o_r;
reg                           error_print_flag_dq_dqs_o_r;
reg                           error_print_flag_data_dqs_o_r;
reg                           error_print_flag_dm_o_r;
reg                           error_print_flag_dqs_o_r;
reg     [10:0]                total_delay_cntr_r;
wire    [9:0]                 dqs_rd_del_value_dec_w;
wire    [9:0]                 dqs_wr_del_value_dec_w;

wire    [10:0]                total_delay_max_count;
wire                          total_delay_done;

///////////////////// GSR /////////////////////
reg CLK_GSR = 0;
reg USER_GSR = 1;
wire GSROUT;

initial begin
    forever begin
        #50;
        CLK_GSR = ~CLK_GSR;
    end
end

GSR GSR_INST (
    .GSR_N(USER_GSR),
    .CLK(CLK_GSR)
);
/////////////////////////////////////////////////

assign eclk_i     = ddr_clk_w;
//assign rst_n_w    = ~rst_w;

generate
  for(i=0; i < NUM_CS; i=i+1) begin
    if((INTERFACE_TYPE == "LPDDR2") || (INTERFACE_TYPE == "LPDDR3")) begin
      if(GEARING == 2)
        assign exp_csn_o_w[i] = exp_csn_o_0_r[i];
      else
        assign exp_csn_o_w[i] = exp_csn_o_r[i];
    end
    else begin
      if(GEARING == 2)
        assign #(10) exp_csn_o_w[i] = exp_csn_o_1_r[i];
      else
        assign #(10) exp_csn_o_w[i] = exp_csn_o_2_r[i];
    end
  end
endgenerate

assign ce_i = ce_out_i | ce_in_i;

if(GEARING == 2) begin
  assign exp_addr_o_w = exp_addr_o_0_r;
  assign exp_ba_o_w   = exp_ba_o_0_r;
  assign exp_casn_o_w = exp_casn_o_0_r;
  assign exp_rasn_o_w = exp_rasn_o_0_r;
  assign exp_wen_o_w  = exp_wen_o_0_r;
end
else begin
  assign exp_addr_o_w = exp_addr_o_0_r;
  assign exp_ba_o_w   = exp_ba_o_0_r;
  assign exp_casn_o_w = exp_casn_o_0_r;
  assign exp_rasn_o_w = exp_rasn_o_0_r;
  assign exp_wen_o_w  = exp_wen_o_0_r;
end

generate
  if(GEARING == 2) begin
    if((INTERFACE_TYPE == "LPDDR2") || (INTERFACE_TYPE == "LPDDR3")) begin
      assign exp_cke_o_w = exp_cke_o_4_r;
      assign exp_odt_o_w = exp_odt_o_2_r;
    end
    else begin
      assign exp_cke_o_w = exp_cke_o_2_r;
      assign exp_odt_o_w = exp_odt_o_2_r;
    end
  end
  else begin
    if((INTERFACE_TYPE == "LPDDR2") || (INTERFACE_TYPE == "LPDDR3")) begin
      assign exp_cke_o_w = exp_cke_o_6_r;
      assign exp_odt_o_w = exp_odt_o_3_r;
    end
    else begin
      assign exp_cke_o_w = exp_cke_o_2_r;
      assign exp_odt_o_w = exp_odt_o_2_r;
    end
  end
endgenerate

generate
  if(GEARING == 2) begin
    assign #(6750) exp_ca_o_w   = exp_ca_o_5_r;// 675ps is 270 phase shift between ca_o and ck_o.

    for(i=0; i<NUM_DQS_GROUP; i=i+1) begin
      assign        exp_dq_dqs_io_o_w[i] = exp_dq_dqs_io_o_r_4[i];
      assign        exp_dqs_io_o_w[i]    = exp_dqs_io_o_5_r[i];
      assign        exp_dm_o_w[i]        = exp_dm_o_4_r[i];
      assign        exp_data_dqs_o_w[i]  = exp_data_dqs_o_r_3[i];
    end
  end
  else begin
    if((INTERFACE_TYPE == "LPDDR2") || (INTERFACE_TYPE == "LPDDR3")) begin
      assign #(6750) exp_ca_o_w   = exp_ca_o_7_r;// 675ps is 270 phase shift between ca_o and ck_o.

      for(i=0; i<NUM_DQS_GROUP; i=i+1) begin
        assign        exp_dq_dqs_io_o_w[i] = exp_dq_dqs_io_o_r_6[i];
        assign        exp_dqs_io_o_w[i]    = exp_dqs_io_o_11_r[i];
        assign        exp_dm_o_w[i]        = exp_dm_o_6_r[i];
        assign        exp_data_dqs_o_w[i]  = exp_data_dqs_o_r_7[i];
      end
    end
    else begin
      assign #(6750) exp_ca_o_w   = exp_ca_o_7_r;// 675ps is 270 phase shift between ca_o and ck_o.

      for(i=0; i<NUM_DQS_GROUP; i=i+1) begin
        assign        exp_dq_dqs_io_o_w[i] = exp_dq_dqs_io_o_r_6[i];
        assign        exp_dqs_io_o_w[i]    = exp_dqs_io_o_11_r[i];
        assign        exp_dm_o_w[i]        = exp_dm_o_6_r[i];
        assign        exp_data_dqs_o_w[i]  = exp_data_dqs_o_r_7[i];
      end
    end
  end
endgenerate

generate
   begin : ADDR_BA_ODT_CKE_GEN
   if (4==GEARING) begin: X4_GEAR
      assign addr_din0_i = addr_i[1*ADDR_WIDTH-1:0*ADDR_WIDTH];
      assign addr_din1_i = addr_i[1*ADDR_WIDTH-1:0*ADDR_WIDTH];
      assign addr_din2_i = addr_i[1*ADDR_WIDTH-1:0*ADDR_WIDTH];
      assign addr_din3_i = addr_i[1*ADDR_WIDTH-1:0*ADDR_WIDTH];
      assign addr_din4_i = addr_i[2*ADDR_WIDTH-1:1*ADDR_WIDTH];
      assign addr_din5_i = addr_i[2*ADDR_WIDTH-1:1*ADDR_WIDTH];
      assign addr_din6_i = addr_i[2*ADDR_WIDTH-1:1*ADDR_WIDTH];
      assign addr_din7_i = addr_i[2*ADDR_WIDTH-1:1*ADDR_WIDTH];

      assign ba_din0_i   = ba_i[1*BA_WIDTH-1:0*BA_WIDTH];
      assign ba_din1_i   = ba_i[1*BA_WIDTH-1:0*BA_WIDTH];
      assign ba_din2_i   = ba_i[1*BA_WIDTH-1:0*BA_WIDTH];
      assign ba_din3_i   = ba_i[1*BA_WIDTH-1:0*BA_WIDTH];
      assign ba_din4_i   = ba_i[2*BA_WIDTH-1:1*BA_WIDTH];
      assign ba_din5_i   = ba_i[2*BA_WIDTH-1:1*BA_WIDTH];
      assign ba_din6_i   = ba_i[2*BA_WIDTH-1:1*BA_WIDTH];
      assign ba_din7_i   = ba_i[2*BA_WIDTH-1:1*BA_WIDTH];

      assign odt_din0_i  = odt_i[1*ODT_LEN-1:0*ODT_LEN];
      assign odt_din1_i  = odt_i[1*ODT_LEN-1:0*ODT_LEN];
      assign odt_din2_i  = odt_i[1*ODT_LEN-1:0*ODT_LEN];
      assign odt_din3_i  = odt_i[1*ODT_LEN-1:0*ODT_LEN];
      assign odt_din4_i  = odt_i[2*ODT_LEN-1:1*ODT_LEN];
      assign odt_din5_i  = odt_i[2*ODT_LEN-1:1*ODT_LEN];
      assign odt_din6_i  = odt_i[2*ODT_LEN-1:1*ODT_LEN];
      assign odt_din7_i  = odt_i[2*ODT_LEN-1:1*ODT_LEN];

      assign cke_din0_i  = cke_i[1*CKE_LEN-1:0*CKE_LEN];
      assign cke_din1_i  = cke_i[1*CKE_LEN-1:0*CKE_LEN];
      assign cke_din2_i  = cke_i[1*CKE_LEN-1:0*CKE_LEN];
      assign cke_din3_i  = cke_i[1*CKE_LEN-1:0*CKE_LEN];
      assign cke_din4_i  = cke_i[2*CKE_LEN-1:1*CKE_LEN];
      assign cke_din5_i  = cke_i[2*CKE_LEN-1:1*CKE_LEN];
      assign cke_din6_i  = cke_i[2*CKE_LEN-1:1*CKE_LEN];
      assign cke_din7_i  = cke_i[2*CKE_LEN-1:1*CKE_LEN];
   end
   else begin : X2_GEAR
      assign addr_din0_i = addr_i[1*ADDR_WIDTH-1:0*ADDR_WIDTH];
      assign addr_din1_i = addr_i[2*ADDR_WIDTH-1:1*ADDR_WIDTH];

      assign ba_din0_i   = ba_i[BA_WIDTH-1:0];
      assign ba_din1_i   = ba_i[BA_WIDTH*2-1:BA_WIDTH];

      assign odt_din0_i  = odt_i[ODT_LEN-1:0];
      assign odt_din1_i  = odt_i[2*ODT_LEN-1:ODT_LEN];

      assign cke_din0_i  = cke_i[CKE_LEN-1:0];
      assign cke_din1_i  = cke_i[2*CKE_LEN-1:CKE_LEN];
   end
end
endgenerate



generate
  for(i=0;i<NUM_CS;i=i+1)begin
    if(GEARING == 2) begin
      assign csn_din0_i[i] = csn_i[i][0];
      assign csn_din1_i[i] = csn_i[i][1];
    end
    else begin
      assign csn_din0_i[i] = csn_i[i][0];
      assign csn_din1_i[i] = csn_i[i][1];
      assign csn_din2_i[i] = csn_i[i][2];
      assign csn_din3_i[i] = csn_i[i][3];
    end
  end
endgenerate

assign casn_din0_i = casn_i[0];
assign casn_din1_i = casn_i[1];
assign casn_din2_i = casn_i[2];
assign casn_din3_i = casn_i[3];
assign casn_din4_i = casn_i[4];
assign casn_din5_i = casn_i[5];
assign casn_din6_i = casn_i[6];
assign casn_din7_i = casn_i[7];

assign rasn_din0_i = rasn_i[0];
assign rasn_din1_i = rasn_i[1];
assign rasn_din2_i = rasn_i[2];
assign rasn_din3_i = rasn_i[3];
assign rasn_din4_i = rasn_i[4];
assign rasn_din5_i = rasn_i[5];
assign rasn_din6_i = rasn_i[6];
assign rasn_din7_i = rasn_i[7];

assign wen_din0_i = wen_i[0];
assign wen_din1_i = wen_i[1];
assign wen_din2_i = wen_i[2];
assign wen_din3_i = wen_i[3];
assign wen_din4_i = wen_i[4];
assign wen_din5_i = wen_i[5];
assign wen_din6_i = wen_i[6];
assign wen_din7_i = wen_i[7];

assign data_dqs_o[0] = data_dqs0_o;
assign data_dqs_o[1] = data_dqs1_o;
assign data_dqs_o[2] = data_dqs2_o;
assign data_dqs_o[3] = data_dqs3_o;
assign data_dqs_o[4] = data_dqs4_o;
assign data_dqs_o[5] = data_dqs5_o;
assign data_dqs_o[6] = data_dqs6_o;
assign data_dqs_o[7] = data_dqs7_o;
assign data_dqs_o[8] = data_dqs8_o;

assign data_dqs0_i = data_dqs_i[0];
assign data_dqs1_i = data_dqs_i[1];
assign data_dqs2_i = data_dqs_i[2];
assign data_dqs3_i = data_dqs_i[3];
assign data_dqs4_i = data_dqs_i[4];
assign data_dqs5_i = data_dqs_i[5];
assign data_dqs6_i = data_dqs_i[6];
assign data_dqs7_i = data_dqs_i[7];
assign data_dqs8_i = data_dqs_i[8];

assign data_mask_dqs0_i = data_mask_i[0];
assign data_mask_dqs1_i = data_mask_i[1];
assign data_mask_dqs2_i = data_mask_i[2];
assign data_mask_dqs3_i = data_mask_i[3];
assign data_mask_dqs4_i = data_mask_i[4];
assign data_mask_dqs5_i = data_mask_i[5];
assign data_mask_dqs6_i = data_mask_i[6];
assign data_mask_dqs7_i = data_mask_i[7];
assign data_mask_dqs8_i = data_mask_i[8];

assign dm_o[0] = dm_dqs0_o;
assign dm_o[1] = dm_dqs1_o;
assign dm_o[2] = dm_dqs2_o;
assign dm_o[3] = dm_dqs3_o;
assign dm_o[4] = dm_dqs4_o;
assign dm_o[5] = dm_dqs5_o;
assign dm_o[6] = dm_dqs6_o;
assign dm_o[7] = dm_dqs7_o;
assign dm_o[8] = dm_dqs8_o;

assign rd_clksel_dqs0_i = rd_clksel_dqs_i[0];
assign rd_clksel_dqs1_i = rd_clksel_dqs_i[1];
assign rd_clksel_dqs2_i = rd_clksel_dqs_i[2];
assign rd_clksel_dqs3_i = rd_clksel_dqs_i[3];
assign rd_clksel_dqs4_i = rd_clksel_dqs_i[4];
assign rd_clksel_dqs5_i = rd_clksel_dqs_i[5];
assign rd_clksel_dqs6_i = rd_clksel_dqs_i[6];
assign rd_clksel_dqs7_i = rd_clksel_dqs_i[7];
assign rd_clksel_dqs8_i = rd_clksel_dqs_i[8];

assign rd_dir_dqs0_i = rd_dir_dqs_i[0];
assign rd_dir_dqs1_i = rd_dir_dqs_i[1];
assign rd_dir_dqs2_i = rd_dir_dqs_i[2];
assign rd_dir_dqs3_i = rd_dir_dqs_i[3];
assign rd_dir_dqs4_i = rd_dir_dqs_i[4];
assign rd_dir_dqs5_i = rd_dir_dqs_i[5];
assign rd_dir_dqs6_i = rd_dir_dqs_i[6];
assign rd_dir_dqs7_i = rd_dir_dqs_i[7];
assign rd_dir_dqs8_i = rd_dir_dqs_i[8];

assign rd_loadn_dqs0_i = rd_loadn_dqs_i[0];
assign rd_loadn_dqs1_i = rd_loadn_dqs_i[1];
assign rd_loadn_dqs2_i = rd_loadn_dqs_i[2];
assign rd_loadn_dqs3_i = rd_loadn_dqs_i[3];
assign rd_loadn_dqs4_i = rd_loadn_dqs_i[4];
assign rd_loadn_dqs5_i = rd_loadn_dqs_i[5];
assign rd_loadn_dqs6_i = rd_loadn_dqs_i[6];
assign rd_loadn_dqs7_i = rd_loadn_dqs_i[7];
assign rd_loadn_dqs8_i = rd_loadn_dqs_i[8];

assign rd_dqs0_i = rd_i[0];
assign rd_dqs1_i = rd_i[1];
assign rd_dqs2_i = rd_i[2];
assign rd_dqs3_i = rd_i[3];
assign rd_dqs4_i = rd_i[4];
assign rd_dqs5_i = rd_i[5];
assign rd_dqs6_i = rd_i[6];
assign rd_dqs7_i = rd_i[7];
assign rd_dqs8_i = rd_i[8];

assign rd_move_dqs0_i = rd_move_dqs_i[0];
assign rd_move_dqs1_i = rd_move_dqs_i[1];
assign rd_move_dqs2_i = rd_move_dqs_i[2];
assign rd_move_dqs3_i = rd_move_dqs_i[3];
assign rd_move_dqs4_i = rd_move_dqs_i[4];
assign rd_move_dqs5_i = rd_move_dqs_i[5];
assign rd_move_dqs6_i = rd_move_dqs_i[6];
assign rd_move_dqs7_i = rd_move_dqs_i[7];
assign rd_move_dqs8_i = rd_move_dqs_i[8];

assign wr_dir_dqs0_i = wr_dir_dqs_i[0];
assign wr_dir_dqs1_i = wr_dir_dqs_i[1];
assign wr_dir_dqs2_i = wr_dir_dqs_i[2];
assign wr_dir_dqs3_i = wr_dir_dqs_i[3];
assign wr_dir_dqs4_i = wr_dir_dqs_i[4];
assign wr_dir_dqs5_i = wr_dir_dqs_i[5];
assign wr_dir_dqs6_i = wr_dir_dqs_i[6];
assign wr_dir_dqs7_i = wr_dir_dqs_i[7];
assign wr_dir_dqs8_i = wr_dir_dqs_i[8];

assign wr_loadn_dqs0_i = wr_loadn_dqs_i[0];
assign wr_loadn_dqs1_i = wr_loadn_dqs_i[1];
assign wr_loadn_dqs2_i = wr_loadn_dqs_i[2];
assign wr_loadn_dqs3_i = wr_loadn_dqs_i[3];
assign wr_loadn_dqs4_i = wr_loadn_dqs_i[4];
assign wr_loadn_dqs5_i = wr_loadn_dqs_i[5];
assign wr_loadn_dqs6_i = wr_loadn_dqs_i[6];
assign wr_loadn_dqs7_i = wr_loadn_dqs_i[7];
assign wr_loadn_dqs8_i = wr_loadn_dqs_i[8];

assign wr_move_dqs0_i = wr_move_dqs_i[0];
assign wr_move_dqs1_i = wr_move_dqs_i[1];
assign wr_move_dqs2_i = wr_move_dqs_i[2];
assign wr_move_dqs3_i = wr_move_dqs_i[3];
assign wr_move_dqs4_i = wr_move_dqs_i[4];
assign wr_move_dqs5_i = wr_move_dqs_i[5];
assign wr_move_dqs6_i = wr_move_dqs_i[6];
assign wr_move_dqs7_i = wr_move_dqs_i[7];
assign wr_move_dqs8_i = wr_move_dqs_i[8];

assign wrlvl_dir_dqs0_i = wrlvl_dir_dqs_i[0];
assign wrlvl_dir_dqs1_i = wrlvl_dir_dqs_i[1];
assign wrlvl_dir_dqs2_i = wrlvl_dir_dqs_i[2];
assign wrlvl_dir_dqs3_i = wrlvl_dir_dqs_i[3];
assign wrlvl_dir_dqs4_i = wrlvl_dir_dqs_i[4];
assign wrlvl_dir_dqs5_i = wrlvl_dir_dqs_i[5];
assign wrlvl_dir_dqs6_i = wrlvl_dir_dqs_i[6];
assign wrlvl_dir_dqs7_i = wrlvl_dir_dqs_i[7];
assign wrlvl_dir_dqs8_i = wrlvl_dir_dqs_i[8];

assign wrlvl_loadn_dqs0_i = wrlvl_loadn_dqs_i[0];
assign wrlvl_loadn_dqs1_i = wrlvl_loadn_dqs_i[1];
assign wrlvl_loadn_dqs2_i = wrlvl_loadn_dqs_i[2];
assign wrlvl_loadn_dqs3_i = wrlvl_loadn_dqs_i[3];
assign wrlvl_loadn_dqs4_i = wrlvl_loadn_dqs_i[4];
assign wrlvl_loadn_dqs5_i = wrlvl_loadn_dqs_i[5];
assign wrlvl_loadn_dqs6_i = wrlvl_loadn_dqs_i[6];
assign wrlvl_loadn_dqs7_i = wrlvl_loadn_dqs_i[7];
assign wrlvl_loadn_dqs8_i = wrlvl_loadn_dqs_i[8];

assign wrlvl_move_dqs0_i = wrlvl_move_dqs_i[0];
assign wrlvl_move_dqs1_i = wrlvl_move_dqs_i[1];
assign wrlvl_move_dqs2_i = wrlvl_move_dqs_i[2];
assign wrlvl_move_dqs3_i = wrlvl_move_dqs_i[3];
assign wrlvl_move_dqs4_i = wrlvl_move_dqs_i[4];
assign wrlvl_move_dqs5_i = wrlvl_move_dqs_i[5];
assign wrlvl_move_dqs6_i = wrlvl_move_dqs_i[6];
assign wrlvl_move_dqs7_i = wrlvl_move_dqs_i[7];
assign wrlvl_move_dqs8_i = wrlvl_move_dqs_i[8];

assign dqs_rd_section_dqs_o[0] = dqs_rd_section_dqs0_o;
assign dqs_rd_section_dqs_o[1] = dqs_rd_section_dqs1_o;
assign dqs_rd_section_dqs_o[2] = dqs_rd_section_dqs2_o;
assign dqs_rd_section_dqs_o[3] = dqs_rd_section_dqs3_o;
assign dqs_rd_section_dqs_o[4] = dqs_rd_section_dqs4_o;
assign dqs_rd_section_dqs_o[5] = dqs_rd_section_dqs5_o;
assign dqs_rd_section_dqs_o[6] = dqs_rd_section_dqs6_o;
assign dqs_rd_section_dqs_o[7] = dqs_rd_section_dqs7_o;
assign dqs_rd_section_dqs_o[8] = dqs_rd_section_dqs8_o;

assign burst_detect_dqs_o[0] = burst_detect_dqs0_o;
assign burst_detect_dqs_o[1] = burst_detect_dqs1_o;
assign burst_detect_dqs_o[2] = burst_detect_dqs2_o;
assign burst_detect_dqs_o[3] = burst_detect_dqs3_o;
assign burst_detect_dqs_o[4] = burst_detect_dqs4_o;
assign burst_detect_dqs_o[5] = burst_detect_dqs5_o;
assign burst_detect_dqs_o[6] = burst_detect_dqs6_o;
assign burst_detect_dqs_o[7] = burst_detect_dqs7_o;
assign burst_detect_dqs_o[8] = burst_detect_dqs8_o;

assign burst_detect_sclk_dqs_o[0] = burst_detect_sclk_dqs0_o;
assign burst_detect_sclk_dqs_o[1] = burst_detect_sclk_dqs1_o;
assign burst_detect_sclk_dqs_o[2] = burst_detect_sclk_dqs2_o;
assign burst_detect_sclk_dqs_o[3] = burst_detect_sclk_dqs3_o;
assign burst_detect_sclk_dqs_o[4] = burst_detect_sclk_dqs4_o;
assign burst_detect_sclk_dqs_o[5] = burst_detect_sclk_dqs5_o;
assign burst_detect_sclk_dqs_o[6] = burst_detect_sclk_dqs6_o;
assign burst_detect_sclk_dqs_o[7] = burst_detect_sclk_dqs7_o;
assign burst_detect_sclk_dqs_o[8] = burst_detect_sclk_dqs8_o;

assign data_valid_dqs_o[0] = data_valid_dqs0_o;
assign data_valid_dqs_o[1] = data_valid_dqs1_o;
assign data_valid_dqs_o[2] = data_valid_dqs2_o;
assign data_valid_dqs_o[3] = data_valid_dqs3_o;
assign data_valid_dqs_o[4] = data_valid_dqs4_o;
assign data_valid_dqs_o[5] = data_valid_dqs5_o;
assign data_valid_dqs_o[6] = data_valid_dqs6_o;
assign data_valid_dqs_o[7] = data_valid_dqs7_o;
assign data_valid_dqs_o[8] = data_valid_dqs8_o;

assign rd_cout_dqs_o[0] = rd_cout_dqs0_o;
assign rd_cout_dqs_o[1] = rd_cout_dqs1_o;
assign rd_cout_dqs_o[2] = rd_cout_dqs2_o;
assign rd_cout_dqs_o[3] = rd_cout_dqs3_o;
assign rd_cout_dqs_o[4] = rd_cout_dqs4_o;
assign rd_cout_dqs_o[5] = rd_cout_dqs5_o;
assign rd_cout_dqs_o[6] = rd_cout_dqs6_o;
assign rd_cout_dqs_o[7] = rd_cout_dqs7_o;
assign rd_cout_dqs_o[8] = rd_cout_dqs8_o;

assign wr_cout_dqs_o[0] = wr_cout_dqs0_o;
assign wr_cout_dqs_o[1] = wr_cout_dqs1_o;
assign wr_cout_dqs_o[2] = wr_cout_dqs2_o;
assign wr_cout_dqs_o[3] = wr_cout_dqs3_o;
assign wr_cout_dqs_o[4] = wr_cout_dqs4_o;
assign wr_cout_dqs_o[5] = wr_cout_dqs5_o;
assign wr_cout_dqs_o[6] = wr_cout_dqs6_o;
assign wr_cout_dqs_o[7] = wr_cout_dqs7_o;
assign wr_cout_dqs_o[8] = wr_cout_dqs8_o;

assign wrlvl_cout_dqs_o[0] = wrlvl_cout_dqs0_o;
assign wrlvl_cout_dqs_o[1] = wrlvl_cout_dqs1_o;
assign wrlvl_cout_dqs_o[2] = wrlvl_cout_dqs2_o;
assign wrlvl_cout_dqs_o[3] = wrlvl_cout_dqs3_o;
assign wrlvl_cout_dqs_o[4] = wrlvl_cout_dqs4_o;
assign wrlvl_cout_dqs_o[5] = wrlvl_cout_dqs5_o;
assign wrlvl_cout_dqs_o[6] = wrlvl_cout_dqs6_o;
assign wrlvl_cout_dqs_o[7] = wrlvl_cout_dqs7_o;
assign wrlvl_cout_dqs_o[8] = wrlvl_cout_dqs8_o;

assign dqs_outen_n_dqs0_i = dqs_outen_n_dqs_i[0];
assign dqs_outen_n_dqs1_i = dqs_outen_n_dqs_i[1];
assign dqs_outen_n_dqs2_i = dqs_outen_n_dqs_i[2];
assign dqs_outen_n_dqs3_i = dqs_outen_n_dqs_i[3];
assign dqs_outen_n_dqs4_i = dqs_outen_n_dqs_i[4];
assign dqs_outen_n_dqs5_i = dqs_outen_n_dqs_i[5];
assign dqs_outen_n_dqs6_i = dqs_outen_n_dqs_i[6];
assign dqs_outen_n_dqs7_i = dqs_outen_n_dqs_i[7];
assign dqs_outen_n_dqs8_i = dqs_outen_n_dqs_i[8];

generate
  if(GEARING == 2) begin
    assign #1510 dqs0_io = ((dqs_outen_n_dqs_i_07[0]) == {GEARING{1'b1}}) ? ((ce_in_i== 1) ? dqs_io_i_7_r[0] : 0) : 8'hZZ;
    assign #1510 dqs1_io = ((dqs_outen_n_dqs_i_07[1]) == {GEARING{1'b1}}) ? ((ce_in_i== 1) ? dqs_io_i_7_r[1] : 0) : 8'hZZ;
    assign #1510 dqs2_io = ((dqs_outen_n_dqs_i_07[2]) == {GEARING{1'b1}}) ? ((ce_in_i== 1) ? dqs_io_i_7_r[2] : 0) : 8'hZZ;
    assign #1510 dqs3_io = ((dqs_outen_n_dqs_i_07[3]) == {GEARING{1'b1}}) ? ((ce_in_i== 1) ? dqs_io_i_7_r[3] : 0) : 8'hZZ;
    assign #1510 dqs4_io = ((dqs_outen_n_dqs_i_07[4]) == {GEARING{1'b1}}) ? ((ce_in_i== 1) ? dqs_io_i_7_r[4] : 0) : 8'hZZ;
    assign #1510 dqs5_io = ((dqs_outen_n_dqs_i_07[5]) == {GEARING{1'b1}}) ? ((ce_in_i== 1) ? dqs_io_i_7_r[5] : 0) : 8'hZZ;
    assign #1510 dqs6_io = ((dqs_outen_n_dqs_i_07[6]) == {GEARING{1'b1}}) ? ((ce_in_i== 1) ? dqs_io_i_7_r[6] : 0) : 8'hZZ;
    assign #1510 dqs7_io = ((dqs_outen_n_dqs_i_07[7]) == {GEARING{1'b1}}) ? ((ce_in_i== 1) ? dqs_io_i_7_r[7] : 0) : 8'hZZ;
    assign #1510 dqs8_io = ((dqs_outen_n_dqs_i_07[8]) == {GEARING{1'b1}}) ? ((ce_in_i== 1) ? dqs_io_i_7_r[8] : 0) : 8'hZZ;

    assign #(125)dq_dqs0_io = ((|dq_outen_n_i_0_r) == 1'b1) ? dq_dqs_io_i[0] : 8'hZZ;
    assign #(125)dq_dqs1_io = ((|dq_outen_n_i_0_r) == 1'b1) ? dq_dqs_io_i[1] : 8'hZZ;
    assign #(125)dq_dqs2_io = ((|dq_outen_n_i_0_r) == 1'b1) ? dq_dqs_io_i[2] : 8'hZZ;
    assign #(125)dq_dqs3_io = ((|dq_outen_n_i_0_r) == 1'b1) ? dq_dqs_io_i[3] : 8'hZZ;
    assign #(125)dq_dqs4_io = ((|dq_outen_n_i_0_r) == 1'b1) ? dq_dqs_io_i[4] : 8'hZZ;
    assign #(125)dq_dqs5_io = ((|dq_outen_n_i_0_r) == 1'b1) ? dq_dqs_io_i[5] : 8'hZZ;
    assign #(125)dq_dqs6_io = ((|dq_outen_n_i_0_r) == 1'b1) ? dq_dqs_io_i[6] : 8'hZZ;
    assign #(125)dq_dqs7_io = ((|dq_outen_n_i_0_r) == 1'b1) ? dq_dqs_io_i[7] : 8'hZZ;
    assign #(125)dq_dqs8_io = ((|dq_outen_n_i_0_r) == 1'b1) ? dq_dqs_io_i[8] : 8'hZZ;
  end
  else begin
    assign #(1510)dqs0_io = ((dqs_outen_n_dqs_i_17[0]) == {GEARING{1'b1}}) ? dqs_io_i_17_r[0] : 8'hZZ;
    assign #(1510)dqs1_io = ((dqs_outen_n_dqs_i_17[1]) == {GEARING{1'b1}}) ? dqs_io_i_17_r[1] : 8'hZZ;
    assign #(1510)dqs2_io = ((dqs_outen_n_dqs_i_17[2]) == {GEARING{1'b1}}) ? dqs_io_i_17_r[2] : 8'hZZ;
    assign #(1510)dqs3_io = ((dqs_outen_n_dqs_i_17[3]) == {GEARING{1'b1}}) ? dqs_io_i_17_r[3] : 8'hZZ;
    assign #(1510)dqs4_io = ((dqs_outen_n_dqs_i_17[4]) == {GEARING{1'b1}}) ? dqs_io_i_17_r[4] : 8'hZZ;
    assign #(1510)dqs5_io = ((dqs_outen_n_dqs_i_17[5]) == {GEARING{1'b1}}) ? dqs_io_i_17_r[5] : 8'hZZ;
    assign #(1510)dqs6_io = ((dqs_outen_n_dqs_i_17[6]) == {GEARING{1'b1}}) ? dqs_io_i_17_r[6] : 8'hZZ;
    assign #(1510)dqs7_io = ((dqs_outen_n_dqs_i_17[7]) == {GEARING{1'b1}}) ? dqs_io_i_17_r[7] : 8'hZZ;
    assign #(1510)dqs8_io = ((dqs_outen_n_dqs_i_17[8]) == {GEARING{1'b1}}) ? dqs_io_i_17_r[8] : 8'hZZ;

    assign #(3010)dq_dqs0_io = ((|dq_outen_n_i_9_r) == 1'b1) ? dq_dqs_io_i[0] : 8'hZZ;
    assign #(3010)dq_dqs1_io = ((|dq_outen_n_i_9_r) == 1'b1) ? dq_dqs_io_i[1] : 8'hZZ;
    assign #(3010)dq_dqs2_io = ((|dq_outen_n_i_9_r) == 1'b1) ? dq_dqs_io_i[2] : 8'hZZ;
    assign #(3010)dq_dqs3_io = ((|dq_outen_n_i_9_r) == 1'b1) ? dq_dqs_io_i[3] : 8'hZZ;
    assign #(3010)dq_dqs4_io = ((|dq_outen_n_i_9_r) == 1'b1) ? dq_dqs_io_i[4] : 8'hZZ;
    assign #(3010)dq_dqs5_io = ((|dq_outen_n_i_9_r) == 1'b1) ? dq_dqs_io_i[5] : 8'hZZ;
    assign #(3010)dq_dqs6_io = ((|dq_outen_n_i_9_r) == 1'b1) ? dq_dqs_io_i[6] : 8'hZZ;
    assign #(3010)dq_dqs7_io = ((|dq_outen_n_i_9_r) == 1'b1) ? dq_dqs_io_i[7] : 8'hZZ;
    assign #(3010)dq_dqs8_io = ((|dq_outen_n_i_9_r) == 1'b1) ? dq_dqs_io_i[8] : 8'hZZ;
  end
endgenerate
assign dqs_io_o[0] = dqs0_io;
assign dqs_io_o[1] = dqs1_io;
assign dqs_io_o[2] = dqs2_io;
assign dqs_io_o[3] = dqs3_io;
assign dqs_io_o[4] = dqs4_io;
assign dqs_io_o[5] = dqs5_io;
assign dqs_io_o[6] = dqs6_io;
assign dqs_io_o[7] = dqs7_io;
assign dqs_io_o[8] = dqs8_io;

assign dq_dqs_io_o[0] = dq_dqs0_io;
assign dq_dqs_io_o[1] = dq_dqs1_io;
assign dq_dqs_io_o[2] = dq_dqs2_io;
assign dq_dqs_io_o[3] = dq_dqs3_io;
assign dq_dqs_io_o[4] = dq_dqs4_io;
assign dq_dqs_io_o[5] = dq_dqs5_io;
assign dq_dqs_io_o[6] = dq_dqs6_io;
assign dq_dqs_io_o[7] = dq_dqs7_io;
assign dq_dqs_io_o[8] = dq_dqs8_io;

assign dqs0_i = dqs_i[0];
assign dqs1_i = dqs_i[1];
assign dqs2_i = dqs_i[2];
assign dqs3_i = dqs_i[3];
assign dqs4_i = dqs_i[4];
assign dqs5_i = dqs_i[5];
assign dqs6_i = dqs_i[6];
assign dqs7_i = dqs_i[7];
assign dqs8_i = dqs_i[8];

`include "dut_inst.v"

always @ (posedge slow_clk_r) begin
  if(watchdog_r == 200000) begin
    $display("******  TEST IS TIMED OUT  ******\n");
    $stop;
    watchdog_r <= 0;
  end
  else begin
    watchdog_r <= watchdog_r + 1;
  end
end


//Input Clock generation
initial begin
  slow_clk_r = 0;
  forever slow_clk_r = #(CLK_PERIOD/2) ~slow_clk_r;
end

initial begin
  slow_clk_90_r = 0;
  forever slow_clk_90_r = #(CLK_PERIOD/4) slow_clk_r;
end

initial begin
  slow_clk_180_r = 0;
  forever slow_clk_180_r = #(CLK_PERIOD/2) slow_clk_r;
end

initial begin
  ddr_clk_r  = 1;
  forever ddr_clk_r = #(DDR_CLK_PERIOD) ~ddr_clk_r;
end

generate
  if (PLL_EN) begin : PLL_ENA
  
    lscc_pll #(
      .CLKI_FREQ                (CLKI_FREQ                ),
      .CLKOP_FREQ_ACTUAL        (CLKOP_FREQ_ACTUAL        ),
      .CLKOS_FREQ_ACTUAL        (CLKOS_FREQ_ACTUAL        ),
      .CLKOS2_FREQ_ACTUAL       (CLKOS2_FREQ_ACTUAL       ),
      .CLKOS3_FREQ_ACTUAL       (CLKOS3_FREQ_ACTUAL       ),
      .CLKOS4_FREQ_ACTUAL       (CLKOS4_FREQ_ACTUAL       ),
      .CLKOS5_FREQ_ACTUAL       (CLKOS5_FREQ_ACTUAL       ),
      .CLKOP_PHASE_ACTUAL       (CLKOP_PHASE_ACTUAL       ),
      .CLKOS_PHASE_ACTUAL       (CLKOS_PHASE_ACTUAL       ),
      .CLKOS2_PHASE_ACTUAL      (CLKOS2_PHASE_ACTUAL      ),
      .CLKOS3_PHASE_ACTUAL      (CLKOS3_PHASE_ACTUAL      ),
      .CLKOS4_PHASE_ACTUAL      (CLKOS4_PHASE_ACTUAL      ),
      .CLKOS5_PHASE_ACTUAL      (CLKOS5_PHASE_ACTUAL      ),
      .CLKOS_EN                 (CLKOS_EN                 ),
      .CLKOS2_EN                (CLKOS2_EN                ),
      .CLKOS3_EN                (CLKOS3_EN                ),
      .CLKOS4_EN                (CLKOS4_EN                ),
      .CLKOS5_EN                (CLKOS5_EN                ),
      .CLKOP_BYPASS             (CLKOP_BYPASS             ),
      .CLKOS_BYPASS             (CLKOS_BYPASS             ),
      .CLKOS2_BYPASS            (CLKOS2_BYPASS            ),
      .CLKOS3_BYPASS            (CLKOS3_BYPASS            ),
      .CLKOS4_BYPASS            (CLKOS4_BYPASS            ),
      .CLKOS5_BYPASS            (CLKOS5_BYPASS            ),
      .ENCLKOP_EN               (ENCLKOP_EN               ),
      .ENCLKOS_EN               (ENCLKOS_EN               ),
      .ENCLKOS2_EN              (ENCLKOS2_EN              ),
      .ENCLKOS3_EN              (ENCLKOS3_EN              ),
      .ENCLKOS4_EN              (ENCLKOS4_EN              ),
      .ENCLKOS5_EN              (ENCLKOS5_EN              ),
      .FRAC_N_EN                (FRAC_N_EN                ),
      .SS_EN                    (SS_EN                    ),
      .DYN_PORTS_EN             (DYN_PORTS_EN             ),
      .PLL_RST                  (PLL_RST                  ),
      .LOCK_EN                  (LOCK_EN                  ),
      .PLL_LOCK_STICKY          (PLL_LOCK_STICKY          ),
      .LEGACY_EN                (LEGACY_EN                ),
      .LMMI_EN                  (LMMI_EN                  ),
      .APB_EN                   (APB_EN                   ),
      .POWERDOWN_EN             (POWERDOWN_EN             ),
      .TRIM_EN_P                (TRIM_EN_P                ),
      .TRIM_EN_S                (TRIM_EN_S                ),
      .PLL_REFCLK_FROM_PIN      (PLL_REFCLK_FROM_PIN      ),
      .IO_TYPE                  (PLL_IO_TYPE              ),
      .CLKOP_TRIM_MODE          (CLKOP_TRIM_MODE          ),
      .CLKOS_TRIM_MODE          (CLKOS_TRIM_MODE          ),
      .CLKOP_TRIM               (CLKOP_TRIM               ),
      .CLKOS_TRIM               (CLKOS_TRIM               ),
      .FBK_MODE                 (FBK_MODE                 ),
      .CLKI_DIVIDER_ACTUAL_STR  (CLKI_DIVIDER_ACTUAL_STR  ),
      .FBCLK_DIVIDER_ACTUAL_STR (FBCLK_DIVIDER_ACTUAL_STR ),
      .DIVOP_ACTUAL_STR         (DIVOP_ACTUAL_STR         ),
      .DIVOS_ACTUAL_STR         (DIVOS_ACTUAL_STR         ),
      .DIVOS2_ACTUAL_STR        (DIVOS2_ACTUAL_STR        ),
      .DIVOS3_ACTUAL_STR        (DIVOS3_ACTUAL_STR        ),
      .DIVOS4_ACTUAL_STR        (DIVOS4_ACTUAL_STR        ),
      .DIVOS5_ACTUAL_STR        (DIVOS5_ACTUAL_STR        ),
      .SSC_N_CODE_STR           (SSC_N_CODE_STR           ),
      .SSC_F_CODE_STR           (SSC_F_CODE_STR           ),
      .SSC_PROFILE              (SSC_PROFILE              ),
      .SSC_TBASE_STR            (SSC_TBASE_STR            ),
      .SSC_STEP_IN_STR          (SSC_STEP_IN_STR          ),
      .SSC_REG_WEIGHTING_SEL_STR(SSC_REG_WEIGHTING_SEL_STR),
      .DELA                     (DELA                     ),
      .DELB                     (DELB                     ),
      .DELC                     (DELC                     ),
      .DELD                     (DELD                     ),
      .DELE                     (DELE                     ),
      .DELF                     (DELF                     ),
      .PHIA                     (PHIA                     ),
      .PHIB                     (PHIB                     ),
      .PHIC                     (PHIC                     ),
      .PHID                     (PHID                     ),
      .PHIE                     (PHIE                     ),
      .PHIF                     (PHIF                     ),
      .REF_COUNTS               (REF_COUNTS               ),
      .INTFBKDEL_SEL            (INTFBKDEL_SEL            ),
      .PMU_WAITFORLOCK          (PMU_WAITFORLOCK          ),
      .REF_OSC_CTRL             (REF_OSC_CTRL             ),
//    .SIM_FLOAT_PRECISION      (SIM_FLOAT_PRECISION      ), use default value
      .IPI_CMP                  (IPI_CMP                  ),
      .CSET                     (CSET                     ),
      .CRIPPLE                  (CRIPPLE                  ),
      .IPP_CTRL                 (IPP_CTRL                 ),
      .IPP_SEL                  (IPP_SEL                  ),
      .BW_CTL_BIAS              (BW_CTL_BIAS              ),
      .V2I_PP_RES               (V2I_PP_RES               ),
      .KP_VCO                   (KP_VCO                   ),
      .V2I_KVCO_SEL             (V2I_KVCO_SEL             ),
      .V2I_1V_EN                (V2I_1V_EN                ))
    u_pll (
      .clki_i                   (pll_refclk_i), 
      .usr_fbclk_i              (1'b0        ), 
      .rstn_i                   (pll_rst_n_i ), 
      .legacy_i                 (1'b1        ), 
      .pllpd_en_n_i             (1'b1        ), 
      .phasedir_i               (1'b0        ), 
      .phasestep_i              (1'b0        ), 
      .phaseloadreg_i           (1'b0        ), 
      .phasesel_i               (3'b000      ), 
      .enclkop_i                (1'b1        ), 
      .enclkos_i                (1'b1        ), 
      .enclkos2_i               (1'b1        ), 
      .enclkos3_i               (1'b1        ), 
      .enclkos4_i               (1'b1        ), 
      .enclkos5_i               (1'b1        ), 
      .clkop_o                  (ddr_clk_w   ), 
      .clkos_o                  (            ), // unused in TB
      .clkos2_o                 (            ), 
      .clkos3_o                 (            ), 
      .clkos4_o                 (            ), 
      .clkos5_o                 (            ), 
      .lock_o                   (            ), // unused in TB
      .lmmi_clk_i               (1'b0        ), 
      .lmmi_resetn_i            (1'b1        ), 
      .lmmi_request_i           (1'b0        ), 
      .lmmi_wr_rdn_i            (1'b0        ), 
      .lmmi_offset_i            (7'b0000000  ), 
      .lmmi_wdata_i             (8'b00000000 ), 
      .lmmi_rdata_o             (            ), 
      .lmmi_rdata_valid_o       (            ), 
      .lmmi_ready_o             (            ), 
      .apb_pclk_i               (1'b0        ), 
      .apb_preset_n_i           (1'b1        ), 
      .apb_penable_i            (1'b0        ), 
      .apb_psel_i               (1'b0        ), 
      .apb_pwrite_i             (1'b0        ), 
      .apb_paddr_i              (7'b0000000  ), 
      .apb_pwdata_i             (8'b00000000 ), 
      .apb_pready_o             (            ), 
      .apb_pslverr_o            (            ), 
      .apb_prdata_o             (            )); 
  end
  else begin : PLL_DIS
    assign ddr_clk_w = ddr_clk_r;
  end
endgenerate

initial begin
  ddr_clk_90_r  = 0;
  forever ddr_clk_90_r = #(DDR_CLK_PERIOD/2) ddr_clk_w;
end

initial begin
  ddr_clk_180_r  = 0;
  forever ddr_clk_180_r = #(DDR_CLK_PERIOD) ddr_clk_w;
end

initial begin
  ddr_clk_270_r  = 0;
  forever ddr_clk_270_r = #(DDR_CLK_PERIOD/2) ddr_clk_180_r;
end

initial begin
  pll_refclk_i   = 0;
  forever pll_refclk_i = #(PLL_REFCLK_PREIOD/2) ~pll_refclk_i;
end


always @(posedge sclk_o) begin
  if(rst_w == 1'b1) begin
    sclk_o_next_period <= 0;
    sclk_o_rising_edge_count<= 0;
  end
  else begin
    sclk_o_rising_edge_count <= 1;
    sclk_o_next_period <= $realtime;
  end
end

always @(posedge sclk_o) begin
  if(rst_w == 1'b1) begin
    sclk_o_period <= 0;
  end
  else begin
    if (sclk_o_rising_edge_count ==1) begin
      sclk_o_period <= ($realtime - sclk_o_next_period);
    end
  end
end

always @(posedge ck_o[0]) begin
  if(rst_w == 1'b1) begin
    ck_o_rising_edge_count <= 0;
    ck_o_next_period <= 0;
  end
  else begin
    ck_o_rising_edge_count <= 1;
    ck_o_next_period <= $realtime;
  end
end

always @(posedge ck_o[0]) begin
  if(rst_w == 1'b1) begin
    ck_o_period <= 0;
  end
  else begin
    if (ck_o_rising_edge_count == 1) begin
      ck_o_period <= ($realtime - ck_o_next_period);
    end
  end
end


//Error generation logic
generate
   if (CLK_ADDR_CMD_ENABLE == 1) begin
      for(i=0;i<NUM_DDRCLK;i=i+1) begin
         always @ ( * ) begin
            #10;
            if((ready_o_4_r == 1) && (ck_o_period != ck_o_exp_period)) begin
            error_clk_r = 1;
            end
         end
      end
   end
endgenerate

always @ ( * ) begin
  error_global_r = error_clk_r || error_sclk_o_r || error_ca_o_r || error_csn_o_r || error_addr_o_r || error_casn_o_r || error_rasn_o_r || error_ba_o_r || error_odt_o_r || error_cke_o_r || error_wen_o_r || error_dq_dqs_o_r || error_data_dqs_o_r || error_dqs_o_r || error_dm_o_r;
end

always @ ( * ) begin
  if(((INTERFACE_TYPE == "LPDDR3") || (INTERFACE_TYPE == "LPDDR2")) && (CLK_ADDR_CMD_ENABLE == 1)) begin
    #10;
    if((ready_o_4_r == 1) && (exp_ca_o_w !== ca_o)) begin
      error_ca_o_r = 1;
    end
  end
end

always @ ( * ) begin
  #10;
  if((ready_o_4_r == 1) && (sclk_o_exp_period != sclk_o_period)) begin
    error_sclk_o_r = 1;
  end
end

generate
    if(((INTERFACE_TYPE == "DDR3") || (INTERFACE_TYPE == "DDR3L")) && (CLK_ADDR_CMD_ENABLE == 1)) begin
    always @ ( * ) begin
      #10;
      if((ready_o_4_r == 1) && (exp_addr_o_w !== addr_o)) begin
        error_addr_o_r = 1;
      end
    end

    always @ ( * ) begin
      #10;
      if((ready_o_4_r == 1) && (exp_ba_o_w !== ba_o)) begin
        error_ba_o_r = 1;
      end
    end

    always @ ( * ) begin
      #10;
      if((ready_o_4_r == 1) && (exp_casn_o_w !== casn_o)) begin
        error_casn_o_r = 1;
      end
    end

    always @ ( * ) begin
      #10;
      if((ready_o_4_r == 1) && (exp_rasn_o_w !== rasn_o)) begin
        error_rasn_o_r = 1;
      end
    end
    always @ ( * ) begin
       #10;
       if((ready_o_4_r == 1) && (exp_wen_o_w !== wen_o)) begin
          error_wen_o_r = 1;
       end
    end
  end
endgenerate

always @ ( * ) begin
  #10;
  if((INTERFACE_TYPE != "LPDDR2" && CLK_ADDR_CMD_ENABLE == 1) && (ready_o_4_r == 1) && (exp_odt_o_w !== odt_o)) begin
    error_odt_o_r = 1;
  end
end

generate
 if (CLK_ADDR_CMD_ENABLE == 1) begin
   always @ ( * ) begin
      #10;
      if((ready_o_4_r == 1) && (exp_cke_o_w !== cke_o)) begin
         error_cke_o_r = 1;
      end
   end
   always @ ( * ) begin
      #10;
      if((ready_o_4_r == 1) && (exp_csn_o_w !== csn_o)) begin
         error_csn_o_r = 1;
      end
   end
 end
endgenerate

generate
  for (i=0; i<NUM_DQS_GROUP; i=i+1) begin
    always @ ( * ) begin
      #10;
      if((ready_o_4_r == 1) && (wrlvl_del_rdy_r[i] == 1) && (ce_i == 1) && (exp_wrlvl_dqs_dly_r[i] < DDR_CLK_PERIOD +500)) begin
        if(dqs_outen_n_dqs_i_17[i] == 0) begin
          if(exp_dqs_io_o_w[i] !== dqs_io_o[i]) begin
            error_dqs_o_r = 1;
          end
        end
      end
    end
  end
endgenerate

generate
  for (i=0; i<NUM_DQS_GROUP; i=i+1) begin
    always @ (posedge ddr_clk_w, negedge ddr_clk_w) begin
      if((rst_w == 1)|| (ready_o == 0))begin
        dqs_io_i_0_r[i]  <= 1'b1;
        dqs_io_i_1_r[i]  <= 1'b1;
        dqs_io_i_2_r[i]  <= 1'b1;
        dqs_io_i_3_r[i]  <= 1'b1;
        dqs_io_i_4_r[i]  <= 1'b1;
        dqs_io_i_5_r[i]  <= 1'b1;
        dqs_io_i_6_r[i]  <= 1'b1;
        dqs_io_i_7_r[i]  <= 1'b1;
        dqs_io_i_8_r[i]  <= 1'b1;
        dqs_io_i_9_r[i]  <= 1'b1;
        dqs_io_i_10_r[i] <= 1'b1;
        dqs_io_i_11_r[i] <= 1'b1;
        dqs_io_i_12_r[i] <= 1'b1;
        dqs_io_i_13_r[i] <= 1'b1;
        dqs_io_i_14_r[i] <= 1'b1;
        dqs_io_i_15_r[i] <= 1'b1;
        dqs_io_i_16_r[i] <= 1'b1;
        dqs_io_i_17_r[i] <= 1'b1;

        dqs_outen_n_dqs_i_00[i] <= {GEARING{1'b0}};
        dqs_outen_n_dqs_i_01[i] <= {GEARING{1'b0}};
        dqs_outen_n_dqs_i_02[i] <= {GEARING{1'b0}};
        dqs_outen_n_dqs_i_03[i] <= {GEARING{1'b0}};
        dqs_outen_n_dqs_i_04[i] <= {GEARING{1'b0}};
        dqs_outen_n_dqs_i_05[i] <= {GEARING{1'b0}};
        dqs_outen_n_dqs_i_06[i] <= {GEARING{1'b0}};
        dqs_outen_n_dqs_i_07[i] <= {GEARING{1'b0}};
        dqs_outen_n_dqs_i_08[i] <= {GEARING{1'b0}};
        dqs_outen_n_dqs_i_09[i] <= {GEARING{1'b0}};
        dqs_outen_n_dqs_i_10[i] <= {GEARING{1'b0}};
        dqs_outen_n_dqs_i_11[i] <= {GEARING{1'b0}};
        dqs_outen_n_dqs_i_12[i] <= {GEARING{1'b0}};
        dqs_outen_n_dqs_i_13[i] <= {GEARING{1'b0}};
        dqs_outen_n_dqs_i_14[i] <= {GEARING{1'b0}};
        dqs_outen_n_dqs_i_15[i] <= {GEARING{1'b0}};
        dqs_outen_n_dqs_i_16[i] <= {GEARING{1'b0}};
        dqs_outen_n_dqs_i_17[i] <= {GEARING{1'b0}};
        dqs_outen_n_dqs_i_18[i] <= {GEARING{1'b0}};
        dqs_outen_n_dqs_i_19[i] <= {GEARING{1'b0}};
      end
      else begin
//        if((ce_out_i == 1) || (ce_in_i == 1)) begin
        dqs_io_i_0_r[i]  <= dqs_io_i[i]    ;
        dqs_io_i_1_r[i]  <= dqs_io_i_0_r[i];
        dqs_io_i_2_r[i]  <= dqs_io_i_1_r[i];
        dqs_io_i_3_r[i]  <= dqs_io_i_2_r[i];
        dqs_io_i_4_r[i]  <= dqs_io_i_3_r[i];
        dqs_io_i_5_r[i]  <= dqs_io_i_4_r[i];
        dqs_io_i_6_r[i]  <= dqs_io_i_5_r[i];
        dqs_io_i_7_r[i]  <= dqs_io_i_6_r[i];
        dqs_io_i_8_r[i]  <= dqs_io_i_7_r[i];
        dqs_io_i_9_r[i]  <= dqs_io_i_8_r[i];
        dqs_io_i_10_r[i] <= dqs_io_i_9_r[i];
        dqs_io_i_11_r[i] <= dqs_io_i_10_r[i];
        dqs_io_i_12_r[i] <= dqs_io_i_11_r[i];
        dqs_io_i_13_r[i] <= dqs_io_i_12_r[i];
        dqs_io_i_14_r[i] <= dqs_io_i_13_r[i];
        dqs_io_i_15_r[i] <= dqs_io_i_14_r[i];
        dqs_io_i_16_r[i] <= dqs_io_i_15_r[i];
        dqs_io_i_17_r[i] <= dqs_io_i_16_r[i];

        dqs_outen_n_dqs_i_00[i] <= dqs_outen_n_dqs_i[i];
        dqs_outen_n_dqs_i_01[i] <= dqs_outen_n_dqs_i_00[i];
        dqs_outen_n_dqs_i_02[i] <= dqs_outen_n_dqs_i_01[i];
        dqs_outen_n_dqs_i_03[i] <= dqs_outen_n_dqs_i_02[i];
        dqs_outen_n_dqs_i_04[i] <= dqs_outen_n_dqs_i_03[i];
        dqs_outen_n_dqs_i_05[i] <= dqs_outen_n_dqs_i_04[i];
        dqs_outen_n_dqs_i_06[i] <= dqs_outen_n_dqs_i_05[i];
        dqs_outen_n_dqs_i_07[i] <= dqs_outen_n_dqs_i_06[i];
        dqs_outen_n_dqs_i_08[i] <= dqs_outen_n_dqs_i_07[i];
        dqs_outen_n_dqs_i_09[i] <= dqs_outen_n_dqs_i_08[i];
        dqs_outen_n_dqs_i_10[i] <= dqs_outen_n_dqs_i_09[i];
        dqs_outen_n_dqs_i_11[i] <= dqs_outen_n_dqs_i_10[i];
        dqs_outen_n_dqs_i_12[i] <= dqs_outen_n_dqs_i_11[i];
        dqs_outen_n_dqs_i_13[i] <= dqs_outen_n_dqs_i_12[i];
        dqs_outen_n_dqs_i_14[i] <= dqs_outen_n_dqs_i_13[i];
        dqs_outen_n_dqs_i_15[i] <= dqs_outen_n_dqs_i_14[i];
        dqs_outen_n_dqs_i_16[i] <= dqs_outen_n_dqs_i_15[i];
        dqs_outen_n_dqs_i_17[i] <= dqs_outen_n_dqs_i_16[i];
        dqs_outen_n_dqs_i_18[i] <= dqs_outen_n_dqs_i_17[i];
        dqs_outen_n_dqs_i_19[i] <= dqs_outen_n_dqs_i_18[i];
      end
    end
  end
endgenerate

generate
  for (i=0; i<NUM_DQS_GROUP; i=i+1) begin
    always @ ( * ) begin
      #10;
      if(ready_o_4_r == 1) begin
        if((dq_outen_n_i_10_r == 0) && (test_case_r == `STATE_WRITE_DATA)/* && (total_delay_done == 1'b1)*/) begin
          if(exp_dq_dqs_io_o_w[i] !== dq_dqs_io_o[i]) begin
            error_dq_dqs_o_r = 1;
          end
        end
      end
    end
  end
endgenerate

generate
  for (i=0; i<NUM_DQS_GROUP; i=i+1) begin
    always @ ( * ) begin
      #10;
      if(ready_o_4_r == 1) begin
        if((exp_data_delay_counter_r[i] == 32) && ((test_case_r == `STATE_READ_DATA) || (test_case_r == `STATE_READ_DELAY)) && (((data_valid_dqs_o[i] == 1) && (burst_detect_sclk_dqs_o[i] == 1) && (burst_detect_dqs_o[i] == 1)))) begin
          if(exp_data_dqs_o_w[i] !== data_dqs_o[i]) begin
            error_data_dqs_o_r = 1;
          end
        end
      end
    end
  end
endgenerate

// DM Error Generation Logic
generate
  if (DATA_MASK_ENABLE == 1) begin
   for (i=0; i<NUM_DQS_GROUP; i=i+1) begin
      always @ ( * ) begin
         #10;
         if(ready_o_4_r == 1) begin
         if((ce_out_i_1_r == 1) && (ce_out_i_2_r == 1)&& (ce_i == 1)&& (wrlvl_del_rdy_r[i] == 1) && (wr_del_rdy_r[i] == 1) && (exp_wr_dqs_dly_r[i] < (DDR_CLK_PERIOD+500))&& test_case_r == `STATE_WRITE_DATA) begin
            if(exp_dm_o_w[i] !== dm_o[i]) begin
               error_dm_o_r = 1;
            end
         end
         end
      end
   end
  end
endgenerate
//

always @ (posedge sclk_o, posedge rst_w) begin
  if(rst_w == 1) begin
    ready_o_0_r <= 0;
    ready_o_1_r <= 0;
    ready_o_2_r <= 0;
    ready_o_3_r <= 0;
    ready_o_4_r <= 0;
  end
  else if (total_delay_done) begin
    ready_o_0_r <= ready_o;
    ready_o_1_r <= ready_o_0_r;
    ready_o_2_r <= ready_o_1_r;
    ready_o_3_r <= ready_o_2_r;
    ready_o_4_r <= ready_o_3_r;
  end
end

generate
for(i=0; i< NUM_DQS_GROUP; i = i+1) begin
  assign dqswdelaybefore12_5pscell_w[i] = (wrlvl_code_r[i] < 12) ? 1500 : (((wrlvl_code_r[i] > 11) && (wrlvl_code_r[i] < 448)) ? (500 + (wrlvl_code_r[i]/4)*500) : 56000);
end
endgenerate



//Top logic
initial begin
  test_case_r = 0;
  test_case_done_r = 0;
  watchdog_r  = 0;
  rst_w       = 0;

  error_global_r     = 0;
  error_clk_r        = 0;
  error_ca_o_r       = 0;
  error_sclk_o_r     = 0;
  error_csn_o_r      = 0;
  error_addr_o_r     = 0;
  error_casn_o_r     = 0;
  error_rasn_o_r     = 0;
  error_ba_o_r       = 0;
  error_odt_o_r      = 0;
  error_cke_o_r      = 0;
  error_wen_o_r      = 0;
  error_dq_dqs_o_r   = 0;
  error_data_dqs_o_r = 0;
  error_dm_o_r       = 0;
  error_dqs_o_r      = 0;


  error_print_flag_clk_r        = 0;
  error_print_flag_ca_o_r       = 0;
  error_print_flag_sclk_o_r     = 0;
  error_print_flag_csn_o_r      = 0;
  error_print_flag_addr_o_r     = 0;
  error_print_flag_casn_o_r     = 0;
  error_print_flag_rasn_o_r     = 0;
  error_print_flag_ba_o_r       = 0;
  error_print_flag_odt_o_r      = 0;
  error_print_flag_cke_o_r      = 0;
  error_print_flag_wen_o_r      = 0;
  error_print_flag_dq_dqs_o_r   = 0;
  error_print_flag_data_dqs_o_r = 0;
  error_print_flag_dm_o_r       = 0;
  error_print_flag_dqs_o_r      = 0;






  pll_lock_i  = 0;
  selclk_i    = 0; //???
  ce_in_i     = 0;
  ce_out_i    = 0;

  pause_cmd_i = 1; //???
  rst_w       = 0;
  pll_rst_n_i = 0;

  @(posedge sync_clk_i);
  @(posedge sync_clk_i);
  rst_w      = 1;
  pll_rst_n_i = 1;
  @(posedge sync_clk_i);
  @(posedge sync_clk_i);
  @(posedge sync_clk_i);
  @(posedge sync_clk_i);
  @(posedge sync_clk_i);
  @(posedge sync_clk_i);
  @(posedge sync_clk_i);
  @(posedge sync_clk_i);

  rst_w      = 0;
  @(posedge sync_clk_i);
  if (PLL_EN) begin  // Wait for pll_lock_o to assert
    while(!pll_lock_o) @(posedge sync_clk_i);
  end
  pll_lock_i = 1;
  pause_cmd_i = 0;

//  test_case_r = `STATE_INIT;
//  test_case_done_r = {NUM_DQS_GROUP{1'b1}};

//  while((|test_case_done_r) == 1) begin
//    @(posedge ddr_clk_w, negedge ddr_clk_w);
//  end

  while(ready_o_0_r !== 1) begin
    @(posedge ddr_clk_w, negedge ddr_clk_w);
  end
  watchdog_r = 0;
  // while((total_delay_done) == 0) begin
    // @(posedge ddr_clk_w, negedge ddr_clk_w);
  // end
  @(posedge ddr_clk_w, negedge ddr_clk_w);
  test_case_r = `STATE_READ_TRAINING;
  test_case_done_r = {NUM_DQS_GROUP{1'b1}};
  while((|test_case_done_r) == 1) begin
    @(posedge ddr_clk_w, negedge ddr_clk_w);
  end

    @(posedge ddr_clk_w, negedge ddr_clk_w);
  test_case_r = `STATE_READ_DATA;
    test_case_done_r = {NUM_DQS_GROUP{1'b1}};
    while((|test_case_done_r) == 1) begin
      @(posedge ddr_clk_w, negedge ddr_clk_w);
    end


  @(posedge ddr_clk_w, negedge ddr_clk_w);
  test_case_r = `STATE_WRITE_DATA;

  test_case_done_r = {NUM_DQS_GROUP{1'b1}};
  while((|test_case_done_r) == 1) begin
    @(posedge ddr_clk_w, negedge ddr_clk_w);
  end


  if(DYN_MARGIN_ENABLE == 1) begin
    if((INTERFACE_TYPE == "LPDDR3") || (INTERFACE_TYPE == "DDR3")) begin
      @(posedge ddr_clk_w, negedge ddr_clk_w);
      test_case_r = `STATE_WRITE_LEVELING;
      test_case_done_r = {NUM_DQS_GROUP{1'b1}};
      while((|test_case_done_r) == 1) begin
        @(posedge ddr_clk_w, negedge ddr_clk_w);
      end
    end
    @(posedge ddr_clk_w, negedge ddr_clk_w);
    test_case_r = `STATE_WRITE_DELAY;
    test_case_done_r = {NUM_DQS_GROUP{1'b1}};
    while((|test_case_done_r) == 1) begin
      @(posedge ddr_clk_w, negedge ddr_clk_w);
    end
  end

  if(DYN_MARGIN_ENABLE == 1) begin
    @(posedge ddr_clk_w, negedge ddr_clk_w);
    test_case_r = `STATE_READ_DELAY;
    test_case_done_r = {NUM_DQS_GROUP{1'b1}};
    while((|test_case_done_r) == 1) begin
      @(posedge ddr_clk_w, negedge ddr_clk_w);
    end
  end

  if(error_clk_r == 0)
    $display("****** CLK TEST IS PASSED *******\n");

  if(error_sclk_o_r == 0)
    $display("****** SCLK TEST IS PASSED ******\n");

  if(CLK_ADDR_CMD_ENABLE == 1) begin
    if((INTERFACE_TYPE == "LPDDR2") || (INTERFACE_TYPE == "LPDDR3")) begin
      if(error_ca_o_r == 0)
        $display("****** CA TEST IS PASSED *******\n");
    end
    else if(CLK_ADDR_CMD_ENABLE == 1) begin
      if(error_addr_o_r == 0)
        $display("****** ADDRESS TEST IS PASSED *******\n");

      if(error_casn_o_r == 0)
        $display("****** CASN TEST IS PASSED *******\n");

      if(error_rasn_o_r == 0)
        $display("****** RASN TEST IS PASSED *******\n");

      if(error_ba_o_r == 0)
        $display("****** BA TEST IS PASSED *******\n");

      if(error_wen_o_r == 0)
        $display("****** WEN OUT TEST IS PASSED *******\n");
    end

    if((INTERFACE_TYPE != "LPDDR2") && (CLK_ADDR_CMD_ENABLE == 1)) begin
      if(error_odt_o_r == 0)
        $display("****** ODT OUT TEST IS PASSED *******\n");
    end

    if(CLK_ADDR_CMD_ENABLE == 1) begin
      if(error_csn_o_r == 0)
        $display("****** CSN TEST IS PASSED *******\n");

      if(error_cke_o_r == 0)
        $display("****** CKE OUT TEST IS PASSED *******\n");
    end
  end

  if(error_dq_dqs_o_r == 0)
    $display("****** DQ TX TEST IS PASSED *******\n");

  if(error_data_dqs_o_r == 0)
    $display("****** DQ RX TEST IS PASSED *******\n");

  if(error_dqs_o_r == 0)
    $display("****** DQS OUT TEST IS PASSED *******\n");


  if(DATA_MASK_ENABLE == 1) begin
    if(error_dm_o_r == 0)
      $display("****** DM OUT TEST IS PASSED *******\n");
  end

  if(error_global_r == 0) begin
    $display("*SIMULATION PASSED*");
  end
  else begin
    $display("*TESTS COMPLETE WITH ERRORS*");
  end

  $stop;

end


always @( * ) begin

  if((error_clk_r == 1) && (error_print_flag_clk_r == 0)) begin
    $display("****** CLK TEST FAILED *******\n");
    error_print_flag_clk_r = 1;
  end

  if((error_sclk_o_r == 1) && (error_print_flag_sclk_o_r == 0)) begin
    $display("****** SCLK TEST FAILED *******\n");
    error_print_flag_sclk_o_r = 1;
  end

  if(CLK_ADDR_CMD_ENABLE == 1) begin
    if((INTERFACE_TYPE == "LPDDR2") || (INTERFACE_TYPE == "LPDDR3")) begin
      if((error_ca_o_r == 1) && (error_print_flag_ca_o_r == 0)) begin
        $display("****** CA TEST FAILED *******\n");
        error_print_flag_ca_o_r = 1;
      end
    end
    else if(CLK_ADDR_CMD_ENABLE == 1) begin
      if((error_addr_o_r == 1) && (error_print_flag_addr_o_r == 0)) begin
        $display("****** ADDRESS TEST FAILED *******\n");
        error_print_flag_addr_o_r = 1;
      end

      if((error_casn_o_r == 1) && (error_print_flag_casn_o_r == 0)) begin
        $display("****** CASN TEST FAILED *******\n");
        error_print_flag_casn_o_r = 1;
      end

      if((error_rasn_o_r == 1) && (error_print_flag_rasn_o_r ==0)) begin
        $display("****** RASN TEST FAILED *******\n");
        error_print_flag_rasn_o_r = 1;
      end

      if((error_ba_o_r == 1) && (error_print_flag_ba_o_r == 0)) begin
        $display("****** BA TEST FAILED *******\n");
        error_print_flag_ba_o_r = 1;
      end

      if((error_wen_o_r == 1) && (error_print_flag_wen_o_r == 0)) begin
        $display("****** WEN OUT TEST FAILED *******\n");
        error_print_flag_wen_o_r = 1;
      end
    end

    if((INTERFACE_TYPE != "LPDDR2") && (CLK_ADDR_CMD_ENABLE == 1)) begin
      if((error_odt_o_r == 1) && (error_print_flag_odt_o_r == 0)) begin
        $display("****** ODT OUT TEST FAILED *******\n");
        error_print_flag_odt_o_r = 1;
      end
    end

    if(CLK_ADDR_CMD_ENABLE == 1) begin
      if((error_csn_o_r == 1) && (error_print_flag_csn_o_r == 0)) begin
        $display("****** CSN TEST FAILED *******\n");
        error_print_flag_csn_o_r = 1;
      end

      if((error_cke_o_r == 1) && (error_print_flag_cke_o_r == 0)) begin
        $display("****** CKE OUT TEST FAILED *******\n");
        error_print_flag_cke_o_r = 1;
      end
    end
  end

  if((error_dq_dqs_o_r == 1) && (error_print_flag_dq_dqs_o_r == 0)) begin
    $display("[%010d] ****** DQ TX TEST FAILED *******\n", $time);
    error_print_flag_dq_dqs_o_r = 1;
  end

  if((error_data_dqs_o_r == 1) && (error_print_flag_data_dqs_o_r == 0)) begin
    $display("****** DQ RX TEST FAILED *******\n");
    error_print_flag_data_dqs_o_r = 1;
  end

  if((error_dqs_o_r == 1) && (error_print_flag_dqs_o_r == 0)) begin
    $display("****** DQS OUT TEST FAILED *******\n");
    error_print_flag_dqs_o_r = 1;
  end


  if(DATA_MASK_ENABLE == 1) begin
    if((error_dm_o_r == 1) && (error_print_flag_dm_o_r == 0)) begin
      $display("****** DM OUT TEST FAILED *******\n");
      error_print_flag_dm_o_r = 1;
    end
  end
end

//GDDR/RX_SYNC Logic
initial begin
  sync_clk_i = 0;
  forever begin
    sync_clk_i = #(`SYNC_CLK_PERIOD/2) ~sync_clk_i;
  end
end

initial begin
  sync_rst_i = 1;
  while(rst_w == 0)
    #100;
  while(rst_w == 1)
    #100;
  @(posedge sync_clk_i);
  sync_rst_i = 1;
  @(posedge sync_clk_i);
  @(posedge sync_clk_i);
  @(posedge sync_clk_i);
  sync_rst_i = 0;
end

initial begin
  sync_update_i = 0;
  sync_done_r   = 0;
  while(rst_w == 0)
    #100;
  while(rst_w == 1)
    #100;
  while(sync_rst_i == 1)
    #100;

  @(posedge sync_clk_i);
  @(posedge sync_clk_i);
  sync_update_i = 1;
  @(posedge sync_clk_i);
  @(posedge sync_clk_i);
  @(posedge sync_clk_i);
  @(posedge sync_clk_i);
  sync_update_i = 0;
  sync_done_r   = 1;
end


//Initialize
generate
  for(i = 0; i<NUM_DQS_GROUP; i=i+1) begin
    initial begin
      dqs_i[i]             = 0;
      timeout_r[i]         = 0;

      pause_i              = 1;
      ce_in_i              = 0;
      ce_out_i             = 0;
      dqs_outen_n_dqs_i[i] = {GEARING{1'b0}};
      dq_outen_n_i         = {GEARING{1'b0}};

      rd_clksel_dqs_i[i]   = 0;
      rd_i[i]              = 4'hF;
      rd_dir_dqs_i[i]      = 1'b0;
      rd_loadn_dqs_i[i]    = 1'b1;
      rd_move_dqs_i[i]     = 1'b0;
      rd_timeout_r[i]      = 0;

      wr_dir_dqs_i[i]      = 0;
      wr_loadn_dqs_i[i]    = 1'b1;
      wr_move_dqs_i[i]     = 1'b0;
      wr_timeout_r[i]      = 0;

      wrlvl_dir_dqs_i[i]   = 0;
      wrlvl_loadn_dqs_i[i] = 1'b1;
      wrlvl_move_dqs_i[i]  = 1'b0;
      wrlvl_timeout_r[i]   = 0;

      dqs_io_i[i]          = 0;
//      dq_dqs_io_i[i]       = 0;

      if(GEARING == 2) begin
        data_dqs_i[i] = 32'h44332211;
      end
      else begin
        data_dqs_i[i] = 64'h8877665544332211;
      end

      pause_i              = 0;

      while(rst_w == 0)
        #100;

      rd_loadn_dqs_i[i]    = 1'b0;
      wr_loadn_dqs_i[i]    = 1'b0;
      wrlvl_loadn_dqs_i[i] = 1'b0;

      while(rst_w == 1)
        #100;

      rd_loadn_dqs_i[i]    = 1'b1;
      wr_loadn_dqs_i[i]    = 1'b1;
      wrlvl_loadn_dqs_i[i] = 1'b1;

      @(posedge sclk_o);

      while(ready_o_3_r == 0)
        @(posedge sclk_o);

      rd_loadn_dqs_i[i]    = 1'b0;
      wr_loadn_dqs_i[i]    = 1'b0;
      wrlvl_loadn_dqs_i[i] = 1'b0;
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);


      rd_move_dqs_i[i]     = 1'b1;
      wr_move_dqs_i[i]     = 1'b1;
      wrlvl_move_dqs_i[i]  = 1'b1;
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      rd_move_dqs_i[i]     = 1'b0;
      wr_move_dqs_i[i]     = 1'b0;
      wrlvl_move_dqs_i[i]  = 1'b0;

      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);

      rd_loadn_dqs_i[i]    = 1'b1;
      wr_loadn_dqs_i[i]    = 1'b1;
      wrlvl_loadn_dqs_i[i] = 1'b1;

//      test_case_done_r[i] = 1'b0;
//      @(posedge sclk_o);
    end
  end
endgenerate

//Read Training logic
generate
  for(i = 0; i<NUM_DQS_GROUP; i=i+1) begin
    initial begin
      while(test_case_r != `STATE_READ_TRAINING) begin
        @(posedge sclk_o);
      end

      dqs_outen_n_dqs_i[i] = {GEARING{1'b1}};
      dq_outen_n_i         = {GEARING{1'b1}};
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);

      ce_in_i              = 1;
      rd_clksel_dqs_i[i]   = 0;
      rd_i[i]              = 0;
      @(posedge sclk_o);

      for(n[i] = 1; n[i] <= 5'h10; n[i] = n[i]+1) begin
        rd_i[i] = 4'hF;
        @(posedge sclk_o);
        @(posedge sclk_o);
        rd_i[i] = 4'h0;
        repeat(8) begin
        @(posedge sclk_o);
        end
        pause_i = 1;
        @(posedge sclk_o);
        @(posedge sclk_o);
        rd_clksel_dqs_i[i] = n[i][3:0];
        @(posedge sclk_o);
        @(posedge sclk_o);
        pause_i = 0;
        timeout_r[i] = 0;
        while((timeout_r[i] < 100) && ((data_valid_dqs_o[i] == 0) || (burst_detect_sclk_dqs_o[i] == 0) || (burst_detect_dqs_o[i] == 0))) begin
          @(posedge ddr_clk_w, negedge ddr_clk_w);
          timeout_r[i] = timeout_r[i] + 1;
        end

        if((burst_detect_sclk_dqs_o[i] == 1) && (burst_detect_dqs_o[i] == 1)) begin
          $display("****** VALID DATA ******\n");
          $display("rd_clksel_dqs_%d = %h", i, rd_clksel_dqs_i[i]);
        end

        @(posedge sclk_o);
        @(posedge sclk_o);
        @(posedge sclk_o);
        @(posedge sclk_o);
      end

      rd_clksel_dqs_i[i] = 0;
      rd_i[i] = 4'hF;
      ce_in_i = 0;
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);

      test_case_done_r[i] = 1'b0;
    end
  end
endgenerate


//DQS Read delay logic
generate
  for(i=0; i < NUM_DQS_GROUP; i=i+1) begin
    initial begin
      while(test_case_r != `STATE_READ_DELAY) begin
        @(posedge sclk_o);
      end

      dqs_outen_n_dqs_i[i] = {GEARING{1'b1}};
      dq_outen_n_i         = {GEARING{1'b1}};
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);

      ce_in_i = 1;
      @(posedge sclk_o);
/*
      rd_loadn_dqs_i[i]    = 1'b0;
      @(posedge sclk_o);
      rd_loadn_dqs_i[i]    = 1'b1;
      @(posedge sclk_o);
      */

      rd_dir_dqs_i[i]  = 1'b0;

      while ((rd_cout_dqs_o[i] == 1) && (rd_timeout_r[i] < 1024)) begin
        rd_move_dqs_i[i] = 1'b1;
        @(posedge sclk_o);
        rd_move_dqs_i[i] = 1'b0;
        @(posedge sclk_o);
        @(posedge sclk_o);
        @(posedge sclk_o);
        @(posedge sclk_o);
        rd_timeout_r[i] = rd_timeout_r[i] +1;
      end

      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);

      for(a[i] = 0; a[i] < 512; a[i] = a[i]+1) begin
        rd_dir_dqs_i[i]  = 1'b0;
        rd_move_dqs_i[i] = 1'b1;
        @(posedge sclk_o);
        rd_move_dqs_i[i] = 1'b0;
        @(posedge sclk_o);
        @(posedge sclk_o);
        @(posedge sclk_o);
        @(posedge sclk_o);

        if(exp_rd_dqs_dly_r[i] >= DDR_CLK_PERIOD-250) begin
          a[i] = 512;
        end

      end

      ce_in_i = 0;

      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);

      test_case_done_r[i] = 1'b0;
    end
  end
endgenerate

//Read Data
generate
  for(i=0; i < NUM_DQS_GROUP; i=i+1) begin
    initial begin
      while(test_case_r != `STATE_READ_DATA) begin
        @(posedge sclk_o);
      end
      dqs_outen_n_dqs_i[i] = {GEARING{1'b1}};
      dq_outen_n_i         = {GEARING{1'b1}};
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);

      ce_in_i = 1;
      for(a[i] = 0; a[i] < 128; a[i] = a[i]+1) begin
        @(posedge sclk_o);
      end
      ce_in_i = 0;

      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);

      test_case_done_r[i] = 1'b0;
    end
  end
endgenerate

//Write Data
generate
  for(i=0;i<NUM_DQS_GROUP;i=i+1) begin
    initial begin
      while(test_case_r != `STATE_WRITE_DATA) begin
        @(posedge sclk_o);
      end

      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);

      dqs_outen_n_dqs_i[i] = {GEARING{1'b0}};
      dq_outen_n_i         = {GEARING{1'b0}};
      ce_out_i = 1'b1;

      for(c[i] = 0; c[i] < 128; c[i] =c[i]+1) begin
        @(posedge sclk_o);
        dqs_i[i] = ~dqs_i[i];
      end

      ce_out_i = 1'b0;

      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);

      test_case_done_r[i] = 1'b0;
    end
  end
endgenerate


// DQS Read Delay Adjustment Enable.
localparam DQS_RD_DEL_VALUE_MAGNITUDE = (DQS_RD_DEL_VALUE_INT == 0) ? 0 : 512 - DQS_RD_DEL_VALUE_INT; // 2's complement to get the magnitude
generate
    if (DQS_RD_DEL_SIGN == "COMPLEMENT") begin
        if (DQS_RD_DEL_VALUE_MAGNITUDE <= CLK_CODE && DQS_RD_DEL_VALUE_MAGNITUDE > 0) begin
            assign dqs_rd_del_value_dec_w = (CLK_CODE-DQS_RD_DEL_VALUE_MAGNITUDE);
        end
        else begin
            assign dqs_rd_del_value_dec_w = 0;
        end
    end
    else if (CLK_CODE+DQS_RD_DEL_VALUE_INT > 511) begin
      assign dqs_rd_del_value_dec_w = 511;
    end
    else begin
      assign dqs_rd_del_value_dec_w = (CLK_CODE+DQS_RD_DEL_VALUE_INT);
    end
endgenerate


// DQS Write Delay Adjustment Enable.
localparam DQS_WR_DEL_VALUE_MAGNITUDE = (DQS_WR_DEL_VALUE_INT == 0) ? 0 : 512 - DQS_WR_DEL_VALUE_INT; // 2's complement to get the magnitude
generate
    if (DQS_WR_DEL_SIGN == "COMPLEMENT") begin
        if ((DQS_WR_DEL_VALUE_MAGNITUDE <= CLK_CODE) && (DQS_WR_DEL_VALUE_MAGNITUDE > 0)) begin
            assign dqs_wr_del_value_dec_w = (CLK_CODE-DQS_WR_DEL_VALUE_MAGNITUDE);
        end
        else begin
            assign dqs_wr_del_value_dec_w = 0;
        end
    end
    else if (CLK_CODE+DQS_WR_DEL_VALUE_INT > 511) begin
      assign dqs_wr_del_value_dec_w = 511;
    end
    else begin
      assign dqs_wr_del_value_dec_w = (CLK_CODE+DQS_WR_DEL_VALUE_INT);
    end
endgenerate
// To achieve the total delay value need total_delay_value * sclk_o time.
assign total_delay_max_count = (dqs_rd_del_value_dec_w > dqs_wr_del_value_dec_w) ? dqs_rd_del_value_dec_w : dqs_wr_del_value_dec_w;
assign total_delay_done      = (total_delay_cntr_r > 2 * total_delay_max_count) ? 1'b1:1'b0;

always @(posedge sclk_o) begin
   if((rst_w == 1) || (ready_o == 0))begin
      total_delay_cntr_r <= 11'd0;
   end
   else if (ready_o==1'b1) begin
      if (total_delay_cntr_r < 2*(total_delay_max_count + 10)) begin // Extra 10 cycles. 2*2.5ns:
         total_delay_cntr_r <= total_delay_cntr_r + 11'd1;
      end
      else begin
         total_delay_cntr_r <= total_delay_cntr_r;
      end
   end
end
//

//Expected values calculation
//Expected DQS Read delay calculation
generate
  for(i=0; i<NUM_DQS_GROUP; i=i+1) begin
    always @ (posedge sclk_o, negedge sclk_o, negedge rst_w) begin
      if((rst_w == 1) || (ready_o_0_r == 0))begin
        exp_rd_dqs_dly_r[i] <= 0;
        rd_code_r[i]        <= dqs_rd_del_value_dec_w; //DQS_RD_DEL_VALUE_DEC;
        rd_code_r_0[i]      <= dqs_rd_del_value_dec_w; //DQS_RD_DEL_VALUE_DEC;
        rd_code_r_1[i]      <= dqs_rd_del_value_dec_w; //DQS_RD_DEL_VALUE_DEC;
        rd_code_r_2[i]      <= dqs_rd_del_value_dec_w; //DQS_RD_DEL_VALUE_DEC;
        rd_code_r_3[i]      <= dqs_rd_del_value_dec_w; //DQS_RD_DEL_VALUE_DEC;
        rd_code_r_4[i]      <= dqs_rd_del_value_dec_w; //DQS_RD_DEL_VALUE_DEC;
        rd_code_r_5[i]      <= dqs_rd_del_value_dec_w; //DQS_RD_DEL_VALUE_DEC;
        rd_cout_dqs_o_r[i]  <= rd_cout_dqs_o[i];
      end
      else begin
        rd_move_dqs_r[i] <= rd_move_dqs_i[i];

        if(rd_loadn_dqs_i[i] == 1'b0) begin
          exp_rd_dqs_dly_r[i] <= 0;
          rd_code_r[i] <= 0;
        end

        rd_code_r_0[i] <= rd_code_r[i];
        rd_code_r_1[i] <= rd_code_r_0[i];
        rd_code_r_2[i] <= rd_code_r_1[i];
        rd_code_r_3[i] <= rd_code_r_2[i];
        rd_code_r_4[i] <= rd_code_r_3[i];
        rd_code_r_5[i] <= rd_code_r_4[i];

//        if((rd_move_dqs_i[i] == 1'b0) && (rd_move_dqs_r[i] == 1'b1) && (rd_cout_dqs_o[i] != rd_cout_dqs_o_r[i])) begin
        if((rd_move_dqs_i[i] == 1'b0) && (rd_move_dqs_r[i] == 1'b1) && (rd_cout_dqs_o[i] == 0)) begin
          rd_cout_dqs_o_r[i] <= rd_cout_dqs_o[i];
          if(rd_dir_dqs_i[i] == 0) begin
            if(rd_code_r[i] < 512) begin
              rd_code_r[i] <= rd_code_r[i] + 1;
            end
          end
          else begin
            if(rd_code_r[i][i] > 0) begin
              rd_code_r[i] <= rd_code_r[i] - 1;
            end
          end
        end

        if((rd_code_r[i] == 0) || (rd_code_r[i] == 4) || (rd_code_r[i] == 8)) begin
          exp_rd_dqs_dly_r[i] <= 1500;
        end
        else if((rd_code_r[i] == 1) || (rd_code_r[i] == 5) || (rd_code_r[i] == 9)) begin
          exp_rd_dqs_dly_r[i] <= 1625;
        end
        else if((rd_code_r[i] == 2) || (rd_code_r[i] == 6) || (rd_code_r[i] == 10)) begin
          exp_rd_dqs_dly_r[i] <= 1750;
        end
        else if((rd_code_r[i] == 3) || (rd_code_r[i] == 7) || (rd_code_r[i] == 11)) begin
          exp_rd_dqs_dly_r[i] <= 1875;
        end
        else if((rd_code_r[i] > 11) && (rd_code_r[i] < 447)) begin
          exp_rd_dqs_dly_r[i] <= 500 + (rd_code_r[i]/4)*500 + rd_code_r[i][1:0]*125;
        end
       else if(rd_code_r[i] > 447)begin
         exp_rd_dqs_dly_r[i] <= 56000 + rd_code_r[i][1:0]*125;
       end

      end
    end
  end
endgenerate

//Write DQS delay logic
generate
  for(i=0;i<NUM_DQS_GROUP;i=i+1) begin
    initial begin
//      wr_loadn_dqs_i[i] = 1'b0;
      wr_move_dqs_i[i]  = 1'b0;
      wr_dir_dqs_i[i]   = 1'b0;

      while(test_case_r != `STATE_WRITE_DELAY) begin
        @(posedge sclk_o);
      end

      dqs_outen_n_dqs_i[i] = {GEARING{1'b0}};
      dq_outen_n_i         = {GEARING{1'b0}};

      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);

      ce_out_i = 1'b1;
      @(posedge sclk_o);
/*
      wr_loadn_dqs_i[i] = 1'b0;
      @(posedge sclk_o);
      wr_loadn_dqs_i[i] = 1'b1;
*/
      rd_i[i]              = 4'hF;
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);

      while ((wr_cout_dqs_o[i] == 1) && (wr_timeout_r[i] < 1024)) begin
        wr_move_dqs_i[i] = 1'b1;
        @(posedge sclk_o);
        @(posedge sclk_o);
        @(posedge sclk_o);
        @(posedge sclk_o);
        wr_move_dqs_i[i] = 1'b0;
        @(posedge sclk_o);
        @(posedge sclk_o);
        @(posedge sclk_o);
        @(posedge sclk_o);
        wr_timeout_r[i] = wr_timeout_r[i]+1;
      end

      for(b[i] = 0; b[i] < 511; b[i] = b[i]+1) begin
        wr_dir_dqs_i[i]  = 1'b0;
        wr_move_dqs_i[i] = 1'b1;
        @(posedge sclk_o);
        @(posedge sclk_o);
        @(posedge sclk_o);
        @(posedge sclk_o);
        @(posedge sclk_o);
        wr_move_dqs_i[i] = 1'b0;
        @(posedge sclk_o);
        @(posedge sclk_o);
        @(posedge sclk_o);
        @(posedge sclk_o);
        @(posedge sclk_o);
        @(posedge sclk_o);

        dqs_i[i] = {GEARING{1'b1}};
        @(posedge sclk_o);
        dqs_i[i] = {GEARING{1'b0}};
      end

      ce_out_i = 1'b0;
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);

      test_case_done_r[i] = 1'b0;
    end
  end
endgenerate

//Expected DQS Write delay calculation
generate
  for (i=0; i<NUM_DQS_GROUP; i=i+1) begin
    always @ (posedge sclk_o) begin
      if(rst_w == 1) begin
        wr_del_rdy_r[i] <= 1'b0;
        wrlvl_del_rdy_r[i] <= 1'b0;
      end
      else begin
        if(wr_move_dqs_i[i] == 1'b1) begin
          wr_del_rdy_r[i] <= 1'b0;
          wr_del_rdy_cnt_r[i] <= 0;
        end
        else begin
          if(wr_del_rdy_cnt_r[i] == 5) begin
            wr_del_rdy_r[i] <= 1'b1;
          end
          else begin
            wr_del_rdy_cnt_r[i] <= wr_del_rdy_cnt_r[i] + 1;
          end
        end

        if(wrlvl_move_dqs_i[i] == 1'b1) begin
          wrlvl_del_rdy_r[i] <= 1'b0;
          wrlvl_del_rdy_cnt_r[i] <= 0;
        end
        else begin
          if(wrlvl_del_rdy_cnt_r[i] == 5) begin
            wrlvl_del_rdy_r[i] <= 1'b1;
          end
          else begin
            wrlvl_del_rdy_cnt_r[i] <= wrlvl_del_rdy_cnt_r[i] + 1;
          end
        end
      end
    end
 end
endgenerate


generate
  for(i=0;i<NUM_DQS_GROUP;i=i+1) begin
    always @ (posedge sclk_o, negedge sclk_o, negedge rst_w) begin
      if((rst_w == 1)|| (ready_o_0_r == 0))begin
        exp_wr_dqs_dly_r[i] <= 0;
        wr_code_r[i]   <= (dqs_wr_del_value_dec_w);
        wr_code_r_0[i] <= (dqs_wr_del_value_dec_w);
        wr_code_r_1[i] <= (dqs_wr_del_value_dec_w);
        wr_code_r_2[i] <= (dqs_wr_del_value_dec_w);
        wr_code_r_3[i] <= (dqs_wr_del_value_dec_w);
        wr_code_r_4[i] <= (dqs_wr_del_value_dec_w);
        wr_code_r_5[i] <= (dqs_wr_del_value_dec_w);
        wr_code_r_6[i] <= (dqs_wr_del_value_dec_w);
        wr_cout_dqs_o_r[i] <= wr_cout_dqs_o[i];
      end
      else begin
        wr_move_dqs_r[i] <= wr_move_dqs_i[i];

        if(wr_loadn_dqs_i[i] == 1'b0) begin
          wr_code_r[i]   <= (dqs_wr_del_value_dec_w);
          wr_code_r_0[i] <= (dqs_wr_del_value_dec_w);
          wr_code_r_1[i] <= (dqs_wr_del_value_dec_w);
          wr_code_r_2[i] <= (dqs_wr_del_value_dec_w);
          wr_code_r_3[i] <= (dqs_wr_del_value_dec_w);
          wr_code_r_4[i] <= (dqs_wr_del_value_dec_w);
          wr_code_r_5[i] <= (dqs_wr_del_value_dec_w);
          wr_code_r_6[i] <= (dqs_wr_del_value_dec_w);
          exp_wr_dqs_dly_r[i] <= 0;
        end
        else begin
          wr_code_r_0[i] <= wr_code_r[i];
          wr_code_r_1[i] <= wr_code_r_0[i];
          wr_code_r_2[i] <= wr_code_r_1[i];
          wr_code_r_3[i] <= wr_code_r_2[i];
          wr_code_r_4[i] <= wr_code_r_3[i];
          wr_code_r_5[i] <= wr_code_r_4[i];
          wr_code_r_6[i] <= wr_code_r_5[i];

          if((wr_move_dqs_i[i] == 1'b0) && (wr_move_dqs_r[i] == 1'b1) && ((wr_cout_dqs_o[i] == 0) || (wr_cout_dqs_o_r[i] != wr_cout_dqs_o[i]))) begin
            wr_cout_dqs_o_r[i] <= wr_cout_dqs_o[i];
            if(wr_dir_dqs_i[i] == 0) begin
              if(wr_code_r[i] < 512) begin
                wr_code_r[i] <= wr_code_r[i] + 1;
              end
            end
            else begin
              if(wr_code_r[i] > 0) begin
                wr_code_r[i] <= wr_code_r[i] - 1;
              end
            end
          end

          if(GEARING == 2) begin
            if(INTERFACE_TYPE == "LPDDR2") begin
              if((wr_code_r_5[i] == 0) || (wr_code_r_5[i] == 4) || (wr_code_r_5[i] == 8)) begin
                exp_wr_dqs_dly_r[i] <= 1500 + dqswdelaybefore12_5pscell_r[i];
              end
              else if((wr_code_r_5[i] == 1) || (wr_code_r_5[i] == 5) || (wr_code_r_5[i] == 9)) begin
                exp_wr_dqs_dly_r[i] <= 1625 + dqswdelaybefore12_5pscell_r[i];
              end
              else if((wr_code_r_5[i] == 2) || (wr_code_r_5[i] == 6) || (wr_code_r_5[i] == 10)) begin
                exp_wr_dqs_dly_r[i] <= 1750 + dqswdelaybefore12_5pscell_r[i];
              end
              else if((wr_code_r_5[i] == 3) || (wr_code_r_5[i] == 7) || (wr_code_r_5[i] == 11)) begin
                exp_wr_dqs_dly_r[i] <= 1875 + dqswdelaybefore12_5pscell_r[i];
              end
              else if((wr_code_r_5[i] > 11) && (wr_code_r_5[i] < 448)) begin
                exp_wr_dqs_dly_r[i] <= dqswdelaybefore12_5pscell_r[i] + 500 + (wr_code_r_5[i]/4)*500 + wr_code_r_5[i][1:0]*125;
              end
              else if(wr_code_r_5[i] > 447)begin
                exp_wr_dqs_dly_r[i] <= dqswdelaybefore12_5pscell_r[i] + 56000 + wr_code_r_5[i][1:0]*125;
              end
            end
            else begin
              if((wr_code_r_0[i] == 0) || (wr_code_r_0[i] == 4) || (wr_code_r_0[i] == 8)) begin
              exp_wr_dqs_dly_r[i] <= 1500 + dqswdelaybefore12_5pscell_r[i];
              end
              else if((wr_code_r_0[i] == 1) || (wr_code_r_0[i] == 5) || (wr_code_r_0[i] == 9)) begin
                exp_wr_dqs_dly_r[i] <= 1625 + dqswdelaybefore12_5pscell_r[i];
              end
              else if((wr_code_r_0[i] == 2) || (wr_code_r_0[i] == 6) || (wr_code_r_0[i] == 10)) begin
                exp_wr_dqs_dly_r[i] <= 1750 + dqswdelaybefore12_5pscell_r[i];
              end
              else if((wr_code_r_0[i] == 3) || (wr_code_r_0[i] == 7) || (wr_code_r_0[i] == 11)) begin
                exp_wr_dqs_dly_r[i] <= 1875 + dqswdelaybefore12_5pscell_r[i];
              end
              else if((wr_code_r_0[i] > 11) && (wr_code_r_0[i] < 448)) begin
                exp_wr_dqs_dly_r[i] <= dqswdelaybefore12_5pscell_r[i] + 500 + (wr_code_r_0[i]/4)*500 + wr_code_r_0[i][1:0]*125;
              end
              else if(wr_code_r_0[i] > 447)begin
                exp_wr_dqs_dly_r[i] <= dqswdelaybefore12_5pscell_r[i] + 56000 + wr_code_r_0[i][1:0]*125;
              end
            end
          end
          else begin
            if((wr_code_r_0[i] == 0) || (wr_code_r_0[i] == 4) || (wr_code_r_0[i] == 8)) begin
              exp_wr_dqs_dly_r[i] <= 1500 + dqswdelaybefore12_5pscell_w[i];
            end
            else if((wr_code_r_0[i] == 1) || (wr_code_r_0[i] == 5) || (wr_code_r_0[i] == 9)) begin
              exp_wr_dqs_dly_r[i] <= 1625 + dqswdelaybefore12_5pscell_w[i];
            end
            else if((wr_code_r_0[i] == 2) || (wr_code_r_0[i] == 6) || (wr_code_r_0[i] == 10)) begin
              exp_wr_dqs_dly_r[i] <= 1750 + dqswdelaybefore12_5pscell_w[i];
            end
            else if((wr_code_r_0[i] == 3) || (wr_code_r_0[i] == 7) || (wr_code_r_0[i] == 11)) begin
              exp_wr_dqs_dly_r[i] <= 1875 + dqswdelaybefore12_5pscell_w[i];
            end
            else if((wr_code_r_0[i] > 11) && (wr_code_r_0[i] < 448)) begin
              exp_wr_dqs_dly_r[i] <= dqswdelaybefore12_5pscell_w[i] + 500 + (wr_code_r_0[i]/4)*500 + wr_code_r_0[i][1:0]*125;
            end
            else if(wr_code_r_0[i] > 447)begin
              exp_wr_dqs_dly_r[i] <= dqswdelaybefore12_5pscell_w[i] + 56000 + wr_code_r_0[i][1:0]*125;
            end
          end
        end
      end
    end
  end
endgenerate

//Write Leveling logic
generate
  for(i=0;i<NUM_DQS_GROUP;i=i+1) begin
    initial begin
//      wrlvl_loadn_dqs_i[i] = 1'b0;
      wrlvl_move_dqs_i[i]  = 1'b0;
      wrlvl_dir_dqs_i[i]   = 1'b0;

      while(test_case_r != `STATE_WRITE_LEVELING) begin
        @(posedge sclk_o);
      end

      dqs_outen_n_dqs_i[i] = {GEARING{1'b0}};
      dq_outen_n_i         = {GEARING{1'b0}};
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);

      ce_out_i = 1'b1;

      @(posedge sclk_o);
/*
      wrlvl_loadn_dqs_i[i] = 1'b0;
      @(posedge sclk_o);
      wrlvl_loadn_dqs_i[i] = 1'b1;
*/
      while ((wrlvl_cout_dqs_o[i] == 1) && (wrlvl_timeout_r[i] < 1024)) begin
        wrlvl_move_dqs_i[i] = 1'b1;
        @(posedge sclk_o);
        wrlvl_move_dqs_i[i] = 1'b0;
        @(posedge sclk_o);
        @(posedge sclk_o);
        @(posedge sclk_o);

        wrlvl_timeout_r[i] = wrlvl_timeout_r[i] + 1;
      end

      for(c[i] = 0; c[i] < 512; c[i] =c[i]+1) begin
        wrlvl_dir_dqs_i[i]  = 1'b0;
        wrlvl_move_dqs_i[i] = 1'b1;
        @(posedge sclk_o);
        wrlvl_move_dqs_i[i] = 1'b0;
        @(posedge sclk_o);
        @(posedge sclk_o);
        @(posedge sclk_o);
        @(posedge sclk_o);
        @(posedge sclk_o);
        @(posedge sclk_o);

        dqs_i[i] = {GEARING{1'b1}};
        @(posedge sclk_o);
        dqs_i[i] = {GEARING{1'b0}};
      end

      wrlvl_dir_dqs_i[i]  = 1'b1;
      @(posedge sclk_o);
      @(posedge sclk_o);

      for(c[i] = 0; c[i] < 500; c[i] =c[i]+1) begin
        wrlvl_move_dqs_i[i] = 1'b1;
        @(posedge sclk_o);
        wrlvl_move_dqs_i[i] = 1'b0;
        @(posedge sclk_o);
        @(posedge sclk_o);
        @(posedge sclk_o);
        @(posedge sclk_o);
        @(posedge sclk_o);
        @(posedge sclk_o);

        dqs_i[i] = {GEARING{1'b1}};
        @(posedge sclk_o);
        dqs_i[i] = {GEARING{1'b0}};
        if(wrlvl_cout_dqs_o[i] == 1)
          c[i] = 500;
      end

      ce_out_i = 1'b0;
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);
      @(posedge sclk_o);

      test_case_done_r[i] = 1'b0;
    end
  end
endgenerate

//Expected DQS Write leveling delay calculation
generate
  for(i=0;i<NUM_DQS_GROUP;i=i+1) begin
    always @ (posedge sclk_o, negedge sclk_o, negedge rst_w) begin
      if((rst_w == 1)|| (ready_o_0_r == 0))begin
        exp_wrlvl_dqs_dly_r[i] <= 0;
        wrlvl_code_r[i] <= 0;
        wrlvl_code_r_0[i] <= 0;
        wrlvl_code_r_1[i] <= 0;
        wrlvl_code_r_2[i] <= 0;
        wrlvl_code_r_3[i] <= 0;
        wrlvl_code_r_4[i] <= 0;
        wrlvl_code_r_5[i] <= 0;
        wrlvl_cout_dqs_o_r[i] <= wrlvl_cout_dqs_o[i];
      end
      else begin
        if(wrlvl_loadn_dqs_i[i] == 1'b0) begin
          wrlvl_code_r[i] <= 0;
          exp_wrlvl_dqs_dly_r[i] <= 0;
          wrlvl_code_r_0[i] <= 0;
          wrlvl_code_r_1[i] <= 0;
          wrlvl_code_r_2[i] <= 0;
          wrlvl_code_r_3[i] <= 0;
          wrlvl_code_r_4[i] <= 0;
          wrlvl_code_r_5[i] <= 0;
        end

        wrlvl_code_r_0[i] <= wrlvl_code_r[i];
        wrlvl_code_r_1[i] <= wrlvl_code_r_0[i];
        wrlvl_code_r_2[i] <= wrlvl_code_r_1[i];
        wrlvl_code_r_3[i] <= wrlvl_code_r_2[i];
        wrlvl_code_r_4[i] <= wrlvl_code_r_3[i];
        wrlvl_code_r_5[i] <= wrlvl_code_r_4[i];

        wrlvl_move_dqs_r[i] <= wrlvl_move_dqs_i[i];
        if((wrlvl_move_dqs_i[i] == 1'b0) && (wrlvl_move_dqs_r[i] == 1'b1) && ((wrlvl_cout_dqs_o[i] == 0) || (wrlvl_cout_dqs_o_r[i] != wrlvl_cout_dqs_o[i]))) begin
          wrlvl_cout_dqs_o_r[i] <= wrlvl_cout_dqs_o[i];
          if(wrlvl_dir_dqs_i[i] == 0) begin
            if(wrlvl_code_r[i] < 512) begin
              wrlvl_code_r[i] <= wrlvl_code_r[i] + 1;
            end
          end
          else begin
            if(wrlvl_code_r[i] > 0) begin
              wrlvl_code_r[i] <= wrlvl_code_r[i] - 1;
            end
          end
        end

        if((wrlvl_code_r[i] == 0) || (wrlvl_code_r[i] == 4) || (wrlvl_code_r[i] == 8)) begin
          exp_wrlvl_dqs_dly_r[i] <= 1500;
        end
        else if((wrlvl_code_r[i] == 1) || (wrlvl_code_r[i] == 5) || (wrlvl_code_r[i] == 9)) begin
          exp_wrlvl_dqs_dly_r[i] <= 1625;
        end
        else if((wrlvl_code_r[i] == 2) || (wrlvl_code_r[i] == 6) || (wrlvl_code_r[i] == 10)) begin
          exp_wrlvl_dqs_dly_r[i] <= 1750;
        end
        else if((wrlvl_code_r[i] == 3) || (wrlvl_code_r[i] == 7) || (wrlvl_code_r[i] == 11)) begin
          exp_wrlvl_dqs_dly_r[i] <= 1875;
        end
        else if((wrlvl_code_r[i] > 11) && (wrlvl_code_r[i] < 448)) begin
          exp_wrlvl_dqs_dly_r[i] <= 500 + (wrlvl_code_r[i]/4)*500 + wrlvl_code_r[i][1:0]*125;
        end
        else if(wrlvl_code_r[i] > 447)begin
          exp_wrlvl_dqs_dly_r[i] <= 56000 + wrlvl_code_r[i][1:0]*125;
        end

        dqswdelaybefore12_5pscell_r[i] <= dqswdelaybefore12_5pscell_w[i];
      end
    end
  end
endgenerate

//Expected DQS output calculation
generate
  for(i=0;i<NUM_DQS_GROUP;i=i+1) begin
    always @ (posedge ddr_clk_w, posedge rst_w) begin
      if((rst_w == 1)|| (ready_o_0_r == 0))begin
        dqs_i_r_0[i] <= 0;
        dqs_i_r_1[i] <= 0;
        dqs_i_r_2[i] <= 0;
      end
      else if(ce_out_i == 1) begin
        dqs_i_r_0[i] <= dqs_i[i];
        dqs_i_r_1[i] <= dqs_i_r_0[i];
        dqs_i_r_2[i] <= dqs_i_r_1[i];
      end
      else begin
        dqs_i_r_0[i] <= 0;
        dqs_i_r_1[i] <= dqs_i_r_0[i];
        dqs_i_r_2[i] <= dqs_i_r_1[i];
      end
    end
  end
endgenerate

generate
  for(i=0;i<NUM_DQS_GROUP;i=i+1) begin
    always @ (negedge ddr_clk_w, posedge ddr_clk_w, posedge rst_w) begin
      if((rst_w == 1)|| (ready_o_0_r == 0))begin
        exp_dqs_io_o_r[i] <= {GEARING{1'b0}};
        exp_dqs_io_o_0_r[i]  <= {GEARING{1'b0}};
        exp_dqs_io_o_1_r[i]  <= {GEARING{1'b0}};
        exp_dqs_io_o_2_r[i]  <= {GEARING{1'b0}};
        exp_dqs_io_o_3_r[i]  <= {GEARING{1'b0}};
        exp_dqs_io_o_4_r[i]  <= {GEARING{1'b0}};
        exp_dqs_io_o_5_r[i]  <= {GEARING{1'b0}};
        exp_dqs_io_o_6_r[i]  <= {GEARING{1'b0}};
        exp_dqs_io_o_7_r[i]  <= {GEARING{1'b0}};
        exp_dqs_io_o_8_r[i]  <= {GEARING{1'b0}};
        exp_dqs_io_o_9_r[i]  <= {GEARING{1'b0}};
        exp_dqs_io_o_10_r[i] <= {GEARING{1'b0}};
        exp_dqs_io_o_11_r[i] <= {GEARING{1'b0}};
        exp_dqs_io_o_12_r[i] <= {GEARING{1'b0}};

        dqs_counter_r[i]  <= 0;
      end
      else begin
        if(ddr_clk_w == 0) begin
          if(ce_out_i == 1) begin
            if(dqs_counter_r[i] == GEARING-1) begin
              dqs_counter_r[i] <= 0;
            end
            else begin
              dqs_counter_r[i] <= dqs_counter_r[i] + 1;
            end
            exp_dqs_io_o_r[i] <= dqs_i_r_1[i][dqs_counter_r[i]];
//            exp_dqs_io_o_r[i] <= dqs_i[i][dqs_counter_r[i]];
          end
        end
        else begin
          exp_dqs_io_o_r[i] <= 0;
        end

        if(GEARING == 2) begin
          exp_dqs_io_o_0_r[i]  <= exp_dqs_io_o_r[i];
          exp_dqs_io_o_1_r[i]  <= exp_dqs_io_o_0_r[i];
          exp_dqs_io_o_2_r[i]  <= exp_dqs_io_o_1_r[i];
          exp_dqs_io_o_3_r[i]  <= exp_dqs_io_o_2_r[i];
          exp_dqs_io_o_4_r[i]  <= exp_dqs_io_o_3_r[i];
          exp_dqs_io_o_5_r[i]  <= #(exp_wrlvl_dqs_dly_r[i]) exp_dqs_io_o_4_r[i];
          exp_dqs_io_o_6_r[i]  <= exp_dqs_io_o_5_r[i];
          exp_dqs_io_o_7_r[i]  <= exp_dqs_io_o_6_r[i];
          exp_dqs_io_o_8_r[i]  <= exp_dqs_io_o_7_r[i];
          exp_dqs_io_o_9_r[i]  <= exp_dqs_io_o_8_r[i];
          exp_dqs_io_o_10_r[i] <= exp_dqs_io_o_9_r[i];
          exp_dqs_io_o_11_r[i] <= exp_dqs_io_o_10_r[i];
          exp_dqs_io_o_12_r[i] <= exp_dqs_io_o_11_r[i];
        end
        else begin
          exp_dqs_io_o_0_r[i]  <= exp_dqs_io_o_r[i];
          exp_dqs_io_o_1_r[i]  <= exp_dqs_io_o_0_r[i];
          exp_dqs_io_o_2_r[i]  <= exp_dqs_io_o_1_r[i];
          exp_dqs_io_o_3_r[i]  <= exp_dqs_io_o_2_r[i];
          exp_dqs_io_o_4_r[i]  <= exp_dqs_io_o_3_r[i];
          exp_dqs_io_o_5_r[i]  <= exp_dqs_io_o_4_r[i];
          exp_dqs_io_o_6_r[i]  <= exp_dqs_io_o_5_r[i];
          exp_dqs_io_o_7_r[i]  <= exp_dqs_io_o_6_r[i];
          exp_dqs_io_o_8_r[i]  <= exp_dqs_io_o_7_r[i];
          exp_dqs_io_o_9_r[i]  <= exp_dqs_io_o_8_r[i];
          exp_dqs_io_o_10_r[i] <= exp_dqs_io_o_9_r[i];
          exp_dqs_io_o_11_r[i] <= #(exp_wrlvl_dqs_dly_r[i]) exp_dqs_io_o_10_r[i];
          exp_dqs_io_o_12_r[i] <= exp_dqs_io_o_11_r[i];
        end
      end
    end
  end
endgenerate



//Expected DQ output calculation
generate
  for(i=0;i<NUM_DQS_GROUP;i=i+1) begin
    always @ (posedge ddr_clk_w, negedge ddr_clk_w, posedge rst_w) begin
      if((rst_w == 1) || (ready_o_0_r == 0)) begin
        data_counter_r[i]    <= 1;
        exp_dq_dqs_io_o_r[i] <= 0;
        exp_dq_dqs_io_o_r_0[i] <= 0;
        exp_dq_dqs_io_o_r_1[i] <= 0;
        exp_dq_dqs_io_o_r_2[i] <= 0;
        exp_dq_dqs_io_o_r_3[i] <= 0;
        exp_dq_dqs_io_o_r_4[i] <= 0;
        exp_dq_dqs_io_o_r_5[i] <= 0;
        exp_dq_dqs_io_o_r_6[i] <= 0;
        exp_dq_dqs_io_o_r_7[i] <= 0;

        if(GEARING == 2) begin
          data_dqs_i[i] <= 32'h44332211;
        end
        else begin
          data_dqs_i[i] <= 64'h8877665544332211;
        end

        data_i_r_0[i] <= 0;
        data_i_r_1[i] <= 0;
        data_i_r_2[i] <= 0;
        data_i_r_3[i] <= 0;

        dq_outen_n_i_0_r <= {GEARING{1'b0}};
        dq_outen_n_i_1_r <= {GEARING{1'b0}};
        dq_outen_n_i_2_r <= {GEARING{1'b0}};
        dq_outen_n_i_3_r <= {GEARING{1'b0}};
        dq_outen_n_i_4_r <= {GEARING{1'b0}};
        dq_outen_n_i_5_r <= {GEARING{1'b0}};
        dq_outen_n_i_6_r <= {GEARING{1'b0}};
        dq_outen_n_i_7_r <= {GEARING{1'b0}};
        dq_outen_n_i_8_r <= {GEARING{1'b0}};
        dq_outen_n_i_9_r <= {GEARING{1'b0}};
        dq_outen_n_i_10_r<= {GEARING{1'b0}};
        dq_outen_n_i_11_r<= {GEARING{1'b0}};
        dq_outen_n_i_12_r<= {GEARING{1'b0}};
        dq_outen_n_i_13_r<= {GEARING{1'b0}};
        dq_outen_n_i_14_r<= {GEARING{1'b0}};
        dq_outen_n_i_15_r<= {GEARING{1'b0}};
        dq_outen_n_i_16_r<= {GEARING{1'b0}};
        dq_outen_n_i_17_r<= {GEARING{1'b0}};
        dq_outen_n_i_18_r<= {GEARING{1'b0}};


      end
      else begin
        if(GEARING == 2) begin
          exp_dq_dqs_io_o_r_0[i] <= exp_dq_dqs_io_o_r[i];
          exp_dq_dqs_io_o_r_1[i] <= exp_dq_dqs_io_o_r_0[i];
          exp_dq_dqs_io_o_r_2[i] <= exp_dq_dqs_io_o_r_1[i];
          exp_dq_dqs_io_o_r_3[i] <= exp_dq_dqs_io_o_r_2[i];
          exp_dq_dqs_io_o_r_4[i] <= #(exp_wr_dqs_dly_r[i] % SCLK_PERIOD) exp_dq_dqs_io_o_r_3[i];
        end
        else begin
          exp_dq_dqs_io_o_r_0[i] <= exp_dq_dqs_io_o_r[i];
          exp_dq_dqs_io_o_r_1[i] <= exp_dq_dqs_io_o_r_0[i];
          exp_dq_dqs_io_o_r_2[i] <= exp_dq_dqs_io_o_r_1[i];
          exp_dq_dqs_io_o_r_3[i] <= exp_dq_dqs_io_o_r_2[i];
          exp_dq_dqs_io_o_r_4[i] <= exp_dq_dqs_io_o_r_3[i];
          exp_dq_dqs_io_o_r_5[i] <= exp_dq_dqs_io_o_r_4[i];
          exp_dq_dqs_io_o_r_6[i] <= #(exp_wr_dqs_dly_r[i] % SCLK_PERIOD) exp_dq_dqs_io_o_r_5[i];
          exp_dq_dqs_io_o_r_7[i] <= exp_dq_dqs_io_o_r_6[i];
        end

        if(data_counter_r[i] == GEARING*2) begin
          data_counter_r[i] <= 1;


          if((ce_out_i == 1) && (dq_outen_n_i === 0)) begin
            data_dqs_i[i] <= data_dqs_i[i] + {GEARING*2{8'h11}};
          end
          else begin
            if(GEARING == 2) begin
              data_dqs_i[i] <= 32'h44332211;
            end
            else begin
              data_dqs_i[i] <= 64'h8877665544332211;
            end
          end

          data_i_r_0[i] <= data_dqs_i[i];
          data_i_r_1[i] <= data_i_r_0[i];
          data_i_r_2[i] <= data_i_r_1[i];
          data_i_r_3[i] <= data_i_r_2[i];

          dq_outen_n_i_0_r  <= dq_outen_n_i;
          dq_outen_n_i_1_r  <= dq_outen_n_i_0_r;
          dq_outen_n_i_2_r  <= dq_outen_n_i_1_r;
          dq_outen_n_i_3_r  <= dq_outen_n_i_2_r;
          dq_outen_n_i_4_r  <= dq_outen_n_i_3_r;
          dq_outen_n_i_5_r  <= dq_outen_n_i_4_r;
          dq_outen_n_i_6_r  <= dq_outen_n_i_5_r;
          dq_outen_n_i_7_r  <= dq_outen_n_i_6_r;
          dq_outen_n_i_8_r  <= dq_outen_n_i_7_r;
          dq_outen_n_i_9_r  <= dq_outen_n_i_8_r;
          dq_outen_n_i_10_r <= dq_outen_n_i_9_r;
          dq_outen_n_i_11_r <= dq_outen_n_i_10_r;
          dq_outen_n_i_12_r <= dq_outen_n_i_11_r;
          dq_outen_n_i_13_r <= dq_outen_n_i_12_r;
          dq_outen_n_i_14_r <= dq_outen_n_i_13_r;
          dq_outen_n_i_15_r <= dq_outen_n_i_14_r;
          dq_outen_n_i_16_r <= dq_outen_n_i_15_r;
          dq_outen_n_i_17_r <= dq_outen_n_i_16_r;
          dq_outen_n_i_18_r <= dq_outen_n_i_17_r;

        end
        else begin
          data_counter_r[i] <= data_counter_r[i] + 1;
        end

//        exp_dq_dqs_io_o_r[i] <= data_i_r_3[i][(data_counter_r[i]*8-1):((data_counter_r[i]-1)*8)];
        if(GEARING == 4) begin
          if(data_counter_r[i] == 1)
            exp_dq_dqs_io_o_r[i] <= data_dqs_i[i][7:0];
          if(data_counter_r[i] == 2)
            exp_dq_dqs_io_o_r[i] <= data_dqs_i[i][15:8];
          if(data_counter_r[i] == 3)
            exp_dq_dqs_io_o_r[i] <= data_dqs_i[i][23:16];
          if(data_counter_r[i] == 4)
            exp_dq_dqs_io_o_r[i] <= data_dqs_i[i][31:24];
          if(data_counter_r[i] == 5)
            exp_dq_dqs_io_o_r[i] <= data_dqs_i[i][39:32];
          if(data_counter_r[i] == 6)
            exp_dq_dqs_io_o_r[i] <= data_dqs_i[i][47:40];
          if(data_counter_r[i] == 7)
            exp_dq_dqs_io_o_r[i] <= data_dqs_i[i][55:48];
          if(data_counter_r[i] == 8)
            exp_dq_dqs_io_o_r[i] <= data_dqs_i[i][63:56];
        end
        else begin
          if(data_counter_r[i] == 1)
            exp_dq_dqs_io_o_r[i] <= data_dqs_i[i][7:0];
          if(data_counter_r[i] == 2)
            exp_dq_dqs_io_o_r[i] <= data_dqs_i[i][15:8];
          if(data_counter_r[i] == 3)
            exp_dq_dqs_io_o_r[i] <= data_dqs_i[i][23:16];
          if(data_counter_r[i] == 4)
            exp_dq_dqs_io_o_r[i] <= data_dqs_i[i][31:24];
        end
/*      for(k[i]=0; k[i] < 8; k[i]=k[i]+1) begin
          if(dq_outen_n_i[(data_counter_r[i]-1)/2] == 1'b0) begin
            exp_dq_dqs_io_o_r[i][k[i]] <= data_i_r_3[i][(k[i]*GEARING*2)+(GEARING*2-data_counter_r[i])];
          end
          else begin
            exp_dq_dqs_io_o_r[i][k[i]] <= 1'b0;
          end
        end     */
      end
    end
  end
endgenerate



//Expected data_o calculation
generate
  for(i=0;i<NUM_DQS_GROUP;i=i+1) begin
    always @ (posedge ddr_clk_w, negedge ddr_clk_w, posedge rst_w) begin
      if((rst_w == 1) || (ready_o_0_r == 0)) begin
        rx_data_counter_r[i]   <= 0;
        exp_data_delay_counter_r[i] <= 0;
        exp_data_dqs_o_r[i]   <= 0;
        exp_data_dqs_o_r_0[i] <= 0;
        exp_data_dqs_o_r_1[i] <= 0;
        exp_data_dqs_o_r_2[i] <= 0;
        exp_data_dqs_o_r_3[i] <= 0;
        exp_data_dqs_o_r_4[i] <= 0;
        exp_data_dqs_o_r_5[i] <= 0;
        exp_data_dqs_o_r_6[i] <= 0;
        exp_data_dqs_o_r_7[i] <= 0;
        exp_data_dqs_o_r_8[i] <= 0;
        exp_data_dqs_o_r_9[i] <= 0;

        dqs_io_i[i]           <= 0;
        dq_dqs_io_i[i]        <= 8'h01;

        dq_dqs_io_i_r[i]      <= 8'h01;
        dq_dqs_io_i_0_r[i]    <= 0;
        dq_dqs_io_i_1_r[i]    <= 0;
        dq_dqs_io_i_2_r[i]    <= 0;
        dq_dqs_io_i_3_r[i]    <= 0;
        dq_dqs_io_i_4_r[i]    <= 0;
        dq_dqs_io_i_5_r[i]    <= 0;
        dq_dqs_io_i_6_r[i]    <= 0;
        dq_dqs_io_i_7_r[i]    <= 0;
        dq_dqs_io_i_8_r[i]    <= 0;
        dq_dqs_io_i_9_r[i]    <= 0;
        dq_dqs_io_i_10_r[i]   <= 0;
        dq_dqs_io_i_11_r[i]   <= 0;
        dq_dqs_io_i_12_r[i]   <= 0;
        dq_dqs_io_i_13_r[i]   <= 0;
        dq_dqs_io_i_14_r[i]   <= 0;
        dq_dqs_io_i_15_r[i]   <= 0;
        dq_dqs_io_i_16_r[i]   <= 0;

      end
      else begin
      //DQS input generation
        if((dq_outen_n_i_10_r == {GEARING{1'b1}}) && (ce_in_i == 1)) begin
          dqs_io_i[i] <= ~dqs_io_i[i];

          if(exp_data_delay_counter_r[i] < 32)
            exp_data_delay_counter_r[i] <= exp_data_delay_counter_r[i]+1;

//          dq_dqs_io_i[i]      <= dq_dqs_io_i[i]+1;
          dq_dqs_io_i[i]      <= #(exp_rd_dqs_dly_r[i])(dq_dqs_io_i_r[i]+1); //Delay input data
          dq_dqs_io_i_r[i]    <= dq_dqs_io_i_r[i]+1;
          dq_dqs_io_i_0_r[i]  <= dq_dqs_io_i_r[i];
          dq_dqs_io_i_1_r[i]  <= dq_dqs_io_i_0_r[i];
          dq_dqs_io_i_2_r[i]  <= dq_dqs_io_i_1_r[i];
          dq_dqs_io_i_3_r[i]  <= dq_dqs_io_i_2_r[i];
          dq_dqs_io_i_4_r[i]  <= dq_dqs_io_i_3_r[i];
          dq_dqs_io_i_5_r[i]  <= dq_dqs_io_i_4_r[i];
          dq_dqs_io_i_6_r[i]  <= dq_dqs_io_i_5_r[i];
          dq_dqs_io_i_7_r[i]  <= dq_dqs_io_i_6_r[i];
          dq_dqs_io_i_8_r[i]  <= dq_dqs_io_i_7_r[i];
          dq_dqs_io_i_9_r[i]  <= dq_dqs_io_i_8_r[i];
          dq_dqs_io_i_10_r[i] <= dq_dqs_io_i_9_r[i];
          dq_dqs_io_i_11_r[i] <= dq_dqs_io_i_10_r[i];
          dq_dqs_io_i_12_r[i] <= dq_dqs_io_i_11_r[i];
          dq_dqs_io_i_13_r[i] <= dq_dqs_io_i_12_r[i];
          dq_dqs_io_i_14_r[i] <= dq_dqs_io_i_13_r[i];
          dq_dqs_io_i_15_r[i] <= dq_dqs_io_i_14_r[i];
          dq_dqs_io_i_16_r[i] <= dq_dqs_io_i_15_r[i];
        end
        else begin
          exp_data_delay_counter_r[i] <= 0;
          dqs_io_i[i] <= 0;
        end


        if(rx_data_counter_r[i] == (2*GEARING-1)) begin
          rx_data_counter_r[i]     <= 0;
        end
        else begin
          rx_data_counter_r[i] <= rx_data_counter_r[i] +1;
        end

        if(rx_data_counter_r[i] == 0) begin
          exp_data_dqs_o_r[i]   <= 0;
        end
        exp_data_dqs_o_r_1[i] <= exp_data_dqs_o_r_0[i];
        exp_data_dqs_o_r_2[i] <= exp_data_dqs_o_r_1[i];
        exp_data_dqs_o_r_3[i] <= exp_data_dqs_o_r_2[i];
        exp_data_dqs_o_r_4[i] <= exp_data_dqs_o_r_3[i];
        exp_data_dqs_o_r_5[i] <= exp_data_dqs_o_r_4[i];
        exp_data_dqs_o_r_6[i] <= exp_data_dqs_o_r_5[i];
        exp_data_dqs_o_r_7[i] <= exp_data_dqs_o_r_6[i];
        exp_data_dqs_o_r_8[i] <= exp_data_dqs_o_r_7[i];
        exp_data_dqs_o_r_9[i] <= exp_data_dqs_o_r_8[i];

        if(GEARING == 2) begin
          for(m = 0; m < 8; m=m+1) begin
            exp_data_dqs_o_r[i][((rx_data_counter_r[i]*8) + m)] <= dq_dqs_io_i_2_r[i][m];
          end
        end
        else begin
          for(m = 0; m < 8; m=m+1) begin
            exp_data_dqs_o_r[i][((rx_data_counter_r[i]*8) + m)] <= dq_dqs_io_i_5_r[i][m];
          end
        end
        if(rx_data_counter_r[i] == 0) begin
          exp_data_dqs_o_r_0[i] <= exp_data_dqs_o_r[i];
        end
      end
    end
  end
endgenerate


always @ (posedge sclk_o, posedge rst_w) begin
  if((rst_w == 1)|| (ready_o_0_r == 0))begin
    ce_out_i_0_r <= 0;
    ce_out_i_1_r <= 0;
    ce_out_i_2_r <= 0;
    ce_out_i_3_r <= 0;
  end
  else begin
    ce_out_i_0_r <= ce_out_i;
    ce_out_i_1_r <= ce_out_i_0_r;
    ce_out_i_2_r <= ce_out_i_1_r;
    ce_out_i_3_r <= ce_out_i_2_r;
  end
end

//Expected DM output calculation
generate
  if(DATA_MASK_ENABLE == 1) begin
    for(i=0;i<NUM_DQS_GROUP;i=i+1) begin
      always @ (posedge ddr_clk_w, negedge ddr_clk_w, posedge rst_w) begin
        if((rst_w == 1) || (ready_o_0_r == 0)) begin
          dm_counter_r[i] <= 0;
          exp_dm_o_r[i]   <= 0;
          exp_dm_o_0_r[i] <= 0;
          exp_dm_o_1_r[i] <= 0;
          exp_dm_o_2_r[i] <= 0;
          exp_dm_o_3_r[i] <= 0;
          exp_dm_o_4_r[i] <= 0;
          exp_dm_o_5_r[i] <= 0;
          exp_dm_o_6_r[i] <= 0;
          exp_dm_o_7_r[i] <= 0;
          exp_dm_o_8_r[i] <= 0;

          dm_i_r_0[i]    <= 0;
          dm_i_r_1[i]    <= 0;
          dm_i_r_2[i]    <= 0;
          dm_i_r_3[i]    <= 0;
          data_mask_i[i] <= {GEARING{2'b01}};
        end
        else begin

          if(GEARING == 2) begin
            exp_dm_o_0_r[i] <= exp_dm_o_r[i];
            exp_dm_o_1_r[i] <= exp_dm_o_0_r[i];
            exp_dm_o_2_r[i] <= exp_dm_o_1_r[i];
            exp_dm_o_3_r[i] <= exp_dm_o_2_r[i];
            exp_dm_o_4_r[i] <= #(exp_wr_dqs_dly_r[i] % SCLK_PERIOD) exp_dm_o_3_r[i];
          end
          else begin
            exp_dm_o_0_r[i] <= exp_dm_o_r[i];
            exp_dm_o_1_r[i] <= exp_dm_o_0_r[i];
            exp_dm_o_2_r[i] <= exp_dm_o_1_r[i];
            exp_dm_o_3_r[i] <= exp_dm_o_2_r[i];
            exp_dm_o_4_r[i] <= exp_dm_o_3_r[i];
            exp_dm_o_5_r[i] <= exp_dm_o_4_r[i];
            exp_dm_o_6_r[i] <= #(exp_wr_dqs_dly_r[i] % SCLK_PERIOD) exp_dm_o_5_r[i];
            exp_dm_o_7_r[i] <= exp_dm_o_6_r[i];
            exp_dm_o_8_r[i] <= exp_dm_o_7_r[i];
          end

          if(dm_counter_r[i] < GEARING*2-1) begin
            dm_counter_r[i] <= dm_counter_r[i] + 1;
          end
          else begin
            dm_counter_r[i] <= 0;

            if(ce_out_i == 1) begin
              data_mask_i[i] <= ~data_mask_i[i];
              dm_i_r_0[i]    <= data_mask_i[i];
            end

            dm_i_r_1[i] <= dm_i_r_0[i];
            dm_i_r_2[i] <= dm_i_r_1[i];
            dm_i_r_3[i] <= dm_i_r_2[i];
          end

//          exp_dm_o_r[i] <= dm_i_r_0[i][dm_counter_r[i]];
          exp_dm_o_r[i] <= data_mask_i[i][dm_counter_r[i]];
        end
      end
    end
  end
endgenerate


//Expected CMD output calculation
reg [9:0] phase_shif_r    = 8'd1250;
generate
  if(CLK_ADDR_CMD_ENABLE == 1) begin
  // After this time the 270 phase shift should be done between ck_o and ca_o.
    always @ (posedge sclk_o, negedge sclk_o, posedge rst_w) begin
      if((rst_w == 1)|| (ready_o_0_r == 0))begin
        phase_shif_r <= 9'd1250;
     end
     else begin
      if (phase_shif_r > 0) begin
        phase_shif_r    <= phase_shif_r - 9'd1;
       end
     end
    end
    //
    always @ (posedge ck_o, negedge ck_o, posedge rst_w) begin
      if((rst_w == 1) || (ready_o_0_r == 0) || (phase_shif_r != 8'd0))begin
        exp_ca_o_r   <= 0;
        exp_ca_o_0_r <= 0;
        exp_ca_o_1_r <= 0;
        exp_ca_o_2_r <= 0;
        exp_ca_o_3_r <= 0;
        exp_ca_o_4_r <= 0;
        exp_ca_o_5_r <= 0;
        exp_ca_o_6_r <= 0;
        exp_ca_o_7_r <= 0;
        ca_counter_r <= 1;
        ca_i         <= 0;
        ca_i_r_0     <= 0;
        ca_i_r_1     <= 0;
        ca_i_r_2     <= 0;
      end
      else begin

        if(ca_counter_r == GEARING*2) begin
          ca_counter_r <= 1;
          ca_i     <= ~ca_i;
          ca_i_r_0 <= ca_i;
          ca_i_r_1 <= ca_i_r_0;
          ca_i_r_2 <= ca_i_r_1;
        end
        else begin
          ca_counter_r <= ca_counter_r + 1;
        end

        exp_ca_o_0_r <= exp_ca_o_r;
        exp_ca_o_1_r <= exp_ca_o_0_r;
        exp_ca_o_2_r <= exp_ca_o_1_r;
        exp_ca_o_3_r <= exp_ca_o_2_r;
        exp_ca_o_4_r <= exp_ca_o_3_r;
        exp_ca_o_5_r <= exp_ca_o_4_r;
        exp_ca_o_6_r <= exp_ca_o_5_r;
        exp_ca_o_7_r <= exp_ca_o_6_r;

        for(x=0; x<10; x=x+1) begin
          exp_ca_o_r[x] <= ca_i[(x*(GEARING*2) + (ca_counter_r-1))];
        end
      end
    end
  end
endgenerate

//Expected CSN output calculation
generate
  if(CLK_ADDR_CMD_ENABLE == 1) begin
    for(i=0; i<NUM_CS; i=i+1) begin
      always @ (negedge ck_o, posedge rst_w) begin
        if((rst_w == 1)|| (ready_o_0_r == 0))begin
          exp_csn_o_r[i]   <= {GEARING{1'b0}};
          exp_csn_o_0_r[i] <= {GEARING{1'b0}};
          exp_csn_o_1_r[i] <= {GEARING{1'b0}};
          exp_csn_o_2_r[i] <= {GEARING{1'b0}};
          exp_csn_o_3_r[i] <= {GEARING{1'b0}};
          csn_counter_r[i] <= 1;

          csn_i[i]     <= {GEARING{1'b0}};
          csn_i_r_0[i] <= 0;
          csn_i_r_1[i] <= 0;
          csn_i_r_2[i] <= 0;
          csn_i_r_3[i] <= 0;
        end
        else begin
          exp_csn_o_0_r[i] <= exp_csn_o_r[i];
          exp_csn_o_1_r[i] <= exp_csn_o_0_r[i];
          exp_csn_o_2_r[i] <= exp_csn_o_1_r[i];
          exp_csn_o_3_r[i] <= exp_csn_o_2_r[i];
          if(csn_counter_r[i] == GEARING) begin
            csn_counter_r[i] <= 1;

            csn_i[i] <= ~csn_i[i];
            csn_i_r_0[i] <= csn_i[i];
            csn_i_r_1[i] <= csn_i_r_0[i];
            csn_i_r_2[i] <= csn_i_r_1[i];
            csn_i_r_3[i] <= csn_i_r_2[i];
          end
          else begin
            csn_counter_r[i] <= csn_counter_r[i] + 1;
          end

          exp_csn_o_r[i] <= csn_i_r_0[i][(csn_counter_r[i]-1)];
        end
      end
    end
  end
endgenerate

//Expected Address output calculation
generate
  if(CLK_ADDR_CMD_ENABLE == 1) begin
    always @ (posedge sclk_o, negedge sclk_o, posedge rst_w) begin
      if((rst_w == 1)|| (ready_o_0_r == 0))begin
        exp_addr_o_0_r <= 0;
        exp_addr_o_r   <= 0;
        addr_counter_r <= 1;

        addr_i     <= 0;
        addr_i_r_0 <= 0;
        addr_i_r_1 <= 0;
        addr_i_r_2 <= 0;
      end
      else begin
        exp_addr_o_0_r <= exp_addr_o_r;
        exp_addr_o_1_r <= exp_addr_o_0_r;

        if(addr_counter_r == 2) begin
          addr_counter_r <= 1;

          addr_i     <= addr_i+13;
          addr_i_r_0 <= addr_i;
          addr_i_r_1 <= addr_i_r_0;
          addr_i_r_2 <= addr_i_r_1;
        end
        else begin
          addr_counter_r <= addr_counter_r + 1;
        end
  //      exp_addr_o_r <= addr_i_r_2[((2+1)-addr_counter_r)*ADDR_WIDTH-1 : (2 - addr_counter_r)*ADDR_WIDTH];
        if(addr_counter_r == 1)
          exp_addr_o_r <= addr_i_r_1[ADDR_WIDTH-1 : 0];
        if(addr_counter_r == 2)
          exp_addr_o_r <= addr_i_r_1[2*ADDR_WIDTH-1 : ADDR_WIDTH];
      end
    end
  end
endgenerate

//Expected BA output calculation
generate
  if(CLK_ADDR_CMD_ENABLE == 1) begin
    always @ (posedge sclk_o, negedge sclk_o, posedge rst_w) begin
      if((rst_w == 1)|| (ready_o_0_r == 0))begin
        exp_ba_o_r   <= 0;
        exp_ba_o_0_r <= 0;
        exp_ba_o_1_r <= 0;
        ba_counter_r <= 1;

        ba_i     <= 0;
        ba_i_r_0 <= 0;
        ba_i_r_1 <= 0;
        ba_i_r_2 <= 0;
      end
      else begin
        exp_ba_o_0_r <= exp_ba_o_r;
        exp_ba_o_1_r <= exp_ba_o_0_r;

        if(ba_counter_r == 2) begin
          ba_counter_r <= 1;

          ba_i     <= ba_i+1;
          ba_i_r_0 <= ba_i;
          ba_i_r_1 <= ba_i_r_0;
          ba_i_r_2 <= ba_i_r_1;
        end
        else begin
          ba_counter_r <= ba_counter_r + 1;
        end

  //      exp_ba_o_r <= ba_i_r_2[((2+1)-ba_counter_r)*BA_WIDTH-1 : (2 - ba_counter_r)*BA_WIDTH];
        if(ba_counter_r == 1)
          exp_ba_o_r <= ba_i_r_1[BA_WIDTH-1 : 0];
        if(ba_counter_r == 2)
          exp_ba_o_r <= ba_i_r_1[2*BA_WIDTH-1 : BA_WIDTH];
      end
    end
  end
endgenerate


//Expected CAS output calculation
generate
  if(CLK_ADDR_CMD_ENABLE == 1) begin
    always @ (posedge sclk_o, negedge sclk_o, posedge rst_w) begin
      if((rst_w == 1)|| (ready_o_0_r == 0))begin
        exp_casn_o_r   <= 0;
        exp_casn_o_0_r <= 0;
        exp_casn_o_1_r <= 0;
        cas_counter_r  <= 1;

        casn_i     <= 0;
        casn_i_r_0 <= 0;
        casn_i_r_1 <= 0;
        casn_i_r_2 <= 0;
      end
      else begin
        exp_casn_o_0_r <= exp_casn_o_r;
        exp_casn_o_1_r <= exp_casn_o_0_r;
        if(cas_counter_r == 2) begin
          cas_counter_r <= 1;
          casn_i        <= ~casn_i;
          casn_i_r_0    <= casn_i;
          casn_i_r_1    <= casn_i_r_0;
          casn_i_r_2    <= casn_i_r_1;
        end
        else begin
          cas_counter_r <= cas_counter_r + 1;
        end
        if(cas_counter_r == 1)
          exp_casn_o_r <= casn_i_r_1[0];
        if(cas_counter_r == 2)
          exp_casn_o_r <= casn_i_r_1[1];
      end
    end
  end
endgenerate


//Expected RAS output calculation
generate
  if(CLK_ADDR_CMD_ENABLE == 1) begin
    always @ (posedge sclk_o, negedge sclk_o, posedge rst_w) begin
      if((rst_w == 1)|| (ready_o_0_r == 0))begin
        exp_rasn_o_r   <= 0;
        exp_rasn_o_0_r <= 0;
        exp_rasn_o_1_r <= 0;
        ras_counter_r  <= 1;

        rasn_i     <= 0;
        rasn_i_r_0 <= 0;
        rasn_i_r_1 <= 0;
        rasn_i_r_2 <= 0;
      end
      else begin
        exp_rasn_o_0_r <= exp_rasn_o_r;
        exp_rasn_o_1_r <= exp_rasn_o_0_r;
        if(ras_counter_r == 2) begin
          ras_counter_r <= 1;

          rasn_i     <= ~rasn_i;
          rasn_i_r_0 <= rasn_i;
          rasn_i_r_1 <= rasn_i_r_0;
          rasn_i_r_2 <= rasn_i_r_1;
        end
        else begin
          ras_counter_r <= ras_counter_r + 1;
        end

        if(ras_counter_r == 1)
          exp_rasn_o_r <= rasn_i_r_1[0];
        if(ras_counter_r == 2)
          exp_rasn_o_r <= rasn_i_r_1[1];
      end
    end
  end
endgenerate


//Expected WEN output calculation
generate
  if(CLK_ADDR_CMD_ENABLE == 1) begin
    always @ (posedge sclk_o, negedge sclk_o, posedge rst_w) begin
      if((rst_w == 1)|| (ready_o_0_r == 0))begin
        exp_wen_o_r   <= 0;
        exp_wen_o_0_r <= 0;
        exp_wen_o_1_r <= 0;
        wen_counter_r <= 1;

        wen_i     <= 0;
        wen_i_r_0 <= 0;
        wen_i_r_1 <= 0;
        wen_i_r_2 <= 0;
      end
      else begin
        exp_wen_o_0_r <= exp_wen_o_r;
        exp_wen_o_1_r <= exp_wen_o_0_r;
        if(wen_counter_r == 2) begin
          wen_counter_r <= 1;
          wen_i     <= ~wen_i;
          wen_i_r_0 <= wen_i;
          wen_i_r_1 <= wen_i_r_0;
          wen_i_r_2 <= wen_i_r_1;
        end
        else begin
          wen_counter_r <= wen_counter_r + 1;
        end
        if(wen_counter_r == 1)
          exp_wen_o_r <= wen_i_r_1[0];
        if(wen_counter_r == 2)
          exp_wen_o_r <= wen_i_r_1[1];
      end
    end
  end
endgenerate

//Expected ODT output calculation
generate
  if((CLK_ADDR_CMD_ENABLE == 1)&&(INTERFACE_TYPE == "LPDDR3")) begin
    always @ (negedge ck_o, posedge rst_w) begin
      if((rst_w == 1)|| (ready_o_0_r == 0))begin
        odt_i     <= 0;
        odt_i_r_0 <= 0;
        odt_i_r_1 <= 0;
        odt_i_r_2 <= 0;
        exp_odt_o_r   <= {NUM_CS{1'b0}};
        exp_odt_o_0_r <= {NUM_CS{1'b0}};
        exp_odt_o_1_r <= {NUM_CS{1'b0}};
        exp_odt_o_2_r <= {NUM_CS{1'b0}};
        exp_odt_o_3_r <= {NUM_CS{1'b0}};
        exp_odt_o_4_r <= {NUM_CS{1'b0}};
        exp_odt_o_5_r <= {NUM_CS{1'b0}};
        exp_odt_o_6_r <= {NUM_CS{1'b0}};
        exp_odt_o_7_r <= {NUM_CS{1'b0}};
        odt_counter_r <= 1;
      end
      else begin
        exp_odt_o_0_r <= exp_odt_o_r;
        exp_odt_o_1_r <= exp_odt_o_0_r;
        exp_odt_o_2_r <= exp_odt_o_1_r;
        exp_odt_o_3_r <= exp_odt_o_2_r;
        exp_odt_o_4_r <= exp_odt_o_3_r;
        exp_odt_o_5_r <= exp_odt_o_4_r;
        exp_odt_o_6_r <= exp_odt_o_5_r;
        exp_odt_o_7_r <= exp_odt_o_6_r;

        if(odt_counter_r == GEARING) begin
          odt_counter_r <= 1;
          odt_i     <= ~odt_i;
          odt_i_r_0 <= odt_i;
          odt_i_r_1 <= odt_i_r_0;
          odt_i_r_2 <= odt_i_r_1;
        end
        else begin
          odt_counter_r <= odt_counter_r + 1;
        end

        if(odt_counter_r == 1)
          exp_odt_o_r <= odt_i[NUM_CS-1 : 0];
        if(odt_counter_r == 2)
          exp_odt_o_r <= odt_i[2*NUM_CS-1 : NUM_CS];
        if(odt_counter_r == 3)
          exp_odt_o_r <= odt_i[3*NUM_CS-1 : 2*NUM_CS];
        if(odt_counter_r == 4)
          exp_odt_o_r <= odt_i[4*NUM_CS-1 : 3*NUM_CS];
      end
    end
  end
  else if((CLK_ADDR_CMD_ENABLE == 1)&&((INTERFACE_TYPE == "DDR3")||(INTERFACE_TYPE == "DDR3L"))) begin
    always @ (negedge sclk_o, posedge sclk_o, posedge rst_w) begin
      if((rst_w == 1)|| (ready_o_0_r == 0))begin
        odt_i     <= 0;
        odt_i_r_0 <= 0;
        odt_i_r_1 <= 0;
        odt_i_r_2 <= 0;
        exp_odt_o_r   <= {NUM_CS{1'b0}};
        exp_odt_o_0_r <= {NUM_CS{1'b0}};
        exp_odt_o_1_r <= {NUM_CS{1'b0}};
        exp_odt_o_2_r <= {NUM_CS{1'b0}};
        exp_odt_o_3_r <= {NUM_CS{1'b0}};
        exp_odt_o_4_r <= {NUM_CS{1'b0}};
        exp_odt_o_5_r <= {NUM_CS{1'b0}};
        exp_odt_o_6_r <= {NUM_CS{1'b0}};
        exp_odt_o_7_r <= {NUM_CS{1'b0}};
        odt_counter_r <= 1;
      end
      else begin
        exp_odt_o_0_r <= exp_odt_o_r;
        exp_odt_o_1_r <= exp_odt_o_0_r;
        exp_odt_o_2_r <= exp_odt_o_1_r;
        if(odt_counter_r == 2) begin
          odt_counter_r <= 1;
          odt_i         <= ~odt_i;
          odt_i_r_0     <= odt_i;
          odt_i_r_1     <= odt_i_r_0;
          odt_i_r_2     <= odt_i_r_1;
        end
        else begin
          odt_counter_r <= odt_counter_r + 1;
        end

        if(odt_counter_r == 1)
          exp_odt_o_r <= odt_i_r_0[NUM_CS-1 : 0];
        if(odt_counter_r == 2)
          exp_odt_o_r <= odt_i_r_0[2*NUM_CS-1 : NUM_CS];
      end
    end
  end
endgenerate

//Expected CKE output calculation
generate
  if((CLK_ADDR_CMD_ENABLE == 1) && ((INTERFACE_TYPE == "LPDDR3")||(INTERFACE_TYPE == "LPDDR2"))) begin
    always @ (negedge ck_o, posedge ck_o, posedge rst_w) begin
      if((rst_w == 1)|| (ready_o_0_r == 0))begin
        exp_cke_o_r   <= {NUM_CS{1'b1}};
        exp_cke_o_0_r <= {NUM_CS{1'b1}};
        exp_cke_o_1_r <= {NUM_CS{1'b1}};
        exp_cke_o_2_r <= {NUM_CS{1'b1}};
        exp_cke_o_3_r <= {NUM_CS{1'b1}};
        exp_cke_o_4_r <= {NUM_CS{1'b1}};
        exp_cke_o_5_r <= {NUM_CS{1'b1}};
        exp_cke_o_6_r <= {NUM_CS{1'b1}};
        exp_cke_o_7_r <= {NUM_CS{1'b1}};
        cke_counter_r <= 1;
        cke_i     <= 0;
        cke_i_r_0 <= 0;
        cke_i_r_1 <= 0;
        cke_i_r_2 <= 0;
      end
      else begin
        exp_cke_o_0_r <= exp_cke_o_r;
        exp_cke_o_1_r <= exp_cke_o_0_r;
        exp_cke_o_2_r <= exp_cke_o_1_r;
        exp_cke_o_3_r <= exp_cke_o_2_r;
        exp_cke_o_4_r <= exp_cke_o_3_r;
        exp_cke_o_5_r <= exp_cke_o_4_r;
        exp_cke_o_6_r <= exp_cke_o_5_r;
        exp_cke_o_7_r <= exp_cke_o_6_r;

        if(cke_counter_r == GEARING*2) begin
          cke_counter_r <= 1;
          cke_i     <= ~cke_i;
          cke_i_r_0 <= cke_i;
          cke_i_r_1 <= cke_i_r_0;
          cke_i_r_2 <= cke_i_r_1;
        end
        else begin
          cke_counter_r <= cke_counter_r + 1;
        end

        if(cke_counter_r == 2)
          exp_cke_o_r <= cke_i[NUM_CS-1 : 0];
        if(cke_counter_r == 4)
          exp_cke_o_r <= cke_i[2*NUM_CS-1 : NUM_CS];
        if(cke_counter_r == 6)
          exp_cke_o_r <= cke_i[3*NUM_CS-1 : 2*NUM_CS];
        if(cke_counter_r == 8)
          exp_cke_o_r <= cke_i[4*NUM_CS-1 : 3*NUM_CS];
      end
    end
  end
  else if(((INTERFACE_TYPE == "DDR3")||(INTERFACE_TYPE == "DDR3L")) && (CLK_ADDR_CMD_ENABLE == 1)) begin
    always @ (negedge sclk_o, posedge sclk_o, posedge rst_w) begin
      if((rst_w == 1)|| (ready_o_0_r == 0))begin
        exp_cke_o_r   <= {NUM_CS{1'b1}};
        exp_cke_o_0_r <= {NUM_CS{1'b1}};
        exp_cke_o_1_r <= {NUM_CS{1'b1}};
        exp_cke_o_2_r <= {NUM_CS{1'b1}};
        exp_cke_o_3_r <= {NUM_CS{1'b1}};
        exp_cke_o_4_r <= {NUM_CS{1'b1}};
        exp_cke_o_5_r <= {NUM_CS{1'b1}};
        exp_cke_o_6_r <= {NUM_CS{1'b1}};
        exp_cke_o_7_r <= {NUM_CS{1'b1}};
        cke_counter_r <= 1;
        cke_i     <= 0;
        cke_i_r_0 <= 0;
        cke_i_r_1 <= 0;
        cke_i_r_2 <= 0;
      end
      else begin
        exp_cke_o_0_r <= exp_cke_o_r;
        exp_cke_o_1_r <= exp_cke_o_0_r;
        exp_cke_o_2_r <= exp_cke_o_1_r;
        exp_cke_o_3_r <= exp_cke_o_2_r;
        if(cke_counter_r == 2) begin
          cke_counter_r <= 1;
          cke_i         <= ~cke_i;
          cke_i_r_0     <= cke_i;
          cke_i_r_1     <= cke_i_r_0;
          cke_i_r_2     <= cke_i_r_1;
        end
        else begin
          cke_counter_r <= cke_counter_r + 1;
        end

        if(cke_counter_r == 1)
          exp_cke_o_r <= cke_i_r_0[NUM_CS-1 : 0];
        if(cke_counter_r == 2)
          exp_cke_o_r <= cke_i_r_0[2*NUM_CS-1 : NUM_CS];
      end
    end
  end

endgenerate

endmodule
