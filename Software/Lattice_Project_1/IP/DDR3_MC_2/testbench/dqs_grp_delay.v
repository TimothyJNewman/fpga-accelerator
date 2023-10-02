`timescale 100 fs / 100 fs

module dqs_grp_delay_prim #( 
  parameter WR_DEL_VALUE = 0,
  parameter RD_DEL_VALUE = 0
)
(
  input rst_n,
  input ts,
  inout mc_io,
  inout mem_io
);

  localparam WR_DEL_VALUE_10th = WR_DEL_VALUE/10;
  localparam RD_DEL_VALUE_10th = RD_DEL_VALUE/10;
  reg        wr_ts_dly;
  reg        rd_ts_dly;
  reg [10:0] mc2mem;
  reg [10:0] mem2mc;

  genvar i;
  
  always @(posedge ts or negedge ts)
    wr_ts_dly = #(WR_DEL_VALUE) ts;

  always @(posedge ts or negedge ts)
    rd_ts_dly = #(RD_DEL_VALUE + WR_DEL_VALUE) ts;
    
  always @(*) begin
    mc2mem[0] = mc_io;
    mem2mc[0] = mem_io;
  end
  
  generate   
    for(i=1; i<=10; i=i+1) begin : DLY
      always @(posedge mc2mem[i-1] or negedge mc2mem[i-1])
        mc2mem[i] = #(WR_DEL_VALUE_10th) mc2mem[i-1];
            
      always @(posedge mem2mc[i-1] or negedge mem2mc[i-1])
        mem2mc[i] = #(RD_DEL_VALUE_10th) mem2mc[i-1];
    end
  endgenerate
//  localparam DEL_VALUE_TS = DEL_VALUE + 1;
//  wire ts_dly;
//  wire mc2mem;
//  wire mem2mc;
//  
//  assign #(DEL_VALUE_TS) ts_dly = ts;
//  
//  assign #(DEL_VALUE)    mc2mem = mc_io;
//    
//  assign #(DEL_VALUE)    mem2mc = mem_io;
  
  assign mem_io = wr_ts_dly ? 1'bz       : mc2mem[10];
  //assign mc_io  = rd_ts_dly ? mem2mc[10] : 1'bz;
  assign mc_io  = (ts && wr_ts_dly && rd_ts_dly) ? mem2mc[10] : 1'bz;
 
endmodule

module dqs_grp_delay #(
  parameter  WR_DQS_DEL_VALUE     = 0,
  parameter  WR_DQ_DMI_DEL_VALUE  = 0,
  parameter  RD_DQS_DEL_VALUE     = 0,
  parameter  RD_DQ_DMI_DEL_VALUE  = 0,
  parameter  NO_WRITE_LEVEL       = 0,
  parameter  GEAR                 = 4
)
(
  input       rst_n,
  input       mem_clk,
  input [5:0] cmd_sig_w,
  input       dram_init_done,
  input       wl_act,
  
  inout       mc_dqs_t,
  inout       mc_dqs_c,
  inout [7:0] mc_dq,
  inout       mc_dmi,
  inout       mem_dqs_t,
  inout       mem_dqs_c,
  inout [7:0] mem_dq,
  inout       mem_dmi
);
  
  wire        dqs_ts;
  wire        dq_ts;
  wire        dqs_c;
  wire        ddr_write_n;
  
  reg         ddr_wr_n;
  reg [2:0]   ddr_wr_n_q;

  initial begin
    ddr_wr_n = 1'b1;
    ddr_wr_n_q = 3'b111;
  end
  
  always @(posedge mem_clk)
    if (cmd_sig_w == 6'b11_0100)
      ddr_wr_n <= 0;
    else if (cmd_sig_w == 6'b11_0111)
      ddr_wr_n <= ddr_wr_n;
    else
      ddr_wr_n <= 1;

  always @(posedge mem_clk)
    ddr_wr_n_q <= {ddr_wr_n_q[1:0], ddr_wr_n};

  assign ddr_write_n = (GEAR == 4) ? ddr_wr_n : ddr_wr_n_q[2];

  if (NO_WRITE_LEVEL)
    assign dqs_ts = ~dram_init_done ? |cmd_sig_w : ddr_write_n;
  else
    assign dqs_ts = ~dram_init_done ? |cmd_sig_w : (~wl_act & ddr_write_n);
  
  assign dq_ts  = ~dram_init_done ? |cmd_sig_w : ddr_write_n;
  assign dqs_c  = (mc_dqs_t === 1'bz) || dqs_ts ? 1'bz : ~mc_dqs_t;

  dqs_grp_delay_prim #( 
    .WR_DEL_VALUE(WR_DQS_DEL_VALUE),
    .RD_DEL_VALUE(RD_DQS_DEL_VALUE)
  ) u_dqst_del (
    .rst_n (rst_n    ),
    .ts    (dqs_ts   ),
    .mc_io (mc_dqs_t ),
    .mem_io(mem_dqs_t)
  );
  
  dqs_grp_delay_prim #( 
    .WR_DEL_VALUE(WR_DQS_DEL_VALUE),
    .RD_DEL_VALUE(RD_DQS_DEL_VALUE)
  ) u_dqsc_del (
    .rst_n (rst_n    ),
    .ts    (dqs_ts   ),
    .mc_io (dqs_c    ),
    .mem_io(mem_dqs_c)
  );

  genvar i;
  generate
    for (i=0; i<8;i=i+1) begin : DQ_DEL
      dqs_grp_delay_prim #( 
        .WR_DEL_VALUE(WR_DQ_DMI_DEL_VALUE),
        .RD_DEL_VALUE(RD_DQ_DMI_DEL_VALUE)
      ) u_dq_del (
        .rst_n (rst_n    ),
        .ts    (dq_ts    ),
        .mc_io (mc_dq[i] ),
        .mem_io(mem_dq[i])
      );
    end
  endgenerate


  dqs_grp_delay_prim #( 
    .WR_DEL_VALUE(WR_DQ_DMI_DEL_VALUE),
    .RD_DEL_VALUE(RD_DQ_DMI_DEL_VALUE)
  ) u_dmi_del (
    .rst_n (rst_n  ),
    .ts    (dq_ts  ),
    .mc_io (mc_dmi ),
    .mem_io(mem_dmi)
  );

endmodule