#-----------------------------------------------------------------------------
# This file is part of the 'ePix HR Camera Firmware'. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the 'SPACE SMURF MCU', including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

import pyrogue as pr

import surf.axi                  as axi
import surf.devices.transceivers as optics
import surf.protocols.pgp        as pgp
import surf.xilinx               as xil

import epix_hr_core

class SysReg(pr.Device):
    def __init__(self,
        sim  = False,
        pgp3 = True,
        **kwargs):

        super().__init__(**kwargs)

        self.add(epix_hr_core.AxiVersion(
            offset = 0x00000000,
        ))

        self.add(xil.AxiSysMonUltraScale(
            offset  = 0x01000000,
            enabled = (not sim),
        ))

        self.add(optics.Sff8472(
            name    = 'QSfpI2C',
            offset  = 0x03000000,
            enabled = (not sim),
        ))

        for i in range(4):
            if (pgp3):
                self.add(pgp.Pgp3AxiL(
                    name    = (f'PgpMon[{i}]'),
                    offset  = 0x05000000 + (i*0x10000),
                    numVc   = 4,
                    writeEn = False,
                    enabled = (not sim),
                ))

            else:
                self.add(pgp.Pgp2bAxi(
                    name    = (f'PgpMon[{i}]'),
                    offset  = 0x05000000 + (i*0x10000),
                    writeEn = False,
                    enabled = (not sim),
                ))
