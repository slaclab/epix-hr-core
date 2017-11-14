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
## Common Core Ports ##
#######################

# Board IDs

#set_property -dict { PACKAGE_PIN H6 IOSTANDARD LVCMOS18 } [get_ports {snIoAdcCard}]
#set_property -dict { PACKAGE_PIN H6 IOSTANDARD LVCMOS18 } [get_ports {snIoCarrier}]

# QSFP Ports

set_property PACKAGE_PIN T2 [get_ports {qsfpRxP[0]}]
set_property PACKAGE_PIN T1 [get_ports {qsfpRxN[0]}]
set_property PACKAGE_PIN U4 [get_ports {qsfpTxP[0]}]
set_property PACKAGE_PIN U3 [get_ports {qsfpTxN[0]}]
set_property PACKAGE_PIN W4 [get_ports {qsfpTxP[1]}]
set_property PACKAGE_PIN W3 [get_ports {qsfpTxN[1]}]
set_property PACKAGE_PIN V2 [get_ports {qsfpRxP[1]}]
set_property PACKAGE_PIN V1 [get_ports {qsfpRxN[1]}]

#set_property PACKAGE_PIN R4 [get_ports {qsfpTxP[2]}]
#set_property PACKAGE_PIN R3 [get_ports {qsfpTxN[2]}]
#set_property PACKAGE_PIN P2 [get_ports {qsfpRxP[2]}]
#set_property PACKAGE_PIN P1 [get_ports {qsfpRxN[2]}]
#set_property PACKAGE_PIN AA4 [get_ports {qsfpTxP[3]}]
#set_property PACKAGE_PIN AA3 [get_ports {qsfpTxN[3]}]
#set_property PACKAGE_PIN Y2 [get_ports {qsfpRxP[3]}]
#set_property PACKAGE_PIN Y1 [get_ports {qsfpRxN[3]}]

set_property PACKAGE_PIN P5 [get_ports qsfpClkN]
set_property PACKAGE_PIN P6 [get_ports qsfpClkP]

set_property -dict {PACKAGE_PIN D13 IOSTANDARD LVCMOS18} [get_ports qsfpLpMode]
set_property -dict {PACKAGE_PIN C13 IOSTANDARD LVCMOS18} [get_ports qsfpModSel]
#set_property -dict { PACKAGE_PIN K6 IOSTANDARD LVCMOS18 } [get_ports {qsfpInitL}]
#set_property -dict { PACKAGE_PIN K5 IOSTANDARD LVCMOS18 } [get_ports {qsfpRstL}]
set_property -dict {PACKAGE_PIN G9 IOSTANDARD LVCMOS18} [get_ports qsfpPrstL]
set_property -dict {PACKAGE_PIN F9 IOSTANDARD LVCMOS18} [get_ports qsfpScl]
set_property -dict {PACKAGE_PIN L13 IOSTANDARD LVCMOS18} [get_ports qsfpSda]

# DDR Ports

set_property -dict {PACKAGE_PIN M25 IOSTANDARD LVCMOS18} [get_ports ddrClkP]
set_property -dict {PACKAGE_PIN M26 IOSTANDARD LVCMOS18} [get_ports ddrClkN]

set_property PACKAGE_PIN AG15 [get_ports ddrBg]
set_property PACKAGE_PIN AE16 [get_ports ddrCkP]
set_property PACKAGE_PIN AE15 [get_ports ddrCkN]
set_property PACKAGE_PIN AD15 [get_ports ddrCke]
set_property PACKAGE_PIN AL19 [get_ports ddrCsL]
set_property PACKAGE_PIN AJ18 [get_ports ddrOdt]
set_property PACKAGE_PIN AH14 [get_ports ddrAct]
set_property PACKAGE_PIN AL18 [get_ports ddrRstL]

set_property PACKAGE_PIN AE17 [get_ports {ddrA[0]}]
set_property PACKAGE_PIN AH17 [get_ports {ddrA[1]}]
set_property PACKAGE_PIN AE18 [get_ports {ddrA[2]}]
set_property PACKAGE_PIN AJ15 [get_ports {ddrA[3]}]
set_property PACKAGE_PIN AG16 [get_ports {ddrA[4]}]
set_property PACKAGE_PIN AL17 [get_ports {ddrA[5]}]
set_property PACKAGE_PIN AK18 [get_ports {ddrA[6]}]
set_property PACKAGE_PIN AG17 [get_ports {ddrA[7]}]
set_property PACKAGE_PIN AF18 [get_ports {ddrA[8]}]
set_property PACKAGE_PIN AH19 [get_ports {ddrA[9]}]
set_property PACKAGE_PIN AF15 [get_ports {ddrA[10]}]
set_property PACKAGE_PIN AD19 [get_ports {ddrA[11]}]
set_property PACKAGE_PIN AJ14 [get_ports {ddrA[12]}]
set_property PACKAGE_PIN AG19 [get_ports {ddrA[13]}]
set_property PACKAGE_PIN AD16 [get_ports {ddrA[14]}]
set_property PACKAGE_PIN AG14 [get_ports {ddrA[15]}]
set_property PACKAGE_PIN AF14 [get_ports {ddrA[16]}]

set_property PACKAGE_PIN AF17 [get_ports {ddrBa[0]}]
set_property PACKAGE_PIN AL15 [get_ports {ddrBa[1]}]

set_property PACKAGE_PIN AD21 [get_ports {ddrDm[0]}]
set_property PACKAGE_PIN AE25 [get_ports {ddrDm[1]}]
set_property PACKAGE_PIN AJ21 [get_ports {ddrDm[2]}]
set_property PACKAGE_PIN AM21 [get_ports {ddrDm[3]}]

set_property PACKAGE_PIN AE23 [get_ports {ddrDq[0]}]
set_property PACKAGE_PIN AG20 [get_ports {ddrDq[1]}]
set_property PACKAGE_PIN AF22 [get_ports {ddrDq[2]}]
set_property PACKAGE_PIN AF20 [get_ports {ddrDq[3]}]
set_property PACKAGE_PIN AE22 [get_ports {ddrDq[4]}]
set_property PACKAGE_PIN AD20 [get_ports {ddrDq[5]}]
set_property PACKAGE_PIN AG22 [get_ports {ddrDq[6]}]
set_property PACKAGE_PIN AE20 [get_ports {ddrDq[7]}]
set_property PACKAGE_PIN AJ24 [get_ports {ddrDq[8]}]
set_property PACKAGE_PIN AG24 [get_ports {ddrDq[9]}]
set_property PACKAGE_PIN AJ23 [get_ports {ddrDq[10]}]
set_property PACKAGE_PIN AF23 [get_ports {ddrDq[11]}]
set_property PACKAGE_PIN AH23 [get_ports {ddrDq[12]}]
set_property PACKAGE_PIN AF24 [get_ports {ddrDq[13]}]
set_property PACKAGE_PIN AH22 [get_ports {ddrDq[14]}]
set_property PACKAGE_PIN AG25 [get_ports {ddrDq[15]}]
set_property PACKAGE_PIN AL22 [get_ports {ddrDq[16]}]
set_property PACKAGE_PIN AL25 [get_ports {ddrDq[17]}]
set_property PACKAGE_PIN AM20 [get_ports {ddrDq[18]}]
set_property PACKAGE_PIN AK23 [get_ports {ddrDq[19]}]
set_property PACKAGE_PIN AK22 [get_ports {ddrDq[20]}]
set_property PACKAGE_PIN AL24 [get_ports {ddrDq[21]}]
set_property PACKAGE_PIN AL20 [get_ports {ddrDq[22]}]
set_property PACKAGE_PIN AL23 [get_ports {ddrDq[23]}]
set_property PACKAGE_PIN AM24 [get_ports {ddrDq[24]}]
set_property PACKAGE_PIN AN23 [get_ports {ddrDq[25]}]
set_property PACKAGE_PIN AN24 [get_ports {ddrDq[26]}]
set_property PACKAGE_PIN AP23 [get_ports {ddrDq[27]}]
set_property PACKAGE_PIN AP25 [get_ports {ddrDq[28]}]
set_property PACKAGE_PIN AN22 [get_ports {ddrDq[29]}]
set_property PACKAGE_PIN AP24 [get_ports {ddrDq[30]}]
set_property PACKAGE_PIN AM22 [get_ports {ddrDq[31]}]

set_property PACKAGE_PIN AG21 [get_ports {ddrDqsP[0]}]
set_property PACKAGE_PIN AH21 [get_ports {ddrDqsN[0]}]
set_property PACKAGE_PIN AH24 [get_ports {ddrDqsP[1]}]
set_property PACKAGE_PIN AJ25 [get_ports {ddrDqsN[1]}]
set_property PACKAGE_PIN AJ20 [get_ports {ddrDqsP[2]}]
set_property PACKAGE_PIN AK20 [get_ports {ddrDqsN[2]}]
set_property PACKAGE_PIN AP20 [get_ports {ddrDqsP[3]}]
set_property PACKAGE_PIN AP21 [get_ports {ddrDqsN[3]}]

set_property -dict {PACKAGE_PIN L8 IOSTANDARD LVCMOS18} [get_ports ddrPg]
set_property -dict {PACKAGE_PIN K8 IOSTANDARD LVCMOS18} [get_ports ddrPwrEn]

set_property IOSTANDARD LVCMOS18 [get_ports ddrClkP]
set_property IOSTANDARD LVCMOS18 [get_ports ddrClkN]
set_property IOSTANDARD LVCMOS18 [get_ports ddrBg]
set_property IOSTANDARD LVCMOS18 [get_ports ddrCkP]
set_property IOSTANDARD LVCMOS18 [get_ports ddrCkN]
set_property IOSTANDARD LVCMOS18 [get_ports ddrCke]
set_property IOSTANDARD LVCMOS18 [get_ports ddrCsL]
set_property IOSTANDARD LVCMOS18 [get_ports ddrOdt]
set_property IOSTANDARD LVCMOS18 [get_ports ddrAct]
set_property IOSTANDARD LVCMOS18 [get_ports ddrRstL]
set_property IOSTANDARD LVCMOS18 [get_ports {ddrA[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {ddrBa[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {ddrDm[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {ddrDq[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {{ddrDqsP[*]} {ddrDqsN[*]}}]

##########################
## Timing Constraints   ##
##########################

create_clock -period 6.400 -name qsfpClkP [get_ports qsfpClkP]
create_clock -period 6.400 -name ddrClkP [get_ports ddrClkP]
create_generated_clock -name sysClk [get_pins {U_Core/U_Mmcm/PllGen.U_Pll/CLKOUT0}]
create_generated_clock -name dnaClk [get_pins {U_Core/U_Version/GEN_DEVICE_DNA.DeviceDna_1/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O}]

set_clock_groups -asynchronous -group [get_clocks {sysClk}] -group [get_clocks {dnaClk}]
set_clock_groups -asynchronous -group [get_clocks {sysClk}] -group [get_clocks {byteClk}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks qsfpClkP] -group [get_clocks -include_generated_clocks ddrClkP]

##########################
## Misc. Configurations ##
##########################

set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR Yes [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 1 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE No [current_design]

set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

