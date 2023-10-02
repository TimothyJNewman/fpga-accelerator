`ifndef LSCC_testcase
`define LSCC_testcase
// =============================================================================
//                           COPYRIGHT NOTICE
// Copyright 2008 (c) Lattice Semiconductor Corporation
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
//                         FILE DETAILS
// Project          : DDR3 SDRAM Controller
// File             : ddr_test_01.v
// Title            : Data Mask Test Case
// Dependencies     : 
// Description      : This is the GOLDEN Test. It issues basic commands like 
//                    Power down Self Ref, Load MR, INIT, WR and RD.                    
// =============================================================================

// load_mr       (cmd_valid_lat, bl, bt, cl, wr)
// write         (cmd_valid_lat, burst_count, row_addr, bank_addr, col_addr, bl_mem, ofly_burst_len)
// read          (cmd_valid_lat, burst_count, row_addr, bank_addr, col_addr, bl_mem, ofly_burst_len)
// reg [8*20:1] whereami;
initial begin
    reset;
    #(20*c); // 100ns

    
if (LOCAL_BUS_TYPE==1) begin
    enableInt(0); //enable init_done interrupt
// // initialize the memory, the default burst length is 4    
    init_lmmi;
    #(`DELAY*c);
	#(10*c); // 5ns
    clearInt(0);
    pdown_lmmi;  
    #(`DELAY*c);
    pdown_ext_lmmi;
    #(`DELAY*c);
	
	// m_write(CmdR, {cmd_burst_cnt, ofly_burst_len, 4'b0010, CmdR});
	
    // write (singleWrite, addr, cmd_burst_cnt, ofly_burst_len, wrData)l
	// whereami = "startWrite1";
	w_tdata_i={{(DSIZE/8){lo}}, {(DSIZE/2){2'b10}}};
	w_tvalid_i        = 1;
	m_write({27'd5120}, CmdR, {5'b1, lo, 4'b0010});
	@(negedge w_ready_o);
	w_tvalid_i        = 0;
    repeat (2) @(posedge sclk_o);
	// whereami = "wait W_READY";
	// @(posedge W_READY);
	// whereami = "wait cmd_rdy";
    repeat (20) @(posedge sclk_o);
	// @(posedge tb_top.u_may26.lscc_ddr3_mc_inst.cmd_rdy);
	repeat (5) @(posedge sclk_o);
	// whereami = "startWrite2";
	w_tvalid_i        = 1;
	w_tdata_i={{(DSIZE/8){lo}}, {(DSIZE/2){2'b01}}};
	m_write({27'd0}, CmdR, {5'b1, lo, 4'b0010}); // Writes in to 
	@(negedge w_ready_o);
	w_tvalid_i        = 0;
    repeat (27) @(posedge sclk_o);
	w_tvalid_i        = 1;
	w_tdata_i={{(DSIZE/8){lo}}, {(DSIZE/2){2'b01}}};
	m_write({27'd0}, CmdR, {5'b1, lo, 4'b0010}); // Writes in to 
	@(negedge w_ready_o);
	w_tvalid_i        = 0;
    repeat (2) @(posedge sclk_o);
	// whereami = "startREAD1";
	m_write({27'd0}, CmdR, {5'b1, lo, 4'b0001}); // 
//                         burst  |     READ
//                           ofly_burst_len
	
    repeat (5) @(posedge sclk_o);
	@(posedge tb_top.r_tvalid_o);
	repeat (2) @(posedge sclk_o);
	r_ready_i = 1;
	// whereami = "r_ready_i=1";
	repeat (5) @(posedge sclk_o);
	r_ready_i = 0;
	// whereami = "r_ready_i=0";
 
    #(500*c);
	// whereami = "500*c";
	#(500*c);
    endoftest = 1;
    #c;
	// whereami = "endoftest=1";
    endoftest = 0;
  if (data_from_memory == {(DSIZE/2){2'b01}}) 
    $display("SIMULATION PASSED");
  else
    $display("Simulation failed");
end else 
begin
// LOCAL_BUS_TYPE = 0, legacy User I/F
    init;
    #(`DELAY*c);

    #(250*c);
    dm_toggle = 0;
    #(50*c);
//    dm_toggle = 1;

  // power down
    pdown        (0);
    #(`DELAY*c);
    pdown_ext    (0);
    #(`DELAY*c);


    write       (0, 8, 0, 5, 0, 0);
    read        (0, 8, 0, 5, 0, 0);
    #(20*c);
    write       (0, 1, 0, 4, 0, 0);
    write       (0, 1, 0, 4, 1, 0);
    write       (0, 1, 0, 4, 2, 0);
    write       (0, 1, 0, 4, 3, 0);
    write       (0, 1, 0, 4, 4, 0);
    write       (0, 1, 0, 4, 5, 0);
    write       (0, 1, 0, 4, 6, 0);
    write       (0, 1, 0, 4, 7, 0);
    write       (0, 1, 0, 4, 8, 0);

////////////////////////////////////////////////////////////
    $display("@ %10d: Column sweep with bank sweep started", $time);
    cs_addr  = 0;
    col_addr = 'h0;
// increment burst + increment bank + row A + Rank=0
    write       (0, 1, 'hBCA, 0, col_addr, 0);
    write       (0, 2, 'hBCA, 1, col_addr, 0);
    write       (0, 3, 'hBCA, 2, col_addr, 0);
    write       (0, 4, 'hBCA, 3, col_addr, 0);
    write       (0, 5, 'hBCA, 4, col_addr, 0);
    write       (0, 6, 'hBCA, 5, col_addr, 0);
    write       (0, 7, 'hBCA, 6, col_addr, 0);
    write       (0, 8, 'hBCA, 7, col_addr, 0);
    if (CS_WIDTH == 2) begin
        cs_addr  = 1;
        col_addr = 'h0;
    end
    else begin
        cs_addr  = 0;
        col_addr = 'h200; // move column address to avoid address conflict
    end
// increment burst + increment bank + row A + Rank=1 (or Rank=0, col X)
    write       (0,  9, 'hBCA, 0, col_addr, 0);
    write       (0, 10, 'hBCA, 1, col_addr, 0);
    write       (0, 11, 'hBCA, 2, col_addr, 0);
    write       (0, 12, 'hBCA, 3, col_addr, 0);
    write       (0, 13, 'hBCA, 4, col_addr, 0);
    write       (0, 14, 'hBCA, 5, col_addr, 0);
    write       (0, 15, 'hBCA, 6, col_addr, 0);
    write       (0, 16, 'hBCA, 7, col_addr, 0);
    cs_addr  = 0;
    col_addr = 'h0;
// increment burst + increment bank + row B + Rank=0
    write       (0, 17, 'h321, 0, col_addr, 0);
    write       (0, 18, 'h321, 1, col_addr, 0);
    write       (0, 19, 'h321, 2, col_addr, 0);
    write       (0, 20, 'h321, 3, col_addr, 0);
    write       (0, 21, 'h321, 4, col_addr, 0);
    write       (0, 22, 'h321, 5, col_addr, 0);
    write       (0, 23, 'h321, 6, col_addr, 0);
    write       (0, 24, 'h321, 7, col_addr, 0);
    if (CS_WIDTH == 2) begin
        cs_addr  = 1;
        col_addr = 'h0;
    end
    else begin
        cs_addr  = 0;
        col_addr = 'h200; // move column address to avoid address conflict
    end
// increment burst + increment bank + row B + Rank=1 (or Rank=0, col X)
    write       (0, 25, 'h321, 0, col_addr, 0);
    write       (0, 26, 'h321, 1, col_addr, 0);
    write       (0, 27, 'h321, 2, col_addr, 0);
    write       (0, 28, 'h321, 3, col_addr, 0);
    write       (0, 29, 'h321, 4, col_addr, 0);
    write       (0, 30, 'h321, 5, col_addr, 0);
    write       (0, 31, 'h321, 6, col_addr, 0);
    write       (0, 32, 'h321, 7, col_addr, 0);

// Read and check the written data
    cs_addr  = 0;
    col_addr = 'h0;
// increment burst + increment bank + row A + Rank=0
    read        (0, 1, 'hBCA, 0, col_addr, 0);
    read        (0, 2, 'hBCA, 1, col_addr, 0);
    read        (0, 3, 'hBCA, 2, col_addr, 0);
    read        (0, 4, 'hBCA, 3, col_addr, 0);
    read        (0, 5, 'hBCA, 4, col_addr, 0);
    read        (0, 6, 'hBCA, 5, col_addr, 0);
    read        (0, 7, 'hBCA, 6, col_addr, 0);
    read        (0, 8, 'hBCA, 7, col_addr, 0);
    if (CS_WIDTH == 2) begin
        cs_addr  = 1;
        col_addr = 'h0;
    end
    else begin
        cs_addr  = 0;
        col_addr = 'h200; // move column address to avoid address conflict
    end
    read        (0,  9, 'hBCA, 0, col_addr, 0);
    read        (0, 10, 'hBCA, 1, col_addr, 0);
    read        (0, 11, 'hBCA, 2, col_addr, 0);
    read        (0, 12, 'hBCA, 3, col_addr, 0);
    read        (0, 13, 'hBCA, 4, col_addr, 0);
    read        (0, 14, 'hBCA, 5, col_addr, 0);
    read        (0, 15, 'hBCA, 6, col_addr, 0);
    read        (0, 16, 'hBCA, 7, col_addr, 0);
// increment burst + check bank and rank switch, row set 2
    cs_addr  = 0;
    col_addr = 'h0;
    read        (0, 17, 'h321, 0, col_addr, 0);
    read        (0, 18, 'h321, 1, col_addr, 0);
    read        (0, 19, 'h321, 2, col_addr, 0);
    read        (0, 20, 'h321, 3, col_addr, 0);
    read        (0, 21, 'h321, 4, col_addr, 0);
    read        (0, 22, 'h321, 5, col_addr, 0);
    read        (0, 23, 'h321, 6, col_addr, 0);
    read        (0, 24, 'h321, 7, col_addr, 0);
    if (CS_WIDTH == 2) begin
        cs_addr  = 1;
        col_addr = 'h0;
    end
    else begin
        cs_addr  = 0;
        col_addr = 'h200; // move column address to avoid address conflict
    end
    read        (0, 25, 'h321, 0, col_addr, 0);
    read        (0, 26, 'h321, 1, col_addr, 0);
    read        (0, 27, 'h321, 2, col_addr, 0);
    read        (0, 28, 'h321, 3, col_addr, 0);
    read        (0, 29, 'h321, 4, col_addr, 0);
    read        (0, 30, 'h321, 5, col_addr, 0);
    read        (0, 31, 'h321, 6, col_addr, 0);
    read        (0, 32, 'h321, 7, col_addr, 0);
    $display("@ %10d: Column sweep with bank sweep ended", $time);

////////////////////////////////////////////////////////////

    if (PLL_EXT_RESET_EN == 1 && EXT_AUTO_REF == 1) begin
    $display("@ %10d: PLL reset checking start", $time);
    #(250*c)
    
    @(negedge monclk) clk_i_min = 1;
    
    for(i=20; i <=1000; i=i+20) begin
      ckl_i_min_period = i;
      repeat(50) @(negedge monclk);
      if (!clocking_good_o)
        i = 1000;
    end  
    
    @(negedge monclk) clk_i_min = 0;
    // clk_i_stop = 1;
    
    // repeat(300) @(negedge monclk);
    // clk_i_stop = 0;
    
    #(100*c)
    pll_rst_n_i          = 0;
    #(100*c)
    pll_rst_n_i          = 1;
    #(100*c)
       
    wait(clocking_good_o);

    #(100*c)
    @(posedge sclk_o);
    ext_auto_ref_i = 1;
    
    wait (ext_auto_ref_ack_o);

    @(posedge sclk_o);
    ext_auto_ref_i = 0;

    #(1000*c)
    @(posedge sclk_o)   wl_start_i = 1;
    @(posedge sclk_o)   wl_start_i = 0;
   
    wait (wl_done_o);
    
    $display("@ %10d: PLL reset checking ended", $time);
    end
    
    else if (PLL_EXT_RESET_EN == 0 && EXT_AUTO_REF == 1) begin
    $display("@ %10d: External refresh port checking start", $time);
    
    #(100*c)
    @(posedge sclk_o);
    ext_auto_ref_i = 1;
    
    wait (ext_auto_ref_ack_o);

    @(posedge sclk_o);
    ext_auto_ref_i = 0;
    
    $display("@ %10d: External refresh port checking ended", $time);
    end
////////////////////////////////////////////////////////////
//  burst chop 4 operation
    #(250*c);
    write       (0, 1, 0, 0, 0, 0);
    #(`DELAY*c);

    #(250*c)
    dm_toggle = 1;
    #(50*c);

// burst count 1
    write       (0, 1, 3, 2, 8, 0);
    write       (0, 1, 4, 2, 0, 0);
    write       (0, 1, 5, 2, 0, 0);
    write       (0, 1, 6, 2, 0, 0);
    #(`DELAY*c);
    read        (0, 1, 3, 2, 8, 0);
    #(`DELAY*c);
    write       (0, 1, 3, 2, 0, 0);
    #(`DELAY*c);
// burst count N
    write       (0, 15, 1, 0, 0, 0);
    #(`DELAY*c);
    write       (0, 8, 2, 2, 8, 0);
    #(`DELAY*c);
    read        (0, 12, 1, 0, 0, 0);
    #(`DELAY*c);
    read        (0, 8, 2, 2, 8, 0);
    #(`DELAY*c);

    #(500*c)
    dm_toggle = 0;
    #(50*c);
//    dm_toggle = 1;

   // To check BC4 single cmd stream (1 eclk gap case)
    write       (0, 1, 0, 7, 0, 0);
    write       (0, 1, 0, 7, 1, 0);
    write       (0, 1, 0, 7, 2, 0);
    write       (0, 1, 0, 7, 3, 0);
    write       (0, 1, 0, 7, 4, 0);
    write       (0, 1, 0, 7, 5, 0);
    write       (0, 1, 0, 7, 6, 0);
    write       (0, 1, 0, 7, 7, 0);
    write       (0, 1, 0, 7, 8, 0);
    read        (0, 1, 0, 7, 0, 0);
    read        (0, 1, 0, 7, 1, 0);
    read        (0, 1, 0, 7, 2, 0);
    read        (0, 1, 0, 7, 3, 0);
    read        (0, 1, 0, 7, 4, 0);
    read        (0, 1, 0, 7, 5, 0);
    read        (0, 1, 0, 7, 6, 0);
    read        (0, 1, 0, 7, 7, 0);
    read        (0, 1, 0, 7, 8, 0);

// change burst length to 8
  // load_mr0     (0, 8, 0, 6, 6);
  //load_mr0     (0, 8, 0, 6, `TWR*`X_FAC);
    #(`DELAY*c);

// burst count 1
    write       (0, 1, 3, 0, 0, 0);
    #(`DELAY*c);
    read        (0, 1, 3, 0, 0, 0);
   #(`DELAY*c);
    write       (0, 2, 3, 0, 0, 0);
   #(`DELAY*c); 
    read        (0, 2, 3, 0, 0, 0);
    #(`DELAY*c);
    writea      (0, 1, 3, 2, 12, 0);
    #(`DELAY*c);
    read        (0, 1, 3, 2, 12, 0);
    #(`DELAY*c);
////// burst count N
    write       (0, 31, 15, 0, 0, 0);
    #(`DELAY*c);
    write       (0, 3, 2, 0, 8, 0);
    #(`DELAY*c);
    read        (0, 31, 15, 0, 0, 0);
    #(`DELAY*c);
    read        (0, 3, 2, 0, 8, 0);
   #(`DELAY*c);
   #(500*c);

   // To check BL8 single cmd stream (1 eclk gap case)
    write       (0, 1, 0, 6, 0, 0); 
    write       (0, 1, 0, 6, 1, 0); 
    write       (0, 1, 0, 6, 2, 0); 
    #(500*c)
    dm_toggle = 1;
    #(50*c);
    write       (0, 1, 0, 6, 3, 0);
    write       (0, 1, 0, 6, 4, 0);
    write       (0, 1, 0, 6, 5, 0);
    write       (0, 1, 0, 6, 6, 0);
    write       (0, 1, 0, 6, 7, 0);
    write       (0, 1, 0, 6, 8, 0);

    read        (0, 1, 0, 6, 0, 0); 
    read        (0, 1, 0, 6, 1, 0); 
    read        (0, 1, 0, 6, 2, 0); 

    read        (0, 1, 0, 6, 3, 0);
    read        (0, 1, 0, 6, 4, 0);
    read        (0, 1, 0, 6, 5, 0);
    read        (0, 1, 0, 6, 6, 0);
    read        (0, 1, 0, 6, 7, 0);
    read        (0, 1, 0, 6, 8, 0);



   // power down
   // Uncomment when defined CL macro value???
    // pdown        (0);
    // #(`DELAY*c);
    // pdown_ext    (0);
    // #(`DELAY*c);

       // load_mr0      (cmd_valid_lat, bl, bt, cl, wr)
       
       // What is CL macro value???
   // load_mr0      (0, 8, 0, `CL*2, `TWR*2);
   // //load_mr0      (0, 8, 0, `CL*2, `TWR*`X_FAC);
    // #(`DELAY*c);


    // write (0, 1, 0, 1, 0, 0);
    // read  (0, 1, 0, 1, 0, 0);
    // read  (0, 1, 0, 1, 0, 0);
    // read  (0, 1, 0, 1, 0, 0);

// // To check tWTR compliance. Effective if CMD_VALID_TYPE1 is defined.
  // load_mr0     (0, 0, 0, 6, 6);
  // //load_mr0     (0, 0, 0, 6, `TWR*`X_FAC);
    // write       (0, 1, 0, 4, 0, 1);
    // write       (0, 1, 0, 4, 1, 1);
    // write       (0, 1, 0, 4, 2, 1);
    // read        (0, 1, 0, 4, 1, 1);
    // read        (0, 1, 0, 4, 0, 1);


    #(500*c);
    endoftest = 1;
    #c;
    endoftest = 0;
end
// $stop;
$finish;

end

`endif