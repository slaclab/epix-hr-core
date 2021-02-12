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

class ProgrammablePowerSupplyCryo(pr.Device):
    def __init__(self, **kwargs):
        super().__init__(description='Two channel programmable power supply', **kwargs)

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
            pr.RemoteVariable(name='Vdd1',    description='',                  offset=0x00004, bitSize=16,   bitOffset=0,   base=pr.UInt, disp = '{:#x}', mode='RW'),
            pr.RemoteVariable(name='Vdd2',    description='',                  offset=0x00008, bitSize=16,   bitOffset=0,   base=pr.UInt, disp = '{:#x}', mode='RW'))
        )
        self.add((
            pr.LinkVariable  (name='Vdd1_V',         linkedGet=self.convtFloatP5p0,    dependencies=[self.Vdd1]),
            pr.LinkVariable  (name='Vdd2_V',         linkedGet=self.convtFloatP5p0,    dependencies=[self.Vdd2]))
        )


        #####################################
        # Create commands
        #####################################

        # A command has an associated function. The function can be a series of
        # python commands in a string. Function calls are executed in the command scope
        # the passed arg is available as 'arg'. Use 'dev' to get to device scope.
        # A command can also be a call to a local function with local scope.
        # The command object and the arg are passed


    @staticmethod
    def convtFloatP5p0(dev, var):
        value   = var.dependencies[0].get(read=False)
        fpValue = value*(5.0/65536.0)
        return '%0.3f'%(fpValue)

    @staticmethod
    def frequencyConverter(self):
        def func(dev, var):
            return '{:.3f} kHz'.format(1/(self.clkPeriod * self._count(var.dependencies)) * 1e-3)
        return func
