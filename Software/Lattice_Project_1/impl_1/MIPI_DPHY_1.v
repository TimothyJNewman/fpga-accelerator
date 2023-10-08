// Verilog netlist produced by program LSE 
// Netlist written on Sun Oct  8 01:54:57 2023
// Source file index table: 
// Object locations will have the form @<file_index>(<first_ line>[<left_column>],<last_line>[<right_column>])
// file 0 "/home/timothyjabez/lscc/radiant/2023.1/ip/avant/fifo/rtl/lscc_fifo.v"
// file 1 "/home/timothyjabez/lscc/radiant/2023.1/ip/avant/fifo_dc/rtl/lscc_fifo_dc.v"
// file 2 "/home/timothyjabez/lscc/radiant/2023.1/ip/avant/ram_dp/rtl/lscc_ram_dp.v"
// file 3 "/home/timothyjabez/lscc/radiant/2023.1/ip/avant/ram_dp_true/rtl/lscc_ram_dp_true.v"
// file 4 "/home/timothyjabez/lscc/radiant/2023.1/ip/avant/ram_dq/rtl/lscc_ram_dq.v"
// file 5 "/home/timothyjabez/lscc/radiant/2023.1/ip/avant/rom/rtl/lscc_rom.v"
// file 6 "/home/timothyjabez/lscc/radiant/2023.1/ip/common/adder/rtl/lscc_adder.v"
// file 7 "/home/timothyjabez/lscc/radiant/2023.1/ip/common/adder_subtractor/rtl/lscc_add_sub.v"
// file 8 "/home/timothyjabez/lscc/radiant/2023.1/ip/common/complex_mult/rtl/lscc_complex_mult.v"
// file 9 "/home/timothyjabez/lscc/radiant/2023.1/ip/common/counter/rtl/lscc_cntr.v"
// file 10 "/home/timothyjabez/lscc/radiant/2023.1/ip/common/distributed_dpram/rtl/lscc_distributed_dpram.v"
// file 11 "/home/timothyjabez/lscc/radiant/2023.1/ip/common/distributed_rom/rtl/lscc_distributed_rom.v"
// file 12 "/home/timothyjabez/lscc/radiant/2023.1/ip/common/distributed_spram/rtl/lscc_distributed_spram.v"
// file 13 "/home/timothyjabez/lscc/radiant/2023.1/ip/common/mult_accumulate/rtl/lscc_mult_accumulate.v"
// file 14 "/home/timothyjabez/lscc/radiant/2023.1/ip/common/mult_add_sub/rtl/lscc_mult_add_sub.v"
// file 15 "/home/timothyjabez/lscc/radiant/2023.1/ip/common/mult_add_sub_sum/rtl/lscc_mult_add_sub_sum.v"
// file 16 "/home/timothyjabez/lscc/radiant/2023.1/ip/common/multiplier/rtl/lscc_multiplier.v"
// file 17 "/home/timothyjabez/lscc/radiant/2023.1/ip/common/ram_shift_reg/rtl/lscc_shift_register.v"
// file 18 "/home/timothyjabez/lscc/radiant/2023.1/ip/common/subtractor/rtl/lscc_subtractor.v"
// file 19 "/home/timothyjabez/lscc/radiant/2023.1/ip/pmi/pmi_add.v"
// file 20 "/home/timothyjabez/lscc/radiant/2023.1/ip/pmi/pmi_addsub.v"
// file 21 "/home/timothyjabez/lscc/radiant/2023.1/ip/pmi/pmi_complex_mult.v"
// file 22 "/home/timothyjabez/lscc/radiant/2023.1/ip/pmi/pmi_counter.v"
// file 23 "/home/timothyjabez/lscc/radiant/2023.1/ip/pmi/pmi_distributed_dpram.v"
// file 24 "/home/timothyjabez/lscc/radiant/2023.1/ip/pmi/pmi_distributed_rom.v"
// file 25 "/home/timothyjabez/lscc/radiant/2023.1/ip/pmi/pmi_distributed_shift_reg.v"
// file 26 "/home/timothyjabez/lscc/radiant/2023.1/ip/pmi/pmi_distributed_spram.v"
// file 27 "/home/timothyjabez/lscc/radiant/2023.1/ip/pmi/pmi_fifo.v"
// file 28 "/home/timothyjabez/lscc/radiant/2023.1/ip/pmi/pmi_fifo_dc.v"
// file 29 "/home/timothyjabez/lscc/radiant/2023.1/ip/pmi/pmi_mac.v"
// file 30 "/home/timothyjabez/lscc/radiant/2023.1/ip/pmi/pmi_mult.v"
// file 31 "/home/timothyjabez/lscc/radiant/2023.1/ip/pmi/pmi_multaddsub.v"
// file 32 "/home/timothyjabez/lscc/radiant/2023.1/ip/pmi/pmi_multaddsubsum.v"
// file 33 "/home/timothyjabez/lscc/radiant/2023.1/ip/pmi/pmi_ram_dp.v"
// file 34 "/home/timothyjabez/lscc/radiant/2023.1/ip/pmi/pmi_ram_dp_be.v"
// file 35 "/home/timothyjabez/lscc/radiant/2023.1/ip/pmi/pmi_ram_dp_true.v"
// file 36 "/home/timothyjabez/lscc/radiant/2023.1/ip/pmi/pmi_ram_dq.v"
// file 37 "/home/timothyjabez/lscc/radiant/2023.1/ip/pmi/pmi_ram_dq_be.v"
// file 38 "/home/timothyjabez/lscc/radiant/2023.1/ip/pmi/pmi_rom.v"
// file 39 "/home/timothyjabez/lscc/radiant/2023.1/ip/pmi/pmi_sub.v"
// file 40 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/ACC54.v"
// file 41 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/ADC.v"
// file 42 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/ALUREG.v"
// file 43 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/AON.v"
// file 44 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/BB_ADC.v"
// file 45 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/BB_CDR.v"
// file 46 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/BB_I3C_A.v"
// file 47 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/BB_PROGRAMN.v"
// file 48 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/BFD1P3KX.v"
// file 49 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/BFD1P3LX.v"
// file 50 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/BNKREF18.v"
// file 51 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/CONFIG_IP.v"
// file 52 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/CONFIG_LMMI.v"
// file 53 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/CONFIG_LMMIA.v"
// file 54 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/DDRDLL.v"
// file 55 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/DIFFIO18.v"
// file 56 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/DLLDEL.v"
// file 57 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/DP16K.v"
// file 58 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/DPHY.v"
// file 59 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/DPSC512K.v"
// file 60 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/DQSBUF.v"
// file 61 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/EBR.v"
// file 62 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/ECLKDIV.v"
// file 63 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/ECLKSYNC.v"
// file 64 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/FBMUX.v"
// file 65 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/FIFO16K.v"
// file 66 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/I2CFIFO.v"
// file 67 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/IFD1P3BX.v"
// file 68 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/IFD1P3DX.v"
// file 69 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/IFD1P3IX.v"
// file 70 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/IFD1P3JX.v"
// file 71 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/IOLOGIC.v"
// file 72 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/JTAG.v"
// file 73 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/LRAM.v"
// file 74 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/M18X36.v"
// file 75 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/MIPI.v"
// file 76 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/MULT18.v"
// file 77 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/MULT18X18.v"
// file 78 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/MULT18X36.v"
// file 79 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/MULT36.v"
// file 80 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/MULT36X36.v"
// file 81 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/MULT9.v"
// file 82 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/MULT9X9.v"
// file 83 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/MULTADDSUB18X18.v"
// file 84 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/MULTADDSUB18X18WIDE.v"
// file 85 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/MULTADDSUB18X36.v"
// file 86 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/MULTADDSUB36X36.v"
// file 87 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/MULTADDSUB9X9WIDE.v"
// file 88 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/MULTIBOOT.v"
// file 89 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/MULTPREADD18X18.v"
// file 90 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/MULTPREADD9X9.v"
// file 91 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/OFD1P3BX.v"
// file 92 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/OFD1P3DX.v"
// file 93 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/OFD1P3IX.v"
// file 94 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/OFD1P3JX.v"
// file 95 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/OSC.v"
// file 96 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/OSCA.v"
// file 97 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/OSCD.v"
// file 98 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/PCIE.v"
// file 99 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/PDP16K.v"
// file 100 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/PDPSC16K.v"
// file 101 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/PDPSC512K.v"
// file 102 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/PLL.v"
// file 103 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/PLLA.v"
// file 104 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/PLLREFCS.v"
// file 105 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/PMU.v"
// file 106 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/PREADD9.v"
// file 107 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/REFMUX.v"
// file 108 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/REG18.v"
// file 109 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/SEDC.v"
// file 110 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/SEIO18.v"
// file 111 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/SEIO33.v"
// file 112 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/SGMIICDR.v"
// file 113 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/SIOLOGIC.v"
// file 114 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/SP16K.v"
// file 115 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/SP512K.v"
// file 116 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/TSALLA.v"
// file 117 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/USB23.v"
// file 118 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/lifcl/WDT.v"
// file 119 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/uaplatform/DPR16X4.v"
// file 120 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/uaplatform/FD1P3BX.v"
// file 121 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/uaplatform/FD1P3DX.v"
// file 122 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/uaplatform/FD1P3IX.v"
// file 123 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/uaplatform/FD1P3JX.v"
// file 124 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/uaplatform/GSR.v"
// file 125 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/uaplatform/IB.v"
// file 126 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/uaplatform/OB.v"
// file 127 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/uaplatform/OBZ.v"
// file 128 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/uaplatform/PCLKDIVSP.v"
// file 129 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/uaplatform/SPR16X4.v"
// file 130 "/home/timothyjabez/lscc/radiant/2023.1/cae_library/simulation/verilog/uaplatform/WIDEFN9.v"

//
// Verilog Description of module MIPI_DPHY_1
// module wrapper written out since it is a black-box. 
//

//

module MIPI_DPHY_1 (sync_clk_i, sync_rst_i, lmmi_clk_i, lmmi_resetn_i, 
            lmmi_wdata_i, lmmi_wr_rdn_i, lmmi_offset_i, lmmi_request_i, 
            lmmi_ready_o, lmmi_rdata_o, lmmi_rdata_valid_o, hs_rx_data_o, 
            hs_rx_data_sync_o, pll_lock_i, clk_p_io, clk_n_io, data_p_io, 
            data_n_io, pd_dphy_i, clk_byte_o, ready_o) /* synthesis cpe_box=1 */ ;
    input sync_clk_i;
    input sync_rst_i;
    input lmmi_clk_i;
    input lmmi_resetn_i;
    input [3:0]lmmi_wdata_i;
    input lmmi_wr_rdn_i;
    input [4:0]lmmi_offset_i;
    input lmmi_request_i;
    output lmmi_ready_o;
    output [3:0]lmmi_rdata_o;
    output lmmi_rdata_valid_o;
    output [31:0]hs_rx_data_o;
    output [3:0]hs_rx_data_sync_o;
    input pll_lock_i;
    inout clk_p_io;
    inout clk_n_io;
    inout [3:0]data_p_io;
    inout [3:0]data_n_io;
    input pd_dphy_i;
    output clk_byte_o;
    output ready_o;
    
    
    
endmodule
