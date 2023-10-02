`ifndef _MEM_CORE_
`define _MEM_CORE_

`include "lscc_ddr3.v"
`timescale 1ps / 1ps

module mem_core # (
    parameter CLKO_WIDTH      = 2,
    parameter CKE_WIDTH       = 2,
    parameter DDR_CS_WIDTH    = 1,
    parameter BANK_WIDTH      = 3,
    parameter ROW_WIDTH       = 1,
    parameter DDR_DATA_WIDTH  = 32,
    parameter DQS_WIDTH       = DDR_DATA_WIDTH/8,

    parameter TCK_MIN         = 2500,  // tCK        ps    Minimum Clock Cycle Time
    parameter TJIT_PER        = 100,   // tJIT(per)  ps    Period JItter
    parameter TJIT_CC         = 200,   // tJIT(cc)   ps    Cycle to Cycle jitter
    parameter TERR_2PER       = 147,   // tERR(2per) ps    Accumulated Error (2-cycle)
    parameter TERR_3PER       = 175,   // tERR(3per) ps    Accumulated Error (3-cycle)
    parameter TERR_4PER       = 194,   // tERR(4per) ps    Accumulated Error (4-cycle)
    parameter TERR_5PER       = 209,   // tERR(5per) ps    Accumulated Error (5-cycle)
    parameter TERR_6PER       = 222,   // tERR(6per) ps    Accumulated Error (6-cycle)
    parameter TERR_7PER       = 232,   // tERR(7per) ps    Accumulated Error (7-cycle)
    parameter TERR_8PER       = 241,   // tERR(8per) ps    Accumulated Error (8-cycle)
    parameter TERR_9PER       = 249,   // tERR(9per) ps    Accumulated Error (9-cycle)
    parameter TERR_10PER      = 257,   // tERR(10per)ps    Accumulated Error (10-cycle)
    parameter TERR_11PER      = 263,   // tERR(11per)ps    Accumulated Error (11-cycle)
    parameter TERR_12PER      = 269,   // tERR(12per)ps    Accumulated Error (12-cycle)
    parameter TDS             = 125,   // tDS        ps    DQ and DM input setup time relative to DQS
    parameter TDH             = 150,   // tDH        ps    DQ and DM input hold time relative to DQS
    parameter TDQSQ           = 200,   // tDQSQ      ps    DQS-DQ skew, DQS to last DQ valid, per group, per access
    parameter TDQSS           = 0.25,  // tDQSS      tCK   Rising clock edge to DQS/DQS# latching transition
    parameter TDSS            = 0.20,  // tDSS       tCK   DQS falling edge to CLK rising (setup time)
    parameter TDSH            = 0.20,  // tDSH       tCK   DQS falling edge from CLK rising (hold time)
    parameter TDQSCK          = 400,   // tDQSCK     ps    DQS output access time from CK/CK#
    parameter TQSH            = 0.38,  // tQSH       tCK   DQS Output High Pulse Width
    parameter TQSL            = 0.38,  // tQSL       tCK   DQS Output Low Pulse Width
    parameter TDIPW           = 600,   // tDIPW      ps    DQ and DM input Pulse Width
    parameter TIPW            = 900,   // tIPW       ps    Control and Address input Pulse Width  
    parameter TIS             = 350,   // tIS        ps    Input Setup Time
    parameter TIH             = 275,   // tIH        ps    Input Hold Time
    parameter TRAS_MIN        = 37500, // tRAS       ps    Minimum Active to Precharge command time
    parameter TRC             = 50000, // tRC        ps    Active to Active/Auto Refresh command time
    parameter TRCD            = 12500, // tRCD       ps    Active to Read/Write command time
    parameter TRP             = 12500, // tRP        ps    Precharge command period
    parameter TXP             = 7500,  // tXP        ps    Exit power down to a valid command
    parameter TCKE            = 7500,  // tCKE       ps    CKE minimum high or low pulse width
    parameter TAON            = 400,   // tAON       ps    RTT turn-on from ODTLon reference

    parameter TWLS            = 325,   // tWLS       ps    Setup time for tDQS flop
    parameter TWLH            = 325,   // tWLH       ps    Hold time of tDQS flop
    parameter TWLO            = 9000,  // tWLO       ps    Write levelization output delay
    parameter TAA_MIN         = 12500, // TAA        ps    Internal READ command to first data
    parameter CL_TIME         = 12500, // CL         ps    Minimum CAS Latency

    parameter TRRD            = 10000, // tRRD       ps     (2KB page size) Active bank a to Active bank b command time
    parameter TFAW            = 50000, // tFAW       ps     (2KB page size) Four Bank Activate window

    parameter DM_BITS         =     1, // Set this parameter to control how many Data Mask bits are used
    parameter ADDR_BITS       =    14, // MAX Address Bits
    parameter ROW_BITS        =    14, // Set this parameter to control how many Address bits are used
    parameter COL_BITS        =    10, // Set this parameter to control how many Column bits are used
    parameter DQ_BITS         =     8, // Set this parameter to control how many Data bits are used       **Same as part bit width**
    parameter DQS_BITS        =     1, // Set this parameter to control how many Dqs bits are used

    parameter DDR_FREQ        =   800,
    parameter GEARING         = 2,
    parameter MEM_TYPE        = "1Gb",
    parameter WRITE_LEVELING  = 0,
    parameter MEM_CONFIG      = "X8",
    parameter MAX_MEM         = 0,
    parameter DIFF            = 0,
    parameter MPR_DQ0         = 1,
    parameter WL_ALLDQ        = 0,
    parameter FULL_FLY_BY_DEL = 1000
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

// Timing localparams

// Mode Register
localparam CL_MIN           =       5; // CL         tCK   Minimum CAS Latency
localparam CL_MAX           =      14; // CL         tCK   Maximum CAS Latency
localparam AL_MIN           =       0; // AL         tCK   Minimum Additive Latency
localparam AL_MAX           =       2; // AL         tCK   Maximum Additive Latency
localparam WR_MIN           =       5; // WR         tCK   Minimum Write Recovery
localparam WR_MAX           =      16; // WR         tCK   Maximum Write Recovery
localparam BL_MIN           =       4; // BL         tCK   Minimum Burst Length
localparam BL_MAX           =       8; // BL         tCK   Minimum Burst Length
localparam CWL_MIN          =       5; // CWL        tCK   Minimum CAS Write Latency
localparam CWL_MAX          =      10; // CWL        tCK   Maximum CAS Write Latency

// Clock
localparam TCK_MAX          =    3334; // tCK        ps    Maximum Clock Cycle Time
localparam TCH_AVG_MIN      =    0.47; // tCH        tCK   Minimum Clock High-Level Pulse Width
localparam TCL_AVG_MIN      =    0.47; // tCL        tCK   Minimum Clock Low-Level Pulse Width
localparam TCH_AVG_MAX      =    0.53; // tCH        tCK   Maximum Clock High-Level Pulse Width
localparam TCL_AVG_MAX      =    0.53; // tCL        tCK   Maximum Clock Low-Level Pulse Width
localparam TCH_ABS_MIN      =    0.43; // tCH        tCK   Minimum Clock High-Level Pulse Width
localparam TCL_ABS_MIN      =    0.43; // tCL        tCK   Maximum Clock Low-Level Pulse Width
localparam TCKE_TCK         =       3; // tCKE       tCK   CKE minimum high or low pulse width
localparam TAA_MAX          =   20000; // TAA        ps    Internal READ command to first data

// Data OUT
localparam TQH              =    0.38; // tQH        ps    DQ output hold time from DQS, DQS#
// Data Strobe OUT
localparam TRPRE            =    0.90; // tRPRE      tCK   DQS Read Preamble
localparam TRPST            =    0.30; // tRPST      tCK   DQS Read Postamble
// Data Strobe IN
localparam TDQSH            =    0.45; // tDQSH      tCK   DQS input High Pulse Width
localparam TDQSL            =    0.45; // tDQSL      tCK   DQS input Low Pulse Width
localparam TWPRE            =    0.90; // tWPRE      tCK   DQS Write Preamble
localparam TWPST            =    0.30; // tWPST      tCK   DQS Write Postamble
// Command and Address
localparam TZQCS            =      64; // tZQCS      tCK   ZQ Cal (Short) time
localparam TZQINIT          =     512; // tZQinit    tCK   ZQ Cal (Long) time
localparam TZQOPER          =     256; // tZQoper    tCK   ZQ Cal (Long) time
localparam TCCD             =       4; // tCCD       tCK   Cas to Cas command delay
localparam TCCD_DG          =       2; // tCCD_DG    tCK   Cas to Cas command delay to different group
localparam TRAS_MAX         =    60e9; // tRAS       ps    Maximum Active to Precharge command time
localparam TWR              =   15000; // tWR        ps    Write recovery time
localparam TMRD             =       4; // tMRD       tCK   Load Mode Register command cycle time
localparam TMOD             =   15000; // tMOD       ps    LOAD MODE to non-LOAD MODE command cycle time
localparam TMOD_TCK         =      12; // tMOD       tCK   LOAD MODE to non-LOAD MODE command cycle time
localparam TRRD_TCK         =       4; // tRRD       tCK   Active bank a to Active bank b command time
localparam TRRD_DG          =    3000; // tRRD_DG    ps     Active bank a to Active bank b command time to different group
localparam TRRD_DG_TCK      =       2; // tRRD_DG    tCK   Active bank a to Active bank b command time to different group
localparam TRTP             =    7500; // tRTP       ps    Read to Precharge command delay
localparam TRTP_TCK         =       4; // tRTP       tCK   Read to Precharge command delay
localparam TWTR             =    7500; // tWTR       ps    Write to Read command delay
localparam TWTR_DG          =    3750; // tWTR_DG    ps    Write to Read command delay to different group
localparam TWTR_TCK         =       4; // tWTR       tCK   Write to Read command delay
localparam TWTR_DG_TCK      =       2; // tWTR_DG    tCK   Write to Read command delay to different group
localparam TDLLK            =     512; // tDLLK      tCK   DLL locking time
// Refresh
localparam TRFC_MIN         = (MEM_TYPE == "1Gb") ? 110000 : 160000; // tRFC       ps    Refresh to Refresh Command interval minimum value
localparam TRFC_MAX         =70312500; // tRFC       ps    Refresh to Refresh Command Interval maximum value
// Power Down
localparam TXP_TCK          =       3; // tXP        tCK   Exit power down to a valid command
localparam TXPDLL           =   24000; // tXPDLL     ps    Exit precharge power down to READ or WRITE command (DLL-off mode)
localparam TXPDLL_TCK       =      10; // tXPDLL     tCK   Exit precharge power down to READ or WRITE command (DLL-off mode)
localparam TACTPDEN         =       1; // tACTPDEN   tCK   Timing of last ACT command to power down entry
localparam TPRPDEN          =       1; // tPREPDEN   tCK   Timing of last PRE command to power down entry
localparam TREFPDEN         =       1; // tARPDEN    tCK   Timing of last REFRESH command to power down entry
localparam TCPDED           =       1; // tCPDED     tCK   Command pass disable/enable delay
localparam TPD_MAX          = TRFC_MAX; // tPD        ps    Power-down entry-to-exit timing
localparam TXPR             = (MEM_TYPE == "1Gb") ? 120000 : 170000; // tXPR       ps    Exit Reset from CKE assertion to a valid command
localparam TXPR_TCK         =       5; // tXPR       tCK   Exit Reset from CKE assertion to a valid command
// Self Refresh
localparam TXS              = (MEM_TYPE == "1Gb") ? 120000 : 170000; // tXS        ps    Exit self refesh to a non-read or write command
localparam TXS_TCK          =       5; // tXS        tCK   Exit self refesh to a non-read or write command
localparam TXSDLL           =   TDLLK; // tXSRD      tCK   Exit self refresh to a read or write command
localparam TISXR            =     TIS; // tISXR      ps    CKE setup time during self refresh exit.
localparam TCKSRE           =   10000; // tCKSRE     ps    Valid Clock requirement after self refresh entry (SRE)
localparam TCKSRE_TCK       =       5; // tCKSRE     tCK   Valid Clock requirement after self refresh entry (SRE)
localparam TCKSRX           =   10000; // tCKSRX     ps    Valid Clock requirement prior to self refresh exit (SRX)
localparam TCKSRX_TCK       =       5; // tCKSRX     tCK   Valid Clock requirement prior to self refresh exit (SRX)
localparam TCKESR_TCK       =       4; // tCKESR     tCK   Minimum CKE low width for Self Refresh entry to exit timing
// ODT
localparam TAOF             =     0.7; // tAOF       tCK   RTT turn-off from ODTLoff reference
localparam TAONPD           =    8500; // tAONPD     ps    Asynchronous RTT turn-on delay (Power-Down with DLL frozen)
localparam TAOFPD           =    8500; // tAONPD     ps    Asynchronous RTT turn-off delay (Power-Down with DLL frozen)
localparam ODTH4            =       4; // ODTH4      tCK   ODT minimum HIGH time after ODT assertion or write (BL4)
localparam ODTH8            =       6; // ODTH8      tCK   ODT minimum HIGH time after write (BL8)
localparam TADC             =     0.7; // tADC       tCK   RTT dynamic change skew
// Write Levelization
localparam TWLMRD           =      40; // tWLMRD     tCK   First DQS pulse rising edge after tDQSS margining mode is programmed
localparam TWLDQSEN         =      25; // tWLDQSEN   tCK   DQS/DQS delay after tDQSS margining mode is programmed
localparam TWLOE            =    2000; // tWLOE      ps    Write levelization output error

// Size Parameters
localparam BA_BITS          =       3; // Set this parmaeter to control how many Bank Address bits are used
localparam MEM_BITS         =      10; // Set this parameter to control how many write data bursts can be stored in memory.  The default is 2^10=1024.
localparam AP               =      10; // the address bit that controls auto-precharge and precharge-all
localparam BC               =      12; // the address bit that controls burst chop
localparam BL_BITS          =       3; // the number of bits required to count to BL_MAX
localparam BO_BITS          =       2; // the number of Burst Order Bits

// Simulation parameters
localparam RZQ              =     240; // termination resistance
localparam PRE_DEF_PAT      =   8'hAA; // value returned during mpr pre-defined pattern readout
localparam STOP_ON_ERROR    =       1; // If set to 1, the model will halt on command sequence/major errors
localparam DEBUG            =       0; // Turn on Debug messages
localparam BUS_DELAY        =       0; // delay in nanoseconds
localparam RANDOM_OUT_DELAY =       0; // If set to 1, the model will put a random amount of delay on DQ/DQS during reads
localparam RANDOM_SEED      = 711689044; //seed value for random generator.

localparam RDQSEN_PRE       =       2; // DQS driving time prior to first read strobe
localparam RDQSEN_PST       =       1; // DQS driving time after last read strobe
localparam RDQS_PRE         =       2; // DQS low time prior to first read strobe
localparam RDQS_PST         =       1; // DQS low time after last read strobe
localparam RDQEN_PRE        =       0; // DQ/DM driving time prior to first read data
localparam RDQEN_PST        =       0; // DQ/DM driving time after last read data
localparam WDQS_PRE         =       2; // DQS half clock periods prior to first write strobe
localparam WDQS_PST         =       1; // DQS half clock periods after last write strobe

localparam FBY_TRC_DQS0     = FULL_FLY_BY_DEL * ((WRITE_LEVELING) ? 0.461 : 0);
localparam FBY_TRC_DQS1     = FULL_FLY_BY_DEL * ((WRITE_LEVELING) ? 0.077 : 0);
localparam FBY_TRC_DQS2     = FULL_FLY_BY_DEL * ((WRITE_LEVELING) ? 0.077 : 0);
localparam FBY_TRC_DQS3     = FULL_FLY_BY_DEL * ((WRITE_LEVELING) ? 0.077 : 0);

wire [1:0] rck              = ddr_clk;
wire [1:0] rck_n            = ddr_clk_n ;
wire [1:0] rcke             = ddr_cke;
wire [1:0] rs_n             = ddr_cs_n;
wire       rras_n           = ddr_ras_n;
wire       rcas_n           = ddr_cas_n;
wire       rwe_n            = ddr_we_n;
wire [2:0] rba              = ddr_ba;
wire [15:0] raddr           = ddr_ad;
wire [1:0] rodt             = ddr_odt;

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

assign #(FBY_TRC_DQS0)    rck_dev0    = rck;
assign #(FBY_TRC_DQS0)  rck_n_dev0    = rck_n;
assign #(FBY_TRC_DQS0)   rcke_dev0    = rcke;
assign #(FBY_TRC_DQS0)   rs_n_dev0    = rs_n;
assign #(FBY_TRC_DQS0) rras_n_dev0    = rras_n;
assign #(FBY_TRC_DQS0) rcas_n_dev0    = rcas_n;
assign #(FBY_TRC_DQS0)  rwe_n_dev0    = rwe_n;
assign #(FBY_TRC_DQS0)    rba_dev0    = rba;
assign #(FBY_TRC_DQS0)    rba_dev0_mr = {rba[2],rba[0],rba[1]};
assign #(FBY_TRC_DQS0)  raddr_dev0    = raddr;
assign #(FBY_TRC_DQS0)  raddr_dev0_mr = {raddr[ADDR_BITS-1:9],raddr[7],raddr[8],raddr[5],raddr[6],raddr[3],raddr[4],raddr[2:0]};
assign #(FBY_TRC_DQS0)   rodt_dev0    = rodt;

assign #(FBY_TRC_DQS1)    rck_dev1    =    rck_dev0;
assign #(FBY_TRC_DQS1)  rck_n_dev1    =  rck_n_dev0;
assign #(FBY_TRC_DQS1)   rcke_dev1    =   rcke_dev0;
assign #(FBY_TRC_DQS1)   rs_n_dev1    =   rs_n_dev0;
assign #(FBY_TRC_DQS1) rras_n_dev1    = rras_n_dev0;
assign #(FBY_TRC_DQS1) rcas_n_dev1    = rcas_n_dev0;
assign #(FBY_TRC_DQS1)  rwe_n_dev1    =  rwe_n_dev0;
assign #(FBY_TRC_DQS1)    rba_dev1    =    rba_dev0;
assign #(FBY_TRC_DQS1)    rba_dev1_mr =    rba_dev0_mr;
assign #(FBY_TRC_DQS1)  raddr_dev1    =  raddr_dev0;
assign #(FBY_TRC_DQS1)  raddr_dev1_mr =  raddr_dev0_mr;
assign #(FBY_TRC_DQS1)   rodt_dev1    =   rodt_dev0;

genvar i0;

if(MEM_CONFIG == "X8") begin : X8_CFG
    assign #(FBY_TRC_DQS2)    rck_dev2    =    rck_dev1;
    assign #(FBY_TRC_DQS2)  rck_n_dev2    =  rck_n_dev1;
    assign #(FBY_TRC_DQS2)   rcke_dev2    =   rcke_dev1;
    assign #(FBY_TRC_DQS2)   rs_n_dev2    =   rs_n_dev1;
    assign #(FBY_TRC_DQS2) rras_n_dev2    = rras_n_dev1;
    assign #(FBY_TRC_DQS2) rcas_n_dev2    = rcas_n_dev1;
    assign #(FBY_TRC_DQS2)  rwe_n_dev2    =  rwe_n_dev1;
    assign #(FBY_TRC_DQS2)    rba_dev2    =    rba_dev1;
    assign #(FBY_TRC_DQS2)    rba_dev2_mr =    rba_dev1_mr;
    assign #(FBY_TRC_DQS2)  raddr_dev2    =  raddr_dev1;
    assign #(FBY_TRC_DQS2)  raddr_dev2_mr =  raddr_dev1_mr;
    assign #(FBY_TRC_DQS2)   rodt_dev2    =   rodt_dev1;

    assign #(FBY_TRC_DQS3)    rck_dev3    =    rck_dev2;
    assign #(FBY_TRC_DQS3)  rck_n_dev3    =  rck_n_dev2;
    assign #(FBY_TRC_DQS3)   rcke_dev3    =   rcke_dev2;
    assign #(FBY_TRC_DQS3)   rs_n_dev3    =   rs_n_dev2;
    assign #(FBY_TRC_DQS3) rras_n_dev3    = rras_n_dev2;
    assign #(FBY_TRC_DQS3) rcas_n_dev3    = rcas_n_dev2;
    assign #(FBY_TRC_DQS3)  rwe_n_dev3    =  rwe_n_dev2;
    assign #(FBY_TRC_DQS3)    rba_dev3    =    rba_dev2;
    assign #(FBY_TRC_DQS3)    rba_dev3_mr =    rba_dev2_mr;
    assign #(FBY_TRC_DQS3)  raddr_dev3    =  raddr_dev2;
    assign #(FBY_TRC_DQS3)  raddr_dev3_mr =  raddr_dev2_mr;
    assign #(FBY_TRC_DQS3)   rodt_dev3    =   rodt_dev2;

    initial if (DEBUG) $display("%m: Component Width = x8"); 
    wire [3:0] rck_devN;
    wire [3:0] rck_n_devN;
    wire [3:0] rcke_devN;
    wire [3:0] rs_n_devN;
    wire [3:0] rras_n_devN;
    wire [3:0] rcas_n_devN;
    wire [3:0] rwe_n_devN;
    wire [3:0] rba_devN;
    wire [3:0] rodt_devN;

    assign rck_devN    = {rck_dev3[0]  , rck_dev2[0]  , rck_dev1[0]  , rck_dev0[0]};
    assign rck_n_devN  = {rck_n_dev3[0], rck_n_dev2[0], rck_n_dev1[0], rck_n_dev0[0]};
    assign rcke_devN   = {rcke_dev3[0] , rcke_dev2[0] , rcke_dev1[0] , rcke_dev0[0]};
    assign rs_n_devN   = {rs_n_dev3[0] , rs_n_dev2[0] , rs_n_dev1[0] , rs_n_dev0[0]};
    assign rras_n_devN = {rras_n_dev3  , rras_n_dev2  , rras_n_dev1  , rras_n_dev0};
    assign rcas_n_devN = {rcas_n_dev3  , rcas_n_dev2  , rcas_n_dev1  , rcas_n_dev0};
    assign rwe_n_devN  = {rwe_n_dev3   , rwe_n_dev2   , rwe_n_dev1   , rwe_n_dev0};
    assign rodt_devN   = {rodt_dev3[0],  rodt_dev2[0] , rodt_dev1[0] , rodt_dev0[0]};

    for(i0 = 0; i0 < (DDR_DATA_WIDTH/8); i0 = i0 + 1) begin : U_INST
        wire [ADDR_BITS-1:0] u_addr;
        wire [2:0]           u_rba_dev;
        assign u_addr    = (i0 == 0) ? raddr_dev0 :
                           (i0 == 1) ? raddr_dev1 :
                           (i0 == 2) ? raddr_dev2 :
                                       raddr_dev3;
        assign u_rba_dev = (i0 == 0) ? rba_dev0 :
                           (i0 == 1) ? rba_dev1 :
                           (i0 == 2) ? rba_dev2 :
                                       rba_dev3;
        lscc_ddr3 U0   (rst_n, rck_devN[i0], rck_n_devN[i0], rcke_devN[i0], rs_n_devN[i0], rras_n_devN[i0], rcas_n_devN[i0], rwe_n_devN[i0], ddr_dm_tdqs[i0], u_rba_dev, u_addr, ddr_dq[i0*8 +: 8], ddr_dqs[i0], ddr_dqs_n[i0],      , rodt_devN[i0]);

        defparam U0.TCK_MIN          = TCK_MIN;
        defparam U0.TJIT_PER         = TJIT_PER;            
        defparam U0.TJIT_CC          = TJIT_CC;
        defparam U0.TERR_2PER        = TERR_2PER;
        defparam U0.TERR_3PER        = TERR_3PER;
        defparam U0.TERR_4PER        = TERR_4PER;
        defparam U0.TERR_5PER        = TERR_5PER;
        defparam U0.TERR_6PER        = TERR_6PER;
        defparam U0.TERR_7PER        = TERR_7PER;
        defparam U0.TERR_8PER        = TERR_8PER;
        defparam U0.TERR_9PER        = TERR_9PER;
        defparam U0.TERR_10PER       = TERR_10PER;
        defparam U0.TERR_11PER       = TERR_11PER;
        defparam U0.TERR_12PER       = TERR_12PER;
        defparam U0.TDS              = TDS;
        defparam U0.TDH              = TDH;
        defparam U0.TDQSQ            = TDQSQ;
        defparam U0.TDQSS            = TDQSS;
        defparam U0.TDSS             = TDSS;
        defparam U0.TDSH             = TDSH;
        defparam U0.TDQSCK           = TDQSCK;
        defparam U0.TQSH             = TQSH;
        defparam U0.TQSL             = TQSL;
        defparam U0.TDIPW            = TDIPW;
        defparam U0.TIPW             = TIPW;
        defparam U0.TIS              = TIS;
        defparam U0.TIH              = TIH;
        defparam U0.TRAS_MIN         = TRAS_MIN;
        defparam U0.TRC              = TRC;
        defparam U0.TRCD             = TRCD;
        defparam U0.TRP              = TRP;
        defparam U0.TXP              = TXP;
        defparam U0.TCKE             = TCKE;
        defparam U0.TAON             = TAON;
	    						       			      
        defparam U0.TWLS             = TWLS;
        defparam U0.TWLH             = TWLH;
        defparam U0.TWLO             = TWLO;
        defparam U0.TAA_MIN          = TAA_MIN;
        defparam U0.CL_TIME          = CL_TIME;
	    						       			      
        defparam U0.TRRD             = TRRD;
        defparam U0.TFAW             = TFAW;
                                       
        // Mode Register             
        defparam U0.CL_MIN           = CL_MIN;
        defparam U0.CL_MAX           = CL_MAX;
        defparam U0.AL_MIN           = AL_MIN;
        defparam U0.AL_MAX           = AL_MAX;
        defparam U0.WR_MIN           = WR_MIN;
        defparam U0.WR_MAX           = WR_MAX;
        defparam U0.BL_MIN           = BL_MIN;
        defparam U0.BL_MAX           = BL_MAX;
        defparam U0.CWL_MIN          = CWL_MIN;
        defparam U0.CWL_MAX          = CWL_MAX;
	     						       			       
        // Clock                                           
        defparam U0.TCK_MAX          = TCK_MAX;
        defparam U0.TCH_AVG_MIN      = TCH_AVG_MIN;
        defparam U0.TCL_AVG_MIN      = TCL_AVG_MIN;
        defparam U0.TCH_AVG_MAX      = TCH_AVG_MAX;
        defparam U0.TCL_AVG_MAX      = TCL_AVG_MAX;
        defparam U0.TCH_ABS_MIN      = TCH_ABS_MIN;
        defparam U0.TCL_ABS_MIN      = TCL_ABS_MIN;
        defparam U0.TCKE_TCK         = TCKE_TCK;
        defparam U0.TAA_MAX          = TAA_MAX;
	     						       			       
        // Data OUT                                        
        defparam U0.TQH              = TQH;
        // Data Strobe OUT              
        defparam U0.TRPRE            = TRPRE;
        defparam U0.TRPST            = TRPST;
        // Data Strobe IN              
        defparam U0.TDQSH            = TDQSH;
        defparam U0.TDQSL            = TDQSL;
        defparam U0.TWPRE            = TWPRE;
        defparam U0.TWPST            = TWPST;
        // Command and Address          
        defparam U0.TZQCS            = TZQCS;
        defparam U0.TZQINIT          = TZQINIT;
        defparam U0.TZQOPER          = TZQOPER;
        defparam U0.TCCD             = TCCD;
        defparam U0.TCCD_DG          = TCCD_DG;
        defparam U0.TRAS_MAX         = TRAS_MAX;
        defparam U0.TWR              = TWR;
        defparam U0.TMRD             = TMRD;
        defparam U0.TMOD             = TMOD;
        defparam U0.TMOD_TCK         = TMOD_TCK;
        defparam U0.TRRD_TCK         = TRRD_TCK;
        defparam U0.TRRD_DG          = TRRD_DG;
        defparam U0.TRRD_DG_TCK      = TRRD_DG_TCK;
        defparam U0.TRTP             = TRTP;
        defparam U0.TRTP_TCK         = TRTP_TCK;
        defparam U0.TWTR             = TWTR;
        defparam U0.TWTR_DG          = TWTR_DG;
        defparam U0.TWTR_TCK         = TWTR_TCK;
        defparam U0.TWTR_DG_TCK      = TWTR_DG_TCK;
        defparam U0.TDLLK            = TDLLK;
        // Refresh - 1Gb               
        defparam U0.TRFC_MIN         = TRFC_MIN;
        defparam U0.TRFC_MAX         = TRFC_MAX;
        // Power Down                  
        defparam U0.TXP_TCK          = TXP_TCK;
        defparam U0.TXPDLL           = TXPDLL;
        defparam U0.TXPDLL_TCK       = TXPDLL_TCK;
        defparam U0.TACTPDEN         = TACTPDEN;
        defparam U0.TPRPDEN          = TPRPDEN;
        defparam U0.TREFPDEN         = TREFPDEN;
        defparam U0.TCPDED           = TCPDED;
        defparam U0.TXPR             = TXPR;
        defparam U0.TXPR_TCK         = TXPR_TCK;
        // Self Refresh                
        defparam U0.TXS              = TXS;
        defparam U0.TXS_TCK          = TXS_TCK;
        defparam U0.TCKSRE           = TCKSRE;
        defparam U0.TCKSRE_TCK       = TCKSRE_TCK;
        defparam U0.TCKSRX           = TCKSRX;
        defparam U0.TCKSRX_TCK       = TCKSRX_TCK;
        defparam U0.TCKESR_TCK       = TCKESR_TCK;
        // ODT                                             
        defparam U0.TAOF             = TAOF;
        defparam U0.TAONPD           = TAONPD;
        defparam U0.TAOFPD           = TAOFPD;
        defparam U0.ODTH4            = ODTH4;
        defparam U0.ODTH8            = ODTH8;
        defparam U0.TADC             = TADC;
        // Write Levelization          
        defparam U0.TWLMRD           = TWLMRD;
        defparam U0.TWLDQSEN         = TWLDQSEN;
        defparam U0.TWLOE            = TWLOE;
        defparam U0.AP               = AP;
        defparam U0.BC               = BC;
                                         
        defparam U0.RDQSEN_PRE       = RDQSEN_PRE;
        defparam U0.RDQSEN_PST       = RDQSEN_PST;
        defparam U0.RDQS_PRE         = RDQS_PRE;
        defparam U0.RDQS_PST         = RDQS_PST;
        defparam U0.RDQEN_PRE        = RDQEN_PRE;
        defparam U0.RDQEN_PST        = RDQEN_PST;
        defparam U0.WDQS_PRE         = WDQS_PRE;
        defparam U0.WDQS_PST         = WDQS_PST;
        defparam U0.RANDOM_OUT_DELAY = RANDOM_OUT_DELAY;
                                       
        defparam U0.DQ_BITS          = DQ_BITS;
        defparam U0.DQS_BITS         = DQS_BITS;
        defparam U0.BA_BITS          = BA_BITS;
        defparam U0.ROW_BITS         = ROW_BITS;
        defparam U0.COL_BITS         = COL_BITS;
        defparam U0.BL_BITS          = BL_BITS;
        defparam U0.MEM_BITS         = MEM_BITS;
        defparam U0.ADDR_BITS        = ADDR_BITS;
        defparam U0.DM_BITS          = DM_BITS;
        defparam U0.MAX_MEM          = MAX_MEM;
        defparam U0.BO_BITS          = BO_BITS;
        defparam U0.BUS_DELAY        = BUS_DELAY;
        defparam U0.DIFF             = DIFF;
        defparam U0.RANDOM_SEED      = RANDOM_SEED;
        defparam U0.RZQ              = RZQ;
        defparam U0.STOP_ON_ERROR    = STOP_ON_ERROR;
        defparam U0.MPR_DQ0          = MPR_DQ0;
        defparam U0.DEBUG            = DEBUG;
        defparam U0.WL_ALLDQ         = WL_ALLDQ;
        defparam U0.GEARING          = GEARING;
    end
    if(DDR_CS_WIDTH == 2) begin : CS_WID_2

        wire [3:0] rck1_devN;
        wire [3:0] rck1_n_devN;
        wire [3:0] rcke1_devN;
        wire [3:0] rs1_n_devN;
        wire [3:0] rodt1_devN;

        assign rck1_devN    = {rck_dev3[1]  , rck_dev2[1]  , rck_dev1[1]  , rck_dev0[1]};
        assign rck1_n_devN  = {rck_n_dev3[1], rck_n_dev2[1], rck_n_dev1[1], rck_n_dev0[1]};
        assign rcke1_devN   = {rcke_dev3[1] , rcke_dev2[1] , rcke_dev1[1] , rcke_dev0[1]};
        assign rs1_n_devN   = {rs_n_dev3[1] , rs_n_dev2[1] , rs_n_dev1[1] , rs_n_dev0[1]};
        assign rodt1_devN   = {rodt_dev3[1],  rodt_dev2[1] , rodt_dev1[1] , rodt_dev0[1]};

        for(i0 = 0; i0 < (DDR_DATA_WIDTH/8); i0 = i0 + 1) begin : UT_INST
            wire [ADDR_BITS-1:0] u_addr;
            wire [2:0]           u_rba_dev;
            assign u_addr    = (i0 == 0) ? raddr_dev0 :
                               (i0 == 1) ? raddr_dev1 :
                               (i0 == 2) ? raddr_dev2 :
                                           raddr_dev3;
            assign u_rba_dev = (i0 == 0) ? rba_dev0 :
                               (i0 == 1) ? rba_dev1 :
                               (i0 == 2) ? rba_dev2 :
                                           rba_dev3;
            lscc_ddr3 UT0 (rst_n, rck1_devN[i0], rck1_n_devN[i0], rcke1_devN[i0], rs1_n_devN[i0], rras_n_devN[i0], rcas_n_devN[i0], rwe_n_devN[i0], ddr_dm_tdqs[i0], u_rba_dev, u_addr, ddr_dq[i0*8 +: 8], ddr_dqs[i0], ddr_dqs_n[i0],      , rodt1_devN[i0]);
	    
            defparam UT0.TCK_MIN          = TCK_MIN;
            defparam UT0.TJIT_PER         = TJIT_PER;            
            defparam UT0.TJIT_CC          = TJIT_CC;
            defparam UT0.TERR_2PER        = TERR_2PER;
            defparam UT0.TERR_3PER        = TERR_3PER;
            defparam UT0.TERR_4PER        = TERR_4PER;
            defparam UT0.TERR_5PER        = TERR_5PER;
            defparam UT0.TERR_6PER        = TERR_6PER;
            defparam UT0.TERR_7PER        = TERR_7PER;
            defparam UT0.TERR_8PER        = TERR_8PER;
            defparam UT0.TERR_9PER        = TERR_9PER;
            defparam UT0.TERR_10PER       = TERR_10PER;
            defparam UT0.TERR_11PER       = TERR_11PER;
            defparam UT0.TERR_12PER       = TERR_12PER;
            defparam UT0.TDS              = TDS;
            defparam UT0.TDH              = TDH;
            defparam UT0.TDQSQ            = TDQSQ;
            defparam UT0.TDQSS            = TDQSS;
            defparam UT0.TDSS             = TDSS;
            defparam UT0.TDSH             = TDSH;
            defparam UT0.TDQSCK           = TDQSCK;
            defparam UT0.TQSH             = TQSH;
            defparam UT0.TQSL             = TQSL;
            defparam UT0.TDIPW            = TDIPW;
            defparam UT0.TIPW             = TIPW;
            defparam UT0.TIS              = TIS;
            defparam UT0.TIH              = TIH;
            defparam UT0.TRAS_MIN         = TRAS_MIN;
            defparam UT0.TRC              = TRC;
            defparam UT0.TRCD             = TRCD;
            defparam UT0.TRP              = TRP;
            defparam UT0.TXP              = TXP;
            defparam UT0.TCKE             = TCKE;
            defparam UT0.TAON             = TAON;
	        						       			      
            defparam UT0.TWLS             = TWLS;
            defparam UT0.TWLH             = TWLH;
            defparam UT0.TWLO             = TWLO;
            defparam UT0.TAA_MIN          = TAA_MIN;
            defparam UT0.CL_TIME          = CL_TIME;
	        						       			      
            defparam UT0.TRRD             = TRRD;
            defparam UT0.TFAW             = TFAW;
                                           
            // Mode Register             
            defparam UT0.CL_MIN           = CL_MIN;
            defparam UT0.CL_MAX           = CL_MAX;
            defparam UT0.AL_MIN           = AL_MIN;
            defparam UT0.AL_MAX           = AL_MAX;
            defparam UT0.WR_MIN           = WR_MIN;
            defparam UT0.WR_MAX           = WR_MAX;
            defparam UT0.BL_MIN           = BL_MIN;
            defparam UT0.BL_MAX           = BL_MAX;
            defparam UT0.CWL_MIN          = CWL_MIN;
            defparam UT0.CWL_MAX          = CWL_MAX;
	         						       			       
            // Clock                                           
            defparam UT0.TCK_MAX          = TCK_MAX;
            defparam UT0.TCH_AVG_MIN      = TCH_AVG_MIN;
            defparam UT0.TCL_AVG_MIN      = TCL_AVG_MIN;
            defparam UT0.TCH_AVG_MAX      = TCH_AVG_MAX;
            defparam UT0.TCL_AVG_MAX      = TCL_AVG_MAX;
            defparam UT0.TCH_ABS_MIN      = TCH_ABS_MIN;
            defparam UT0.TCL_ABS_MIN      = TCL_ABS_MIN;
            defparam UT0.TCKE_TCK         = TCKE_TCK;
            defparam UT0.TAA_MAX          = TAA_MAX;
	         						       			       
            // Data OUT                                        
            defparam UT0.TQH              = TQH;
            // Data Strobe OUT              
            defparam UT0.TRPRE            = TRPRE;
            defparam UT0.TRPST            = TRPST;
            // Data Strobe IN              
            defparam UT0.TDQSH            = TDQSH;
            defparam UT0.TDQSL            = TDQSL;
            defparam UT0.TWPRE            = TWPRE;
            defparam UT0.TWPST            = TWPST;
            // Command and Address          
            defparam UT0.TZQCS            = TZQCS;
            defparam UT0.TZQINIT          = TZQINIT;
            defparam UT0.TZQOPER          = TZQOPER;
            defparam UT0.TCCD             = TCCD;
            defparam UT0.TCCD_DG          = TCCD_DG;
            defparam UT0.TRAS_MAX         = TRAS_MAX;
            defparam UT0.TWR              = TWR;
            defparam UT0.TMRD             = TMRD;
            defparam UT0.TMOD             = TMOD;
            defparam UT0.TMOD_TCK         = TMOD_TCK;
            defparam UT0.TRRD_TCK         = TRRD_TCK;
            defparam UT0.TRRD_DG          = TRRD_DG;
            defparam UT0.TRRD_DG_TCK      = TRRD_DG_TCK;
            defparam UT0.TRTP             = TRTP;
            defparam UT0.TRTP_TCK         = TRTP_TCK;
            defparam UT0.TWTR             = TWTR;
            defparam UT0.TWTR_DG          = TWTR_DG;
            defparam UT0.TWTR_TCK         = TWTR_TCK;
            defparam UT0.TWTR_DG_TCK      = TWTR_DG_TCK;
            defparam UT0.TDLLK            = TDLLK;
            // Refresh - 1Gb               
            defparam UT0.TRFC_MIN         = TRFC_MIN;
            defparam UT0.TRFC_MAX         = TRFC_MAX;
            // Power Down                  
            defparam UT0.TXP_TCK          = TXP_TCK;
            defparam UT0.TXPDLL           = TXPDLL;
            defparam UT0.TXPDLL_TCK       = TXPDLL_TCK;
            defparam UT0.TACTPDEN         = TACTPDEN;
            defparam UT0.TPRPDEN          = TPRPDEN;
            defparam UT0.TREFPDEN         = TREFPDEN;
            defparam UT0.TCPDED           = TCPDED;
            defparam UT0.TXPR             = TXPR;
            defparam UT0.TXPR_TCK         = TXPR_TCK;
            // Self Refresh                
            defparam UT0.TXS              = TXS;
            defparam UT0.TXS_TCK          = TXS_TCK;
            defparam UT0.TCKSRE           = TCKSRE;
            defparam UT0.TCKSRE_TCK       = TCKSRE_TCK;
            defparam UT0.TCKSRX           = TCKSRX;
            defparam UT0.TCKSRX_TCK       = TCKSRX_TCK;
            defparam UT0.TCKESR_TCK       = TCKESR_TCK;
            // ODT                                             
            defparam UT0.TAOF             = TAOF;
            defparam UT0.TAONPD           = TAONPD;
            defparam UT0.TAOFPD           = TAOFPD;
            defparam UT0.ODTH4            = ODTH4;
            defparam UT0.ODTH8            = ODTH8;
            defparam UT0.TADC             = TADC;
            // Write Levelization          
            defparam UT0.TWLMRD           = TWLMRD;
            defparam UT0.TWLDQSEN         = TWLDQSEN;
            defparam UT0.TWLOE            = TWLOE;
            defparam UT0.AP               = AP;
            defparam UT0.BC               = BC;
                                             
            defparam UT0.RDQSEN_PRE       = RDQSEN_PRE;
            defparam UT0.RDQSEN_PST       = RDQSEN_PST;
            defparam UT0.RDQS_PRE         = RDQS_PRE;
            defparam UT0.RDQS_PST         = RDQS_PST;
            defparam UT0.RDQEN_PRE        = RDQEN_PRE;
            defparam UT0.RDQEN_PST        = RDQEN_PST;
            defparam UT0.WDQS_PRE         = WDQS_PRE;
            defparam UT0.WDQS_PST         = WDQS_PST;
            defparam UT0.RANDOM_OUT_DELAY = RANDOM_OUT_DELAY;
                                           
            defparam UT0.DQ_BITS          = DQ_BITS;
            defparam UT0.DQS_BITS         = DQS_BITS;
            defparam UT0.BA_BITS          = BA_BITS;
            defparam UT0.ROW_BITS         = ROW_BITS;
            defparam UT0.COL_BITS         = COL_BITS;
            defparam UT0.BL_BITS          = BL_BITS;
            defparam UT0.MEM_BITS         = MEM_BITS;
            defparam UT0.ADDR_BITS        = ADDR_BITS;
            defparam UT0.DM_BITS          = DM_BITS;
            defparam UT0.MAX_MEM          = MAX_MEM;
            defparam UT0.BO_BITS          = BO_BITS;
            defparam UT0.BUS_DELAY        = BUS_DELAY;
            defparam UT0.DIFF             = DIFF;
            defparam UT0.RANDOM_SEED      = RANDOM_SEED;
            defparam UT0.RZQ              = RZQ;
            defparam UT0.STOP_ON_ERROR    = STOP_ON_ERROR;
            defparam UT0.MPR_DQ0          = MPR_DQ0;
            defparam UT0.DEBUG            = DEBUG;
            defparam UT0.WL_ALLDQ         = WL_ALLDQ;
            defparam UT0.GEARING          = GEARING;
        end
    end
end
else begin : X16_CFG
    initial if (DEBUG) $display("%m: Component Width = x16");
    lscc_ddr3 U0   (rst_n, rck_dev0[0], rck_n_dev0[0], rcke_dev0[0], rs_n_dev0[0], rras_n_dev0, rcas_n_dev0, rwe_n_dev0, ddr_dm_tdqs[1:0], rba_dev0, raddr_dev0[ADDR_BITS-1:0], ddr_dq[15:0], ddr_dqs[1:0], ddr_dqs_n[1:0],  , rodt_dev0[0]);

    defparam U0.TCK_MIN          = TCK_MIN;
    defparam U0.TJIT_PER         = TJIT_PER;            
    defparam U0.TJIT_CC          = TJIT_CC;
    defparam U0.TERR_2PER        = TERR_2PER;
    defparam U0.TERR_3PER        = TERR_3PER;
    defparam U0.TERR_4PER        = TERR_4PER;
    defparam U0.TERR_5PER        = TERR_5PER;
    defparam U0.TERR_6PER        = TERR_6PER;
    defparam U0.TERR_7PER        = TERR_7PER;
    defparam U0.TERR_8PER        = TERR_8PER;
    defparam U0.TERR_9PER        = TERR_9PER;
    defparam U0.TERR_10PER       = TERR_10PER;
    defparam U0.TERR_11PER       = TERR_11PER;
    defparam U0.TERR_12PER       = TERR_12PER;
    defparam U0.TDS              = TDS;
    defparam U0.TDH              = TDH;
    defparam U0.TDQSQ            = TDQSQ;
    defparam U0.TDQSS            = TDQSS;
    defparam U0.TDSS             = TDSS;
    defparam U0.TDSH             = TDSH;
    defparam U0.TDQSCK           = TDQSCK;
    defparam U0.TQSH             = TQSH;
    defparam U0.TQSL             = TQSL;
    defparam U0.TDIPW            = TDIPW;
    defparam U0.TIPW             = TIPW;
    defparam U0.TIS              = TIS;
    defparam U0.TIH              = TIH;
    defparam U0.TRAS_MIN         = TRAS_MIN;
    defparam U0.TRC              = TRC;
    defparam U0.TRCD             = TRCD;
    defparam U0.TRP              = TRP;
    defparam U0.TXP              = TXP;
    defparam U0.TCKE             = TCKE;
    defparam U0.TAON             = TAON;
    						       			      
    defparam U0.TWLS             = TWLS;
    defparam U0.TWLH             = TWLH;
    defparam U0.TWLO             = TWLO;
    defparam U0.TAA_MIN          = TAA_MIN;
    defparam U0.CL_TIME          = CL_TIME;
    						       			      
    defparam U0.TRRD             = TRRD;
    defparam U0.TFAW             = TFAW;
                                   
    // Mode Register             
    defparam U0.CL_MIN           = CL_MIN;
    defparam U0.CL_MAX           = CL_MAX;
    defparam U0.AL_MIN           = AL_MIN;
    defparam U0.AL_MAX           = AL_MAX;
    defparam U0.WR_MIN           = WR_MIN;
    defparam U0.WR_MAX           = WR_MAX;
    defparam U0.BL_MIN           = BL_MIN;
    defparam U0.BL_MAX           = BL_MAX;
    defparam U0.CWL_MIN          = CWL_MIN;
    defparam U0.CWL_MAX          = CWL_MAX;
     						       			       
    // Clock                                           
    defparam U0.TCK_MAX          = TCK_MAX;
    defparam U0.TCH_AVG_MIN      = TCH_AVG_MIN;
    defparam U0.TCL_AVG_MIN      = TCL_AVG_MIN;
    defparam U0.TCH_AVG_MAX      = TCH_AVG_MAX;
    defparam U0.TCL_AVG_MAX      = TCL_AVG_MAX;
    defparam U0.TCH_ABS_MIN      = TCH_ABS_MIN;
    defparam U0.TCL_ABS_MIN      = TCL_ABS_MIN;
    defparam U0.TCKE_TCK         = TCKE_TCK;
    defparam U0.TAA_MAX          = TAA_MAX;
     						       			       
    // Data OUT                                        
    defparam U0.TQH              = TQH;
    // Data Strobe OUT              
    defparam U0.TRPRE            = TRPRE;
    defparam U0.TRPST            = TRPST;
    // Data Strobe IN              
    defparam U0.TDQSH            = TDQSH;
    defparam U0.TDQSL            = TDQSL;
    defparam U0.TWPRE            = TWPRE;
    defparam U0.TWPST            = TWPST;
    // Command and Address          
    defparam U0.TZQCS            = TZQCS;
    defparam U0.TZQINIT          = TZQINIT;
    defparam U0.TZQOPER          = TZQOPER;
    defparam U0.TCCD             = TCCD;
    defparam U0.TCCD_DG          = TCCD_DG;
    defparam U0.TRAS_MAX         = TRAS_MAX;
    defparam U0.TWR              = TWR;
    defparam U0.TMRD             = TMRD;
    defparam U0.TMOD             = TMOD;
    defparam U0.TMOD_TCK         = TMOD_TCK;
    defparam U0.TRRD_TCK         = TRRD_TCK;
    defparam U0.TRRD_DG          = TRRD_DG;
    defparam U0.TRRD_DG_TCK      = TRRD_DG_TCK;
    defparam U0.TRTP             = TRTP;
    defparam U0.TRTP_TCK         = TRTP_TCK;
    defparam U0.TWTR             = TWTR;
    defparam U0.TWTR_DG          = TWTR_DG;
    defparam U0.TWTR_TCK         = TWTR_TCK;
    defparam U0.TWTR_DG_TCK      = TWTR_DG_TCK;
    defparam U0.TDLLK            = TDLLK;
    // Refresh - 1Gb               
    defparam U0.TRFC_MIN         = TRFC_MIN;
    defparam U0.TRFC_MAX         = TRFC_MAX;
    // Power Down                  
    defparam U0.TXP_TCK          = TXP_TCK;
    defparam U0.TXPDLL           = TXPDLL;
    defparam U0.TXPDLL_TCK       = TXPDLL_TCK;
    defparam U0.TACTPDEN         = TACTPDEN;
    defparam U0.TPRPDEN          = TPRPDEN;
    defparam U0.TREFPDEN         = TREFPDEN;
    defparam U0.TCPDED           = TCPDED;
    defparam U0.TXPR             = TXPR;
    defparam U0.TXPR_TCK         = TXPR_TCK;
    // Self Refresh                
    defparam U0.TXS              = TXS;
    defparam U0.TXS_TCK          = TXS_TCK;
    defparam U0.TCKSRE           = TCKSRE;
    defparam U0.TCKSRE_TCK       = TCKSRE_TCK;
    defparam U0.TCKSRX           = TCKSRX;
    defparam U0.TCKSRX_TCK       = TCKSRX_TCK;
    defparam U0.TCKESR_TCK       = TCKESR_TCK;
    // ODT                                             
    defparam U0.TAOF             = TAOF;
    defparam U0.TAONPD           = TAONPD;
    defparam U0.TAOFPD           = TAOFPD;
    defparam U0.ODTH4            = ODTH4;
    defparam U0.ODTH8            = ODTH8;
    defparam U0.TADC             = TADC;
    // Write Levelization          
    defparam U0.TWLMRD           = TWLMRD;
    defparam U0.TWLDQSEN         = TWLDQSEN;
    defparam U0.TWLOE            = TWLOE;
    defparam U0.AP               = AP;
    defparam U0.BC               = BC;
                                     
    defparam U0.RDQSEN_PRE       = RDQSEN_PRE;
    defparam U0.RDQSEN_PST       = RDQSEN_PST;
    defparam U0.RDQS_PRE         = RDQS_PRE;
    defparam U0.RDQS_PST         = RDQS_PST;
    defparam U0.RDQEN_PRE        = RDQEN_PRE;
    defparam U0.RDQEN_PST        = RDQEN_PST;
    defparam U0.WDQS_PRE         = WDQS_PRE;
    defparam U0.WDQS_PST         = WDQS_PST;
    defparam U0.RANDOM_OUT_DELAY = RANDOM_OUT_DELAY;
                                   
    defparam U0.DQ_BITS          = DQ_BITS;
    defparam U0.DQS_BITS         = DQS_BITS;
    defparam U0.BA_BITS          = BA_BITS;
    defparam U0.ROW_BITS         = ROW_BITS;
    defparam U0.COL_BITS         = COL_BITS;
    defparam U0.BL_BITS          = BL_BITS;
    defparam U0.MEM_BITS         = MEM_BITS;
    defparam U0.ADDR_BITS        = ADDR_BITS;
    defparam U0.DM_BITS          = DM_BITS;
    defparam U0.MAX_MEM          = MAX_MEM;
    defparam U0.BO_BITS          = BO_BITS;
    defparam U0.BUS_DELAY        = BUS_DELAY;
    defparam U0.DIFF             = DIFF;
    defparam U0.RANDOM_SEED      = RANDOM_SEED;
    defparam U0.RZQ              = RZQ;
    defparam U0.STOP_ON_ERROR    = STOP_ON_ERROR;
    defparam U0.MPR_DQ0          = MPR_DQ0;
    defparam U0.DEBUG            = DEBUG;
    defparam U0.WL_ALLDQ         = WL_ALLDQ;
    defparam U0.GEARING          = GEARING;

    if(DDR_DATA_WIDTH > 16) begin : DWID_EXT
/*        wire [1:0]  ddr24_dm_tdqs;
        wire [15:0] ddr24_dq;
        wire [1:0]  ddr24_dqs;
        wire [1:0]  ddr24_dqs_n;

        assign ddr24_dm_tdqs = (DDR_DATA_WIDTH == 24) ? {ddr_dm_tdqs[2], ddr_dm_tdqs[2]} : ddr_dm_tdqs[3:2];
        assign ddr24_dq      = (DDR_DATA_WIDTH == 24) ? ((ddr_dq[23:16] == {8{1'bz}})  ? {16{1'bz}} : {ddr_dq[23:16], ddr_dq[23:16]})
                                                      : ((ddr_dq[31:16] == {16{1'bz}}) ? {16{1'bz}} : ddr_dq[31:16]);
        assign ddr24_dqs     = (DDR_DATA_WIDTH == 24) ? ((ddr_dqs[2] == 1'bz) ? 2'bzz : {ddr_dqs[2], ddr_dqs[2]})
                                                      : ((ddr_dqs[3:2] == 2'bzz) ? 2'bzz : ddr_dqs[3:2]);
        assign ddr24_dqs_n   = ~ddr24_dqs;*/
        lscc_ddr3 U1   (rst_n, rck_dev1[0], rck_n_dev1[0], rcke_dev1[0], rs_n_dev1[0], rras_n_dev1, rcas_n_dev1, rwe_n_dev1, ddr_dm_tdqs[3:2], rba_dev1, raddr_dev1[ADDR_BITS-1:0], ddr_dq[31:16], ddr_dqs[3:2], ddr_dqs_n[3:2],  , rodt_dev1[0]);
//        lscc_ddr3 U1   (rst_n, rck_dev1[0], rck_n_dev1[0], rcke_dev1[0], rs_n_dev1[0], rras_n_dev1, rcas_n_dev1, rwe_n_dev1, ddr24_dm_tdqs, rba_dev1, raddr_dev1[ADDR_BITS-1:0], ddr24_dq, ddr24_dqs, ddr24_dqs_n,  , rodt_dev1[0]);

        defparam U1.TCK_MIN          = TCK_MIN;
        defparam U1.TJIT_PER         = TJIT_PER;            
        defparam U1.TJIT_CC          = TJIT_CC;
        defparam U1.TERR_2PER        = TERR_2PER;
        defparam U1.TERR_3PER        = TERR_3PER;
        defparam U1.TERR_4PER        = TERR_4PER;
        defparam U1.TERR_5PER        = TERR_5PER;
        defparam U1.TERR_6PER        = TERR_6PER;
        defparam U1.TERR_7PER        = TERR_7PER;
        defparam U1.TERR_8PER        = TERR_8PER;
        defparam U1.TERR_9PER        = TERR_9PER;
        defparam U1.TERR_10PER       = TERR_10PER;
        defparam U1.TERR_11PER       = TERR_11PER;
        defparam U1.TERR_12PER       = TERR_12PER;
        defparam U1.TDS              = TDS;
        defparam U1.TDH              = TDH;
        defparam U1.TDQSQ            = TDQSQ;
        defparam U1.TDQSS            = TDQSS;
        defparam U1.TDSS             = TDSS;
        defparam U1.TDSH             = TDSH;
        defparam U1.TDQSCK           = TDQSCK;
        defparam U1.TQSH             = TQSH;
        defparam U1.TQSL             = TQSL;
        defparam U1.TDIPW            = TDIPW;
        defparam U1.TIPW             = TIPW;
        defparam U1.TIS              = TIS;
        defparam U1.TIH              = TIH;
        defparam U1.TRAS_MIN         = TRAS_MIN;
        defparam U1.TRC              = TRC;
        defparam U1.TRCD             = TRCD;
        defparam U1.TRP              = TRP;
        defparam U1.TXP              = TXP;
        defparam U1.TCKE             = TCKE;
        defparam U1.TAON             = TAON;
        						       			      
        defparam U1.TWLS             = TWLS;
        defparam U1.TWLH             = TWLH;
        defparam U1.TWLO             = TWLO;
        defparam U1.TAA_MIN          = TAA_MIN;
        defparam U1.CL_TIME          = CL_TIME;
        						       			      
        defparam U1.TRRD             = TRRD;
        defparam U1.TFAW             = TFAW;
                                       
        // Mode Register             
        defparam U1.CL_MIN           = CL_MIN;
        defparam U1.CL_MAX           = CL_MAX;
        defparam U1.AL_MIN           = AL_MIN;
        defparam U1.AL_MAX           = AL_MAX;
        defparam U1.WR_MIN           = WR_MIN;
        defparam U1.WR_MAX           = WR_MAX;
        defparam U1.BL_MIN           = BL_MIN;
        defparam U1.BL_MAX           = BL_MAX;
        defparam U1.CWL_MIN          = CWL_MIN;
        defparam U1.CWL_MAX          = CWL_MAX;
         						       			       
        // Clock                                           
        defparam U1.TCK_MAX          = TCK_MAX;
        defparam U1.TCH_AVG_MIN      = TCH_AVG_MIN;
        defparam U1.TCL_AVG_MIN      = TCL_AVG_MIN;
        defparam U1.TCH_AVG_MAX      = TCH_AVG_MAX;
        defparam U1.TCL_AVG_MAX      = TCL_AVG_MAX;
        defparam U1.TCH_ABS_MIN      = TCH_ABS_MIN;
        defparam U1.TCL_ABS_MIN      = TCL_ABS_MIN;
        defparam U1.TCKE_TCK         = TCKE_TCK;
        defparam U1.TAA_MAX          = TAA_MAX;
         						       			       
        // Data OUT                                        
        defparam U1.TQH              = TQH;
        // Data Strobe OUT              
        defparam U1.TRPRE            = TRPRE;
        defparam U1.TRPST            = TRPST;
        // Data Strobe IN              
        defparam U1.TDQSH            = TDQSH;
        defparam U1.TDQSL            = TDQSL;
        defparam U1.TWPRE            = TWPRE;
        defparam U1.TWPST            = TWPST;
        // Command and Address          
        defparam U1.TZQCS            = TZQCS;
        defparam U1.TZQINIT          = TZQINIT;
        defparam U1.TZQOPER          = TZQOPER;
        defparam U1.TCCD             = TCCD;
        defparam U1.TCCD_DG          = TCCD_DG;
        defparam U1.TRAS_MAX         = TRAS_MAX;
        defparam U1.TWR              = TWR;
        defparam U1.TMRD             = TMRD;
        defparam U1.TMOD             = TMOD;
        defparam U1.TMOD_TCK         = TMOD_TCK;
        defparam U1.TRRD_TCK         = TRRD_TCK;
        defparam U1.TRRD_DG          = TRRD_DG;
        defparam U1.TRRD_DG_TCK      = TRRD_DG_TCK;
        defparam U1.TRTP             = TRTP;
        defparam U1.TRTP_TCK         = TRTP_TCK;
        defparam U1.TWTR             = TWTR;
        defparam U1.TWTR_DG          = TWTR_DG;
        defparam U1.TWTR_TCK         = TWTR_TCK;
        defparam U1.TWTR_DG_TCK      = TWTR_DG_TCK;
        defparam U1.TDLLK            = TDLLK;
        // Refresh - 1Gb               
        defparam U1.TRFC_MIN         = TRFC_MIN;
        defparam U1.TRFC_MAX         = TRFC_MAX;
        // Power Down                  
        defparam U1.TXP_TCK          = TXP_TCK;
        defparam U1.TXPDLL           = TXPDLL;
        defparam U1.TXPDLL_TCK       = TXPDLL_TCK;
        defparam U1.TACTPDEN         = TACTPDEN;
        defparam U1.TPRPDEN          = TPRPDEN;
        defparam U1.TREFPDEN         = TREFPDEN;
        defparam U1.TCPDED           = TCPDED;
        defparam U1.TXPR             = TXPR;
        defparam U1.TXPR_TCK         = TXPR_TCK;
        // Self Refresh                
        defparam U1.TXS              = TXS;
        defparam U1.TXS_TCK          = TXS_TCK;
        defparam U1.TCKSRE           = TCKSRE;
        defparam U1.TCKSRE_TCK       = TCKSRE_TCK;
        defparam U1.TCKSRX           = TCKSRX;
        defparam U1.TCKSRX_TCK       = TCKSRX_TCK;
        defparam U1.TCKESR_TCK       = TCKESR_TCK;
        // ODT                                             
        defparam U1.TAOF             = TAOF;
        defparam U1.TAONPD           = TAONPD;
        defparam U1.TAOFPD           = TAOFPD;
        defparam U1.ODTH4            = ODTH4;
        defparam U1.ODTH8            = ODTH8;
        defparam U1.TADC             = TADC;
        // Write Levelization          
        defparam U1.TWLMRD           = TWLMRD;
        defparam U1.TWLDQSEN         = TWLDQSEN;
        defparam U1.TWLOE            = TWLOE;
        defparam U1.AP               = AP;
        defparam U1.BC               = BC;
                                         
        defparam U1.RDQSEN_PRE       = RDQSEN_PRE;
        defparam U1.RDQSEN_PST       = RDQSEN_PST;
        defparam U1.RDQS_PRE         = RDQS_PRE;
        defparam U1.RDQS_PST         = RDQS_PST;
        defparam U1.RDQEN_PRE        = RDQEN_PRE;
        defparam U1.RDQEN_PST        = RDQEN_PST;
        defparam U1.WDQS_PRE         = WDQS_PRE;
        defparam U1.WDQS_PST         = WDQS_PST;
        defparam U1.RANDOM_OUT_DELAY = RANDOM_OUT_DELAY;
                                       
        defparam U1.DQ_BITS          = DQ_BITS;
        defparam U1.DQS_BITS         = DQS_BITS;
        defparam U1.BA_BITS          = BA_BITS;
        defparam U1.ROW_BITS         = ROW_BITS;
        defparam U1.COL_BITS         = COL_BITS;
        defparam U1.BL_BITS          = BL_BITS;
        defparam U1.MEM_BITS         = MEM_BITS;
        defparam U1.ADDR_BITS        = ADDR_BITS;
        defparam U1.DM_BITS          = DM_BITS;
        defparam U1.MAX_MEM          = MAX_MEM;
        defparam U1.BO_BITS          = BO_BITS;
        defparam U1.BUS_DELAY        = BUS_DELAY;
        defparam U1.DIFF             = DIFF;
        defparam U1.RANDOM_SEED      = RANDOM_SEED;
        defparam U1.RZQ              = RZQ;
        defparam U1.STOP_ON_ERROR    = STOP_ON_ERROR;
        defparam U1.MPR_DQ0          = MPR_DQ0;
        defparam U1.DEBUG            = DEBUG;
        defparam U1.WL_ALLDQ         = WL_ALLDQ;
        defparam U1.GEARING          = GEARING;
    end

    if(DDR_CS_WIDTH == 2) begin
        lscc_ddr3 U0T  (rst_n, rck_dev0[1], rck_n_dev0[1], rcke_dev0[1], rs_n_dev0[1], rras_n_dev0, rcas_n_dev0, rwe_n_dev0, ddr_dm_tdqs[1:0], rba_dev0, raddr_dev0[ADDR_BITS-1:0], ddr_dq[15:0], ddr_dqs[1:0], ddr_dqs_n[1:0],  , rodt_dev0[1]);

        defparam U0T.TCK_MIN          = TCK_MIN;
        defparam U0T.TJIT_PER         = TJIT_PER;            
        defparam U0T.TJIT_CC          = TJIT_CC;
        defparam U0T.TERR_2PER        = TERR_2PER;
        defparam U0T.TERR_3PER        = TERR_3PER;
        defparam U0T.TERR_4PER        = TERR_4PER;
        defparam U0T.TERR_5PER        = TERR_5PER;
        defparam U0T.TERR_6PER        = TERR_6PER;
        defparam U0T.TERR_7PER        = TERR_7PER;
        defparam U0T.TERR_8PER        = TERR_8PER;
        defparam U0T.TERR_9PER        = TERR_9PER;
        defparam U0T.TERR_10PER       = TERR_10PER;
        defparam U0T.TERR_11PER       = TERR_11PER;
        defparam U0T.TERR_12PER       = TERR_12PER;
        defparam U0T.TDS              = TDS;
        defparam U0T.TDH              = TDH;
        defparam U0T.TDQSQ            = TDQSQ;
        defparam U0T.TDQSS            = TDQSS;
        defparam U0T.TDSS             = TDSS;
        defparam U0T.TDSH             = TDSH;
        defparam U0T.TDQSCK           = TDQSCK;
        defparam U0T.TQSH             = TQSH;
        defparam U0T.TQSL             = TQSL;
        defparam U0T.TDIPW            = TDIPW;
        defparam U0T.TIPW             = TIPW;
        defparam U0T.TIS              = TIS;
        defparam U0T.TIH              = TIH;
        defparam U0T.TRAS_MIN         = TRAS_MIN;
        defparam U0T.TRC              = TRC;
        defparam U0T.TRCD             = TRCD;
        defparam U0T.TRP              = TRP;
        defparam U0T.TXP              = TXP;
        defparam U0T.TCKE             = TCKE;
        defparam U0T.TAON             = TAON;
        						       			      
        defparam U0T.TWLS             = TWLS;
        defparam U0T.TWLH             = TWLH;
        defparam U0T.TWLO             = TWLO;
        defparam U0T.TAA_MIN          = TAA_MIN;
        defparam U0T.CL_TIME          = CL_TIME;
        						       			      
        defparam U0T.TRRD             = TRRD;
        defparam U0T.TFAW             = TFAW;
                                       
        // Mode Register             
        defparam U0T.CL_MIN           = CL_MIN;
        defparam U0T.CL_MAX           = CL_MAX;
        defparam U0T.AL_MIN           = AL_MIN;
        defparam U0T.AL_MAX           = AL_MAX;
        defparam U0T.WR_MIN           = WR_MIN;
        defparam U0T.WR_MAX           = WR_MAX;
        defparam U0T.BL_MIN           = BL_MIN;
        defparam U0T.BL_MAX           = BL_MAX;
        defparam U0T.CWL_MIN          = CWL_MIN;
        defparam U0T.CWL_MAX          = CWL_MAX;
         						       			       
        // Clock                                           
        defparam U0T.TCK_MAX          = TCK_MAX;
        defparam U0T.TCH_AVG_MIN      = TCH_AVG_MIN;
        defparam U0T.TCL_AVG_MIN      = TCL_AVG_MIN;
        defparam U0T.TCH_AVG_MAX      = TCH_AVG_MAX;
        defparam U0T.TCL_AVG_MAX      = TCL_AVG_MAX;
        defparam U0T.TCH_ABS_MIN      = TCH_ABS_MIN;
        defparam U0T.TCL_ABS_MIN      = TCL_ABS_MIN;
        defparam U0T.TCKE_TCK         = TCKE_TCK;
        defparam U0T.TAA_MAX          = TAA_MAX;
         						       			       
        // Data OUT                                        
        defparam U0T.TQH              = TQH;
        // Data Strobe OUT              
        defparam U0T.TRPRE            = TRPRE;
        defparam U0T.TRPST            = TRPST;
        // Data Strobe IN              
        defparam U0T.TDQSH            = TDQSH;
        defparam U0T.TDQSL            = TDQSL;
        defparam U0T.TWPRE            = TWPRE;
        defparam U0T.TWPST            = TWPST;
        // Command and Address          
        defparam U0T.TZQCS            = TZQCS;
        defparam U0T.TZQINIT          = TZQINIT;
        defparam U0T.TZQOPER          = TZQOPER;
        defparam U0T.TCCD             = TCCD;
        defparam U0T.TCCD_DG          = TCCD_DG;
        defparam U0T.TRAS_MAX         = TRAS_MAX;
        defparam U0T.TWR              = TWR;
        defparam U0T.TMRD             = TMRD;
        defparam U0T.TMOD             = TMOD;
        defparam U0T.TMOD_TCK         = TMOD_TCK;
        defparam U0T.TRRD_TCK         = TRRD_TCK;
        defparam U0T.TRRD_DG          = TRRD_DG;
        defparam U0T.TRRD_DG_TCK      = TRRD_DG_TCK;
        defparam U0T.TRTP             = TRTP;
        defparam U0T.TRTP_TCK         = TRTP_TCK;
        defparam U0T.TWTR             = TWTR;
        defparam U0T.TWTR_DG          = TWTR_DG;
        defparam U0T.TWTR_TCK         = TWTR_TCK;
        defparam U0T.TWTR_DG_TCK      = TWTR_DG_TCK;
        defparam U0T.TDLLK            = TDLLK;
        // Refresh - 1Gb               
        defparam U0T.TRFC_MIN         = TRFC_MIN;
        defparam U0T.TRFC_MAX         = TRFC_MAX;
        // Power Down                  
        defparam U0T.TXP_TCK          = TXP_TCK;
        defparam U0T.TXPDLL           = TXPDLL;
        defparam U0T.TXPDLL_TCK       = TXPDLL_TCK;
        defparam U0T.TACTPDEN         = TACTPDEN;
        defparam U0T.TPRPDEN          = TPRPDEN;
        defparam U0T.TREFPDEN         = TREFPDEN;
        defparam U0T.TCPDED           = TCPDED;
        defparam U0T.TXPR             = TXPR;
        defparam U0T.TXPR_TCK         = TXPR_TCK;
        // Self Refresh                
        defparam U0T.TXS              = TXS;
        defparam U0T.TXS_TCK          = TXS_TCK;
        defparam U0T.TCKSRE           = TCKSRE;
        defparam U0T.TCKSRE_TCK       = TCKSRE_TCK;
        defparam U0T.TCKSRX           = TCKSRX;
        defparam U0T.TCKSRX_TCK       = TCKSRX_TCK;
        defparam U0T.TCKESR_TCK       = TCKESR_TCK;
        // ODT                                             
        defparam U0T.TAOF             = TAOF;
        defparam U0T.TAONPD           = TAONPD;
        defparam U0T.TAOFPD           = TAOFPD;
        defparam U0T.ODTH4            = ODTH4;
        defparam U0T.ODTH8            = ODTH8;
        defparam U0T.TADC             = TADC;
        // Write Levelization          
        defparam U0T.TWLMRD           = TWLMRD;
        defparam U0T.TWLDQSEN         = TWLDQSEN;
        defparam U0T.TWLOE            = TWLOE;
        defparam U0T.AP               = AP;
        defparam U0T.BC               = BC;
                                         
        defparam U0T.RDQSEN_PRE       = RDQSEN_PRE;
        defparam U0T.RDQSEN_PST       = RDQSEN_PST;
        defparam U0T.RDQS_PRE         = RDQS_PRE;
        defparam U0T.RDQS_PST         = RDQS_PST;
        defparam U0T.RDQEN_PRE        = RDQEN_PRE;
        defparam U0T.RDQEN_PST        = RDQEN_PST;
        defparam U0T.WDQS_PRE         = WDQS_PRE;
        defparam U0T.WDQS_PST         = WDQS_PST;
        defparam U0T.RANDOM_OUT_DELAY = RANDOM_OUT_DELAY;
                                       
        defparam U0T.DQ_BITS          = DQ_BITS;
        defparam U0T.DQS_BITS         = DQS_BITS;
        defparam U0T.BA_BITS          = BA_BITS;
        defparam U0T.ROW_BITS         = ROW_BITS;
        defparam U0T.COL_BITS         = COL_BITS;
        defparam U0T.BL_BITS          = BL_BITS;
        defparam U0T.MEM_BITS         = MEM_BITS;
        defparam U0T.ADDR_BITS        = ADDR_BITS;
        defparam U0T.DM_BITS          = DM_BITS;
        defparam U0T.MAX_MEM          = MAX_MEM;
        defparam U0T.BO_BITS          = BO_BITS;
        defparam U0T.BUS_DELAY        = BUS_DELAY;
        defparam U0T.DIFF             = DIFF;
        defparam U0T.RANDOM_SEED      = RANDOM_SEED;
        defparam U0T.RZQ              = RZQ;
        defparam U0T.STOP_ON_ERROR    = STOP_ON_ERROR;
        defparam U0T.MPR_DQ0          = MPR_DQ0;
        defparam U0T.DEBUG            = DEBUG;
        defparam U0T.WL_ALLDQ         = WL_ALLDQ;
        defparam U0T.GEARING          = GEARING;

        if(DDR_DATA_WIDTH == 24) begin : DWID_EXT_24
            lscc_ddr3 U1T  (rst_n, rck_dev1[1], rck_n_dev1[1], rcke_dev1[1], rs_n_dev1[1], rras_n_dev1, rcas_n_dev1, rwe_n_dev1, {ddr_dm_tdqs[2], ddr_dm_tdqs[2]}, rba_dev1, 
                       raddr_dev1[ADDR_BITS-1:0], {ddr_dq[23:16], ddr_dq[23:16]}, {ddr_dqs[2], ddr_dqs[2]}, {ddr_dqs_n[2], ddr_dqs_n[2]},  , rodt_dev1[1]);

            defparam U1T.TCK_MIN          = TCK_MIN;
            defparam U1T.TJIT_PER         = TJIT_PER;            
            defparam U1T.TJIT_CC          = TJIT_CC;
            defparam U1T.TERR_2PER        = TERR_2PER;
            defparam U1T.TERR_3PER        = TERR_3PER;
            defparam U1T.TERR_4PER        = TERR_4PER;
            defparam U1T.TERR_5PER        = TERR_5PER;
            defparam U1T.TERR_6PER        = TERR_6PER;
            defparam U1T.TERR_7PER        = TERR_7PER;
            defparam U1T.TERR_8PER        = TERR_8PER;
            defparam U1T.TERR_9PER        = TERR_9PER;
            defparam U1T.TERR_10PER       = TERR_10PER;
            defparam U1T.TERR_11PER       = TERR_11PER;
            defparam U1T.TERR_12PER       = TERR_12PER;
            defparam U1T.TDS              = TDS;
            defparam U1T.TDH              = TDH;
            defparam U1T.TDQSQ            = TDQSQ;
            defparam U1T.TDQSS            = TDQSS;
            defparam U1T.TDSS             = TDSS;
            defparam U1T.TDSH             = TDSH;
            defparam U1T.TDQSCK           = TDQSCK;
            defparam U1T.TQSH             = TQSH;
            defparam U1T.TQSL             = TQSL;
            defparam U1T.TDIPW            = TDIPW;
            defparam U1T.TIPW             = TIPW;
            defparam U1T.TIS              = TIS;
            defparam U1T.TIH              = TIH;
            defparam U1T.TRAS_MIN         = TRAS_MIN;
            defparam U1T.TRC              = TRC;
            defparam U1T.TRCD             = TRCD;
            defparam U1T.TRP              = TRP;
            defparam U1T.TXP              = TXP;
            defparam U1T.TCKE             = TCKE;
            defparam U1T.TAON             = TAON;
            						       			      
            defparam U1T.TWLS             = TWLS;
            defparam U1T.TWLH             = TWLH;
            defparam U1T.TWLO             = TWLO;
            defparam U1T.TAA_MIN          = TAA_MIN;
            defparam U1T.CL_TIME          = CL_TIME;
            						       			      
            defparam U1T.TRRD             = TRRD;
            defparam U1T.TFAW             = TFAW;
                                           
            // Mode Register             
            defparam U1T.CL_MIN           = CL_MIN;
            defparam U1T.CL_MAX           = CL_MAX;
            defparam U1T.AL_MIN           = AL_MIN;
            defparam U1T.AL_MAX           = AL_MAX;
            defparam U1T.WR_MIN           = WR_MIN;
            defparam U1T.WR_MAX           = WR_MAX;
            defparam U1T.BL_MIN           = BL_MIN;
            defparam U1T.BL_MAX           = BL_MAX;
            defparam U1T.CWL_MIN          = CWL_MIN;
            defparam U1T.CWL_MAX          = CWL_MAX;
             						       			       
            // Clock                                           
            defparam U1T.TCK_MAX          = TCK_MAX;
            defparam U1T.TCH_AVG_MIN      = TCH_AVG_MIN;
            defparam U1T.TCL_AVG_MIN      = TCL_AVG_MIN;
            defparam U1T.TCH_AVG_MAX      = TCH_AVG_MAX;
            defparam U1T.TCL_AVG_MAX      = TCL_AVG_MAX;
            defparam U1T.TCH_ABS_MIN      = TCH_ABS_MIN;
            defparam U1T.TCL_ABS_MIN      = TCL_ABS_MIN;
            defparam U1T.TCKE_TCK         = TCKE_TCK;
            defparam U1T.TAA_MAX          = TAA_MAX;
             						       			       
            // Data OUT                                        
            defparam U1T.TQH              = TQH;
            // Data Strobe OUT              
            defparam U1T.TRPRE            = TRPRE;
            defparam U1T.TRPST            = TRPST;
            // Data Strobe IN              
            defparam U1T.TDQSH            = TDQSH;
            defparam U1T.TDQSL            = TDQSL;
            defparam U1T.TWPRE            = TWPRE;
            defparam U1T.TWPST            = TWPST;
            // Command and Address          
            defparam U1T.TZQCS            = TZQCS;
            defparam U1T.TZQINIT          = TZQINIT;
            defparam U1T.TZQOPER          = TZQOPER;
            defparam U1T.TCCD             = TCCD;
            defparam U1T.TCCD_DG          = TCCD_DG;
            defparam U1T.TRAS_MAX         = TRAS_MAX;
            defparam U1T.TWR              = TWR;
            defparam U1T.TMRD             = TMRD;
            defparam U1T.TMOD             = TMOD;
            defparam U1T.TMOD_TCK         = TMOD_TCK;
            defparam U1T.TRRD_TCK         = TRRD_TCK;
            defparam U1T.TRRD_DG          = TRRD_DG;
            defparam U1T.TRRD_DG_TCK      = TRRD_DG_TCK;
            defparam U1T.TRTP             = TRTP;
            defparam U1T.TRTP_TCK         = TRTP_TCK;
            defparam U1T.TWTR             = TWTR;
            defparam U1T.TWTR_DG          = TWTR_DG;
            defparam U1T.TWTR_TCK         = TWTR_TCK;
            defparam U1T.TWTR_DG_TCK      = TWTR_DG_TCK;
            defparam U1T.TDLLK            = TDLLK;
            // Refresh - 1Gb               
            defparam U1T.TRFC_MIN         = TRFC_MIN;
            defparam U1T.TRFC_MAX         = TRFC_MAX;
            // Power Down                  
            defparam U1T.TXP_TCK          = TXP_TCK;
            defparam U1T.TXPDLL           = TXPDLL;
            defparam U1T.TXPDLL_TCK       = TXPDLL_TCK;
            defparam U1T.TACTPDEN         = TACTPDEN;
            defparam U1T.TPRPDEN          = TPRPDEN;
            defparam U1T.TREFPDEN         = TREFPDEN;
            defparam U1T.TCPDED           = TCPDED;
            defparam U1T.TXPR             = TXPR;
            defparam U1T.TXPR_TCK         = TXPR_TCK;
            // Self Refresh                
            defparam U1T.TXS              = TXS;
            defparam U1T.TXS_TCK          = TXS_TCK;
            defparam U1T.TCKSRE           = TCKSRE;
            defparam U1T.TCKSRE_TCK       = TCKSRE_TCK;
            defparam U1T.TCKSRX           = TCKSRX;
            defparam U1T.TCKSRX_TCK       = TCKSRX_TCK;
            defparam U1T.TCKESR_TCK       = TCKESR_TCK;
            // ODT                                             
            defparam U1T.TAOF             = TAOF;
            defparam U1T.TAONPD           = TAONPD;
            defparam U1T.TAOFPD           = TAOFPD;
            defparam U1T.ODTH4            = ODTH4;
            defparam U1T.ODTH8            = ODTH8;
            defparam U1T.TADC             = TADC;
            // Write Levelization          
            defparam U1T.TWLMRD           = TWLMRD;
            defparam U1T.TWLDQSEN         = TWLDQSEN;
            defparam U1T.TWLOE            = TWLOE;
            defparam U1T.AP               = AP;
            defparam U1T.BC               = BC;
                                             
            defparam U1T.RDQSEN_PRE       = RDQSEN_PRE;
            defparam U1T.RDQSEN_PST       = RDQSEN_PST;
            defparam U1T.RDQS_PRE         = RDQS_PRE;
            defparam U1T.RDQS_PST         = RDQS_PST;
            defparam U1T.RDQEN_PRE        = RDQEN_PRE;
            defparam U1T.RDQEN_PST        = RDQEN_PST;
            defparam U1T.WDQS_PRE         = WDQS_PRE;
            defparam U1T.WDQS_PST         = WDQS_PST;
            defparam U1T.RANDOM_OUT_DELAY = RANDOM_OUT_DELAY;
                                           
            defparam U1T.DQ_BITS          = DQ_BITS;
            defparam U1T.DQS_BITS         = DQS_BITS;
            defparam U1T.BA_BITS          = BA_BITS;
            defparam U1T.ROW_BITS         = ROW_BITS;
            defparam U1T.COL_BITS         = COL_BITS;
            defparam U1T.BL_BITS          = BL_BITS;
            defparam U1T.MEM_BITS         = MEM_BITS;
            defparam U1T.ADDR_BITS        = ADDR_BITS;
            defparam U1T.DM_BITS          = DM_BITS;
            defparam U1T.MAX_MEM          = MAX_MEM;
            defparam U1T.BO_BITS          = BO_BITS;
            defparam U1T.BUS_DELAY        = BUS_DELAY;
            defparam U1T.DIFF             = DIFF;
            defparam U1T.RANDOM_SEED      = RANDOM_SEED;
            defparam U1T.RZQ              = RZQ;
            defparam U1T.STOP_ON_ERROR    = STOP_ON_ERROR;
            defparam U1T.MPR_DQ0          = MPR_DQ0;
            defparam U1T.DEBUG            = DEBUG;
            defparam U1T.WL_ALLDQ         = WL_ALLDQ;
            defparam U1T.GEARING          = GEARING;
        end
        if(DDR_DATA_WIDTH == 32) begin : DWID_EXT_32
            lscc_ddr3 U1T  (rst_n, rck_dev1[1], rck_n_dev1[1], rcke_dev1[1], rs_n_dev1[1], rras_n_dev1, rcas_n_dev1, rwe_n_dev1, ddr_dm_tdqs[3:2], rba_dev1, raddr_dev1[ADDR_BITS-1:0], ddr_dq[31:16], ddr_dqs[3:2], ddr_dqs_n[3:2],  , rodt_dev1[1]);

            defparam U1T.TCK_MIN          = TCK_MIN;
            defparam U1T.TJIT_PER         = TJIT_PER;            
            defparam U1T.TJIT_CC          = TJIT_CC;
            defparam U1T.TERR_2PER        = TERR_2PER;
            defparam U1T.TERR_3PER        = TERR_3PER;
            defparam U1T.TERR_4PER        = TERR_4PER;
            defparam U1T.TERR_5PER        = TERR_5PER;
            defparam U1T.TERR_6PER        = TERR_6PER;
            defparam U1T.TERR_7PER        = TERR_7PER;
            defparam U1T.TERR_8PER        = TERR_8PER;
            defparam U1T.TERR_9PER        = TERR_9PER;
            defparam U1T.TERR_10PER       = TERR_10PER;
            defparam U1T.TERR_11PER       = TERR_11PER;
            defparam U1T.TERR_12PER       = TERR_12PER;
            defparam U1T.TDS              = TDS;
            defparam U1T.TDH              = TDH;
            defparam U1T.TDQSQ            = TDQSQ;
            defparam U1T.TDQSS            = TDQSS;
            defparam U1T.TDSS             = TDSS;
            defparam U1T.TDSH             = TDSH;
            defparam U1T.TDQSCK           = TDQSCK;
            defparam U1T.TQSH             = TQSH;
            defparam U1T.TQSL             = TQSL;
            defparam U1T.TDIPW            = TDIPW;
            defparam U1T.TIPW             = TIPW;
            defparam U1T.TIS              = TIS;
            defparam U1T.TIH              = TIH;
            defparam U1T.TRAS_MIN         = TRAS_MIN;
            defparam U1T.TRC              = TRC;
            defparam U1T.TRCD             = TRCD;
            defparam U1T.TRP              = TRP;
            defparam U1T.TXP              = TXP;
            defparam U1T.TCKE             = TCKE;
            defparam U1T.TAON             = TAON;
            						       			      
            defparam U1T.TWLS             = TWLS;
            defparam U1T.TWLH             = TWLH;
            defparam U1T.TWLO             = TWLO;
            defparam U1T.TAA_MIN          = TAA_MIN;
            defparam U1T.CL_TIME          = CL_TIME;
            						       			      
            defparam U1T.TRRD             = TRRD;
            defparam U1T.TFAW             = TFAW;
                                           
            // Mode Register             
            defparam U1T.CL_MIN           = CL_MIN;
            defparam U1T.CL_MAX           = CL_MAX;
            defparam U1T.AL_MIN           = AL_MIN;
            defparam U1T.AL_MAX           = AL_MAX;
            defparam U1T.WR_MIN           = WR_MIN;
            defparam U1T.WR_MAX           = WR_MAX;
            defparam U1T.BL_MIN           = BL_MIN;
            defparam U1T.BL_MAX           = BL_MAX;
            defparam U1T.CWL_MIN          = CWL_MIN;
            defparam U1T.CWL_MAX          = CWL_MAX;
             						       			       
            // Clock                                           
            defparam U1T.TCK_MAX          = TCK_MAX;
            defparam U1T.TCH_AVG_MIN      = TCH_AVG_MIN;
            defparam U1T.TCL_AVG_MIN      = TCL_AVG_MIN;
            defparam U1T.TCH_AVG_MAX      = TCH_AVG_MAX;
            defparam U1T.TCL_AVG_MAX      = TCL_AVG_MAX;
            defparam U1T.TCH_ABS_MIN      = TCH_ABS_MIN;
            defparam U1T.TCL_ABS_MIN      = TCL_ABS_MIN;
            defparam U1T.TCKE_TCK         = TCKE_TCK;
            defparam U1T.TAA_MAX          = TAA_MAX;
             						       			       
            // Data OUT                                        
            defparam U1T.TQH              = TQH;
            // Data Strobe OUT              
            defparam U1T.TRPRE            = TRPRE;
            defparam U1T.TRPST            = TRPST;
            // Data Strobe IN              
            defparam U1T.TDQSH            = TDQSH;
            defparam U1T.TDQSL            = TDQSL;
            defparam U1T.TWPRE            = TWPRE;
            defparam U1T.TWPST            = TWPST;
            // Command and Address          
            defparam U1T.TZQCS            = TZQCS;
            defparam U1T.TZQINIT          = TZQINIT;
            defparam U1T.TZQOPER          = TZQOPER;
            defparam U1T.TCCD             = TCCD;
            defparam U1T.TCCD_DG          = TCCD_DG;
            defparam U1T.TRAS_MAX         = TRAS_MAX;
            defparam U1T.TWR              = TWR;
            defparam U1T.TMRD             = TMRD;
            defparam U1T.TMOD             = TMOD;
            defparam U1T.TMOD_TCK         = TMOD_TCK;
            defparam U1T.TRRD_TCK         = TRRD_TCK;
            defparam U1T.TRRD_DG          = TRRD_DG;
            defparam U1T.TRRD_DG_TCK      = TRRD_DG_TCK;
            defparam U1T.TRTP             = TRTP;
            defparam U1T.TRTP_TCK         = TRTP_TCK;
            defparam U1T.TWTR             = TWTR;
            defparam U1T.TWTR_DG          = TWTR_DG;
            defparam U1T.TWTR_TCK         = TWTR_TCK;
            defparam U1T.TWTR_DG_TCK      = TWTR_DG_TCK;
            defparam U1T.TDLLK            = TDLLK;
            // Refresh - 1Gb               
            defparam U1T.TRFC_MIN         = TRFC_MIN;
            defparam U1T.TRFC_MAX         = TRFC_MAX;
            // Power Down                  
            defparam U1T.TXP_TCK          = TXP_TCK;
            defparam U1T.TXPDLL           = TXPDLL;
            defparam U1T.TXPDLL_TCK       = TXPDLL_TCK;
            defparam U1T.TACTPDEN         = TACTPDEN;
            defparam U1T.TPRPDEN          = TPRPDEN;
            defparam U1T.TREFPDEN         = TREFPDEN;
            defparam U1T.TCPDED           = TCPDED;
            defparam U1T.TXPR             = TXPR;
            defparam U1T.TXPR_TCK         = TXPR_TCK;
            // Self Refresh                
            defparam U1T.TXS              = TXS;
            defparam U1T.TXS_TCK          = TXS_TCK;
            defparam U1T.TCKSRE           = TCKSRE;
            defparam U1T.TCKSRE_TCK       = TCKSRE_TCK;
            defparam U1T.TCKSRX           = TCKSRX;
            defparam U1T.TCKSRX_TCK       = TCKSRX_TCK;
            defparam U1T.TCKESR_TCK       = TCKESR_TCK;
            // ODT                                             
            defparam U1T.TAOF             = TAOF;
            defparam U1T.TAONPD           = TAONPD;
            defparam U1T.TAOFPD           = TAOFPD;
            defparam U1T.ODTH4            = ODTH4;
            defparam U1T.ODTH8            = ODTH8;
            defparam U1T.TADC             = TADC;
            // Write Levelization          
            defparam U1T.TWLMRD           = TWLMRD;
            defparam U1T.TWLDQSEN         = TWLDQSEN;
            defparam U1T.TWLOE            = TWLOE;
            defparam U1T.AP               = AP;
            defparam U1T.BC               = BC;
                                             
            defparam U1T.RDQSEN_PRE       = RDQSEN_PRE;
            defparam U1T.RDQSEN_PST       = RDQSEN_PST;
            defparam U1T.RDQS_PRE         = RDQS_PRE;
            defparam U1T.RDQS_PST         = RDQS_PST;
            defparam U1T.RDQEN_PRE        = RDQEN_PRE;
            defparam U1T.RDQEN_PST        = RDQEN_PST;
            defparam U1T.WDQS_PRE         = WDQS_PRE;
            defparam U1T.WDQS_PST         = WDQS_PST;
            defparam U1T.RANDOM_OUT_DELAY = RANDOM_OUT_DELAY;
                                           
            defparam U1T.DQ_BITS          = DQ_BITS;
            defparam U1T.DQS_BITS         = DQS_BITS;
            defparam U1T.BA_BITS          = BA_BITS;
            defparam U1T.ROW_BITS         = ROW_BITS;
            defparam U1T.COL_BITS         = COL_BITS;
            defparam U1T.BL_BITS          = BL_BITS;
            defparam U1T.MEM_BITS         = MEM_BITS;
            defparam U1T.ADDR_BITS        = ADDR_BITS;
            defparam U1T.DM_BITS          = DM_BITS;
            defparam U1T.MAX_MEM          = MAX_MEM;
            defparam U1T.BO_BITS          = BO_BITS;
            defparam U1T.BUS_DELAY        = BUS_DELAY;
            defparam U1T.DIFF             = DIFF;
            defparam U1T.RANDOM_SEED      = RANDOM_SEED;
            defparam U1T.RZQ              = RZQ;
            defparam U1T.STOP_ON_ERROR    = STOP_ON_ERROR;
            defparam U1T.MPR_DQ0          = MPR_DQ0;
            defparam U1T.DEBUG            = DEBUG;
            defparam U1T.WL_ALLDQ         = WL_ALLDQ;
            defparam U1T.GEARING          = GEARING;
        end
    end
end

function valid_cl;
    input [3:0] cl;
    input [3:0] cwl;
    begin
        if(GEARING == 4) begin
            case ({cwl, cl})
                {4'd5, 4'd5 },
                {4'd5, 4'd6 },
                {4'd6, 4'd7 },
                {4'd6, 4'd8 }: valid_cl = 1;
                default      : valid_cl = 0;
            endcase
        end
        else begin
            if(DDR_FREQ == 1066) begin
                case ({cwl, cl})
                    {4'd5, 4'd5 },
                    {4'd5, 4'd6 },
                    {4'd6, 4'd8 }: valid_cl = 1;
                    default      : valid_cl = 0;
                endcase
            end
            else begin
                case ({cwl, cl})
                    {4'd5, 4'd5 },
                    {4'd5, 4'd6 }: valid_cl = 1;
                    default      : valid_cl = 0;
                endcase
            end
        end
    end
endfunction

// find the minimum valid cas write latency
function [3:0] min_cwl;
    input period;
    real period;
    min_cwl = (period >= 2500.0) ? 5:
              (period >= 1875.0) ? 6:
              (period >= 1500.0) ? 7:
              (period >= 1250.0) ? 8:
              (period >= 1070.0) ? 9:
              10; // (period >= 935)
endfunction

// find the minimum valid cas latency
function [3:0] min_cl;
    input period;
    real period;
    reg [3:0] cwl;
    reg [3:0] cl;
    begin
        cwl = min_cwl(period);
        for (cl=CL_MAX; cl>=CL_MIN; cl=cl-1) begin
            if (valid_cl(cl, cwl)) begin
                min_cl = cl;
            end
        end
    end
endfunction

endmodule
`endif
