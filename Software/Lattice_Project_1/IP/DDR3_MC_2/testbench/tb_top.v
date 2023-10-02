`ifndef LSCC_tb_top
`define LSCC_tb_top

`timescale 1 ps / 1 ps
`include "lscc_lmmi2ahbl.v"

`include "ddr3_sdram_mem_params.vh"
`include "tb_config_params.vh"
`include "monitor.v"
`include "odt_watchdog.v"
`include "dqs_grp_delay.v"

`ifdef DATA_SIZE_32
   `include "ddr3_dimm_32.vh"
`endif
`ifdef DATA_SIZE_24
   `include "ddr3_dimm_24.vh"
`endif
`ifdef DATA_SIZE_16
   `include "ddr3_dimm_16.vh"
`endif
`ifdef DATA_SIZE_8
   `include "ddr3_dimm_8.vh"
`endif

//=======================================
//DQ/DQS/DM Delay for Read Training
//=======================================
//Read Enable Pattern Used   /*| F  |*/  /*| ALL |*/  /*|     |*/  /*|    |*/  /*| F  |*/  /*| F  |*/  /*| F   |*/ /*| F   |*/   /*|    F |*/ /*| F   |*/  /*| F   |*/ /*| F   |*/  /*| WL_F |*/
`define DDR3_GEAR4_DELAY     (`GEAR-1.75)/2
`define BOARD_DELAY_ENABLE      /*|    |*/               /*|     |*/  /*|    |*/  /*|    |*/  /*|    |*/  /*|     |*/ /*|     |*/   /*|      |*/ /*|     |*/  /*|     |*/ /*|     |*/  /*|      |*/
`define DDR3_MEM00_CS_DEL       /*|    |*/      10       /*|1800 |*/  /*|3675|*/  /*|2000|*/  /*|2000|*/  /*|2000 |*/ /*|2000 |*/   /*|2000  |*/ /*|2000 |*/  /*|2000 |*/ /*|2000 |*/  /*|2000  |*/
`define DDR3_MEM00_CS_DEL_10th                  1        /*|1800 |*/  /*|367 |*/  /*|200 |*/  /*|200 |*/  /*|200  |*/ /*|200  |*/   /*|200   |*/ /*|200  |*/  /*|200  |*/ /*|200  |*/  /*|200   |*/
`define DDR3_MEM00_CA_DEL       /*|    |*/      10       /*|1800 |*/  /*|3675|*/  /*|2000|*/  /*|2000|*/  /*|2000 |*/ /*|2000 |*/   /*|2000  |*/ /*|2000 |*/  /*|2000 |*/ /*|2000 |*/  /*|2000  |*/
`define DDR3_MEM00_CA_DEL_10th                  1        /*|180  |*/  /*|367 |*/  /*|200 |*/  /*|200 |*/  /*|200  |*/ /*|200  |*/   /*|200   |*/ /*|200  |*/  /*|200  |*/ /*|200  |*/  /*|200   |*/
`define DDR3_MEM00_CK_DEL       /*|    |*/      10       /*|1800 |*/  /*|3675|*/  /*|2000|*/  /*|2000|*/  /*|2000 |*/ /*|2000 |*/   /*|2000  |*/ /*|2000 |*/  /*|2000 |*/ /*|2000 |*/  /*|2000  |*/
`define DDR3_MEM00_CK_DEL_10th                  1        /*|180  |*/  /*|367 |*/  /*|200 |*/  /*|200 |*/  /*|200  |*/ /*|200  |*/   /*|200   |*/ /*|200  |*/  /*|200  |*/ /*|200  |*/  /*|200   |*/
`define DDR3_MEM00_WR_DQS_DEL   /*|0   |*/  /*|0    |*/  /*|1875 |*/    `DDR3_GEAR4_DELAY*27*1000000/`MEMCLK_FREQ     /*|2500|*/  /*|2500|*/  /*|2500 |*/ /*|2500 |*/   /*|2500  |*/ /*|2500 |*/  /*|2500 |*/ /*|2500 |*/  /*|2500  |*/
`define DDR3_MEM00_WR_DQ_DMI_DEL/*|0   |*/  /*|0    |*/  /*|1875 |*/    `DDR3_GEAR4_DELAY*27*1000000/`MEMCLK_FREQ     /*|2500|*/  /*|2500|*/  /*|2500 |*/ /*|2500 |*/   /*|2500  |*/ /*|2500 |*/  /*|2500 |*/ /*|2500 |*/  /*|2500  |*/
`define DDR3_MEM00_RD_DQS_DEL   /*|0   |*/  /*|0    |*/  /*|1875 |*/    `DDR3_GEAR4_DELAY*8*1000000/`MEMCLK_FREQ     /*|2500|*/  /*|2500|*/  /*|2500 |*/ /*|2500 |*/   /*|2500  |*/ /*|2500 |*/  /*|2500 |*/ /*|2500 |*/  /*|2500  |*/
`define DDR3_MEM00_RD_DQ_DMI_DEL/*|0   |*/  /*|0    |*/  /*|1875 |*/    `DDR3_GEAR4_DELAY*8*1000000/`MEMCLK_FREQ      /*|2500|*/  /*|2500|*/  /*|2500 |*/ /*|2500 |*/   /*|2500  |*/ /*|2500 |*/  /*|2500 |*/ /*|2500 |*/  /*|2500  |*/

                             /*|    |*/  /*|     |*/  /*|     |*/              /*|    |*/  /*|    |*/  /*|     |*/ /*|     |*/   /*|      |*/ /*|     |*/  /*|     |*/ /*|     |*/  /*|      |*/
`define DDR3_MEM01_WR_DQS_DEL   /*|1000|*/  /*|1000 |*/  /*|1975 |*/    `DDR3_GEAR4_DELAY*27*1000000/`MEMCLK_FREQ      /*|2750|*/  /*|2750|*/  /*|5000 |*/ /*|10000|*/   /*|10000 |*/ /*|7500 |*/  /*|7500 |*/ /*|7500 |*/  /*|10000 |*/
`define DDR3_MEM01_WR_DQ_DMI_DEL/*|1500|*/  /*|1500 |*/  /*|2000 |*/    `DDR3_GEAR4_DELAY*27*1000000/`MEMCLK_FREQ      /*|2800|*/  /*|2800|*/  /*|5500 |*/ /*|12500|*/   /*|12500 |*/ /*|8750 |*/  /*|8750 |*/ /*|8750 |*/  /*|12500 |*/
`define DDR3_MEM01_RD_DQS_DEL   /*|1000|*/  /*|1000 |*/  /*|1975 |*/    `DDR3_GEAR4_DELAY*8*1000000/`MEMCLK_FREQ     /*|2750|*/  /*|2750|*/  /*|5000 |*/ /*|10000|*/   /*|10000 |*/ /*|7500 |*/  /*|7500 |*/ /*|7500 |*/  /*|10000 |*/
`define DDR3_MEM01_RD_DQ_DMI_DEL/*|1500|*/  /*|1500 |*/  /*|2000 |*/    `DDR3_GEAR4_DELAY*8*1000000/`MEMCLK_FREQ     /*|2800|*/  /*|2800|*/  /*|5500 |*/ /*|12500|*/   /*|12500 |*/ /*|8750 |*/  /*|8750 |*/ /*|8750 |*/  /*|12500 |*/
                             /*|    |*/  /*|     |*/  /*|     |*/              /*|    |*/  /*|    |*/  /*|     |*/ /*|     |*/   /*|      |*/ /*|     |*/  /*|     |*/ /*|     |*/  /*|      |*/
`define DDR3_MEM10_WR_DQS_DEL   /*|2000|*/  /*|2000 |*/  /*|2200 |*/    `DDR3_GEAR4_DELAY*27*1000000/`MEMCLK_FREQ      /*|3000|*/  /*|4000|*/  /*|7500 |*/ /*|12500|*/   /*|13750 |*/ /*|13750|*/  /*|13750|*/ /*|13750|*/  /*|20000 |*/
`define DDR3_MEM10_WR_DQ_DMI_DEL/*|2500|*/  /*|2500 |*/  /*|2250 |*/    `DDR3_GEAR4_DELAY*27*1000000/`MEMCLK_FREQ      /*|3200|*/  /*|4200|*/  /*|8000 |*/ /*|13000|*/   /*|15000 |*/ /*|15000|*/  /*|15000|*/ /*|15000|*/  /*|22500 |*/
`define DDR3_MEM10_RD_DQS_DEL   /*|2000|*/  /*|2000 |*/  /*|2200 |*/    `DDR3_GEAR4_DELAY*8*1000000/`MEMCLK_FREQ     /*|3000|*/  /*|4000|*/  /*|7500 |*/ /*|12500|*/   /*|13750 |*/ /*|13750|*/  /*|13750|*/ /*|13750|*/  /*|20000 |*/
`define DDR3_MEM10_RD_DQ_DMI_DEL/*|2500|*/  /*|2500 |*/  /*|2250 |*/    `DDR3_GEAR4_DELAY*8*1000000/`MEMCLK_FREQ     /*|3200|*/  /*|4200|*/  /*|8000 |*/ /*|13000|*/   /*|15000 |*/ /*|15000|*/  /*|15000|*/ /*|15000|*/  /*|22500 |*/
                             /*|    |*/  /*|     |*/  /*|     |*/              /*|    |*/  /*|    |*/  /*|     |*/ /*|     |*/   /*|      |*/ /*|     |*/  /*|     |*/ /*|     |*/  /*|      |*/
`define DDR3_MEM11_WR_DQS_DEL   /*|3000|*/  /*|20000|*/  /*|2500 |*/    `DDR3_GEAR4_DELAY*27*1000000/`MEMCLK_FREQ      /*|3500|*/  /*|5250|*/  /*|10000|*/ /*|15000|*/   /*|15625 |*/ /*|15000|*/  /*|25000|*/ /*|25000|*/  /*|30000 |*/
`define DDR3_MEM11_WR_DQ_DMI_DEL/*|3500|*/  /*|3500 |*/  /*|2550 |*/    `DDR3_GEAR4_DELAY*27*1000000/`MEMCLK_FREQ      /*|3550|*/  /*|5500|*/  /*|12500|*/ /*|15500|*/   /*|18000 |*/ /*|18000|*/  /*|28000|*/ /*|28000|*/  /*|32500 |*/
`define DDR3_MEM11_RD_DQS_DEL   /*|3000|*/  /*|20000|*/  /*|2500 |*/    `DDR3_GEAR4_DELAY*8*1000000/`MEMCLK_FREQ     /*|3500|*/  /*|5250|*/  /*|10000|*/ /*|15000|*/   /*|15625 |*/ /*|15000|*/  /*|25000|*/ /*|25000|*/  /*|30000 |*/
`define DDR3_MEM11_RD_DQ_DMI_DEL/*|3500|*/  /*|3500 |*/  /*|2550 |*/    `DDR3_GEAR4_DELAY*8*1000000/`MEMCLK_FREQ     /*|3550|*/  /*|5500|*/  /*|12500|*/ /*|15500|*/   /*|18000 |*/ /*|18000|*/  /*|28000|*/ /*|28000|*/  /*|32500 |*/
//=======================================                                                                                        

`include "ddr3.v"
//=======================================
// `define GATE_SIM
`define SIM
`define GEAR_MODE "X2"
//=======================================
module  tb_top;

`include "dut_params.v"
localparam USR_RST_CLK_CNT = 8'd20;   // 20 x 5ns = 100 ns

localparam DUAL_RANK = CS_WIDTH-1;
localparam BSIZE = CS_WIDTH + 2;
//`ifdef GATE_SIM
//    localparam  GATE_SIM = 1'b1;
//`else
//    localparam  GATE_SIM = 1'b0; 
//`endif
//`ifdef SIM
//    localparam  SIM = 1'b1;
//`else
//    localparam  SIM = 1'b0; 
//`endif
localparam  USER_DM   = DSIZE/8;
localparam  AHBL_DATA_WIDTH = 16;
localparam  AHBL_ADDR_WIDTH = 32;
parameter                    LOW       = 1'b0;
parameter                    HIGH      = 1'b1;
parameter                    lo        = 1'b0;
parameter                    hi        = 1'b1;

parameter                    ldata     = 13;
parameter                    InitStart = 3'd0,
                             CmdR      = 3'd1,
                             MemRstN   = 3'd2,
                             IntStatus = 3'd3,
                             IntEnable = 3'd4,
                             IntSet    = 3'd5,
                             RstN      = 3'd6;
                             
// ====================================================================
// Internal signals
// ====================================================================
wire   [DATA_WIDTH-1:0]      em_ddr_data_io;
wire   [DQS_WIDTH-1:0]       em_ddr_dqs_io;
wire   [DQS_WIDTH-1:0]       inv_ddr_dqs;
wire   [DQS_WIDTH-1:0]       ddr_dqm;
wire   [DQS_WIDTH-1:0]       em_ddr_dm_o;
wire   [DQS_WIDTH-1:0]       ddr_dqs_d;


wire   [DATA_WIDTH-1:0]      ddr_dq     ;
wire   [DQS_WIDTH-1:0]       ddr_dqs_t  ;
wire   [DQS_WIDTH-1:0]       ddr_dqs_c  ;
wire   [DQS_WIDTH-1:0]       ddr_dmi    ;

// ====================================================================
// Registers used by the tasks to drive the input signals of the
// FPGA bridge
// ====================================================================
reg                          eclk_i    ; // for PLL_EN=0
reg                          sync_clk_i; // for PLL_EN=0
reg                          pll_lock_i; // for PLL_EN=0
reg                          rst_n_i;
reg    [3:0]                 cmd_i;
reg                          cmd_valid_i;
reg                          init_start_i;
reg                          ofly_burst_len_i;
reg    [4:0]                 ff_burst_count;
wire   [4:0]                 cmd_burst_cnt_i = ff_burst_count;
reg    [USER_DM-1:0]         dmsel;
reg    [ADDR_WIDTH-1:0]      addr_i;



reg                          mem_rst_n_i;
reg                          pll_rst_n_i;

reg    [2:0]                 ar_burst_cnt;
reg    [2:0]                 ar_burst_en;
reg    [3:0]                 db_size;
reg    [15:0]                trefi;

reg    [DSIZE-1:0]           write_data_i;
reg    [USER_DM-1:0]         data_mask_i;
// reg    [USER_DM-1:0]         data_mask;
wire   [DSIZE-1:0]           read_data_o;

reg                          wl_start_i;
wire                         wl_done_o;

reg                          wl_done_q;
wire                         wl_done_p;
wire                         init_done;
reg                          init_wl;
wire                         init_start;

// ====================================================================
// Output signals from the controller
// ====================================================================


wire                         cmd_rdy_o;
wire                         init_done_o;
wire                         clocking_good_o;

wire   [CKE_WIDTH-1:0]       em_ddr_cke_o;
wire                         em_ddr_ras_n_o;
wire                         em_ddr_cas_n_o;
wire                         em_ddr_we_n_o;
wire                         em_ddr_reset_n_o;
wire   [CS_WIDTH-1:0]        em_ddr_cs_n_o;
wire   [CS_WIDTH-1:0]        em_ddr_odt_o;
wire   [ROW_WIDTH-1:0]       em_ddr_addr_o;
wire   [2:0]                 em_ddr_ba_o;

wire                         data_rdy;
wire                         datain_rdy_o;
assign  data_rdy = datain_rdy_o;

reg                          w_tvalid_i; // signal from uP; should be HI all time; NC inside
wire                         w_ready_o;  // from MC to uP; datain_rdy
reg [DSIZE +(DSIZE/8)-1:0]   w_tdata_i;  // write data from uP. Should include DATA MASK;

// AXI4-Stream I/F; for READ from memory
wire                         r_tvalid_o; // <- read_data_valid
reg                          r_ready_i; // NC; should be HI all the time
wire [DSIZE - 1:0]           r_tdata_o; // READ data from MC

reg                          ext_auto_ref_i;
wire                         ext_auto_ref_ack_o;

// AHB-Lite Interface
wire                         ahbl_hsel_i;
wire                         ahbl_hready_i;
wire   [AHBL_ADDR_WIDTH-1:0] ahbl_haddr_i;
wire   [2:0]                 ahbl_hburst_i;
wire   [2:0]                 ahbl_hsize_i;
wire                         ahbl_hmastlock_i;
wire   [3:0]                 ahbl_hprot_i;
wire   [1:0]                 ahbl_htrans_i;
wire                         ahbl_hwrite_i;
wire   [AHBL_DATA_WIDTH-1:0] ahbl_hwdata_i;

wire                         ahbl_hreadyout_o;
wire                         ahbl_hresp_o;
wire   [AHBL_DATA_WIDTH-1:0] ahbl_hrdata_o;
wire   [AHBL_DATA_WIDTH-1:0] ahbl_lmmi_rdata_w;
// ====================================================================
// Clock generation logic and Parameters
// ====================================================================
reg                          clk_i;        // memory controller clock
wire                         sys_clk;         // memory controller clock
reg                          mem_clk;         // memory controller clock
wire                         sclk_o;
wire   [CLKO_WIDTH-1:0]      em_ddr_clk_o;    // clock connected to the memory
wire   [CLKO_WIDTH-1:0]      ddr_clk_n;       // clock connected to the memory
reg                          monclk;          // monitor clock

wire                         ddr_clk_d;
reg                          cs_addr;
reg    [9:0]                 col_addr;
wire                         ddr_mem_rst_n_w; // reset that goes to the memory model

wire                         lmmi_clk_i    = clk_i;
wire                         lmmi_resetn_i = rst_n_i;
reg                          lmmi_request_i;
reg                          lmmi_wr_rdn_i;
reg [ADDR_WIDTH-1:0]         lmmi_offset_i;
reg [ldata-1:0]              lmmi_wdata_i;

wire [ldata-1:0]             lmmi_rdata_o;
wire                         lmmi_data_valid_o;
wire                         lmmi_ready_o;
wire                         int_o;      // Interrupt signal
wire                         odt_error_flg;

`ifdef BOARD_DELAY_ENABLE   
// Common CK/CKE/CSn/RASn/CASn/WEn/BA/AD
    reg  [CLKO_WIDTH-1:0] ck_delay[0:10]    ;
    reg  [CKE_WIDTH-1:0] cke_delay[0:10]   ;
    reg  [CS_WIDTH-1:0]  cs_n_delay[0:10]  ;
    reg                  ras_n_delay[0:10] ;
    reg                  cas_n_delay[0:10] ;
    reg                  we_n_delay[0:10]  ;
    reg                  odt_delay[0:10]   ;
    reg  [ROW_WIDTH-1:0] ad_delay[0:10]    ;
    reg    [2:0]         ba_delay[0:10]    ;
    
    wire [CLKO_WIDTH-1:0] ddr3mem0_ck       ;
    wire [CKE_WIDTH-1:0]  ddr3mem0_cke      ;
    wire [CS_WIDTH-1:0]  ddr3mem0_cs_n     ;
    wire                 ddr3mem0_ras_n    ;
    wire                 ddr3mem0_cas_n    ;
    wire                 ddr3mem0_we_n     ;
    wire                 ddr3mem0_odt      ;
    wire [ROW_WIDTH-1:0] ddr3mem0_ad       ;
    wire   [2:0]         ddr3mem0_ba       ;

    wire                 ddr3mem0_dqs_ts   ;
    wire                 ddr3mem0_dq_ts    ;
    wire                 ddr3mem0_dqs_t    ;
    wire                 ddr3mem0_dqs_c    ;
    wire  [7:0]          ddr3mem0_dq       ;
    wire                 ddr3mem0_dmi      ;
    
    wire                 ddr3mem1_dqs_ts   ;
    wire                 ddr3mem1_dq_ts    ;
    wire                 ddr3mem1_dqs_t    ;
    wire                 ddr3mem1_dqs_c    ;
    wire  [7:0]          ddr3mem1_dq       ;
    wire                 ddr3mem1_dmi      ;
    
    wire                 ddr3mem2_dqs_ts   ;
    wire                 ddr3mem2_dq_ts    ;
    wire                 ddr3mem2_dqs_t    ;
    wire                 ddr3mem2_dqs_c    ;
    wire  [7:0]          ddr3mem2_dq       ;
    wire                 ddr3mem2_dmi      ;
    
    wire                 ddr3mem3_dqs_ts   ;
    wire                 ddr3mem3_dq_ts    ;
    wire                 ddr3mem3_dqs_t    ;
    wire                 ddr3mem3_dqs_c    ;
    wire  [7:0]          ddr3mem3_dq       ;
    wire                 ddr3mem3_dmi      ;
    genvar dly_i;
    
    // For DQS delay
    wire  [5:0] cmd_sig_w;
    wire        dram_init_done;
    wire        wl_act;
    
    // For PLL reset check
    reg         clk_i_stop;
    reg         clk_i_min;
    integer     ckl_i_min_period;
    integer     i;
    
    `ifndef NO_WRITE_LEVEL
    localparam  NO_WRITE_LEVEL = 0;
    `else
    localparam  NO_WRITE_LEVEL = 1;
    `endif
`endif


`ifdef GATE_SIM
genvar p;

generate
   for (p=0;p< DATA_WIDTH;p=p+1)
   begin: p1
    pullup (em_ddr_data_io[p]);
   end
endgenerate
`endif


//GSR GSR_INST (.GSR(rst_n_i));
///////////////////// GSR /////////////////////
reg CLK_GSR = 0;
reg USER_GSR = 1;
wire GSROUT;

initial begin
    forever begin
        #5;
        CLK_GSR = ~CLK_GSR;
    end
end

GSR GSR_INST (
    .GSR_N(USER_GSR),
    .CLK(CLK_GSR)
);

PUR PUR_INST (.PUR(1'b1));
/////////////////////////////////////////////////
//`ifndef GATE_SIM
//   defparam `RTL_SIM = 1; // `RTL_SIM is tb_top.u_$instName\.lscc_ddr3_mc.SIM parameter.
//`endif
// Used RTL for simulation
/////////////////////////////////////////////////


//Simulation Clock Cycle in PS
//parameter c = HALF_CLOCK_PERIOD;
// parameter c = `REFCLK_PERIOD_BY2;  // PLL_FIN is refclk to PLL.  unit of c is ps.
parameter c = $ceil(500000.0/CLKI_FREQ);  // PLL_FIN is refclk to PLL.  unit of c is ps.


initial begin
    clk_i            = 0;
    mem_clk          = 0;
    monclk           = 0;
    init_start_i     = 0;
    mem_rst_n_i      = 1'b1;
    addr_i           = 0;
    ff_burst_count   = 1;
    cmd_i            = 0;
    dmsel            = 'b0;
    cmd_valid_i      = 0;
    write_data_i     = 0;     //  64'h0123456789ABCDEF
    data_mask_i      = 0;
    // data_mask        = 0;
    ofly_burst_len_i = 0;
    ar_burst_cnt     = 4;
    if (AR_BURST_EN == 8) 
      ar_burst_en    = 3'b000;
    else
      ar_burst_en    = AR_BURST_EN;
      
    trefi            = TREFI;
    cs_addr          = 1'b0;
    
    lmmi_request_i   = 0;
    lmmi_wr_rdn_i    = 0;
    lmmi_offset_i    = 0;
    lmmi_wdata_i     = 0;
    w_tdata_i        = 0;
    w_tvalid_i       = 0;
    r_ready_i        = 0;
    
    clk_i_stop       = 0;
    clk_i_min        = 0;
    
    wl_start_i       = 0;
    wl_done_q        = 0;
    init_wl          = 0;
    
    ext_auto_ref_i   = 0;
end

if (PLL_EXT_RESET_EN == 0)
  always #(c)   clk_i   = ~clk_i;
else
  always begin
    if (clk_i_stop)
      clk_i = 0;
    else if (clk_i_min) 
      #(c-ckl_i_min_period) clk_i   = ~clk_i;
    else
      #(c) clk_i   = ~clk_i;
  end
    
always #(c)   monclk   = ~monclk;    
    
always #(c/2) mem_clk    = ~mem_clk;

localparam tH_ECLK   = $ceil(500000.0/MEMCLK_FREQ);
// The sync clock period can be any clock frequency that is slower than ECLK
localparam tH_SYNCLK = $ceil(2000000.0/MEMCLK_FREQ);

//for write leveling initiated by wl_start_i
always @(posedge sclk_o)
  if (wl_start_i)
    init_wl <= 1'b1;
  else if (wl_done_o)
    init_wl <= 1'b0;

always @(posedge sclk_o)
  wl_done_q <= wl_done_o;
    
assign init_start = init_start_i | init_wl;
assign wl_done_p  = wl_done_o & ~wl_done_q;
assign init_done  = init_done_o | wl_done_p;

// The PLL will provide these signals below and is modeled here if PLL is disabled
initial begin
  eclk_i         = 1'b0;
  pll_lock_i     = 1'b0;
  // The PLL will provide these signals and is modeled here if PLL is disabled
  if (PLL_EN == 0) begin
    @(posedge rst_n_i);        // rst_n_i is controlled in reset task of cmd_gen.v
    repeat(7) @(posedge clk_i);
    repeat(11) #(tH_ECLK) eclk_i   = ~eclk_i;
    pll_lock_i          = 1'b1;
    forever    #(tH_ECLK) eclk_i   = ~eclk_i;
  end
end

initial begin
  sync_clk_i  = 1'b0;
  if (PLL_EN == 0) begin
    forever #(tH_SYNCLK) sync_clk_i   = ~sync_clk_i;
  end
end



// ====================================================================
// This will provide display of the current settings, good for debugging
// ====================================================================

initial begin
   $display ("// ==================================================");
   $display ("INFO: Current Data Bus Width is %0d bits", 15+1);
   $display ("INFO: Current Addr Bus Width is %0d bits", 26+1);
   $display ("INFO: Current User Data Bus Width is %0d bits", 63+1);
   $display ("INFO: Current User Data Mask Bus Width is %0d bits", 7+1);
   $display ("INFO: Current Frequency is %0d MHz", (1000000/c));
   $display ("INFO: Current Clock Period is %2f ns", c/1000.0);
   if (ENB_MEM_RST) begin
   $display ("INFO: Controller Reset to Memory is Enabled!!!");
   end
   else begin
   $display ("INFO: Controller Reset to Memory is Disabled");
   end
 
 `ifdef GATE_SIM
   $display ("INFO: Doing Gate Level Simulation");
 `endif

   $display ("// ==================================================");
end

reg   dm_toggle;       // 0: data mask=0
                       // 1: random pattern on data mask

initial begin
      dm_toggle = 0;
end

always @(dm_toggle) begin
   if (dm_toggle == 0)
      $display ("INFO: Data Mask is Disabled.\n");
   else if (dm_toggle == 1)
      $display ("INFO: Data Mask is Enabled.\n");
end

assign ddr_dqm     = em_ddr_dm_o;
assign inv_ddr_dqs = ~em_ddr_dqs_io;

// =========================================================
// When <Controller Reset to Memory> is unchecked from GUI.
// =========================================================
reg                   clocking_good_r;
reg                   mem_rst_n_r;
reg    [7:0]          rst_cnt;
wire                  ddr3_rst_o;
generate
  if (0==ENB_MEM_RST) begin : CTRL_RST_TO_MEM_OFF
  always @(negedge rst_n_i or posedge sclk_o) begin
   if (!rst_n_i)
      mem_rst_n_r <= 1'b0;
   else
      mem_rst_n_r <= mem_rst_n_i;
  end
  
  always @(negedge rst_n_i or posedge sclk_o) begin
     if (!rst_n_i)
        rst_cnt <= 8'h0;
     else if (rst_cnt == USR_RST_CLK_CNT - 1)
        rst_cnt <= 8'h0;
     else if ((!mem_rst_n_i && mem_rst_n_r) || |(rst_cnt) )
        rst_cnt <= rst_cnt + 1;
     else
        rst_cnt <= rst_cnt;
  end
  
  always @(negedge rst_n_i or posedge sclk_o) begin
     if (!rst_n_i)
        clocking_good_r <= 1'b0;
     else if (clocking_good_o)
        clocking_good_r <= 1'b1;
  end
  
  assign ddr3_rst_o = rst_n_i & mem_rst_n_i & ~|(rst_cnt) & clocking_good_r;
  end
endgenerate

// ====================================================================
// Instantiate the memory controller module
// ====================================================================

`include "dut_inst.v"

//--------------- DIMM 0 --------------------------------------
assign ddr_mem_rst_n_w = (ENB_MEM_RST)? em_ddr_reset_n_o: ddr3_rst_o;

// ====================================================================
// This file has all the tasks used in the tests to generate stimulus on
// the FPGA interface for the DDR memory controller
// ====================================================================

// ====================================================================
// Instantiate the protocol monitor
// ====================================================================
reg endoftest;

initial begin
    endoftest  = 0;
end

wire [1:0]  burst_len;
wire [31:0] mem_write_cnt;
wire [31:0] mem_read_cnt;
wire [3:0]  cas_latency;
wire [3:0]  cas_write_latency;

generate
if (`LOCAL_BUS_TYPE==0) begin : NATIVE_INTERFACE
monitor U1_monitor (
    //.refclk                    (clk_i),
    .refclk                    (monclk),
    .clk                       (sclk_o),
    .mem_clk                   (em_ddr_clk_o[0]),
    .rst_n                     (rst_n_i),
    .mem_rst_n                 (ddr_mem_rst_n_w),
    .endoftest                 (endoftest),
    .cmd                       (cmd_i),
    .cmd_valid                 (cmd_valid_i),
    .dmsel                     (dmsel),
    .dm_toggle                 (dm_toggle),
    .addr                      (addr_i),
    .datain                    (write_data_i),
    .burst_cnt                 (ff_burst_count),
    //.init_start                (init_start_i),
    .init_start                (init_start),
    //.init_done                 (init_done_o),
    .init_done                 (init_done),
    .ar_burst_en               (ar_burst_en),
    .db_size                   (db_size),

    .ddr_cke                   (em_ddr_cke_o[0]),
    .ddr_we_n                  (em_ddr_we_n_o),
    .ddr_cs_n                  (em_ddr_cs_n_o[CS_WIDTH-1:0]),
    .ddr_ad                    (em_ddr_addr_o),
    .ddr_ba                    (em_ddr_ba_o),
    .ddr_ras_n                 (em_ddr_ras_n_o),
    .ddr_cas_n                 (em_ddr_cas_n_o),
`ifdef BOARD_DELAY_ENABLE  
  `ifdef DATA_SIZE_32 
    .ddr_dqm                   ({ddr3mem3_dmi,  ddr3mem2_dmi,  ddr3mem1_dmi,  ddr3mem0_dmi  }),
    .ddr_dq                    ({ddr3mem3_dq,   ddr3mem2_dq,   ddr3mem1_dq,   ddr3mem0_dq   }),   
    .ddr_dqs                   ({ddr3mem3_dqs_t,ddr3mem2_dqs_t,ddr3mem1_dqs_t,ddr3mem0_dqs_t}),
  `elsif DATA_SIZE_24
    .ddr_dqm                   ({ddr3mem2_dmi,  ddr3mem1_dmi,  ddr3mem0_dmi  }),
    .ddr_dq                    ({ddr3mem2_dq,   ddr3mem1_dq,   ddr3mem0_dq   }),   
    .ddr_dqs                   ({ddr3mem2_dqs_t,ddr3mem1_dqs_t,ddr3mem0_dqs_t}),
  `elsif DATA_SIZE_16
    .ddr_dqm                   ({ddr3mem1_dmi,  ddr3mem0_dmi  }),
    .ddr_dq                    ({ddr3mem1_dq,   ddr3mem0_dq   }),   
    .ddr_dqs                   ({ddr3mem1_dqs_t,ddr3mem0_dqs_t}),
  `elsif DATA_SIZE_8
    .ddr_dqm                   (ddr3mem0_dmi  ),
    .ddr_dq                    (ddr3mem0_dq   ),   
    .ddr_dqs                   (ddr3mem0_dqs_t),
  `endif
`else 
    .ddr_dqm                   (ddr_dqm),
    .ddr_dq                    (em_ddr_data_io),
    .ddr_dqs                   (em_ddr_dqs_io),    
`endif    
    .user_clk                  (sclk_o),
    .dataout                   (read_data_o),
    .cmd_rdy                   (cmd_rdy_o),
    .dataout_valid             (read_data_valid_o),
    .datain_valid              (datain_rdy_o),
    .clocking_good             (clocking_good_o),
    .mem_write_cnt             (mem_write_cnt),
    .mem_read_cnt              (mem_read_cnt),
    .burst_len                 (burst_len),
    .cas_latency_true          (cas_latency),
    .cas_write_latency_true    (cas_write_latency),
    .self_ref_done             (self_ref_done),
    .odt_error_flg             (odt_error_flg)
);

odt_watchdog U1_odt_watchdog (
    .mem_clk                   (em_ddr_clk_o[0]),
    .rst_n                     (rst_n_i),
    .ddr_cke                   (em_ddr_cke_o[0]),
    .ddr_cs_n                  (em_ddr_cs_n_o[CS_WIDTH-1 :0]),
    .ddr_ras_n                 (em_ddr_ras_n_o),
    .ddr_cas_n                 (em_ddr_cas_n_o),
    .ddr_we_n                  (em_ddr_we_n_o),
    .ddr_ad                    (em_ddr_addr_o),
    .ddr_ba                    (em_ddr_ba_o),
    .ddr_dqm                   (ddr_dqm),
    .ddr_dq                    (em_ddr_data_io),
    .ddr_dqs                   (em_ddr_dqs_io),
    .ddr_odt                   (em_ddr_odt_o),
    .burst_len                 (burst_len),
    .cas_latency               (cas_latency),
    .cas_write_latency         (cas_write_latency),
    .self_ref_done             (self_ref_done),
    .odt_error_flg             (odt_error_flg)
);

end
else begin : LMMI2AHBL
    lscc_lmmi2ahbl #(
      .DATA_WIDTH         (AHBL_DATA_WIDTH),
      .ADDR_WIDTH         (AHBL_ADDR_WIDTH),
      .CNT_WIDTH          (32)
    )
    u_lscc_lmmi2ahbl (
    .clk_i              (sclk_o),
    .rst_n_i            (rst_n_i),

    .lmmi_request_i     (lmmi_request_i),
    .lmmi_wr_rdn_i      (lmmi_wr_rdn_i),
    .lmmi_offset_i      ({5'hFF, lmmi_offset_i}),
    .lmmi_wdata_i       ({3'hF, lmmi_wdata_i}),

    .lmmi_start_i       (1'b0),
    .lmmi_cnt_i         ('d0),

    .lmmi_rdata_o       (ahbl_lmmi_rdata_w),
    .lmmi_rdata_valid_o (lmmi_data_valid_o),
    .lmmi_ready_o       (lmmi_ready_o),
    .lmmi_error_o       (),

    .ahbl_hready_i      (ahbl_hreadyout_o),
    .ahbl_hresp_i       (ahbl_hresp_o),
    .ahbl_hrdata_i      (ahbl_hrdata_o),

    .ahbl_haddr_o       (ahbl_haddr_i),
    .ahbl_hburst_o      (ahbl_hburst_i),
    .ahbl_hsize_o       (ahbl_hsize_i),
    .ahbl_hmastlock_o   (ahbl_hmastlock_i),
    .ahbl_hprot_o       (ahbl_hprot_i),
    .ahbl_htrans_o      (ahbl_htrans_i),
    .ahbl_hwrite_o      (ahbl_hwrite_i),
    .ahbl_hwdata_o      (ahbl_hwdata_i)
    );
  end
  assign lmmi_rdata_o  = ahbl_lmmi_rdata_w[ldata-1:0];
  assign ahbl_hready_i = 1'b1;
  assign ahbl_hsel_i   = 1'b1;
endgenerate

reg  [DSIZE - 1:0] data_from_memory;
always @(negedge sclk_o)
  if (r_tvalid_o && r_ready_i)
    data_from_memory <= r_tdata_o;

`ifdef BOARD_DELAY_ENABLE 
    if (`LOCAL_BUS_TYPE==0) begin
      assign dram_init_done = tb_top.NATIVE_INTERFACE.U1_monitor.dram_init_done;
      if (CS_WIDTH == 1) begin
          assign cmd_sig_w      = tb_top.NATIVE_INTERFACE.U1_monitor.mon_dbg_0.cmd_sig_w;
      end
      else begin
          assign cmd_sig_w      = tb_top.NATIVE_INTERFACE.U1_monitor.mon_dbg_0.cmd_sig_w & tb_top.NATIVE_INTERFACE.U1_monitor.mon_dbg_1.cmd_sig_w;
      end
      
      `ifndef NO_WRITE_LEVEL
      assign wl_act         = tb_top.NATIVE_INTERFACE.U1_monitor.wl_act;
      `endif
    end
    else begin
      assign dram_init_done = tb_top.LMMI2AHBL.U1_monitor.dram_init_done;
      if (CS_WIDTH == 1) begin
          assign cmd_sig_w      = tb_top.LMMI2AHBL.U1_monitor.mon_dbg_0.cmd_sig_w;
      end
      else begin
          assign cmd_sig_w      = tb_top.LMMI2AHBL.U1_monitor.mon_dbg_0.cmd_sig_w & tb_top.LMMI2AHBL.U1_monitor.mon_dbg_1.cmd_sig_w;
      end
      
      `ifndef NO_WRITE_LEVEL
      assign wl_act         = tb_top.LMMI2AHBL.U1_monitor.wl_act;
      `endif
    end

    always @(*)  begin
        ck_delay[0]    = em_ddr_clk_o  ;
        cke_delay[0]   = em_ddr_cke_o  ;
        cs_n_delay[0]  = em_ddr_cs_n_o ;
        ras_n_delay[0] = em_ddr_ras_n_o;
        cas_n_delay[0] = em_ddr_cas_n_o;
        we_n_delay[0]  = em_ddr_we_n_o ;
        ad_delay[0]    = em_ddr_addr_o ;
        ba_delay[0]    = em_ddr_ba_o   ;
        odt_delay[0]   = em_ddr_odt_o  ;
    end    
    
    generate
      for(dly_i=1; dly_i <=10; dly_i=dly_i+1) begin : CK_DLY
        always @(ck_delay[dly_i-1])  
            ck_delay[dly_i]    = #(`DDR3_MEM00_CK_DEL_10th) ck_delay[dly_i-1];    
 
        always @(cke_delay[dly_i-1])
            cke_delay[dly_i]   = #(`DDR3_MEM00_CK_DEL_10th) cke_delay[dly_i-1];
            
        always @(cs_n_delay[dly_i-1])
             cs_n_delay[dly_i] = #(`DDR3_MEM00_CK_DEL_10th) cs_n_delay[dly_i-1];
        
        always @(ras_n_delay[dly_i-1])
            ras_n_delay[dly_i] = #(`DDR3_MEM00_CK_DEL_10th) ras_n_delay[dly_i-1];
            
        always @(cas_n_delay[dly_i-1])
            cas_n_delay[dly_i] = #(`DDR3_MEM00_CK_DEL_10th) cas_n_delay[dly_i-1];
                        
        always @(we_n_delay[dly_i-1])
            we_n_delay[dly_i]  = #(`DDR3_MEM00_CK_DEL_10th) we_n_delay[dly_i-1];
            
        always @(ad_delay[dly_i-1])
             ad_delay[dly_i]   = #(`DDR3_MEM00_CK_DEL_10th) ad_delay[dly_i-1];
            
        always @(ba_delay[dly_i-1])
             ba_delay[dly_i]   = #(`DDR3_MEM00_CK_DEL_10th) ba_delay[dly_i-1];
        
        always @(odt_delay[dly_i-1])
            odt_delay[dly_i]   = #(`DDR3_MEM00_CK_DEL_10th) odt_delay[dly_i-1];
      end // for loop
    endgenerate
        
    // assign ddr3mem0_ck    = ck_delay[10]   ;
    // assign ddr3mem0_cke   = cke_delay[10]  ;
    // assign ddr3mem0_cs_n  = cs_n_delay[10] ;
    // assign ddr3mem0_ras_n = ras_n_delay[10];
    // assign ddr3mem0_cas_n = cas_n_delay[10];
    // assign ddr3mem0_we_n  = we_n_delay[10] ;
    // assign ddr3mem0_ad    = ad_delay[10]   ;
    // assign ddr3mem0_ba    = ba_delay[10]   ;
    // assign ddr3mem0_odt   = odt_delay[10]  ;

    assign ddr3mem0_ck    = em_ddr_clk_o  ;
    assign ddr3mem0_cke   = em_ddr_cke_o  ;
    assign ddr3mem0_cs_n  = em_ddr_cs_n_o ;
    assign ddr3mem0_ras_n = em_ddr_ras_n_o;
    assign ddr3mem0_cas_n = em_ddr_cas_n_o;
    assign ddr3mem0_we_n  = em_ddr_we_n_o ;
    assign ddr3mem0_ad    = em_ddr_addr_o ;
    assign ddr3mem0_ba    = em_ddr_ba_o   ;
    assign ddr3mem0_odt   = em_ddr_odt_o  ;
       
    generate
        if (DATA_WIDTH >= 8) begin  : DDR3_MEM0       
          // assign ddr3mem0_dqs_ts   = u_ddr3_mc_0.lscc_ddr3_mc_inst.NATIVE_ITF.u0_ddr3_mc_wrapper.U1_ddr3_sdram_phy.phy_wrapper_lscc_ddr_mem.DDR_MEM_32_BIT.u0_lscc_ddr_mem_inst.DW_8.u1_dq_dqs_dm_unit.dqs_outen_n_w;
          // assign ddr3mem0_dq_ts    = u_ddr3_mc_0.lscc_ddr3_mc_inst.NATIVE_ITF.u0_ddr3_mc_wrapper.U1_ddr3_sdram_phy.phy_wrapper_lscc_ddr_mem.DDR_MEM_32_BIT.u0_lscc_ddr_mem_inst.DW_8.u1_dq_dqs_dm_unit.tout_w[7]; //dq
    
          dqs_grp_delay #(
            .WR_DQS_DEL_VALUE   (`DDR3_MEM00_WR_DQS_DEL   ),
            .WR_DQ_DMI_DEL_VALUE(`DDR3_MEM00_WR_DQ_DMI_DEL),
            .RD_DQS_DEL_VALUE   (`DDR3_MEM00_RD_DQS_DEL   ),
            .RD_DQ_DMI_DEL_VALUE(`DDR3_MEM00_RD_DQ_DMI_DEL),
            .NO_WRITE_LEVEL     (NO_WRITE_LEVEL           ),
            .GEAR               (`GEAR                    )
          )
          ddr3mem00_dly (
            .rst_n          (ddr_mem_rst_n_w),
            .mem_clk        (em_ddr_clk_o[0]),
            .cmd_sig_w      (cmd_sig_w      ),
            .dram_init_done (dram_init_done ),
            .wl_act         (wl_act         ),            
            .mc_dqs_t (em_ddr_dqs_io[0]),
            .mc_dqs_c (),
            //.mc_dqs_c (~(em_ddr_dqs_io[0])),
            .mc_dq    (em_ddr_data_io[7:0]),
            .mc_dmi   (em_ddr_dm_o[0] ),
            .mem_dqs_t(ddr3mem0_dqs_t ),
            .mem_dqs_c(ddr3mem0_dqs_c ),
            .mem_dq   (ddr3mem0_dq    ),
            .mem_dmi  (ddr3mem0_dmi   )
          );  
        end
        if (DATA_WIDTH >= 16) begin : DDR3_MEM1
          // assign ddr3mem1_dqs_ts   = u_ddr3_mc_0.lscc_ddr3_mc_inst.NATIVE_ITF.u0_ddr3_mc_wrapper.U1_ddr3_sdram_phy.phy_wrapper_lscc_ddr_mem.DDR_MEM_32_BIT.u0_lscc_ddr_mem_inst.DW_16.u1_dq_dqs_dm_unit.dqs_outen_n_w;
          // assign ddr3mem1_dq_ts    = u_ddr3_mc_0.lscc_ddr3_mc_inst.NATIVE_ITF.u0_ddr3_mc_wrapper.U1_ddr3_sdram_phy.phy_wrapper_lscc_ddr_mem.DDR_MEM_32_BIT.u0_lscc_ddr_mem_inst.DW_16.u1_dq_dqs_dm_unit.tout_w[7]; //dq
          
          dqs_grp_delay #(
            .WR_DQS_DEL_VALUE   (`DDR3_MEM01_WR_DQS_DEL   ),
            .WR_DQ_DMI_DEL_VALUE(`DDR3_MEM01_WR_DQ_DMI_DEL),
            .RD_DQS_DEL_VALUE   (`DDR3_MEM01_RD_DQS_DEL   ),
            .RD_DQ_DMI_DEL_VALUE(`DDR3_MEM01_RD_DQ_DMI_DEL),
            .NO_WRITE_LEVEL     (NO_WRITE_LEVEL           ),
            .GEAR               (`GEAR                    )
          )
          ddr3mem01_dly (
            .rst_n          (ddr_mem_rst_n_w),
            .mem_clk        (em_ddr_clk_o[0]),
            .cmd_sig_w      (cmd_sig_w      ),
            .dram_init_done (dram_init_done ),
            .wl_act         (wl_act         ), 
            .mc_dqs_t (em_ddr_dqs_io[1]),
            .mc_dqs_c (),
            //.mc_dqs_c (~(em_ddr_dqs_io[1])),
            .mc_dq    (em_ddr_data_io[15:8]),
            .mc_dmi   (em_ddr_dm_o[1] ),
            .mem_dqs_t(ddr3mem1_dqs_t ),
            .mem_dqs_c(ddr3mem1_dqs_c ),
            .mem_dq   (ddr3mem1_dq    ),
            .mem_dmi  (ddr3mem1_dmi   )
          );          
        end
        if (DATA_WIDTH >= 24) begin : DDR3_MEM2         
          // assign ddr3mem2_dqs_ts   = u_ddr3_mc_0.lscc_ddr3_mc_inst.NATIVE_ITF.u0_ddr3_mc_wrapper.U1_ddr3_sdram_phy.phy_wrapper_lscc_ddr_mem.DDR_MEM_32_BIT.u0_lscc_ddr_mem_inst.DW_24.u1_dq_dqs_dm_unit.dqs_outen_n_w;
          // assign ddr3mem2_dq_ts    = u_ddr3_mc_0.lscc_ddr3_mc_inst.NATIVE_ITF.u0_ddr3_mc_wrapper.U1_ddr3_sdram_phy.phy_wrapper_lscc_ddr_mem.DDR_MEM_32_BIT.u0_lscc_ddr_mem_inst.DW_24.u1_dq_dqs_dm_unit.tout_w[7]; //dq
          
          dqs_grp_delay #(
            .WR_DQS_DEL_VALUE   (`DDR3_MEM10_WR_DQS_DEL   ),
            .WR_DQ_DMI_DEL_VALUE(`DDR3_MEM10_WR_DQ_DMI_DEL),
            .RD_DQS_DEL_VALUE   (`DDR3_MEM10_RD_DQS_DEL   ),
            .RD_DQ_DMI_DEL_VALUE(`DDR3_MEM10_RD_DQ_DMI_DEL),
            .NO_WRITE_LEVEL     (NO_WRITE_LEVEL           ),
            .GEAR               (`GEAR                    )
          )
          ddr3mem10_dly (
            .rst_n          (ddr_mem_rst_n_w),
            .mem_clk        (em_ddr_clk_o[0]),
            .cmd_sig_w      (cmd_sig_w      ),
            .dram_init_done (dram_init_done ),
            .wl_act         (wl_act         ), 
            .mc_dqs_t (em_ddr_dqs_io[2]),
            .mc_dqs_c (),
            //.mc_dqs_c (~(em_ddr_dqs_io[2])),
            .mc_dq    (em_ddr_data_io[23:16]),
            .mc_dmi   (em_ddr_dm_o[2] ),
            .mem_dqs_t(ddr3mem2_dqs_t ),
            .mem_dqs_c(ddr3mem2_dqs_c ),
            .mem_dq   (ddr3mem2_dq    ),
            .mem_dmi  (ddr3mem2_dmi   )
          );          
        end
        if (DATA_WIDTH >= 32) begin : DDR3_MEM3         
          // assign ddr3mem3_dqs_ts   = u_ddr3_mc_0.lscc_ddr3_mc_inst.NATIVE_ITF.u0_ddr3_mc_wrapper.U1_ddr3_sdram_phy.phy_wrapper_lscc_ddr_mem.DDR_MEM_32_BIT.u0_lscc_ddr_mem_inst.DW_32.u1_dq_dqs_dm_unit.dqs_outen_n_w;
          // assign ddr3mem3_dq_ts    = u_ddr3_mc_0.lscc_ddr3_mc_inst.NATIVE_ITF.u0_ddr3_mc_wrapper.U1_ddr3_sdram_phy.phy_wrapper_lscc_ddr_mem.DDR_MEM_32_BIT.u0_lscc_ddr_mem_inst.DW_32.u1_dq_dqs_dm_unit.tout_w[7]; //dq
          
          dqs_grp_delay #(
            .WR_DQS_DEL_VALUE   (`DDR3_MEM11_WR_DQS_DEL   ),
            .WR_DQ_DMI_DEL_VALUE(`DDR3_MEM11_WR_DQ_DMI_DEL),
            .RD_DQS_DEL_VALUE   (`DDR3_MEM11_RD_DQS_DEL   ),
            .RD_DQ_DMI_DEL_VALUE(`DDR3_MEM11_RD_DQ_DMI_DEL),
            .NO_WRITE_LEVEL     (NO_WRITE_LEVEL           ),
            .GEAR               (`GEAR                    )
          )
          ddr3mem11_dly (
            .rst_n          (ddr_mem_rst_n_w),
            .mem_clk        (em_ddr_clk_o[0]),
            .cmd_sig_w      (cmd_sig_w      ),
            .dram_init_done (dram_init_done ),
            .wl_act         (wl_act         ), 
            .mc_dqs_t (em_ddr_dqs_io[3]),
            .mc_dqs_c (),
            //.mc_dqs_c (~(em_ddr_dqs_io[3])),
            .mc_dq    (em_ddr_data_io[31:24]),
            .mc_dmi   (em_ddr_dm_o[3] ),
            .mem_dqs_t(ddr3mem3_dqs_t ),
            .mem_dqs_c(ddr3mem3_dqs_c ),
            .mem_dq   (ddr3mem3_dq    ),
            .mem_dmi  (ddr3mem3_dmi   )
          );
        end   
    endgenerate
    
    `ifdef DATA_SIZE_32   
    ddr3_dimm_32 U0_ddr3_dimm (
        .rst_n              (ddr_mem_rst_n_w),
        .ddr_dq             ({ddr3mem3_dq[7:0],ddr3mem2_dq[7:0],ddr3mem1_dq[7:0],ddr3mem0_dq[7:0]}),
        .ddr_dqs            ({ddr3mem3_dqs_t,ddr3mem2_dqs_t,ddr3mem1_dqs_t,ddr3mem0_dqs_t}),
        .ddr_dqs_n          ({ddr3mem3_dqs_c,ddr3mem2_dqs_c,ddr3mem1_dqs_c,ddr3mem0_dqs_c}),
        .ddr_dm_tdqs        ({ddr3mem3_dmi  ,ddr3mem2_dmi  ,ddr3mem1_dmi  ,ddr3mem0_dmi  }),
        .ddr_ad             (ddr3mem0_ad),
        .ddr_ba             (ddr3mem0_ba),
        .ddr_ras_n          (ddr3mem0_ras_n),
        .ddr_cas_n          (ddr3mem0_cas_n),
        .ddr_we_n           (ddr3mem0_we_n),
        .ddr_cs_n           (ddr3mem0_cs_n),
        .ddr_clk            (ddr3mem0_ck),
        .ddr_clk_n          (~ddr3mem0_ck),
        .ddr_cke            (ddr3mem0_cke),
        .ddr_odt            (ddr3mem0_odt)
    );
    `endif
    `ifdef DATA_SIZE_24
    ddr3_dimm_24 U0_ddr3_dimm (
        .rst_n              (ddr_mem_rst_n_w),
        .ddr_dq             ({ddr3mem2_dq[7:0],ddr3mem1_dq[7:0],ddr3mem0_dq[7:0]}),
        .ddr_dqs            ({ddr3mem2_dqs_t,ddr3mem1_dqs_t,ddr3mem0_dqs_t}),
        .ddr_dqs_n          ({ddr3mem2_dqs_c,ddr3mem1_dqs_c,ddr3mem0_dqs_c}),
        .ddr_dm_tdqs        ({ddr3mem2_dmi  ,ddr3mem1_dmi  ,ddr3mem0_dmi  }),
        .ddr_ad             (ddr3mem0_ad),
        .ddr_ba             (ddr3mem0_ba),
        .ddr_ras_n          (ddr3mem0_ras_n),
        .ddr_cas_n          (ddr3mem0_cas_n),
        .ddr_we_n           (ddr3mem0_we_n),
        .ddr_cs_n           (ddr3mem0_cs_n),
        .ddr_clk            (ddr3mem0_ck),
        .ddr_clk_n          (~ddr3mem0_ck),
        .ddr_cke            (ddr3mem0_cke),
        .ddr_odt            (ddr3mem0_odt)
    );  
    `endif
    `ifdef DATA_SIZE_16
    ddr3_dimm_16 U0_ddr3_dimm (
        .rst_n              (ddr_mem_rst_n_w),
        .ddr_dq             ({ddr3mem1_dq[7:0],ddr3mem0_dq[7:0]}),
        .ddr_dqs            ({ddr3mem1_dqs_t,ddr3mem0_dqs_t}),
        .ddr_dqs_n          ({ddr3mem1_dqs_c,ddr3mem0_dqs_c}),
        .ddr_dm_tdqs        ({ddr3mem1_dmi  ,ddr3mem0_dmi  }),
        .ddr_ad             (ddr3mem0_ad),
        .ddr_ba             (ddr3mem0_ba),
        .ddr_ras_n          (ddr3mem0_ras_n),
        .ddr_cas_n          (ddr3mem0_cas_n),
        .ddr_we_n           (ddr3mem0_we_n),
        .ddr_cs_n           (ddr3mem0_cs_n),
        .ddr_clk            (ddr3mem0_ck),
        .ddr_clk_n          (~ddr3mem0_ck),
        .ddr_cke            (ddr3mem0_cke),
        .ddr_odt            (ddr3mem0_odt)
    );
    `endif
    `ifdef DATA_SIZE_8
    ddr3_dimm_8 U0_ddr3_dimm (
        .rst_n              (ddr_mem_rst_n_w ),
        .ddr_dq             (ddr3mem0_dq[7:0]),
        .ddr_dqs            (ddr3mem0_dqs_t  ),
        .ddr_dqs_n          (ddr3mem0_dqs_c  ),
        .ddr_dm_tdqs        (ddr3mem0_dmi    ),
        .ddr_ad             (ddr3mem0_ad),
        .ddr_ba             (ddr3mem0_ba),
        .ddr_ras_n          (ddr3mem0_ras_n),
        .ddr_cas_n          (ddr3mem0_cas_n),
        .ddr_we_n           (ddr3mem0_we_n),
        .ddr_cs_n           (ddr3mem0_cs_n),
        .ddr_clk            (ddr3mem0_ck),
        .ddr_clk_n          (~ddr3mem0_ck),
        .ddr_cke            (ddr3mem0_cke),
        .ddr_odt            (ddr3mem0_odt)
    );
    `endif
`else   
    `ifdef DATA_SIZE_32
       ddr3_dimm_32 U0_ddr3_dimm (
    `endif
    `ifdef DATA_SIZE_24
       ddr3_dimm_24 U0_ddr3_dimm (
    `endif
    `ifdef DATA_SIZE_16
       ddr3_dimm_16 U0_ddr3_dimm (
    `endif
    `ifdef DATA_SIZE_8
       ddr3_dimm_8 U0_ddr3_dimm (
    `endif
           .rst_n              (ddr_mem_rst_n_w),
           .ddr_dq             (em_ddr_data_io),
           .ddr_dqs            (em_ddr_dqs_io),
           .ddr_dqs_n          (inv_ddr_dqs),
           .ddr_dm_tdqs        (ddr_dqm),
           .ddr_ad             (em_ddr_addr_o),
           .ddr_ba             (em_ddr_ba_o),
           .ddr_ras_n          (em_ddr_ras_n_o),
           .ddr_cas_n          (em_ddr_cas_n_o),
           .ddr_we_n           (em_ddr_we_n_o),
           .ddr_cs_n           (em_ddr_cs_n_o[CS_WIDTH-1:0]),
           .ddr_clk            (em_ddr_clk_o[CLKO_WIDTH-1:0]),
           .ddr_clk_n          (~em_ddr_clk_o[CLKO_WIDTH-1:0]),
           .ddr_cke            (em_ddr_cke_o[CKE_WIDTH-1:0]),
           .ddr_odt            (em_ddr_odt_o[CS_WIDTH-1:0])
       );

`endif
// ====================================================================
// Initialize the static parameters
// ====================================================================

integer timeout;
reg [63:0] init_time;

initial begin
   timeout = 40000; // in number of clock SCLK cycles
   if (SIM == 0) begin
      $error("Error! Running simulation with SIM=0 is not currently supported. Please follow the procedure below to set SIM=1.");
      $display("  ");
      $display("  Modify the <generated_ip_path>/rtl/<generated_ip_name>.v and set SIM parameter to 1.");
      $display("  For example:");
      $display("      ddr3_mc_0_ipgen_lscc_ddr3_mc #(.INTERFACE_TYPE(\"DDR3\"),");
      $display("          .SIM(1), // Set SIM=1 for simulation only");
      $display("          .GEAR(4),\n");
      $display("  Set SIM=1 local parameter in the file <generated_ip_path>/testbench/dut_params.v as follows:");
      $display("  localparam SIM = 1;");
      $display("  Please refer to Section 3.3. Running Functional Simulation of the IP user guide. for more information.\n");
      $error("============TestBench INFO: SIMULATION Failed=============");
      $stop;
      
// Running the SIM==0 will take at least a whole day to simulate using ModelsimOEM
//     // Calculate the power up and initialization period in terms of SCLK
//     init_time = 750000; // in ns
//     init_time  = init_time * 4000;
//     init_time  = init_time / CLKOP_FREQ_ACTUAL;
//     timeout = timeout * 3;
//     timeout = timeout + init_time;
   end
   repeat (timeout) @(posedge sclk_o);
   $display ("============TestBench INFO: SIMULATION TIMEOUT=============");
   $stop;
end

initial begin
   db_size  = 4'b0001;
end

// Moved these to monitor and odt_watchdog
// set an flag to check if the monitor checking has passed.
//reg error_flg;
//reg odt_error_flg;

//initial begin
//    error_flg = 0;
//    odt_error_flg = 0;
//end

`include "cmd_gen.vh"
// Select only 1 test case
`include "testcase.vh"
//`include "testcase_bank_sweep.vh"

endmodule


`endif