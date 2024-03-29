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

class HighSpeedDacRegisters(pr.Device):
    def __init__(self,HsDacEnum={0:'None',1:'DAC A (SE)',2:'DAC B (Diff)',3:'DAC A & DAC B',}, DacModel='8812', MaximumDacValue = 32000,**kwargs):
        super().__init__(description='HS DAC Registers', **kwargs)

        # Creation. memBase is either the register bus server (srp, rce mapped memory, etc) or the device which
        # contains this object. In most cases the parent and memBase are the same but they can be
        # different in more complex bus structures. They will also be different for the top most node.
        # The setMemBase call can be used to update the memBase for this Device. All sub-devices and local
        # blocks will be updated.

        #############################################
        # Create block / variable combinations
        #############################################

        bitSize = 16
        convFunc = self.convtFloat8812
        if (DacModel == 'Max5719a'):
            bitSize = 20
            convFunc = self.convtFloatMax5719a

        #Setup registers & variables

        self.add((
            pr.RemoteVariable(name='WFEnabled',       description='Enable waveform generation',                        offset=0x00000000, bitSize=1,   bitOffset=0,   base=pr.Bool, mode='RW'),
            pr.RemoteVariable(name='run',             description='Generates waveform when true',                      offset=0x00000000, bitSize=1,   bitOffset=1,   base=pr.Bool, mode='RW'),
            pr.RemoteVariable(name='externalUpdateEn',description='Updates value on AcqStart',                         offset=0x00000000, bitSize=1,   bitOffset=2,   base=pr.Bool, mode='RW'),
            pr.RemoteVariable(name='waveformSource',  description='Selects between custom wf or internal ramp',        offset=0x00000000, bitSize=2,   bitOffset=3,   base=pr.UInt, mode='RW', enum={0: "CustomWF", 1: "RampCounter"}),
            pr.RemoteVariable(name='samplingCounter', description='Sampling period (>269, times 1/clock ref. 156MHz)', offset=0x00000004, bitSize=12,  bitOffset=0,   base=pr.UInt, disp = '{:#x}', mode='RW'),
            pr.RemoteVariable(name='DacValue',        description='Set a fixed value for the DAC',                     offset=0x00000008, bitSize=bitSize,  bitOffset=0,   base=pr.UInt, disp = '{:#x}', mode='RW', maximum = MaximumDacValue)
        ))

        self.add((pr.LinkVariable  (name='DacValueV' ,      linkedGet=convFunc,        dependencies=[self.DacValue])))

        if (DacModel != 'Max5719a'):
            self.add((pr.RemoteVariable(name='DacChannel',      description='Select the DAC channel to use',                     offset=0x00000008, bitSize=2,   bitOffset=bitSize,  mode='RW', enum=HsDacEnum)))

        self.add((
            pr.RemoteVariable(name='rCStartValue',    description='Internal ramp generator start value',               offset=0x00000010, bitSize=bitSize,  bitOffset=0,   base=pr.UInt, disp = '{:#x}', mode='RW', maximum = MaximumDacValue),
            pr.RemoteVariable(name='rCStopValue',     description='Internal ramp generator stop value',                offset=0x00000014, bitSize=bitSize,  bitOffset=0,   base=pr.UInt, disp = '{:#x}', mode='RW', maximum = MaximumDacValue),
            pr.RemoteVariable(name='rCStep',          description='Internal ramp generator step value',                offset=0x00000018, bitSize=bitSize,  bitOffset=0,   base=pr.UInt, disp = '{:#x}', mode='RW'),
            pr.RemoteVariable(name='dacValueRBV',     description='Current DAC value',                                 offset=0x0000001C, bitSize=bitSize,  bitOffset=0,   base=pr.UInt, disp = '{:#x}', mode='RO', pollInterval = 1)
        ))

        self.add((pr.LinkVariable  (name='DacValueVRBV' ,      linkedGet=convFunc,        dependencies=[self.dacValueRBV])))

        #####################################
        # Create commands
        #####################################

        # A command has an associated function. The function can be a series of
        # python commands in a string. Function calls are executed in the command scope
        # the passed arg is available as 'arg'. Use 'dev' to get to device scope.
        # A command can also be a call to a local function with local scope.
        # The command object and the arg are passed


    @staticmethod
    def convtFloat8812(dev, var):
        value   = var.dependencies[0].get(read=False)
        fpValue = value*(2.3/65536.0) # Modified from 2.5 to 2.3 due to the bug on the PCB Bandgap
        return '%0.3f'%(fpValue)

    @staticmethod
    def convtFloatMax5719a(dev, var):
        value   = var.dependencies[0].get(read=False)
        fpValue = value*(2.5/1048576.0)
        return '%0.3f'%(fpValue)

    @staticmethod
    def frequencyConverter(self):
        def func(dev, var):
            return '{:.3f} kHz'.format(1/(self.clkPeriod * self._count(var.dependencies)) * 1e-3)
        return func
