-------------------------------------------------------------------------------
-- File       : EpixHrComm.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-04-21
-- Last update: 2017-04-24
-------------------------------------------------------------------------------
-- Description: EpixHrComm Core's Top Level
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

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;
use work.AxiLitePkg.all;
use work.EpixHrCorePkg.all;

library unisim;
use unisim.vcomponents.all;

entity EpixHrComm is
   generic (
      TPD_G            : time             := 1 ns;
      COMM_TYPE_G      : CommModeType     := COMM_MODE_PGP2B_C;
      ETH_DHCP_G       : boolean          := true;
      AXI_BASE_ADDR_G  : slv(31 downto 0) := (others => '0');
      AXI_ERROR_RESP_G : slv(1 downto 0)  := AXI_RESP_SLVERR_C);
   port (
      -- Debug AXI-Lite Interface
      axilReadMaster   : in  AxiLiteReadMasterType;
      axilReadSlave    : out AxiLiteReadSlaveType;
      axilWriteMaster  : in  AxiLiteWriteMasterType;
      axilWriteSlave   : out AxiLiteWriteSlaveType;
      -- Microblaze Streaming Interface
      mbTxMaster       : in  AxiStreamMasterType;
      mbTxSlave        : out AxiStreamSlaveType;
      ----------------------
      -- Top Level Interface
      ----------------------
      -- System Clock and Reset
      sysClk           : out sl;
      sysRst           : out sl;
      -- AXI-Lite Register Interface (sysClk domain)
      mAxilReadMaster  : out AxiLiteReadMasterType;
      mAxilReadSlave   : in  AxiLiteReadSlaveType;
      mAxilWriteMaster : out AxiLiteWriteMasterType;
      mAxilWriteSlave  : in  AxiLiteWriteSlaveType;
      -- AXI Stream, one per QSFP lane (sysClk domain)
      sAxisMasters     : in  AxiStreamMasterArray(3 downto 0);
      sAxisSlaves      : out AxiStreamSlaveArray(3 downto 0);
      ----------------
      -- Core Ports --
      ----------------   
      -- QSFP Ports
      qsfpRxP          : in  slv(3 downto 0);
      qsfpRxN          : in  slv(3 downto 0);
      qsfpTxP          : out slv(3 downto 0);
      qsfpTxN          : out slv(3 downto 0);
      qsfpClkP         : in  sl;
      qsfpClkN         : in  sl);
end EpixHrComm;

architecture mapping of EpixHrComm is

   signal gtRefClk : sl;
   signal fabClock : sl;
   signal fabClk   : sl;
   signal fabRst   : sl;
   signal clk      : sl;
   signal rst      : sl;
   signal reset    : slv(1 downto 0);

begin

   sysClk <= clk;
   sysRst <= rst;

   U_IBUFDS : IBUFDS_GTE3
      generic map (
         REFCLK_EN_TX_PATH  => '0',
         REFCLK_HROW_CK_SEL => "00",    -- 2'b00: ODIV2 = O
         REFCLK_ICNTL_RX    => "00")
      port map (
         I     => qsfpClkP,
         IB    => qsfpClkN,
         CEB   => '0',
         ODIV2 => fabClock,
         O     => gtRefClk);

   U_BUFG_GT : BUFG_GT
      port map (
         I       => fabClock,
         CE      => '1',
         CEMASK  => '1',
         CLR     => '0',
         CLRMASK => '1',
         DIV     => "000",              -- Divide by 1
         O       => fabClk);

   U_PwrUpRst : entity work.PwrUpRst
      generic map(
         TPD_G => TPD_G)
      port map(
         clk    => fabClk,
         rstOut => fabRst);

   U_Mmcm : entity work.ClockManagerUltraScale
      generic map(
         TPD_G             => TPD_G,
         TYPE_G            => "PLL",
         INPUT_BUFG_G      => true,
         FB_BUFG_G         => true,
         RST_IN_POLARITY_G => '1',
         NUM_CLOCKS_G      => 1,
         -- MMCM attributes
         BANDWIDTH_G       => "OPTIMIZED",
         CLKIN_PERIOD_G    => 6.4,
         DIVCLK_DIVIDE_G   => 1,
         CLKFBOUT_MULT_G   => 4,
         CLKOUT0_DIVIDE_G  => 4)
      port map(
         -- Clock Input
         clkIn     => fabClk,
         rstIn     => fabRst,
         -- Clock Outputs
         clkOut(0) => clk,
         -- Reset Outputs
         rstOut(0) => reset(0));

   process(clk)
   begin
      if rising_edge(clk) then
         rst      <= reset(1) after TPD_G;  -- Register to help with timing
         reset(1) <= reset(0) after TPD_G;  -- Register to help with timing
      end if;
   end process;

   PGP2B : if (COMM_TYPE_G = COMM_MODE_PGP2B_C) generate
      U_Inst : entity work.EpixHrCommPgp2b
         generic map (
            TPD_G            => TPD_G,
            AXI_BASE_ADDR_G  => AXI_BASE_ADDR_G,
            AXI_ERROR_RESP_G => AXI_ERROR_RESP_G)
         port map (
            -- Debug AXI-Lite Interface
            axilReadMaster   => axilReadMaster,
            axilReadSlave    => axilReadSlave,
            axilWriteMaster  => axilWriteMaster,
            axilWriteSlave   => axilWriteSlave,
            -- Microblaze Streaming Interface
            mbTxMaster       => mbTxMaster,
            mbTxSlave        => mbTxSlave,
            ----------------------
            -- Top Level Interface
            ----------------------
            -- System Clock and Reset
            sysClk           => clk,
            sysRst           => rst,
            gtRefClk         => gtRefClk,
            -- AXI-Lite Register Interface (sysClk domain)
            mAxilReadMaster  => mAxilReadMaster,
            mAxilReadSlave   => mAxilReadSlave,
            mAxilWriteMaster => mAxilWriteMaster,
            mAxilWriteSlave  => mAxilWriteSlave,
            -- AXI Stream Interface (sysClk domain)
            sAxisMasters     => sAxisMasters,
            sAxisSlaves      => sAxisSlaves,
            ----------------
            -- Core Ports --
            ----------------   
            -- QSFP Ports
            qsfpRxP          => qsfpRxP,
            qsfpRxN          => qsfpRxN,
            qsfpTxP          => qsfpTxP,
            qsfpTxN          => qsfpTxN);
   end generate;

   PGP3 : if (COMM_TYPE_G = COMM_MODE_PGP3_C) generate
      U_Inst : entity work.EpixHrCommPgp3
         generic map (
            TPD_G            => TPD_G,
            AXI_BASE_ADDR_G  => AXI_BASE_ADDR_G,
            AXI_ERROR_RESP_G => AXI_ERROR_RESP_G)
         port map (
            -- Debug AXI-Lite Interface
            axilReadMaster   => axilReadMaster,
            axilReadSlave    => axilReadSlave,
            axilWriteMaster  => axilWriteMaster,
            axilWriteSlave   => axilWriteSlave,
            -- Microblaze Streaming Interface
            mbTxMaster       => mbTxMaster,
            mbTxSlave        => mbTxSlave,
            ----------------------
            -- Top Level Interface
            ----------------------
            -- System Clock and Reset
            sysClk           => clk,
            sysRst           => rst,
            gtRefClk         => gtRefClk,
            -- AXI-Lite Register Interface (sysClk domain)
            mAxilReadMaster  => mAxilReadMaster,
            mAxilReadSlave   => mAxilReadSlave,
            mAxilWriteMaster => mAxilWriteMaster,
            mAxilWriteSlave  => mAxilWriteSlave,
            -- AXI Stream Interface (sysClk domain)
            sAxisMasters     => sAxisMasters,
            sAxisSlaves      => sAxisSlaves,
            ----------------
            -- Core Ports --
            ----------------   
            -- QSFP Ports
            qsfpRxP          => qsfpRxP,
            qsfpRxN          => qsfpRxN,
            qsfpTxP          => qsfpTxP,
            qsfpTxN          => qsfpTxN);
   end generate;

   ETH : if ((COMM_TYPE_G = COMM_MODE_1GbE_C) or (COMM_TYPE_G = COMM_MODE_10GbE_C)) generate
      U_Inst : entity work.EpixHrCommEth
         generic map (
            TPD_G            => TPD_G,
            COMM_MODE_G      => ite((COMM_TYPE_G = COMM_MODE_10GbE_C), true, false),
            ETH_DHCP_G       => ETH_DHCP_G,
            AXI_BASE_ADDR_G  => AXI_BASE_ADDR_G,
            AXI_ERROR_RESP_G => AXI_ERROR_RESP_G)
         port map (
            -- Debug AXI-Lite Interface
            axilReadMaster   => axilReadMaster,
            axilReadSlave    => axilReadSlave,
            axilWriteMaster  => axilWriteMaster,
            axilWriteSlave   => axilWriteSlave,
            -- Microblaze Streaming Interface
            mbTxMaster       => mbTxMaster,
            mbTxSlave        => mbTxSlave,
            ----------------------
            -- Top Level Interface
            ----------------------
            -- System Clock and Reset
            sysClk           => clk,
            sysRst           => rst,
            gtRefClk         => gtRefClk,
            -- AXI-Lite Register Interface (sysClk domain)
            mAxilReadMaster  => mAxilReadMaster,
            mAxilReadSlave   => mAxilReadSlave,
            mAxilWriteMaster => mAxilWriteMaster,
            mAxilWriteSlave  => mAxilWriteSlave,
            -- AXI Stream Interface (sysClk domain)
            sAxisMasters     => sAxisMasters,
            sAxisSlaves      => sAxisSlaves,
            ----------------
            -- Core Ports --
            ----------------   
            -- QSFP Ports
            qsfpRxP          => qsfpRxP,
            qsfpRxN          => qsfpRxN,
            qsfpTxP          => qsfpTxP,
            qsfpTxN          => qsfpTxN);
   end generate;

end mapping;
