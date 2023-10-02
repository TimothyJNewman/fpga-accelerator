component MIPI_DPHY_2 is
    port(
        sync_clk_i: in std_logic;
        sync_rst_i: in std_logic;
        lmmi_clk_i: in std_logic;
        lmmi_resetn_i: in std_logic;
        lmmi_wdata_i: in std_logic_vector(3 downto 0);
        lmmi_wr_rdn_i: in std_logic;
        lmmi_offset_i: in std_logic_vector(4 downto 0);
        lmmi_request_i: in std_logic;
        lmmi_ready_o: out std_logic;
        lmmi_rdata_o: out std_logic_vector(3 downto 0);
        lmmi_rdata_valid_o: out std_logic;
        hs_tx_en_i: in std_logic;
        hs_tx_data_i: in std_logic_vector(31 downto 0);
        hs_tx_data_en_i: in std_logic;
        lp_tx_en_i: in std_logic;
        lp_tx_data_p_i: in std_logic_vector(3 downto 0);
        lp_tx_data_n_i: in std_logic_vector(3 downto 0);
        lp_tx_data_en_i: in std_logic;
        lp_tx_clk_p_i: in std_logic;
        lp_tx_clk_n_i: in std_logic;
        hs_tx_cil_ready_o: out std_logic_vector(3 downto 0);
        data_lane_ss_o: out std_logic_vector(3 downto 0);
        clk_p_io: inout std_logic;
        clk_n_io: inout std_logic;
        data_p_io: inout std_logic_vector(3 downto 0);
        data_n_io: inout std_logic_vector(3 downto 0);
        usrstdby_i: in std_logic;
        pd_dphy_i: in std_logic;
        pll_lock_o: out std_logic;
        clk_byte_o: out std_logic;
        ready_o: out std_logic
    );
end component;

__: MIPI_DPHY_2 port map(
    sync_clk_i=>,
    sync_rst_i=>,
    lmmi_clk_i=>,
    lmmi_resetn_i=>,
    lmmi_wdata_i=>,
    lmmi_wr_rdn_i=>,
    lmmi_offset_i=>,
    lmmi_request_i=>,
    lmmi_ready_o=>,
    lmmi_rdata_o=>,
    lmmi_rdata_valid_o=>,
    hs_tx_en_i=>,
    hs_tx_data_i=>,
    hs_tx_data_en_i=>,
    lp_tx_en_i=>,
    lp_tx_data_p_i=>,
    lp_tx_data_n_i=>,
    lp_tx_data_en_i=>,
    lp_tx_clk_p_i=>,
    lp_tx_clk_n_i=>,
    hs_tx_cil_ready_o=>,
    data_lane_ss_o=>,
    clk_p_io=>,
    clk_n_io=>,
    data_p_io=>,
    data_n_io=>,
    usrstdby_i=>,
    pd_dphy_i=>,
    pll_lock_o=>,
    clk_byte_o=>,
    ready_o=>
);
