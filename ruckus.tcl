# Load RUCKUS library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load Source Code
loadSource -dir "$::DIR_PATH/rtl/"

loadSource -path "$::DIR_PATH/ip/SysMonCore.dcp"
# loadIpCore -path "$::DIR_PATH/ip/SysMonCore.xci"

loadSource -path "$::DIR_PATH/ip/MigCore.dcp"
# loadIpCore -path "$::DIR_PATH/ip/MigCore.xci"

# Load Constraints
loadConstraints -path "$::DIR_PATH/xdc/EpixHrCorePinout.xdc" 
loadConstraints -path "$::DIR_PATH/xdc/EpixHrAppPinout.xdc" 
loadConstraints -path "$::DIR_PATH/xdc/EpixHrTiming.xdc" 

# Check for Application Microblaze build
if { [expr [info exists ::env(SDK_SRC_PATH)]] == 0 } {
   ## Add the Microblaze Calibration Code
   add_files $::DIR_PATH/ip/MigCoreMicroblazeCalibration.elf
   set_property SCOPED_TO_REF   {MigCore} [get_files MigCoreMicroblazeCalibration.elf]
   set_property SCOPED_TO_CELLS {inst/u_ddr3_mem_intfc/u_ddr_cal_riu/mcs0/microblaze_I} [get_files MigCoreMicroblazeCalibration.elf]

   add_files $::DIR_PATH/ip/MigCoreMicroblazeCalibration.bmm
   set_property SCOPED_TO_REF   {MigCore} [get_files MigCoreMicroblazeCalibration.bmm]
   set_property SCOPED_TO_CELLS {inst/u_ddr3_mem_intfc/u_ddr_cal_riu/mcs0} [get_files MigCoreMicroblazeCalibration.bmm]
}

## Place and Route strategies 
set_property strategy Performance_Explore [get_runs impl_1]
set_property STEPS.OPT_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]

## Skip the utilization check during placement
set_param place.skipUtilizationCheck 1
