`ifndef _MEM_MODEL_
`define _MEM_MODEL_

`include "mem_core.v"
`timescale 1ps / 1ps

module mem_model # (
    parameter CLKO_WIDTH        = 2,
    parameter CKE_WIDTH         = 2,
    parameter DDR_CS_WIDTH      = 1,
    parameter BANK_WIDTH        = 3,
    parameter ROW_WIDTH         = 1,
    parameter DDR_DATA_WIDTH    = 32,
    parameter DQS_WIDTH         = DDR_DATA_WIDTH/8,
    parameter TARGET_FREQUENCY  = 800,
    parameter DQSW              = "x8",
    parameter WRITE_LEVEL_EN    = 0,
    parameter MEM_TYPE          = "1Gb",
    parameter GEARING           = 2
)(
    input                       rst_n,
    input  [CLKO_WIDTH-1:0]     ddr_clk,
    input  [CLKO_WIDTH-1:0]     ddr_clk_n,
    input  [CKE_WIDTH-1:0]      ddr_cke,
    input  [DDR_CS_WIDTH-1:0]   ddr_cs_n,
    input  [DDR_CS_WIDTH-1:0]   ddr_odt,

    input                       ddr_ras_n,
    input                       ddr_cas_n,
    input                       ddr_we_n,
    input  [BANK_WIDTH-1:0]     ddr_ba,
    input  [ROW_WIDTH-1:0]      ddr_ad,
    inout  [DQS_WIDTH-1:0]      ddr_dqs,
    inout  [DQS_WIDTH-1:0]      ddr_dqs_n,
    inout  [DDR_DATA_WIDTH-1:0] ddr_dq,
    inout  [DQS_WIDTH-1:0]      ddr_dm_tdqs
);

if(TARGET_FREQUENCY <= 400) begin : _X2_GEAR
    mem_core # (
        .CLKO_WIDTH      (CLKO_WIDTH),
        .CKE_WIDTH       (CKE_WIDTH),
        .DDR_CS_WIDTH    (DDR_CS_WIDTH), 
        .BANK_WIDTH      (BANK_WIDTH), 
        .ROW_WIDTH       (ROW_WIDTH),   
        .DDR_DATA_WIDTH  (DDR_DATA_WIDTH),
        .DQS_WIDTH       (DQS_WIDTH),
        .MEM_TYPE        (MEM_TYPE),
        .ADDR_BITS       (ROW_WIDTH)
    ) ddr_mem (
        .rst_n           (rst_n),
    
        .ddr_clk         (ddr_clk),
        .ddr_clk_n       (ddr_clk_n),
        .ddr_cke         (ddr_cke),
        .ddr_cs_n        (ddr_cs_n),
        .ddr_odt         (ddr_odt),
    
        .ddr_ras_n       (ddr_ras_n),
        .ddr_cas_n       (ddr_cas_n),
        .ddr_we_n        (ddr_we_n),
        .ddr_ba          (ddr_ba),
        .ddr_ad          (ddr_ad),
        .ddr_dqs         (ddr_dqs),
        .ddr_dqs_n       (ddr_dqs_n),
        .ddr_dq          (ddr_dq),
        .ddr_dm_tdqs     (ddr_dm_tdqs)
    );
    
    defparam ddr_mem.TCK_MIN    = (TARGET_FREQUENCY == 533) ?  1875:  2500; // tCK        ps    Minimum Clock Cycle Time
    defparam ddr_mem.TJIT_PER   = (TARGET_FREQUENCY == 533) ?    90:   100; // tJIT(per)  ps    Period JItter
    defparam ddr_mem.TJIT_CC    = (TARGET_FREQUENCY == 533) ?   180:   200; // tJIT(cc)   ps    Cycle to Cycle jitter
    defparam ddr_mem.TERR_2PER  = (TARGET_FREQUENCY == 533) ?   132:   147; // tERR(2per) ps    Accumulated Error (2-cycle)
    defparam ddr_mem.TERR_3PER  = (TARGET_FREQUENCY == 533) ?   157:   175; // tERR(3per) ps    Accumulated Error (3-cycle)
    defparam ddr_mem.TERR_4PER  = (TARGET_FREQUENCY == 533) ?   175:   194; // tERR(4per) ps    Accumulated Error (4-cycle)
    defparam ddr_mem.TERR_5PER  = (TARGET_FREQUENCY == 533) ?   188:   209; // tERR(5per) ps    Accumulated Error (5-cycle)
    defparam ddr_mem.TERR_6PER  = (TARGET_FREQUENCY == 533) ?   200:   222; // tERR(6per) ps    Accumulated Error (6-cycle)
    defparam ddr_mem.TERR_7PER  = (TARGET_FREQUENCY == 533) ?   209:   232; // tERR(7per) ps    Accumulated Error (7-cycle)
    defparam ddr_mem.TERR_8PER  = (TARGET_FREQUENCY == 533) ?   217:   241; // tERR(8per) ps    Accumulated Error (8-cycle)
    defparam ddr_mem.TERR_9PER  = (TARGET_FREQUENCY == 533) ?   224:   249; // tERR(9per) ps    Accumulated Error (9-cycle)
    defparam ddr_mem.TERR_10PER = (TARGET_FREQUENCY == 533) ?   231:   257; // tERR(10per)ps    Accumulated Error (10-cycle)
    defparam ddr_mem.TERR_11PER = (TARGET_FREQUENCY == 533) ?   237:   263; // tERR(11per)ps    Accumulated Error (11-cycle)
    defparam ddr_mem.TERR_12PER = (TARGET_FREQUENCY == 533) ?   242:   269; // tERR(12per)ps    Accumulated Error (12-cycle)
    defparam ddr_mem.TDS        = (TARGET_FREQUENCY == 533) ?    75:   125; // tDS        ps    DQ and DM input setup time relative to DQS
    defparam ddr_mem.TDH        = (TARGET_FREQUENCY == 533) ?   100:   150; // tDH        ps    DQ and DM input hold time relative to DQS
    defparam ddr_mem.TDQSQ      = (TARGET_FREQUENCY == 533) ?   150:   200; // tDQSQ      ps    DQS-DQ skew; DQS to last DQ valid; per group; per access
    defparam ddr_mem.TDQSS      = (TARGET_FREQUENCY == 533) ?  0.25:  0.25; // tDQSS      tCK   Rising clock edge to DQS/DQS# latching transition
    defparam ddr_mem.TDSS       = (TARGET_FREQUENCY == 533) ?  0.20:  0.20; // tDSS       tCK   DQS falling edge to CLK rising (setup time)
    defparam ddr_mem.TDSH       = (TARGET_FREQUENCY == 533) ?  0.20:  0.20; // tDSH       tCK   DQS falling edge from CLK rising (hold time)
    defparam ddr_mem.TDQSCK     = (TARGET_FREQUENCY == 533) ?   300:   400; // tDQSCK     ps    DQS output access time from CK/CK#
    defparam ddr_mem.TQSH       = (TARGET_FREQUENCY == 533) ?  0.38:  0.38; // tQSH       tCK   DQS Output High Pulse Width
    defparam ddr_mem.TQSL       = (TARGET_FREQUENCY == 533) ?  0.38:  0.38; // tQSL       tCK   DQS Output Low Pulse Width
    defparam ddr_mem.TDIPW      = (TARGET_FREQUENCY == 533) ?   490:   600; // tDIPW      ps    DQ and DM input Pulse Width
    defparam ddr_mem.TIPW       = (TARGET_FREQUENCY == 533) ?   780:   900; // tIPW       ps    Control and Address input Pulse Width  
    defparam ddr_mem.TIS        = (TARGET_FREQUENCY == 533) ?   275:   350; // tIS        ps    Input Setup Time
    defparam ddr_mem.TIH        = (TARGET_FREQUENCY == 533) ?   200:   275; // tIH        ps    Input Hold Time
    defparam ddr_mem.TRAS_MIN   = (TARGET_FREQUENCY == 533) ? 37500: 37500; // tRAS       ps    Minimum Active to Precharge command time
    defparam ddr_mem.TRC        = (TARGET_FREQUENCY == 533) ? 52500: 50000; // tRC        ps    Active to Active/Auto Refresh command time
    defparam ddr_mem.TRCD       = (TARGET_FREQUENCY == 533) ? 15000: 12500; // tRCD       ps    Active to Read/Write command time
    defparam ddr_mem.TRP        = (TARGET_FREQUENCY == 533) ? 15000: 12500; // tRP        ps    Precharge command period
    defparam ddr_mem.TXP        = (TARGET_FREQUENCY == 533) ?  7500:  7500; // tXP        ps    Exit power down to a valid command
    defparam ddr_mem.TCKE       = (TARGET_FREQUENCY == 533) ?  5625:  7500; // tCKE       ps    CKE minimum high or low pulse width
    defparam ddr_mem.TAON       = (TARGET_FREQUENCY == 533) ?   300:   400; // tAON       ps    RTT turn-on from ODTLon reference
    defparam ddr_mem.TWLS       = (TARGET_FREQUENCY == 533) ?   245:   325; // tWLS       ps    Setup time for tDQS flop
    defparam ddr_mem.TWLH       = (TARGET_FREQUENCY == 533) ?   245:   325; // tWLH       ps    Hold time of tDQS flop
    defparam ddr_mem.TWLO       = (TARGET_FREQUENCY == 533) ?  9000:  9000; // tWLO       ps    Write levelization output delay
    defparam ddr_mem.TAA_MIN    = (TARGET_FREQUENCY == 533) ? 15000: 12500; // TAA        ps    Internal READ command to first data
    defparam ddr_mem.CL_TIME    = (TARGET_FREQUENCY == 533) ? 15000: 12500; // CL         ps    Minimum CAS Latency
    							    
    defparam ddr_mem.TRRD       = (DQSW == "x16") ? 10000 : (TARGET_FREQUENCY == 533) ?  7500 : 10000;
    defparam ddr_mem.TFAW       = (DQSW == "x16") ? 50000 : (TARGET_FREQUENCY == 533) ? 37500 : 40000;
    							    
    defparam ddr_mem.DM_BITS    = (DQSW == "x16") ?  2 :  1; // Set this parameter to control how many Data Mask bits are used
    defparam ddr_mem.ADDR_BITS  = (DQSW == "x16") ? 13 : 14; // MAX Address Bits
    defparam ddr_mem.ROW_BITS   = (DQSW == "x16") ? 13 : 14; // Set this parameter to control how many Address bits are used
    defparam ddr_mem.COL_BITS   = (DQSW == "x16") ? 10 : 10; // Set this parameter to control how many Column bits are used
    defparam ddr_mem.DQ_BITS    = (DQSW == "x16") ? 16 :  8; // Set this parameter to control how many Data bits are used       **Same as part bit width**
    defparam ddr_mem.DQS_BITS   = (DQSW == "x16") ?  2 :  1; // Set this parameter to control how many Dqs bits are used
    defparam ddr_mem.MEM_CONFIG = (DQSW == "x16") ? "X16" : "X8";
    defparam ddr_mem.WRITE_LEVELING = WRITE_LEVEL_EN;
    defparam ddr_mem.GEARING    = GEARING;
end
else begin : _X4_GEAR
    mem_core # (
        .CLKO_WIDTH      (CLKO_WIDTH),
        .CKE_WIDTH       (CKE_WIDTH),
        .DDR_CS_WIDTH    (DDR_CS_WIDTH), 
        .BANK_WIDTH      (BANK_WIDTH), 
        .ROW_WIDTH       (ROW_WIDTH),   
        .DDR_DATA_WIDTH  (DDR_DATA_WIDTH),
        .DQS_WIDTH       (DQS_WIDTH),
        .MEM_TYPE        (MEM_TYPE),
        .ADDR_BITS       (ROW_WIDTH),
        .GEARING         (GEARING)
    ) ddr_mem (
        .rst_n           (rst_n),
    
        .ddr_clk         (ddr_clk),
        .ddr_clk_n       (ddr_clk_n),
        .ddr_cke         (ddr_cke),
        .ddr_cs_n        (ddr_cs_n),
        .ddr_odt         (ddr_odt),
    
        .ddr_ras_n       (ddr_ras_n),
        .ddr_cas_n       (ddr_cas_n),
        .ddr_we_n        (ddr_we_n),
        .ddr_ba          (ddr_ba),
        .ddr_ad          (ddr_ad),
        .ddr_dqs         (ddr_dqs),
        .ddr_dqs_n       (ddr_dqs_n),
        .ddr_dq          (ddr_dq),
        .ddr_dm_tdqs     (ddr_dm_tdqs)
    );
    
    defparam ddr_mem.TCK_MIN    =  1875; // tCK        ps    Minimum Clock Cycle Time
    defparam ddr_mem.TJIT_PER   =    90; // tJIT(per)  ps    Period JItter
    defparam ddr_mem.TJIT_CC    =   180; // tJIT(cc)   ps    Cycle to Cycle jitter
    defparam ddr_mem.TERR_2PER  =   132; // tERR(2per) ps    Accumulated Error (2-cycle)
    defparam ddr_mem.TERR_3PER  =   157; // tERR(3per) ps    Accumulated Error (3-cycle)
    defparam ddr_mem.TERR_4PER  =   175; // tERR(4per) ps    Accumulated Error (4-cycle)
    defparam ddr_mem.TERR_5PER  =   188; // tERR(5per) ps    Accumulated Error (5-cycle)
    defparam ddr_mem.TERR_6PER  =   200; // tERR(6per) ps    Accumulated Error (6-cycle)
    defparam ddr_mem.TERR_7PER  =   209; // tERR(7per) ps    Accumulated Error (7-cycle)
    defparam ddr_mem.TERR_8PER  =   217; // tERR(8per) ps    Accumulated Error (8-cycle)
    defparam ddr_mem.TERR_9PER  =   224; // tERR(9per) ps    Accumulated Error (9-cycle)
    defparam ddr_mem.TERR_10PER =   231; // tERR(10per)ps    Accumulated Error (10-cycle)
    defparam ddr_mem.TERR_11PER =   237; // tERR(11per)ps    Accumulated Error (11-cycle)
    defparam ddr_mem.TERR_12PER =   242; // tERR(12per)ps    Accumulated Error (12-cycle)
    defparam ddr_mem.TDS        =    75; // tDS        ps    DQ and DM input setup time relative to DQS
    defparam ddr_mem.TDH        =   100; // tDH        ps    DQ and DM input hold time relative to DQS
    defparam ddr_mem.TDQSQ      =   150; // tDQSQ      ps    DQS-DQ skew; DQS to last DQ valid; per group; per access
    defparam ddr_mem.TDQSS      =  0.25; // tDQSS      tCK   Rising clock edge to DQS/DQS# latching transition
    defparam ddr_mem.TDSS       =  0.20; // tDSS       tCK   DQS falling edge to CLK rising (setup time)
    defparam ddr_mem.TDSH       =  0.20; // tDSH       tCK   DQS falling edge from CLK rising (hold time)
    defparam ddr_mem.TDQSCK     =   300; // tDQSCK     ps    DQS output access time from CK/CK#
    defparam ddr_mem.TQSH       =  0.38; // tQSH       tCK   DQS Output High Pulse Width
    defparam ddr_mem.TQSL       =  0.38; // tQSL       tCK   DQS Output Low Pulse Width
    defparam ddr_mem.TDIPW      =   490; // tDIPW      ps    DQ and DM input Pulse Width
    defparam ddr_mem.TIPW       =   780; // tIPW       ps    Control and Address input Pulse Width  
    defparam ddr_mem.TIS        =   275; // tIS        ps    Input Setup Time
    defparam ddr_mem.TIH        =   200; // tIH        ps    Input Hold Time
    defparam ddr_mem.TRAS_MIN   = 37500; // tRAS       ps    Minimum Active to Precharge command time
    defparam ddr_mem.TRC        = 50625; // tRC        ps    Active to Active/Auto Refresh command time
    defparam ddr_mem.TRCD       = 13125; // tRCD       ps    Active to Read/Write command time
    defparam ddr_mem.TRP        = 13125; // tRP        ps    Precharge command period
    defparam ddr_mem.TXP        =  7500; // tXP        ps    Exit power down to a valid command
    defparam ddr_mem.TCKE       =  5625; // tCKE       ps    CKE minimum high or low pulse width
    defparam ddr_mem.TAON       =   300; // tAON       ps    RTT turn-on from ODTLon reference
    defparam ddr_mem.TWLS       =   245; // tWLS       ps    Setup time for tDQS flop
    defparam ddr_mem.TWLH       =   245; // tWLH       ps    Hold time of tDQS flop
    defparam ddr_mem.TWLO       =  9000; // tWLO       ps    Write levelization output delay
    defparam ddr_mem.TAA_MIN    = 13125; // TAA        ps    Internal READ command to first data
    defparam ddr_mem.CL_TIME    = 13125; // CL         ps    Minimum CAS Latency
    							    
    defparam ddr_mem.TRRD       = 10000;
    defparam ddr_mem.TFAW       = 50000;
    							    
    defparam ddr_mem.DM_BITS    = (DQSW == "x16") ?  2 :  1; // Set this parameter to control how many Data Mask bits are used
    defparam ddr_mem.ADDR_BITS  = (DQSW == "x16") ? 13 : 14; // MAX Address Bits
    defparam ddr_mem.ROW_BITS   = (DQSW == "x16") ? 13 : 14; // Set this parameter to control how many Address bits are used
    defparam ddr_mem.COL_BITS   = (DQSW == "x16") ? 10 : 10; // Set this parameter to control how many Column bits are used
    defparam ddr_mem.DQ_BITS    = (DQSW == "x16") ? 16 :  8; // Set this parameter to control how many Data bits are used       **Same as part bit width**
    defparam ddr_mem.DQS_BITS   = (DQSW == "x16") ?  2 :  1; // Set this parameter to control how many Dqs bits are used
    defparam ddr_mem.MEM_CONFIG = (DQSW == "x16") ? "X16" : "X8";
    defparam ddr_mem.GEARING    = GEARING;
    defparam ddr_mem.WRITE_LEVELING = WRITE_LEVEL_EN;
end
endmodule
`endif