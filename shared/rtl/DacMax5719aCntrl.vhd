------------------------------------------------------------------------------
-- Title         : DAC Controller
-- Project       : ePix HR Detector
-------------------------------------------------------------------------------
-- File          : Max5719aCntrl.vhd
-------------------------------------------------------------------------------
-- Description:
-- DAC Controller.
-------------------------------------------------------------------------------
-- This file is part of 'EPIX HR Development Firmware'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'EPIX HR Development Firmware', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity DacMax5719aCntrl is
   generic (
      TPD_G : time := 1 ns
   );
   port (

      -- Master system clock
      sysClk          : in  std_logic;
      sysClkRst       : in  std_logic;

      -- DAC Data
      dacData         : in  std_logic_vector(19 downto 0);

      -- DAC Control Signals
      dacDin          : out std_logic;
      dacSclk         : out std_logic;
      dacCsL          : out std_logic;
      dacLdacL        : out std_logic;
      dacClrL         : out std_logic
   );
end DacMax5719aCntrl;


-- Define architecture
architecture DacMax5719aCntrl of DacMax5719aCntrl is


   attribute keep : string;

   -- Local Signals
   signal intData     : std_logic_vector(19 downto 0);
   signal intCnt      : std_logic_vector(2  downto 0);
   signal intClk      : std_logic;
   signal intClkEn    : std_logic;
   signal intBitRst   : std_logic;
   signal intBitEn    : std_logic;
   signal intBit      : std_logic_vector(4 downto 0);
   signal smCntN    : std_logic_vector(7 downto 0);
   signal smCntR    : std_logic_vector(7 downto 0);
   signal nxtDin      : std_logic;
   signal nxtCsL      : std_logic;
   signal dacStrobe   : std_logic;
   signal intdacLdacL : std_logic;

   -- State Machine
   constant ST_IDLE      : std_logic_vector(2 downto 0) := "001";
   constant ST_WAIT      : std_logic_vector(2 downto 0) := "010";
   constant ST_SHIFT     : std_logic_vector(2 downto 0) := "011";
   constant ST_WAIT_LD   : std_logic_vector(2 downto 0) := "100";
   constant ST_WAIT_CS   : std_logic_vector(2 downto 0) := "101";
   constant ST_LOAD      : std_logic_vector(2 downto 0) := "110";
   constant ST_WAIT_DIGLAT : std_logic_vector(2 downto 0) := "111";
   signal   curState     : std_logic_vector(2 downto 0);
   signal   nxtState     : std_logic_vector(2 downto 0);
   signal   downCounter  : std_logic_vector(4 downto 0);
   attribute keep of curState : signal is "true";
   attribute keep of dacStrobe : signal is "true";

begin

   -- Clear
   dacClrL <= '0' when sysClkRst = '1' else '1';

   -- Modified so that strobe is internally generated when input data changes.
   process ( sysClk ) begin
      if rising_edge(sysClk) then
         if (sysClkRst = '1') then
            intData   <= (dacData) after TPD_G;
            dacStrobe <= '0' after TPD_G;
         elsif (intData /= dacData) then
            dacStrobe <= '1' after TPD_G;
            intData   <= dacData after TPD_G;
         else
            dacStrobe <= '0' after TPD_G;
         end if;
      end if;
   end process;

   -- Generate clock and enable signal
   process ( sysClk, sysClkRst ) begin
      if sysClkRst = '1' then
         intClk   <= '0'           after TPD_G;
         intCnt   <= (others=>'0') after TPD_G;
         intClkEn <= '0'           after TPD_G;
      elsif rising_edge(sysClk) then
        if curState = ST_IDLE or curState = ST_WAIT_LD or curState = ST_LOAD or curState = ST_WAIT_DIGLAT then
          intClk <= '0'           after TPD_G;
          intClkEn <= '0'           after TPD_G;
        else
          if intCnt = 4 then           -- Generates an 19.6MHz clock (51.2 ns period). Not validated with faster clocks.
            intCnt   <= (others=>'0') after TPD_G;
            intClk   <= not intClk    after TPD_G;
            intClkEn <= intClk        after TPD_G;
          else
            intCnt   <= intCnt + 1    after TPD_G;
            intClkEn <= '0'           after TPD_G;
          end if;
        end if;
      end if;
   end process;

   -- Output clock
   dacSclk <= intClk;

   -- async load dac value
   process ( sysClk, sysClkRst ) begin
      if sysClkRst = '1' then
         dacLdacL <= '1';
      elsif rising_edge(sysClk) then
         dacLdacL <= intdacLdacL after TPD_G;
      end if;
   end process;

   -- State machine
   process ( sysClk, sysClkRst ) begin
      if sysClkRst = '1' then
         smCntR <= (others=>'0') after TPD_G;         
         intBit   <= "10111" after TPD_G;
         curState <= ST_IDLE       after TPD_G;
      elsif rising_edge(sysClk) then

         -- Bit counter
         if intBitRst = '1' then
            downCounter <= "10111" after TPD_G;
            intBit <= "10011" after TPD_G;
         elsif intBitEn = '1' then
            if (intBit > 0) then
               intBit <= intBit - 1 after TPD_G;
            end if;
            downCounter <= downCounter - 1 after TPD_G;
         end if;

         -- DAC controls
         dacDin <= nxtDin after TPD_G;
         dacCsL <= nxtCsL after TPD_G;

         -- State
         curState <= nxtState after TPD_G;

         smCntR <= smCntN after TPD_G;
      end if;
   end process;

   -- State machine
   process ( curState, intBit, dacStrobe, intClkEn, intData, smCntR, downCounter ) begin
      case ( curState ) is

         -- IDLE
         when ST_IDLE =>
            intBitRst   <= '1';
            intBitEn    <= '0';
            nxtDin      <= '0';
            nxtCsL      <= '1';
            intdacLdacL <= '1';
            smCntN <= (others => '0');

            if dacStrobe = '1' then
               nxtState <= ST_WAIT;
            else
               nxtState <= curState;
            end if;

         -- Wait for neg edge. CS Pulse-Width High must be larger than 20ns. (3.125 cycles @ 156.25Mhz ~ 4 cycles)
         -- Waiting for inClkEn takes several cycles so no control was done here.
         when ST_WAIT =>
            intBitRst   <= '1';
            intBitEn    <= '0';
            nxtDin      <= '0';
            nxtCsL      <= '1';
            intdacLdacL <= '1';
            smCntN <= (others => '0');

            if intClkEn = '1' then
               nxtState <= ST_SHIFT;
               nxtCsL      <= '0'; -- CS Fall to SCLK Rise HoldTime is 8 ns.
            else
               nxtState <= curState;
            end if;

         -- Shift data
         when ST_SHIFT =>
            intBitRst   <= '0';
            intBitEn    <= intClkEn;
            nxtDin      <= intData(conv_integer(intBit));
            if (downCounter <= "00011") then
               nxtDin <= '0';
            end if;
            nxtCsL      <= '0';
            intdacLdacL <= '1';
            smCntN <= (others => '0');

            if intClkEn = '1' and downCounter = "0" then
               nxtState <= ST_WAIT_DIGLAT;
            else
               nxtState <= curState;
            end if;

         -- Wait digital latency 1500ns - (4-bit time - 4*2*6.4*4 = 204.8ns) (~ 204 cycles of 156.25 MHz)
         when ST_WAIT_DIGLAT =>
         intBitRst   <= '1';
         intBitEn    <= '0';
         nxtDin      <= '0';
         nxtCsL      <= '0';
         intdacLdacL <= '1';
         smCntN    <= smCntR + 1;
         if smCntR = "11001100" then
            nxtState <= ST_WAIT_LD;
            smCntN <= (others => '0');
         else
            nxtState <= curState;               
         end if;

         -- CS High to LDAC Setup Time 20ns - here will take 4 cycles
         when ST_WAIT_LD =>
            intBitRst   <= '1';
            intBitEn    <= '0';
            nxtDin      <= '0';
            nxtCsL      <= '1';
            intdacLdacL <= '1';
            smCntN    <= smCntR + 1;
            if smCntR = "101" then
               nxtState <= ST_LOAD;
               smCntN <= (others => '0');
            else
               nxtState <= curState;               
            end if;

         -- LDAC Pulse Width 20ns. Here will take 4 cycles
         when ST_LOAD =>
            intBitRst   <= '1';
            intBitEn    <= '0';
            nxtDin      <= '0';
            nxtCsL      <= '1';
            intdacLdacL <= '0';
            smCntN <= smCntR + 1;
            if smCntR = "101" then
               nxtState <= ST_IDLE;
               smCntN <= (others => '0');
            else
               nxtState <= curState;
            end if;

         when others =>
            intBitRst   <= '0';
            intBitEn    <= '0';
            nxtDin      <= '0';
            nxtCsL      <= '1';
            intdacLdacL <= '1';
            nxtState  <= ST_IDLE;
            smCntN <= (others => '0');
      end case;
   end process;

end DacMax5719aCntrl;

