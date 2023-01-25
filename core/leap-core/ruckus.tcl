# Load RUCKUS library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code
loadSource -lib epix_leap_core -dir "$::DIR_PATH/rtl"

loadSource -path "$::DIR_PATH/ip/SysMonCore.dcp"

if { $::env(RELEASE) == "EPixHR10k2M" } {

   # Adding the default Si5345 configuration
    add_files -norecurse "$::DIR_PATH/pll-config/EPixHR10k2M/leapCorePllConfig.mem"

} elseif { $::env(RELEASE) == "ePix320KM" } {

    add_files -norecurse "$::DIR_PATH/pll-config/ePix320KM/leapCorePllConfig.mem"

}
