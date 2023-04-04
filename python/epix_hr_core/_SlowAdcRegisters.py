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

class SlowAdcRegisters(pr.Device):
    def __init__(self, AdcChannelEnum = [], **kwargs):
        super().__init__(description='Monitoring Slow ADC Registers', **kwargs)

        # Creation. memBase is either the register bus server (srp, rce mapped memory, etc) or the device which
        # contains this object. In most cases the parent and memBase are the same but they can be
        # different in more complex bus structures. They will also be different for the top most node.
        # The setMemBase call can be used to update the memBase for this Device. All sub-devices and local
        # blocks will be updated.

        #############################################
        # Create block / variable combinations
        #############################################
        if not AdcChannelEnum:
            AdcChannelEnum = ["Temp1", "Temp2", "Humidity", "AsicAnalogCurr", "AsicDigitalCurr", "AsicVguardCurr", "Unused", "AnalogVin","DigitalVin" ]

        #Setup registers & variables

        self.add(pr.RemoteVariable(name='StreamEn',        description='StreamEn',          offset=0x00000000, bitSize=1,  bitOffset=0, base=pr.Bool, mode='RW'))
        self.add(pr.RemoteVariable(name='StreamPeriod',    description='StreamPeriod',      offset=0x00000004, bitSize=32, bitOffset=0, base=pr.UInt, disp = '{}', mode='RW'))
        self.add(pr.RemoteVariable(name='AdcData0',        description='RawAdcData',        offset=0x00000040, bitSize=24, bitOffset=0, base=pr.UInt, disp = '{:#x}',  mode='RO'))
        self.add(pr.RemoteVariable(name='AdcData1',        description='RawAdcData',        offset=0x00000044, bitSize=24, bitOffset=0, base=pr.UInt, disp = '{:#x}',  mode='RO'))
        self.add(pr.RemoteVariable(name='AdcData2',        description='RawAdcData',        offset=0x00000048, bitSize=24, bitOffset=0, base=pr.UInt, disp = '{:#x}',  mode='RO'))
        self.add(pr.RemoteVariable(name='AdcData3',        description='RawAdcData',        offset=0x0000004C, bitSize=24, bitOffset=0, base=pr.UInt, disp = '{:#x}',  mode='RO'))
        self.add(pr.RemoteVariable(name='AdcData4',        description='RawAdcData',        offset=0x00000050, bitSize=24, bitOffset=0, base=pr.UInt, disp = '{:#x}',  mode='RO'))
        self.add(pr.RemoteVariable(name='AdcData5',        description='RawAdcData',        offset=0x00000054, bitSize=24, bitOffset=0, base=pr.UInt, disp = '{:#x}',  mode='RO'))
        self.add(pr.RemoteVariable(name='AdcData6',        description='RawAdcData',        offset=0x00000058, bitSize=24, bitOffset=0, base=pr.UInt, disp = '{:#x}',  mode='RO'))
        self.add(pr.RemoteVariable(name='AdcData7',        description='RawAdcData',        offset=0x0000005C, bitSize=24, bitOffset=0, base=pr.UInt, disp = '{:#x}',  mode='RO'))
        self.add(pr.RemoteVariable(name='AdcData8',        description='RawAdcData',        offset=0x00000060, bitSize=24, bitOffset=0, base=pr.UInt, disp = '{:#x}',  mode='RO'))

        self.add(pr.RemoteVariable(name='EnvData0',        description=AdcChannelEnum[0],   offset=0x00000080, bitSize=32, bitOffset=0, base=pr.UInt, disp = '{}',  mode='RO'))
        self.add(pr.RemoteVariable(name='EnvData1',        description=AdcChannelEnum[1],   offset=0x00000084, bitSize=32, bitOffset=0, base=pr.Int,  mode='RO'))
        self.add(pr.RemoteVariable(name='EnvData2',        description=AdcChannelEnum[2],   offset=0x00000088, bitSize=32, bitOffset=0, base=pr.UInt, disp = '{}', mode='RO'))
        self.add(pr.RemoteVariable(name='EnvData3',        description=AdcChannelEnum[3],   offset=0x0000008C, bitSize=32, bitOffset=0, base=pr.UInt, disp = '{}', mode='RO'))
        self.add(pr.RemoteVariable(name='EnvData4',        description=AdcChannelEnum[4],   offset=0x00000090, bitSize=32, bitOffset=0, base=pr.UInt, disp = '{}', mode='RO'))
        self.add(pr.RemoteVariable(name='EnvData5',        description=AdcChannelEnum[5],   offset=0x00000094, bitSize=32, bitOffset=0, base=pr.UInt, disp = '{}', mode='RO'))
        self.add(pr.RemoteVariable(name='EnvData6',        description=AdcChannelEnum[6],   offset=0x00000098, bitSize=32, bitOffset=0, base=pr.UInt, disp = '{}', mode='RO'))
        self.add(pr.RemoteVariable(name='EnvData7',        description=AdcChannelEnum[7],   offset=0x0000009C, bitSize=32, bitOffset=0, base=pr.UInt, disp = '{}', mode='RO'))
        self.add(pr.RemoteVariable(name='EnvData8',        description=AdcChannelEnum[8],   offset=0x000000A0, bitSize=32, bitOffset=0, base=pr.UInt, disp = '{}', mode='RO'))



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
