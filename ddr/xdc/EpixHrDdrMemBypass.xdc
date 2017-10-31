##############################################################################
## This file is part of 'LCLS2 AMC Carrier Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'LCLS2 AMC Carrier Firmware', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property IOSTANDARD LVCMOS12 [get_ports ddrClkP]
set_property IOSTANDARD LVCMOS12 [get_ports ddrClkN]
set_property IOSTANDARD LVCMOS12 [get_ports ddrBg]
set_property IOSTANDARD LVCMOS12 [get_ports ddrCkP]
set_property IOSTANDARD LVCMOS12 [get_ports ddrCkN]
set_property IOSTANDARD LVCMOS12 [get_ports ddrCke]
set_property IOSTANDARD LVCMOS12 [get_ports ddrCsL]
set_property IOSTANDARD LVCMOS12 [get_ports ddrOdt]
set_property IOSTANDARD LVCMOS12 [get_ports ddrAct]
set_property IOSTANDARD LVCMOS12 [get_ports ddrRstL]
set_property IOSTANDARD LVCMOS12 [get_ports {ddrA[*]}]
set_property IOSTANDARD LVCMOS12 [get_ports {ddrBa[*]}]
set_property IOSTANDARD LVCMOS12 [get_ports {ddrDm[*]}]
set_property IOSTANDARD LVCMOS12 [get_ports {ddrDq[*]}]
set_property IOSTANDARD LVCMOS12 [get_ports {{ddrDqsP[*]} {ddrDqsN[*]}}]
