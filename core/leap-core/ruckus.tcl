# Load RUCKUS library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code
loadSource -lib epix_leap_core -dir "$::DIR_PATH/rtl"

# Adding the default Si5345 configuration
add_files -norecurse "$::DIR_PATH/pll-config/leapCorePllConfig.mem"
