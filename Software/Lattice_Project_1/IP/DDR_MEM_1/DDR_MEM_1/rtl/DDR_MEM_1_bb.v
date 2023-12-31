/*******************************************************************************
    Verilog netlist generated by IPGEN Lattice Radiant Software (64-bit)
    2023.1.1.200.1
    Soft IP Version: 1.4.0
    2023 10 08 01:43:46
*******************************************************************************/
/*******************************************************************************
    Wrapper Module generated per user settings.
*******************************************************************************/
module DDR_MEM_1 (eclk_i, sync_clk_i, sync_rst_i, pll_lock_i, sclk_o,
    sync_update_i, rd_clksel_dqs0_i, rd_clksel_dqs1_i, rd_dqs0_i, rd_dqs1_i,
    selclk_i, pause_i, dq_outen_n_i, data_dqs0_i, data_dqs1_i, dcnt_o, ready_o,
    data_dqs0_o, data_dqs1_o, burst_detect_dqs0_o, burst_detect_dqs1_o,
    burst_detect_sclk_dqs0_o, burst_detect_sclk_dqs1_o, data_valid_dqs0_o,
    data_valid_dqs1_o, dqs_outen_n_dqs0_i, dqs_outen_n_dqs1_i, dqs0_i, dqs1_i,
    data_mask_dqs0_i, data_mask_dqs1_i, csn_din0_i, csn_din1_i, addr_din0_i,
    addr_din1_i, ba_din0_i, ba_din1_i, casn_din0_i, casn_din1_i, rasn_din0_i,
    rasn_din1_i, wen_din0_i, wen_din1_i, odt_din0_i, odt_din1_i, cke_din0_i,
    cke_din1_i, dqwl_dqs0_o, dqwl_dqs1_o, dq_dqs0_io, dq_dqs1_io, dqs0_io,
    dqs1_io, dm_dqs0_o, dm_dqs1_o, ck_o, csn_o, addr_o, ba_o, casn_o, rasn_o,
    wen_o, odt_o, cke_o)/* synthesis syn_black_box syn_declare_black_box=1 */;
    input  eclk_i;
    input  sync_clk_i;
    input  sync_rst_i;
    input  pll_lock_i;
    output  sclk_o;
    input  sync_update_i;
    input  [3:0]  rd_clksel_dqs0_i;
    input  [3:0]  rd_clksel_dqs1_i;
    input  [3:0]  rd_dqs0_i;
    input  [3:0]  rd_dqs1_i;
    input  selclk_i;
    input  pause_i;
    input  [1:0]  dq_outen_n_i;
    input  [31:0]  data_dqs0_i;
    input  [31:0]  data_dqs1_i;
    output  [7:0]  dcnt_o;
    output  ready_o;
    output  [31:0]  data_dqs0_o;
    output  [31:0]  data_dqs1_o;
    output  burst_detect_dqs0_o;
    output  burst_detect_dqs1_o;
    output  burst_detect_sclk_dqs0_o;
    output  burst_detect_sclk_dqs1_o;
    output  data_valid_dqs0_o;
    output  data_valid_dqs1_o;
    input  [1:0]  dqs_outen_n_dqs0_i;
    input  [1:0]  dqs_outen_n_dqs1_i;
    input  [1:0]  dqs0_i;
    input  [1:0]  dqs1_i;
    input  [3:0]  data_mask_dqs0_i;
    input  [3:0]  data_mask_dqs1_i;
    input  [0:0]  csn_din0_i;
    input  [0:0]  csn_din1_i;
    input  [13:0]  addr_din0_i;
    input  [13:0]  addr_din1_i;
    input  [2:0]  ba_din0_i;
    input  [2:0]  ba_din1_i;
    input  casn_din0_i;
    input  casn_din1_i;
    input  rasn_din0_i;
    input  rasn_din1_i;
    input  wen_din0_i;
    input  wen_din1_i;
    input  [0:0]  odt_din0_i;
    input  [0:0]  odt_din1_i;
    input  [0:0]  cke_din0_i;
    input  [0:0]  cke_din1_i;
    output  [7:0]  dqwl_dqs0_o;
    output  [7:0]  dqwl_dqs1_o;
    inout  [7:0]  dq_dqs0_io;
    inout  [7:0]  dq_dqs1_io;
    inout  dqs0_io;
    inout  dqs1_io;
    output  dm_dqs0_o;
    output  dm_dqs1_o;
    output  [0:0]  ck_o;
    output  [0:0]  csn_o;
    output  [13:0]  addr_o;
    output  [2:0]  ba_o;
    output  casn_o;
    output  rasn_o;
    output  wen_o;
    output  [0:0]  odt_o;
    output  [0:0]  cke_o;
endmodule