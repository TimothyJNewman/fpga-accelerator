// Verilog netlist produced by program LSE 
// Netlist written on Sun Oct  1 01:19:40 2023
// Source file index table: 
// Object locations will have the form @<file_index>(<first_ line>[<left_column>],<last_line>[<right_column>])
// file 0 "c:/lscc/radiant/2023.1/ip/avant/fifo/rtl/lscc_fifo.v"
// file 1 "c:/lscc/radiant/2023.1/ip/avant/fifo_dc/rtl/lscc_fifo_dc.v"
// file 2 "c:/lscc/radiant/2023.1/ip/avant/ram_dp/rtl/lscc_ram_dp.v"
// file 3 "c:/lscc/radiant/2023.1/ip/avant/ram_dp_true/rtl/lscc_ram_dp_true.v"
// file 4 "c:/lscc/radiant/2023.1/ip/avant/ram_dq/rtl/lscc_ram_dq.v"
// file 5 "c:/lscc/radiant/2023.1/ip/avant/rom/rtl/lscc_rom.v"
// file 6 "c:/lscc/radiant/2023.1/ip/common/adder/rtl/lscc_adder.v"
// file 7 "c:/lscc/radiant/2023.1/ip/common/adder_subtractor/rtl/lscc_add_sub.v"
// file 8 "c:/lscc/radiant/2023.1/ip/common/complex_mult/rtl/lscc_complex_mult.v"
// file 9 "c:/lscc/radiant/2023.1/ip/common/counter/rtl/lscc_cntr.v"
// file 10 "c:/lscc/radiant/2023.1/ip/common/distributed_dpram/rtl/lscc_distributed_dpram.v"
// file 11 "c:/lscc/radiant/2023.1/ip/common/distributed_rom/rtl/lscc_distributed_rom.v"
// file 12 "c:/lscc/radiant/2023.1/ip/common/distributed_spram/rtl/lscc_distributed_spram.v"
// file 13 "c:/lscc/radiant/2023.1/ip/common/mult_accumulate/rtl/lscc_mult_accumulate.v"
// file 14 "c:/lscc/radiant/2023.1/ip/common/mult_add_sub/rtl/lscc_mult_add_sub.v"
// file 15 "c:/lscc/radiant/2023.1/ip/common/mult_add_sub_sum/rtl/lscc_mult_add_sub_sum.v"
// file 16 "c:/lscc/radiant/2023.1/ip/common/multiplier/rtl/lscc_multiplier.v"
// file 17 "c:/lscc/radiant/2023.1/ip/common/ram_shift_reg/rtl/lscc_shift_register.v"
// file 18 "c:/lscc/radiant/2023.1/ip/common/subtractor/rtl/lscc_subtractor.v"
// file 19 "c:/lscc/radiant/2023.1/ip/pmi/pmi_add.v"
// file 20 "c:/lscc/radiant/2023.1/ip/pmi/pmi_addsub.v"
// file 21 "c:/lscc/radiant/2023.1/ip/pmi/pmi_complex_mult.v"
// file 22 "c:/lscc/radiant/2023.1/ip/pmi/pmi_counter.v"
// file 23 "c:/lscc/radiant/2023.1/ip/pmi/pmi_distributed_dpram.v"
// file 24 "c:/lscc/radiant/2023.1/ip/pmi/pmi_distributed_rom.v"
// file 25 "c:/lscc/radiant/2023.1/ip/pmi/pmi_distributed_shift_reg.v"
// file 26 "c:/lscc/radiant/2023.1/ip/pmi/pmi_distributed_spram.v"
// file 27 "c:/lscc/radiant/2023.1/ip/pmi/pmi_fifo.v"
// file 28 "c:/lscc/radiant/2023.1/ip/pmi/pmi_fifo_dc.v"
// file 29 "c:/lscc/radiant/2023.1/ip/pmi/pmi_mac.v"
// file 30 "c:/lscc/radiant/2023.1/ip/pmi/pmi_mult.v"
// file 31 "c:/lscc/radiant/2023.1/ip/pmi/pmi_multaddsub.v"
// file 32 "c:/lscc/radiant/2023.1/ip/pmi/pmi_multaddsubsum.v"
// file 33 "c:/lscc/radiant/2023.1/ip/pmi/pmi_ram_dp.v"
// file 34 "c:/lscc/radiant/2023.1/ip/pmi/pmi_ram_dp_be.v"
// file 35 "c:/lscc/radiant/2023.1/ip/pmi/pmi_ram_dp_true.v"
// file 36 "c:/lscc/radiant/2023.1/ip/pmi/pmi_ram_dq.v"
// file 37 "c:/lscc/radiant/2023.1/ip/pmi/pmi_ram_dq_be.v"
// file 38 "c:/lscc/radiant/2023.1/ip/pmi/pmi_rom.v"
// file 39 "c:/lscc/radiant/2023.1/ip/pmi/pmi_sub.v"
// file 40 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/acc54.v"
// file 41 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/adc.v"
// file 42 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/alureg.v"
// file 43 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/aon.v"
// file 44 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/bb_adc.v"
// file 45 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/bb_cdr.v"
// file 46 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/bb_i3c_a.v"
// file 47 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/bb_programn.v"
// file 48 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/bfd1p3kx.v"
// file 49 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/bfd1p3lx.v"
// file 50 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/bnkref18.v"
// file 51 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/config_ip.v"
// file 52 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/config_lmmi.v"
// file 53 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/config_lmmia.v"
// file 54 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/ddrdll.v"
// file 55 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/diffio18.v"
// file 56 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/dlldel.v"
// file 57 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/dp16k.v"
// file 58 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/dphy.v"
// file 59 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/dpsc512k.v"
// file 60 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/dqsbuf.v"
// file 61 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/ebr.v"
// file 62 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/eclkdiv.v"
// file 63 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/eclksync.v"
// file 64 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/fbmux.v"
// file 65 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/fifo16k.v"
// file 66 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/i2cfifo.v"
// file 67 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/ifd1p3bx.v"
// file 68 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/ifd1p3dx.v"
// file 69 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/ifd1p3ix.v"
// file 70 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/ifd1p3jx.v"
// file 71 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/iologic.v"
// file 72 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/jtag.v"
// file 73 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/lram.v"
// file 74 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/m18x36.v"
// file 75 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/mipi.v"
// file 76 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/mult18.v"
// file 77 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/mult18x18.v"
// file 78 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/mult18x36.v"
// file 79 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/mult36.v"
// file 80 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/mult36x36.v"
// file 81 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/mult9.v"
// file 82 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/mult9x9.v"
// file 83 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/multaddsub18x18.v"
// file 84 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/multaddsub18x18wide.v"
// file 85 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/multaddsub18x36.v"
// file 86 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/multaddsub36x36.v"
// file 87 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/multaddsub9x9wide.v"
// file 88 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/multiboot.v"
// file 89 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/multpreadd18x18.v"
// file 90 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/multpreadd9x9.v"
// file 91 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/ofd1p3bx.v"
// file 92 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/ofd1p3dx.v"
// file 93 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/ofd1p3ix.v"
// file 94 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/ofd1p3jx.v"
// file 95 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/osc.v"
// file 96 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/osca.v"
// file 97 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/oscd.v"
// file 98 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/pcie.v"
// file 99 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/pdp16k.v"
// file 100 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/pdpsc16k.v"
// file 101 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/pdpsc512k.v"
// file 102 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/pll.v"
// file 103 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/plla.v"
// file 104 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/pllrefcs.v"
// file 105 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/pmu.v"
// file 106 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/preadd9.v"
// file 107 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/refmux.v"
// file 108 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/reg18.v"
// file 109 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/sedc.v"
// file 110 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/seio18.v"
// file 111 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/seio33.v"
// file 112 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/sgmiicdr.v"
// file 113 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/siologic.v"
// file 114 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/sp16k.v"
// file 115 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/sp512k.v"
// file 116 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/tsalla.v"
// file 117 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/usb23.v"
// file 118 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/wdt.v"
// file 119 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/uaplatform/dpr16x4.v"
// file 120 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/uaplatform/fd1p3bx.v"
// file 121 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/uaplatform/fd1p3dx.v"
// file 122 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/uaplatform/fd1p3ix.v"
// file 123 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/uaplatform/fd1p3jx.v"
// file 124 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/uaplatform/gsr.v"
// file 125 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/uaplatform/ib.v"
// file 126 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/uaplatform/ob.v"
// file 127 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/uaplatform/obz.v"
// file 128 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/uaplatform/pclkdivsp.v"
// file 129 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/uaplatform/spr16x4.v"
// file 130 "c:/lscc/radiant/2023.1/cae_library/simulation/verilog/uaplatform/widefn9.v"

//
// Verilog Description of module DDR3_PHY_2
// module wrapper written out since it is a black-box. 
//

//

module DDR3_PHY_2 (clk_i, eclk_i, clk_stable_i, dqsbuf_pause_i, ddr_rst_i, 
            update_done_i, sclk_o, dll_update_o, phy_init_act_o, wl_act_o, 
            wl_err_o, rt_err_o, rst_cntr_ready_o, csm_ready_o, dfi_rst_n_i, 
            dfi_addr_i, dfi_bank_i, dfi_cas_n_i, dfi_cke_i, dfi_cs_n_i, 
            dfi_odt_i, dfi_ras_n_i, dfi_we_n_i, dfi_wrdata_i, dfi_wrdataen_i, 
            dfi_wrdata_mask_i, dfi_init_start_i, dfi_rddata_o, dfi_init_complete_o, 
            dfi_rddata_valid_o, em_ddr_rst_n_o, em_ddr_clk_o, em_ddr_cke_o, 
            em_ddr_addr_o, em_ddr_ba_o, em_ddr_cs_n_o, em_ddr_odt_o, 
            em_ddr_cas_n_o, em_ddr_ras_n_o, em_ddr_we_n_o, em_ddr_dm_o, 
            em_ddr_dqs_io, em_ddr_data_io) /* synthesis cpe_box=1 */ ;
    input clk_i;
    input eclk_i;
    input clk_stable_i;
    input dqsbuf_pause_i;
    input ddr_rst_i;
    input update_done_i;
    output sclk_o;
    output dll_update_o;
    output phy_init_act_o;
    output wl_act_o;
    output wl_err_o;
    output rt_err_o;
    output rst_cntr_ready_o;
    output csm_ready_o;
    input dfi_rst_n_i;
    input [13:0]dfi_addr_i;
    input [2:0]dfi_bank_i;
    input dfi_cas_n_i;
    input [0:0]dfi_cke_i;
    input [0:0]dfi_cs_n_i;
    input [0:0]dfi_odt_i;
    input dfi_ras_n_i;
    input dfi_we_n_i;
    input [63:0]dfi_wrdata_i;
    input dfi_wrdataen_i;
    input [7:0]dfi_wrdata_mask_i;
    input dfi_init_start_i;
    output [63:0]dfi_rddata_o;
    output dfi_init_complete_o;
    output dfi_rddata_valid_o;
    output em_ddr_rst_n_o;
    output [0:0]em_ddr_clk_o;
    output [0:0]em_ddr_cke_o;
    output [13:0]em_ddr_addr_o;
    output [2:0]em_ddr_ba_o;
    output [0:0]em_ddr_cs_n_o;
    output [0:0]em_ddr_odt_o;
    output em_ddr_cas_n_o;
    output em_ddr_ras_n_o;
    output em_ddr_we_n_o;
    output [1:0]em_ddr_dm_o;
    inout [1:0]em_ddr_dqs_io;
    inout [15:0]em_ddr_data_io;
    
    
    
endmodule
