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

set_property -dict {PACKAGE_PIN AB16 IOSTANDARD LVCMOS33} [get_ports snIoAdcCard]
set_property -dict {PACKAGE_PIN AF13 IOSTANDARD LVCMOS25} [get_ports snIoCarrier]

# QSFP Ports

set_property PACKAGE_PIN AH2 [get_ports {qsfpRxP[0]}]
set_property PACKAGE_PIN AH1 [get_ports {qsfpRxN[0]}]
set_property PACKAGE_PIN AG4 [get_ports {qsfpTxP[0]}]
set_property PACKAGE_PIN AG3 [get_ports {qsfpTxN[0]}]
set_property PACKAGE_PIN AF2 [get_ports {qsfpRxP[1]}]
set_property PACKAGE_PIN AF1 [get_ports {qsfpRxN[1]}]
set_property PACKAGE_PIN AF6 [get_ports {qsfpTxP[1]}]
set_property PACKAGE_PIN AF5 [get_ports {qsfpTxN[1]}]
set_property PACKAGE_PIN AD2 [get_ports {qsfpRxP[2]}]
set_property PACKAGE_PIN AD1 [get_ports {qsfpRxN[2]}]
set_property PACKAGE_PIN AE4 [get_ports {qsfpTxP[2]}]
set_property PACKAGE_PIN AE3 [get_ports {qsfpTxN[2]}]
set_property PACKAGE_PIN AB2 [get_ports {qsfpRxP[3]}]
set_property PACKAGE_PIN AB1 [get_ports {qsfpRxN[3]}]
set_property PACKAGE_PIN AC4 [get_ports {qsfpTxP[3]}]
set_property PACKAGE_PIN AC3 [get_ports {qsfpTxN[3]}]

set_property PACKAGE_PIN Y5 [get_ports qsfpClkN]
set_property PACKAGE_PIN Y6 [get_ports qsfpClkP]

set_property -dict {PACKAGE_PIN AG16 IOSTANDARD LVCMOS33} [get_ports qsfpLpMode]
set_property -dict {PACKAGE_PIN AH16 IOSTANDARD LVCMOS33} [get_ports qsfpModSel]
set_property -dict {PACKAGE_PIN AD23 IOSTANDARD LVCMOS33} [get_ports qsfpInitL]
set_property -dict {PACKAGE_PIN AE23 IOSTANDARD LVCMOS33} [get_ports qsfpRstL]
set_property -dict {PACKAGE_PIN AE21 IOSTANDARD LVCMOS33} [get_ports qsfpPrstL]
set_property -dict {PACKAGE_PIN AE22 IOSTANDARD LVCMOS33} [get_ports qsfpScl]
set_property -dict {PACKAGE_PIN AF24 IOSTANDARD LVCMOS33} [get_ports qsfpSda]

# DDR Ports

set_property PACKAGE_PIN D3 [get_ports ddrClkP]
set_property PACKAGE_PIN C3 [get_ports ddrClkN]

set_property PACKAGE_PIN C4 [get_ports ddrBg]
set_property PACKAGE_PIN H3 [get_ports ddrCke]
set_property PACKAGE_PIN H4 [get_ports ddrCsL]
set_property PACKAGE_PIN H2 [get_ports ddrOdt]
set_property PACKAGE_PIN G2 [get_ports ddrAct]
set_property PACKAGE_PIN F2 [get_ports ddrRstL]

set_property PACKAGE_PIN E5 [get_ports {ddrA[0]}]
set_property PACKAGE_PIN D5 [get_ports {ddrA[1]}]
set_property PACKAGE_PIN D6 [get_ports {ddrA[2]}]
set_property PACKAGE_PIN C6 [get_ports {ddrA[3]}]
set_property PACKAGE_PIN C7 [get_ports {ddrA[4]}]
set_property PACKAGE_PIN B7 [get_ports {ddrA[5]}]
set_property PACKAGE_PIN A8 [get_ports {ddrA[6]}]
set_property PACKAGE_PIN A7 [get_ports {ddrA[7]}]
set_property PACKAGE_PIN D8 [get_ports {ddrA[8]}]
set_property PACKAGE_PIN C8 [get_ports {ddrA[9]}]
set_property PACKAGE_PIN C1 [get_ports {ddrA[10]}]
set_property PACKAGE_PIN B1 [get_ports {ddrA[11]}]
set_property PACKAGE_PIN A2 [get_ports {ddrA[12]}]
set_property PACKAGE_PIN A1 [get_ports {ddrA[13]}]
set_property PACKAGE_PIN C2 [get_ports {ddrA[14]}]
set_property PACKAGE_PIN B2 [get_ports {ddrA[15]}]
set_property PACKAGE_PIN B4 [get_ports {ddrA[16]}]

set_property PACKAGE_PIN A4 [get_ports {ddrBa[0]}]
set_property PACKAGE_PIN D4 [get_ports {ddrBa[1]}]

set_property PACKAGE_PIN H13 [get_ports {ddrDm[0]}]
set_property PACKAGE_PIN J15 [get_ports {ddrDm[1]}]
set_property PACKAGE_PIN D14 [get_ports {ddrDm[2]}]
set_property PACKAGE_PIN E11 [get_ports {ddrDm[3]}]

set_property PACKAGE_PIN J11 [get_ports {ddrDq[0]}]
set_property PACKAGE_PIN J10 [get_ports {ddrDq[1]}]
set_property PACKAGE_PIN H11 [get_ports {ddrDq[2]}]
set_property PACKAGE_PIN G11 [get_ports {ddrDq[3]}]
set_property PACKAGE_PIN G10 [get_ports {ddrDq[4]}]
set_property PACKAGE_PIN G9 [get_ports {ddrDq[5]}]
set_property PACKAGE_PIN F10 [get_ports {ddrDq[6]}]
set_property PACKAGE_PIN F9 [get_ports {ddrDq[7]}]
set_property PACKAGE_PIN H16 [get_ports {ddrDq[8]}]
set_property PACKAGE_PIN G15 [get_ports {ddrDq[9]}]
set_property PACKAGE_PIN H14 [get_ports {ddrDq[10]}]
set_property PACKAGE_PIN G14 [get_ports {ddrDq[11]}]
set_property PACKAGE_PIN E13 [get_ports {ddrDq[12]}]
set_property PACKAGE_PIN E12 [get_ports {ddrDq[13]}]
set_property PACKAGE_PIN F13 [get_ports {ddrDq[14]}]
set_property PACKAGE_PIN F12 [get_ports {ddrDq[15]}]
set_property PACKAGE_PIN C14 [get_ports {ddrDq[16]}]
set_property PACKAGE_PIN C13 [get_ports {ddrDq[17]}]
set_property PACKAGE_PIN E15 [get_ports {ddrDq[18]}]
set_property PACKAGE_PIN D15 [get_ports {ddrDq[19]}]
set_property PACKAGE_PIN A13 [get_ports {ddrDq[20]}]
set_property PACKAGE_PIN A12 [get_ports {ddrDq[21]}]
set_property PACKAGE_PIN A15 [get_ports {ddrDq[22]}]
set_property PACKAGE_PIN A14 [get_ports {ddrDq[23]}]
set_property PACKAGE_PIN D11 [get_ports {ddrDq[24]}]
set_property PACKAGE_PIN D10 [get_ports {ddrDq[25]}]
set_property PACKAGE_PIN D9 [get_ports {ddrDq[26]}]
set_property PACKAGE_PIN C9 [get_ports {ddrDq[27]}]
set_property PACKAGE_PIN B9 [get_ports {ddrDq[28]}]
set_property PACKAGE_PIN A9 [get_ports {ddrDq[29]}]
set_property PACKAGE_PIN B10 [get_ports {ddrDq[30]}]
set_property PACKAGE_PIN A10 [get_ports {ddrDq[31]}]


set_property -dict {PACKAGE_PIN AB11 IOSTANDARD LVCMOS25} [get_ports ddrPg]
set_property -dict {PACKAGE_PIN AC11 IOSTANDARD LVCMOS25} [get_ports ddrPwrEn]

##########################
## Timing Constraints   ##
##########################

create_clock -period 6.400 -name qsfpClkP [get_ports qsfpClkP]
create_clock -period 6.400 -name ddrClkP [get_ports ddrClkP]
create_clock -period 2.857 -name adcMonDoClkP [get_ports adcDoClkP]

create_generated_clock -name sysClk [get_pins U_Core/U_Mmcm/PllGen.U_Pll/CLKOUT0]
create_generated_clock -name dnaClk [get_pins U_Core/U_Version/GEN_DEVICE_DNA.DeviceDna_1/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O]

set_clock_groups -asynchronous -group [get_clocks sysClk] -group [get_clocks dnaClk]
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

set_property PACKAGE_PIN B6 [get_ports ddrCkP]
set_property PACKAGE_PIN B5 [get_ports ddrCkN]
set_property PACKAGE_PIN C12 [get_ports {ddrDqsP[3]}]
set_property PACKAGE_PIN C11 [get_ports {ddrDqsN[3]}]
set_property PACKAGE_PIN B15 [get_ports {ddrDqsP[2]}]
set_property PACKAGE_PIN B14 [get_ports {ddrDqsN[2]}]
set_property PACKAGE_PIN F15 [get_ports {ddrDqsP[1]}]
set_property PACKAGE_PIN F14 [get_ports {ddrDqsN[1]}]
set_property PACKAGE_PIN J9 [get_ports {ddrDqsP[0]}]
set_property PACKAGE_PIN H9 [get_ports {ddrDqsN[0]}]
