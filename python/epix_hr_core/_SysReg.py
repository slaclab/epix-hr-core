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

import epix_hr_core as epixHr

import surf.devices.transceivers as optics
import surf.protocols.pgp        as pgp
import surf.xilinx               as xil
import surf.devices.micron       as micron

class SysReg(pr.Device):
    def __init__(self,
        sim        = False,
        pgpVersion = 4,
    **kwargs):

        super().__init__(**kwargs)

        self.add(epixHr.AxiVersion(
            offset = 0x00000000,
        ))

        self.add(xil.AxiSysMonUltraScale(
            offset  = 0x01000000,
            enabled = (not sim),
        ))

        self.add(micron.AxiMicronN25Q(
            name     = "MicronN25Q",
            offset   = 0x02000000,
            addrMode = True,
            expand   = False,
            hidden   = True,
            enabled  = (not sim),
        ))

        self.add(optics.Qsfp(
            name    = 'QSfpI2C',
            offset  = 0x03000000,
            enabled = (not sim),
        ))

        if pgpVersion == 4:
            pgpMonDev = pgp.Pgp4AxiL
        elif pgpVersion == 3:
            pgpMonDev = pgp.Pgp3AxiL
        elif pgpVersion == 2:
            pgpMonDev = pgp.Pgp2bAxi

        for i in range(4):
            self.add(pgpMonDev(
                name    = (f'Pgp{pgpVersion}Mon[{i}]'),
                offset  = 0x05000000 + (i*0x10000),
                numVc   = 4,
                writeEn = False,
                enabled = (not sim),
            ))
