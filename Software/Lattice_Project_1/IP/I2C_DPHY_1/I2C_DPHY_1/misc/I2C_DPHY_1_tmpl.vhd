component I2C_DPHY_1 is
    port(
        scl_io: inout std_logic;
        sda_io: inout std_logic;
        clk_i: in std_logic;
        rst_n_i: in std_logic;
        lmmi_request_i: in std_logic;
        lmmi_wr_rdn_i: in std_logic;
        lmmi_offset_i: in std_logic_vector(3 downto 0);
        lmmi_wdata_i: in std_logic_vector(7 downto 0);
        lmmi_rdata_o: out std_logic_vector(7 downto 0);
        lmmi_rdata_valid_o: out std_logic;
        lmmi_ready_o: out std_logic;
        int_o: out std_logic
    );
end component;

__: I2C_DPHY_1 port map(
    scl_io=>,
    sda_io=>,
    clk_i=>,
    rst_n_i=>,
    lmmi_request_i=>,
    lmmi_wr_rdn_i=>,
    lmmi_offset_i=>,
    lmmi_wdata_i=>,
    lmmi_rdata_o=>,
    lmmi_rdata_valid_o=>,
    lmmi_ready_o=>,
    int_o=>
);
