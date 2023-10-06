component DDR_MEM_1 is
    port(
        eclk_i: in std_logic;
        sync_clk_i: in std_logic;
        sync_rst_i: in std_logic;
        pll_lock_i: in std_logic;
        sclk_o: out std_logic;
        sync_update_i: in std_logic;
        rd_clksel_dqs0_i: in std_logic_vector(3 downto 0);
        rd_clksel_dqs1_i: in std_logic_vector(3 downto 0);
        rd_dqs0_i: in std_logic_vector(3 downto 0);
        rd_dqs1_i: in std_logic_vector(3 downto 0);
        selclk_i: in std_logic;
        pause_i: in std_logic;
        dq_outen_n_i: in std_logic_vector(1 downto 0);
        data_dqs0_i: in std_logic_vector(31 downto 0);
        data_dqs1_i: in std_logic_vector(31 downto 0);
        dcnt_o: out std_logic_vector(7 downto 0);
        ready_o: out std_logic;
        data_dqs0_o: out std_logic_vector(31 downto 0);
        data_dqs1_o: out std_logic_vector(31 downto 0);
        burst_detect_dqs0_o: out std_logic;
        burst_detect_dqs1_o: out std_logic;
        burst_detect_sclk_dqs0_o: out std_logic;
        burst_detect_sclk_dqs1_o: out std_logic;
        data_valid_dqs0_o: out std_logic;
        data_valid_dqs1_o: out std_logic;
        dqs_outen_n_dqs0_i: in std_logic_vector(1 downto 0);
        dqs_outen_n_dqs1_i: in std_logic_vector(1 downto 0);
        dqs0_i: in std_logic_vector(1 downto 0);
        dqs1_i: in std_logic_vector(1 downto 0);
        csn_din0_i: in std_logic_vector(0 to 0);
        csn_din1_i: in std_logic_vector(0 to 0);
        addr_din0_i: in std_logic_vector(13 downto 0);
        addr_din1_i: in std_logic_vector(13 downto 0);
        ba_din0_i: in std_logic_vector(2 downto 0);
        ba_din1_i: in std_logic_vector(2 downto 0);
        casn_din0_i: in std_logic;
        casn_din1_i: in std_logic;
        rasn_din0_i: in std_logic;
        rasn_din1_i: in std_logic;
        wen_din0_i: in std_logic;
        wen_din1_i: in std_logic;
        odt_din0_i: in std_logic_vector(0 to 0);
        odt_din1_i: in std_logic_vector(0 to 0);
        cke_din0_i: in std_logic_vector(0 to 0);
        cke_din1_i: in std_logic_vector(0 to 0);
        dqwl_dqs0_o: out std_logic_vector(7 downto 0);
        dqwl_dqs1_o: out std_logic_vector(7 downto 0);
        dq_dqs0_io: inout std_logic_vector(7 downto 0);
        dq_dqs1_io: inout std_logic_vector(7 downto 0);
        dqs0_io: inout std_logic;
        dqs1_io: inout std_logic;
        ck_o: out std_logic_vector(0 to 0);
        csn_o: out std_logic_vector(0 to 0);
        addr_o: out std_logic_vector(13 downto 0);
        ba_o: out std_logic_vector(2 downto 0);
        casn_o: out std_logic;
        rasn_o: out std_logic;
        wen_o: out std_logic;
        odt_o: out std_logic_vector(0 to 0);
        cke_o: out std_logic_vector(0 to 0)
    );
end component;

__: DDR_MEM_1 port map(
    eclk_i=>,
    sync_clk_i=>,
    sync_rst_i=>,
    pll_lock_i=>,
    sclk_o=>,
    sync_update_i=>,
    rd_clksel_dqs0_i=>,
    rd_clksel_dqs1_i=>,
    rd_dqs0_i=>,
    rd_dqs1_i=>,
    selclk_i=>,
    pause_i=>,
    dq_outen_n_i=>,
    data_dqs0_i=>,
    data_dqs1_i=>,
    dcnt_o=>,
    ready_o=>,
    data_dqs0_o=>,
    data_dqs1_o=>,
    burst_detect_dqs0_o=>,
    burst_detect_dqs1_o=>,
    burst_detect_sclk_dqs0_o=>,
    burst_detect_sclk_dqs1_o=>,
    data_valid_dqs0_o=>,
    data_valid_dqs1_o=>,
    dqs_outen_n_dqs0_i=>,
    dqs_outen_n_dqs1_i=>,
    dqs0_i=>,
    dqs1_i=>,
    csn_din0_i=>,
    csn_din1_i=>,
    addr_din0_i=>,
    addr_din1_i=>,
    ba_din0_i=>,
    ba_din1_i=>,
    casn_din0_i=>,
    casn_din1_i=>,
    rasn_din0_i=>,
    rasn_din1_i=>,
    wen_din0_i=>,
    wen_din1_i=>,
    odt_din0_i=>,
    odt_din1_i=>,
    cke_din0_i=>,
    cke_din1_i=>,
    dqwl_dqs0_o=>,
    dqwl_dqs1_o=>,
    dq_dqs0_io=>,
    dq_dqs1_io=>,
    dqs0_io=>,
    dqs1_io=>,
    ck_o=>,
    csn_o=>,
    addr_o=>,
    ba_o=>,
    casn_o=>,
    rasn_o=>,
    wen_o=>,
    odt_o=>,
    cke_o=>
);
