-------------------------------------------------------------------------------
-- File       : EpixHrComm.vhd
-- Company    : SLAC National Accelerator Laboratory
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

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;
use surf.SsiPkg.all;
use surf.SsiCmdMasterPkg.all;
use surf.Pgp2bPkg.all;

library epix_hr_core;
use epix_hr_core.EpixHrCorePkg.all;

library unisim;
use unisim.vcomponents.all;

entity EpixHrComm is
   generic (
      TPD_G            : time             := 1 ns;
      AXI_BASE_ADDR_G  : slv(31 downto 0) := (others => '0');
      SIMULATION_G     : boolean          := false;
      PORT_NUM_G       : natural range 1024 to 49151 := 11000);   
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
      sAxisMasters     : in  AxiStreamMasterArray(3 downto 0);
      sAxisSlaves      : out AxiStreamSlaveArray(3 downto 0);
      -- ssi commands (Lane and Vc 0)
      ssiCmd           : out SsiCmdMasterType;      
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
   signal pgpRxSlave   : AxiStreamSlaveVectorArray(0 to 7, 0 to 3)  := (others => (others => AXI_STREAM_SLAVE_FORCE_C));
   signal pgpRxCtrl    : AxiStreamCtrlVectorArray(0 to 7, 0 to 3)   := (others => (others => AXI_STREAM_CTRL_UNUSED_C));

   --lane 0, vc2 mux signals
   signal inMuxTxMaster       : AxiStreamMasterArray(1 downto 0);
   signal inMuxTxSlave        : AxiStreamSlaveArray(1 downto 0);
   signal outMuxTxMaster      : AxiStreamMasterType;
   signal outMuxTxSlave       : AxiStreamSlaveType;   
   
begin

   U_XBAR : entity surf.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
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

      U_PGP : entity epix_hr_core.EpixHrPgp2bGthUltra
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

      U_PgpMon : entity surf.Pgp2bAxi
         generic map (
            TPD_G              => TPD_G,
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

      U_Vc0 : entity surf.AxiStreamFifoV2
         generic map (
            CASCADE_SIZE_G      => 1,
            MEMORY_TYPE_G       => "block",
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
         U_SRPv3 : entity surf.SrpV3AxiLite
            generic map (
               TPD_G               => TPD_G,
               SLAVE_READY_EN_G    => SIMULATION_G,
               GEN_SYNC_FIFO_G     => true,
               AXI_STREAM_CONFIG_G => SSI_PGP2B_CONFIG_C)
            port map (
               -- Streaming Slave (Rx) Interface (sAxisClk domain) 
               sAxisClk         => sysClk,
               sAxisRst         => sysRst,
               sAxisMaster      => pgpRxMasters(0, 1),
               sAxisCtrl        => pgpRxCtrl(0, 1),
               sAxisSlave       => pgpRxSlave(0,1),
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
               
         U_Vc0SsiCmdMaster : entity surf.SsiCmdMaster
           generic map (
             AXI_STREAM_CONFIG_G => SSI_PGP2B_CONFIG_C,
             SLAVE_READY_EN_G    => SIMULATION_G)   
           port map (
             -- Streaming Data Interface
             axisClk     => sysClk,
             axisRst     => sysRst,
             sAxisMaster => pgpRxMasters(0, 0),
             sAxisSlave  => pgpRxSlave(0,0),
             sAxisCtrl   => pgpRxCtrl(0, 0),
             -- Command signals
             cmdClk      => sysClk,
             cmdRst      => sysRst,
             cmdMaster   => ssiCmd
             );                 

         -- VC2, Microblaze AXI Streaming Interface
         U_Vc2 : entity surf.AxiStreamFifoV2
            generic map (
               CASCADE_SIZE_G      => 1,
               MEMORY_TYPE_G       => "block",
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
               sAxisMaster => outMuxTxMaster,
               sAxisSlave  => outMuxTxSlave,
               -- Master Port
               mAxisClk    => sysClk,
               mAxisRst    => sysRst,
               mAxisMaster => pgpTxMasters(0, 2),
               mAxisSlave  => pgpTxSlaves(0, 2));
               
         -- VC2_in_mb, Microblaze/PSCOPE AXI Streaming Interface
         U_Vc2_mb : entity surf.AxiStreamFifoV2
            generic map (
               TPD_G               => TPD_G,
               CASCADE_SIZE_G      => 1,
               MEMORY_TYPE_G       => "block",
               GEN_SYNC_FIFO_G     => false,
               FIFO_ADDR_WIDTH_G   => 9,
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
               mAxisMaster => inMuxTxMaster(0),
               mAxisSlave  => inMuxTxSlave(0));

         -- VC2, Microblaze/PSCOPE AXI Streaming Interface
         U_Vc2_ps : entity surf.AxiStreamFifoV2
            generic map (
               TPD_G               => TPD_G,
               CASCADE_SIZE_G      => 1,
               MEMORY_TYPE_G       => "block",
               GEN_SYNC_FIFO_G     => false,
               FIFO_ADDR_WIDTH_G   => 9,
               SLAVE_AXI_CONFIG_G  => ssiAxiStreamConfig(4),
               MASTER_AXI_CONFIG_G => SSI_PGP2B_CONFIG_C)
            port map (
               -- Slave Port
               sAxisClk    => sysClk,
               sAxisRst    => sysRst,
               sAxisMaster => psTxMaster,
               sAxisSlave  => psTxSlave,
               -- Master Port
               mAxisClk    => sysClk,
               mAxisRst    => sysRst,
               mAxisMaster => inMuxTxMaster(1),
               mAxisSlave  => inMuxTxSlave(1));               

         -- VC2, axiStream mux for Microblaze/PSCOPE AXI Streaming Interface
         U_Vc2_mux : entity surf.AxiStreamMux 
           generic map(
             TPD_G                => TPD_G,
             NUM_SLAVES_G         => 2,
             PIPE_STAGES_G        => 0,
             TDEST_LOW_G          => 0,      -- LSB of updated tdest for INDEX
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
               CASCADE_SIZE_G      => 1,
               MEMORY_TYPE_G       => "block",
               GEN_SYNC_FIFO_G     => false,
               FIFO_ADDR_WIDTH_G   => 9,
               SLAVE_AXI_CONFIG_G  => ssiAxiStreamConfig(4),
               MASTER_AXI_CONFIG_G => SSI_PGP2B_CONFIG_C)
            port map (
               -- Slave Port
               sAxisClk    => sysClk,
               sAxisRst    => sysRst,
               sAxisMaster => monTxMaster,
               sAxisSlave  => monTxSlave,
               -- Master Port
               mAxisClk    => sysClk,
               mAxisRst    => sysRst,
               mAxisMaster => pgpTxMasters(0, 3),
               mAxisSlave  => pgpTxSlaves(0, 3));           
               
      end generate;

   end generate PGP_LANE;

end mapping;
