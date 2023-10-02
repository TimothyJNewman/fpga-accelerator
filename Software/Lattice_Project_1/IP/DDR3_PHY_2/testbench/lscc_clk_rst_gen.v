`ifndef LSCC_CLK_RST_GEN
`define LSCC_CLK_RST_GEN

`timescale 1 ps / 1 ps

module lscc_clk_rst_gen # (
    parameter ECLK     = 400,
    parameter SYN_CLK  = 50,
    parameter RST_CNTR = 35000
)(
    output reg eclk_o,
    output reg sync_clk_o,
    output reg global_rst_o,
    output reg global_rst_n_o
);

localparam ECLK_HP    = 500000 / ECLK;
localparam SYNCLK_HP  = 500000 / SYN_CLK;

initial begin
    eclk_o <= 1'b0;
    forever #ECLK_HP eclk_o <= ~eclk_o;
end

initial begin
    sync_clk_o <= 1'b0;
    forever #SYNCLK_HP sync_clk_o <= ~sync_clk_o;
end

initial begin
    global_rst_n_o <= 1'b0;
    global_rst_o   <= 1'b1;
    #RST_CNTR;
    global_rst_n_o <= 1'b1;
    global_rst_o   <= 1'b0;
end

endmodule
`endif