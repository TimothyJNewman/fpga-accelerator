    DDR3_PHY_2 u_DDR3_PHY_2(.clk_i(clk_i),
        .eclk_i(eclk_i),
        .clk_stable_i(clk_stable_i),
        .dqsbuf_pause_i(dqsbuf_pause_i),
        .ddr_rst_i(ddr_rst_i),
        .update_done_i(update_done_i),
        .sclk_o(sclk_o),
        .dll_update_o(dll_update_o),
        .phy_init_act_o(phy_init_act_o),
        .wl_act_o(wl_act_o),
        .wl_err_o(wl_err_o),
        .rt_err_o(rt_err_o),
        .rst_cntr_ready_o(rst_cntr_ready_o),
        .csm_ready_o(csm_ready_o),
        .dfi_rst_n_i(dfi_rst_n_i),
        .dfi_addr_i(dfi_addr_i),
        .dfi_bank_i(dfi_bank_i),
        .dfi_cas_n_i(dfi_cas_n_i),
        .dfi_cke_i(dfi_cke_i),
        .dfi_cs_n_i(dfi_cs_n_i),
        .dfi_odt_i(dfi_odt_i),
        .dfi_ras_n_i(dfi_ras_n_i),
        .dfi_we_n_i(dfi_we_n_i),
        .dfi_wrdata_i(dfi_wrdata_i),
        .dfi_wrdataen_i(dfi_wrdataen_i),
        .dfi_wrdata_mask_i(dfi_wrdata_mask_i),
        .dfi_init_start_i(dfi_init_start_i),
        .dfi_rddata_o(dfi_rddata_o),
        .dfi_init_complete_o(dfi_init_complete_o),
        .dfi_rddata_valid_o(dfi_rddata_valid_o),
        .em_ddr_rst_n_o(em_ddr_rst_n_o),
        .em_ddr_clk_o(em_ddr_clk_o),
        .em_ddr_cke_o(em_ddr_cke_o),
        .em_ddr_addr_o(em_ddr_addr_o),
        .em_ddr_ba_o(em_ddr_ba_o),
        .em_ddr_cs_n_o(em_ddr_cs_n_o),
        .em_ddr_odt_o(em_ddr_odt_o),
        .em_ddr_cas_n_o(em_ddr_cas_n_o),
        .em_ddr_ras_n_o(em_ddr_ras_n_o),
        .em_ddr_we_n_o(em_ddr_we_n_o),
        .em_ddr_dm_o(em_ddr_dm_o),
        .em_ddr_dqs_io(em_ddr_dqs_io),
        .em_ddr_data_io(em_ddr_data_io));