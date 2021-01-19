# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code and Constraints
loadSource -lib epix_hr_core -dir "$::DIR_PATH/rtl"

# Check if required variables exist
if { [info exists ::env(INCLUDE_PGP3_10G)] != 1 && [info exists ::env(INCLUDE_PGP3_6G)] != 1 && [info exists ::env(INCLUDE_PGP3_3G)] != 1 } {
   puts "\n\nERROR: The PGP3 link speed (INCLUDE_PGP3_10G or INCLUDE_PGP3_6G or INCLUDE_PGP3_3G) is not defined in $::env(PROJ_DIR)/Makefile\n\n"; exit -1
}

if { [info exists ::env(INCLUDE_PGP3_10G)] != 1 || $::env(INCLUDE_PGP3_10G) == 0 } {
   set nop 0
} else {

   loadConstraints -path "$::DIR_PATH/xdc/EpixHrComm10G.xdc"
}

if { [info exists ::env(INCLUDE_PGP3_6G)] != 1 || $::env(INCLUDE_PGP3_6G) == 0 } {
   set nop 0
} else {

   loadConstraints -path "$::DIR_PATH/xdc/EpixHrComm6G.xdc"
}

if { [info exists ::env(INCLUDE_PGP3_3G)] != 1 || $::env(INCLUDE_PGP3_3G) == 0 } {
   set nop 0
} else {

   loadConstraints -path "$::DIR_PATH/xdc/EpixHrComm3G.xdc"
}
