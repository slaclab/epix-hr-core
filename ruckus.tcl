# Load RUCKUS library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

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
# loadIpCore -path "$::DIR_PATH/ip/SysMonCore.xci"

loadSource -path "$::DIR_PATH/ip/EpixHrPgp2bGthCore.dcp"
# loadIpCore -path "$::DIR_PATH/ip/EpixHrPgp2bGthCore.xci"

# Load Constraints
loadConstraints -path "$::DIR_PATH/core/EpixHrCore.xdc" 
loadConstraints -path "$::DIR_PATH/core/EpixHrAppPinout.xdc" 

# Check if building MIG Core
if { $::env(BUILD_MIG_CORE)  != 0 } {
   # Load Source Code and Constraints
   loadSource      -path "$::DIR_PATH/ddr/EpixHrDdrMem.vhd"
   loadConstraints -path "$::DIR_PATH/ddr/EpixHrDdrMem.xdc" 
   # Check for no Application Microblaze build (MIG core only)
   if { $::env(BUILD_MB_CORE)  == 0 } {

      # Add the pre-built .DCP file 
      loadSource -path "$::DIR_PATH/ip/MigCore.dcp"
      
      ## Add the Microblaze Calibration Code
      add_files -norecurse $::DIR_PATH/ip/MigCoreMicroblazeCalibration.elf
      set_property SCOPED_TO_REF   {MigCore}                                                  [get_files -all -of_objects [get_fileset sources_1] {MigCoreMicroblazeCalibration.elf}]
      set_property SCOPED_TO_CELLS {inst/u_ddr4_mem_intfc/u_ddr_cal_riu/mcs0/U0/microblaze_I} [get_files -all -of_objects [get_fileset sources_1] {MigCoreMicroblazeCalibration.elf}]

      ## Add the Microblaze block memory mapping
      add_files -norecurse $::DIR_PATH/ip/MigCoreMicroblazeCalibration.bmm
      set_property SCOPED_TO_REF   {MigCore}                                     [get_files -all -of_objects [get_fileset sources_1] {MigCoreMicroblazeCalibration.bmm}]
      set_property SCOPED_TO_CELLS {inst/u_ddr4_mem_intfc/u_ddr_cal_riu/mcs0/U0} [get_files -all -of_objects [get_fileset sources_1] {MigCoreMicroblazeCalibration.bmm}]
      
   } else {
      # Add the IP core
      loadIpCore -path "$::DIR_PATH/ip/MigCore.xci"
   }
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
