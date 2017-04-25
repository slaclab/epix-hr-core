-------------------------------------------------------------------------------
-- File       : MicroblazeBasicCoreBypass.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-04-25
-- Last update: 2017-04-25
-------------------------------------------------------------------------------
-- Description: Bypass Module
-------------------------------------------------------------------------------
-- This file is part of 'SLAC Firmware Standard Library'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC Firmware Standard Library', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;
use work.AxiLitePkg.all;
use work.SsiPkg.all;

entity MicroblazeBasicCoreWrapper is
   generic (
      TPD_G           : time    := 1 ns;
      AXIL_RESP_C     : boolean := false;
      AXIL_ADDR_MSB_C : boolean := false);
   port (
      -- Master AXI-Lite Interface
      mAxilWriteMaster : out AxiLiteWriteMasterType;
      mAxilWriteSlave  : in  AxiLiteWriteSlaveType;
      mAxilReadMaster  : out AxiLiteReadMasterType;
      mAxilReadSlave   : in  AxiLiteReadSlaveType;
      -- Master AXIS Interface
      sAxisMaster      : in  AxiStreamMasterType := AXI_STREAM_MASTER_INIT_C;
      sAxisSlave       : out AxiStreamSlaveType;
      -- Slave AXIS Interface
      mAxisMaster      : out AxiStreamMasterType;
      mAxisSlave       : in  AxiStreamSlaveType  := AXI_STREAM_SLAVE_FORCE_C;
      -- Interrupt Interface
      interrupt        : in  slv(7 downto 0)     := (others => '0');
      -- Clock and Reset
      clk              : in  sl;
      pllLock          : in  sl                  := '1';
      rst              : in  sl);
end MicroblazeBasicCoreWrapper;

architecture mapping of MicroblazeBasicCoreWrapper is

begin

   mAxilWriteMaster <= AXI_LITE_WRITE_MASTER_INIT_C;
   mAxilReadMaster  <= AXI_LITE_READ_MASTER_INIT_C;
   sAxisSlave       <= AXI_STREAM_SLAVE_FORCE_C;
   mAxisMaster      <= AXI_STREAM_MASTER_INIT_C;

end mapping;
