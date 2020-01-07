# Load RUCKUS library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Check for version 2017.2 of Vivado (or later)
if { [VersionCheck 2017.2] < 0 } {exit -1}

# Check for submodule tagging
if { [info exists ::env(OVERRIDE_SUBMODULE_LOCKS)] != 1 || $::env(OVERRIDE_SUBMODULE_LOCKS) == 0 } {
   if { [SubmoduleCheck {ruckus} {2.0.3} ] < 0 } {exit -1}
   if { [SubmoduleCheck {surf}   {2.0.2} ] < 0 } {exit -1}
} else {
   puts "\n\n*********************************************************"
   puts "OVERRIDE_SUBMODULE_LOCKS != 0"
   puts "Ignoring the submodule locks in epix-hr-core/ruckus.tcl"
   puts "*********************************************************\n\n"
}

# Check if required variables exist
if { [info exists ::env(COMM_TYPE)] != 1 } {
   puts "\n\nERROR: COMM_TYPE is not defined in $::env(PROJ_DIR)/Makefile\n\n"; exit -1
}

if { [info exists ::env(COMMON_NAME)] != 1 } {
   puts "\n\nERROR: COMMON_NAME is not defined in $::env(PROJ_DIR)/Makefile\n\n"; exit -1
}

if { [info exists ::env(BUILD_MIG_CORE)] != 1 } {
   puts "\n\nERROR: BUILD_MIG_CORE is not defined in $::env(PROJ_DIR)/Makefile\n\n"; exit -1
}

if { [info exists ::env(BUILD_MB_CORE)] != 1 } {
   puts "\n\nERROR: BUILD_MB_CORE is not defined in $::env(PROJ_DIR)/Makefile\n\n"; exit -1
}

if { [info exists ::env(PROM_FSBL)] != 1 } {
   puts "\n\nERROR: PROM_FSBL is not defined in $::env(PROJ_DIR)/Makefile\n\n"; exit -1
}

# Load ruckus files
loadRuckusTcl "$::DIR_PATH/core"
loadRuckusTcl "$::DIR_PATH/comm"
loadRuckusTcl "$::DIR_PATH/ddr"

# Place and Route strategies 
set_property strategy Performance_Explore [get_runs impl_1]
