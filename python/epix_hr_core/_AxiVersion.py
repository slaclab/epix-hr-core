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
import surf.axi    as axi

class AxiVersion(axi.AxiVersion):
    def __init__(self,**kwargs):
        super().__init__(**kwargs)

        self.add(pr.RemoteVariable(
            name         = 'snCarrier',
            offset       = 0x400+(4*0),
            bitSize      = 64,
            mode         = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name         = 'snAdcCard',
            offset       = 0x400+(4*2),
            bitSize      = 64,
            mode         = 'RO',
        ))
