# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load Hardware ruckus files
loadRuckusTcl "$::DIR_PATH/$::env(COMM_TYPE)"
