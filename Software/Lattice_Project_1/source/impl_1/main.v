module main (dq_dqs0_io,
dq_dqs1_io,
dqs0_io,
dqs1_io,
DDR_MEM_1_ck_o,
DDR_MEM_1_csn_o,
DDR_MEM_1_addr_o,
DDR_MEM_1_ba_o,
DDR_MEM_1_casn_o,
DDR_MEM_1_rasn_o,
DDR_MEM_1_wen_o,
DDR_MEM_1_odt_o,
DDR_MEM_1_cke_o,
MIPI_DPHY_1_clk_p_io,
MIPI_DPHY_1_clk_n_io,
MIPI_DPHY_1_data_p_io,
MIPI_DPHY_1_data_n_io,
MIPI_DPHY_2_clk_p_io,
MIPI_DPHY_2_clk_n_io,
MIPI_DPHY_2_data_p_io,
MIPI_DPHY_2_data_n_io,
I2C_DPHY_1_scl_io,
I2C_DPHY_1_sda_io,
I2C_DPHY_2_scl_io,
I2C_DPHY_2_sda_io);

wire DDR_MEM_1_eclk_i;
wire DDR_MEM_1_sync_clk_i;
wire DDR_MEM_1_sync_rst_i;
wire DDR_MEM_1_pll_lock_i;
wire DDR_MEM_1_pll_refclk_i ; 
wire DDR_MEM_1_pll_rst_n_i ; 
wire DDR_MEM_1_pll_lock_o ; 
wire DDR_MEM_1_sclk_o ; 
wire DDR_MEM_1_sync_update_i ; 
wire [3:0] DDR_MEM_1_rd_clksel_dqs0_i ; 
wire [3:0] DDR_MEM_1_rd_clksel_dqs1_i ; 
wire [3:0] DDR_MEM_1_rd_dqs0_i ; 
wire [3:0] DDR_MEM_1_rd_dqs1_i ; 
wire DDR_MEM_1_selclk_i ; 
wire DDR_MEM_1_pause_i ; 
wire [1:0] DDR_MEM_1_dq_outen_n_i ; 
wire [31:0] DDR_MEM_1_data_dqs0_i ; 
wire [31:0] DDR_MEM_1_data_dqs1_i ; 
wire [7:0] DDR_MEM_1_dcnt_o ; 
wire DDR_MEM_1_ready_o ; 
wire [31:0] DDR_MEM_1_data_dqs0_o ; 
wire [31:0] DDR_MEM_1_data_dqs1_o ; 
wire DDR_MEM_1_burst_detect_dqs0_o ; 
wire DDR_MEM_1_burst_detect_dqs1_o ; 
wire DDR_MEM_1_burst_detect_sclk_dqs0_o ; 
wire DDR_MEM_1_burst_detect_sclk_dqs1_o ; 
wire DDR_MEM_1_data_valid_dqs0_o ; 
wire DDR_MEM_1_data_valid_dqs1_o ; 
wire [1:0] DDR_MEM_1_dqs_outen_n_dqs0_i ; 
wire [1:0] DDR_MEM_1_dqs_outen_n_dqs1_i ; 
wire [1:0] DDR_MEM_1_dqs0_i ; 
wire [1:0] DDR_MEM_1_dqs1_i ; 
wire [0:0] DDR_MEM_1_csn_din0_i ; 
wire [0:0] DDR_MEM_1_csn_din1_i ; 
wire [12:0] DDR_MEM_1_addr_din0_i ; 
wire [12:0] DDR_MEM_1_addr_din1_i ; 
wire [2:0] DDR_MEM_1_ba_din0_i ; 
wire [2:0] DDR_MEM_1_ba_din1_i ; 
wire DDR_MEM_1_casn_din0_i ; 
wire DDR_MEM_1_casn_din1_i ; 
wire DDR_MEM_1_rasn_din0_i ; 
wire DDR_MEM_1_rasn_din1_i ; 
wire DDR_MEM_1_wen_din0_i ; 
wire DDR_MEM_1_wen_din1_i ; 
wire [0:0] DDR_MEM_1_odt_din0_i ; 
wire [0:0] DDR_MEM_1_odt_din1_i ; 
wire [0:0] DDR_MEM_1_cke_din0_i ; 
wire [0:0] DDR_MEM_1_cke_din1_i ; 
wire [7:0] DDR_MEM_1_dqwl_dqs0_o ; 
wire [7:0] DDR_MEM_1_dqwl_dqs1_o ; 

inout [7:0] dq_dqs0_io ; 
inout [7:0] dq_dqs1_io ; 
inout dqs0_io ;
inout dqs1_io ;
output [0:0] DDR_MEM_1_ck_o ;
output [0:0] DDR_MEM_1_csn_o ; 
output [12:0] DDR_MEM_1_addr_o ; 
output [2:0] DDR_MEM_1_ba_o ; 
output DDR_MEM_1_casn_o ; 
output DDR_MEM_1_rasn_o ; 
output DDR_MEM_1_wen_o ; 
output [0:0] DDR_MEM_1_odt_o ; 
output [0:0] DDR_MEM_1_cke_o ; 

wire MIPI_DPHY_1_sync_clk_i ; 
wire MIPI_DPHY_1_sync_rst_i ; 
wire MIPI_DPHY_1_lmmi_clk_i ; 
wire MIPI_DPHY_1_lmmi_resetn_i ; 
wire [3:0] MIPI_DPHY_1_lmmi_wdata_i ; 
wire MIPI_DPHY_1_lmmi_wr_rdn_i ; 
wire [4:0] MIPI_DPHY_1_lmmi_offset_i ; 
wire MIPI_DPHY_1_lmmi_request_i ; 
wire MIPI_DPHY_1_lmmi_ready_o ; 
wire [3:0] MIPI_DPHY_1_lmmi_rdata_o ; 
wire MIPI_DPHY_1_lmmi_rdata_valid_o ; 
wire MIPI_DPHY_1_hs_rx_clk_en_i ; 
wire MIPI_DPHY_1_hs_rx_data_en_i ; 
wire MIPI_DPHY_1_hs_data_des_en_i ; 
wire [31:0] MIPI_DPHY_1_hs_rx_data_o ; 
wire [3:0] MIPI_DPHY_1_hs_rx_data_sync_o ; 
wire MIPI_DPHY_1_lp_rx_en_i ; 
wire [3:0] MIPI_DPHY_1_lp_rx_data_p_o ; 
wire [3:0] MIPI_DPHY_1_lp_rx_data_n_o ; 
wire MIPI_DPHY_1_lp_rx_clk_p_o ; 
wire MIPI_DPHY_1_lp_rx_clk_n_o ; 
wire MIPI_DPHY_1_pll_lock_i ; 

inout MIPI_DPHY_1_clk_p_io ; 
inout MIPI_DPHY_1_clk_n_io ; 
inout [3:0] MIPI_DPHY_1_data_p_io ; 
inout [3:0] MIPI_DPHY_1_data_n_io ; 

// Check these signals
wire MIPI_DPHY_1_pd_dphy_i ; 
wire MIPI_DPHY_1_clk_byte_o ; 
wire MIPI_DPHY_1_ready_o ; 

wire MIPI_DPHY_2_sync_clk_i ; 
wire MIPI_DPHY_2_sync_rst_i ; 
wire MIPI_DPHY_2_lmmi_clk_i ; 
wire MIPI_DPHY_2_lmmi_resetn_i ; 
wire [3:0] MIPI_DPHY_2_lmmi_wdata_i ; 
wire MIPI_DPHY_2_lmmi_wr_rdn_i ; 
wire [4:0] MIPI_DPHY_2_lmmi_offset_i ; 
wire MIPI_DPHY_2_lmmi_request_i ; 
wire MIPI_DPHY_2_lmmi_ready_o ; 
wire [3:0] MIPI_DPHY_2_lmmi_rdata_o ; 
wire MIPI_DPHY_2_lmmi_rdata_valid_o ; 
wire MIPI_DPHY_2_hs_tx_en_i ; 
wire [31:0] MIPI_DPHY_2_hs_tx_data_i ; 
wire MIPI_DPHY_2_hs_tx_data_en_i ; 
wire MIPI_DPHY_2_lp_tx_en_i ; 
wire [3:0] MIPI_DPHY_2_lp_tx_data_p_i ; 
wire [3:0] MIPI_DPHY_2_lp_tx_data_n_i ; 
wire MIPI_DPHY_2_lp_tx_data_en_i ; 
wire MIPI_DPHY_2_lp_tx_clk_p_i ; 
wire MIPI_DPHY_2_lp_tx_clk_n_i ;

inout MIPI_DPHY_2_clk_p_io ; 
inout MIPI_DPHY_2_clk_n_io ; 
inout [3:0] MIPI_DPHY_2_data_p_io ; 
inout [3:0] MIPI_DPHY_2_data_n_io ; 

// Check these signals
wire MIPI_DPHY_2_usrstdby_i ; 
wire MIPI_DPHY_2_pd_dphy_i ; 
wire MIPI_DPHY_2_txclk_hsgate_i ; 
wire MIPI_DPHY_2_pll_lock_o ; 
wire MIPI_DPHY_2_clk_byte_o ; 
wire MIPI_DPHY_2_ready_o ; 

inout I2C_DPHY_1_scl_io;
inout I2C_DPHY_1_sda_io;
inout I2C_DPHY_2_scl_io;
inout I2C_DPHY_2_sda_io;

wire I2C_DPHY_1_scl_io;
wire I2C_DPHY_1_sda_io;
wire I2C_DPHY_1_clk_i;
wire I2C_DPHY_1_rst_n_i;
wire I2C_DPHY_1_lmmi_request_i;
wire I2C_DPHY_1_lmmi_wr_rdn_i;
wire [3:0] I2C_DPHY_1_lmmi_offset_i;
wire [7:0] I2C_DPHY_1_lmmi_wdata_i;
wire [7:0] I2C_DPHY_1_lmmi_rdata_o;
wire I2C_DPHY_1_lmmi_rdata_valid_o;
wire I2C_DPHY_1_lmmi_ready_o;
wire I2C_DPHY_1_int_o;

wire I2C_DPHY_2_scl_io;
wire I2C_DPHY_2_sda_io;
wire I2C_DPHY_2_clk_i;
wire I2C_DPHY_2_rst_n_i;
wire I2C_DPHY_2_lmmi_request_i;
wire I2C_DPHY_2_lmmi_wr_rdn_i;
wire [3:0] I2C_DPHY_2_lmmi_offset_i;
wire [7:0] I2C_DPHY_2_lmmi_wdata_i;
wire [7:0] I2C_DPHY_2_lmmi_rdata_o;
wire I2C_DPHY_2_lmmi_rdata_valid_o;
wire I2C_DPHY_2_lmmi_ready_o;
wire I2C_DPHY_2_int_o;

DDR_MEM_1 DDR_MEM_1_inst (.eclk_i(DDR_MEM_1_eclk_i),
        .sync_clk_i(DDR_MEM_1_sync_clk_i),
        .sync_rst_i(DDR_MEM_1_sync_rst_i),
        .pll_lock_i(DDR_MEM_1_pll_lock_i),
		.sclk_o(DDR_MEM_1_sclk_o),
    .sync_update_i(DDR_MEM_1_sync_update_i),
    .rd_clksel_dqs0_i(DDR_MEM_1_rd_clksel_dqs0_i),
	.rd_clksel_dqs1_i(DDR_MEM_1_rd_clksel_dqs1_i),
    .rd_dqs0_i(DDR_MEM_1_rd_dqs0_i),
	.rd_dqs1_i(DDR_MEM_1_rd_dqs1_i),
    .selclk_i(DDR_MEM_1_selclk_i),
    .pause_i(DDR_MEM_1_pause_i),
    .dq_outen_n_i(DDR_MEM_1_dq_outen_n_i),
    .data_dqs0_i(DDR_MEM_1_data_dqs0_i),
	.data_dqs1_i(DDR_MEM_1_data_dqs1_i),
    .dcnt_o(DDR_MEM_1_dcnt_o),
    .ready_o(DDR_MEM_1_ready_o),
    .data_dqs0_o(DDR_MEM_1_data_dqs0_o),
	.data_dqs1_o(DDR_MEM_1_data_dqs1_o),
    .burst_detect_dqs0_o(DDR_MEM_1_burst_detect_dqs0_o),
	.burst_detect_dqs1_o(DDR_MEM_1_burst_detect_dqs1_o),
    .burst_detect_sclk_dqs0_o(DDR_MEM_1_burst_detect_sclk_dqs0_o),
	.burst_detect_sclk_dqs1_o(DDR_MEM_1_burst_detect_sclk_dqs1_o),
    .data_valid_dqs0_o(DDR_MEM_1_data_valid_dqs0_o),
	.data_valid_dqs1_o(DDR_MEM_1_data_valid_dqs1_o),
    .dqs_outen_n_dqs0_i(DDR_MEM_1_dqs_outen_n_dqs0_i),
	.dqs_outen_n_dqs1_i(DDR_MEM_1_dqs_outen_n_dqs1_i),
    .dqs0_i(DDR_MEM_1_dqs0_i),
	.dqs1_i(DDR_MEM_1_dqs1_i),
    .csn_din0_i(DDR_MEM_1_csn_din0_i),
    .csn_din1_i(DDR_MEM_1_csn_din1_i),
    .addr_din0_i(DDR_MEM_1_addr_din0_i),
    .addr_din1_i(DDR_MEM_1_addr_din1_i),
    .ba_din0_i(DDR_MEM_1_ba_din0_i),
    .ba_din1_i(DDR_MEM_1_ba_din1_i),
    .casn_din0_i(DDR_MEM_1_casn_din0_i),
    .casn_din1_i(DDR_MEM_1_casn_din1_i),
    .rasn_din0_i(DDR_MEM_1_rasn_din0_i),
    .rasn_din1_i(DDR_MEM_1_rasn_din1_i),
    .wen_din0_i(DDR_MEM_1_wen_din0_i),
    .wen_din1_i(DDR_MEM_1_wen_din1_i),
    .odt_din0_i(DDR_MEM_1_odt_din0_i),
    .odt_din1_i(DDR_MEM_1_odt_din1_i),
    .cke_din0_i(DDR_MEM_1_cke_din0_i),
    .cke_din1_i(DDR_MEM_1_cke_din1_i),
    .dqwl_dqs0_o(DDR_MEM_1_dqwl_dqs0_o),
	.dqwl_dqs1_o(DDR_MEM_1_dqwl_dqs1_o),
    .dq_dqs0_io(dq_dqs0_io),
	.dq_dqs1_io(dq_dqs1_io),
    .dqs0_io(dqs0_io),
	.dqs1_io(dqs1_io),
    .ck_o(DDR_MEM_1_ck_o),
    .csn_o(DDR_MEM_1_csn_o),
    .addr_o(DDR_MEM_1_addr_o),
    .ba_o(DDR_MEM_1_ba_o),
    .casn_o(DDR_MEM_1_casn_o),
    .rasn_o(DDR_MEM_1_rasn_o),
    .wen_o(DDR_MEM_1_wen_o),
    .odt_o(DDR_MEM_1_odt_o),
    .cke_o(DDR_MEM_1_cke_o));

MIPI_DPHY_1 MIPI_DPHY_1_inst (.sync_clk_i(MIPI_DPHY_1_sync_clk_i),
    .sync_rst_i(MIPI_DPHY_1_sync_rst_i),
    .lmmi_clk_i(MIPI_DPHY_1_lmmi_clk_i),
    .lmmi_resetn_i(MIPI_DPHY_1_lmmi_resetn_i),
    .lmmi_wdata_i(MIPI_DPHY_1_lmmi_wdata_i),
    .lmmi_wr_rdn_i(MIPI_DPHY_1_lmmi_wr_rdn_i),
    .lmmi_offset_i(MIPI_DPHY_1_lmmi_offset_i),
    .lmmi_request_i(MIPI_DPHY_1_lmmi_request_i),
    .lmmi_ready_o(MIPI_DPHY_1_lmmi_ready_o),
    .lmmi_rdata_o(MIPI_DPHY_1_lmmi_rdata_o),
    .lmmi_rdata_valid_o(MIPI_DPHY_1_lmmi_rdata_valid_o),
    .hs_rx_clk_en_i(MIPI_DPHY_1_hs_rx_clk_en_i),
    .hs_rx_data_en_i(MIPI_DPHY_1_hs_rx_data_en_i),
    .hs_data_des_en_i(MIPI_DPHY_1_hs_data_des_en_i),
    .hs_rx_data_o(MIPI_DPHY_1_hs_rx_data_o),
    .hs_rx_data_sync_o(MIPI_DPHY_1_hs_rx_data_sync_o),
    .lp_rx_en_i(MIPI_DPHY_1_lp_rx_en_i),
    .lp_rx_data_p_o(MIPI_DPHY_1_lp_rx_data_p_o),
    .lp_rx_data_n_o(MIPI_DPHY_1_lp_rx_data_n_o),
    .lp_rx_clk_p_o(MIPI_DPHY_1_lp_rx_clk_p_o),
    .lp_rx_clk_n_o(MIPI_DPHY_1_lp_rx_clk_n_o),
    .pll_lock_i(MIPI_DPHY_1_pll_lock_i),
    .clk_p_io(MIPI_DPHY_1_clk_p_io),
    .clk_n_io(MIPI_DPHY_1_clk_n_io),
    .data_p_io(MIPI_DPHY_1_data_p_io),
    .data_n_io(MIPI_DPHY_1_data_n_io),
    .pd_dphy_i(MIPI_DPHY_1_pd_dphy_i),
    .clk_byte_o(MIPI_DPHY_1_clk_byte_o),
    .ready_o(MIPI_DPHY_1_ready_o));

MIPI_DPHY_2 MIPI_DPHY_2_inst (.sync_clk_i(MIPI_DPHY_2_sync_clk_i),
    .sync_rst_i(MIPI_DPHY_2_sync_rst_i),
    .lmmi_clk_i(MIPI_DPHY_2_lmmi_clk_i),
    .lmmi_resetn_i(MIPI_DPHY_2_lmmi_resetn_i),
    .lmmi_wdata_i(MIPI_DPHY_2_lmmi_wdata_i),
    .lmmi_wr_rdn_i(MIPI_DPHY_2_lmmi_wr_rdn_i),
    .lmmi_offset_i(MIPI_DPHY_2_lmmi_offset_i),
    .lmmi_request_i(MIPI_DPHY_2_lmmi_request_i),
    .lmmi_ready_o(MIPI_DPHY_2_lmmi_ready_o),
    .lmmi_rdata_o(MIPI_DPHY_2_lmmi_rdata_o),
    .lmmi_rdata_valid_o(MIPI_DPHY_2_lmmi_rdata_valid_o),
    .hs_tx_en_i(MIPI_DPHY_2_hs_tx_en_i),
    .hs_tx_data_i(MIPI_DPHY_2_hs_tx_data_i),
    .hs_tx_data_en_i(MIPI_DPHY_2_hs_tx_data_en_i),
    .lp_tx_en_i(MIPI_DPHY_2_lp_tx_en_i),
    .lp_tx_data_p_i(MIPI_DPHY_2_lp_tx_data_p_i),
    .lp_tx_data_n_i(MIPI_DPHY_2_lp_tx_data_n_i),
    .lp_tx_data_en_i(MIPI_DPHY_2_lp_tx_data_en_i),
    .lp_tx_clk_p_i(MIPI_DPHY_2_lp_tx_clk_p_i),
    .lp_tx_clk_n_i(MIPI_DPHY_2_lp_tx_clk_n_i),
    .clk_p_io(MIPI_DPHY_2_clk_p_io),
    .clk_n_io(MIPI_DPHY_2_clk_n_io),
    .data_p_io(MIPI_DPHY_2_data_p_io),
    .data_n_io(MIPI_DPHY_2_data_n_io),
    .usrstdby_i(MIPI_DPHY_2_usrstdby_i),
    .pd_dphy_i(MIPI_DPHY_2_pd_dphy_i),
    .txclk_hsgate_i(MIPI_DPHY_2_txclk_hsgate_i),
    .pll_lock_o(MIPI_DPHY_2_pll_lock_o),
    .clk_byte_o(MIPI_DPHY_2_clk_byte_o),
    .ready_o(MIPI_DPHY_2_ready_o));
	
I2C_DPHY_1 I2C_DPHY_1_inst (.scl_io(I2C_DPHY_1_scl_io),
        .sda_io(I2C_DPHY_1_sda_io),
        .clk_i(I2C_DPHY_1_clk_i),
        .rst_n_i(I2C_DPHY_1_rst_n_i),
        .lmmi_request_i(I2C_DPHY_1_lmmi_request_i),
        .lmmi_wr_rdn_i(I2C_DPHY_1_lmmi_wr_rdn_i),
        .lmmi_offset_i(I2C_DPHY_1_lmmi_offset_i),
        .lmmi_wdata_i(I2C_DPHY_1_lmmi_wdata_i),
        .lmmi_rdata_o(I2C_DPHY_1_lmmi_rdata_o),
        .lmmi_rdata_valid_o(I2C_DPHY_1_lmmi_rdata_valid_o),
        .lmmi_ready_o(I2C_DPHY_1_lmmi_ready_o),
        .int_o(I2C_DPHY_1_int_o));
		
I2C_DPHY_2 I2C_DPHY_2_inst (.scl_io(I2C_DPHY_2_scl_io),
        .sda_io(I2C_DPHY_2_sda_io),
        .clk_i(I2C_DPHY_2_clk_i),
        .rst_n_i(I2C_DPHY_2_rst_n_i),
        .lmmi_request_i(I2C_DPHY_2_lmmi_request_i),
        .lmmi_wr_rdn_i(I2C_DPHY_2_lmmi_wr_rdn_i),
        .lmmi_offset_i(I2C_DPHY_2_lmmi_offset_i),
        .lmmi_wdata_i(I2C_DPHY_2_lmmi_wdata_i),
        .lmmi_rdata_o(I2C_DPHY_2_lmmi_rdata_o),
        .lmmi_rdata_valid_o(I2C_DPHY_2_lmmi_rdata_valid_o),
        .lmmi_ready_o(I2C_DPHY_2_lmmi_ready_o),
        .int_o(I2C_DPHY_2_int_o));

endmodule