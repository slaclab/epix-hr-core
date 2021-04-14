-------------------------------------------------------------------------------
-- Title      : Pseudo Oscilloscope Interface
-- Project    : EPIX
-------------------------------------------------------------------------------
-- File       : PseudoScopeAxi.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description:
-- Pseudo-oscilloscope interface for ADC channels, similar to chipscope.
-------------------------------------------------------------------------------
-- This file is part of 'EPIX Development Firmware'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'EPIX Development Firmware', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiStreamPkg.all;
use surf.AxiLitePkg.all;
use surf.SsiPkg.all;


entity PseudoScope2Axi is
   generic (
      TPD_G                      : time                  := 1 ns;
      INPUTS_G                   : integer range 0 to 32 := 4;
      MASTER_AXI_STREAM_CONFIG_G : AxiStreamConfigType   := ssiAxiStreamConfig(4, TKEEP_COMP_C)
   );
   port (
      -- system clock
      clk               : in  sl;
      rst               : in  sl;
      -- input data
      dataIn            : in  Slv16Array(INPUTS_G-1 downto 0);
      dataValid         : in  slv(INPUTS_G-1 downto 0);
      -- Signal for auto-rearm of trigger
      arm               : in  sl;
      -- input triggers
      triggerIn         : in  slv(12 downto 0) := (others=>'0');
      -- AXI stream output
      axisClk           : in  sl;
      axisRst           : in  sl;
      axisMaster        : out  AxiStreamMasterType;
      axisSlave         : in   AxiStreamSlaveType;
      -- AXI lite for register access
      axilClk           : in  sl;
      axilRst           : in  sl;
      sAxilWriteMaster  : in  AxiLiteWriteMasterType;
      sAxilWriteSlave   : out AxiLiteWriteSlaveType;
      sAxilReadMaster   : in  AxiLiteReadMasterType;
      sAxilReadSlave    : out AxiLiteReadSlaveType

   );
end PseudoScope2Axi;


architecture rtl of PseudoScope2Axi is

-- Stream settings
   constant SLAVE_AXI_CONFIG_C   : AxiStreamConfigType := ssiAxiStreamConfig(2);
   constant MASTER_AXI_CONFIG_C  : AxiStreamConfigType := MASTER_AXI_STREAM_CONFIG_G;
   signal txSlave                : AxiStreamSlaveType;

   type WrStateType is (
      IDLE_S,
      ARMED_S,
      OFFSET_S,
      WRITE_1_S,
      WRITE_S
   );
   type WrStateArray is array (natural range <>) of WrStateType;

   type RdStateType is (
      IDLE_S,
      HDR_S,
      DATA_A_S,
      WAIT_S,
      DATA_B_S,
      FOOTER_S
   );

   type RegType is record
      scopeEnable          : sl;
      arm                  : sl;
      trig                 : sl;
      triggerEdge          : sl;
      triggerChannel       : slv(3 downto 0);
      triggerMode          : slv(1 downto 0);
      triggerAdcThresh     : slv(15 downto 0);
      triggerHoldoff       : slv(12 downto 0);
      triggerOffset        : slv(12 downto 0);
      triggerDelay         : slv(12 downto 0);
      traceLength          : slv(12 downto 0);
      skipSamples          : slv(12 downto 0);
      inputChannelA        : slv(4 downto 0);
      inputChannelB        : slv(4 downto 0);
      rdState              : RdStateType;
      wrState              : WrStateArray(1 downto 0);
      dataMux              : Slv16Array(1 downto 0);
      dataMuxValid         : slv(1 downto 0);
      wrEn                 : slv(1 downto 0);
      wrBuffCnt            : Slv1Array(1 downto 0);
      rdBuffCnt            : Slv1Array(1 downto 0);
      wrAddr               : Slv13Array(1 downto 0);
      rdAddr               : Slv13Array(1 downto 0);
      smplCnt              : Slv13Array(1 downto 0);
      triggerCnt           : Slv13Array(1 downto 0);
      buffRd               : Slv2Array(1 downto 0);
      wordCnt              : slv(3 downto 0);
      txMaster             : AxiStreamMasterType;
      axilWriteSlave       : AxiLiteWriteSlaveType;
      axilReadSlave        : AxiLiteReadSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      scopeEnable          => '0',
      arm                  => '0',
      trig                 => '0',
      triggerEdge          => '0',
      triggerChannel       => (others=>'0'),
      triggerMode          => (others=>'0'),
      triggerAdcThresh     => (others=>'0'),
      triggerHoldoff       => (others=>'0'),
      triggerOffset        => (others=>'0'),
      triggerDelay         => (others=>'0'),
      traceLength          => (others=>'0'),
      skipSamples          => (others=>'0'),
      inputChannelA        => (others=>'0'),
      inputChannelB        => (others=>'0'),
      rdState              => IDLE_S,
      wrState              => (others=>IDLE_S),
      dataMux              => (others=>(others=>'0')),
      dataMuxValid         => (others=>'0'),
      wrEn                 => (others=>'0'),
      wrBuffCnt            => (others=>(others=>'0')),
      rdBuffCnt            => (others=>(others=>'0')),
      wrAddr               => (others=>(others=>'0')),
      rdAddr               => (others=>(others=>'0')),
      smplCnt              => (others=>(others=>'0')),
      triggerCnt           => (others=>(others=>'0')),
      buffRd               => (others=>(others=>'0')),
      wordCnt              => (others=>'0'),
      txMaster             => AXI_STREAM_MASTER_INIT_C,
      axilWriteSlave       => AXI_LITE_WRITE_SLAVE_INIT_C,
      axilReadSlave        => AXI_LITE_READ_SLAVE_INIT_C
   );

   signal r                : RegType := REG_INIT_C;
   signal rin              : RegType;

   signal sAxisCtrl        : AxiStreamCtrlType;

   signal axilReadMaster   : AxiLiteReadMasterType;
   signal axilWriteMaster  : AxiLiteWriteMasterType;

   signal rdData           : Slv16Array(1 downto 0);

   signal triggerInput     : slv(15 downto 0);
   signal triggerInRise    : slv(15 downto 0);
   signal triggerInFall    : slv(15 downto 0);
   constant cLane     : slv( 1 downto 0) := "00";
   constant cVC       : slv( 1 downto 0) := "10";
   constant cQuad     : slv( 1 downto 0) := "00";
   constant cOpCode   : slv( 7 downto 0) := x"00";
   constant cZeroWord : slv(31 downto 0) := x"00000000";

   signal addra : Slv14Array(1 downto 0);
   signal addrb : Slv14Array(1 downto 0);

   signal trigSel : sl;
   signal armSel  : sl;
   signal armSync : sl;

begin

   --------------------------------------------------
   -- AXI lite synchronizer
   --------------------------------------------------
   U_AxilSync : entity surf.AxiLiteAsync
   generic map (
      TPD_G             => TPD_G
   )
   port map (
      -- Slave Port
      sAxiClk           => axilClk,
      sAxiClkRst        => axilRst,
      sAxiReadMaster    => sAxilReadMaster,
      sAxiReadSlave     => sAxilReadSlave,
      sAxiWriteMaster   => sAxilWriteMaster,
      sAxiWriteSlave    => sAxilWriteSlave,
      -- Master Port
      mAxiClk           => clk,
      mAxiClkRst        => rst,
      mAxiReadMaster    => axilReadMaster,
      mAxiReadSlave     => r.axilReadSlave,
      mAxiWriteMaster   => axilWriteMaster,
      mAxiWriteSlave    => r.axilWriteSlave
   );

   U_Sync : entity surf.SynchronizerEdge
      generic map (
         TPD_G       => TPD_G
      )
      port map (
         clk         => clk,
         rst         => rst,
         dataIn      => arm,
         risingEdge  => armSync
      );

   -- Arming mode
   armSel <=
      '0'      when r.triggerMode = 0 else
      r.arm    when r.triggerMode = 1 else
      armSync  when r.triggerMode = 2 else
      '1';

   --------------------------------------------------
   -- trigger synchronizers
   --------------------------------------------------
   triggerInput(0) <= r.trig;
   triggerInput(1) <= '1' when r.dataMux(0) > r.triggerAdcThresh else '0';
   triggerInput(2) <= '1' when r.dataMux(1) > r.triggerAdcThresh else '0';
   triggerInput(15 downto 3) <= triggerIn;

   G_TrigIn: for i in 15 downto 0 generate
      U_Sync : entity surf.SynchronizerEdge
         generic map (
            TPD_G       => TPD_G
         )
         port map (
            clk         => clk,
            rst         => rst,
            dataIn      => triggerInput(i),
            risingEdge  => triggerInRise(i),
            fallingEdge => triggerInFall(i)
         );
   end generate;

   --------------------------------------------------
   -- Trigger selection
   --------------------------------------------------
   trigSel <= triggerInRise(conv_integer(r.triggerChannel)) when r.triggerEdge = '1' else triggerInFall(conv_integer(r.triggerChannel));

   --------------------------------------------------
   -- Data processing and streaming FSM
   --------------------------------------------------
   comb : process (r, rst, txSlave, axilReadMaster, axilWriteMaster, rdData, dataIn, dataValid, trigSel, armSel) is
      variable v       : RegType;
      variable regCon  : AxiLiteEndPointType;
   begin
      v := r;

      v.arm := '0';

      --------------------------------------------------
      -- AXI Lite register logic
      --------------------------------------------------

      -- Determine the AXI-Lite transaction
      axiSlaveWaitTxn(regCon, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);

      axiSlaveRegister (regCon, x"000",  0, v.arm);
      axiSlaveRegister (regCon, x"004",  0, v.trig);
      axiSlaveRegister (regCon, x"008",  0, v.scopeEnable);
      axiSlaveRegister (regCon, x"008",  1, v.triggerEdge);
      axiSlaveRegister (regCon, x"008",  2, v.triggerChannel);
      axiSlaveRegister (regCon, x"008",  6, v.triggerMode);
      axiSlaveRegister (regCon, x"008", 16, v.triggerAdcThresh);
      axiSlaveRegister (regCon, x"00C",  0, v.triggerHoldoff);
      axiSlaveRegister (regCon, x"00C", 13, v.triggerOffset);
      axiSlaveRegister (regCon, x"010",  0, v.traceLength);
      axiSlaveRegister (regCon, x"010", 13, v.skipSamples);
      axiSlaveRegister (regCon, x"014",  0, v.inputChannelA);
      axiSlaveRegister (regCon, x"014",  5, v.inputChannelB);
      axiSlaveRegister (regCon, x"018",  0, v.triggerDelay);

      -- Close out the AXI-Lite transaction
      axiSlaveDefault(regCon, v.axilWriteSlave, v.axilReadSlave, AXI_RESP_DECERR_C);

      --------------------------------------------------
      -- Data selection
      --------------------------------------------------
      v.dataMux(0)   := dataIn(conv_integer(r.inputChannelA));
      v.dataMuxValid(0) := dataValid(conv_integer(r.inputChannelA));
      v.dataMux(1)   := dataIn(conv_integer(r.inputChannelB));
      v.dataMuxValid(1) := dataValid(conv_integer(r.inputChannelB));

      --------------------------------------------------
      -- Data write FSM
      --------------------------------------------------

      for i in 1 downto 0 loop

         v.wrEn(i) := '0';

         case r.wrState(i) is

            -- wait trigger
            when IDLE_S =>
               if armSel = '1' and r.buffRd(i)(conv_integer(r.wrBuffCnt(i))) = '0' and r.scopeEnable = '1' then
                  v.wrState(i) := ARMED_S;
               end if;

            when ARMED_S =>
               if trigSel = '1' then
                  if r.triggerOffset = 0 then
                     v.wrState(i) := WRITE_1_S;
                  else
                     v.wrState(i) := OFFSET_S;
                  end if;
               end if;

            -- offset trigger
            when OFFSET_S =>
               v. triggerCnt(i) := r. triggerCnt(i) + 1;
               if r. triggerCnt(i) >= r.triggerOffset then
                  v. triggerCnt(i) := (others=>'0');
                  v.wrState(i) := WRITE_1_S;
               end if;

            when WRITE_1_S =>
               if r.dataMuxValid(i) = '1' then
                  v.wrEn(i) := '1';
                  v.wrState(i) := WRITE_S;
               end if;

            -- write samles to ram
            when WRITE_S =>
               if r.dataMuxValid(i) = '1' then
                  if r.wrAddr(i) < r.traceLength then
                     if r.smplCnt(i) < r.skipSamples then
                        v.smplCnt(i) := r.smplCnt(i) + 1;
                     else
                        v.smplCnt(i) := (others=>'0');
                        v.wrAddr(i) := r.wrAddr(i) + 1;
                        v.wrEn(i) := '1';
                     end if;
                  else
                     v.buffRd(i)(conv_integer(r.wrBuffCnt(i))) := '1';
                     v.wrBuffCnt(i) := r.wrBuffCnt(i) + 1;
                     v.wrAddr(i) := (others=>'0');
                     v.wrState(i) := IDLE_S;
                  end if;
               end if;

            when others =>
               v.wrState(i) := IDLE_S;

         end case;

      end loop;

      --------------------------------------------------
      -- Data stream FSM
      --------------------------------------------------

      -- Reset strobing Signals
      if (txSlave.tReady = '1') then
         v.txMaster.tValid := '0';
         v.txMaster.tLast  := '0';
         v.txMaster.tUser  := (others => '0');
         v.txMaster.tKeep  := (others => '1');
         v.txMaster.tStrb  := (others => '1');
      end if;

      case r.rdState is

         -- wait trigger
         when IDLE_S =>
            if r.buffRd(0)(conv_integer(r.rdBuffCnt(0))) = '1' then
               v.rdState := HDR_S;
            end if;

         when HDR_S =>
            if v.txMaster.tValid = '0' then
               v.wordCnt := r.wordCnt + 1;
               v.txMaster.tValid := '1';
               if r.wordCnt = 0 then
                  ssiSetUserSof(SLAVE_AXI_CONFIG_C, v.txMaster, '1');
                  v.txMaster.tData(15 downto 0) := x"00" & "00" & cLane & "00" & cVC;
               elsif r.wordCnt = 1 then
                  v.txMaster.tData(15 downto 0) := x"0000";
               elsif r.wordCnt = 2 then
                  v.txMaster.tData(15 downto 0) := x"0000";
               elsif r.wordCnt = 3 then
                  v.txMaster.tData(15 downto 0) := x"0" & "00" & cQuad & cOpCode;
               else
                  v.txMaster.tData(15 downto 0) := (others=>'0');
                  if r.wordCnt = 15 then
                     v.rdState := DATA_A_S;
                     v.wordCnt := (others=>'0');
                  end if;
               end if;
            end if;

         when DATA_A_S =>
            if v.txMaster.tValid = '0' then
               v.rdAddr(0) := r.rdAddr(0) + 1;
               v.txMaster.tValid := '1';
               v.txMaster.tData(15 downto 0) := rdData(0);
               if r.rdAddr(0) >= r.traceLength then
                  v.rdState := WAIT_S;
                  v.rdAddr(0) := (others=>'0');
                  v.rdBuffCnt(0) := r.rdBuffCnt(0) + 1;
                  v.buffRd(0)(conv_integer(r.rdBuffCnt(0))) := '0';
               end if;
            end if;

         when WAIT_S =>
            if r.buffRd(1)(conv_integer(r.rdBuffCnt(1))) = '1' then
               v.rdState := DATA_B_S;
            end if;


         when DATA_B_S =>
            if v.txMaster.tValid = '0' then
               v.rdAddr(1) := r.rdAddr(1) + 1;
               v.txMaster.tValid := '1';
               v.txMaster.tData(15 downto 0) := rdData(1);
               if r.rdAddr(1) >= r.traceLength then
                  v.rdState := FOOTER_S;
                  v.rdAddr(1) := (others=>'0');
                  v.rdBuffCnt(1) := r.rdBuffCnt(1) + 1;
                  v.buffRd(1)(conv_integer(r.rdBuffCnt(1))) := '0';
               end if;
            end if;

         when FOOTER_S =>
            if v.txMaster.tValid = '0' then
               v.wordCnt := r.wordCnt + 1;
               v.txMaster.tValid := '1';
               v.txMaster.tData(15 downto 0) := (others=>'0');
               if r.wordCnt >= 9 then
                  v.txMaster.tLast  := '1';
                  ssiSetUserEofe(SLAVE_AXI_CONFIG_C, v.txMaster, '0');
                  v.wordCnt := (others=>'0');
                  v.rdState := IDLE_S;
               end if;
            end if;

         when others =>
            v.rdState := IDLE_S;

      end case;

      if (rst = '1') then
         v := REG_INIT_C;
      end if;

      rin <= v;

   end process comb;

   seq : process (clk) is
   begin
      if (rising_edge(clk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

   ----------------------------------------------------------------------
   -- sample buffers
   ----------------------------------------------------------------------
   G_Buf : for i in 1 downto 0 generate
      U_SmplBuf : entity surf.DualPortRam
      generic map (
         TPD_G          => TPD_G,
         DATA_WIDTH_G   => 16,
         ADDR_WIDTH_G   => 14
      )
      port map (
         -- Port A
         clka     => clk,
         rsta     => rst,
         wea      => r.wrEn(i),
         addra    => addra(i),
         dina     => r.dataMux(i),
         -- Port B
         clkb     => clk,
         rstb     => rst,
         addrb    => addrb(i),
         doutb    => rdData(i)
      );

      addra(i) <= r.wrBuffCnt(i) & r.wrAddr(i);
      addrb(i) <= r.rdBuffCnt(i) & r.rdAddr(i);

   end generate;

   ----------------------------------------------------------------------
   -- Output Axis FIFO
   ----------------------------------------------------------------------

   U_AxisBuf : entity surf.AxiStreamFifoV2
   generic map (
      -- General Configurations
      TPD_G                => TPD_G,
      PIPE_STAGES_G        => 1,
      SLAVE_READY_EN_G     => true,
      VALID_THOLD_G        => 1,     -- =0 = only when frame ready
      -- FIFO configurations
      GEN_SYNC_FIFO_G      => false,
      CASCADE_SIZE_G       => 1,
      FIFO_ADDR_WIDTH_G    => 5,
      -- AXI Stream Port Configurations
      SLAVE_AXI_CONFIG_G   => SLAVE_AXI_CONFIG_C,
      MASTER_AXI_CONFIG_G  => MASTER_AXI_CONFIG_C
   )
   port map (
      -- Slave Port
      sAxisClk          => clk,
      sAxisRst          => rst,
      sAxisMaster       => r.txMaster,
      sAxisSlave        => txSlave,
      sAxisCtrl         => sAxisCtrl,
      -- Master Port
      mAxisClk          => axisClk,
      mAxisRst          => axisRst,
      mAxisMaster       => axisMaster,
      mAxisSlave        => axisSlave
   );

end rtl;

