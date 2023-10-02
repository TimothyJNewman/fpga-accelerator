#-- Lattice Semiconductor Corporation Ltd.
#-- Synplify OEM project file C:/Users/timot/Documents/Programming/fpga-accelerator/Software/Lattice_Project_1/impl_1/launch_synplify.tcl
#-- Written on Sun Oct  1 02:23:29 2023

project -close
set filename "C:/Users/timot/Documents/Programming/fpga-accelerator/Software/Lattice_Project_1/impl_1/impl_1_syn.prj"
project -new "$filename"
set create_new 1

#device options
set_option -technology LIFCL
set_option -part LIFCL_40
set_option -package CABGA256C
set_option -speed_grade -7

if {$create_new == 1} {
	#-- add synthesis options
	#compilation/mapping options
	set_option -symbolic_fsm_compiler true
	set_option -resource_sharing true

	#use verilog standard option
	set_option -vlog_std v2001
	set_option -disable_io_insertion false

	#map options
	set_option -frequency 200
	set_option -maxfan 1000
	set_option -auto_constrain_io 0
	set_option -retiming false; set_option -pipe true
	set_option -force_gsr auto
	set_option -compiler_compatible 0
	
	
	set_option -default_enum_encoding default

	#timing analysis options
	
	

	#automatic place and route (vendor) options
	set_option -write_apr_constraint 1

	#synplifyPro options
	set_option -fix_gated_and_generated_clocks 0
	set_option -update_models_cp 0
	set_option -resolve_multiple_driver 0
	
	
	set_option -rw_check_on_ram 0
	set_option -seqshift_no_replicate 0
	
	#-- set any command lines input by customer
	
	set_option -dup false
}
#-- add_file options
add_file -constraint {C:/Users/timot/Documents/Programming/fpga-accelerator/Software/Lattice_Project_1/impl_1/Lattice_Project_1_impl_1_cpe.ldc}
add_file -verilog {C:/lscc/radiant/2023.1/ip/pmi/pmi_lifcl.v}
add_file -vhdl -lib pmi {C:/lscc/radiant/2023.1/ip/pmi/pmi_lifcl.vhd}
set_option -include_path "C:/Users/timot/Documents/Programming/fpga-accelerator/Software/Lattice_Project_1"
add_file -verilog -vlog_std v2001 "C:/Users/timot/Documents/Programming/fpga-accelerator/Software/Lattice_Project_1/IP/MIPI_DPHY_1/rtl/MIPI_DPHY_1.v"
add_file -verilog -vlog_std v2001 "C:/Users/timot/Documents/Programming/fpga-accelerator/Software/Lattice_Project_1/IP/DDR_MEM_1/DDR_MEM_1/rtl/DDR_MEM_1.v"
add_file -verilog -vlog_std v2001 "C:/Users/timot/Documents/Programming/fpga-accelerator/Software/Lattice_Project_1/IP/MIPI_DPHY_2/rtl/MIPI_DPHY_2.v"
add_file -verilog -vlog_std v2001 "C:/Users/timot/Documents/Programming/fpga-accelerator/Software/Lattice_Project_1/IP/I2C_CAM/rtl/I2C_CAM.v"
add_file -verilog -vlog_std v2001 "C:/Users/timot/Documents/Programming/fpga-accelerator/Software/Lattice_Project_1/source/impl_1/main.v"
#-- top module name
set_option -top_module {main}
project -result_format "vm"
project -result_file {C:/Users/timot/Documents/Programming/fpga-accelerator/Software/Lattice_Project_1/impl_1/Lattice_Project_1_impl_1.vm}
project -save "$filename"
