##############################################################################
## This file is part of 'EPIX HR Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'EPIX HR Firmware', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

# PROM Configurations
set format     "mcs"
set inteface   "SPIx1"
set size       "1024"

# BIT file locations
set FSBL_BIT   "0x00000000"
set APP_BIT    "0x02000000"
set SPARE0_BIT "0x04000000"
set SPARE1_BIT "0x06000000"

# File Paths
set BIT_PATH   "$::env(IMPL_DIR)/$::env(PROJECT).bit"

# Check if FSBL
if { $::env(PROM_FSBL)  != 0 } {
   set loadbit "up ${FSBL_BIT} ${BIT_PATH}"
} else {
   set loadbit "up ${APP_BIT}  ${BIT_PATH}"
}
