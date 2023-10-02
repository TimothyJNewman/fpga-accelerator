`ifndef LSCC_TIMEOUT_GEN
`define LSCC_TIMEOUT_GEN

`timescale 1 ns / 1 ns

module lscc_timeout_gen # (
    parameter TIMEOUT = 8000
)(
    input clk_i,
    input rst_i
);

reg [31:0] counter_r;
reg clk10k_r;

always @ (posedge clk_i, posedge rst_i) begin
    if(rst_i) begin
        counter_r <= {32{1'b0}};
    end
    else begin
        counter_r <= counter_r + 1'b1;
    end
end

always @ (*) begin
    if(counter_r >= TIMEOUT) begin
        $display("TIME-OUT");
        $finish;
    end
end

initial begin
    clk10k_r <= 1'b0;
    #10000;
    clk10k_r <= 1'b1;
    forever #5000 clk10k_r <= ~clk10k_r;
end

always @ (posedge clk10k_r) begin
    $display("10000ns lapsed");
end

endmodule
`endif