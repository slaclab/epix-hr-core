-------------------------------------------------------------------------------
-- Title      : ADS1217 ADC Controller
-- Project    : EPIX Detector
-------------------------------------------------------------------------------
-- File       : SlowAdcCntrl.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description:
-- This block is responsible for reading the voltages, currents and strongback
-- temperatures from the ADS1217 on the generation 2 EPIX analog board.
-- The ADS1217 is an 8 channel ADC.
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
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

library surf;
use surf.StdRtlPkg.all;

entity SlowAdcCntrl is
   generic (
      SIMULATION_G      : boolean := FALSE;
      TPD_G           	: time := 1 ns;
      SYS_CLK_PERIOD_G  : real := 10.0E-9;	-- 100MHz
      ADC_CLK_PERIOD_G  : real := 200.0E-9;	-- 5MHz
      SPI_SCLK_PERIOD_G : real := 1.0E-6  	-- 1MHz
   );
   port (
      -- Master system clock
      sysClk          : in  std_logic;
      sysClkRst       : in  std_logic;

      -- Operation Control
      adcStart        : in  std_logic;
      adcData         : out Slv24Array(8 downto 0);
      allChRd         : out std_logic;

      -- ADC Control Signals
      adcRefClk     : out   std_logic;
      adcDrdy       : in    std_logic;
      adcSclk       : out   std_logic;
      adcDout       : in    std_logic;
      adcCsL        : out   std_logic;
      adcDin        : out   std_logic;

      -- Debug
      dbg_cmdcnter  : out   slv(31 downto 0)
   );
end SlowAdcCntrl;


-- Define architecture
architecture RTL of SlowAdcCntrl is

   constant r0_speed :     std_logic_vector(0 downto 0) := "0";      -- "0" - fosc/128, "1" - fosc/256
   constant r0_refhi :     std_logic_vector(0 downto 0) := "0";      -- "0" - Vref 1.25, "1" - Vref 2.5
   constant r0_bufen :     std_logic_vector(0 downto 0) := "0";      -- "0" - buffer disabled, "1" - buffer enabled
   constant r2_idac1r :    std_logic_vector(1 downto 0) := "00";     -- "00" - off, "01" - range 1 (0.25mA@1.25Vref) ... "11" - range 3 (1mA@1.25Vref)
   constant r2_idac2r :    std_logic_vector(1 downto 0) := "00";     -- "00" - off, "01" - range 1 (0.25mA@1.25Vref) ... "11" - range 3 (1mA@1.25Vref)
   constant r2_pga :       std_logic_vector(2 downto 0) := "000";    -- PGA 1 to 128
   constant r3_idac1 :     std_logic_vector(7 downto 0) := CONV_STD_LOGIC_VECTOR(0, 8);    -- I DAC1 0 to max range
   constant r4_idac2 :     std_logic_vector(7 downto 0) := CONV_STD_LOGIC_VECTOR(0, 8);    -- I DAC2 0 to max range
   constant r5_r6_dec0 :   std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(195, 11); -- Decimation value
   constant r6_ub :        std_logic_vector(0 downto 0) := "1";      -- "0" - bipolar, "1" - unipolar
   constant r6_mode :      std_logic_vector(1 downto 0) := "00";     -- "00" - auto, "01" - fast ...

   constant adc_setup_regs : Slv8Array(9 downto 0) := (
      0 => "000" & r0_speed & "1" & r0_refhi & r0_bufen & "0",
      1 => "00001000",  -- start with MUX set to Ain0 and Comm
      2 => "0" & r2_idac1r & r2_idac2r & r2_pga,
      3 => r3_idac1,
      4 => r4_idac2,
      5 => "00000000",  -- offset DAC leave default
      6 => "00000000",  -- DIO leave default
      7 => "11111111",  -- Leave all DIO in input mode
      8 => r5_r6_dec0(7 downto 0),
      9 => "0" & r6_ub & r6_mode & "0" & r5_r6_dec0(10 downto 8)
   );

   constant cmd_wr_reg :   std_logic_vector(3 downto 0) := "0101";
   constant cmd_reset :    std_logic_vector(7 downto 0) := "11111110";
   constant cmd_dsync :    std_logic_vector(7 downto 0) := "11111100";
   constant cmd_rdata :    std_logic_vector(7 downto 0) := "00000001";

   constant adc_refclk_t: integer := integer(ceil((ADC_CLK_PERIOD_G/SYS_CLK_PERIOD_G)/2.0))-1;
   constant dout_wait_t: integer := 2000;
   constant wreg_wait_t: integer := 2000;
   constant reset_wait_t: integer := 320;
   constant sim_wait_t: integer := 5;

   TYPE STATE_TYPE IS (RESET, IDLE, CMD_SEND, CMD_WAIT, CMD_DLY, WAIT_DRDY, READ_DATA, STORE_DATA);
   SIGNAL state, next_state   : STATE_TYPE;

   signal adcData_r :      Slv(23 downto 0);
   signal adcDrdyEn :      std_logic;
   signal adcDrdyD1 :      std_logic;
   signal adcDrdyD2 :      std_logic;
   signal adcStartEn :     std_logic;
   signal adcStartD1 :     std_logic;
   signal adcStartD2 :     std_logic;
   signal spi_wr_en :      std_logic;
   signal spi_wr_data :    std_logic_vector(7 downto 0);
   signal spi_rd_en :      std_logic;
   signal spi_rd_en_d1 :   std_logic;
   signal spiRdEn :        std_logic;
   signal spi_rd_data :    std_logic_vector(7 downto 0);
   signal cmd_counter :    integer range 0 to 22;
   signal cmd_data :       integer range 0 to 22;
   signal cmd_load :       std_logic;
   signal cmd_en :         std_logic;
   signal ch_sel  :        std_logic_vector(3 downto 0);
   signal byte_counter :   integer range 0 to 4;
   signal byte_rst :       std_logic;
   signal byte_en :        std_logic;
   signal ch_counter :     integer range 0 to 9;
   signal channel_en :     std_logic;

   signal wait_counter :   integer range 0 to dout_wait_t;
   signal wait_data :      integer range 0 to dout_wait_t;
   signal wait_load :      std_logic;
   signal wait_done :      std_logic;

   signal data_23_16 :     std_logic_vector(7 downto 0);
   signal data_15_08 :     std_logic_vector(7 downto 0);

   signal ref_counter :    integer range 0 to adc_refclk_t;
   signal ref_clk :        std_logic;
   signal ref_clk_en :     std_logic;

   signal csl_master :     std_logic;
   signal csl_cmd :        std_logic;

   signal mdec1_reg :      slv(7 downto 0);
begin


   -- ADC reference clock counter
   ref_cnt_p: process ( sysClk )
   begin
      if rising_edge(sysClk) then
         if sysClkRst = '1' then
            ref_counter <= 0 after TPD_G;
            ref_clk <= '0' after TPD_G;
         elsif ref_counter >= adc_refclk_t then
            ref_counter <= 0 after TPD_G;
            ref_clk <= not ref_clk after TPD_G;
         else
            ref_counter <= ref_counter + 1 after TPD_G;
         end if;
      end if;
   end process;
   adcRefClk <= ref_clk;
   ref_clk_en <= '1' when ref_clk = '1' and ref_counter >= adc_refclk_t else '0';

   -- Drdy sync and falling edge detector
   process ( sysClk )
   begin
      if rising_edge(sysClk) then
         if sysClkRst = '1' then
            adcDrdyD1 <= '0' after TPD_G;
            adcDrdyD2 <= '0' after TPD_G;
            adcStartD1 <= '0' after TPD_G;
            adcStartD2 <= '0' after TPD_G;
            spi_rd_en_d1 <= '0' after TPD_G;
         else
            adcDrdyD1 <= adcDrdy after TPD_G;
            adcDrdyD2 <= adcDrdyD1 after TPD_G;
            adcStartD1 <= adcStart after TPD_G;
            adcStartD2 <= adcStartD1 after TPD_G;
            spi_rd_en_d1 <= spi_rd_en after TPD_G;
         end if;
      end if;
   end process;

   adcDrdyEn <= adcDrdyD2 and not adcDrdyD1;
   adcStartEn <= adcStartD1 and not adcStartD2;
   spiRdEn    <= spi_rd_en and not spi_rd_en_d1;

   -- Instance of the SPI Master controller
   SPI_Master_i: entity surf.SpiMaster
      generic map (
         TPD_G             => TPD_G,
         NUM_CHIPS_G       => 1,
         DATA_SIZE_G       => 8,
         CPHA_G            => '1',
         CPOL_G            => '1',
         CLK_PERIOD_G      => SYS_CLK_PERIOD_G,
         SPI_SCLK_PERIOD_G => SPI_SCLK_PERIOD_G
      )
      port map (
         --Global Signals
         clk      => sysClk,
         sRst     => sysClkRst,
         -- Parallel interface
         chipSel  => "0",
         wrEn     => spi_wr_en,
         wrData   => spi_wr_data,
         rdEn     => spi_rd_en,
         rdData   => spi_rd_data,
         --SPI interface
         --spiCsL(0)=> adcCsL,
         spiCsL(0)=> csl_master,
         spiSclk  => adcSclk,
         spiSdi   => adcDin,
         spiSdo   => adcDout
      );

      adcCsL <= csl_master and csl_cmd;

   -- keep CS low when within one command
   csl_cmd <= '0';

   dbg_cmdcnter <= csl_master &
        csl_cmd &
        spi_rd_en &
        wait_done &
        ref_clk_en &
        "000" &
        mdec1_reg &
        std_logic_vector(to_unsigned(ch_counter, 8)) &
        std_logic_vector(to_unsigned(cmd_counter, 8));

   -- selsct command to be transimitted to the ADC
   spi_wr_data <=
      cmd_reset               when cmd_counter = 0 else    -- write reset command
      cmd_wr_reg & "0000"     when cmd_counter = 1 else    -- write register command starting from reg 0
      "00001001"              when cmd_counter = 2 else    -- write register command write 10 registers
      adc_setup_regs(0)       when cmd_counter = 3 else    -- write registers 0 to 9
      ch_sel & "1000"         when cmd_counter = 4 else    -- write register data with selected ain
      adc_setup_regs(2)       when cmd_counter = 5 else
      adc_setup_regs(3)       when cmd_counter = 6 else
      adc_setup_regs(4)       when cmd_counter = 7 else
      adc_setup_regs(5)       when cmd_counter = 8 else
      "00000000"              when cmd_counter = 9 else    -- DIO
      adc_setup_regs(7)       when cmd_counter = 10 else
      adc_setup_regs(8)       when cmd_counter = 11 else
      adc_setup_regs(9)       when cmd_counter = 12 else
      cmd_dsync               when cmd_counter = 13 else    -- write dsync command
      "00011001"              when cmd_counter = 14 else    -- read register 09h
      "00000000"              when cmd_counter = 15 else    -- only one reg
      "00000000"              when cmd_counter = 16 else
      --"00000000"              when cmd_counter = 14 else    -- write zeros to release reset (see ADC doc.)
      cmd_rdata               when cmd_counter = 17 else    -- write RDATA command
      "00000000";

   -- after command delay counter
   wait_cnt_p: process ( sysClk )
   begin
      if rising_edge(sysClk) then
         if sysClkRst = '1' then
            wait_counter <= 0 after TPD_G;
         elsif wait_load = '1' then
            wait_counter <= wait_data after TPD_G;
         elsif wait_done = '0' and ref_clk_en = '1' then
            wait_counter <= wait_counter - 1 after TPD_G;
         end if;
      end if;
   end process;
   wait_done <= '1' when wait_counter = 0 else '0';
   wait_data <=
      reset_wait_t      when cmd_counter = 0  and SIMULATION_G = FALSE else    -- tosc delay after reset cmd
      sim_wait_t        when cmd_counter = 0  and SIMULATION_G = TRUE  else    -- tosc delay after reset cmd (simulation)
      wreg_wait_t       when cmd_counter = 13 and SIMULATION_G = FALSE else    -- tosc delay after dsync
      sim_wait_t        when cmd_counter = 13 and SIMULATION_G = TRUE  else    -- tosc delay after dsync (simulation)
      dout_wait_t       when cmd_counter = 15 and SIMULATION_G = FALSE else    -- tosc delay after rdata cmd
      sim_wait_t        when cmd_counter = 15 and SIMULATION_G = TRUE  else    -- tosc delay after rdata cmd (simulation)
      dout_wait_t       when cmd_counter = 17 and SIMULATION_G = FALSE else    -- tosc delay after rdata cmd
      sim_wait_t        when cmd_counter = 17 and SIMULATION_G = TRUE  else    -- tosc delay after rdata cmd (simulation)
      0;

   ch_sel <= CONV_STD_LOGIC_VECTOR(ch_counter, 4);

   -- Readout loop FSM

   fsm_cmb_p: process (sysClk)
   begin

      if rising_edge(sysClk) then

          if sysClkRst = '1' then
            state <= RESET;
          else

              cmd_en <= '0';
              cmd_load <= '0';
              spi_wr_en <= '0';
              wait_load <= '0';


              case state is

                 when RESET =>           -- command 0 (reset) only after power up
                    cmd_counter <= 0;
                    ch_counter <= 0;

                    if adcStartEn = '1' then
                       state    <= CMD_SEND;
                       allChRd  <= '0';
                    end if;

                 when IDLE =>            -- start from command 1
                    cmd_counter <= 1;

                    if adcStartEn = '1' or ch_counter /= 0 then
                       state <= CMD_SEND;
                       allChRd  <= '0';
                    end if;

                 when CMD_SEND =>        -- trigger the SPI master
                    spi_wr_en   <= '1';
                    wait_load   <= '1';
                    state       <= CMD_WAIT;

                 when CMD_WAIT =>        -- wait for the SPI master to finish
                    if spiRdEn = '1' then
                       state <= CMD_DLY;
                    end if;

                 when CMD_DLY =>                     -- wait required Tosc periods (see ADC doc.)
                    if wait_done = '1' then
                       if cmd_counter < 16 then      -- repeat send command up to DSYNC
                          cmd_counter <= cmd_counter + 1;
                          state   <= CMD_SEND;
                          
                       elsif cmd_counter = 16 then   -- after DSYNC must wait for DRDY
                          state   <= WAIT_DRDY;
                          
                       else                          -- after RDATA go to data readout
                          cmd_counter <= cmd_counter + 1;
                          state       <= READ_DATA;
                       end if;
                    end if;

                 when WAIT_DRDY =>          -- wait for DRDY and go to send RDATA command
                    --if adcDrdyEn = '1' or SIMULATION_G = True then
                    mdec1_reg <= spi_rd_data;
                    
                    if spi_rd_data(7) = '0' or SIMULATION_G = True then
                       state                 <= CMD_SEND;
                       byte_counter          <= 0;
                       data_23_16            <= (others => '0');
                       data_15_08            <= (others => '0');
                       adcData_r             <= (others => '0');
                       cmd_counter           <= cmd_counter + 1;
                    else
                       state                 <= CMD_SEND;
                       cmd_counter           <= 14;
                    end if;

                 when READ_DATA =>          -- trigger the SPI master for readout
                    spi_wr_en <= '1';
                    state <= STORE_DATA;

                 when STORE_DATA =>          -- wait for the readout to complete and repeat 3 times
                    if spiRdEn = '1' then
                       if byte_counter < 3 then
                          adcData_r    <= adcData_r(15 downto 0) & spi_rd_data;
                          state        <= READ_DATA;
                          byte_counter <= byte_counter + 1;
                          
                       else
                          state               <= IDLE;
                          adcData(ch_counter) <= adcData_r;

                          if ch_counter = 7 then
                            ch_counter <= 0;
                            allChRd    <= '1';
                          else
                            ch_counter <= ch_counter + 1;
                          end if;
                       
                       end if;
                    end if;

                 when others =>
                    state <= RESET;

              end case;
          end if;
       end if;
   end process;

end RTL;
