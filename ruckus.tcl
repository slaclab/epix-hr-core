# Load RUCKUS library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Check for version 2017.2 of Vivado (or later)
if { [VersionCheck 2017.2] < 0 } {exit -1}

# Check if required variables exist
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

# Load Source Code
loadSource -path "$::DIR_PATH/core/EpixHrCorePkg.vhd"
loadSource -path "$::DIR_PATH/core/EpixHrCore.vhd"
loadSource -path "$::DIR_PATH/core/EpixHrSysMon.vhd"
loadSource -dir  "$::DIR_PATH/comm/"

loadSource -path "$::DIR_PATH/ip/SysMonCore.dcp"
#loadIpCore -path "$::DIR_PATH/ip/SysMonCore.xci"

# Load Constraints
if { $::env(PRJ_PART) == "XCKU040-FFVA1156-2-E" } {

    loadSource -path "$::DIR_PATH/ip_eval/EpixHrPgp2bGthCore.dcp"
    #loadSource -path "$::DIR_PATH/../surf/protocols/pgp/pgp2b/gthUltraScale/ip/PgpGthCore.dcp"
    #loadIpCore -path "$::DIR_PATH/ip/EpixHrPgp2bGthCore.xci"
    loadConstraints -path "$::DIR_PATH/core/EpixHrCoreEval.xdc" 
    loadConstraints -path "$::DIR_PATH/core/EpixHrAppPinoutEval.xdc" 

} elseif { $::env(PRJ_PART) == "XCKU035-SFVA784-1-C" } { 

    loadSource -path "$::DIR_PATH/ip/EpixHrPgp2bGthCore.dcp"
    #loadIpCore -path "$::DIR_PATH/ip/EpixHrPgp2bGthCore.xci"
    loadConstraints -path "$::DIR_PATH/core/EpixHrCore.xdc" 
    loadConstraints -path "$::DIR_PATH/core/EpixHrAppPinout.xdc" 

} else { 

   puts "\n\nERROR: PRJ_PART was not defined as 'XCKU040-FFVA1156-2-E' or 'XCKU035-SFVA784-1-C' in the Makefile\n\n"; exit -1

}

# Check if building MIG Core
if { $::env(BUILD_MIG_CORE)  != 0 } {
   # Load Source Code and Constraints
   loadSource      -path "$::DIR_PATH/ddr/EpixHrDdrMem.vhd"
   loadConstraints -path "$::DIR_PATH/ddr/EpixHrDdrMem.xdc" 
   # Add the IP core
   loadIpCore -path "$::DIR_PATH/ip/MigCore.xci"   
} else {
   # Load Source Code and Constraints
   loadSource      -path "$::DIR_PATH/ddr/EpixHrDdrMemBypass.vhd"
   loadConstraints -path "$::DIR_PATH/ddr/EpixHrDdrMemBypass.xdc" 
}

# Check if building not building Microblaze Core
if { $::env(BUILD_MB_CORE)  == 0 } {
   # Remove the surf MB core
   remove_files  [get_files {MicroblazeBasicCore.bd}]
   remove_files  [get_files {MicroblazeBasicCoreWrapper.vhd}]
   # Add dummy source code
   loadSource -path "$::DIR_PATH/core/MicroblazeBasicCoreBypass.vhd"
}

## Place and Route strategies 
set_property strategy Performance_Explore [get_runs impl_1]
set_property STEPS.OPT_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]

## Skip the utilization check during placement
set_param place.skipUtilizationCheck 1
