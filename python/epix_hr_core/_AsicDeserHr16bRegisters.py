#-----------------------------------------------------------------------------
# This file is part of the 'EPIX HR Firmware'. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the 'EPIX HR Firmware', including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------
import pyrogue      as pr
import epix_hr_core as epixHrCore
import numpy        as np
import time

############################################################################
## Deserializers HR 16bit
############################################################################
class AsicDeserHr16bRegisters(pr.Device):
    def __init__(self, **kwargs):
        super().__init__(description='7 Series 20 bit Deserializer Registers', **kwargs)

        # Creation. memBase is either the register bus server (srp, rce mapped memory, etc) or the device which
        # contains this object. In most cases the parent and memBase are the same but they can be
        # different in more complex bus structures. They will also be different for the top most node.
        # The setMemBase call can be used to update the memBase for this Device. All sub-devices and local
        # blocks will be updated.

        #############################################
        # Create block / variable combinations
        #############################################


        #Setup registers & variables
        self.add(pr.RemoteVariable(name='StreamsEn_n',  description='Enable/Disable', offset=0x00000000, bitSize=2,  bitOffset=0,  base=pr.UInt, mode='RW'))
        self.add(pr.RemoteVariable(name='Resync',       description='Resync',         offset=0x00000004, bitSize=1,  bitOffset=0,  base=pr.Bool, verify = False, mode='RW'))
        self.add(pr.RemoteVariable(name='Delay0_', description='Data ADC Idelay3 value', offset=0x00000010, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.LinkVariable(  name='Delay0',  description='Data ADC Idelay3 value', linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.Delay0_]))
        self.add(pr.RemoteVariable(name='Delay1_', description='Data ADC Idelay3 value', offset=0x00000014, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.LinkVariable(  name='Delay1',  description='Data ADC Idelay3 value', linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.Delay1_]))
        self.add(pr.RemoteVariable(name='LockErrors0',  description='LockErrors',     offset=0x00000030, bitSize=16, bitOffset=0,  base=pr.UInt, disp = '{}', mode='RO'))
        self.add(pr.RemoteVariable(name='Locked0',      description='Locked',         offset=0x00000030, bitSize=1,  bitOffset=16, base=pr.Bool, mode='RO'))
        self.add(pr.RemoteVariable(name='LockErrors1',  description='LockErrors',     offset=0x00000034, bitSize=16, bitOffset=0,  base=pr.UInt, disp = '{}', mode='RO'))
        self.add(pr.RemoteVariable(name='Locked1',      description='Locked',         offset=0x00000034, bitSize=1,  bitOffset=16, base=pr.Bool, mode='RO'))

        for i in range(0, 2):
            self.add(pr.RemoteVariable(name='IserdeseOutA'+str(i),   description='IserdeseOut'+str(i),  offset=0x00000080+i*4, bitSize=20, bitOffset=0, base=pr.UInt,  disp = '{:#x}', mode='RO'))

        for i in range(0, 2):
            self.add(pr.RemoteVariable(name='IserdeseOutB'+str(i),   description='IserdeseOut'+str(i),  offset=0x00000088+i*4, bitSize=20, bitOffset=0, base=pr.UInt,  disp = '{:#x}', mode='RO'))
        self.add(epixHrCore.AsicDeser10bDataRegisters(name='tenbData_ser0',      offset=0x00000100, expand=False))
        self.add(epixHrCore.AsicDeser10bDataRegisters(name='tenbData_ser1',      offset=0x00000200, expand=False))
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
        # parent = self.parent
        numDelayTaps = 512
        self.IDLE_PATTERN1 = 0xAAA83
        self.IDLE_PATTERN2 = 0xAA97C
        print("Executing delay test for ePixHr")

        self.testResult0 = np.zeros(numDelayTaps)
        self.testDelay0  = np.zeros(numDelayTaps)
        #check adc 0
        for delay in range (0, numDelayTaps):
            self.Delay0.set(delay)
            self.testDelay0[delay] = self.Delay0.get()
            self.Resync.set(True)
            self.Resync.set(False)
            time.sleep(1.0 / float(100))
            self.testResult0[delay] = ((self.IserdeseOutA0.get()==self.IDLE_PATTERN1) or (self.IserdeseOutA0.get()==self.IDLE_PATTERN2))
        print("Test result adc 0:")
        print(self.testResult0*self.testDelay0)

        #check adc 1
        self.testResult1 = np.zeros(numDelayTaps)
        self.testDelay1  = np.zeros(numDelayTaps)
        for delay in range (0, numDelayTaps):
            self.Delay1.set(delay)
            self.testDelay1[delay] = self.Delay1.get()
            self.Resync.set(True)
            self.Resync.set(False)
            time.sleep(1.0 / float(100))
            self.testResult1[delay] = ((self.IserdeseOutA1.get()==self.IDLE_PATTERN1) or (self.IserdeseOutA1.get()==self.IDLE_PATTERN2))
        print("Test result adc 1:")
        print(self.testResult1*self.testDelay1)

        self.resultArray0 =  np.zeros(numDelayTaps)
        self.resultArray1 =  np.zeros(numDelayTaps)
        for i in range(1, numDelayTaps):
            if (self.testResult0[i] != 0):
                self.resultArray0[i] = self.resultArray0[i-1] + self.testResult0[i]
            if (self.testResult1[i] != 0):
                self.resultArray1[i] = self.resultArray1[i-1] + self.testResult1[i]
        self.longestDelay0 = np.where(self.resultArray0==np.max(self.resultArray0))
        if len(self.longestDelay0[0])==1:
            self.sugDelay0 = int(self.longestDelay0[0]) - int(self.resultArray0[self.longestDelay0]/2)
        else:
            self.sugDelay0 = int(self.longestDelay0[0][0]) - int(self.resultArray0[self.longestDelay0[0][0]]/2)
        self.longestDelay1 = np.where(self.resultArray1==np.max(self.resultArray1))
        if len(self.longestDelay1[0])==1:
            self.sugDelay1 = int(self.longestDelay1[0]) - int(self.resultArray1[self.longestDelay1]/2)
        else:
            self.sugDelay1 = int(self.longestDelay1[0][0]) - int(self.resultArray1[self.longestDelay1[0][0]]/2)
        print("Suggested delay_0: " + str(self.sugDelay0))
        print("Suggested delay_1: " + str(self.sugDelay1))


    @staticmethod
    def setDelay(var, value, write):
        iValue = value + 512
        var.dependencies[0].set(iValue, write)
        var.dependencies[0].set(value, write)

    @staticmethod
    def getDelay(var, read):
        return var.dependencies[0].get(read)
