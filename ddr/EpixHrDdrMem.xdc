##############################################################################
## This file is part of 'LCLS2 AMC Carrier Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'LCLS2 AMC Carrier Firmware', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property IOSTANDARD    DIFF_SSTL12 [get_ports {ddrClkP ddrClkN}]
set_property IBUF_LOW_PWR  FALSE       [get_ports {ddrClkP ddrClkN}]
set_property PULLTYPE      KEEPER      [get_ports {ddrClkP ddrClkN}]

set_property -dict { IOSTANDARD SSTL12_DCI SLEW FAST }      [get_ports {ddrBg}] 
set_property -dict { IOSTANDARD DIFF_SSTL12_DCI SLEW FAST } [get_ports {ddrCkP}] 
set_property -dict { IOSTANDARD DIFF_SSTL12_DCI SLEW FAST } [get_ports {ddrCkN}] 
set_property -dict { IOSTANDARD SSTL12_DCI SLEW FAST }      [get_ports {ddrCke}] 
set_property -dict { IOSTANDARD SSTL12_DCI SLEW FAST }      [get_ports {ddrCsL}] 
set_property -dict { IOSTANDARD SSTL12_DCI SLEW FAST }      [get_ports {ddrOdt}] 
set_property -dict { IOSTANDARD SSTL12_DCI SLEW FAST }      [get_ports {ddrAct}] 
set_property -dict { IOSTANDARD SSTL12 OUTPUT_IMPEDANCE RDRV_48_48 SLEW SLOW } [get_ports {ddrRstL}]

set_property IOSTANDARD SSTL12_DCI       [get_ports {ddrA[*]}]
set_property SLEW FAST                   [get_ports {ddrA[*]}]
set_property OUTPUT_IMPEDANCE RDRV_40_40 [get_ports {ddrA[*]}]

set_property IOSTANDARD SSTL12_DCI       [get_ports {ddrBa[*]}]
set_property SLEW FAST                   [get_ports {ddrBa[*]}]
set_property OUTPUT_IMPEDANCE RDRV_40_40 [get_ports {ddrBa[*]}]

set_property IOSTANDARD POD12_DCI        [get_ports {ddrDm[*]}]
set_property SLEW FAST                   [get_ports {ddrDm[*]}]
set_property OUTPUT_IMPEDANCE RDRV_40_40 [get_ports {ddrDm[*]}]

set_property IOSTANDARD POD12_DCI        [get_ports {ddrDq[*]}]
set_property SLEW       FAST             [get_ports {ddrDq[*]}]
set_property OUTPUT_IMPEDANCE RDRV_40_40 [get_ports {ddrDq[*]}]

set_property IOSTANDARD DIFF_POD12_DCI   [get_ports {ddrDqsP[*] ddrDqsN[*]}]
set_property SLEW       FAST             [get_ports {ddrDqsP[*] ddrDqsN[*]}]
set_property OUTPUT_IMPEDANCE RDRV_40_40 [get_ports {ddrDqsP[*] ddrDqsN[*]}]
