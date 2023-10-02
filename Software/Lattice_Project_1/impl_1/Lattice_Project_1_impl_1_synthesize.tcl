if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/2023.1} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) 1
set para(prj_dir) "C:/Users/timot/Documents/Programming/fpga-accelerator/Software/Lattice_Project_1"
# synthesize IPs
# synthesize VMs
# propgate constraints
file delete -force -- Lattice_Project_1_impl_1_cpe.ldc
run_engine_newmsg cpe -f "Lattice_Project_1_impl_1.cprj" "MIPI_DPHY_1.cprj" "DDR_MEM_1.cprj" "MIPI_DPHY_2.cprj" "I2C_DPHY_1.cprj" "I2C_DPHY_2.cprj" "PLL_1.cprj" -a "LIFCL"  -o Lattice_Project_1_impl_1_cpe.ldc
# synthesize top design
file delete -force -- Lattice_Project_1_impl_1.vm Lattice_Project_1_impl_1.ldc
run_engine synpwrap -prj "Lattice_Project_1_impl_1_synplify.tcl" -log "Lattice_Project_1_impl_1.srf"
run_postsyn [list -a LIFCL -p LIFCL-40 -t CABGA256 -sp 7_High-Performance_1.0V -oc Commercial -top -w -o Lattice_Project_1_impl_1_syn.udb Lattice_Project_1_impl_1.vm] "C:/Users/timot/Documents/Programming/fpga-accelerator/Software/Lattice_Project_1/impl_1/Lattice_Project_1_impl_1.ldc"

} out]} {
   runtime_log $out
   exit 1
}
