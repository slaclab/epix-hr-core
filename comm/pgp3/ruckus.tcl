# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code and Constraints
loadSource -lib epix_hr_core -dir "$::DIR_PATH/rtl"
loadConstraints -dir "$::DIR_PATH/xdc"
