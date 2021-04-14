#-----------------------------------------------------------------------------
# This file is part of the 'EPIX HR Firmware'. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the 'EPIX HR Firmware', including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------
import pyrogue     as pr

class AsicDeser10bDataRegisters(pr.Device):
    def __init__(self, **kwargs):
        super().__init__(description='10b data of 20 bit Deserializer Registers', **kwargs)

        #Setup registers & variables
        for i in range(0, 2):
            self.add(pr.RemoteVariable(
                name        = 'tenbData_'+str(i),
                description = 'Sample N_'+str(i),
                offset      = 0x00000000+i*4,
                bitSize     = 10,
                disp        = '{:#x}',
                mode        = 'RO',
            ))
