-------------------------------------------------------------------------------
-- File       : EpixHrCorePkg.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-04-21
-- Last update: 2017-04-24
-------------------------------------------------------------------------------
-- Description: Application's Package File
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

use work.StdRtlPkg.all;
use work.AxiPkg.all;
use work.AxiStreamPkg.all;
use work.SsiPkg.all;

package EpixHrCorePkg is

   constant SYSCLK_FREQ_C   : real := 156.25E+6;
   constant SYSCLK_PERIOD_C : real := (1.0/SYSCLK_FREQ_C);
   
   constant COMM_AXIS_CONFIG_C : AxiStreamConfigType := ssiAxiStreamConfig(16); -- Make this constant to match or be bigger than the protocol bus width (PGP2b 2B min)

   constant DDR_AXI_CONFIG_C : AxiConfigType := (
      ADDR_WIDTH_C => 30,
      DATA_BYTES_C => 32,
      ID_BITS_C    => 4,
      LEN_BITS_C   => 8);

   type CommModeType is (
      COMM_MODE_PGP2B_C,
      COMM_MODE_PGP3_C,
      COMM_MODE_1GbE_C,
      COMM_MODE_10GbE_C);

end package EpixHrCorePkg;

package body EpixHrCorePkg is

end package body EpixHrCorePkg;
