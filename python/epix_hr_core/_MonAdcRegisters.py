#-----------------------------------------------------------------------------
# This file is part of the 'EPIX HR Firmware'. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the 'EPIX HR Firmware', including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------
import pyrogue as pr
import numpy   as np

class MonAdcRegisters(pr.Device):
    def __init__(self,  **kwargs):
        super().__init__(description='Virtual Oscilloscope Registers', **kwargs)

        # Creation. memBase is either the register bus server (srp, rce mapped memory, etc) or the device which
        # contains this object. In most cases the parent and memBase are the same but they can be
        # different in more complex bus structures. They will also be different for the top most node.
        # The setMemBase call can be used to update the memBase for this Device. All sub-devices and local
        # blocks will be updated.

        #############################################
        # Create block / variable combinations
        #############################################


        #Setup registers & variables
        self.add(pr.RemoteVariable(name='DelayAdc0_', description='Data ADC Idelay3 value', offset=0x00000000, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.RemoteVariable(name='DelayAdc1_', description='Data ADC Idelay3 value', offset=0x00000004, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.RemoteVariable(name='DelayAdc2_', description='Data ADC Idelay3 value', offset=0x00000008, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.RemoteVariable(name='DelayAdc3_', description='Data ADC Idelay3 value', offset=0x0000000C, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.RemoteVariable(name='DelayAdcF_', description='Data ADC Idelay3 value', offset=0x00000020, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.LinkVariable(  name='DelayAdc0',      description='Data ADC Idelay3 value',       linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.DelayAdc0_]))
        self.add(pr.LinkVariable(  name='DelayAdc1',      description='Data ADC Idelay3 value',       linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.DelayAdc1_]))
        self.add(pr.LinkVariable(  name='DelayAdc2',      description='Data ADC Idelay3 value',       linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.DelayAdc2_]))
        self.add(pr.LinkVariable(  name='DelayAdc3',      description='Data ADC Idelay3 value',       linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.DelayAdc3_]))
        self.add(pr.LinkVariable(  name='DelayAdcFrame',  description='Data ADC Idelay3 value',       linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.DelayAdcF_]))

        self.add(pr.RemoteVariable(name='lockedFallCount',    description='Frame ADC Idelay3 value',              offset=0x00000030, bitSize=16, bitOffset=0,  base=pr.UInt, disp = '{}', mode='RO'))
        self.add(pr.RemoteVariable(name='lockedSync',         description='Frame ADC Idelay3 value',              offset=0x00000030, bitSize=1,  bitOffset=16, base=pr.Bool, mode='RO'))
        self.add(pr.RemoteVariable(name='AdcFrameSync',       description='Frame ADC Idelay3 value',              offset=0x00000034, bitSize=14, bitOffset=0,  base=pr.UInt, disp = '{:#x}', mode='RO'))
        self.add(pr.RemoteVariable(name='lockedCountRst',     description='Frame ADC Idelay3 value',              offset=0x00000038, bitSize=1,  bitOffset=0,  base=pr.Bool, mode='RW'))

        self.add(pr.RemoteVariable(name='Adc0_0',             description='ADC data  value',pollInterval = 1,     offset=0x00000080, bitSize=16,  bitOffset=0, base=pr.UInt, disp = '{:#x}', mode='RO'))
        self.add(pr.RemoteVariable(name='Adc0_1',             description='ADC data  value',pollInterval = 1,     offset=0x00000080, bitSize=16,  bitOffset=16,base=pr.UInt, disp = '{:#x}', mode='RO'))
        self.add(pr.RemoteVariable(name='Adc1_0',             description='ADC data  value',pollInterval = 1,     offset=0x00000084, bitSize=16,  bitOffset=0, base=pr.UInt, disp = '{:#x}', mode='RO'))
        self.add(pr.RemoteVariable(name='Adc1_1',             description='ADC data  value',pollInterval = 1,     offset=0x00000084, bitSize=16,  bitOffset=16,base=pr.UInt, disp = '{:#x}', mode='RO'))
        self.add(pr.RemoteVariable(name='Adc2_0',             description='ADC data  value',pollInterval = 1,     offset=0x00000088, bitSize=16,  bitOffset=0, base=pr.UInt, disp = '{:#x}', mode='RO'))
        self.add(pr.RemoteVariable(name='Adc2_1',             description='ADC data  value',pollInterval = 1,     offset=0x00000088, bitSize=16,  bitOffset=16,base=pr.UInt, disp = '{:#x}', mode='RO'))
        self.add(pr.RemoteVariable(name='Adc3_0',             description='ADC data  value',pollInterval = 1,     offset=0x0000008C, bitSize=16,  bitOffset=0, base=pr.UInt, disp = '{:#x}', mode='RO'))
        self.add(pr.RemoteVariable(name='Adc3_1',             description='ADC data  value',pollInterval = 1,     offset=0x0000008C, bitSize=16,  bitOffset=16,base=pr.UInt, disp = '{:#x}', mode='RO'))

        self.add(pr.RemoteVariable(name='FreezeDebug',     description='',                                        offset=0x000000A0, bitSize=1,  bitOffset=0,  base=pr.Bool, mode='RW'))

        #####################################
        # Create commands
        #####################################

        # A command has an associated function. The function can be a series of
        # python commands in a string. Function calls are executed in the command scope
        # the passed arg is available as 'arg'. Use 'dev' to get to device scope.
        # A command can also be a call to a local function with local scope.
        # The command object and the arg are passed
        self.add(pr.LocalCommand(name='InitAdcDelay',description='Find and set best delay for the adc channels', function=self.fnSetFindAndSetDelays))

    def fnSetFindAndSetDelays(self,dev,cmd,arg):
        """Find and set Monitoring ADC delays"""
        parent = self.parent
        if not (parent.Ad9249Config_Adc_0.enable.get()):
            parent.Ad9249Config_Adc_0.enable.set(True)

        parent.Ad9249Config_Adc_0.OutputTestMode.set(9) # one bit on
        self.testResult = np.zeros(256)
        #check adc 0
        for delay in range (0, 256):
            self.DelayAdc0.set(delay)
            self.testResult[delay] = (self.Adc0_0.get()==0x2AAA)
        print(self.testResult)
        #check adc 1


    @staticmethod
    def frequencyConverter(self):
        def func(dev, var):
            return '{:.3f} kHz'.format(1/(self.clkPeriod * self._count(var.dependencies)) * 1e-3)
        return func


    @staticmethod
    def setDelay(var, value, write):
        iValue = value + 512
        var.dependencies[0].set(iValue)
        var.dependencies[0].set(value)


    @staticmethod
    def getDelay(var, read):
        return var.dependencies[0].get()
