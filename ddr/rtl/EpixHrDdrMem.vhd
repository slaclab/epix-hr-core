-------------------------------------------------------------------------------
-- File       : EpixHrDdrMem.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: EpixHrDdrMem Core's Top Level
-------------------------------------------------------------------------------
-- This file is part of 'EPIX HR Firmware'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'EPIX HR Firmware', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiPkg.all;

library epix_hr_core;
use epix_hr_core.EpixHrCorePkg.all;

entity EpixHrDdrMem is
   generic (
      TPD_G            : time            := 1 ns);
   port (
      -- System Clock and reset
      clk             : in    sl;
      rst             : in    sl;
      -- AXI-Lite Interface
      axilReadMaster  : in    AxiLiteReadMasterType;
      axilReadSlave   : out   AxiLiteReadSlaveType;
      axilWriteMaster : in    AxiLiteWriteMasterType;
      axilWriteSlave  : out   AxiLiteWriteSlaveType;
      -- DDR's AXI Memory Interface (sysClk domain)
      -- DDR Address Range = [0x00000000:0x3FFFFFFF]
      sAxiReadMaster  : in    AxiReadMasterType;
      sAxiReadSlave   : out   AxiReadSlaveType;
      sAxiWriteMaster : in    AxiWriteMasterType;
      sAxiWriteSlave  : out   AxiWriteSlaveType;
      ----------------
      -- Core Ports --
      ----------------   
      -- DDR Ports
      ddrClkP         : in    sl;
      ddrClkN         : in    sl;
      ddrBg           : out   sl;
      ddrCkP          : out   sl;
      ddrCkN          : out   sl;
      ddrCke          : out   sl;
      ddrCsL          : out   sl;
      ddrOdt          : out   sl;
      ddrAct          : out   sl;
      ddrRstL         : out   sl;
      ddrA            : out   slv(16 downto 0);
      ddrBa           : out   slv(1 downto 0);
      ddrDm           : inout slv(3 downto 0);
      ddrDq           : inout slv(31 downto 0);
      ddrDqsP         : inout slv(3 downto 0);
      ddrDqsN         : inout slv(3 downto 0);
      ddrPg           : in    sl;
      ddrPwrEn        : out   sl);
end EpixHrDdrMem;

architecture mapping of EpixHrDdrMem is

   component MigCore
      port (
         c0_init_calib_complete  : out   std_logic;
         dbg_clk                 : out   std_logic;
         c0_sys_clk_p            : in    std_logic;
         c0_sys_clk_n            : in    std_logic;
         dbg_bus                 : out   std_logic_vector(511 downto 0);
         c0_ddr4_adr             : out   std_logic_vector(16 downto 0);
         c0_ddr4_ba              : out   std_logic_vector(1 downto 0);
         c0_ddr4_cke             : out   std_logic_vector(0 downto 0);
         c0_ddr4_cs_n            : out   std_logic_vector(0 downto 0);
         c0_ddr4_dm_dbi_n        : inout std_logic_vector(3 downto 0);
         c0_ddr4_dq              : inout std_logic_vector(31 downto 0);
         c0_ddr4_dqs_c           : inout std_logic_vector(3 downto 0);
         c0_ddr4_dqs_t           : inout std_logic_vector(3 downto 0);
         c0_ddr4_odt             : out   std_logic_vector(0 downto 0);
         c0_ddr4_bg              : out   std_logic_vector(0 downto 0);
         c0_ddr4_reset_n         : out   std_logic;
         c0_ddr4_act_n           : out   std_logic;
         c0_ddr4_ck_c            : out   std_logic_vector(0 downto 0);
         c0_ddr4_ck_t            : out   std_logic_vector(0 downto 0);
         c0_ddr4_ui_clk          : out   std_logic;
         c0_ddr4_ui_clk_sync_rst : out   std_logic;
         c0_ddr4_aresetn         : in    std_logic;
         c0_ddr4_s_axi_awid      : in    std_logic_vector(3 downto 0);
         c0_ddr4_s_axi_awaddr    : in    std_logic_vector(29 downto 0);
         c0_ddr4_s_axi_awlen     : in    std_logic_vector(7 downto 0);
         c0_ddr4_s_axi_awsize    : in    std_logic_vector(2 downto 0);
         c0_ddr4_s_axi_awburst   : in    std_logic_vector(1 downto 0);
         c0_ddr4_s_axi_awlock    : in    std_logic_vector(0 downto 0);
         c0_ddr4_s_axi_awcache   : in    std_logic_vector(3 downto 0);
         c0_ddr4_s_axi_awprot    : in    std_logic_vector(2 downto 0);
         c0_ddr4_s_axi_awqos     : in    std_logic_vector(3 downto 0);
         c0_ddr4_s_axi_awvalid   : in    std_logic;
         c0_ddr4_s_axi_awready   : out   std_logic;
         c0_ddr4_s_axi_wdata     : in    std_logic_vector(255 downto 0);
         c0_ddr4_s_axi_wstrb     : in    std_logic_vector(31 downto 0);
         c0_ddr4_s_axi_wlast     : in    std_logic;
         c0_ddr4_s_axi_wvalid    : in    std_logic;
         c0_ddr4_s_axi_wready    : out   std_logic;
         c0_ddr4_s_axi_bready    : in    std_logic;
         c0_ddr4_s_axi_bid       : out   std_logic_vector(3 downto 0);
         c0_ddr4_s_axi_bresp     : out   std_logic_vector(1 downto 0);
         c0_ddr4_s_axi_bvalid    : out   std_logic;
         c0_ddr4_s_axi_arid      : in    std_logic_vector(3 downto 0);
         c0_ddr4_s_axi_araddr    : in    std_logic_vector(29 downto 0);
         c0_ddr4_s_axi_arlen     : in    std_logic_vector(7 downto 0);
         c0_ddr4_s_axi_arsize    : in    std_logic_vector(2 downto 0);
         c0_ddr4_s_axi_arburst   : in    std_logic_vector(1 downto 0);
         c0_ddr4_s_axi_arlock    : in    std_logic_vector(0 downto 0);
         c0_ddr4_s_axi_arcache   : in    std_logic_vector(3 downto 0);
         c0_ddr4_s_axi_arprot    : in    std_logic_vector(2 downto 0);
         c0_ddr4_s_axi_arqos     : in    std_logic_vector(3 downto 0);
         c0_ddr4_s_axi_arvalid   : in    std_logic;
         c0_ddr4_s_axi_arready   : out   std_logic;
         c0_ddr4_s_axi_rready    : in    std_logic;
         c0_ddr4_s_axi_rlast     : out   std_logic;
         c0_ddr4_s_axi_rvalid    : out   std_logic;
         c0_ddr4_s_axi_rresp     : out   std_logic_vector(1 downto 0);
         c0_ddr4_s_axi_rid       : out   std_logic_vector(3 downto 0);
         c0_ddr4_s_axi_rdata     : out   std_logic_vector(255 downto 0);
         sys_rst                 : in    std_logic
         );
   end component;

   signal ddrWriteMaster : AxiWriteMasterType := AXI_WRITE_MASTER_INIT_C;
   signal ddrWriteSlave  : AxiWriteSlaveType  := AXI_WRITE_SLAVE_INIT_C;
   signal ddrReadMaster  : AxiReadMasterType  := AXI_READ_MASTER_INIT_C;
   signal ddrReadSlave   : AxiReadSlaveType   := AXI_READ_SLAVE_INIT_C;


   signal ddrClk     : sl;
   signal ddrRst     : sl;
   signal ddrCalDone : sl;
   signal rstL       : sl;
   signal coreRst    : slv(1 downto 0) := "11";

begin

   rstL <= not(rst);

   U_MigCore : MigCore
      port map (
         c0_init_calib_complete  => ddrCalDone,
         dbg_clk                 => open,
         c0_sys_clk_p            => ddrClkP,
         c0_sys_clk_n            => ddrClkN,
         dbg_bus                 => open,
         c0_ddr4_adr             => ddrA,
         c0_ddr4_ba              => ddrBa,
         c0_ddr4_cke(0)          => ddrCke,
         c0_ddr4_cs_n(0)         => ddrCsL,
         c0_ddr4_dm_dbi_n        => ddrDm,
         c0_ddr4_dq              => ddrDq,
         c0_ddr4_dqs_c           => ddrDqsN,
         c0_ddr4_dqs_t           => ddrDqsP,
         c0_ddr4_odt(0)          => ddrOdt,
         c0_ddr4_bg(0)           => ddrBg,
         c0_ddr4_reset_n         => ddrRstL,
         c0_ddr4_act_n           => ddrAct,
         c0_ddr4_ck_c(0)         => ddrCkN,
         c0_ddr4_ck_t(0)         => ddrCkP,
         c0_ddr4_ui_clk          => ddrClk,
         c0_ddr4_ui_clk_sync_rst => coreRst(0),
         c0_ddr4_aresetn         => rstL,
         c0_ddr4_s_axi_awid      => ddrWriteMaster.awid(3 downto 0),
         c0_ddr4_s_axi_awaddr    => ddrWriteMaster.awaddr(29 downto 0),
         c0_ddr4_s_axi_awlen     => ddrWriteMaster.awlen(7 downto 0),
         c0_ddr4_s_axi_awsize    => ddrWriteMaster.awsize(2 downto 0),
         c0_ddr4_s_axi_awburst   => ddrWriteMaster.awburst(1 downto 0),
         c0_ddr4_s_axi_awlock    => ddrWriteMaster.awlock(0 downto 0),
         c0_ddr4_s_axi_awcache   => ddrWriteMaster.awcache(3 downto 0),
         c0_ddr4_s_axi_awprot    => ddrWriteMaster.awprot(2 downto 0),
         c0_ddr4_s_axi_awqos     => ddrWriteMaster.awqos(3 downto 0),
         c0_ddr4_s_axi_awvalid   => ddrWriteMaster.awvalid,
         c0_ddr4_s_axi_awready   => ddrWriteSlave.awready,
         c0_ddr4_s_axi_wdata     => ddrWriteMaster.wdata(255 downto 0),
         c0_ddr4_s_axi_wstrb     => ddrWriteMaster.wstrb(31 downto 0),
         c0_ddr4_s_axi_wlast     => ddrWriteMaster.wlast,
         c0_ddr4_s_axi_wvalid    => ddrWriteMaster.wvalid,
         c0_ddr4_s_axi_wready    => ddrWriteSlave.wready,
         c0_ddr4_s_axi_bready    => ddrWriteMaster.bready,
         c0_ddr4_s_axi_bid       => ddrWriteSlave.bid(3 downto 0),
         c0_ddr4_s_axi_bresp     => ddrWriteSlave.bresp(1 downto 0),
         c0_ddr4_s_axi_bvalid    => ddrWriteSlave.bvalid,
         c0_ddr4_s_axi_arid      => ddrReadMaster.arid(3 downto 0),
         c0_ddr4_s_axi_araddr    => ddrReadMaster.araddr(29 downto 0),
         c0_ddr4_s_axi_arlen     => ddrReadMaster.arlen(7 downto 0),
         c0_ddr4_s_axi_arsize    => ddrReadMaster.arsize(2 downto 0),
         c0_ddr4_s_axi_arburst   => ddrReadMaster.arburst(1 downto 0),
         c0_ddr4_s_axi_arlock    => ddrReadMaster.arlock(0 downto 0),
         c0_ddr4_s_axi_arcache   => ddrReadMaster.arcache(3 downto 0),
         c0_ddr4_s_axi_arprot    => ddrReadMaster.arprot(2 downto 0),
         c0_ddr4_s_axi_arqos     => ddrReadMaster.arqos(3 downto 0),
         c0_ddr4_s_axi_arvalid   => ddrReadMaster.arvalid,
         c0_ddr4_s_axi_arready   => ddrReadSlave.arready,
         c0_ddr4_s_axi_rready    => ddrReadMaster.rready,
         c0_ddr4_s_axi_rlast     => ddrReadSlave.rlast,
         c0_ddr4_s_axi_rvalid    => ddrReadSlave.rvalid,
         c0_ddr4_s_axi_rresp     => ddrReadSlave.rresp(1 downto 0),
         c0_ddr4_s_axi_rid       => ddrReadSlave.rid(3 downto 0),
         c0_ddr4_s_axi_rdata     => ddrReadSlave.rdata(255 downto 0),
         sys_rst                 => rst);

   process(ddrClk)
   begin
      if rising_edge(ddrClk) then
         ddrRst     <= coreRst(1) after TPD_G;  -- Register to help with timing
         coreRst(1) <= coreRst(0) after TPD_G;  -- Register to help with timing
      end if;
   end process;

   ---------------------
   -- Read Path AXI FIFO (Need to double check this generic configurations!!! not sure if they are correct)
   ---------------------
   U_AxiReadPathFifo : entity surf.AxiReadPathFifo
      generic map (
         TPD_G                  => TPD_G,
         GEN_SYNC_FIFO_G        => false,
         ADDR_LSB_G             => 3,
         ID_FIXED_EN_G          => true,
         SIZE_FIXED_EN_G        => true,
         BURST_FIXED_EN_G       => true,
         LEN_FIXED_EN_G         => false,
         LOCK_FIXED_EN_G        => true,
         PROT_FIXED_EN_G        => true,
         CACHE_FIXED_EN_G       => true,
         ADDR_MEMORY_TYPE_G     => "distributed",
         ADDR_CASCADE_SIZE_G    => 1,
         ADDR_FIFO_ADDR_WIDTH_G => 4,
         DATA_MEMORY_TYPE_G     => "distributed",
         DATA_CASCADE_SIZE_G    => 1,
         DATA_FIFO_ADDR_WIDTH_G => 4,
         AXI_CONFIG_G           => DDR_AXI_CONFIG_C)
      port map (
         sAxiClk        => clk,
         sAxiRst        => rst,
         sAxiReadMaster => sAxiReadMaster,
         sAxiReadSlave  => sAxiReadSlave,
         mAxiClk        => ddrClk,
         mAxiRst        => ddrRst,
         mAxiReadMaster => ddrReadMaster,
         mAxiReadSlave  => ddrReadSlave);

   ----------------------
   -- Write Path AXI FIFO (Need to double check this generic configurations!!! not sure if they are correct)
   ----------------------
   U_AxiWritePathFifo : entity surf.AxiWritePathFifo
      generic map (
         TPD_G                    => TPD_G,
         GEN_SYNC_FIFO_G          => false,
         ADDR_LSB_G               => 3,
         ID_FIXED_EN_G            => true,
         SIZE_FIXED_EN_G          => true,
         BURST_FIXED_EN_G         => true,
         LEN_FIXED_EN_G           => false,
         LOCK_FIXED_EN_G          => true,
         PROT_FIXED_EN_G          => true,
         CACHE_FIXED_EN_G         => true,
         ADDR_MEMORY_TYPE_G       => "block",
         ADDR_CASCADE_SIZE_G      => 1,
         ADDR_FIFO_ADDR_WIDTH_G   => 9,
         DATA_MEMORY_TYPE_G       => "block",
         DATA_CASCADE_SIZE_G      => 1,
         DATA_FIFO_ADDR_WIDTH_G   => 9,
         DATA_FIFO_PAUSE_THRESH_G => 456,
         RESP_MEMORY_TYPE_G       => "distributed",
         RESP_CASCADE_SIZE_G      => 1,
         RESP_FIFO_ADDR_WIDTH_G   => 4,
         AXI_CONFIG_G             => DDR_AXI_CONFIG_C)
      port map (
         sAxiClk         => clk,
         sAxiRst         => rst,
         sAxiWriteMaster => sAxiWriteMaster,
         sAxiWriteSlave  => sAxiWriteSlave,
         mAxiClk         => ddrClk,
         mAxiRst         => ddrRst,
         mAxiWriteMaster => ddrWriteMaster,
         mAxiWriteSlave  => ddrWriteSlave);

   -- Placeholder for future DDR monitoring and power control firmware code
   ddrPwrEn <= '1';
   axilReadSlave  <= AXI_LITE_READ_SLAVE_EMPTY_OK_C;
   axilWriteSlave <= AXI_LITE_WRITE_SLAVE_EMPTY_OK_C;


end mapping;
