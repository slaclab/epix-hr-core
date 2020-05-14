# Load RUCKUS library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code
loadSource -lib epix_hr_core -dir "$::DIR_PATH/rtl"

# IP cores
loadSource   -path "$::DIR_PATH/ip/SysMonCore.dcp"
# loadIpCore -path "$::DIR_PATH/ip/SysMonCore.xci"

# Load Constraints
if { $::env(PRJ_PART) == "XCKU035-SFVA784-1-C" } { 

   loadConstraints -dir "$::DIR_PATH/xdc/epix-hr"
    
} elseif { $::env(PRJ_PART) == "XCKU040-FFVA1156-2-E" } {

   loadConstraints -dir "$::DIR_PATH/xdc/kcu105"
    
}
