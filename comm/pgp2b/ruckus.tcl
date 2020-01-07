# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code and Constraints
loadSource -lib epix_hr_core -dir "$::DIR_PATH/rtl"
loadConstraints -dir "$::DIR_PATH/xdc"

# Load Constraints
if { $::env(PRJ_PART) == "XCKU035-SFVA784-1-C" } { 

   loadSource      -path "$::DIR_PATH/ip/epix-hr/EpixHrPgp2bGthCore.dcp"
   # loadIpCore    -path "$::DIR_PATH/ip/epix-hr/EpixHrPgp2bGthCore.xci"
    
} elseif { $::env(PRJ_PART) == "XCKU040-FFVA1156-2-E" } {

   loadSource      -path "$::DIR_PATH/ip/kcu105/EpixHrPgp2bGthCore.dcp"
   # loadIpCore    -path "$::DIR_PATH/ip/kcu105/EpixHrPgp2bGthCore.xci"
    
}
