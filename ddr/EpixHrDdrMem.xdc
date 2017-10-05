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






## copied from lz project


set_multicycle_path -setup 8 -from [get_pins U_Core/U_DdrMem/inst/u_ddr4_mem_intfc/u_ddr_cal_top/calDone*/C]
set_multicycle_path -end -hold 7 -from [get_pins U_Core/U_DdrMem/inst/u_ddr4_mem_intfc/u_ddr_cal_top/calDone*/C]


## These signals once asserted, stays asserted for multiple clock cycles.

## False path constraint is added to improve the HOLD timing.

set_false_path -hold -to [get_pins U_Core/U_DdrMem/inst/u_ddr4_mem_intfc/u_mig_ddr4_phy/inst/generate_block1.u_ddr_xiphy/byte_num[*].xiphy_byte_wrapper.u_xiphy_byte_wrapper/I_CONTROL[*].GEN_I_CONTROL.u_xiphy_control/xiphy_control/RIU_ADDR*]
set_false_path -hold -to [get_pins U_Core/U_DdrMem/inst/u_ddr4_mem_intfc/u_mig_ddr4_phy/inst/generate_block1.u_ddr_xiphy/byte_num[*].xiphy_byte_wrapper.u_xiphy_byte_wrapper/I_CONTROL[*].GEN_I_CONTROL.u_xiphy_control/xiphy_control/RIU_WR_DATA*]
#set_false_path -hold -to [get_pins */*/*/*/*/*.u_xiphy_control/xiphy_control/RIU_ADDR*]
#set_false_path -hold -to [get_pins */*/*/*/*/*.u_xiphy_control/xiphy_control/RIU_WR_DATA*]


set_property SLEW FAST  [get_ports {ddrDq[*] ddrDqsP[*] ddrDqsN[*]}]
set_property SLEW FAST  [get_ports {ddrA[*] ddrAct ddrBa[*] ddrBg[*] ddrCke[*] ddrCkP[*] ddrCkN[*] ddrOdt[*]}]
set_property IBUF_LOW_PWR FALSE  [get_ports {ddrDq[*] ddrDqsP[*] ddrDqsN[*]}]
set_property ODT RTT_40  [get_ports {ddrDq[*] ddrDqsP[*] ddrDqsN[*]}]
##set_property EQUALIZATION EQ_LEVEL2 [get_ports {c0_ddr4_dq[*] c0_ddr4_dqs_t[*] c0_ddr4_dqs_c[*]}]
##set_property PRE_EMPHASIS RDRV_240 [get_ports {c0_ddr4_dq[*] c0_ddr4_dqs_t[*] c0_ddr4_dqs_c[*]}]
set_property SLEW FAST  [get_ports {ddrCsL[*]}]
set_property DATA_RATE SDR  [get_ports {ddrCsL[*]}]

set_property SLEW FAST  [get_ports {ddrDm[*]}]
set_property IBUF_LOW_PWR FALSE  [get_ports {ddrDm[*]}]
set_property ODT RTT_40  [get_ports {ddrDm[*]}]
##set_property EQUALIZATION EQ_LEVEL2 [get_ports {c0_ddr4_dm_dbi_n[*]}]
##set_property PRE_EMPHASIS RDRV_240 [get_ports {c0_ddr4_dm_dbi_n[*]}]
set_property DATA_RATE DDR  [get_ports {ddrDm[*]}]
set_property DATA_RATE SDR  [get_ports {ddrA[*] ddrAct ddrBa[*] ddrBg[*] ddrCke[*] ddrOdt[*] }]
set_property DATA_RATE DDR  [get_ports {ddrDq[*] ddrDqsP[*] ddrDqsN[*] ddrCkP[*] ddrCkN[*]}]
### Multi-cycle path constraints for Fabric - RIU clock domain crossing signals
##set_max_delay 5.0 -datapath_only -from [get_pins */*/*/u_ddr_cal_addr_decode/io_ready_lvl_reg/C] -to [get_pins */u_io_ready_lvl_sync/SYNC[*].sync_reg_reg[0]/D]
##set_max_delay 5.0 -datapath_only -from [get_pins */*/*/u_ddr_cal_addr_decode/io_read_data_reg[*]/C] -to [get_pins */u_io_read_data_sync/SYNC[*].sync_reg_reg[0]/D]
##set_max_delay 3.0 -datapath_only -from [get_pins */*/*/phy_ready_riuclk_reg/C] -to [get_pins */u_phy2clb_phy_ready_sync/SYNC[*].sync_reg_reg[0]/D]
##set_max_delay 3.0 -datapath_only -from [get_pins */*/*/bisc_complete_riuclk_reg/C] -to [get_pins */u_phy2clb_bisc_complete_sync/SYNC[*].sync_reg_reg[0]/D]
##set_max_delay 3.0 -datapath_only -from [get_pins */*/io_addr_strobe_lvl_riuclk_reg/C] -to [get_pins */u_io_addr_strobe_lvl_sync/SYNC[*].sync_reg_reg[0]/D]
##set_max_delay 3.0 -datapath_only -from [get_pins */*/io_write_strobe_riuclk_reg/C] -to [get_pins */u_io_write_strobe_sync/SYNC[*].sync_reg_reg[0]/D]
##set_max_delay 3.0 -datapath_only -from [get_pins */*/io_address_riuclk_reg[*]/C] -to [get_pins */u_io_addr_sync/SYNC[*].sync_reg_reg[0]/D]
##set_max_delay 3.0 -datapath_only -from [get_pins */*/io_write_data_riuclk_reg[*]/C] -to [get_pins */u_io_write_data_sync/SYNC[*].sync_reg_reg[0]/D]
##set_max_delay 10.0 -datapath_only -from [get_pins */en_vtc_in_reg/C] -to [get_pins */u_en_vtc_sync/SYNC[*].sync_reg_reg[0]/D]
##set_max_delay 10.0 -datapath_only -from [get_pins */*/riu2clb_valid_r1_riuclk_reg[*]/C] -to [get_pins */u_riu2clb_valid_sync/SYNC[*].sync_reg_reg[0]/D]
##set_max_delay 10.0 -datapath_only -from [get_pins */*/*/phy2clb_fixdly_rdy_low_riuclk_int_reg[*]/C] -to [get_pins */u_phy2clb_fixdly_rdy_low/SYNC[*].sync_reg_reg[0]/D]
##set_max_delay 10.0 -datapath_only -from [get_pins */*/*/phy2clb_fixdly_rdy_upp_riuclk_int_reg[*]/C] -to [get_pins */u_phy2clb_fixdly_rdy_upp/SYNC[*].sync_reg_reg[0]/D]
##set_max_delay 10.0 -datapath_only -from [get_pins */*/*/phy2clb_phy_rdy_low_riuclk_int_reg[*]/C] -to [get_pins */u_phy2clb_phy_rdy_low/SYNC[*].sync_reg_reg[0]/D]
##set_max_delay 10.0 -datapath_only -from [get_pins */*/*/phy2clb_phy_rdy_upp_riuclk_int_reg[*]/C] -to [get_pins */u_phy2clb_phy_rdy_upp/SYNC[*].sync_reg_reg[0]/D]
##set_max_delay 10.0 -datapath_only -from [get_pins */rst_r1_reg/C] -to [get_pins */u_fab_rst_sync/SYNC[*].sync_reg_reg[0]/D]
##set_max_delay 3.0 -datapath_only -from [get_pins  */*/*/clb2phy_t_b_addr_riuclk_reg/C] -to [get_pins  */*/*/clb2phy_t_b_addr_i_reg[0]/D]
##set_max_delay 3.0 -datapath_only -from [get_pins  */*/*/*/slave_en_lvl_reg/C] -to [get_pins  */*/*/*/u_slave_en_sync/SYNC[*].sync_reg_reg[0]/D]
##set_max_delay 3.0 -datapath_only -from [get_pins  */*/*/*/slave_we_r_reg/C] -to [get_pins  */*/*/*/u_slave_we_sync/SYNC[*].sync_reg_reg[0]/D]
##set_max_delay 3.0 -datapath_only -from [get_pins  */*/*/*/slave_addr_r_reg[*]/C] -to [get_pins  */*/*/*/u_slave_addr_sync/SYNC[*].sync_reg_reg[0]/D]
##set_max_delay 3.0 -datapath_only -from [get_pins  */*/*/*/slave_di_r_reg[*]/C] -to [get_pins  */*/*/*/u_slave_di_sync/SYNC[*].sync_reg_reg[0]/D]
##set_max_delay 3.0 -datapath_only -from [get_pins  */*/*/*/slave_rdy_cptd_sclk_reg/C] -to [get_pins  */*/*/*/u_slave_rdy_cptd_sync/SYNC[*].sync_reg_reg[0]/D]
##set_max_delay 12.0 -datapath_only -from [get_pins */*/*/*/slave_rdy_lvl_fclk_reg/C] -to [get_pins  */*/*/*/u_slave_rdy_sync/SYNC[*].sync_reg_reg[0]/D]
##set_max_delay 12.0 -datapath_only -from [get_pins */*/*/*/slave_do_fclk_reg[*]/C] -to [get_pins  */*/*/*/u_slave_do_sync/SYNC[*].sync_reg_reg[0]/D]
set_false_path -through [get_pins U_Core/U_DdrMem/inst/u_ddr4_infrastructure/sys_rst]
set_false_path -from [get_pins  U_Core/U_DdrMem/inst/u_ddr4_infrastructure/input_rst_design_reg/C] -to [get_pins U_Core/U_DdrMem/inst/u_ddr4_infrastructure/rst_div_sync_r_reg[0]/D]
set_false_path -from [get_pins  U_Core/U_DdrMem/inst/u_ddr4_infrastructure/input_rst_design_reg/C] -to [get_pins U_Core/U_DdrMem/inst/u_ddr4_infrastructure/rst_riu_sync_r_reg[0]/D]
set_false_path -from [get_pins  U_Core/U_DdrMem/inst/u_ddr4_infrastructure/input_rst_design_reg/C] -to [get_pins U_Core/U_DdrMem/inst/u_ddr4_infrastructure/rst_mb_sync_r_reg[0]/D]
set_false_path -from [get_pins  U_Core/U_DdrMem/inst/u_ddr4_infrastructure/rst_async_riu_div_reg/C] -to [get_pins U_Core/U_DdrMem/inst/u_ddr4_infrastructure/rst_div_sync_r_reg[0]/D]
set_false_path -from [get_pins  U_Core/U_DdrMem/inst/u_ddr4_infrastructure/rst_async_mb_reg/C]      -to [get_pins U_Core/U_DdrMem/inst/u_ddr4_infrastructure/rst_mb_sync_r_reg[0]/D]
set_false_path -from [get_pins  U_Core/U_DdrMem/inst/u_ddr4_infrastructure/rst_async_riu_div_reg/C] -to [get_pins U_Core/U_DdrMem/inst/u_ddr4_infrastructure/rst_riu_sync_r_reg[0]/D]
### These below commands are used to create Interface ports for controller.


create_interface -quiet interface_MigCore
set_property interface interface_MigCore [get_ports [list {ddrDq[2]} {ddrDm[0]} {ddrDq[3]} {ddrOdt[0]} {ddrDq[4]} {ddrDq[5]} {ddrDm[1]} ddrAct {ddrDq[0]} {ddrDq[6]} {ddrDq[8]} {ddrDq[9]} ddrRstL {ddrDq[1]} {ddrDqsP[0]} {ddrDq[7]} {ddrDq[10]} {ddrDq[11]} {ddrDqsN[0]} {ddrDq[14]} {ddrDq[15]} {ddrDqsP[1]} {ddrDq[28]} {ddrCkP[0]} ddrClkP {ddrDq[12]} {ddrDq[13]} {ddrDqsN[1]} {ddrDq[26]} {ddrDq[31]} {ddrDq[30]} {ddrDq[29]} {ddrCkN[0]} ddrClkN {ddrA[0]} {ddrA[1]} {ddrA[8]} {ddrDm[3]} {ddrDq[27]} {ddrDqsN[3]} {ddrDqsP[3]} {ddrDq[24]} {ddrA[2]} {ddrA[4]} {ddrA[5]} {ddrA[6]} {ddrA[7]} {ddrDq[21]} {ddrDq[20]} {ddrDq[18]} {ddr4Dq[25]} {ddrA[3]} {ddrA[9]} {ddrA[11]} {ddrA[13]} {ddrCke[0]} {ddrDm[2]} {ddrDq[19]} {ddrDqsN[2]} {ddrDqsP[2]} {ddrDq[16]} {ddrA[10]} {ddrA[12]} {ddrBg[0]} {ddrA[14]} {ddrDq[23]} {ddrDq[22]} {ddrDq[17]} {ddrA[15]} {ddrA[16]} {ddrCsL[0]} {ddrBa[0]} {ddrBa[1]}]]
