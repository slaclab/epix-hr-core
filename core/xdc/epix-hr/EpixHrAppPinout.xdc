##############################################################################
## This file is part of 'ePix HR Camera Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'ePix HR Camera Firmware', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

#######################
## Application Ports ##
#######################

# System Ports

set_property -dict {PACKAGE_PIN AD20 IOSTANDARD LVCMOS33} [get_ports digPwrEn]
set_property -dict {PACKAGE_PIN AE20 IOSTANDARD LVCMOS33} [get_ports anaPwrEn]
set_property -dict {PACKAGE_PIN AC18 IOSTANDARD LVCMOS33} [get_ports syncDigDcDc]
set_property -dict {PACKAGE_PIN AD18 IOSTANDARD LVCMOS33} [get_ports syncAnaDcDc]

set_property -dict {PACKAGE_PIN AE16 IOSTANDARD LVCMOS33} [get_ports {syncDcDc[0]}]
set_property -dict {PACKAGE_PIN AD16 IOSTANDARD LVCMOS33} [get_ports {syncDcDc[1]}]
set_property -dict {PACKAGE_PIN AD19 IOSTANDARD LVCMOS33} [get_ports {syncDcDc[2]}]
set_property -dict {PACKAGE_PIN AC19 IOSTANDARD LVCMOS33} [get_ports {syncDcDc[3]}]
set_property -dict {PACKAGE_PIN AD21 IOSTANDARD LVCMOS33} [get_ports {syncDcDc[4]}]
set_property -dict {PACKAGE_PIN AC21 IOSTANDARD LVCMOS33} [get_ports {syncDcDc[5]}]
set_property -dict {PACKAGE_PIN AC16 IOSTANDARD LVCMOS33} [get_ports {syncDcDc[6]}]

#set_property -dict { PACKAGE_PIN AG17 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
#set_property -dict { PACKAGE_PIN AG20 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
#set_property -dict { PACKAGE_PIN AG19 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
#set_property -dict { PACKAGE_PIN AH19 IOSTANDARD LVCMOS33} [get_ports {led[3]}]

set_property -dict {PACKAGE_PIN AA18 IOSTANDARD LVCMOS33} [get_ports daqTg]
set_property -dict {PACKAGE_PIN AA17 IOSTANDARD LVCMOS33} [get_ports connTgOut]
set_property -dict {PACKAGE_PIN AB17 IOSTANDARD LVCMOS33} [get_ports connMps]
set_property -dict {PACKAGE_PIN Y16  IOSTANDARD LVCMOS33} [get_ports connRun]

# Fast ADC Ports

set_property -dict {PACKAGE_PIN Y26 IOSTANDARD LVCMOS18} [get_ports adcSpiClk]
set_property -dict {PACKAGE_PIN Y27 IOSTANDARD LVCMOS18} [get_ports adcSpiData]
set_property -dict {PACKAGE_PIN Y28 IOSTANDARD LVCMOS18} [get_ports adcSpiCsL]
set_property -dict {PACKAGE_PIN W28 IOSTANDARD LVCMOS18} [get_ports adcPdwn]

set_property -dict {PACKAGE_PIN W25 IOSTANDARD LVDS} [get_ports adcClkP]
set_property -dict {PACKAGE_PIN Y25 IOSTANDARD LVDS} [get_ports adcClkM]

set_property -dict {PACKAGE_PIN AB26 IOSTANDARD LVDS} [get_ports adcDoClkP]
set_property -dict {PACKAGE_PIN AC26 IOSTANDARD LVDS} [get_ports adcDoClkM]
set_property -dict {DIFF_TERM TRUE} [get_ports adcDoClkP]

set_property -dict {PACKAGE_PIN AB24 IOSTANDARD LVDS} [get_ports adcFrameClkP]
set_property -dict {PACKAGE_PIN AB25 IOSTANDARD LVDS} [get_ports adcFrameClkM]
set_property -dict {DIFF_TERM TRUE} [get_ports adcFrameClkP]

set_property -dict {PACKAGE_PIN AE25 IOSTANDARD LVDS} [get_ports {adcMonDoutP[0]}]
set_property -dict {PACKAGE_PIN AE26 IOSTANDARD LVDS} [get_ports {adcMonDoutN[0]}]
set_property -dict {DIFF_TERM TRUE} [get_ports adcMonDoutP[0]]

set_property -dict {PACKAGE_PIN AG26 IOSTANDARD LVDS} [get_ports {adcMonDoutP[1]}]
set_property -dict {PACKAGE_PIN AH26 IOSTANDARD LVDS} [get_ports {adcMonDoutN[1]}]
set_property -dict {DIFF_TERM TRUE} [get_ports adcMonDoutP[1]]

set_property -dict {PACKAGE_PIN AE27 IOSTANDARD LVDS} [get_ports {adcMonDoutP[2]}]
set_property -dict {PACKAGE_PIN AF27 IOSTANDARD LVDS} [get_ports {adcMonDoutN[2]}]
set_property -dict {DIFF_TERM TRUE} [get_ports adcMonDoutP[2]]

set_property -dict {PACKAGE_PIN AC24 IOSTANDARD LVDS} [get_ports {adcMonDoutP[3]}]
set_property -dict {PACKAGE_PIN AD24 IOSTANDARD LVDS} [get_ports {adcMonDoutN[3]}]
set_property -dict {DIFF_TERM TRUE} [get_ports adcMonDoutP[3]]

set_property -dict {PACKAGE_PIN AB27 IOSTANDARD LVCMOS18} [get_ports {adcMonDoutP[4]}]
set_property -dict {PACKAGE_PIN AC27 IOSTANDARD LVCMOS18} [get_ports {adcMonDoutN[4]}]
#set_property -dict {DIFF_TERM TRUE} [get_ports adcMonDoutP[4]]

# Slow ADC Ports

set_property -dict {PACKAGE_PIN AH24 IOSTANDARD LVCMOS33} [get_ports slowAdcSclk]
set_property -dict {PACKAGE_PIN AH23 IOSTANDARD LVCMOS33} [get_ports slowAdcDin]
set_property -dict {PACKAGE_PIN AF23 IOSTANDARD LVCMOS33} [get_ports slowAdcCsL]
set_property -dict {PACKAGE_PIN AG22 IOSTANDARD LVCMOS33} [get_ports slowAdcRefClk]
set_property -dict {PACKAGE_PIN AF22 IOSTANDARD LVCMOS33} [get_ports slowAdcDout]
set_property -dict {PACKAGE_PIN AG24 IOSTANDARD LVCMOS33} [get_ports slowAdcDrdy]
set_property -dict {PACKAGE_PIN AG21 IOSTANDARD LVCMOS33} [get_ports slowAdcSync]

# Slow DAC Ports

set_property -dict {PACKAGE_PIN AB14 IOSTANDARD LVCMOS25} [get_ports {sDacCsL[0]}]
set_property -dict {PACKAGE_PIN AA14 IOSTANDARD LVCMOS25} [get_ports {sDacCsL[1]}]
set_property -dict {PACKAGE_PIN AC14 IOSTANDARD LVCMOS25} [get_ports {sDacCsL[2]}]
set_property -dict {PACKAGE_PIN AB15 IOSTANDARD LVCMOS25} [get_ports {sDacCsL[3]}]
set_property -dict {PACKAGE_PIN AG10 IOSTANDARD LVCMOS25} [get_ports {sDacCsL[4]}] 

set_property -dict {PACKAGE_PIN AH9  IOSTANDARD LVCMOS25} [get_ports hsDacCsL]
set_property -dict {PACKAGE_PIN AG9  IOSTANDARD LVCMOS25} [get_ports hsDacLoad]

set_property -dict {PACKAGE_PIN AH11 IOSTANDARD LVCMOS25} [get_ports dacClrL]
set_property -dict {PACKAGE_PIN AG11 IOSTANDARD LVCMOS25} [get_ports dacSck]
set_property -dict {PACKAGE_PIN AH8  IOSTANDARD LVCMOS25} [get_ports dacDin]

# # GTH Ports

# set_property PACKAGE_PIN R4  [get_ports {smaTxP}]
# set_property PACKAGE_PIN R3  [get_ports {smaTxN}]
# set_property PACKAGE_PIN P2  [get_ports {smaRxP}]
# set_property PACKAGE_PIN P1  [get_ports {smaRxN}]

# set_property PACKAGE_PIN AA4 [get_ports {gtTxP}]
# set_property PACKAGE_PIN AA3 [get_ports {gtTxN}]
# set_property PACKAGE_PIN Y2  [get_ports {gtRxP}]
# set_property PACKAGE_PIN Y1  [get_ports {gtRxN}]

# set_property PACKAGE_PIN V6  [get_ports {gtRefP}]
# set_property PACKAGE_PIN V5  [get_ports {gtRefN}]

