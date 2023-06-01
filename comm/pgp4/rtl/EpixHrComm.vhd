-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Wrapper for PGP4 communication
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
use surf.AxiStreamPkg.all;
use surf.SsiPkg.all;
use surf.SsiCmdMasterPkg.all;
use surf.Pgp4Pkg.all;

library epix_hr_core;
use epix_hr_core.EpixHrCorePkg.all;

library unisim;
use unisim.vcomponents.all;

entity EpixHrComm is
   generic (
      TPD_G                : time                        := 1 ns;
      AXI_BASE_ADDR_G      : slv(31 downto 0)            := (others => '0');
      NUM_LANES_G          : integer                     := 4;
      RATE_G               : string                      := "10.3125Gbps";  -- or "6.25Gbps" or "3.125Gbps"
      ROGUE_SIM_EN_G       : boolean                     := false;
      ROGUE_SIM_PORT_NUM_G : natural range 1024 to 49151 := 11000);
   port (
      -- Debug AXI-Lite Interface
      axilReadMaster   : in  AxiLiteReadMasterType;
      axilReadSlave    : out AxiLiteReadSlaveType;
      axilWriteMaster  : in  AxiLiteWriteMasterType;
      axilWriteSlave   : out AxiLiteWriteSlaveType;
      -- Microblaze Streaming Interface
      mbTxMaster       : in  AxiStreamMasterType;
      mbTxSlave        : out AxiStreamSlaveType;
      -- PseudoScope Streaming Interface
      psTxMaster       : in  AxiStreamMasterType;
      psTxSlave        : out AxiStreamSlaveType;
      -- Monitoring Streaming Interface
      monTxMaster      : in  AxiStreamMasterType;
      monTxSlave       : out AxiStreamSlaveType;
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
      sAxisMasters     : in  AxiStreamMasterArray(NUM_LANES_G-1 downto 0);
      sAxisSlaves      : out AxiStreamSlaveArray(NUM_LANES_G-1 downto 0);
      -- ssi commands (Lane 0 and Vc 1)
      ssiCmd           : out SsiCmdMasterType;
      -- Trigger (sysClk domain)
      pgpTrigger       : out sl;
      ----------------
      -- Core Ports --
      ----------------
      -- QSFP Ports
      qsfpRxP          : in  slv(NUM_LANES_G-1 downto 0);
      qsfpRxN          : in  slv(NUM_LANES_G-1 downto 0);
      qsfpTxP          : out slv(NUM_LANES_G-1 downto 0);
      qsfpTxN          : out slv(NUM_LANES_G-1 downto 0));
end EpixHrComm;

architecture mapping of EpixHrComm is

   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_LANES_G-1 downto 0) := genAxiLiteConfig(NUM_LANES_G, AXI_BASE_ADDR_G, 20, 16);

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_LANES_G-1 downto 0) := (others => AXI_LITE_WRITE_MASTER_INIT_C);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_LANES_G-1 downto 0)  := (others => AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_LANES_G-1 downto 0)  := (others => AXI_LITE_READ_MASTER_INIT_C);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_LANES_G-1 downto 0)   := (others => AXI_LITE_READ_SLAVE_EMPTY_DECERR_C);

   signal pgpRxIn  : Pgp4RxInArray(NUM_LANES_G-1 downto 0);
   signal pgpRxOut : Pgp4RxOutArray(NUM_LANES_G-1 downto 0);
   signal pgpTxIn  : Pgp4TxInArray(NUM_LANES_G-1 downto 0);
   signal pgpTxOut : Pgp4TxOutArray(NUM_LANES_G-1 downto 0);

   signal pgpTxMasters : AxiStreamMasterVectorArray(0 to NUM_LANES_G-1, 0 to 3) := (others => (others => AXI_STREAM_MASTER_INIT_C));
   signal pgpTxSlaves  : AxiStreamSlaveVectorArray(0 to NUM_LANES_G-1, 0 to 3)  := (others => (others => AXI_STREAM_SLAVE_FORCE_C));
   signal pgpRxMasters : AxiStreamMasterVectorArray(0 to NUM_LANES_G-1, 0 to 3) := (others => (others => AXI_STREAM_MASTER_INIT_C));
   signal pgpRxSlaves  : AxiStreamSlaveVectorArray(0 to NUM_LANES_G-1, 0 to 3)  := (others => (others => AXI_STREAM_SLAVE_FORCE_C));
   signal pgpRxCtrl    : AxiStreamCtrlVectorArray(0 to NUM_LANES_G-1, 0 to 3)   := (others => (others => AXI_STREAM_CTRL_UNUSED_C));

   signal qpllLock   : Slv2Array(3 downto 0) := (others => "00");
   signal qpllClk    : Slv2Array(3 downto 0) := (others => "00");
   signal qpllRefclk : Slv2Array(3 downto 0) := (others => "00");
   signal qpllRst    : Slv2Array(3 downto 0) := (others => "00");

   signal pgpClk : slv(NUM_LANES_G-1 downto 0);
   signal pgpRst : slv(NUM_LANES_G-1 downto 0);

   signal inMuxTxMaster  : AxiStreamMasterArray(1 downto 0);
   signal inMuxTxSlave   : AxiStreamSlaveArray(1 downto 0);
   signal outMuxTxMaster : AxiStreamMasterType;
   signal outMuxTxSlave  : AxiStreamSlaveType;

begin

  U_SyncTrig1 : entity surf.SynchronizerOneShot
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => sysClk,
         dataIn  => pgpRxOut(0).opCodeEn,
         dataOut => pgpTrigger);

   U_XBAR : entity surf.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_LANES_G,
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

   HW_GEN : if (not ROGUE_SIM_EN_G) generate
      U_QPLL : entity surf.Pgp3GthUsQpll
         generic map (
            TPD_G    => TPD_G,
            RATE_G   => RATE_G,
            EN_DRP_G => true)
         port map (
            -- Stable Clock and Reset
            stableClk  => sysClk,
            stableRst  => sysRst,
            -- QPLL Clocking
            pgpRefClk  => gtRefClk,
            qpllLock   => qpllLock,
            qpllClk    => qpllClk,
            qpllRefclk => qpllRefclk,
            qpllRst    => qpllRst);
   end generate HW_GEN;

   PGP_LANE :
   for i in NUM_LANES_G-1 downto 0 generate

      SIM_GEN : if (ROGUE_SIM_EN_G) generate

         U_Rogue : entity surf.RoguePgp4Sim
            generic map(
               TPD_G      => TPD_G,
               PORT_NUM_G => (ROGUE_SIM_PORT_NUM_G+(i*34)),
               NUM_VC_G   => 4)
            port map(
               -- GT Ports
               pgpRefClk       => gtRefClk,
               pgpGtTxP        => qsfpTxP(i),
               pgpGtTxN        => qsfpTxN(i),
               pgpGtRxP        => qsfpRxP(i),
               pgpGtRxN        => qsfpRxN(i),
               -- Non VC Rx Signals
               pgpRxIn         => pgpRxIn(i),
               pgpRxOut        => pgpRxOut(i),
               -- Non VC Tx Signals
               pgpTxIn         => pgpTxIn(i),
               pgpTxOut        => pgpTxOut(i),
               -- Frame Transmit Interface
               pgpTxMasters(0) => pgpTxMasters(i, 0), -- (lane, VC)
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
               pgpRxSlaves(0)  => pgpRxSlaves(i, 0),
               pgpRxSlaves(1)  => pgpRxSlaves(i, 1),
               pgpRxSlaves(2)  => pgpRxSlaves(i, 2),
               pgpRxSlaves(3)  => pgpRxSlaves(i, 3),
               -- AXI-Lite Register Interface (axilClk domain)
               axilClk         => sysClk,
               axilRst         => sysRst,
               axilReadMaster  => axilReadMasters(i),
               axilReadSlave   => axilReadSlaves(i),
               axilWriteMaster => axilWriteMasters(i),
               axilWriteSlave  => axilWriteSlaves(i));

         pgpRst(i)  <= sysRst;
         pgpClk(i)  <= sysClk;
         qpllRst(i) <= sysRst&sysRst;

      end generate SIM_GEN;

      HW_GEN : if (not ROGUE_SIM_EN_G) generate

         U_PGP : entity surf.Pgp4GthUs
            generic map (
               TPD_G            => TPD_G,
               RATE_G           => RATE_G,
               EN_PGP_MON_G     => true,
               NUM_VC_G         => 4,
               AXIL_CLK_FREQ_G  => SYSCLK_FREQ_C,
               AXIL_BASE_ADDR_G => AXIL_CONFIG_C(i).baseAddr)
            port map (
               -- GT Clocking
               stableClk       => sysClk,
               stableRst       => sysRst,
               -- QPLL Interface
               qpllLock        => qpllLock(i),
               qpllClk         => qpllClk(i),
               qpllRefclk      => qpllRefclk(i),
               qpllRst         => qpllRst(i),
               -- Gt Serial IO
               pgpGtTxP        => qsfpTxP(i),
               pgpGtTxN        => qsfpTxN(i),
               pgpGtRxP        => qsfpRxP(i),
               pgpGtRxN        => qsfpRxN(i),
               -- Clocking
               pgpClk          => pgpClk(i),
               pgpClkRst       => pgpRst(i),
               -- Non VC Rx Signals
               pgpRxIn         => PGP4_RX_IN_INIT_C,
               pgpRxOut        => pgpRxOut(i),
               -- Non VC Tx Signals
               pgpTxIn         => PGP4_TX_IN_INIT_C,
               pgpTxOut        => open,
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
               pgpRxCtrl(3)    => pgpRxCtrl(i, 3),
               -- AXI-Lite Register Interface (axilClk domain)
               axilClk         => sysClk,
               axilRst         => sysRst,
               axilReadMaster  => axilReadMasters(i),
               axilReadSlave   => axilReadSlaves(i),
               axilWriteMaster => axilWriteMasters(i),
               axilWriteSlave  => axilWriteSlaves(i));

      end generate HW_GEN;

      U_Vc1 : entity surf.AxiStreamFifoV2
         generic map (
            TPD_G               => TPD_G,
            GEN_SYNC_FIFO_G     => false,
            FIFO_ADDR_WIDTH_G   => 9,
            SLAVE_AXI_CONFIG_G  => COMM_AXIS_CONFIG_C,
            MASTER_AXI_CONFIG_G => PGP4_AXIS_CONFIG_C)
         port map (
            -- Slave Port
            sAxisClk    => sysClk,
            sAxisRst    => sysRst,
            sAxisMaster => sAxisMasters(i),
            sAxisSlave  => sAxisSlaves(i),
            -- Master Port
            mAxisClk    => pgpClk(i),
            mAxisRst    => pgpRst(i),
            mAxisMaster => pgpTxMasters(i, 1),
            mAxisSlave  => pgpTxSlaves(i, 1));

      -- Check for Lane=0
      GEN_LANE0 : if (i = 0) generate

         -- VC0 RX/TX, SRPv3 Register Module
         U_SRPv3 : entity surf.SrpV3AxiLite
            generic map (
               TPD_G               => TPD_G,
               SLAVE_READY_EN_G    => ROGUE_SIM_EN_G,
               GEN_SYNC_FIFO_G     => false,
               AXI_STREAM_CONFIG_G => PGP4_AXIS_CONFIG_C)
            port map (
               -- Streaming Slave (Rx) Interface (sAxisClk domain)
               sAxisClk         => pgpClk(i),
               sAxisRst         => pgpRst(i),
               sAxisMaster      => pgpRxMasters(0, 0), -- (Lane, VC)
               sAxisCtrl        => pgpRxCtrl(0, 0),
               sAxisSlave       => pgpRxSlaves(0, 0),
               -- Streaming Master (Tx) Data Interface (mAxisClk domain)
               mAxisClk         => pgpClk(i),
               mAxisRst         => pgpRst(i),
               mAxisMaster      => pgpTxMasters(0, 0),
               mAxisSlave       => pgpTxSlaves(0, 0),
               -- Master AXI-Lite Interface (axilClk domain)
               axilClk          => sysClk,
               axilRst          => sysRst,
               mAxilReadMaster  => mAxilReadMaster,
               mAxilReadSlave   => mAxilReadSlave,
               mAxilWriteMaster => mAxilWriteMaster,
               mAxilWriteSlave  => mAxilWriteSlave);

         U_Vc1SsiCmdMaster : entity surf.SsiCmdMaster
            generic map (
               TPD_G               => TPD_G,
               AXI_STREAM_CONFIG_G => PGP4_AXIS_CONFIG_C,
               SLAVE_READY_EN_G    => ROGUE_SIM_EN_G)
            port map (
               -- Streaming Data Interface
               axisClk     => pgpClk(i),
               axisRst     => pgpRst(i),
               sAxisMaster => pgpRxMasters(0, 1),
               sAxisSlave  => pgpRxSlaves(0, 1),
               sAxisCtrl   => pgpRxCtrl(0, 1),
               -- Command signals
               cmdClk      => sysClk,
               cmdRst      => sysRst,
               cmdMaster   => ssiCmd);

         -- VC2, Microblaze/PSCOPE AXI Streaming Interface
         U_Vc2 : entity surf.AxiStreamFifoV2
            generic map (
               TPD_G               => TPD_G,
               GEN_SYNC_FIFO_G     => false,
               FIFO_ADDR_WIDTH_G   => 9,
               SLAVE_AXI_CONFIG_G  => ssiAxiStreamConfig(4),
               MASTER_AXI_CONFIG_G => PGP4_AXIS_CONFIG_C)
            port map (
               -- Slave Port
               sAxisClk    => sysClk,
               sAxisRst    => sysRst,
               sAxisMaster => outMuxTxMaster,
               sAxisSlave  => outMuxTxSlave,
               -- Master Port
               mAxisClk    => pgpClk(i),
               mAxisRst    => pgpRst(i),
               mAxisMaster => pgpTxMasters(0, 2),
               mAxisSlave  => pgpTxSlaves(0, 2));

         -- VC2_in_mb, Microblaze/PSCOPE AXI Streaming Interface
         U_Vc2_mb : entity surf.AxiStreamFifoV2
            generic map (
               TPD_G               => TPD_G,
               GEN_SYNC_FIFO_G     => false,
               FIFO_ADDR_WIDTH_G   => 9,
               SLAVE_AXI_CONFIG_G  => ssiAxiStreamConfig(4),
               MASTER_AXI_CONFIG_G => PGP4_AXIS_CONFIG_C)
            port map (
               -- Slave Port
               sAxisClk    => sysClk,
               sAxisRst    => sysRst,
               sAxisMaster => mbTxMaster,
               sAxisSlave  => mbTxSlave,
               -- Master Port
               mAxisClk    => pgpClk(i),
               mAxisRst    => pgpRst(i),
               mAxisMaster => inMuxTxMaster(0),
               mAxisSlave  => inMuxTxSlave(0));

         -- VC2, Microblaze/PSCOPE AXI Streaming Interface
         U_Vc2_ps : entity surf.AxiStreamFifoV2
            generic map (
               TPD_G               => TPD_G,
               GEN_SYNC_FIFO_G     => false,
               FIFO_ADDR_WIDTH_G   => 9,
               SLAVE_AXI_CONFIG_G  => ssiAxiStreamConfig(4),
               MASTER_AXI_CONFIG_G => PGP4_AXIS_CONFIG_C)
            port map (
               -- Slave Port
               sAxisClk    => sysClk,
               sAxisRst    => sysRst,
               sAxisMaster => psTxMaster,
               sAxisSlave  => psTxSlave,
               -- Master Port
               mAxisClk    => pgpClk(i),
               mAxisRst    => pgpRst(i),
               mAxisMaster => inMuxTxMaster(1),
               mAxisSlave  => inMuxTxSlave(1));

         -- VC2, axiStream mux for Microblaze/PSCOPE AXI Streaming Interface
         U_Vc2_mux : entity surf.AxiStreamMux
            generic map(
               TPD_G                => TPD_G,
               NUM_SLAVES_G         => 2,
               PIPE_STAGES_G        => 0,
               TDEST_LOW_G          => 0,  -- LSB of updated tdest for INDEX
               ILEAVE_EN_G          => false,  -- Set to true if interleaving dests, arbitrate on gaps
               ILEAVE_ON_NOTVALID_G => false,  -- Rearbitrate when tValid drops on selected channel
               ILEAVE_REARB_G       => 0)  -- Max number of transactions between arbitrations, 0 = unlimited
            port map(
               -- Clock and reset
               axisClk      => sysClk,
               axisRst      => sysRst,
               -- Slaves
               sAxisMasters => inMuxTxMaster,
               sAxisSlaves  => inMuxTxSlave,
               -- Master
               mAxisMaster  => outMuxTxMaster,
               mAxisSlave   => outMuxTxSlave);

         -- VC3, Monitoring AXI Streaming Interface
         U_Vc3 : entity surf.AxiStreamFifoV2
            generic map (
               TPD_G               => TPD_G,
               GEN_SYNC_FIFO_G     => false,
               FIFO_ADDR_WIDTH_G   => 9,
               SLAVE_AXI_CONFIG_G  => ssiAxiStreamConfig(4),
               MASTER_AXI_CONFIG_G => PGP4_AXIS_CONFIG_C)
            port map (
               -- Slave Port
               sAxisClk    => sysClk,
               sAxisRst    => sysRst,
               sAxisMaster => monTxMaster,
               sAxisSlave  => monTxSlave,
               -- Master Port
               mAxisClk    => pgpClk(i),
               mAxisRst    => pgpRst(i),
               mAxisMaster => pgpTxMasters(0, 3),
               mAxisSlave  => pgpTxSlaves(0, 3));

      end generate;

   end generate PGP_LANE;

   -----------------------------
   -- XVC Wrapper (non-sim only)
   -----------------------------
   -- lane=1, VC=3
   U_XVC_WRAPPER: entity surf.PgpXvcWrapper
      generic map(
         TPD_G            => TPD_G,
         SIMULATION_G     => ROGUE_SIM_EN_G,
         PHY_AXI_CONFIG_G => PGP4_AXIS_CONFIG_C)
      port map(
         -- Clock and Reset (axisClk domain)
         axilClk     => sysClk,
         axilRst     => sysRst,
         -- Clock and Reset (pgpClk domain)
         pgpClk      => pgpClk(1),
         pgpRst      => pgpRst(1),
         -- PGP Interface (pgpClk domain)
         rxlinkReady => pgpRxOut(1).linkReady,
         txlinkReady => pgpTxOut(1).linkReady,
         -- TX FIFO
         pgpTxSlave  => pgpTxSlaves(1, 3),
         pgpTxMaster => pgpTxMasters(1, 3),
         -- RX FIFO
         pgpRxMaster => pgpRxMasters(1, 3),
         pgpRxCtrl   => pgpRxCtrl(1, 3),
         pgpRxSlave  => pgpRxSlaves(1, 3));

end mapping;
