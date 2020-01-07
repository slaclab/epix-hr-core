# Load RUCKUS library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

if { $::env(PRJ_PART) == "XCKU035-SFVA784-1-C" } { 

   # Check if building MIG Core
   if { $::env(BUILD_MIG_CORE)  != 0 } {
      # Load Source Code and Constraints
      loadSource -lib epix_hr_core -path "$::DIR_PATH/rtl/EpixHrDdrMem.vhd"
      loadConstraints              -path "$::DIR_PATH/xdc/EpixHrDdrMem.xdc" 
      # Add the IP core
      loadIpCore -path "$::DIR_PATH/ip/MigCore.xci"   
   } else {
      # Load Source Code and Constraints
      loadSource -lib epix_hr_core -path "$::DIR_PATH/rtl/EpixHrDdrMemBypass.vhd"
      loadConstraints              -path "$::DIR_PATH/xdc/EpixHrDdrMemBypass.xdc" 
   }
    
} elseif { $::env(PRJ_PART) == "XCKU040-FFVA1156-2-E" } {

   # Load Source Code
   loadSource -lib epix_hr_core -path "$::DIR_PATH/rtl/EpixHrDdrMemBypass.vhd"
    
}




