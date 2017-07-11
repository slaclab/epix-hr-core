-------------------------------------------------------------------------------
-- File       : EpixHrCore.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-04-21
-- Last update: 2017-04-24
-------------------------------------------------------------------------------
-- Description: EpixHrCore Core's Top Level
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
use work.AxiPkg.all;
use work.EpixHrCorePkg.all;
use work.AxiI2cQsfpPkg.all;

library unisim;
use unisim.vcomponents.all;

entity EpixHrCore is
   generic (
      TPD_G            : time            := 1 ns;
      BUILD_INFO_G     : BuildInfoType;
      COMM_TYPE_G      : CommModeType    := COMM_MODE_PGP2B_C;
      ETH_DHCP_G       : boolean         := true;
      AXI_ERROR_RESP_G : slv(1 downto 0) := AXI_RESP_SLVERR_C);
   port (
      ----------------------
      -- Top Level Interface
      ----------------------
      -- System Clock and Reset
      sysClk           : out   sl;
      sysRst           : out   sl;
      -- AXI-Lite Register Interface (sysClk domain)
      -- Register Address Range = [0x80000000:0xFFFFFFFF]
      mAxilReadMaster  : out   AxiLiteReadMasterType;
      mAxilReadSlave   : in    AxiLiteReadSlaveType;
      mAxilWriteMaster : out   AxiLiteWriteMasterType;
      mAxilWriteSlave  : in    AxiLiteWriteSlaveType;
      -- AXI Stream, one per QSFP lane (sysClk domain)
      sAxisMasters     : in    AxiStreamMasterArray(3 downto 0);
      sAxisSlaves      : out   AxiStreamSlaveArray(3 downto 0);
      -- DDR's AXI Memory Interface (sysClk domain)
      -- DDR Address Range = [0x00000000:0x3FFFFFFF]
      sAxiReadMaster   : in    AxiReadMasterType;
      sAxiReadSlave    : out   AxiReadSlaveType;
      sAxiWriteMaster  : in    AxiWriteMasterType;
      sAxiWriteSlave   : out   AxiWriteSlaveType;
      -- Microblaze's Interrupt bus (sysClk domain)
      mbIrq            : in    slv(7 downto 0);
      ----------------
      -- Core Ports --
      ----------------   
      -- Board IDs Ports
      snIoAdcCard      : inout sl;
      snIoCarrier      : inout sl;
      -- QSFP Ports
      qsfpRxP          : in    slv(3 downto 0);
      qsfpRxN          : in    slv(3 downto 0);
      qsfpTxP          : out   slv(3 downto 0);
      qsfpTxN          : out   slv(3 downto 0);
      qsfpClkP         : in    sl;
      qsfpClkN         : in    sl;
      qsfpLpMode       : inout sl;
      qsfpModSel       : inout sl;
      qsfpInitL        : inout sl;
      qsfpRstL         : inout sl;
      qsfpPrstL        : inout sl;
      qsfpScl          : inout sl;
      qsfpSda          : inout sl;
      -- DDR Ports
      ddrClkP          : in    sl;
      ddrClkN          : in    sl;
      ddrBg            : out   sl;
      ddrCkP           : out   sl;
      ddrCkN           : out   sl;
      ddrCke           : out   sl;
      ddrCsL           : out   sl;
      ddrOdt           : out   sl;
      ddrAct           : out   sl;
      ddrRstL          : out   sl;
      ddrA             : out   slv(16 downto 0);
      ddrBa            : out   slv(1 downto 0);
      ddrDm            : inout slv(3 downto 0);
      ddrDq            : inout slv(31 downto 0);
      ddrDqsP          : inout slv(3 downto 0);
      ddrDqsN          : inout slv(3 downto 0);
      ddrPg            : in    sl;
      ddrPwrEn         : out   sl;
      -- SYSMON Ports
      vPIn             : in    sl;
      vNIn             : in    sl);
end EpixHrCore;

architecture mapping of EpixHrCore is

   constant NUM_AXI_MASTERS_C : natural := 7;

   constant VERSION_INDEX_C  : natural := 0;
   constant SYSMON_INDEX_C   : natural := 1;
   constant BOOT_MEM_INDEX_C : natural := 2;
   constant QSFP_I2C_INDEX_C : natural := 3;
   constant DDR_MEM_INDEX_C  : natural := 4;
   constant COMM_INDEX_C     : natural := 5;
   constant APP_INDEX_C      : natural := 6;

   constant AXI_CROSSBAR_MASTERS_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXI_MASTERS_C-1 downto 0) := (
      VERSION_INDEX_C  => (
         baseAddr      => x"00000000",
         addrBits      => 24,
         connectivity  => x"FFFF"),
      SYSMON_INDEX_C   => (
         baseAddr      => x"01000000",
         addrBits      => 24,
         connectivity  => x"FFFF"),
      BOOT_MEM_INDEX_C => (
         baseAddr      => x"02000000",
         addrBits      => 24,
         connectivity  => x"FFFF"),
      QSFP_I2C_INDEX_C => (
         baseAddr      => x"03000000",
         addrBits      => 24,
         connectivity  => x"FFFF"),
      DDR_MEM_INDEX_C  => (
         baseAddr      => x"04000000",
         addrBits      => 24,
         connectivity  => x"FFFF"),
      COMM_INDEX_C     => (
         baseAddr      => x"05000000",
         addrBits      => 24,
         connectivity  => x"FFFF"),
      APP_INDEX_C      => (
         baseAddr      => x"80000000",
         addrBits      => 31,
         connectivity  => x"FFFF"));

   constant EXT_CROSSBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(0 downto 0) := (
      0               => (
         baseAddr     => AXI_CROSSBAR_MASTERS_CONFIG_C(APP_INDEX_C).baseAddr,
         addrBits     => AXI_CROSSBAR_MASTERS_CONFIG_C(APP_INDEX_C).addrBits,
         connectivity => AXI_CROSSBAR_MASTERS_CONFIG_C(APP_INDEX_C).connectivity));

   signal axilWriteMaster : AxiLiteWriteMasterType;
   signal axilWriteSlave  : AxiLiteWriteSlaveType;
   signal axilReadSlave   : AxiLiteReadSlaveType;
   signal axilReadMaster  : AxiLiteReadMasterType;

   signal mbWriteMaster : AxiLiteWriteMasterType;
   signal mbWriteSlave  : AxiLiteWriteSlaveType;
   signal mbReadSlave   : AxiLiteReadSlaveType;
   signal mbReadMaster  : AxiLiteReadMasterType;

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXI_MASTERS_C-1 downto 0);

   signal mbTxMaster : AxiStreamMasterType;
   signal mbTxSlave  : AxiStreamSlaveType;

   signal userValues : Slv32Array(0 to 63) := (others => x"0000_0000");

   signal clk  : sl;
   signal rst  : sl;
   signal rstL : sl;

   signal bootCsL  : sl;
   signal bootSck  : sl;
   signal bootMosi : sl;
   signal bootMiso : sl;
   signal di       : slv(3 downto 0);
   signal do       : slv(3 downto 0);

   signal snCarrier : slv(63 downto 0);
   signal snAdcCard : slv(63 downto 0);

begin

   sysClk <= clk;
   sysRst <= rst;

   ---------------------
   -- QSFP Communication
   ---------------------
   U_Comm : entity work.EpixHrComm
      generic map (
         TPD_G            => TPD_G,
         COMM_TYPE_G      => COMM_TYPE_G,
         ETH_DHCP_G       => ETH_DHCP_G,
         AXI_BASE_ADDR_G  => AXI_CROSSBAR_MASTERS_CONFIG_C(COMM_INDEX_C).baseAddr,
         AXI_ERROR_RESP_G => AXI_ERROR_RESP_G)
      port map (
         -- Debug AXI-Lite Interface
         axilReadMaster   => axilReadMasters(COMM_INDEX_C),
         axilReadSlave    => axilReadSlaves(COMM_INDEX_C),
         axilWriteMaster  => axilWriteMasters(COMM_INDEX_C),
         axilWriteSlave   => axilWriteSlaves(COMM_INDEX_C),
         -- Microblaze Streaming Interface
         mbTxMaster       => mbTxMaster,
         mbTxSlave        => mbTxSlave,
         ----------------------
         -- Top Level Interface
         ----------------------
         -- System Clock and Reset
         sysClk           => clk,
         sysRst           => rst,
         -- AXI-Lite Register Interface (sysClk domain)
         -- Register Address Range = [0x80000000:0xFFFFFFFF]
         mAxilReadMaster  => axilReadMaster,
         mAxilReadSlave   => axilReadSlave,
         mAxilWriteMaster => axilWriteMaster,
         mAxilWriteSlave  => axilWriteSlave,
         -- AXI Stream, one per QSFP lane (sysClk domain)
         sAxisMasters     => sAxisMasters,
         sAxisSlaves      => sAxisSlaves,
         ----------------
         -- Core Ports --
         ----------------   
         -- QSFP Ports
         qsfpRxP          => qsfpRxP,
         qsfpRxN          => qsfpRxN,
         qsfpTxP          => qsfpTxP,
         qsfpTxN          => qsfpTxN,
         qsfpClkP         => qsfpClkP,
         qsfpClkN         => qsfpClkN);

   ---------------------------
   -- 1-bit Serial Number ROMs
   ---------------------------
   U_snCarrier : entity work.DS2411Core
      generic map (
         TPD_G        => TPD_G,
         CLK_PERIOD_G => SYSCLK_PERIOD_C)
      port map (
         clk       => clk,
         rst       => rst,
         fdSerSdio => snIoCarrier,
         fdValue   => snCarrier);

   U_snAdcCard : entity work.DS2411Core
      generic map (
         TPD_G        => TPD_G,
         CLK_PERIOD_G => SYSCLK_PERIOD_C)
      port map (
         clk       => clk,
         rst       => rst,
         fdSerSdio => snIoAdcCard,
         fdValue   => snAdcCard);

   userValues(0) <= snCarrier(31 downto 0);
   userValues(1) <= snCarrier(63 downto 32);
   userValues(2) <= snAdcCard(31 downto 0);
   userValues(3) <= snAdcCard(63 downto 32);

   ------------------------------
   -- AXI-Lite: Internal Crossbar
   ------------------------------
   U_XBAR0 : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         DEC_ERROR_RESP_G   => AXI_ERROR_RESP_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_AXI_MASTERS_C,
         MASTERS_CONFIG_G   => AXI_CROSSBAR_MASTERS_CONFIG_C)
      port map (
         axiClk              => clk,
         axiClkRst           => rst,
         sAxiWriteMasters(0) => axilWriteMaster,
         sAxiWriteSlaves(0)  => axilWriteSlave,
         sAxiReadMasters(0)  => axilReadMaster,
         sAxiReadSlaves(0)   => axilReadSlave,
         mAxiWriteMasters    => axilWriteMasters,
         mAxiWriteSlaves     => axilWriteSlaves,
         mAxiReadMasters     => axilReadMasters,
         mAxiReadSlaves      => axilReadSlaves);

   --------------------------
   -- AXI-Lite Version Module
   --------------------------
   U_Version : entity work.AxiVersion
      generic map (
         TPD_G            => TPD_G,
         BUILD_INFO_G     => BUILD_INFO_G,
         AXI_ERROR_RESP_G => AXI_ERROR_RESP_G,
         CLK_PERIOD_G     => SYSCLK_PERIOD_C,
         XIL_DEVICE_G     => "ULTRASCALE",
         EN_DEVICE_DNA_G  => true)
      port map (
         -- AXI-Lite Interface
         axiClk         => clk,
         axiRst         => rst,
         userValues     => userValues,
         axiReadMaster  => axilReadMasters(VERSION_INDEX_C),
         axiReadSlave   => axilReadSlaves(VERSION_INDEX_C),
         axiWriteMaster => axilWriteMasters(VERSION_INDEX_C),
         axiWriteSlave  => axilWriteSlaves(VERSION_INDEX_C));

   --------------------------
   -- AXI-Lite: SYSMON Module
   --------------------------
   U_SysMon : entity work.EpixHrSysMon
      generic map (
         TPD_G            => TPD_G,
         AXI_ERROR_RESP_G => AXI_ERROR_RESP_G)
      port map (
         -- SYSMON Ports
         vPIn            => vPIn,
         vNIn            => vNIn,
         -- AXI-Lite Register Interface
         axilReadMaster  => axilReadMasters(SYSMON_INDEX_C),
         axilReadSlave   => axilReadSlaves(SYSMON_INDEX_C),
         axilWriteMaster => axilWriteMasters(SYSMON_INDEX_C),
         axilWriteSlave  => axilWriteSlaves(SYSMON_INDEX_C),
         -- Clocks and Resets
         axilClk         => clk,
         axilRst         => rst);

   ------------------------------
   -- AXI-Lite: Boot Flash Module
   ------------------------------
   U_BootProm : entity work.AxiMicronN25QCore
      generic map (
         TPD_G            => TPD_G,
         AXI_ERROR_RESP_G => AXI_ERROR_RESP_G,
         MEM_ADDR_MASK_G  => x"00000000",  -- Using hardware write protection
         AXI_CLK_FREQ_G   => SYSCLK_FREQ_C,        -- units of Hz
         SPI_CLK_FREQ_G   => (SYSCLK_FREQ_C/4.0))  -- units of Hz
      port map (
         -- FLASH Memory Ports
         csL            => bootCsL,
         sck            => bootSck,
         mosi           => bootMosi,
         miso           => bootMiso,
         -- AXI-Lite Register Interface
         axiReadMaster  => axilReadMasters(BOOT_MEM_INDEX_C),
         axiReadSlave   => axilReadSlaves(BOOT_MEM_INDEX_C),
         axiWriteMaster => axilWriteMasters(BOOT_MEM_INDEX_C),
         axiWriteSlave  => axilWriteSlaves(BOOT_MEM_INDEX_C),
         -- Clocks and Resets
         axiClk         => clk,
         axiRst         => rst);

   U_STARTUPE3 : STARTUPE3
      generic map (
         PROG_USR      => "FALSE",  -- Activate program event security feature. Requires encrypted bitstreams.
         SIM_CCLK_FREQ => 0.0)  -- Set the Configuration Clock Frequency(ns) for simulation
      port map (
         CFGCLK    => open,  -- 1-bit output: Configuration main clock output
         CFGMCLK   => open,  -- 1-bit output: Configuration internal oscillator clock output
         DI        => di,  -- 4-bit output: Allow receiving on the D[3:0] input pins
         EOS       => open,  -- 1-bit output: Active high output signal indicating the End Of Startup.
         PREQ      => open,  -- 1-bit output: PROGRAM request to fabric output
         DO        => do,  -- 4-bit input: Allows control of the D[3:0] pin outputs
         DTS       => "1110",  -- 4-bit input: Allows tristate of the D[3:0] pins
         FCSBO     => bootCsL,  -- 1-bit input: Contols the FCS_B pin for flash access
         FCSBTS    => '0',              -- 1-bit input: Tristate the FCS_B pin
         GSR       => '0',  -- 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
         GTS       => '0',  -- 1-bit input: Global 3-state input (GTS cannot be used for the port name)
         KEYCLEARB => '0',  -- 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
         PACK      => '0',  -- 1-bit input: PROGRAM acknowledge input
         USRCCLKO  => bootSck,          -- 1-bit input: User CCLK input
         USRCCLKTS => '0',  -- 1-bit input: User CCLK 3-state enable input
         USRDONEO  => rstL,  -- 1-bit input: User DONE pin output control
         USRDONETS => '0');  -- 1-bit input: User DONE 3-state enable output

   rstL     <= not(rst);  -- IPMC uses DONE to determine if FPGA is ready
   do       <= "111" & bootMosi;
   bootMiso <= di(1);

   ----------------------
   -- AXI-Lite: QSF's I2C
   ----------------------
   U_QsfpI2c : entity work.AxiI2cQsfpCore
      generic map (
         TPD_G            => TPD_G,
         AXI_CLK_FREQ_G   => SYSCLK_FREQ_C,
         AXI_ERROR_RESP_G => AXI_ERROR_RESP_G)
      port map (
         -- QSFP Ports
         qsfpIn.modPrstL => qsfpPrstL,
         qsfpIn.intL     => qsfpInitL,
         qsfpInOut.scl   => qsfpScl,
         qsfpInOut.sda   => qsfpSda,
         qsfpOut.modSelL => qsfpModSel,
         qsfpOut.rstL    => qsfpRstL,
         qsfpOut.lpMode  => qsfpLpMode,
         -- AXI-Lite Register Interface
         axiReadMaster   => axilReadMasters(QSFP_I2C_INDEX_C),
         axiReadSlave    => axilReadSlaves(QSFP_I2C_INDEX_C),
         axiWriteMaster  => axilWriteMasters(QSFP_I2C_INDEX_C),
         axiWriteSlave   => axilWriteSlaves(QSFP_I2C_INDEX_C),
         -- Clocks and Resets
         axiClk          => clk,
         axiRst          => rst);

   -------------------------
   -- AXI-Lite: DDR MIG Core
   -------------------------
   U_DdrMem : entity work.EpixHrDdrMem
      generic map (
         TPD_G            => TPD_G,
         AXI_ERROR_RESP_G => AXI_ERROR_RESP_G)
      port map (
         clk             => clk,
         rst             => rst,
         -- AXI-Lite Interface
         axilReadMaster  => axilReadMasters(DDR_MEM_INDEX_C),
         axilReadSlave   => axilReadSlaves(DDR_MEM_INDEX_C),
         axilWriteMaster => axilWriteMasters(DDR_MEM_INDEX_C),
         axilWriteSlave  => axilWriteSlaves(DDR_MEM_INDEX_C),
         -- AXI4 Interface
         sAxiWriteMaster => sAxiWriteMaster,
         sAxiWriteSlave  => sAxiWriteSlave,
         sAxiReadMaster  => sAxiReadMaster,
         sAxiReadSlave   => sAxiReadSlave,
         ----------------
         -- Core Ports --
         ----------------   
         -- DDR Ports
         ddrClkP         => ddrClkP,
         ddrClkN         => ddrClkN,
         ddrBg           => ddrBg,
         ddrCkP          => ddrCkP,
         ddrCkN          => ddrCkN,
         ddrCke          => ddrCke,
         ddrCsL          => ddrCsL,
         ddrOdt          => ddrOdt,
         ddrAct          => ddrAct,
         ddrRstL         => ddrRstL,
         ddrA            => ddrA,
         ddrBa           => ddrBa,
         ddrDm           => ddrDm,
         ddrDq           => ddrDq,
         ddrDqsP         => ddrDqsP,
         ddrDqsN         => ddrDqsN,
         ddrPg           => ddrPg,
         ddrPwrEn        => ddrPwrEn);

   --------------------------------
   -- Microblaze Embedded Processor
   --------------------------------
   U_CPU : entity work.MicroblazeBasicCoreWrapper
      generic map (
         TPD_G           => TPD_G,
         AXIL_ADDR_MSB_C => true)       -- true = [0x80000000:0xFFFFFFFF]
      port map (
         -- Master AXI-Lite Interface: [0x80000000:0xFFFFFFFF]
         mAxilWriteMaster => mbWriteMaster,
         mAxilWriteSlave  => mbWriteSlave,
         mAxilReadMaster  => mbReadMaster,
         mAxilReadSlave   => mbReadSlave,
         -- Streaming
         mAxisMaster      => mbTxMaster,
         mAxisSlave       => mbTxSlave,
         -- IRQ
         interrupt        => mbIrq,
         -- Clock and Reset
         clk              => clk,
         rst              => rst);

   ------------------------------
   -- AXI-Lite: External Crossbar
   ------------------------------
   U_XBAR1 : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         DEC_ERROR_RESP_G   => AXI_ERROR_RESP_G,
         NUM_SLAVE_SLOTS_G  => 2,
         NUM_MASTER_SLOTS_G => 1,
         MASTERS_CONFIG_G   => EXT_CROSSBAR_CONFIG_C)
      port map (
         axiClk              => clk,
         axiClkRst           => rst,
         sAxiWriteMasters(0) => axilWriteMasters(APP_INDEX_C),
         sAxiWriteMasters(1) => mbWriteMaster,
         sAxiWriteSlaves(0)  => axilWriteSlaves(APP_INDEX_C),
         sAxiWriteSlaves(1)  => mbWriteSlave,
         sAxiReadMasters(0)  => axilReadMasters(APP_INDEX_C),
         sAxiReadMasters(1)  => mbReadMaster,
         sAxiReadSlaves(0)   => axilReadSlaves(APP_INDEX_C),
         sAxiReadSlaves(1)   => mbReadSlave,
         mAxiWriteMasters(0) => mAxilWriteMaster,
         mAxiWriteSlaves(0)  => mAxilWriteSlave,
         mAxiReadMasters(0)  => mAxilReadMaster,
         mAxiReadSlaves(0)   => mAxilReadSlave);

end mapping;