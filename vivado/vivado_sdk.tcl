##############################################################################
## This file is part of 'EPIX HR Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'EPIX HR Firmware', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

# Get variables and Custom Procedures
source -quiet $::env(RUCKUS_DIR)/vivado_env_var.tcl
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl
      
if { $::env(PRJ_PART) == "XCKU035-SFVA784-1-C" } { 

   # Check if building not building Microblaze Core
   if { $::env(BUILD_MIG_CORE)  == 0 } {
      # Use the ruckus SDK project TCL script
      set PrjTclPath   ${RUCKUS_DIR}
   } else {
      # Use the custom SDK project TCL script
      set PrjTclPath   ${TOP_DIR}/submodules/epix-hr-core/vivado
   }  
       
} elseif { $::env(PRJ_PART) == "XCKU040-FFVA1156-2-E" } {

   # Use the ruckus SDK project TCL script
   set PrjTclPath   ${RUCKUS_DIR}
    
}    

puts "PrjTclPath: ${PrjTclPath}"

# Generate SDK project
set SDK_PRJ_RDY false
set SDK_RETRY_CNT 0
while { ${SDK_PRJ_RDY} != true } {
   set src_rc [catch {exec xsdk -batch -source ${PrjTclPath}/vivado_sdk_prj.tcl >@stdout}]
   if {$src_rc} {
      puts "\n********************************************************"
      puts "Retrying to build SDK project"
      puts ${_RESULT}
      puts "********************************************************\n"
      # Increment the counter
      incr SDK_RETRY_CNT
      # Check for max retries
      if { ${SDK_RETRY_CNT} == 10 } {
         puts "Failed to build the SDK project"
         exit -1
         # break
      }
   } else {
      set SDK_PRJ_RDY true
   }
}

# Generate .ELF
set src_rc [catch {exec xsdk -batch -source ${RUCKUS_DIR}/vivado_sdk_elf.tcl >@stdout}]    

# Generate .ELF
exec xsdk -batch -source ${RUCKUS_DIR}/vivado_sdk_elf.tcl >@stdout

# Add .ELF to the .bit file properties
add_files -norecurse ${SDK_ELF}  
set_property SCOPED_TO_REF MicroblazeBasicCore [get_files -all -of_objects [get_fileset sources_1] ${SDK_ELF}]
set_property SCOPED_TO_CELLS { microblaze_0 }  [get_files -all -of_objects [get_fileset sources_1] ${SDK_ELF}]

# Rebuild the .bit file with the .ELF file include
reset_run impl_1 -prev_step
launch_runs -to_step write_bitstream impl_1 >@stdout
set src_rc [catch { 
   wait_on_run impl_1 
} _RESULT]  

# Copy over .bit w/ .ELF file to image directory
exec cp -f ${IMPL_DIR}/${PROJECT}.bit ${IMAGES_DIR}/$::env(IMAGENAME).bit
exec gzip -c -f -9 ${IMPL_DIR}/${PROJECT}.bit > ${IMAGES_DIR}/$::env(IMAGENAME).bit.gz
