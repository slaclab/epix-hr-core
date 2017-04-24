##############################################################################
## This file is part of 'LCLS2 AMC Carrier Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'LCLS2 AMC Carrier Firmware', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

#######################
## Application Ports ##
#######################

# System Ports

set_property -dict { PACKAGE_PIN AD20 IOSTANDARD LVCMOS33 } [get_ports {digPwrEn}]
set_property -dict { PACKAGE_PIN AE20 IOSTANDARD LVCMOS33 } [get_ports {anaPwrEn}]
set_property -dict { PACKAGE_PIN AC18 IOSTANDARD LVCMOS33 } [get_ports {syncDigDcDc}]
set_property -dict { PACKAGE_PIN AD18 IOSTANDARD LVCMOS33 } [get_ports {syncAnaDcDc}]

set_property -dict { PACKAGE_PIN AE16 IOSTANDARD LVCMOS33 } [get_ports {syncDcDc[0]}]
set_property -dict { PACKAGE_PIN AD16 IOSTANDARD LVCMOS33 } [get_ports {syncDcDc[1]}]
set_property -dict { PACKAGE_PIN AD19 IOSTANDARD LVCMOS33 } [get_ports {syncDcDc[2]}]
set_property -dict { PACKAGE_PIN AC19 IOSTANDARD LVCMOS33 } [get_ports {syncDcDc[3]}]
set_property -dict { PACKAGE_PIN AD21 IOSTANDARD LVCMOS33 } [get_ports {syncDcDc[4]}]
set_property -dict { PACKAGE_PIN AC21 IOSTANDARD LVCMOS33 } [get_ports {syncDcDc[5]}]
set_property -dict { PACKAGE_PIN AC16 IOSTANDARD LVCMOS33 } [get_ports {syncDcDc[6]}]

set_property -dict { PACKAGE_PIN AG17 IOSTANDARD LVCMOS33 } [get_ports {led[0]}]
set_property -dict { PACKAGE_PIN AG20 IOSTANDARD LVCMOS33 } [get_ports {led[1]}]
set_property -dict { PACKAGE_PIN AG19 IOSTANDARD LVCMOS33 } [get_ports {led[2]}]
set_property -dict { PACKAGE_PIN AH19 IOSTANDARD LVCMOS33 } [get_ports {led[3]}]

set_property -dict { PACKAGE_PIN AA18 IOSTANDARD LVCMOS33 } [get_ports {daqTg}]
set_property -dict { PACKAGE_PIN AA17 IOSTANDARD LVCMOS33 } [get_ports {connTgOut}]
set_property -dict { PACKAGE_PIN AB17 IOSTANDARD LVCMOS33 } [get_ports {connMps}]
set_property -dict { PACKAGE_PIN Y16  IOSTANDARD LVCMOS33 } [get_ports {connRun}]

# Fast ADC Ports

set_property -dict { PACKAGE_PIN Y26 IOSTANDARD LVCMOS18 } [get_ports {adcSpiClk}]
set_property -dict { PACKAGE_PIN Y27 IOSTANDARD LVCMOS18 } [get_ports {adcSpiData}]
set_property -dict { PACKAGE_PIN Y28 IOSTANDARD LVCMOS18 } [get_ports {adcSpiCsL}]
set_property -dict { PACKAGE_PIN W28 IOSTANDARD LVCMOS18 } [get_ports {adcPdwn}]

set_property -dict { PACKAGE_PIN W25 IOSTANDARD LVDS } [get_ports {adcClkP}]
set_property -dict { PACKAGE_PIN Y25 IOSTANDARD LVDS } [get_ports {adcClkM}]

set_property -dict { PACKAGE_PIN AB26 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {adcDoClkP}]
set_property -dict { PACKAGE_PIN AC26 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {adcDoClkM}]

set_property -dict { PACKAGE_PIN AB24 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {adcFrameClkP}]
set_property -dict { PACKAGE_PIN AB25 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {adcFrameClkM}]

set_property -dict { PACKAGE_PIN AE25 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {adcMonDoutP[0]}]
set_property -dict { PACKAGE_PIN AE26 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {adcMonDoutN[0]}]
set_property -dict { PACKAGE_PIN AF25 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {adcMonDoutP[1]}]
set_property -dict { PACKAGE_PIN AG25 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {adcMonDoutN[1]}]
set_property -dict { PACKAGE_PIN AG26 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {adcMonDoutP[2]}]
set_property -dict { PACKAGE_PIN AH26 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {adcMonDoutN[2]}]
set_property -dict { PACKAGE_PIN AG27 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {adcMonDoutP[3]}]
set_property -dict { PACKAGE_PIN AH27 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {adcMonDoutN[3]}]
set_property -dict { PACKAGE_PIN AE27 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {adcMonDoutP[4]}]
set_property -dict { PACKAGE_PIN AF27 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {adcMonDoutN[4]}]

# Slow ADC Ports

set_property -dict { PACKAGE_PIN AH24 IOSTANDARD LVCMOS33 } [get_ports {slowAdcSclk}]
set_property -dict { PACKAGE_PIN AH23 IOSTANDARD LVCMOS33 } [get_ports {slowAdcDin}]
set_property -dict { PACKAGE_PIN AF23 IOSTANDARD LVCMOS33 } [get_ports {slowAdcCsL}]
set_property -dict { PACKAGE_PIN AG22 IOSTANDARD LVCMOS33 } [get_ports {slowAdcRefClk}]
set_property -dict { PACKAGE_PIN AF22 IOSTANDARD LVCMOS33 } [get_ports {slowAdcDout}]
set_property -dict { PACKAGE_PIN AG24 IOSTANDARD LVCMOS33 } [get_ports {slowAdcDrdy}]
set_property -dict { PACKAGE_PIN AG21 IOSTANDARD LVCMOS33 } [get_ports {slowAdcSync}]

# Slow DAC Ports

set_property -dict { PACKAGE_PIN AB14 IOSTANDARD LVCMOS25 } [get_ports {sDacCsL[0]}]
set_property -dict { PACKAGE_PIN AA14 IOSTANDARD LVCMOS25 } [get_ports {sDacCsL[1]}]
set_property -dict { PACKAGE_PIN AC14 IOSTANDARD LVCMOS25 } [get_ports {sDacCsL[2]}]
set_property -dict { PACKAGE_PIN AB15 IOSTANDARD LVCMOS25 } [get_ports {sDacCsL[3]}]

set_property -dict { PACKAGE_PIN AH9  IOSTANDARD LVCMOS25 } [get_ports {hsDacCsL}]
set_property -dict { PACKAGE_PIN AG10 IOSTANDARD LVCMOS25 } [get_ports {hsDacEn}]
set_property -dict { PACKAGE_PIN AG9  IOSTANDARD LVCMOS25 } [get_ports {hsDacLoad}]
set_property -dict { PACKAGE_PIN AH11 IOSTANDARD LVCMOS25 } [get_ports {hsDacClrL}]

set_property -dict { PACKAGE_PIN AG11 IOSTANDARD LVCMOS25 } [get_ports {dacSck}]
set_property -dict { PACKAGE_PIN AH8  IOSTANDARD LVCMOS25 } [get_ports {dacDin}]


# ASIC Gbps Ports

set_property -dict { PACKAGE_PIN V22 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataP[0]}]
set_property -dict { PACKAGE_PIN V23 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataN[0]}]
set_property -dict { PACKAGE_PIN V20 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataP[1]}]
set_property -dict { PACKAGE_PIN V21 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataN[1]}]
set_property -dict { PACKAGE_PIN U21 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataP[2]}]
set_property -dict { PACKAGE_PIN U22 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataN[2]}]
set_property -dict { PACKAGE_PIN U20 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataP[3]}]
set_property -dict { PACKAGE_PIN T20 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataN[3]}]
set_property -dict { PACKAGE_PIN T22 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataP[4]}]
set_property -dict { PACKAGE_PIN T23 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataN[4]}]
set_property -dict { PACKAGE_PIN R21 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataP[5]}]
set_property -dict { PACKAGE_PIN R22 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataN[5]}]
set_property -dict { PACKAGE_PIN V27 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataP[6]}]
set_property -dict { PACKAGE_PIN V28 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataN[6]}]
set_property -dict { PACKAGE_PIN U25 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataP[7]}]
set_property -dict { PACKAGE_PIN U26 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataN[7]}]
set_property -dict { PACKAGE_PIN T27 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataP[8]}]
set_property -dict { PACKAGE_PIN T28 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataN[8]}]
set_property -dict { PACKAGE_PIN R27 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataP[9]}]
set_property -dict { PACKAGE_PIN R28 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataN[9]}]
set_property -dict { PACKAGE_PIN R25 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataP[10]}]
set_property -dict { PACKAGE_PIN R26 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataN[10]}]
set_property -dict { PACKAGE_PIN T24 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataP[11]}]
set_property -dict { PACKAGE_PIN T25 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataN[11]}]
set_property -dict { PACKAGE_PIN L23 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataP[12]}]
set_property -dict { PACKAGE_PIN L24 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataN[12]}]
set_property -dict { PACKAGE_PIN K20 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataP[13]}]
set_property -dict { PACKAGE_PIN K21 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataN[13]}]
set_property -dict { PACKAGE_PIN L22 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataP[14]}]
set_property -dict { PACKAGE_PIN K22 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataN[14]}]
set_property -dict { PACKAGE_PIN K23 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataP[15]}]
set_property -dict { PACKAGE_PIN J24 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataN[15]}]
set_property -dict { PACKAGE_PIN J23 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataP[16]}]
set_property -dict { PACKAGE_PIN H23 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataN[16]}]
set_property -dict { PACKAGE_PIN H24 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataP[17]}]
set_property -dict { PACKAGE_PIN G24 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataN[17]}]
set_property -dict { PACKAGE_PIN L25 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataP[18]}]
set_property -dict { PACKAGE_PIN K25 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataN[18]}]
set_property -dict { PACKAGE_PIN K27 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataP[19]}]
set_property -dict { PACKAGE_PIN K28 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataN[19]}]
set_property -dict { PACKAGE_PIN K26 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataP[20]}]
set_property -dict { PACKAGE_PIN J26 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataN[20]}]
set_property -dict { PACKAGE_PIN H27 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataP[21]}]
set_property -dict { PACKAGE_PIN H28 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataN[21]}]
set_property -dict { PACKAGE_PIN J25 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataP[22]}]
set_property -dict { PACKAGE_PIN H26 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataN[22]}]
set_property -dict { PACKAGE_PIN G25 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataP[23]}]
set_property -dict { PACKAGE_PIN G26 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {asicDataN[23]}]

# ASIC Control Ports

set_property -dict { PACKAGE_PIN AH14 IOSTANDARD LVCMOS25 } [get_ports {asicR0}]
set_property -dict { PACKAGE_PIN AF14 IOSTANDARD LVCMOS25 } [get_ports {asicPPmat}]
set_property -dict { PACKAGE_PIN AF12 IOSTANDARD LVCMOS25 } [get_ports {asicGlblRst}]
set_property -dict { PACKAGE_PIN AG15 IOSTANDARD LVCMOS25 } [get_ports {asicSync}]
set_property -dict { PACKAGE_PIN AG14 IOSTANDARD LVCMOS25 } [get_ports {asicAcq}]

set_property -dict { PACKAGE_PIN AE11 IOSTANDARD LVDS_25 } [get_ports {asicRoClkP[0]}]
set_property -dict { PACKAGE_PIN AE10 IOSTANDARD LVDS_25 } [get_ports {asicRoClkN[0]}]
set_property -dict { PACKAGE_PIN AF10 IOSTANDARD LVDS_25 } [get_ports {asicRoClkP[1]}]
set_property -dict { PACKAGE_PIN AF9  IOSTANDARD LVDS_25 } [get_ports {asicRoClkN[1]}]
set_property -dict { PACKAGE_PIN AC13 IOSTANDARD LVDS_25 } [get_ports {asicRoClkP[2]}]
set_property -dict { PACKAGE_PIN AC12 IOSTANDARD LVDS_25 } [get_ports {asicRoClkN[2]}]
set_property -dict { PACKAGE_PIN AD14 IOSTANDARD LVDS_25 } [get_ports {asicRoClkP[3]}]
set_property -dict { PACKAGE_PIN AD13 IOSTANDARD LVDS_25 } [get_ports {asicRoClkN[3]}]

# SACI Ports

set_property -dict { PACKAGE_PIN AE15 IOSTANDARD LVCMOS25 } [get_ports {asicSaciCmd}]
set_property -dict { PACKAGE_PIN AF15 IOSTANDARD LVCMOS25 } [get_ports {asicSaciClk}]
set_property -dict { PACKAGE_PIN AH12 IOSTANDARD LVCMOS25 } [get_ports {asicSaciSel[0]}]
set_property -dict { PACKAGE_PIN AG12 IOSTANDARD LVCMOS25 } [get_ports {asicSaciSel[1]}]
set_property -dict { PACKAGE_PIN AE12 IOSTANDARD LVCMOS25 } [get_ports {asicSaciSel[2]}]
set_property -dict { PACKAGE_PIN AE13 IOSTANDARD LVCMOS25 } [get_ports {asicSaciSel[3]}]
set_property -dict { PACKAGE_PIN AH13 IOSTANDARD LVCMOS25 } [get_ports {asicSaciRsp}]

# Spare Ports

set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {spareHpP[0]}]
set_property -dict { PACKAGE_PIN H18 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {spareHpN[0]}]
set_property -dict { PACKAGE_PIN H19 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {spareHpP[1]}]
set_property -dict { PACKAGE_PIN G19 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {spareHpN[1]}]
set_property -dict { PACKAGE_PIN G16 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {spareHpP[2]}]
set_property -dict { PACKAGE_PIN G17 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {spareHpN[2]}]
set_property -dict { PACKAGE_PIN F18 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {spareHpP[3]}]
set_property -dict { PACKAGE_PIN F19 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {spareHpN[3]}]
set_property -dict { PACKAGE_PIN F17 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {spareHpP[4]}]
set_property -dict { PACKAGE_PIN E18 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {spareHpN[4]}]
set_property -dict { PACKAGE_PIN E16 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {spareHpP[5]}]
set_property -dict { PACKAGE_PIN E17 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {spareHpN[5]}]
set_property -dict { PACKAGE_PIN C16 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {spareHpP[6]}]
set_property -dict { PACKAGE_PIN C17 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {spareHpN[6]}]
set_property -dict { PACKAGE_PIN B16 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {spareHpP[7]}]
set_property -dict { PACKAGE_PIN B17 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {spareHpN[7]}]
set_property -dict { PACKAGE_PIN A17 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {spareHpP[8]}]
set_property -dict { PACKAGE_PIN A18 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {spareHpN[8]}]
set_property -dict { PACKAGE_PIN B19 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {spareHpP[9]}]
set_property -dict { PACKAGE_PIN A19 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {spareHpN[9]}]
set_property -dict { PACKAGE_PIN D18 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {spareHpP[10]}]
set_property -dict { PACKAGE_PIN D19 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {spareHpN[10]}]
set_property -dict { PACKAGE_PIN C18 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {spareHpP[11]}]
set_property -dict { PACKAGE_PIN C19 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {spareHpN[11]}]

set_property -dict { PACKAGE_PIN AB10 IOSTANDARD LVDS_25 DIFF_TERM_ADV TERM_100 } [get_ports {spareHrP[0]}]
set_property -dict { PACKAGE_PIN AB9  IOSTANDARD LVDS_25 DIFF_TERM_ADV TERM_100 } [get_ports {spareHrN[0]}]
set_property -dict { PACKAGE_PIN AC9  IOSTANDARD LVDS_25 DIFF_TERM_ADV TERM_100 } [get_ports {spareHrP[1]}]
set_property -dict { PACKAGE_PIN AD9  IOSTANDARD LVDS_25 DIFF_TERM_ADV TERM_100 } [get_ports {spareHrN[1]}]
set_property -dict { PACKAGE_PIN AD11 IOSTANDARD LVDS_25 DIFF_TERM_ADV TERM_100 } [get_ports {spareHrP[2]}]
set_property -dict { PACKAGE_PIN AD10 IOSTANDARD LVDS_25 DIFF_TERM_ADV TERM_100 } [get_ports {spareHrN[2]}]
set_property -dict { PACKAGE_PIN Y13  IOSTANDARD LVDS_25 DIFF_TERM_ADV TERM_100 } [get_ports {spareHrP[3]}]
set_property -dict { PACKAGE_PIN AA13 IOSTANDARD LVDS_25 DIFF_TERM_ADV TERM_100 } [get_ports {spareHrN[3]}]
set_property -dict { PACKAGE_PIN AA12 IOSTANDARD LVDS_25 DIFF_TERM_ADV TERM_100 } [get_ports {spareHrP[4]}]
set_property -dict { PACKAGE_PIN AB12 IOSTANDARD LVDS_25 DIFF_TERM_ADV TERM_100 } [get_ports {spareHrN[4]}]
set_property -dict { PACKAGE_PIN Y12  IOSTANDARD LVDS_25 DIFF_TERM_ADV TERM_100 } [get_ports {spareHrP[5]}]
set_property -dict { PACKAGE_PIN Y11  IOSTANDARD LVDS_25 DIFF_TERM_ADV TERM_100 } [get_ports {spareHrN[5]}]

# GTH Ports

set_property PACKAGE_PIN R4  [get_ports {smaTxP}]
set_property PACKAGE_PIN R3  [get_ports {smaTxN}]
set_property PACKAGE_PIN P2  [get_ports {smaRxP}]
set_property PACKAGE_PIN P1  [get_ports {smaRxN}]

set_property PACKAGE_PIN AA4 [get_ports {gtTxP}]
set_property PACKAGE_PIN AA3 [get_ports {gtTxN}]
set_property PACKAGE_PIN Y2  [get_ports {gtRxP}]
set_property PACKAGE_PIN Y1  [get_ports {gtRxN}]

set_property PACKAGE_PIN V6  [get_ports {gtRefP}]
set_property PACKAGE_PIN V5  [get_ports {gtRefN}]
