-------------------------------------------------------------------------------
-- File       : TrigControlAxi.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- History : 2023/7/27  Added the generation of a designated
--                      number of triggers by Dawood
-------------------------------------------------------------------------------
-- This file is part of 'EPIX HR Firmware'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'EPIX HR Firmware', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.SsiCmdMasterPkg.all;
use surf.Pgp2bPkg.all;

library epix_hr_core;

entity TrigControlAxi is
   generic (
      TPD_G              : time             := 1 ns;
      AXIL_ERR_RESP_G    : slv(1 downto 0)  := AXI_RESP_DECERR_C;
      PULSE_WIDTH_G      : positive         := 2
   );
   port (
      -- Trigger outputs
      appClk            : in  sl;
      appRst            : in  sl;
      acqStart          : out sl;
      dataSend          : out sl;
      
      -- External trigger inputs
      runTrigger        : in  sl;
      daqTrigger        : in  sl;
      
      -- PGP clocks and reset
      sysClk            : in  sl;
      sysRst            : in  sl;
      -- Software trigger
      ssiCmd            : in  SsiCmdMasterType;
      -- Fiber optic trigger
      pgpRxOut          : in  Pgp2bRxOutType;
      -- Fiducial code output
      opCodeOut         : out slv(7 downto 0);

      -- Timing Triggers
      timingRunTrigger  : in sl := '0';
      timingDaqTrigger  : in sl := '0';

      -- AXI lite slave port for register access
      axilClk           : in  sl;
      axilRst           : in  sl;
      sAxilWriteMaster  : in  AxiLiteWriteMasterType;
      sAxilWriteSlave   : out AxiLiteWriteSlaveType;
      sAxilReadMaster   : in  AxiLiteReadMasterType;
      sAxilReadSlave    : out AxiLiteReadSlaveType;

      -- Pause signal monitor
      runTrigPause     : in sl  := '0';
      daqTrigPause     : in sl  := '0';

      forceTrigger     : in sl  := '0'
   );

end TrigControlAxi;

architecture rtl of TrigControlAxi is


   type TriggerType is record
      runTriggerEnable    : sl;
      daqTriggerEnable    : sl;
      pgpTrigEn           : sl;
      autoRunEn           : sl;
      autoDaqEn           : sl;
      timingRunEn         : sl;
      timingDaqEn         : sl;
      acqCountReset       : sl;
      numTriggers         : slv(31 downto 0);
      runTriggerDelay     : slv(31 downto 0);
      daqTriggerDelay     : slv(31 downto 0);
      autoTrigPeriod      : slv(31 downto 0);
      daqPauseEn          : sl;
      numTriggersType     : sl;
      daqPauseCycleCntMin : slv(31 downto 0);
      daqPauseCycleCntMax : slv(31 downto 0);
      daqPauseCycleCntr   : slv(31 downto 0);   
      iDaqTrigPauseR1     : sl;
      iDaqTrigPauseR2     : sl;
      daqEvery            : slv(31 downto 0);   
   end record TriggerType;

   constant TRIGGER_INIT_C : TriggerType := (
      runTriggerEnable    => '0',
      daqTriggerEnable    => '0',
      pgpTrigEn           => '0',
      autoRunEn           => '0',
      autoDaqEn           => '0',
      timingRunEn         => '0',
      timingDaqEn         => '0',
      acqCountReset       => '0',
      numTriggers         => (others=>'0'),
      runTriggerDelay     => (others=>'0'),
      daqTriggerDelay     => (others=>'0'),
      autoTrigPeriod      => (others=>'0'),
      daqPauseEn          => '0',
      numTriggersType     => '0',
      daqPauseCycleCntMin => (others=>'1'),
      daqPauseCycleCntMax => (others=>'0'),
      daqPauseCycleCntr   => (others=>'0'), 
      iDaqTrigPauseR1     => '0',
      iDaqTrigPauseR2     => '0',
      daqEvery            => (others=>'0')
   );

   type RegType is record
      trig              : TriggerType;
      sAxilWriteSlave   : AxiLiteWriteSlaveType;
      sAxilReadSlave    : AxiLiteReadSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      trig              => TRIGGER_INIT_C,
      sAxilWriteSlave   => AXI_LITE_WRITE_SLAVE_INIT_C,
      sAxilReadSlave    => AXI_LITE_READ_SLAVE_INIT_C
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal coreSidebandRun : sl;
   signal coreSidebandDaq : sl;
   signal combinedRunTrig : sl;
   signal combinedDaqTrig : sl;

   signal runTriggerEdge    : std_logic;
   signal daqTriggerEdge    : std_logic;
   signal runTriggerCnt     : std_logic_vector(31 downto 0);
   signal daqTriggerCnt     : std_logic_vector(31 downto 0);
   signal runTriggerOut     : std_logic;
   signal daqTriggerOut     : std_logic;
   signal countEnable       : std_logic;
   signal daqCountEnable    : std_logic;
   signal acqCount          : std_logic_vector(31 downto 0);
   signal daqCount          : std_logic_vector(31 downto 0);
   signal runPauseCnt       : std_logic_vector(31 downto 0);
   signal daqPauseCnt       : std_logic_vector(31 downto 0);  
   signal runPauseCntSync   : std_logic_vector(31 downto 0);
   signal daqPauseCntSync   : std_logic_vector(31 downto 0);     
   signal acqCountSync      : std_logic_vector(31 downto 0);
   signal daqCountSync      : std_logic_vector(31 downto 0);
   signal swRun             : std_logic;
   signal swRunSync         : std_logic;
   signal forceTrigSync     : std_logic;
   signal swRead            : std_logic;
   signal iRunTrigOut       : std_logic;
   signal iDaqTrigOut       : std_logic;
   signal hwRunTrig         : std_logic;
   signal hwDaqTrig         : std_logic;
   signal autoRunEn         : std_logic;
   signal autoDaqEn         : std_logic;
   
   signal forceRead         : std_logic;


   -- Op code signals
   signal syncOpCode : slv(7 downto 0) := (others => '0');
   
   signal trigSync : TriggerType;
   signal daqTrigPauseSync     : std_logic;
   signal runTrigPauseEdgeSync : std_logic;
   signal daqTrigPauseEdgeSync : std_logic;   
   signal iDaqTrigPause        : std_logic;
   signal daqTrigPauseAxiSync  : std_logic;   
begin

   -----------------------------------
   -- SW Triggers:
   --   Run trigger is opCode x00
   --   DAQ trigger trails by 1 clock
   -----------------------------------
   U_TrigPulser : entity surf.SsiCmdMasterPulser
   generic map (
      OUT_POLARITY_G => '1',
      PULSE_WIDTH_G  => PULSE_WIDTH_G
   )
   port map (
       -- Local command signal
      cmdSlaveOut => ssiCmd,
      --addressed cmdOpCode
      opCode      => x"00",
      -- output pulse to sync module
      syncPulse   => swRun,
      -- Local clock and reset
      locClk      => sysClk,
      locRst      => sysRst
   );

   U_forceTriggerSync : entity surf.Synchronizer
   generic map(
      TPD_G          => TPD_G,
      RST_POLARITY_G => '1',
      OUT_POLARITY_G => '1',
      RST_ASYNC_G    => false,
      STAGES_G       => 2,
      BYPASS_SYNC_G  => false,
      INIT_G         => "0")
   port map(
      clk     => appClk,
      rst     => appRst,
      dataIn  => forceTrigger,
      dataOut => forceTrigSync
      );

   U_TrigPulserSync : entity surf.Synchronizer
   generic map(
      TPD_G          => TPD_G,
      RST_POLARITY_G => '1',
      OUT_POLARITY_G => '1',
      RST_ASYNC_G    => false,
      STAGES_G       => 2,
      BYPASS_SYNC_G  => false,
      INIT_G         => "0")
   port map(
      clk     => appClk,
      rst     => appRst,
      dataIn  => swRun,
      dataOut => swRunSync
      );

   process(appClk) begin
      if rising_edge(appClk) then
         if appRst = '1' then
            swRead <= '0' after TPD_G;
            forceRead <= '0' after TPD_G;
         else
            swRead <= swRunSync after TPD_G;
            forceRead <= forceTrigSync after TPD_G;
         end if;
      end if;
   end process;

   -----------------------------------------
   -- PGP Sideband Triggers:
   --   Any op code is a trigger, actual op
   --   code is the fiducial.
   -----------------------------------------
   U_PgpSideBandTrigger : entity surf.SynchronizerFifo
   generic map (
      TPD_G        => TPD_G,
      DATA_WIDTH_G => 8
   )
   port map (
      rst    => sysRst,
      wr_clk => sysClk,
      wr_en  => pgpRxOut.opCodeEn,
      din    => pgpRxOut.opCode,
      rd_clk => appClk,
      rd_en  => '1',
      valid  => coreSidebandRun,
      dout   => syncOpCode
   );
   -- Map op code to output port
   -- Have sideband DAQ lag 1 cycle behind sideband run
   process(appClk) begin
      if rising_edge(appClk) then
         if appRst = '1' then
            opCodeOut <= (others => '0') after TPD_G;
         elsif coreSidebandRun = '1' then
            opCodeOut <= syncOpCode after TPD_G;
         end if;
         coreSidebandDaq <= coreSidebandRun;
      end if;
   end process;

   --------------------------------------------------
   -- Combine with TTL triggers and look for edges --
   --------------------------------------------------
   combinedRunTrig <= (coreSidebandRun and r.trig.pgpTrigEn) or (runTrigger and not r.trig.pgpTrigEn) or (timingRunTrigger and r.trig.timingRunEn);
   combinedDaqTrig <= (coreSidebandDaq and r.trig.pgpTrigEn) or (daqTrigger and not r.trig.pgpTrigEn) or (timingDaqTrigger and r.trig.timingDaqEn);
   
   --------------------------------
   -- Run Input
   --------------------------------
   -- Edge Detect
   U_RunEdge : entity surf.SynchronizerEdge
      port map (
         clk        => appClk,
         rst        => appRst,
         dataIn     => combinedRunTrig,
         risingEdge => runTriggerEdge
      );

   -- Delay
   process ( appClk, appRst ) begin
      if ( appRst = '1' ) then
         runTriggerCnt  <= (others=>'0') after TPD_G;
         runTriggerOut  <= '0'           after TPD_G;
      elsif rising_edge(appClk) then

         -- Run trigger is disabled
         if trigSync.runTriggerEnable = '0' then
            runTriggerCnt  <= (others=>'0') after TPD_G;
            runTriggerOut  <= '0'           after TPD_G;

         -- Edge detected
         elsif runTriggerEdge = '1' then
            runTriggerCnt <= trigSync.runTriggerDelay after TPD_G;

            -- Trigger immediatly if delay is set to zero
            if trigSync.runTriggerDelay = 0 then
               runTriggerOut <= '1' after TPD_G;
            else
               runTriggerOut <= '0' after TPD_G;
            end if;

         -- Stop at zero
         elsif runTriggerCnt = 0 then
            runTriggerOut <= '0' after TPD_G;

         -- About to reach zero
         elsif runTriggerCnt = 1 then
            runTriggerOut <= '1'           after TPD_G;
            runTriggerCnt <= (others=>'0') after TPD_G;

         -- Counting down
         else
            runTriggerOut <= '0'               after TPD_G;
            runTriggerCnt <= runTriggerCnt - 1 after TPD_G;
         end if;
      end if;
   end process;

   --------------------------------
   -- DAQ trigger input
   --------------------------------

   -- Edge Detect
   U_AcqEdge : entity surf.SynchronizerEdge
      port map (
         clk        => appClk,
         rst        => appRst,
         dataIn     => combinedDaqTrig,
         risingEdge => daqTriggerEdge
      );

   -- Delay
   process ( appClk, appRst ) begin
      if ( appRst = '1' ) then
         daqTriggerCnt  <= (others=>'0') after TPD_G;
         daqTriggerOut  <= '0'           after TPD_G;
      elsif rising_edge(appClk) then

         -- DAQ trigger is disabled
         if trigSync.daqTriggerEnable = '0' then
            daqTriggerCnt  <= (others=>'0') after TPD_G;
            daqTriggerOut  <= '0'           after TPD_G;

         -- Edge detected
         elsif daqTriggerEdge = '1' then
            daqTriggerCnt <= trigSync.daqTriggerDelay after TPD_G;

            -- Trigger immediatly if delay is set to zero
            if trigSync.daqTriggerDelay = 0 then
               daqTriggerOut <= '1' after TPD_G;
            else
               daqTriggerOut <= '0' after TPD_G;
            end if;

         -- Stop at zero
         elsif daqTriggerCnt = 0 then
            daqTriggerOut <= '0' after TPD_G;

         -- About to reach zero
         elsif daqTriggerCnt = 1 then
            daqTriggerOut <= '1'           after TPD_G;
            daqTriggerCnt <= (others=>'0') after TPD_G;

         -- Counting down
         else
            daqTriggerOut <= '0'               after TPD_G;
            daqTriggerCnt <= daqTriggerCnt - 1 after TPD_G;
         end if;
      end if;
   end process;

   --------------------------------
   -- External triggers
   --------------------------------
   hwRunTrig <= runTriggerOut;
   hwDaqTrig <= daqTriggerOut;

   --------------------------------
   -- Autotrigger block
   --------------------------------
   U_AutoTrig : entity epix_hr_core.AutoTrigger
   port map (
      -- Sync clock and reset
      sysClk         => appClk,
      sysClkRst      => appRst,
      -- Inputs 
      runTrigIn      => hwRunTrig,
      daqTrigIn      => hwDaqTrig,
      -- Number of c lock cycles between triggers
      trigPeriod     => trigSync.autoTrigPeriod,
      -- Number of t riggers
      numTriggers    => trigSync.numTriggers,
      --Enable run a nd daq triggers
      runEn          => autoRunEn,
      daqEn          => autoDaqEn,
      -- Outputs 
      runTrigOut     => iRunTrigOut,
      daqTrigOut     => iDaqTrigOut,
 
      iDaqTrigPause  => iDaqTrigPause,
      countDaqTrigEn => trigSync.numTriggersType,

      daqEvery       => trigSync.daqEvery
   );

   iDaqTrigPause <= daqTrigPauseSync and trigSync.daqPauseEn;
   autoRunEn <= '1' when trigSync.autoRunEn = '1' and trigSync.runTriggerEnable = '1' and trigSync.autoTrigPeriod /= 0 else '0';
   autoDaqEn <= '1' when trigSync.autoDaqEn = '1' and trigSync.daqTriggerEnable = '1' and trigSync.autoTrigPeriod /= 0 else '0';

   --------------------------------
   -- Acquisition Counter And Outputs
   --------------------------------
   acqStart   <= iRunTrigOut or swRunSync or forceTrigSync;
   dataSend   <= iDaqTrigOut or swRead or forceRead;

   process ( appClk, appRst ) begin
      if ( appRst = '1' ) then
         acqCount    <= (others=>'0') after TPD_G;
         countEnable <= '0'           after TPD_G;
         daqPauseCnt<= (others=>'0') after TPD_G;
         runPauseCnt<= (others=>'0') after TPD_G;
      elsif rising_edge(appClk) then
         countEnable <= iRunTrigOut or swRunSync after TPD_G;

         if trigSync.acqCountReset = '1' then
            acqCount <= (others=>'0') after TPD_G;
            daqPauseCnt<= (others=>'0') after TPD_G;
            runPauseCnt<= (others=>'0') after TPD_G;
         elsif countEnable = '1' then
            acqCount <= acqCount + 1 after TPD_G;
         end if;
         if runTrigPauseEdgeSync = '1' then
            runPauseCnt <= runPauseCnt + 1 after TPD_G;
         end if;
         if daqTrigPauseEdgeSync = '1' then
            daqPauseCnt <= daqPauseCnt + 1 after TPD_G;
         end if;         
      end if;
   end process;

   process ( appClk, appRst ) begin
      if ( appRst = '1' ) then
         daqCount    <= (others=>'0') after TPD_G;
         daqCountEnable <= '0'           after TPD_G;
      elsif rising_edge(appClk) then
         daqCountEnable <= iDaqTrigOut or swRead after TPD_G;

         if trigSync.acqCountReset = '1' then
            daqCount <= (others=>'0') after TPD_G;
         elsif daqCountEnable = '1' then
            daqCount <= daqCount + 1 after TPD_G;
         end if;
      end if;
   end process;
   --------------------------------------------------
   -- AXI Lite register logic
   --------------------------------------------------

   comb : process (axilRst, sAxilReadMaster, sAxilWriteMaster, r, acqCountSync, daqCountSync, daqPauseCntSync, runPauseCntSync, daqTrigPauseAxiSync) is
      variable v        : RegType;
      variable regCon   : AxiLiteEndPointType;
   begin
      v := r;

      v.trig.iDaqTrigPauseR1 := daqTrigPauseAxiSync;
      v.trig.iDaqTrigPauseR2 := r.trig.iDaqTrigPauseR1;

      v.trig.acqCountReset := '0';

      axiSlaveWaitTxn(regCon, sAxilWriteMaster, sAxilReadMaster, v.sAxilWriteSlave, v.sAxilReadSlave);

      axiSlaveRegister (regCon, x"00", 0, v.trig.runTriggerEnable);
      axiSlaveRegister (regCon, x"00", 1, v.trig.timingRunEn);
      axiSlaveRegister (regCon, x"04", 0, v.trig.runTriggerDelay);
      axiSlaveRegister (regCon, x"08", 0, v.trig.daqTriggerEnable);
      axiSlaveRegister (regCon, x"08", 1, v.trig.timingDaqEn);
      axiSlaveRegister (regCon, x"0C", 0, v.trig.daqTriggerDelay);
      axiSlaveRegister (regCon, x"10", 0, v.trig.autoRunEn);
      axiSlaveRegister (regCon, x"14", 0, v.trig.autoDaqEn);
      axiSlaveRegister (regCon, x"18", 0, v.trig.autoTrigPeriod);
      axiSlaveRegister (regCon, x"1C", 0, v.trig.pgpTrigEn);
      axiSlaveRegister (regCon, x"20", 0, v.trig.acqCountReset);
      axiSlaveRegisterR(regCon, x"24", 0, acqCountSync);
      axiSlaveRegisterR(regCon, x"28", 0, daqCountSync);
      axiSlaveRegister (regCon, x"2C", 0, v.trig.numTriggers);
      axiSlaveRegisterR(regCon, x"30", 0, runPauseCntSync);
      axiSlaveRegisterR(regCon, x"34", 0, daqPauseCntSync);      
      axiSlaveRegister (regCon, x"38", 0, v.trig.daqPauseEn); 
      axiSlaveRegister (regCon, x"3C", 0, v.trig.numTriggersType); 
      axiSlaveRegisterR(regCon, x"40", 0, r.trig.daqPauseCycleCntMax);      
      axiSlaveRegisterR(regCon, x"44", 0, r.trig.daqPauseCycleCntMin);
      axiSlaveRegister (regCon, x"48", 0, v.trig.daqEvery);

      axiSlaveDefault(regCon, v.sAxilWriteSlave, v.sAxilReadSlave, AXIL_ERR_RESP_G);

      if (r.trig.acqCountReset = '1') then
         v.trig.daqPauseCycleCntMax := (others => '0');
         v.trig.daqPauseCycleCntMin := (others => '1');
      end if;
      if (r.trig.iDaqTrigPauseR1 = '1' and r.trig.iDaqTrigPauseR2 = '0') then
         -- pause started
         v.trig.daqPauseCycleCntr := (others => '0');
      elsif (r.trig.iDaqTrigPauseR1 = '0' and r.trig.iDaqTrigPauseR2 = '1') then
         -- pause ended
         if r.trig.daqPauseCycleCntMax <= r.trig.daqPauseCycleCntr then
            v.trig.daqPauseCycleCntMax := r.trig.daqPauseCycleCntr;
         end if;
         if r.trig.daqPauseCycleCntMin >= r.trig.daqPauseCycleCntr then
            v.trig.daqPauseCycleCntMin := r.trig.daqPauseCycleCntr;
         end if;
      else
      -- increment counters
         v.trig.daqPauseCycleCntr := r.trig.daqPauseCycleCntr + 1;
      end if;

      if (axilRst = '1') then
         v := REG_INIT_C;
      end if;

      rin <= v;

      sAxilWriteSlave   <= r.sAxilWriteSlave;
      sAxilReadSlave    <= r.sAxilReadSlave;


   end process comb;

   seq : process (axilClk) is
   begin
      if (rising_edge(axilClk)) then
         r <= rin after TPD_G;
         acqCountSync <= acqCount after TPD_G;
         daqCountSync <= daqCount after TPD_G;
         runPauseCntSync <= runPauseCnt after TPD_G;
         daqPauseCntSync <= daqPauseCnt after TPD_G;
      end if;
   end process seq;

   --sync registers to appClk clock
   process(appClk) begin
      if rising_edge(appClk) then
         if appRst = '1' then
            trigSync <= TRIGGER_INIT_C after TPD_G;
         else
            trigSync <= r.trig after TPD_G;
         end if;
      end if;
   end process;

         
   U_runTriggerPauseEdge : entity surf.SynchronizerEdge
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => appClk,
         rst     => appRst,
         dataIn  => runTrigPause,
         risingEdge => runTrigPauseEdgeSync
      );  

   U_daqTriggerPauseEdge : entity surf.SynchronizerEdge
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => appClk,
         rst     => appRst,
         dataIn  => daqTrigPause,
         risingEdge => daqTrigPauseEdgeSync
      );  

      U_daqTriggerPause : entity surf.Synchronizer
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => appClk,
         rst     => appRst,
         dataIn  => daqTrigPause,
         dataOut => daqTrigPauseSync
      );  

      U_daqTriggerPauseaxilclk : entity surf.Synchronizer
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => axilClk,
         rst     => axilRst,
         dataIn  => daqTrigPause,
         dataOut => daqTrigPauseAxiSync
      );        
end rtl;

