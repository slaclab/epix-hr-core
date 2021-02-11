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

##############################################################
##
## Clock Jitter Cleaner
##
##############################################################
class ClockJitterCleanerRegisters(pr.Device):
    def __init__(self, **kwargs):
        super().__init__(description='Clock jitter cleaner Registers', **kwargs)

        # Creation. memBase is either the register bus server (srp, rce mapped memory, etc) or the device which
        # contains this object. In most cases the parent and memBase are the same but they can be
        # different in more complex bus structures. They will also be different for the top most node.
        # The setMemBase call can be used to update the memBase for this Device. All sub-devices and local
        # blocks will be updated.

        #############################################
        # Create block / variable combinations
        #############################################


        #Setup registers & variables

        self.add((
            pr.RemoteVariable(name='Lol',           description='Loss of Lock',                         offset=0x00000000, bitSize=1,   bitOffset=0,   base=pr.Bool, mode='RO'),
            pr.RemoteVariable(name='Los',           description='Loss of Signal',                       offset=0x00000000, bitSize=1,   bitOffset=1,   base=pr.Bool, mode='RO'),
            pr.RemoteVariable(name='RstL',          description='Reset active low',                     offset=0x00000004, bitSize=1,   bitOffset=0,   base=pr.Bool, mode='RW'),
            pr.RemoteVariable(name='Dec',           description='Skew decrement',                       offset=0x00000004, bitSize=1,   bitOffset=2,   base=pr.Bool, mode='RW'),
            pr.RemoteVariable(name='Inc',           description='Skew increment',                       offset=0x00000004, bitSize=1,   bitOffset=4,   base=pr.Bool, mode='RW'),
            pr.RemoteVariable(name='Frqtbl',        description='Frequency table select',               offset=0x00000004, bitSize=1,   bitOffset=6,   base=pr.Bool, mode='RW'),
            pr.RemoteVariable(name='FrqtblZ',       description='Tri-state driver',                     offset=0x00000004, bitSize=1,   bitOffset=7,   base=pr.Bool, mode='RW'),
            pr.RemoteVariable(name='Rate',          description='Rate selection',                       offset=0x00000008, bitSize=2,   bitOffset=0,   base=pr.UInt, disp = '{:#x}', mode='RW'),
            pr.RemoteVariable(name='RateZ',         description='Tri-state driver',                     offset=0x00000008, bitSize=2,   bitOffset=2,   base=pr.UInt, disp = '{:#x}', mode='RW'),
            pr.RemoteVariable(name='BwSel',         description='Loop bandwidth select',                offset=0x0000000C, bitSize=2,   bitOffset=0,   base=pr.UInt, disp = '{:#x}', mode='RW'),
            pr.RemoteVariable(name='BwSelZ',        description='Tri-state driver',                     offset=0x0000000C, bitSize=2,   bitOffset=2,   base=pr.UInt, disp = '{:#x}', mode='RW'),
            pr.RemoteVariable(name='FreqSel',       description='Frequency Select',                     offset=0x00000010, bitSize=4,   bitOffset=0,   base=pr.UInt, disp = '{:#x}', mode='RW'),
            pr.RemoteVariable(name='FreqSelZ',      description='Tri-state driver',                     offset=0x00000010, bitSize=4,   bitOffset=4,   base=pr.UInt, disp = '{:#x}', mode='RW'),
            pr.RemoteVariable(name='Sfout',         description='Signal format select',                 offset=0x00000014, bitSize=2,   bitOffset=0,   base=pr.UInt, disp = '{:#x}', mode='RW'),
            pr.RemoteVariable(name='SfoutZ',        description='Tri-state driver',                     offset=0x00000014, bitSize=2,   bitOffset=2,   base=pr.UInt, disp = '{:#x}', mode='RW')))



        #####################################
        # Create commands
        #####################################

        # A command has an associated function. The function can be a series of
        # python commands in a string. Function calls are executed in the command scope
        # the passed arg is available as 'arg'. Use 'dev' to get to device scope.
        # A command can also be a call to a local function with local scope.
        # The command object and the arg are passed


    @staticmethod
    def frequencyConverter(self):
        def func(dev, var):
            return '{:.3f} kHz'.format(1/(self.clkPeriod * self._count(var.dependencies)) * 1e-3)
        return func
