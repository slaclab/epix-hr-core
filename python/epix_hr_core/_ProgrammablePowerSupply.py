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

class ProgrammablePowerSupply(pr.Device):
    def __init__(self, **kwargs):
        super().__init__(description='Slow DAC Registers', **kwargs)

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
            pr.RemoteVariable(name='MVddAsic_dac_0',    description='',                  offset=0x00004, bitSize=16,   bitOffset=0,   base=pr.UInt, disp = '{:#x}', mode='RW'),
            pr.RemoteVariable(name='MVh_dac_1',         description='',                  offset=0x00008, bitSize=16,   bitOffset=0,   base=pr.UInt, disp = '{:#x}', mode='RW'),
            pr.RemoteVariable(name='MVbias_dac_2',      description='',                  offset=0x0000c, bitSize=16,   bitOffset=0,   base=pr.UInt, disp = '{:#x}', mode='RW'),
            pr.RemoteVariable(name='MVm_dac_3',         description='',                  offset=0x00010, bitSize=16,   bitOffset=0,   base=pr.UInt, disp = '{:#x}', mode='RW'),
            pr.RemoteVariable(name='MVdd_det_dac_4',    description='',                  offset=0x00014, bitSize=16,   bitOffset=0,   base=pr.UInt, disp = '{:#x}', mode='RW'))
        )
        self.add((
            pr.LinkVariable  (name='MVddAsic' ,         linkedGet=self.convtFloatP10p0,   dependencies=[self.MVddAsic_dac_0]),
            pr.LinkVariable  (name='MVh' ,              linkedGet=self.convtFloatP7p0,    dependencies=[self.MVh_dac_1]),
            pr.LinkVariable  (name='MVbias' ,           linkedGet=self.convtFloatP7p0,    dependencies=[self.MVbias_dac_2]),
            pr.LinkVariable  (name='MVm' ,              linkedGet=self.convtFloatM2p5,    dependencies=[self.MVm_dac_3]),
            pr.LinkVariable  (name='MVdd' ,             linkedGet=self.convtFloatP10p0,   dependencies=[self.MVdd_det_dac_4]))
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
    def convtFloatP10p0(dev, var):
        value   = var.dependencies[0].get(read=False)
        fpValue = value*(10.0/65536.0)
        return '%0.3f'%(fpValue)


    @staticmethod
    def convtFloatM2p5(dev, var):
        value   = var.dependencies[0].get(read=False)
        fpValue = value*(-2.5/65536.0)
        return '%0.3f'%(fpValue)


    @staticmethod
    def convtFloatP7p0(dev, var):
        value   = var.dependencies[0].get(read=False)
        fpValue = value*(7.0/65536.0)
        return '%0.3f'%(fpValue)


    @staticmethod
    def frequencyConverter(self):
        def func(dev, var):
            return '{:.3f} kHz'.format(1/(self.clkPeriod * self._count(var.dependencies)) * 1e-3)
        return func
