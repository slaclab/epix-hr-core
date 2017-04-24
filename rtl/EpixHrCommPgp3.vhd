-------------------------------------------------------------------------------
-- File       : EpixHrCommPgp3.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-04-24
-- Last update: 2017-04-24
-------------------------------------------------------------------------------
-- Description: Wrapper for PGP3 communication
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

library unisim;
use unisim.vcomponents.all;

entity EpixHrCommPgp3 is
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
end EpixHrCommPgp3;

architecture mapping of EpixHrCommPgp3 is

begin

   -- Placeholder for future code
   mAxilReadMaster  <= AXI_LITE_READ_MASTER_INIT_C;
   mAxilWriteMaster <= AXI_LITE_WRITE_MASTER_INIT_C;
   sAxisSlaves      <= (others => AXI_STREAM_SLAVE_FORCE_C);
   qsfpTxP          <= (others => '0');
   qsfpTxN          <= (others => '1');
   U_AxiLiteEmpty : entity work.AxiLiteEmpty
      generic map (
         TPD_G            => TPD_G,
         AXI_ERROR_RESP_G => AXI_ERROR_RESP_G)
      port map (
         axiClk         => sysClk,
         axiClkRst      => sysRst,
         axiReadMaster  => axilReadMaster,
         axiReadSlave   => axilReadSlave,
         axiWriteMaster => axilWriteMaster,
         axiWriteSlave  => axilWriteSlave);

end mapping;
