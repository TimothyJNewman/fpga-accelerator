component DDR3_PHY_2 is
    port(
        clk_i: in std_logic;
        eclk_i: in std_logic;
        clk_stable_i: in std_logic;
        dqsbuf_pause_i: in std_logic;
        ddr_rst_i: in std_logic;
        update_done_i: in std_logic;
        sclk_o: out std_logic;
        dll_update_o: out std_logic;
        phy_init_act_o: out std_logic;
        wl_act_o: out std_logic;
        wl_err_o: out std_logic;
        rt_err_o: out std_logic;
        rst_cntr_ready_o: out std_logic;
        csm_ready_o: out std_logic;
        dfi_rst_n_i: in std_logic;
        dfi_addr_i: in std_logic_vector(13 downto 0);
        dfi_bank_i: in std_logic_vector(2 downto 0);
        dfi_cas_n_i: in std_logic;
        dfi_cke_i: in std_logic_vector(0 to 0);
        dfi_cs_n_i: in std_logic_vector(0 to 0);
        dfi_odt_i: in std_logic_vector(0 to 0);
        dfi_ras_n_i: in std_logic;
        dfi_we_n_i: in std_logic;
        dfi_wrdata_i: in std_logic_vector(63 downto 0);
        dfi_wrdataen_i: in std_logic;
        dfi_wrdata_mask_i: in std_logic_vector(7 downto 0);
        dfi_init_start_i: in std_logic;
        dfi_rddata_o: out std_logic_vector(63 downto 0);
        dfi_init_complete_o: out std_logic;
        dfi_rddata_valid_o: out std_logic;
        em_ddr_rst_n_o: out std_logic;
        em_ddr_clk_o: out std_logic_vector(0 to 0);
        em_ddr_cke_o: out std_logic_vector(0 to 0);
        em_ddr_addr_o: out std_logic_vector(13 downto 0);
        em_ddr_ba_o: out std_logic_vector(2 downto 0);
        em_ddr_cs_n_o: out std_logic_vector(0 to 0);
        em_ddr_odt_o: out std_logic_vector(0 to 0);
        em_ddr_cas_n_o: out std_logic;
        em_ddr_ras_n_o: out std_logic;
        em_ddr_we_n_o: out std_logic;
        em_ddr_dm_o: out std_logic_vector(1 downto 0);
        em_ddr_dqs_io: inout std_logic_vector(1 downto 0);
        em_ddr_data_io: inout std_logic_vector(15 downto 0)
    );
end component;

__: DDR3_PHY_2 port map(
    clk_i=>,
    eclk_i=>,
    clk_stable_i=>,
    dqsbuf_pause_i=>,
    ddr_rst_i=>,
    update_done_i=>,
    sclk_o=>,
    dll_update_o=>,
    phy_init_act_o=>,
    wl_act_o=>,
    wl_err_o=>,
    rt_err_o=>,
    rst_cntr_ready_o=>,
    csm_ready_o=>,
    dfi_rst_n_i=>,
    dfi_addr_i=>,
    dfi_bank_i=>,
    dfi_cas_n_i=>,
    dfi_cke_i=>,
    dfi_cs_n_i=>,
    dfi_odt_i=>,
    dfi_ras_n_i=>,
    dfi_we_n_i=>,
    dfi_wrdata_i=>,
    dfi_wrdataen_i=>,
    dfi_wrdata_mask_i=>,
    dfi_init_start_i=>,
    dfi_rddata_o=>,
    dfi_init_complete_o=>,
    dfi_rddata_valid_o=>,
    em_ddr_rst_n_o=>,
    em_ddr_clk_o=>,
    em_ddr_cke_o=>,
    em_ddr_addr_o=>,
    em_ddr_ba_o=>,
    em_ddr_cs_n_o=>,
    em_ddr_odt_o=>,
    em_ddr_cas_n_o=>,
    em_ddr_ras_n_o=>,
    em_ddr_we_n_o=>,
    em_ddr_dm_o=>,
    em_ddr_dqs_io=>,
    em_ddr_data_io=>
);
