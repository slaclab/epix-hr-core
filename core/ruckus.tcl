# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load Hardware ruckus files
loadRuckusTcl "$::DIR_PATH/hr-core"
loadRuckusTcl "$::DIR_PATH/leap-core"

