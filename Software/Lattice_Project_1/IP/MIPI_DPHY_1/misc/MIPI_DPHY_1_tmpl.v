    MIPI_DPHY_1 __(.sync_clk_i( ),
        .sync_rst_i( ),
        .lmmi_clk_i( ),
        .lmmi_resetn_i( ),
        .lmmi_wdata_i( ),
        .lmmi_wr_rdn_i( ),
        .lmmi_offset_i( ),
        .lmmi_request_i( ),
        .lmmi_ready_o( ),
        .lmmi_rdata_o( ),
        .lmmi_rdata_valid_o( ),
        .hs_rx_clk_en_i( ),
        .hs_rx_data_en_i( ),
        .hs_data_des_en_i( ),
        .hs_rx_data_o( ),
        .hs_rx_data_sync_o( ),
        .lp_rx_en_i( ),
        .lp_rx_data_p_o( ),
        .lp_rx_data_n_o( ),
        .lp_rx_clk_p_o( ),
        .lp_rx_clk_n_o( ),
        .pll_lock_i( ),
        .clk_p_io( ),
        .clk_n_io( ),
        .data_p_io( ),
        .data_n_io( ),
        .pd_dphy_i( ),
        .clk_byte_o( ),
        .ready_o( ));
