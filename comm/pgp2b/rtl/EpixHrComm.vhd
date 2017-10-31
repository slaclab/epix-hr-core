-------------------------------------------------------------------------------
-- File       : EpixHrComm.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-04-21
-- Last update: 2017-04-24
-------------------------------------------------------------------------------
-- Description: Wrapper for PGP2B communication
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
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.SsiPkg.all;
use work.Pgp2bPkg.all;
use work.EpixHrCorePkg.all;

library unisim;
use unisim.vcomponents.all;

entity EpixHrComm is
   generic (
      TPD_G            : time             := 1 ns;
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
      sysClk           : in  sl;
      sysRst           : in  sl;
      gtRefClk         : in  sl;
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
      qsfpTxN          : out slv(3 downto 0));
end EpixHrComm;

architecture mapping of EpixHrComm is

   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray(3 downto 0) := genAxiLiteConfig(4, AXI_BASE_ADDR_G, 20, 16);

   signal axilWriteMasters : AxiLiteWriteMasterArray(3 downto 0); 
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(3 downto 0); 
   signal axilReadMasters  : AxiLiteReadMasterArray(3 downto 0); 
   signal axilReadSlaves   : AxiLiteReadSlaveArray(3 downto 0);    
   
   signal pgpRxIn      : Pgp2bRxInArray(3 downto 0);
   signal pgpRxOut     : Pgp2bRxOutArray(3 downto 0);
   signal pgpTxIn      : Pgp2bTxInArray(3 downto 0);
   signal pgpTxOut     : Pgp2bTxOutArray(3 downto 0);
   
   signal pgpTxMasters : AxiStreamMasterVectorArray(0 to 7, 0 to 3) := (others => (others => AXI_STREAM_MASTER_INIT_C));
   signal pgpTxSlaves  : AxiStreamSlaveVectorArray(0 to 7, 0 to 3)  := (others => (others => AXI_STREAM_SLAVE_FORCE_C));
   signal pgpRxMasters : AxiStreamMasterVectorArray(0 to 7, 0 to 3) := (others => (others => AXI_STREAM_MASTER_INIT_C));
   signal pgpRxCtrl    : AxiStreamCtrlVectorArray(0 to 7, 0 to 3)   := (others => (others => AXI_STREAM_CTRL_UNUSED_C));

begin

   U_XBAR : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         DEC_ERROR_RESP_G   => AXI_ERROR_RESP_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => 4,
         MASTERS_CONFIG_G   => AXIL_CONFIG_C)
      port map (
         axiClk              => sysClk,
         axiClkRst           => sysRst,
         sAxiWriteMasters(0) => axilWriteMaster,
         sAxiWriteSlaves(0)  => axilWriteSlave,
         sAxiReadMasters(0)  => axilReadMaster,
         sAxiReadSlaves(0)   => axilReadSlave,
         mAxiWriteMasters    => axilWriteMasters,
         mAxiWriteSlaves     => axilWriteSlaves,
         mAxiReadMasters     => axilReadMasters,
         mAxiReadSlaves      => axilReadSlaves);

   PGP_LANE :
   for i in 3 downto 0 generate

      U_PGP : entity work.EpixHrPgp2bGthUltra
         generic map (
            TPD_G             => TPD_G,
            PGP_RX_ENABLE_G   => true,
            PGP_TX_ENABLE_G   => true,
            PAYLOAD_CNT_TOP_G => 7,     -- Top bit for payload counter
            VC_INTERLEAVE_G   => 0,     -- Interleave Frames = false
            NUM_VC_EN_G       => 4)
         port map (
            -- GT Clocking
            stableClk       => sysClk,
            stableRst       => sysRst,
            gtRefClk        => gtRefClk,
            -- Gt Serial IO
            pgpGtTxP        => qsfpTxP(i),
            pgpGtTxN        => qsfpTxN(i),
            pgpGtRxP        => qsfpRxP(i),
            pgpGtRxN        => qsfpRxN(i),
            -- Tx Clocking
            pgpTxReset      => sysRst,
            pgpTxRecClk     => open,
            pgpTxClk        => sysClk,
            pgpTxMmcmLocked => '1',
            -- Rx clocking
            pgpRxReset      => sysRst,
            pgpRxRecClk     => open,
            pgpRxClk        => sysClk,
            pgpRxMmcmLocked => '1',
            -- Non VC Rx Signals
            pgpRxIn         => pgpRxIn(i),
            pgpRxOut        => pgpRxOut(i),
            -- Non VC Tx Signals
            pgpTxIn         => pgpTxIn(i),
            pgpTxOut        => pgpTxOut(i),
            -- Frame Transmit Interface
            pgpTxMasters(0) => pgpTxMasters(i, 0),
            pgpTxMasters(1) => pgpTxMasters(i, 1),
            pgpTxMasters(2) => pgpTxMasters(i, 2),
            pgpTxMasters(3) => pgpTxMasters(i, 3),
            pgpTxSlaves(0)  => pgpTxSlaves(i, 0),
            pgpTxSlaves(1)  => pgpTxSlaves(i, 1),
            pgpTxSlaves(2)  => pgpTxSlaves(i, 2),
            pgpTxSlaves(3)  => pgpTxSlaves(i, 3),
            -- Frame Receive Interface
            pgpRxMasters(0) => pgpRxMasters(i, 0),
            pgpRxMasters(1) => pgpRxMasters(i, 1),
            pgpRxMasters(2) => pgpRxMasters(i, 2),
            pgpRxMasters(3) => pgpRxMasters(i, 3),
            pgpRxCtrl(0)    => pgpRxCtrl(i, 0),
            pgpRxCtrl(1)    => pgpRxCtrl(i, 1),
            pgpRxCtrl(2)    => pgpRxCtrl(i, 2),
            pgpRxCtrl(3)    => pgpRxCtrl(i, 3));

      U_PgpMon : entity work.Pgp2bAxi
         generic map (
            TPD_G              => TPD_G,
            AXI_ERROR_RESP_G   => AXI_ERROR_RESP_G,
            COMMON_TX_CLK_G    => true,
            COMMON_RX_CLK_G    => true,
            WRITE_EN_G         => false,
            AXI_CLK_FREQ_G     => SYSCLK_FREQ_C,
            STATUS_CNT_WIDTH_G => 32,
            ERROR_CNT_WIDTH_G  => 16)
         port map (
            -- TX PGP Interface (pgpTxClk)
            pgpTxClk        => sysClk,
            pgpTxClkRst     => sysRst,
            pgpTxIn         => pgpTxIn(i),
            pgpTxOut        => pgpTxOut(i),
            -- RX PGP Interface (pgpRxClk)
            pgpRxClk        => sysClk,
            pgpRxClkRst     => sysRst,
            pgpRxIn         => pgpRxIn(i),
            pgpRxOut        => pgpRxOut(i),
            -- AXI-Lite Register Interface (axilClk domain)
            axilClk         => sysClk,
            axilRst         => sysRst,
            axilReadMaster  => axilReadMasters(i),
            axilReadSlave   => axilReadSlaves(i),
            axilWriteMaster => axilWriteMasters(i),
            axilWriteSlave  => axilWriteSlaves(i));

      U_Vc0 : entity work.AxiStreamFifoV2
         generic map (
            CASCADE_SIZE_G      => 1,
            BRAM_EN_G           => true,
            USE_BUILT_IN_G      => false,
            GEN_SYNC_FIFO_G     => true,
            FIFO_ADDR_WIDTH_G   => 9,
            FIFO_FIXED_THRESH_G => true,
            FIFO_PAUSE_THRESH_G => 128,
            SLAVE_AXI_CONFIG_G  => COMM_AXIS_CONFIG_C,
            MASTER_AXI_CONFIG_G => SSI_PGP2B_CONFIG_C)
         port map (
            -- Slave Port
            sAxisClk    => sysClk,
            sAxisRst    => sysRst,
            sAxisMaster => sAxisMasters(i),
            sAxisSlave  => sAxisSlaves(i),
            -- Master Port
            mAxisClk    => sysClk,
            mAxisRst    => sysRst,
            mAxisMaster => pgpTxMasters(i, 0),
            mAxisSlave  => pgpTxSlaves(i, 0));


      -- Check for Lane=0
      GEN_LANE0 : if (i = 0) generate

         -- VC1 RX/TX, SRPv3 Register Module    
         U_SRPv3 : entity work.SrpV3AxiLite
            generic map (
               TPD_G               => TPD_G,
               SLAVE_READY_EN_G    => false,
               GEN_SYNC_FIFO_G     => true,
               AXI_STREAM_CONFIG_G => SSI_PGP2B_CONFIG_C)
            port map (
               -- Streaming Slave (Rx) Interface (sAxisClk domain) 
               sAxisClk         => sysClk,
               sAxisRst         => sysRst,
               sAxisMaster      => pgpRxMasters(0, 1),
               sAxisCtrl        => pgpRxCtrl(0, 1),
               -- Streaming Master (Tx) Data Interface (mAxisClk domain)
               mAxisClk         => sysClk,
               mAxisRst         => sysRst,
               mAxisMaster      => pgpTxMasters(0, 1),
               mAxisSlave       => pgpTxSlaves(0, 1),
               -- Master AXI-Lite Interface (axilClk domain)
               axilClk          => sysClk,
               axilRst          => sysRst,
               mAxilReadMaster  => mAxilReadMaster,
               mAxilReadSlave   => mAxilReadSlave,
               mAxilWriteMaster => mAxilWriteMaster,
               mAxilWriteSlave  => mAxilWriteSlave);

         -- VC2, Microblaze AXI Streaming Interface
         U_Vc2 : entity work.AxiStreamFifoV2
            generic map (
               CASCADE_SIZE_G      => 1,
               BRAM_EN_G           => true,
               USE_BUILT_IN_G      => false,
               GEN_SYNC_FIFO_G     => false,
               FIFO_ADDR_WIDTH_G   => 9,
               FIFO_FIXED_THRESH_G => true,
               FIFO_PAUSE_THRESH_G => 128,
               SLAVE_AXI_CONFIG_G  => ssiAxiStreamConfig(4),
               MASTER_AXI_CONFIG_G => SSI_PGP2B_CONFIG_C)
            port map (
               -- Slave Port
               sAxisClk    => sysClk,
               sAxisRst    => sysRst,
               sAxisMaster => mbTxMaster,
               sAxisSlave  => mbTxSlave,
               -- Master Port
               mAxisClk    => sysClk,
               mAxisRst    => sysRst,
               mAxisMaster => pgpTxMasters(0, 2),
               mAxisSlave  => pgpTxSlaves(0, 2));

      end generate;

   end generate PGP_LANE;

end mapping;
