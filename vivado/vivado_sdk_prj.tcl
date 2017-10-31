##############################################################################
## This file is part of 'EPIX HR Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'EPIX HR Firmware', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

# Project SDK Run Script

#############################
## Get build system variables 
#############################
source $::env(RUCKUS_DIR)/vivado_env_var.tcl
set EmptyApp "Empty Application"
exec rm -rf ${SDK_PRJ}

# Check if project already exists
if { [file exists ${SDK_PRJ}] != 1 } {
   # Make the project for Vivado 2016.1 (or later) ....  Refer to AR#66629
   exec mkdir ${SDK_PRJ}
   exec cp -f ${OUT_DIR}/${VIVADO_PROJECT}.runs/impl_1/${PROJECT}.hwdef ${SDK_PRJ}/${PROJECT}.hdf
   sdk setws ${SDK_PRJ}
   sdk createhw  -name hw_0  -hwspec ${SDK_PRJ}/${PROJECT}.hdf   
   sdk createbsp -name bsp_0 -proc U_Core_U_CPU_U_Microblaze_microblaze_0 -hwproject hw_0 -os standalone
   sdk createapp -name app_0 -app ${EmptyApp} -proc U_Core_U_CPU_U_Microblaze_microblaze_0 -hwproject hw_0 -bsp bsp_0 -os standalone -lang c++
   exec rm -f ${SDK_PRJ}/app_0/src/main.cc
   # Configure the debug build
   sdk configapp -app app_0 build-config debug
   sdk configapp -app  app_0 -set compiler-optimization {Optimize for size (-Os)}
   foreach sdkLib ${SDK_LIB} {
      sdk configapp -app app_0 -add include-path ${sdkLib}
   }        
   # Configure the release build
   sdk configapp -app app_0 build-config release
   sdk configapp -app  app_0 -set compiler-optimization {Optimize for size (-Os)}
   foreach sdkLib ${SDK_LIB} {
      set dirName  [file tail ${sdkLib}]
      set softLink ${SDK_PRJ}/app_0/${dirName}
    exec ls -lath 
      exec ln -s ${sdkLib} ${softLink}
      sdk configapp -app app_0 -add include-path ${sdkLib}
   }
}

# Create a soft-link and add new linker to source tree
if { [file exists ${SDK_PRJ}/app_0/src/lscript.ld] == 1 } {
   exec cp -f ${SDK_PRJ}/app_0/src/lscript.ld ${SDK_PRJ}/app_0/lscript.ld
}
exec rm -rf ${SDK_PRJ}/app_0/src
exec ln -s $::env(SDK_SRC_PATH) ${SDK_PRJ}/app_0/src
if { [file exists ${SDK_PRJ}/app_0/lscript.ld] == 1 } {
   exec mv -f ${SDK_PRJ}/app_0/lscript.ld ${SDK_PRJ}/app_0/src/lscript.ld
}
