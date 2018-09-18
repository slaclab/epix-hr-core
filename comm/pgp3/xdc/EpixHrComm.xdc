##############################################################################
## This file is part of 'ePix HR Camera Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'ePix HR Camera Firmware', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

create_clock -name pgp3PhyRxClk0 -period 3.200 [get_pins {U_Core/U_Comm/PGP_LANE[0].HW_GEN.U_PGP/U_Pgp3GthUsIpWrapper_1/GEN_10G.U_Pgp3GthUsIp/inst/gen_gtwizard_gthe3_top.Pgp3GthUsIp10G_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[2].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[0].GTHE3_CHANNEL_PRIM_INST/RXOUTCLK}]
create_clock -name pgp3PhyRxClk1 -period 3.200 [get_pins {U_Core/U_Comm/PGP_LANE[1].HW_GEN.U_PGP/U_Pgp3GthUsIpWrapper_1/GEN_10G.U_Pgp3GthUsIp/inst/gen_gtwizard_gthe3_top.Pgp3GthUsIp10G_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[2].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[0].GTHE3_CHANNEL_PRIM_INST/RXOUTCLK}]
create_clock -name pgp3PhyRxClk2 -period 3.200 [get_pins {U_Core/U_Comm/PGP_LANE[2].HW_GEN.U_PGP/U_Pgp3GthUsIpWrapper_1/GEN_10G.U_Pgp3GthUsIp/inst/gen_gtwizard_gthe3_top.Pgp3GthUsIp10G_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[2].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[0].GTHE3_CHANNEL_PRIM_INST/RXOUTCLK}]
create_clock -name pgp3PhyRxClk3 -period 3.200 [get_pins {U_Core/U_Comm/PGP_LANE[3].HW_GEN.U_PGP/U_Pgp3GthUsIpWrapper_1/GEN_10G.U_Pgp3GthUsIp/inst/gen_gtwizard_gthe3_top.Pgp3GthUsIp10G_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[2].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[0].GTHE3_CHANNEL_PRIM_INST/RXOUTCLK}]

create_clock -name pgp3PhyTxClk0 -period 3.200 [get_pins {U_Core/U_Comm/PGP_LANE[0].HW_GEN.U_PGP/U_Pgp3GthUsIpWrapper_1/GEN_10G.U_Pgp3GthUsIp/inst/gen_gtwizard_gthe3_top.Pgp3GthUsIp10G_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[2].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[0].GTHE3_CHANNEL_PRIM_INST/TXOUTCLK}]
create_clock -name pgp3PhyTxClk1 -period 3.200 [get_pins {U_Core/U_Comm/PGP_LANE[1].HW_GEN.U_PGP/U_Pgp3GthUsIpWrapper_1/GEN_10G.U_Pgp3GthUsIp/inst/gen_gtwizard_gthe3_top.Pgp3GthUsIp10G_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[2].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[0].GTHE3_CHANNEL_PRIM_INST/TXOUTCLK}]
create_clock -name pgp3PhyTxClk2 -period 3.200 [get_pins {U_Core/U_Comm/PGP_LANE[2].HW_GEN.U_PGP/U_Pgp3GthUsIpWrapper_1/GEN_10G.U_Pgp3GthUsIp/inst/gen_gtwizard_gthe3_top.Pgp3GthUsIp10G_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[2].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[0].GTHE3_CHANNEL_PRIM_INST/TXOUTCLK}]
create_clock -name pgp3PhyTxClk3 -period 3.200 [get_pins {U_Core/U_Comm/PGP_LANE[3].HW_GEN.U_PGP/U_Pgp3GthUsIpWrapper_1/GEN_10G.U_Pgp3GthUsIp/inst/gen_gtwizard_gthe3_top.Pgp3GthUsIp10G_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_channel_container[2].gen_enabled_channel.gthe3_channel_wrapper_inst/channel_inst/gthe3_channel_gen.gen_gthe3_channel_inst[0].GTHE3_CHANNEL_PRIM_INST/TXOUTCLK}]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {pgp3PhyRxClk0}] -group [get_clocks -include_generated_clocks {pgp3PhyTxClk0}] -group [get_clocks -include_generated_clocks {qsfpClkP}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {pgp3PhyRxClk1}] -group [get_clocks -include_generated_clocks {pgp3PhyTxClk1}] -group [get_clocks -include_generated_clocks {qsfpClkP}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {pgp3PhyRxClk2}] -group [get_clocks -include_generated_clocks {pgp3PhyTxClk2}] -group [get_clocks -include_generated_clocks {qsfpClkP}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {pgp3PhyRxClk3}] -group [get_clocks -include_generated_clocks {pgp3PhyTxClk3}] -group [get_clocks -include_generated_clocks {qsfpClkP}]
