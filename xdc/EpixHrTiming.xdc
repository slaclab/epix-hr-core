##############################################################################
## This file is part of 'LCLS2 AMC Carrier Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'LCLS2 AMC Carrier Firmware', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

create_clock -name qsfpClkP -period 6.400 [get_ports {qsfpClkP}]
create_clock -name ddrClkP  -period 6.400 [get_ports {ddrClkP}]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {qsfpClkP}] -group [get_clocks -include_generated_clocks {ddrClkP}]
