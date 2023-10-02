component DDR3_MC_2 is
    port(
        clk_i: in std_logic;
        rst_n_i: in std_logic;
        mem_rst_n_i: in std_logic;
        init_start_i: in std_logic;
        cmd_i: in std_logic_vector(3 downto 0);
        addr_i: in std_logic_vector(27 downto 0);
        cmd_burst_cnt_i: in std_logic_vector(4 downto 0);
        cmd_valid_i: in std_logic;
        write_data_i: in std_logic_vector(255 downto 0);
        data_mask_i: in std_logic_vector(31 downto 0);
        cmd_rdy_o: out std_logic;
        datain_rdy_o: out std_logic;
        init_done_o: out std_logic;
        rt_err_o: out std_logic;
        wl_err_o: out std_logic;
        read_data_o: out std_logic_vector(255 downto 0);
        read_data_valid_o: out std_logic;
        sclk_o: out std_logic;
        clocking_good_o: out std_logic;
        em_ddr_data_io: inout std_logic_vector(31 downto 0);
        em_ddr_reset_n_o: out std_logic;
        em_ddr_dqs_io: inout std_logic_vector(3 downto 0);
        em_ddr_dm_o: out std_logic_vector(3 downto 0);
        em_ddr_clk_o: out std_logic_vector(0 to 0);
        em_ddr_cke_o: out std_logic_vector(0 to 0);
        em_ddr_ras_n_o: out std_logic;
        em_ddr_cas_n_o: out std_logic;
        em_ddr_we_n_o: out std_logic;
        em_ddr_cs_n_o: out std_logic_vector(0 to 0);
        em_ddr_odt_o: out std_logic_vector(0 to 0);
        em_ddr_addr_o: out std_logic_vector(14 downto 0);
        em_ddr_ba_o: out std_logic_vector(2 downto 0)
    );
end component;

__: DDR3_MC_2 port map(
    clk_i=>,
    rst_n_i=>,
    mem_rst_n_i=>,
    init_start_i=>,
    cmd_i=>,
    addr_i=>,
    cmd_burst_cnt_i=>,
    cmd_valid_i=>,
    write_data_i=>,
    data_mask_i=>,
    cmd_rdy_o=>,
    datain_rdy_o=>,
    init_done_o=>,
    rt_err_o=>,
    wl_err_o=>,
    read_data_o=>,
    read_data_valid_o=>,
    sclk_o=>,
    clocking_good_o=>,
    em_ddr_data_io=>,
    em_ddr_reset_n_o=>,
    em_ddr_dqs_io=>,
    em_ddr_dm_o=>,
    em_ddr_clk_o=>,
    em_ddr_cke_o=>,
    em_ddr_ras_n_o=>,
    em_ddr_cas_n_o=>,
    em_ddr_we_n_o=>,
    em_ddr_cs_n_o=>,
    em_ddr_odt_o=>,
    em_ddr_addr_o=>,
    em_ddr_ba_o=>
);
