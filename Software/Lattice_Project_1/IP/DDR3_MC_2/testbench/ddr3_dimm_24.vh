// =============================================================================
//                           COPYRIGHT NOTICE
// Copyright 2000-2001 (c) Lattice Semiconductor Corporation
// ALL RIGHTS RESERVED
// This confidential and proprietary software may be used only as authorised by
// a licensing agreement from Lattice Semiconductor Corporation.
// The entire notice above must be reproduced on all authorized copies and
// copies may only be made to the extent permitted by a licensing agreement from
// Lattice Semiconductor Corporation.
//
// Lattice Semiconductor Corporation        TEL : 1-800-Lattice (USA and Canada)
// 5555 NE Moore Court                            408-826-6000 (other locations)
// Hillsboro, OR 97124                     web  : http://www.latticesemi.com/
// U.S.A                                   email: techsupport@latticesemi.com
// =============================================================================/
//                        FILE DETAILS
// Project          : DDR3 SDRAM Controller
// File             : ddr3_dimm_24.v
// Title            : DDR3 memory DIMM model
// Dependencies     : ddr_sdram_mem_params.v, ddr3_parameters.vh
// Description      : 
// =============================================================================

`timescale 1ps / 1ps
`include "ddr3_sdram_mem_params.vh"
module ddr3_dimm_24 (
    rst_n,
    ddr_clk,
    ddr_clk_n,
    ddr_cke,
    ddr_cs_n, 
    ddr_ras_n,
    ddr_cas_n,
    ddr_we_n,
    ddr_dm_tdqs,
    ddr_ba,
    ddr_ad,
    ddr_odt,
    ddr_dqs,
    ddr_dqs_n,
    ddr_dq
);

`include "ddr3_parameters.vh"

    input                    rst_n;
`ifdef DUAL_RANK
    input  [1:0]             ddr_clk;
    input  [1:0]             ddr_clk_n;
    input  [1:0]             ddr_cke;
    input  [1:0]             ddr_cs_n;
    input  [1:0]             ddr_odt;
`else
    input                    ddr_clk;
    input                    ddr_clk_n;
    input                    ddr_cke;
    input                    ddr_cs_n;
    input                    ddr_odt;
`endif
    input                    ddr_ras_n;
    input                    ddr_cas_n;
    input                    ddr_we_n;
    input  [`BANK_WIDTH-1:0] ddr_ba;
    input  [`ROW_WIDTH-1:0]  ddr_ad;
    inout  [`DQS_WIDTH-1:0]  ddr_dqs;
    inout  [`DQS_WIDTH-1:0]  ddr_dqs_n;
    inout  [`DATA_WIDTH-1:0] ddr_dq;
    inout  [`DQS_WIDTH-1:0]     ddr_dm_tdqs;



`ifdef DUAL_RANK
    initial if (DEBUG) $display("%m: Dual Rank");
`else
    initial if (DEBUG) $display("%m: Single Rank");
`endif

`ifdef RDIMM
   `define RD_IN_DELAY 500

    initial if (DEBUG) $display("%m: Registered DIMM");
    wire [1:0]             rck    = {2{ddr_clk[0]}};
    wire [1:0]             rck_n  = {2{ddr_clk_n[0]}};
    reg  [1:0]             rcke   ;
    reg  [1:0]             rs_n   ;
    reg                    rras_n ;
    reg                    rcas_n ;
    reg                    rwe_n  ;
    reg  [`BANK_WIDTH-1:0] rba    ;
    reg  [15:0]            raddr  ;
    reg  [1:0]             rodt   ;

    always @(negedge reset_n or posedge ck[0]) begin
        if (!rst_n) begin
            rcke   <= #(`RD_IN_DELAY) 0;   
            rs_n   <= #(`RD_IN_DELAY) 0;   
            rras_n <= #(`RD_IN_DELAY) 0;
            rcas_n <= #(`RD_IN_DELAY) 0;   
            rwe_n  <= #(`RD_IN_DELAY) 0;
            rba    <= #(`RD_IN_DELAY) 0;   
            raddr  <= #(`RD_IN_DELAY) 0;   
            rodt   <= #(`RD_IN_DELAY) 0;
         end else begin
            rcke   <= #(`RD_IN_DELAY) ddr_cke;   
            rs_n   <= #(`RD_IN_DELAY) ddr_cs_n;
            rras_n <= #(`RD_IN_DELAY) ddr_ras_n;   
            rcas_n <= #(`RD_IN_DELAY) ddr_cas_n;   
            rwe_n  <= #(`RD_IN_DELAY) ddr_we_n;
            rba    <= #(`RD_IN_DELAY) ddr_ba;   
            raddr  <= #(`RD_IN_DELAY) ddr_ad;   
            rodt   <= #(`RD_IN_DELAY) ddr_odt ;
        end
    end
`else
    initial if (DEBUG) $display("%m: Unbuffered DIMM");
    wire             [1:0] rck    = ddr_clk;
    wire             [1:0] rck_n  = ddr_clk_n ;
    wire             [1:0] rcke   = ddr_cke;
    wire             [1:0] rs_n   = ddr_cs_n;
    wire                   rras_n = ddr_ras_n;
    wire                   rcas_n = ddr_cas_n;
    wire                   rwe_n  = ddr_we_n;
    wire             [2:0] rba    = ddr_ba;
    wire            [15:0] raddr  = ddr_ad;
    wire             [1:0] rodt   = ddr_odt;
`endif

// FLY-BY setting
`ifdef x4
wire [1:0]              rck_dev0;
wire [1:0]            rck_n_dev0;
wire [1:0]             rcke_dev0;
wire [1:0]             rs_n_dev0;
wire                 rras_n_dev0;
wire                 rcas_n_dev0;
wire                  rwe_n_dev0;
wire [2:0]              rba_dev0;
wire [2:0]              rba_dev0_mr;
wire [ADDR_BITS-1:0]  raddr_dev0;
wire [ADDR_BITS-1:0]  raddr_dev0_mr;
wire [1:0]             rodt_dev0;

assign #(`FBY_TRC_DQS0)    rck_dev0    = rck;
assign #(`FBY_TRC_DQS0)  rck_n_dev0    = rck_n;
assign #(`FBY_TRC_DQS0)   rcke_dev0    = rcke;
assign #(`FBY_TRC_DQS0)   rs_n_dev0    = rs_n;
assign #(`FBY_TRC_DQS0) rras_n_dev0    = rras_n;
assign #(`FBY_TRC_DQS0) rcas_n_dev0    = rcas_n;
assign #(`FBY_TRC_DQS0)  rwe_n_dev0    = rwe_n;
assign #(`FBY_TRC_DQS0)    rba_dev0    = rba;
assign #(`FBY_TRC_DQS0)    rba_dev0_mr = {rba[2],rba[0],rba[1]};
assign #(`FBY_TRC_DQS0)  raddr_dev0    = raddr;
assign #(`FBY_TRC_DQS0)  raddr_dev0_mr = {raddr[ADDR_BITS-1:9],raddr[7],raddr[8],raddr[5],raddr[6],raddr[3],raddr[4],raddr[2:0]};
assign #(`FBY_TRC_DQS0)   rodt_dev0    = rodt;

wire [1:0]               rck_dev1;
wire [1:0]             rck_n_dev1;
wire [1:0]              rcke_dev1;
wire [1:0]              rs_n_dev1;
wire                  rras_n_dev1;
wire                  rcas_n_dev1;
wire                   rwe_n_dev1;
wire [2:0]               rba_dev1;
wire [2:0]               rba_dev1_mr;
wire [ADDR_BITS-1:0]  raddr_dev1;
wire [ADDR_BITS-1:0]  raddr_dev1_mr;
wire [1:0]              rodt_dev1;

assign #(`FBY_TRC_DQS1)    rck_dev1    =    rck_dev0;
assign #(`FBY_TRC_DQS1)  rck_n_dev1    =  rck_n_dev0;
assign #(`FBY_TRC_DQS1)   rcke_dev1    =   rcke_dev0;
assign #(`FBY_TRC_DQS1)   rs_n_dev1    =   rs_n_dev0;
assign #(`FBY_TRC_DQS1) rras_n_dev1    = rras_n_dev0;
assign #(`FBY_TRC_DQS1) rcas_n_dev1    = rcas_n_dev0;
assign #(`FBY_TRC_DQS1)  rwe_n_dev1    =  rwe_n_dev0;
assign #(`FBY_TRC_DQS1)    rba_dev1    =    rba_dev0;
assign #(`FBY_TRC_DQS1)    rba_dev1_mr =    rba_dev0_mr;
assign #(`FBY_TRC_DQS1)  raddr_dev1    =  raddr_dev0;
assign #(`FBY_TRC_DQS1)  raddr_dev1_mr =  raddr_dev0_mr;
assign #(`FBY_TRC_DQS1)   rodt_dev1    =   rodt_dev0;

wire [1:0]               rck_dev2;
wire [1:0]             rck_n_dev2;
wire [1:0]              rcke_dev2;
wire [1:0]              rs_n_dev2;
wire                  rras_n_dev2;
wire                  rcas_n_dev2;
wire                   rwe_n_dev2;
wire [2:0]               rba_dev2;
wire [2:0]               rba_dev2_mr;
wire [ADDR_BITS-1:0]   raddr_dev2;
wire [ADDR_BITS-1:0]   raddr_dev2_mr;
wire [1:0]              rodt_dev2;

assign #(`FBY_TRC_DQS2)    rck_dev2    =    rck_dev1;
assign #(`FBY_TRC_DQS2)  rck_n_dev2    =  rck_n_dev1;
assign #(`FBY_TRC_DQS2)   rcke_dev2    =   rcke_dev1;
assign #(`FBY_TRC_DQS2)   rs_n_dev2    =   rs_n_dev1;
assign #(`FBY_TRC_DQS2) rras_n_dev2    = rras_n_dev1;
assign #(`FBY_TRC_DQS2) rcas_n_dev2    = rcas_n_dev1;
assign #(`FBY_TRC_DQS2)  rwe_n_dev2    =  rwe_n_dev1;
assign #(`FBY_TRC_DQS2)    rba_dev2    =    rba_dev1;
assign #(`FBY_TRC_DQS2)    rba_dev2_mr =    rba_dev1_mr;
assign #(`FBY_TRC_DQS2)  raddr_dev2    =  raddr_dev1;
assign #(`FBY_TRC_DQS2)  raddr_dev2_mr =  raddr_dev1_mr;
assign #(`FBY_TRC_DQS2)   rodt_dev2    =   rodt_dev1;

wire [1:0]              rck_dev3;
wire [1:0]            rck_n_dev3;
wire [1:0]             rcke_dev3;
wire [1:0]             rs_n_dev3;
wire                 rras_n_dev3;
wire                 rcas_n_dev3;
wire                  rwe_n_dev3;
wire [2:0]              rba_dev3;
wire [2:0]              rba_dev3_mr;
wire [ADDR_BITS-1:0]  raddr_dev3;
wire [ADDR_BITS-1:0]  raddr_dev3_mr;
wire [1:0]             rodt_dev3;

assign #(`FBY_TRC_DQS3)    rck_dev3    =    rck_dev2;
assign #(`FBY_TRC_DQS3)  rck_n_dev3    =  rck_n_dev2;
assign #(`FBY_TRC_DQS3)   rcke_dev3    =   rcke_dev2;
assign #(`FBY_TRC_DQS3)   rs_n_dev3    =   rs_n_dev2;
assign #(`FBY_TRC_DQS3) rras_n_dev3    = rras_n_dev2;
assign #(`FBY_TRC_DQS3) rcas_n_dev3    = rcas_n_dev2;
assign #(`FBY_TRC_DQS3)  rwe_n_dev3    =  rwe_n_dev2;
assign #(`FBY_TRC_DQS3)    rba_dev3    =    rba_dev2;
assign #(`FBY_TRC_DQS3)    rba_dev3_mr =    rba_dev2_mr;
assign #(`FBY_TRC_DQS3)  raddr_dev3    =  raddr_dev2;
assign #(`FBY_TRC_DQS3)  raddr_dev3_mr =  raddr_dev2_mr;
assign #(`FBY_TRC_DQS3)   rodt_dev3    =   rodt_dev2;

wire [1:0]              rck_dev4;
wire [1:0]            rck_n_dev4;
wire [1:0]             rcke_dev4;
wire [1:0]             rs_n_dev4;
wire                 rras_n_dev4;
wire                 rcas_n_dev4;
wire                  rwe_n_dev4;
wire [2:0]              rba_dev4;
wire [2:0]              rba_dev4_mr;
wire [ADDR_BITS-1:0]  raddr_dev4;
wire [ADDR_BITS-1:0]  raddr_dev4_mr;
wire [1:0]             rodt_dev4;

assign #(`FBY_TRC_DQS4)    rck_dev4    =    rck_dev3;
assign #(`FBY_TRC_DQS4)  rck_n_dev4    =  rck_n_dev3;
assign #(`FBY_TRC_DQS4)   rcke_dev4    =   rcke_dev3;
assign #(`FBY_TRC_DQS4)   rs_n_dev4    =   rs_n_dev3;
assign #(`FBY_TRC_DQS4) rras_n_dev4    = rras_n_dev3;
assign #(`FBY_TRC_DQS4) rcas_n_dev4    = rcas_n_dev3;
assign #(`FBY_TRC_DQS4)  rwe_n_dev4    =  rwe_n_dev3;
assign #(`FBY_TRC_DQS4)    rba_dev4    =    rba_dev3;
assign #(`FBY_TRC_DQS4)    rba_dev4_mr =    rba_dev3_mr;
assign #(`FBY_TRC_DQS4)  raddr_dev4    =  raddr_dev3;
assign #(`FBY_TRC_DQS4)  raddr_dev4_mr =  raddr_dev3_mr;
assign #(`FBY_TRC_DQS4)   rodt_dev4    =   rodt_dev3;

wire [1:0]              rck_dev5;
wire [1:0]            rck_n_dev5;
wire [1:0]             rcke_dev5;
wire [1:0]             rs_n_dev5;
wire                 rras_n_dev5;
wire                 rcas_n_dev5;
wire                  rwe_n_dev5;
wire [2:0]              rba_dev5;
wire [2:0]              rba_dev5_mr;
wire [ADDR_BITS-1:0]  raddr_dev5;
wire [ADDR_BITS-1:0]  raddr_dev5_mr;
wire [1:0]             rodt_dev5;

assign #(`FBY_TRC_DQS5)    rck_dev5    =    rck_dev4;
assign #(`FBY_TRC_DQS5)  rck_n_dev5    =  rck_n_dev4;
assign #(`FBY_TRC_DQS5)   rcke_dev5    =   rcke_dev4;
assign #(`FBY_TRC_DQS5)   rs_n_dev5    =   rs_n_dev4;
assign #(`FBY_TRC_DQS5) rras_n_dev5    = rras_n_dev4;
assign #(`FBY_TRC_DQS5) rcas_n_dev5    = rcas_n_dev4;
assign #(`FBY_TRC_DQS5)  rwe_n_dev5    =  rwe_n_dev4;
assign #(`FBY_TRC_DQS5)    rba_dev5    =    rba_dev4;
assign #(`FBY_TRC_DQS5)    rba_dev5_mr =    rba_dev4_mr;
assign #(`FBY_TRC_DQS5)  raddr_dev5    =  raddr_dev4;
assign #(`FBY_TRC_DQS5)  raddr_dev5_mr =  raddr_dev4_mr;
assign #(`FBY_TRC_DQS5)   rodt_dev5    =   rodt_dev4;
`else //x4
  `ifdef x8
      wire [1:0]              rck_dev0;
      wire [1:0]            rck_n_dev0;
      wire [1:0]             rcke_dev0;
      wire [1:0]             rs_n_dev0;
      wire                 rras_n_dev0;
      wire                 rcas_n_dev0;
      wire                  rwe_n_dev0;
      wire [2:0]              rba_dev0;
      wire [2:0]              rba_dev0_mr;
      wire [ADDR_BITS-1:0]  raddr_dev0;
      wire [ADDR_BITS-1:0]  raddr_dev0_mr;
      wire [1:0]             rodt_dev0;
      
      assign #(`FBY_TRC_DQS0)    rck_dev0    = rck;
      assign #(`FBY_TRC_DQS0)  rck_n_dev0    = rck_n;
      assign #(`FBY_TRC_DQS0)   rcke_dev0    = rcke;
      assign #(`FBY_TRC_DQS0)   rs_n_dev0    = rs_n;
      assign #(`FBY_TRC_DQS0) rras_n_dev0    = rras_n;
      assign #(`FBY_TRC_DQS0) rcas_n_dev0    = rcas_n;
      assign #(`FBY_TRC_DQS0)  rwe_n_dev0    = rwe_n;
      assign #(`FBY_TRC_DQS0)    rba_dev0    = rba;
      assign #(`FBY_TRC_DQS0)    rba_dev0_mr = {rba[2],rba[0],rba[1]};
      assign #(`FBY_TRC_DQS0)  raddr_dev0    = raddr;
      assign #(`FBY_TRC_DQS0)  raddr_dev0_mr = {raddr[ADDR_BITS-1:9],raddr[7],raddr[8],raddr[5],raddr[6],raddr[3],raddr[4],raddr[2:0]};
      assign #(`FBY_TRC_DQS0)   rodt_dev0    = rodt;
      
      wire [1:0]               rck_dev1;
      wire [1:0]             rck_n_dev1;
      wire [1:0]              rcke_dev1;
      wire [1:0]              rs_n_dev1;
      wire                  rras_n_dev1;
      wire                  rcas_n_dev1;
      wire                   rwe_n_dev1;
      wire [2:0]               rba_dev1;
      wire [2:0]               rba_dev1_mr;
      wire [ADDR_BITS-1:0]  raddr_dev1;
      wire [ADDR_BITS-1:0]  raddr_dev1_mr;
      wire [1:0]              rodt_dev1;
      
      assign #(`FBY_TRC_DQS1)    rck_dev1    =    rck_dev0;
      assign #(`FBY_TRC_DQS1)  rck_n_dev1    =  rck_n_dev0;
      assign #(`FBY_TRC_DQS1)   rcke_dev1    =   rcke_dev0;
      assign #(`FBY_TRC_DQS1)   rs_n_dev1    =   rs_n_dev0;
      assign #(`FBY_TRC_DQS1) rras_n_dev1    = rras_n_dev0;
      assign #(`FBY_TRC_DQS1) rcas_n_dev1    = rcas_n_dev0;
      assign #(`FBY_TRC_DQS1)  rwe_n_dev1    =  rwe_n_dev0;
      assign #(`FBY_TRC_DQS1)    rba_dev1    =    rba_dev0;
      assign #(`FBY_TRC_DQS1)    rba_dev1_mr =    rba_dev0_mr;
      assign #(`FBY_TRC_DQS1)  raddr_dev1    =  raddr_dev0;
      assign #(`FBY_TRC_DQS1)  raddr_dev1_mr =  raddr_dev0_mr;
      assign #(`FBY_TRC_DQS1)   rodt_dev1    =   rodt_dev0;
      
      wire [1:0]               rck_dev2;
      wire [1:0]             rck_n_dev2;
      wire [1:0]              rcke_dev2;
      wire [1:0]              rs_n_dev2;
      wire                  rras_n_dev2;
      wire                  rcas_n_dev2;
      wire                   rwe_n_dev2;
      wire [2:0]               rba_dev2;
      wire [2:0]               rba_dev2_mr;
      wire [ADDR_BITS-1:0]   raddr_dev2;
      wire [ADDR_BITS-1:0]   raddr_dev2_mr;
      wire [1:0]              rodt_dev2;
      
      assign #(`FBY_TRC_DQS2)    rck_dev2    =    rck_dev1;
      assign #(`FBY_TRC_DQS2)  rck_n_dev2    =  rck_n_dev1;
      assign #(`FBY_TRC_DQS2)   rcke_dev2    =   rcke_dev1;
      assign #(`FBY_TRC_DQS2)   rs_n_dev2    =   rs_n_dev1;
      assign #(`FBY_TRC_DQS2) rras_n_dev2    = rras_n_dev1;
      assign #(`FBY_TRC_DQS2) rcas_n_dev2    = rcas_n_dev1;
      assign #(`FBY_TRC_DQS2)  rwe_n_dev2    =  rwe_n_dev1;
      assign #(`FBY_TRC_DQS2)    rba_dev2    =    rba_dev1;
      assign #(`FBY_TRC_DQS2)    rba_dev2_mr =    rba_dev1_mr;
      assign #(`FBY_TRC_DQS2)  raddr_dev2    =  raddr_dev1;
      assign #(`FBY_TRC_DQS2)  raddr_dev2_mr =  raddr_dev1_mr;
      assign #(`FBY_TRC_DQS2)   rodt_dev2    =   rodt_dev1;
  `else //x8
     `ifdef x16
         wire [1:0]              rck_dev0;
         wire [1:0]            rck_n_dev0;
         wire [1:0]             rcke_dev0;
         wire [1:0]             rs_n_dev0;
         wire                 rras_n_dev0;
         wire                 rcas_n_dev0;
         wire                  rwe_n_dev0;
         wire [2:0]              rba_dev0;
         wire [2:0]              rba_dev0_mr;
         wire [ADDR_BITS-1:0]  raddr_dev0;
         wire [ADDR_BITS-1:0]  raddr_dev0_mr;
         wire [1:0]             rodt_dev0;
         
         assign #(`FBY_TRC_DQS0)    rck_dev0    = rck;
         assign #(`FBY_TRC_DQS0)  rck_n_dev0    = rck_n;
         assign #(`FBY_TRC_DQS0)   rcke_dev0    = rcke;
         assign #(`FBY_TRC_DQS0)   rs_n_dev0    = rs_n;
         assign #(`FBY_TRC_DQS0) rras_n_dev0    = rras_n;
         assign #(`FBY_TRC_DQS0) rcas_n_dev0    = rcas_n;
         assign #(`FBY_TRC_DQS0)  rwe_n_dev0    = rwe_n;
         assign #(`FBY_TRC_DQS0)    rba_dev0    = rba;
         assign #(`FBY_TRC_DQS0)    rba_dev0_mr = {rba[2],rba[0],rba[1]};
         assign #(`FBY_TRC_DQS0)  raddr_dev0    = {1'b0,raddr};
         assign #(`FBY_TRC_DQS0)  raddr_dev0_mr = {raddr[ADDR_BITS-1:9],raddr[7],raddr[8],raddr[5],raddr[6],raddr[3],raddr[4],raddr[2:0]};
         assign #(`FBY_TRC_DQS0)   rodt_dev0    = rodt;
         
         wire [1:0]               rck_dev1;
         wire [1:0]             rck_n_dev1;
         wire [1:0]              rcke_dev1;
         wire [1:0]              rs_n_dev1;
         wire                  rras_n_dev1;
         wire                  rcas_n_dev1;
         wire                   rwe_n_dev1;
         wire [2:0]               rba_dev1;
         wire [2:0]               rba_dev1_mr;
         wire [ADDR_BITS-1:0]   raddr_dev1;
         wire [ADDR_BITS-1:0]   raddr_dev1_mr;
         wire [1:0]              rodt_dev1;
         
         assign #(`FBY_TRC_DQS1)    rck_dev1    =    rck_dev0;
         assign #(`FBY_TRC_DQS1)  rck_n_dev1    =  rck_n_dev0;
         assign #(`FBY_TRC_DQS1)   rcke_dev1    =   rcke_dev0;
         assign #(`FBY_TRC_DQS1)   rs_n_dev1    =   rs_n_dev0;
         assign #(`FBY_TRC_DQS1) rras_n_dev1    = rras_n_dev0;
         assign #(`FBY_TRC_DQS1) rcas_n_dev1    = rcas_n_dev0;
         assign #(`FBY_TRC_DQS1)  rwe_n_dev1    =  rwe_n_dev0;
         assign #(`FBY_TRC_DQS1)    rba_dev1    =    rba_dev0;
         assign #(`FBY_TRC_DQS1)    rba_dev1_mr =    rba_dev0_mr;
         assign #(`FBY_TRC_DQS1)  raddr_dev1    =  raddr_dev0;
         assign #(`FBY_TRC_DQS1)  raddr_dev1_mr =  raddr_dev0_mr;
         assign #(`FBY_TRC_DQS1)   rodt_dev1    =   rodt_dev0;
     `endif //x16
  `endif //x8
`endif //x4 fly-by delay

`ifdef x4
    initial if (DEBUG) $display("%m: Component Width = x4");
  //ddr3      (rst_n,          ck,          ck_n,          cke,         cs_n,       ras_n,       cas_n,       we_n,     dm_tdqs,       ba,                      addr,          dq,        dqs,        dqs_n,  tdqs_n,        odt);
    ddr3 U0   (rst_n, rck_dev0[0], rck_n_dev0[0], rcke_dev0[0], rs_n_dev0[0], rras_n_dev0, rcas_n_dev0, rwe_n_dev0, ddr_dm_tdqs[0], rba_dev0, raddr_dev0[ADDR_BITS-1:0], ddr_dq[3:0], ddr_dqs[0], ddr_dqs_n[0],        , rodt_dev0[0]);
    ddr3 U1   (rst_n, rck_dev1[0], rck_n_dev1[0], rcke_dev1[0], rs_n_dev1[0], rras_n_dev1, rcas_n_dev1, rwe_n_dev1, ddr_dm_tdqs[1], rba_dev1, raddr_dev1[ADDR_BITS-1:0], ddr_dq[7:4], ddr_dqs[1], ddr_dqs_n[1],        , rodt_dev1[0]);
    ddr3 U2   (rst_n, rck_dev2[0], rck_n_dev2[0], rcke_dev2[0], rs_n_dev2[0], rras_n_dev2, rcas_n_dev2, rwe_n_dev2, ddr_dm_tdqs[2], rba_dev2, raddr_dev2[ADDR_BITS-1:0], ddr_dq[11:8], ddr_dqs[2], ddr_dqs_n[2],       , rodt_dev2[0]);
    ddr3 U3   (rst_n, rck_dev3[0], rck_n_dev3[0], rcke_dev3[0], rs_n_dev3[0], rras_n_dev3, rcas_n_dev3, rwe_n_dev3, ddr_dm_tdqs[3], rba_dev3, raddr_dev3[ADDR_BITS-1:0], ddr_dq[15:12], ddr_dqs[3], ddr_dqs_n[3],      , rodt_dev3[0]);
    ddr3 U4   (rst_n, rck_dev4[0], rck_n_dev4[0], rcke_dev4[0], rs_n_dev4[0], rras_n_dev4, rcas_n_dev4, rwe_n_dev4, ddr_dm_tdqs[4], rba_dev4, raddr_dev4[ADDR_BITS-1:0], ddr_dq[19:16], ddr_dqs[4], ddr_dqs_n[4],      , rodt_dev4[0]);
    ddr3 U5   (rst_n, rck_dev5[0], rck_n_dev5[0], rcke_dev5[0], rs_n_dev5[0], rras_n_dev5, rcas_n_dev5, rwe_n_dev5, ddr_dm_tdqs[5], rba_dev5, raddr_dev5[ADDR_BITS-1:0], ddr_dq[23:20], ddr_dqs[5], ddr_dqs_n[5],      , rodt_dev5[0]);

    `ifdef DUAL_RANK
      `ifdef ADDR_MIRROR
    ddr3 U0T   (rst_n, rck_dev0[1], rck_n_dev0[1], rcke_dev0[1], rs_n_dev0[1], rras_n_dev0, rcas_n_dev0, rwe_n_dev0, ddr_dm_tdqs[0], rba_dev0_mr, raddr_dev0_mr[ADDR_BITS-1:0], ddr_dq[3:0], ddr_dqs[0], ddr_dqs_n[0],        , rodt_dev0[1]);
    ddr3 U1T   (rst_n, rck_dev1[1], rck_n_dev1[1], rcke_dev1[1], rs_n_dev1[1], rras_n_dev1, rcas_n_dev1, rwe_n_dev1, ddr_dm_tdqs[1], rba_dev1_mr, raddr_dev1_mr[ADDR_BITS-1:0], ddr_dq[7:4], ddr_dqs[1], ddr_dqs_n[1],        , rodt_dev1[1]);
    ddr3 U2T   (rst_n, rck_dev2[1], rck_n_dev2[1], rcke_dev2[1], rs_n_dev2[1], rras_n_dev2, rcas_n_dev2, rwe_n_dev2, ddr_dm_tdqs[2], rba_dev2_mr, raddr_dev2_mr[ADDR_BITS-1:0], ddr_dq[11:8], ddr_dqs[2], ddr_dqs_n[2],       , rodt_dev2[1]);
    ddr3 U3T   (rst_n, rck_dev3[1], rck_n_dev3[1], rcke_dev3[1], rs_n_dev3[1], rras_n_dev3, rcas_n_dev3, rwe_n_dev3, ddr_dm_tdqs[3], rba_dev3_mr, raddr_dev3_mr[ADDR_BITS-1:0], ddr_dq[15:12], ddr_dqs[3], ddr_dqs_n[3],      , rodt_dev3[1]);
    ddr3 U4T   (rst_n, rck_dev4[1], rck_n_dev4[1], rcke_dev4[1], rs_n_dev4[1], rras_n_dev4, rcas_n_dev4, rwe_n_dev4, ddr_dm_tdqs[4], rba_dev4_mr, raddr_dev4_mr[ADDR_BITS-1:0], ddr_dq[19:16], ddr_dqs[4], ddr_dqs_n[4],      , rodt_dev4[1]);
    ddr3 U5T   (rst_n, rck_dev5[1], rck_n_dev5[1], rcke_dev5[1], rs_n_dev5[1], rras_n_dev5, rcas_n_dev5, rwe_n_dev5, ddr_dm_tdqs[5], rba_dev5_mr, raddr_dev5_mr[ADDR_BITS-1:0], ddr_dq[23:20], ddr_dqs[5], ddr_dqs_n[5],      , rodt_dev5[1]);

      `else // ADDR_MIRROR
    ddr3 U0T   (rst_n, rck_dev0[1], rck_n_dev0[1], rcke_dev0[1], rs_n_dev0[1], rras_n_dev0, rcas_n_dev0, rwe_n_dev0, ddr_dm_tdqs[0], rba_dev0, raddr_dev0[ADDR_BITS-1:0], ddr_dq[3:0], ddr_dqs[0], ddr_dqs_n[0],        , rodt_dev0[1]);
    ddr3 U1T   (rst_n, rck_dev1[1], rck_n_dev1[1], rcke_dev1[1], rs_n_dev1[1], rras_n_dev1, rcas_n_dev1, rwe_n_dev1, ddr_dm_tdqs[1], rba_dev1, raddr_dev1[ADDR_BITS-1:0], ddr_dq[7:4], ddr_dqs[1], ddr_dqs_n[1],        , rodt_dev1[1]);
    ddr3 U2T   (rst_n, rck_dev2[1], rck_n_dev2[1], rcke_dev2[1], rs_n_dev2[1], rras_n_dev2, rcas_n_dev2, rwe_n_dev2, ddr_dm_tdqs[2], rba_dev2, raddr_dev2[ADDR_BITS-1:0], ddr_dq[11:8], ddr_dqs[2], ddr_dqs_n[2],       , rodt_dev2[1]);
    ddr3 U3T   (rst_n, rck_dev3[1], rck_n_dev3[1], rcke_dev3[1], rs_n_dev3[1], rras_n_dev3, rcas_n_dev3, rwe_n_dev3, ddr_dm_tdqs[3], rba_dev3, raddr_dev3[ADDR_BITS-1:0], ddr_dq[15:12], ddr_dqs[3], ddr_dqs_n[3],      , rodt_dev3[1]);
    ddr3 U4T   (rst_n, rck_dev4[1], rck_n_dev4[1], rcke_dev4[1], rs_n_dev4[1], rras_n_dev4, rcas_n_dev4, rwe_n_dev4, ddr_dm_tdqs[4], rba_dev4, raddr_dev4[ADDR_BITS-1:0], ddr_dq[19:16], ddr_dqs[4], ddr_dqs_n[4],      , rodt_dev4[1]);
    ddr3 U5T   (rst_n, rck_dev5[1], rck_n_dev5[1], rcke_dev5[1], rs_n_dev5[1], rras_n_dev5, rcas_n_dev5, rwe_n_dev5, ddr_dm_tdqs[5], rba_dev5, raddr_dev5[ADDR_BITS-1:0], ddr_dq[23:20], ddr_dqs[5], ddr_dqs_n[5],      , rodt_dev5[1]);

      `endif // ADDR_MIRROR

  `endif //DUAL RANK

`else //x4
   `ifdef x8
    initial if (DEBUG) $display("%m: Component Width = x8");
    ddr3 U0   (rst_n, rck_dev0[0], rck_n_dev0[0], rcke_dev0[0], rs_n_dev0[0], rras_n_dev0, rcas_n_dev0, rwe_n_dev0, ddr_dm_tdqs[0], rba_dev0, raddr_dev0[ADDR_BITS-1:0], ddr_dq[7:0], ddr_dqs[0], ddr_dqs_n[0],      , rodt_dev0[0]);
    ddr3 U1   (rst_n, rck_dev1[0], rck_n_dev1[0], rcke_dev1[0], rs_n_dev1[0], rras_n_dev1, rcas_n_dev1, rwe_n_dev1, ddr_dm_tdqs[1], rba_dev1, raddr_dev1[ADDR_BITS-1:0], ddr_dq[15:8], ddr_dqs[1], ddr_dqs_n[1],      , rodt_dev1[0]);
    ddr3 U2   (rst_n, rck_dev2[0], rck_n_dev2[0], rcke_dev2[0], rs_n_dev2[0], rras_n_dev2, rcas_n_dev2, rwe_n_dev2, ddr_dm_tdqs[2], rba_dev2, raddr_dev2[ADDR_BITS-1:0], ddr_dq[23:16], ddr_dqs[2], ddr_dqs_n[2],      , rodt_dev2[0]);

    `ifdef DUAL_RANK
      `ifdef ADDR_MIRROR
    ddr3 U0T  (rst_n, rck_dev0[1], rck_n_dev0[1], rcke_dev0[1], rs_n_dev0[1], rras_n_dev0, rcas_n_dev0, rwe_n_dev0, ddr_dm_tdqs[0], rba_dev0_mr, raddr_dev0_mr[ADDR_BITS-1:0], ddr_dq[7:0], ddr_dqs[0], ddr_dqs_n[0],      , rodt_dev0[1]);
    ddr3 U1T  (rst_n, rck_dev1[1], rck_n_dev1[1], rcke_dev1[1], rs_n_dev1[1], rras_n_dev1, rcas_n_dev1, rwe_n_dev1, ddr_dm_tdqs[1], rba_dev1_mr, raddr_dev1_mr[ADDR_BITS-1:0], ddr_dq[15:8], ddr_dqs[1], ddr_dqs_n[1],      , rodt_dev1[1]);
    ddr3 U2T  (rst_n, rck_dev2[1], rck_n_dev2[1], rcke_dev2[1], rs_n_dev2[1], rras_n_dev2, rcas_n_dev2, rwe_n_dev2, ddr_dm_tdqs[2], rba_dev2_mr, raddr_dev2_mr[ADDR_BITS-1:0], ddr_dq[23:16], ddr_dqs[2], ddr_dqs_n[2],      , rodt_dev2[1]);

      `else // ADDR_MIRROR
    ddr3 U0T  (rst_n, rck_dev0[1], rck_n_dev0[1], rcke_dev0[1], rs_n_dev0[1], rras_n_dev0, rcas_n_dev0, rwe_n_dev0, ddr_dm_tdqs[0], rba_dev0, raddr_dev0[ADDR_BITS-1:0], ddr_dq[7:0], ddr_dqs[0], ddr_dqs_n[0],      , rodt_dev0[1]);
    ddr3 U1T  (rst_n, rck_dev1[1], rck_n_dev1[1], rcke_dev1[1], rs_n_dev1[1], rras_n_dev1, rcas_n_dev1, rwe_n_dev1, ddr_dm_tdqs[1], rba_dev1, raddr_dev1[ADDR_BITS-1:0], ddr_dq[15:8], ddr_dqs[1], ddr_dqs_n[1],      , rodt_dev1[1]);
    ddr3 U2T  (rst_n, rck_dev2[1], rck_n_dev2[1], rcke_dev2[1], rs_n_dev2[1], rras_n_dev2, rcas_n_dev2, rwe_n_dev2, ddr_dm_tdqs[2], rba_dev2, raddr_dev2[ADDR_BITS-1:0], ddr_dq[23:16], ddr_dqs[2], ddr_dqs_n[2],      , rodt_dev2[1]);

      `endif // ADDR_MIRROR
    `endif //DUAL_RANK
 `else //x8
    `ifdef x16
    initial if (DEBUG) $display("%m: Component Width = x16");
    ddr3 U0   (rst_n, rck_dev0[0], rck_n_dev0[0], rcke_dev0[0], rs_n_dev0[0], rras_n_dev0, rcas_n_dev0, rwe_n_dev0, ddr_dm_tdqs[1:0], rba_dev0, raddr_dev0[ADDR_BITS-1:0], ddr_dq[15:0], ddr_dqs[1:0], ddr_dqs_n[1:0],  , rodt_dev0[0]);
    ddr3 U1   (rst_n, rck_dev1[0], rck_n_dev1[0], rcke_dev1[0], rs_n_dev1[0], rras_n_dev1, rcas_n_dev1, rwe_n_dev1, {ddr_dm_tdqs[2],ddr_dm_tdqs[2]}, rba_dev1, raddr_dev1[ADDR_BITS-1:0], {ddr_dq[23:16],ddr_dq[23:16]}, {ddr_dqs[2],ddr_dqs[2]}, {ddr_dqs_n[2],ddr_dqs_n[2]},  , rodt_dev1[0]);

    `ifdef DUAL_RANK
      `ifdef ADDR_MIRROR
    ddr3 U0T  (rst_n, rck_dev0[1], rck_n_dev0[1], rcke_dev0[1], rs_n_dev0[1], rras_n_dev0, rcas_n_dev0, rwe_n_dev0, ddr_dm_tdqs[1:0], rba_dev0_mr, raddr_dev0_mr[ADDR_BITS-1:0], ddr_dq[15:0], ddr_dqs[1:0], ddr_dqs_n[1:0],  , rodt_dev0[1]);
    ddr3 U1T  (rst_n, rck_dev1[1], rck_n_dev1[1], rcke_dev1[1], rs_n_dev1[1], rras_n_dev1, rcas_n_dev1, rwe_n_dev1, {ddr_dm_tdqs[2],ddr_dm_tdqs[2]}, rba_dev1_mr, raddr_dev1_mr[ADDR_BITS-1:0], {ddr_dq[23:16],ddr_dq[23:16]}, {ddr_dqs[2],ddr_dqs[2]}, {ddr_dqs_n[2],ddr_dqs_n[2]},  , rodt_dev1[1]);

      `else // ADDR_MIRROR
    ddr3 U0T  (rst_n, rck_dev0[1], rck_n_dev0[1], rcke_dev0[1], rs_n_dev0[1], rras_n_dev0, rcas_n_dev0, rwe_n_dev0, ddr_dm_tdqs[1:0], rba_dev0, raddr_dev0[ADDR_BITS-1:0], ddr_dq[15:0], ddr_dqs[1:0], ddr_dqs_n[1:0],  , rodt_dev0[1]);
    ddr3 U1T  (rst_n, rck_dev1[1], rck_n_dev1[1], rcke_dev1[1], rs_n_dev1[1], rras_n_dev1, rcas_n_dev1, rwe_n_dev1, {ddr_dm_tdqs[2],ddr_dm_tdqs[2]}, rba_dev1, raddr_dev1[ADDR_BITS-1:0], {ddr_dq[23:16],ddr_dq[23:16]}, {ddr_dqs[2],ddr_dqs[2]}, {ddr_dqs_n[2],ddr_dqs_n[2]},  , rodt_dev1[1]);

      `endif // ADDR_MIRROR
    `endif //DUAL_RANK

    `endif //x16
  `endif //x8
`endif //x4

endmodule

