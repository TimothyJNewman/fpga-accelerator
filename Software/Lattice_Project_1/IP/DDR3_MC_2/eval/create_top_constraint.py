# =============================================================================
# >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# -----------------------------------------------------------------------------
#   Copyright (c) 2019 by Lattice Semiconductor Corporation
#   ALL RIGHTS RESERVED
# -----------------------------------------------------------------------------
#
#   Permission:
#
#      Lattice SG Pte. Ltd. grants permission to use this code
#      pursuant to the terms of the Lattice Reference Design License Agreement.
#
#
#   Disclaimer:
#
#      This VHDL or Verilog source code is intended as a design reference
#      which illustrates how these types of functions can be implemented.
#      It is the user's responsibility to verify their design for
#      consistency and functionality through the use of formal
#      verification methods.  Lattice provides no warranty
#      regarding the use or functionality of this code.
#
# ------------------------------------------------------------------------------
#
#                  Lattice SG Pte. Ltd.
#                  101 Thomson Road, United Square #07-02
#                  Singapore 307591
#
#
#                  TEL: 1-800-Lattice (USA and Canada)
#                       +65-6631-2000 (Singapore)
#                       +1-503-268-8001 (other locations)
#
#                  web: http://www.latticesemi.com/
#                  email: techsupport@latticesemi.com
#
# ------------------------------------------------------------------------------
#
# ==============================================================================
#                         FILE DETAILS
# Project               : LIFCL
# File                  : create_top_constraint.py
# Title                 :
# Dependencies          : 1.
#                       : 2.
# Description           :
# ==============================================================================
#                        REVISION HISTORY
# Version               : 1.0.0
# Author(s)             :
# Mod. Date             :
# Changes Made          : Initial release.
# ==============================================================================
import os

# Initialize parameter dictionary
ddr3_mc_params = {'GEAR':0, 'PLL_EN':0, 'CLKI_FREQ': 0, 'CLKI_DIVIDER_ACTUAL_STR': 0,
                  'FBCLK_DIVIDER_ACTUAL_STR': 0, 'CLKOP_FREQ_ACTUAL': 0.0, 'DIVOP_ACTUAL_STR': 0,
                  'CLKOS_FREQ_ACTUAL': 0.0, 'DIVOS_ACTUAL_STR': 0,  'DATA_WIDTH': 0, 'ROW_WIDTH':0}
str_param = ['GEAR', 'PLL_EN', 'CLKI_FREQ', 'CLKI_DIVIDER_ACTUAL_STR', 'FBCLK_DIVIDER_ACTUAL_STR',
             'CLKOP_FREQ_ACTUAL', 'DIVOP_ACTUAL_STR', 'CLKOS_FREQ_ACTUAL', 'DIVOS_ACTUAL_STR',
             'DATA_WIDTH', 'ROW_WIDTH', 'END']

f_pdc = open('eval/top_constraint.pdc', 'w')


def load_parameters():
    global ddr3_mc_params

    f_params = open('eval/dut_params.v', 'r')
    param = ''
    i = 0
    while True:
        line = f_params.readline()
        str_spl = line.split(' ')
        val = str_spl[-1]
        param = str_spl[1]
        if str_param[i] == 'END':
            break
        elif param == str_param[i]:
            pos = val.index(';')
            val = val[0:pos]
            #print(param, ' = ', val)
            i = i + 1
            if '.' in val:
                ddr3_mc_params[str_spl[1]] = float(val)
            else:
                ddr3_mc_params[str_spl[1]] = int(val.replace('"', ''))
                #print(str_spl[1], " = ", val)
    return


load_parameters()
f_pdc.write("# Below are constraints for the clocks of DDR3 SDRAM Controller\n")
f_pdc.write("# You need to copy these to your top level constraints \n")
f_pdc.write("# Optional: You can replace the * with the actual instance path from top-level RTL in the FPGA design\n\n")
if (ddr3_mc_params['PLL_EN'] == 1):
    f_pdc.write("# Constraints for PLL reference clock.\n")
    f_pdc.write("create_clock -name {clk_i} -period %.3f [get_ports clk_i]\n\n" % (1000.0 / ddr3_mc_params['CLKI_FREQ']))
    f_pdc.write("# Constraint for the PLL-generated clocks\n")
    f_pdc.write("create_generated_clock -name {clkop} -source [get_pins */lscc_ddr3_mc_inst/EN_PLL.u0_ddr_clks/lscc_pll_inst/gen_no_refclk_mon.u_PLL.PLL_inst/REFCK] -divide_by %d -multiply_by %d [get_pins */lscc_ddr3_mc_inst/EN_PLL.u0_ddr_clks/lscc_pll_inst/gen_no_refclk_mon.u_PLL.PLL_inst/CLKOP]\n" % (ddr3_mc_params['CLKI_DIVIDER_ACTUAL_STR'], ddr3_mc_params['FBCLK_DIVIDER_ACTUAL_STR']))
    f_pdc.write("create_generated_clock -name {clkos} -source [get_pins */lscc_ddr3_mc_inst/EN_PLL.u0_ddr_clks/lscc_pll_inst/gen_no_refclk_mon.u_PLL.PLL_inst/REFCK] -divide_by 1 [get_pins */lscc_ddr3_mc_inst/EN_PLL.u0_ddr_clks/lscc_pll_inst/gen_no_refclk_mon.u_PLL.PLL_inst/CLKOS]\n\n")
    if (ddr3_mc_params['DATA_WIDTH'] == 32 and ddr3_mc_params['ROW_WIDTH'] == 16):
        f_pdc.write("# Need to place the PLL to lower right corner when DDR width=32 and row width=16.\n")
        f_pdc.write("ldc_set_location -site {PLL_LRC} [get_cells {*/lscc_ddr3_mc_inst/EN_PLL.u0_ddr_clks/lscc_pll_inst/gen_no_refclk_mon.u_PLL.PLL_inst}]\n\n")
else:
    f_pdc.write("# Constraints for PLL in eval_top.\n")
    f_pdc.write("# You should replace this according to your actual PLL configuration.\n")
    f_pdc.write("create_clock -name {clk_i} -period %.3f [get_ports clk_i]\n\n" % (1000.0 / ddr3_mc_params['CLKI_FREQ']))
    f_pdc.write("# Constraint for the PLL-generated clocks in eval_top\n")
    f_pdc.write("create_generated_clock -name {clkop} -source [get_pins EXT_PLL.lscc_pll_inst/gen_no_refclk_mon.u_PLL.PLL_inst/REFCK] -divide_by %d -multiply_by %d [get_pins EXT_PLL.lscc_pll_inst/gen_no_refclk_mon.u_PLL.PLL_inst/CLKOP]\n" % (ddr3_mc_params['CLKI_DIVIDER_ACTUAL_STR'], ddr3_mc_params['FBCLK_DIVIDER_ACTUAL_STR']))
    f_pdc.write("create_generated_clock -name {clkos} -source [get_pins EXT_PLL.lscc_pll_inst/gen_no_refclk_mon.u_PLL.PLL_inst/REFCK] -divide_by 1 [get_pins EXT_PLL.lscc_pll_inst/gen_no_refclk_mon.u_PLL.PLL_inst/CLKOS]\n\n")
    if (ddr3_mc_params['DATA_WIDTH'] == 32 and ddr3_mc_params['ROW_WIDTH'] == 16):
        f_pdc.write("# Need to place the PLL to lower right corner when DDR width=32 and row width=16.\n")
        f_pdc.write("ldc_set_location -site {PLL_LRC} [get_cells {EXT_PLL.lscc_pll_inst/gen_no_refclk_mon.u_PLL.PLL_inst}]\n\n")
    
f_pdc.write("# Constrain the clocks generated in the DDR3 SDRAM PHY\n")

if (ddr3_mc_params['PLL_EN'] == 1):
    f_pdc.write("create_generated_clock -name {eclkout_w} -source [get_pins */lscc_ddr3_mc_inst/EN_PLL.u0_ddr_clks/lscc_pll_inst/gen_no_refclk_mon.u_PLL.PLL_inst/CLKOP] -divide_by 1 [get_pins */lscc_ddr3_mc_inst/NATIVE_ITF.u0_ddr3_mc_wrapper/U1_ddr3_sdram_phy/phy_wrapper_lscc_ddr_mem/DDR_MEM_%d_BIT.u0_lscc_ddr_mem_inst/u1_common_logic/u0_ECLKSYNC.ECLKSYNC_inst/ECLKOUT]\n" % ddr3_mc_params['DATA_WIDTH'])
else:
    f_pdc.write("create_generated_clock -name {eclkout_w} -source [get_pins EXT_PLL.lscc_pll_inst/gen_no_refclk_mon.u_PLL.PLL_inst/CLKOP] -divide_by 1 [get_pins */lscc_ddr3_mc_inst/NATIVE_ITF.u0_ddr3_mc_wrapper/U1_ddr3_sdram_phy/phy_wrapper_lscc_ddr_mem/DDR_MEM_%d_BIT.u0_lscc_ddr_mem_inst/u1_common_logic/u0_ECLKSYNC.ECLKSYNC_inst/ECLKOUT]\n" % ddr3_mc_params['DATA_WIDTH'])
    
f_pdc.write("create_generated_clock -name {sclk_o} -source [get_pins */lscc_ddr3_mc_inst/NATIVE_ITF.u0_ddr3_mc_wrapper/U1_ddr3_sdram_phy/phy_wrapper_lscc_ddr_mem/DDR_MEM_%d_BIT.u0_lscc_ddr_mem_inst/u1_common_logic/u0_ECLKSYNC.ECLKSYNC_inst/ECLKOUT] " % ddr3_mc_params['DATA_WIDTH'])
f_pdc.write("-divide_by %d [get_pins */lscc_ddr3_mc_inst/NATIVE_ITF.u0_ddr3_mc_wrapper/U1_ddr3_sdram_phy/phy_wrapper_lscc_ddr_mem/DDR_MEM_%d_BIT.u0_lscc_ddr_mem_inst/u1_common_logic/u0_ECLKDIV.ECLKDIV_inst/DIVOUT]\n\n" % (ddr3_mc_params['GEAR'], ddr3_mc_params['DATA_WIDTH']))

f_pdc.write("# The LOCK signals from PLL and DDRDLL only toggle once during reset and once during loss of lock.\n")
f_pdc.write("# The DDR3_MC halts the data path in both cases.\n")
f_pdc.write("# Thus the timing from the LOCK to the double FF synchronizer can be ignored.\n")
if (ddr3_mc_params['PLL_EN'] == 1):    
    f_pdc.write("set_false_path -from [get_pins */lscc_ddr3_mc_inst/EN_PLL.u0_ddr_clks/lscc_pll_inst/gen_no_refclk_mon.u_PLL.PLL_inst/LOCK] ")
else:
    f_pdc.write("set_false_path -from [get_pins EXT_PLL.lscc_pll_inst/gen_no_refclk_mon.u_PLL.PLL_inst/LOCK] ")
f_pdc.write("-to [get_pins */lscc_ddr3_mc_inst/NATIVE_ITF.u0_ddr3_mc_wrapper/U1_ddr3_sdram_phy/phy_wrapper_lscc_ddr_mem/DDR_MEM_%d_BIT.u0_lscc_ddr_mem_inst/u1_common_logic/u1_mem_sync/pll_lock_d1*.ff_inst/DF]\n" % ddr3_mc_params['DATA_WIDTH'])
f_pdc.write("set_false_path -from [get_pins */lscc_ddr3_mc_inst/NATIVE_ITF.u0_ddr3_mc_wrapper/U1_ddr3_sdram_phy/phy_wrapper_lscc_ddr_mem/DDR_MEM_%d_BIT.u0_lscc_ddr_mem_inst/u1_common_logic/u0_DDRDLL.DDRDLL_inst/LOCK] " % ddr3_mc_params['DATA_WIDTH'])
f_pdc.write("-to [get_pins */lscc_ddr3_mc_inst/NATIVE_ITF.u0_ddr3_mc_wrapper/U1_ddr3_sdram_phy/phy_wrapper_lscc_ddr_mem/DDR_MEM_%d_BIT.u0_lscc_ddr_mem_inst/u1_common_logic/u1_mem_sync/dll_lock_d1*.ff_inst/DF]\n\n" % ddr3_mc_params['DATA_WIDTH'])

f_pdc.write("# The MEMSYNC logic stops the eclkout_w and sclk_o during the reset of DDR primitives as follows:\n")
f_pdc.write("# Stop the eclkout_w and sclk_o, wait for 4 clkos, assert reset for 4 clkos, wait for 4 clkos, resume eclkout_w and sclk_o.\n")
f_pdc.write("# Thus, no need to be concerned on the reset timing requirement for ECLKDIV and DQSBUF.\n")
f_pdc.write("set_false_path -to [get_pins */lscc_ddr3_mc_inst/NATIVE_ITF.u0_ddr3_mc_wrapper/U1_ddr3_sdram_phy/phy_wrapper_lscc_ddr_mem/DDR_MEM_%d_BIT.u0_lscc_ddr_mem_inst/u1_common_logic/u0_ECLKDIV.ECLKDIV_inst/DIVRST]\n" % ddr3_mc_params['DATA_WIDTH'])
f_pdc.write("set_false_path -to [get_pins */lscc_ddr3_mc_inst/NATIVE_ITF.u0_ddr3_mc_wrapper/U1_ddr3_sdram_phy/phy_wrapper_lscc_ddr_mem/DDR_MEM_%d_BIT.u0_lscc_ddr_mem_inst/DW_8.u1_dq_dqs_dm_unit/u0_DQSBUF.DQSBUF_inst/RST]\n" % ddr3_mc_params['DATA_WIDTH'])
if (ddr3_mc_params['DATA_WIDTH'] >= 16):
    f_pdc.write("set_false_path -to [get_pins */lscc_ddr3_mc_inst/NATIVE_ITF.u0_ddr3_mc_wrapper/U1_ddr3_sdram_phy/phy_wrapper_lscc_ddr_mem/DDR_MEM_%d_BIT.u0_lscc_ddr_mem_inst/DW_16.u1_dq_dqs_dm_unit/u0_DQSBUF.DQSBUF_inst/RST]\n" % ddr3_mc_params['DATA_WIDTH'])
if (ddr3_mc_params['DATA_WIDTH'] >= 24):
    f_pdc.write("set_false_path -to [get_pins */lscc_ddr3_mc_inst/NATIVE_ITF.u0_ddr3_mc_wrapper/U1_ddr3_sdram_phy/phy_wrapper_lscc_ddr_mem/DDR_MEM_%d_BIT.u0_lscc_ddr_mem_inst/DW_24.u1_dq_dqs_dm_unit/u0_DQSBUF.DQSBUF_inst/RST]\n" % ddr3_mc_params['DATA_WIDTH'])
if (ddr3_mc_params['DATA_WIDTH'] >= 32):
    f_pdc.write("set_false_path -to [get_pins */lscc_ddr3_mc_inst/NATIVE_ITF.u0_ddr3_mc_wrapper/U1_ddr3_sdram_phy/phy_wrapper_lscc_ddr_mem/DDR_MEM_%d_BIT.u0_lscc_ddr_mem_inst/DW_32.u1_dq_dqs_dm_unit/u0_DQSBUF.DQSBUF_inst/RST]\n" % ddr3_mc_params['DATA_WIDTH'])
f_pdc.write("\n")

f_pdc.write("# Constraints for double FF synchronizer.\n")
f_pdc.write("set_max_delay -to [get_pins */lscc_ddr3_mc_inst/NATIVE_ITF.u0_ddr3_mc_wrapper/U1_ddr3_sdram_phy/phy_wrapper_lscc_ddr_mem/DDR_MEM_%d_BIT.u0_lscc_ddr_mem_inst/u1_common_logic/u1_mem_sync/dll_lock_d2*.ff_inst/DF] 1\n" % ddr3_mc_params['DATA_WIDTH'])
f_pdc.write("set_max_delay -to [get_pins */lscc_ddr3_mc_inst/NATIVE_ITF.u0_ddr3_mc_wrapper/U1_ddr3_sdram_phy/phy_wrapper_lscc_ddr_mem/DDR_MEM_%d_BIT.u0_lscc_ddr_mem_inst/u1_common_logic/u1_mem_sync/pll_lock_d2*.ff_inst/DF] 1\n" % ddr3_mc_params['DATA_WIDTH'])
f_pdc.write("set_false_path -to [get_pins */lscc_ddr3_mc_inst/NATIVE_ITF.u0_ddr3_mc_wrapper/U1_ddr3_sdram_phy/phy_wrapper_lscc_ddr_mem/DDR_MEM_%d_BIT.u0_lscc_ddr_mem_inst/ready_d1*.ff_inst/DF]\n" % ddr3_mc_params['DATA_WIDTH'])
f_pdc.write("set_false_path -to [get_pins */lscc_ddr3_mc_inst/NATIVE_ITF.u0_ddr3_mc_wrapper/U1_ddr3_sdram_phy/phy_wrapper_lscc_ddr_mem/DDR_MEM_%d_BIT.u0_lscc_ddr_mem_inst/ready_d2*.ff_inst/DF]\n" % ddr3_mc_params['DATA_WIDTH'])
f_pdc.write("# Group the ready signal from clkos domain together with the diuble FF synchronizer in sclk_o domain.\n")
f_pdc.write("ldc_create_group -name ddrmem_ready -bbox {2 1} [get_cells {*/lscc_ddr3_mc_inst/NATIVE_ITF.u0_ddr3_mc_wrapper/U1_ddr3_sdram_phy/phy_wrapper_lscc_ddr_mem/DDR_MEM_%d_BIT.u0_lscc_ddr_mem_inst/u1_common_logic/u1_mem_sync/ready.ff_inst " % ddr3_mc_params['DATA_WIDTH'])
f_pdc.write("*/lscc_ddr3_mc_inst/NATIVE_ITF.u0_ddr3_mc_wrapper/U1_ddr3_sdram_phy/phy_wrapper_lscc_ddr_mem/DDR_MEM_%d_BIT.u0_lscc_ddr_mem_inst/ready_d1*.ff_inst " % ddr3_mc_params['DATA_WIDTH'])
f_pdc.write("*/lscc_ddr3_mc_inst/NATIVE_ITF.u0_ddr3_mc_wrapper/U1_ddr3_sdram_phy/phy_wrapper_lscc_ddr_mem/DDR_MEM_%d_BIT.u0_lscc_ddr_mem_inst/ready_d2*.ff_inst}]\n\n" % ddr3_mc_params['DATA_WIDTH'])

f_pdc.write("# The timing of DDR IOs are guaranteed by Hardware and is using the dedicated routing path to the DDR primitives.\n")
f_pdc.write("set_false_path -to [get_ports em_ddr_dm_o*]\n")
f_pdc.write("set_false_path -to [get_ports em_ddr_clk_o*]\n")
f_pdc.write("set_false_path -to [get_ports em_ddr_cke_o*]\n")
f_pdc.write("set_false_path -to [get_ports em_ddr_cs_n_o*]\n")
f_pdc.write("set_false_path -to [get_ports em_ddr_ras_n_o]\n")
f_pdc.write("set_false_path -to [get_ports em_ddr_cas_n_o]\n")
f_pdc.write("set_false_path -to [get_ports em_ddr_we_n_o]\n")
f_pdc.write("set_false_path -to [get_ports em_ddr_odt_o*]\n")
f_pdc.write("set_false_path -to [get_ports em_ddr_addr_o*]\n")
f_pdc.write("set_false_path -to [get_ports em_ddr_ba_o*]\n")
f_pdc.write("set_false_path -to [get_ports em_ddr_reset_n_o]\n")
f_pdc.write("set_false_path -to [get_ports em_ddr_data_io*] -from [get_ports em_ddr_data_io*]\n")
f_pdc.write("set_false_path -to [get_ports em_ddr_dqs_io*] -from [get_ports em_ddr_dqs_io*]\n")

f_pdc.write("# Constraints for double FF that synchronizes the de-assertion of reset.\n")
f_pdc.write("set_false_path -to [get_pins */lscc_ddr3_mc_inst/NATIVE_ITF.u0_ddr3_mc_wrapper/U1_ddr3_sdram_phy/phy_wrapper_lscc_ddr_mem/DDR_MEM_%d_BIT.u0_lscc_ddr_mem_inst/u1_common_logic/u1_mem_sync/mem_sync_rst_d1*.ff_inst/LSR]\n" % ddr3_mc_params['DATA_WIDTH'])
f_pdc.write("set_false_path -to [get_pins */lscc_ddr3_mc_inst/NATIVE_ITF.u0_ddr3_mc_wrapper/U1_ddr3_sdram_phy/phy_wrapper_lscc_ddr_mem/DDR_MEM_%d_BIT.u0_lscc_ddr_mem_inst/u1_common_logic/u1_mem_sync/mem_sync_rst_d2*.ff_inst/LSR]\n" % ddr3_mc_params['DATA_WIDTH'])
#f_pdc.write("set_max_delay  -to [get_pins */lscc_ddr3_mc_inst/NATIVE_ITF.u0_ddr3_mc_wrapper/U1_ddr3_sdram_phy/phy_wrapper_lscc_ddr_mem/DDR_MEM_%d_BIT.u0_lscc_ddr_mem_inst/u1_common_logic/u1_mem_sync/mem_sync_rst_d2*.ff_inst/DF] 1\n" % ddr3_mc_params['DATA_WIDTH'])
f_pdc.write("set_false_path -to [get_pins */lscc_ddr3_mc_inst/NATIVE_ITF.u0_ddr3_mc_wrapper/U1_ddr3_sdram_phy/phy_wrapper_lscc_ddr_mem/DDR_MEM_%d_BIT.u0_lscc_ddr_mem_inst/ddrmem_rst_n_d1*.ff_inst/LSR]\n" % ddr3_mc_params['DATA_WIDTH'])
f_pdc.write("set_false_path -to [get_pins */lscc_ddr3_mc_inst/NATIVE_ITF.u0_ddr3_mc_wrapper/U1_ddr3_sdram_phy/phy_wrapper_lscc_ddr_mem/DDR_MEM_%d_BIT.u0_lscc_ddr_mem_inst/ddrmem_rst_n_d2*.ff_inst/LSR]\n" % ddr3_mc_params['DATA_WIDTH'])
#f_pdc.write("set_max_delay  -to [get_pins */lscc_ddr3_mc_inst/NATIVE_ITF.u0_ddr3_mc_wrapper/U1_ddr3_sdram_phy/phy_wrapper_lscc_ddr_mem/DDR_MEM_%d_BIT.u0_lscc_ddr_mem_inst/ddrmem_rst_n_d2*.ff_inst/DF] 1\n" % ddr3_mc_params['DATA_WIDTH'])
f_pdc.write("set_false_path -to [get_pins */lscc_ddr3_mc_inst/NATIVE_ITF.u0_ddr3_mc_wrapper/ddr3mc_rst_n_d1*.ff_inst/LSR]\n")
f_pdc.write("set_false_path -to [get_pins */lscc_ddr3_mc_inst/NATIVE_ITF.u0_ddr3_mc_wrapper/ddr3mc_rst_n_d2*.ff_inst/LSR]\n")
#f_pdc.write("set_max_delay  -to [get_pins */lscc_ddr3_mc_inst/NATIVE_ITF.u0_ddr3_mc_wrapper/ddr3mc_rst_n_d2*.ff_inst/DF] 1\n\n")

f_pdc.write("# Constraints on other eval_top ports, you dont need these constraints because these are outside of the DDR3_MC.\n")
f_pdc.write("set_false_path -to [get_pins rst_d1*.ff_inst/LSR]\n")
f_pdc.write("set_false_path -to [get_pins rst_d2*.ff_inst/LSR]\n")
f_pdc.write("set_false_path -to [get_pins mem_rst_n*.ff_inst/DF]\n")
f_pdc.write("set_false_path -to [get_pins lfsr_in_en_r*.ff_inst/DF]\n")
f_pdc.write("set_false_path -to [get_pins lfsr_out_en_r*.ff_inst/DF]\n")
f_pdc.write("set_false_path -to [get_ports lfsr_out_o]\n\n")

f_pdc.write("# This is constraint just to check that there is no unexpected reset connection\n")
f_pdc.write("# The DDR3_MC has double registers that synchronizes the reset de-assertion\n")
f_pdc.write("set_input_delay -clock clk_i -max 5 [get_ports rst_n_i]\n")

f_pdc.close()

