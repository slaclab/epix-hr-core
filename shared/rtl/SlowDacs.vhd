-------------------------------------------------------------------------------
-- File       : RegControlEpixHR.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: EpixHR register controller
-------------------------------------------------------------------------------
-- This file is part of 'EpixHR Development Firmware'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'EpixHR Development Firmware', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;

library epix_hr_core;

library unisim;
use unisim.vcomponents.all;

entity SlowDacs is
   generic (
      TPD_G             : time              := 1 ns;
      CLK_PERIOD_G      : real              := 10.0e-9;
      AXIL_ERR_RESP_G   : slv(1 downto 0)   := AXI_RESP_OK_C
   );
   port (
      -- Global Signals
      axiClk         : in  sl;
      axiRst         : in  sl;
      -- AXI-Lite Register Interface (axiClk domain)
      axiReadMaster  : in  AxiLiteReadMasterType;
      axiReadSlave   : out AxiLiteReadSlaveType;
      axiWriteMaster : in  AxiLiteWriteMasterType;
      axiWriteSlave  : out AxiLiteWriteSlaveType;
      -- Guard ring DAC interfaces
      dacSclk        : out sl;
      dacDin         : out sl;
      dacCsb         : out slv(4 downto 0);
      dacClrb        : out sl
   );
end SlowDacs;

architecture rtl of SlowDacs is

   type RegType is record
      vDacSetting       : Slv16Array(4 downto 0);
      dummy             : slv(31 downto 0);
      axiReadSlave      : AxiLiteReadSlaveType;
      axiWriteSlave     : AxiLiteWriteSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      vDacSetting       => (others => (others=>'0')),
      dummy             => x"DEADF00D",
      axiReadSlave      => AXI_LITE_READ_SLAVE_INIT_C,
      axiWriteSlave     => AXI_LITE_WRITE_SLAVE_INIT_C
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal axiReset : sl;

   signal dacDinSig  : slv(4 downto 0);  -- common signals
   signal dacSclkSig : slv(4 downto 0);  -- common signals
   signal dacClrbSig : slv(4 downto 0);  -- common signals

begin

   axiReset <= axiRst;
   dacDin   <= dacDinSig(0)  or dacDinSig(1)  or dacDinSig(2)  or dacDinSig(3)  or dacDinSig(4);
   dacSclk  <= dacSclkSig(0) or dacSclkSig(1) or dacSclkSig(2) or dacSclkSig(3) or dacSclkSig(4);
   dacClrb  <= dacClrbSig(0) or dacClrbSig(1) or dacClrbSig(2) or dacClrbSig(3) or dacClrbSig(4);

   -------------------------------
   -- Configuration Register
   -------------------------------
   comb : process (axiReadMaster, axiReset, axiWriteMaster, r) is
      variable v           : RegType;
      variable regCon      : AxiLiteEndPointType;

   begin
      -- Latch the current value
      v := r;

      -- Reset data and strobes

      -- Determine the transaction type
      axiSlaveWaitTxn(regCon, axiWriteMaster, axiReadMaster, v.axiWriteSlave, v.axiReadSlave);

      -- Map out standard registers
      axiSlaveRegister(regCon,  x"000000",  0, v.vDacSetting(0)); -- Guard ring dac
      axiSlaveRegister(regCon,  x"000004",  0, v.vDacSetting(1));
      axiSlaveRegister(regCon,  x"000008",  0, v.vDacSetting(2));
      axiSlaveRegister(regCon,  x"00000C",  0, v.vDacSetting(3));
      axiSlaveRegister(regCon,  x"000010",  0, v.vDacSetting(4)); -- dac that generates Vocm for HS dac
      axiSlaveRegister(regCon,  x"000014",  0, v.dummy);

      axiSlaveDefault(regCon, v.axiWriteSlave, v.axiReadSlave, AXIL_ERR_RESP_G);

      -- Synchronous Reset
      if axiReset = '1' then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

      axiWriteSlave   <= r.axiWriteSlave;
      axiReadSlave    <= r.axiReadSlave;

   end process comb;

   seq : process (axiClk) is
   begin
      if rising_edge(axiClk) then
         r <= rin after TPD_G;
      end if;
   end process seq;

   -----------------------------------------------
   -- DAC Controller
   -----------------------------------------------
   G_MAX5443 : for i in 0 to 4 generate
       U_DacCntrl : entity epix_hr_core.DacCntrl
       generic map (
          TPD_G => TPD_G
       )
       port map (
          sysClk      => axiClk,
          sysClkRst   => axiReset,
          dacData     => r.vDacSetting(i),
          dacDin      => dacDinSig(i),
          dacSclk     => dacSclkSig(i),
          dacCsL      => dacCsb(i),
          dacClrL     => dacClrbSig(i)
       );
   end generate;

end rtl;
