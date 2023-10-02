/*******************************************************************************
    Verilog netlist generated by IPGEN Lattice Radiant Software (64-bit)
    2023.1.1.200.1
    Soft IP Version: 1.5.0
    2023 10 02 06:36:57
*******************************************************************************/
/*******************************************************************************
    Wrapper Module generated per user settings.
*******************************************************************************/
module I2C_DPHY_1 (scl_io, sda_io, clk_i, rst_n_i, lmmi_request_i,
    lmmi_wr_rdn_i, lmmi_offset_i, lmmi_wdata_i, lmmi_rdata_o,
    lmmi_rdata_valid_o, lmmi_ready_o, int_o)/* synthesis syn_black_box syn_declare_black_box=1 */;
    inout  scl_io;
    inout  sda_io;
    input  clk_i;
    input  rst_n_i;
    input  lmmi_request_i;
    input  lmmi_wr_rdn_i;
    input  [3:0]  lmmi_offset_i;
    input  [7:0]  lmmi_wdata_i;
    output  [7:0]  lmmi_rdata_o;
    output  lmmi_rdata_valid_o;
    output  lmmi_ready_o;
    output  int_o;
endmodule