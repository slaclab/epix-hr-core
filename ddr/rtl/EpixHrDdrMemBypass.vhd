-------------------------------------------------------------------------------
-- File       : EpixHrDdrMem.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-04-21
-- Last update: 2017-04-25
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

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiPkg.all;
use work.EpixHrCorePkg.all;

entity EpixHrDdrMem is
   generic (
      TPD_G            : time            := 1 ns;
      AXI_ERROR_RESP_G : slv(1 downto 0) := AXI_RESP_SLVERR_C);
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

begin

   sAxiReadSlave  <= AXI_READ_SLAVE_FORCE_C;
   sAxiWriteSlave <= AXI_WRITE_SLAVE_FORCE_C;

   ddrBg    <= '1';
   ddrCkP   <= '0';
   ddrCkN   <= '1';
   ddrCke   <= '1';
   ddrCsL   <= '1';
   ddrOdt   <= '1';
   ddrAct   <= '1';
   ddrRstL  <= '1';
   ddrA     <= (others => '1');
   ddrBa    <= (others => '1');
   ddrPwrEn <= '0';

   U_AxiLiteEmpty : entity work.AxiLiteEmpty
      generic map (
         TPD_G            => TPD_G,
         AXI_ERROR_RESP_G => AXI_ERROR_RESP_G)
      port map (
         axiClk         => clk,
         axiClkRst      => rst,
         axiReadMaster  => axilReadMaster,
         axiReadSlave   => axilReadSlave,
         axiWriteMaster => axilWriteMaster,
         axiWriteSlave  => axilWriteSlave);

end mapping;
