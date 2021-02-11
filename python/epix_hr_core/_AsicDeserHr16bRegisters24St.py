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

class AsicDeserHr16bRegisters24St(pr.Device):
    def __init__(self, **kwargs):
        super().__init__(description='20 bit Deserializer Registers', **kwargs)

        # Creation. memBase is either the register bus server (srp, rce mapped memory, etc) or the device which
        # contains this object. In most cases the parent and memBase are the same but they can be
        # different in more complex bus structures. They will also be different for the top most node.
        # The setMemBase call can be used to update the memBase for this Device. All sub-devices and local
        # blocks will be updated.

        #############################################
        # Create block / variable combinations
        #############################################


        #Setup registers & variables
        self.add(pr.RemoteVariable(name='StreamsEn_n',  description='Enable/Disable', offset=0x00000000, bitSize=24,  bitOffset=0,  base=pr.UInt, mode='RW'))
        self.add(pr.RemoteVariable(name=('IdelayRst'),     description='iDelay reset',  offset=0x00000008, bitSize=24, bitOffset=0, base=pr.UInt,  disp = '{:#x}', mode='RW'))
        self.add(pr.RemoteVariable(name=('IserdeseRst'),   description='iSerdese3 reset',  offset=0x0000000C, bitSize=24, bitOffset=0, base=pr.UInt,  disp = '{:#x}', mode='RW'))
        self.add(pr.RemoteVariable(name='Resync',       description='Resync',         offset=0x00000004, bitSize=1,  bitOffset=0,  base=pr.Bool, verify = False, mode='RW'))
        self.add(pr.RemoteVariable(name='Delay0_', description='Data ADC Idelay3 value', offset=0x00000010, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.LinkVariable(  name='Delay0',  description='Data ADC Idelay3 value', linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.Delay0_]))
        self.add(pr.RemoteVariable(name='Delay1_', description='Data ADC Idelay3 value', offset=0x00000014, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.LinkVariable(  name='Delay1',  description='Data ADC Idelay3 value', linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.Delay1_]))
        self.add(pr.RemoteVariable(name='Delay2_', description='Data ADC Idelay3 value', offset=0x00000018, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.LinkVariable(  name='Delay2',  description='Data ADC Idelay3 value', linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.Delay2_]))
        self.add(pr.RemoteVariable(name='Delay3_', description='Data ADC Idelay3 value', offset=0x0000001C, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.LinkVariable(  name='Delay3',  description='Data ADC Idelay3 value', linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.Delay3_]))
        self.add(pr.RemoteVariable(name='Delay4_', description='Data ADC Idelay3 value', offset=0x00000020, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.LinkVariable(  name='Delay4',  description='Data ADC Idelay3 value', linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.Delay4_]))
        self.add(pr.RemoteVariable(name='Delay5_', description='Data ADC Idelay3 value', offset=0x00000024, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.LinkVariable(  name='Delay5',  description='Data ADC Idelay3 value', linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.Delay5_]))
        self.add(pr.RemoteVariable(name='Delay6_', description='Data ADC Idelay3 value', offset=0x00000028, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.LinkVariable(  name='Delay6',  description='Data ADC Idelay3 value', linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.Delay6_]))
        self.add(pr.RemoteVariable(name='Delay7_', description='Data ADC Idelay3 value', offset=0x0000002C, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.LinkVariable(  name='Delay7',  description='Data ADC Idelay3 value', linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.Delay7_]))
        self.add(pr.RemoteVariable(name='Delay8_', description='Data ADC Idelay3 value', offset=0x00000030, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.LinkVariable(  name='Delay8',  description='Data ADC Idelay3 value', linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.Delay8_]))
        self.add(pr.RemoteVariable(name='Delay9_', description='Data ADC Idelay3 value', offset=0x00000034, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.LinkVariable(  name='Delay9',  description='Data ADC Idelay3 value', linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.Delay9_]))
        self.add(pr.RemoteVariable(name='Delay10_', description='Data ADC Idelay3 value', offset=0x00000038, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.LinkVariable(  name='Delay10',  description='Data ADC Idelay3 value', linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.Delay10_]))
        self.add(pr.RemoteVariable(name='Delay11_', description='Data ADC Idelay3 value', offset=0x0000003C, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.LinkVariable(  name='Delay11',  description='Data ADC Idelay3 value', linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.Delay11_]))
        self.add(pr.RemoteVariable(name='Delay12_', description='Data ADC Idelay3 value', offset=0x00000040, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.LinkVariable(  name='Delay12',  description='Data ADC Idelay3 value', linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.Delay12_]))
        self.add(pr.RemoteVariable(name='Delay13_', description='Data ADC Idelay3 value', offset=0x00000044, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.LinkVariable(  name='Delay13',  description='Data ADC Idelay3 value', linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.Delay13_]))
        self.add(pr.RemoteVariable(name='Delay14_', description='Data ADC Idelay3 value', offset=0x00000048, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.LinkVariable(  name='Delay14',  description='Data ADC Idelay3 value', linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.Delay14_]))
        self.add(pr.RemoteVariable(name='Delay15_', description='Data ADC Idelay3 value', offset=0x0000004C, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.LinkVariable(  name='Delay15',  description='Data ADC Idelay3 value', linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.Delay15_]))
        self.add(pr.RemoteVariable(name='Delay16_', description='Data ADC Idelay3 value', offset=0x00000050, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.LinkVariable(  name='Delay16',  description='Data ADC Idelay3 value', linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.Delay16_]))
        self.add(pr.RemoteVariable(name='Delay17_', description='Data ADC Idelay3 value', offset=0x00000054, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.LinkVariable(  name='Delay17',  description='Data ADC Idelay3 value', linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.Delay17_]))
        self.add(pr.RemoteVariable(name='Delay18_', description='Data ADC Idelay3 value', offset=0x00000058, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.LinkVariable(  name='Delay18',  description='Data ADC Idelay3 value', linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.Delay18_]))
        self.add(pr.RemoteVariable(name='Delay19_', description='Data ADC Idelay3 value', offset=0x0000005C, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.LinkVariable(  name='Delay19',  description='Data ADC Idelay3 value', linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.Delay19_]))
        self.add(pr.RemoteVariable(name='Delay20_', description='Data ADC Idelay3 value', offset=0x00000060, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.LinkVariable(  name='Delay20',  description='Data ADC Idelay3 value', linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.Delay20_]))
        self.add(pr.RemoteVariable(name='Delay21_', description='Data ADC Idelay3 value', offset=0x00000064, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.LinkVariable(  name='Delay21',  description='Data ADC Idelay3 value', linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.Delay21_]))
        self.add(pr.RemoteVariable(name='Delay22_', description='Data ADC Idelay3 value', offset=0x00000068, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.LinkVariable(  name='Delay22',  description='Data ADC Idelay3 value', linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.Delay22_]))
        self.add(pr.RemoteVariable(name='Delay23_', description='Data ADC Idelay3 value', offset=0x0000006C, bitSize=10,  bitOffset=0,  base=pr.UInt, disp = '{}', verify=False, mode='RW', hidden=True))
        self.add(pr.LinkVariable(  name='Delay23',  description='Data ADC Idelay3 value', linkedGet=self.getDelay, linkedSet=self.setDelay, dependencies=[self.Delay23_]))

        for i in range(0, 24):
            self.add(pr.RemoteVariable(name=('LockErrors%d'%i),  description='LockErrors',     offset=0x00000100+i*4, bitSize=16, bitOffset=0,  base=pr.UInt, disp = '{}', mode='RO'))
            self.add(pr.RemoteVariable(name=('Locked%d'%i),      description='Locked',         offset=0x00000100+i*4, bitSize=1,  bitOffset=16, base=pr.Bool, mode='RO'))

        for j in range(0, 24):
            for i in range(0, 2):
                self.add(pr.RemoteVariable(name=('IserdeseOut%d_%d' % (j, i)),   description='IserdeseOut'+str(i),  offset=0x00000300+i*4+j*8, bitSize=20, bitOffset=0, base=pr.UInt,  disp = '{:#x}', mode='RO'))

        self.add(pr.RemoteVariable(name='FreezeDebug',      description='Restart BERT',  offset=0x00000400, bitSize=1,  bitOffset=0, base=pr.Bool, mode='RW'))
        self.add(pr.RemoteVariable(name='BERTRst',      description='Restart BERT',      offset=0x00000400, bitSize=1,  bitOffset=1, base=pr.Bool, mode='RW'))
        for i in range(0, 24):
            self.add(pr.RemoteVariable(name='BERTCounter'+str(i),   description='Counter value.'+str(i),  offset=0x00000404+i*8, bitSize=44, bitOffset=0, base=pr.UInt,  disp = '{}', mode='RO'))

        for i in range(0,24):
            self.add(epixHrCore.AsicDeser10bDataRegisters(name='tenbData_ser%d'%i,      offset=(0x00000500+(i*0x00000100)), expand=False))
        #####################################
        # Create commands
        #####################################

        # A command has an associated function. The function can be a series of
        # python commands in a string. Function calls are executed in the command scope
        # the passed arg is available as 'arg'. Use 'dev' to get to device scope.
        # A command can also be a call to a local function with local scope.
        # The command object and the arg are passed

        self.add(pr.LocalCommand(name='InitAdcDelay',description='Find and set best delay for the adc channels', function=self.fnSetFindAndSetDelays))
        self.add(pr.LocalCommand(name='InitAdcDelayConf',description='[skewPct, pattern1, pattern2, noReSync]', value=[50,0,0,0], function=self.fnSetFindAndSetDelaysConf))
        self.add(pr.LocalCommand(name='Refines delay settings',description='Find and set best delay for the adc channels', function=self.fnRefineDelays))

    def fnSetFindAndSetDelaysConf(self,dev,cmd,arg):
        """Find and set Monitoring ADC delays"""
        arguments = np.asarray(arg)
        # parent = self.parent
        numDelayTaps = 512
        if arguments[1] == 0 and arguments[2] == 0:
            self.IDLE_PATTERN1 = 0xAAA83
            self.IDLE_PATTERN2 = 0xAA97C
        else:
            self.IDLE_PATTERN1 = arguments[1]
            self.IDLE_PATTERN2 = arguments[2]
        eyeFactor = arguments[0]/100
        noReSync = arguments[3]

        print("Executing delay test for ePixHr. Eye delay skew %f, pattern1 %X, pattern2 %X, do re-sync %d"%(eyeFactor, self.IDLE_PATTERN1, self.IDLE_PATTERN2, not noReSync))

        #check adcs
        self.testResult = np.zeros((24,numDelayTaps))
        self.testDelay  = np.zeros((24,numDelayTaps))
        for delay in range (0, numDelayTaps):
            self.Delay0.set(delay)
            self.Delay1.set(delay)
            self.Delay2.set(delay)
            self.Delay3.set(delay)
            self.Delay4.set(delay)
            self.Delay5.set(delay)
            self.Delay6.set(delay)
            self.Delay7.set(delay)
            self.Delay8.set(delay)
            self.Delay9.set(delay)
            self.Delay10.set(delay)
            self.Delay11.set(delay)
            self.Delay12.set(delay)
            self.Delay13.set(delay)
            self.Delay14.set(delay)
            self.Delay15.set(delay)
            self.Delay16.set(delay)
            self.Delay17.set(delay)
            self.Delay18.set(delay)
            self.Delay19.set(delay)
            self.Delay20.set(delay)
            self.Delay21.set(delay)
            self.Delay22.set(delay)
            self.Delay23.set(delay)
            self.testDelay[0,delay] =  self.Delay0.get()
            self.testDelay[1,delay] =  self.Delay1.get()
            self.testDelay[2,delay] =  self.Delay2.get()
            self.testDelay[3,delay] =  self.Delay3.get()
            self.testDelay[4,delay] =  self.Delay4.get()
            self.testDelay[5,delay] =  self.Delay5.get()
            self.testDelay[6,delay] =  self.Delay6.get()
            self.testDelay[7,delay] =  self.Delay7.get()
            self.testDelay[8,delay] =  self.Delay8.get()
            self.testDelay[9,delay] =  self.Delay9.get()
            self.testDelay[10,delay] = self.Delay10.get()
            self.testDelay[11,delay] = self.Delay11.get()
            self.testDelay[12,delay] = self.Delay12.get()
            self.testDelay[13,delay] = self.Delay13.get()
            self.testDelay[14,delay] = self.Delay14.get()
            self.testDelay[15,delay] = self.Delay15.get()
            self.testDelay[16,delay] = self.Delay16.get()
            self.testDelay[17,delay] = self.Delay17.get()
            self.testDelay[18,delay] = self.Delay18.get()
            self.testDelay[19,delay] = self.Delay19.get()
            self.testDelay[20,delay] = self.Delay20.get()
            self.testDelay[21,delay] = self.Delay21.get()
            self.testDelay[22,delay] = self.Delay22.get()
            self.testDelay[23,delay] = self.Delay23.get()
            if noReSync == 0:
                self.Resync.set(True)
                self.Resync.set(False)
            time.sleep(1.0 / float(100))
            IserdeseOut_value = self.IserdeseOut0_0.get()
            self.testResult[0,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut1_0.get()
            self.testResult[1,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut2_0.get()
            self.testResult[2,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut3_0.get()
            self.testResult[3,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut4_0.get()
            self.testResult[4,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut5_0.get()
            self.testResult[5,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut6_0.get()
            self.testResult[6,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut7_0.get()
            self.testResult[7,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut8_0.get()
            self.testResult[8,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut9_0.get()
            self.testResult[9,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut10_0.get()
            self.testResult[10,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut11_0.get()
            self.testResult[11,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut12_0.get()
            self.testResult[12,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut13_0.get()
            self.testResult[13,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut14_0.get()
            self.testResult[14,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut15_0.get()
            self.testResult[15,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut16_0.get()
            self.testResult[16,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut17_0.get()
            self.testResult[17,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut18_0.get()
            self.testResult[18,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut19_0.get()
            self.testResult[19,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut20_0.get()
            self.testResult[20,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut21_0.get()
            self.testResult[21,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut22_0.get()
            self.testResult[22,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut23_0.get()
            self.testResult[23,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))

        for i in range(0, 24):
            print("Test result adc %d:"%i)
            print(self.testResult[i,:]*self.testDelay)
        np.savetxt(str(self.name)+'_delayTestResultAll.csv', (self.testResult*self.testDelay), delimiter=',')

        self.resultArray =  np.zeros((24,numDelayTaps))
        for j in range(0, 24):
            for i in range(1, numDelayTaps):
                if (self.testResult[j,i] != 0):
                    self.resultArray[j,i] = self.resultArray[j,i-1] + self.testResult[j,i]



        self.longestDelay0 = np.where(self.resultArray[0]==np.max(self.resultArray[0]))
        if len(self.longestDelay0[0])==1:
            self.sugDelay0 = int(self.longestDelay0[0]) - int(self.resultArray[0][self.longestDelay0]*eyeFactor)
        else:
            self.sugDelay0 = int(self.longestDelay0[0][0]) - int(self.resultArray[0][self.longestDelay0[0][0]]*eyeFactor)

        self.longestDelay1 = np.where(self.resultArray[1]==np.max(self.resultArray[1]))
        if len(self.longestDelay1[0])==1:
            self.sugDelay1 = int(self.longestDelay1[0]) - int(self.resultArray[1][self.longestDelay1]*eyeFactor)
        else:
            self.sugDelay1 = int(self.longestDelay1[0][0]) - int(self.resultArray[1][self.longestDelay1[0][0]]*eyeFactor)

        self.longestDelay2 = np.where(self.resultArray[2]==np.max(self.resultArray[2]))
        if len(self.longestDelay2[0])==1:
            self.sugDelay2 = int(self.longestDelay2[0]) - int(self.resultArray[2][self.longestDelay2]*eyeFactor)
        else:
            self.sugDelay2 = int(self.longestDelay2[0][0]) - int(self.resultArray[2][self.longestDelay2[0][0]]*eyeFactor)

        self.longestDelay3 = np.where(self.resultArray[3]==np.max(self.resultArray[3]))
        if len(self.longestDelay3[0])==1:
            self.sugDelay3 = int(self.longestDelay3[0]) - int(self.resultArray[3][self.longestDelay3]*eyeFactor)
        else:
            self.sugDelay3 = int(self.longestDelay3[0][0]) - int(self.resultArray[3][self.longestDelay3[0][0]]*eyeFactor)

        self.longestDelay4 = np.where(self.resultArray[4]==np.max(self.resultArray[4]))
        if len(self.longestDelay4[0])==1:
            self.sugDelay4 = int(self.longestDelay4[0]) - int(self.resultArray[4][self.longestDelay4]*eyeFactor)
        else:
            self.sugDelay4 = int(self.longestDelay4[0][0]) - int(self.resultArray[4][self.longestDelay4[0][0]]*eyeFactor)

        self.longestDelay5 = np.where(self.resultArray[5]==np.max(self.resultArray[5]))
        if len(self.longestDelay5[0])==1:
            self.sugDelay5 = int(self.longestDelay5[0]) - int(self.resultArray[5][self.longestDelay5]*eyeFactor)
        else:
            self.sugDelay5 = int(self.longestDelay5[0][0]) - int(self.resultArray[5][self.longestDelay5[0][0]]*eyeFactor)

        self.longestDelay6 = np.where(self.resultArray[6]==np.max(self.resultArray[6]))
        if len(self.longestDelay6[0])==1:
            self.sugDelay6 = int(self.longestDelay6[0]) - int(self.resultArray[6][self.longestDelay6]*eyeFactor)
        else:
            self.sugDelay6 = int(self.longestDelay6[0][0]) - int(self.resultArray[6][self.longestDelay6[0][0]]*eyeFactor)

        self.longestDelay7 = np.where(self.resultArray[7]==np.max(self.resultArray[7]))
        if len(self.longestDelay7[0])==1:
            self.sugDelay7 = int(self.longestDelay7[0]) - int(self.resultArray[7][self.longestDelay7]*eyeFactor)
        else:
            self.sugDelay7 = int(self.longestDelay7[0][0]) - int(self.resultArray[7][self.longestDelay7[0][0]]*eyeFactor)

        self.longestDelay8 = np.where(self.resultArray[8]==np.max(self.resultArray[8]))
        if len(self.longestDelay8[0])==1:
            self.sugDelay8 = int(self.longestDelay8[0]) - int(self.resultArray[8][self.longestDelay8]*eyeFactor)
        else:
            self.sugDelay8 = int(self.longestDelay8[0][0]) - int(self.resultArray[8][self.longestDelay8[0][0]]*eyeFactor)

        self.longestDelay9 = np.where(self.resultArray[9]==np.max(self.resultArray[9]))
        if len(self.longestDelay9[0])==1:
            self.sugDelay9 = int(self.longestDelay9[0]) - int(self.resultArray[9][self.longestDelay9]*eyeFactor)
        else:
            self.sugDelay9 = int(self.longestDelay9[0][0]) - int(self.resultArray[9][self.longestDelay9[0][0]]*eyeFactor)

        self.longestDelay10 = np.where(self.resultArray[10]==np.max(self.resultArray[10]))
        if len(self.longestDelay10[0])==1:
            self.sugDelay10 = int(self.longestDelay10[0]) - int(self.resultArray[10][self.longestDelay10]*eyeFactor)
        else:
            self.sugDelay10 = int(self.longestDelay10[0][0]) - int(self.resultArray[10][self.longestDelay10[0][0]]*eyeFactor)

        self.longestDelay11 = np.where(self.resultArray[11]==np.max(self.resultArray[11]))
        if len(self.longestDelay11[0])==1:
            self.sugDelay11 = int(self.longestDelay11[0]) - int(self.resultArray[11][self.longestDelay11]*eyeFactor)
        else:
            self.sugDelay11 = int(self.longestDelay11[0][0]) - int(self.resultArray[11][self.longestDelay11[0][0]]*eyeFactor)

        self.longestDelay12 = np.where(self.resultArray[12]==np.max(self.resultArray[12]))
        if len(self.longestDelay12[0])==1:
            self.sugDelay12 = int(self.longestDelay12[0]) - int(self.resultArray[12][self.longestDelay12]*eyeFactor)
        else:
            self.sugDelay12 = int(self.longestDelay12[0][0]) - int(self.resultArray[12][self.longestDelay12[0][0]]*eyeFactor)

        self.longestDelay13 = np.where(self.resultArray[13]==np.max(self.resultArray[13]))
        if len(self.longestDelay13[0])==1:
            self.sugDelay13 = int(self.longestDelay13[0]) - int(self.resultArray[13][self.longestDelay13]*eyeFactor)
        else:
            self.sugDelay13 = int(self.longestDelay13[0][0]) - int(self.resultArray[13][self.longestDelay13[0][0]]*eyeFactor)

        self.longestDelay14 = np.where(self.resultArray[14]==np.max(self.resultArray[14]))
        if len(self.longestDelay14[0])==1:
            self.sugDelay14 = int(self.longestDelay14[0]) - int(self.resultArray[14][self.longestDelay14]*eyeFactor)
        else:
            self.sugDelay14 = int(self.longestDelay14[0][0]) - int(self.resultArray[14][self.longestDelay14[0][0]]*eyeFactor)

        self.longestDelay15 = np.where(self.resultArray[15]==np.max(self.resultArray[15]))
        if len(self.longestDelay15[0])==1:
            self.sugDelay15 = int(self.longestDelay15[0]) - int(self.resultArray[15][self.longestDelay15]*eyeFactor)
        else:
            self.sugDelay15 = int(self.longestDelay15[0][0]) - int(self.resultArray[15][self.longestDelay15[0][0]]*eyeFactor)

        self.longestDelay16 = np.where(self.resultArray[16]==np.max(self.resultArray[16]))
        if len(self.longestDelay16[0])==1:
            self.sugDelay16 = int(self.longestDelay16[0]) - int(self.resultArray[16][self.longestDelay16]*eyeFactor)
        else:
            self.sugDelay16 = int(self.longestDelay16[0][0]) - int(self.resultArray[16][self.longestDelay16[0][0]]*eyeFactor)

        self.longestDelay17 = np.where(self.resultArray[17]==np.max(self.resultArray[17]))
        if len(self.longestDelay17[0])==1:
            self.sugDelay17 = int(self.longestDelay17[0]) - int(self.resultArray[17][self.longestDelay17]*eyeFactor)
        else:
            self.sugDelay17 = int(self.longestDelay17[0][0]) - int(self.resultArray[17][self.longestDelay17[0][0]]*eyeFactor)

        self.longestDelay18 = np.where(self.resultArray[18]==np.max(self.resultArray[18]))
        if len(self.longestDelay18[0])==1:
            self.sugDelay18 = int(self.longestDelay18[0]) - int(self.resultArray[18][self.longestDelay18]*eyeFactor)
        else:
            self.sugDelay18 = int(self.longestDelay18[0][0]) - int(self.resultArray[18][self.longestDelay18[0][0]]*eyeFactor)

        self.longestDelay19 = np.where(self.resultArray[19]==np.max(self.resultArray[19]))
        if len(self.longestDelay19[0])==1:
            self.sugDelay19 = int(self.longestDelay19[0]) - int(self.resultArray[19][self.longestDelay19]*eyeFactor)
        else:
            self.sugDelay19 = int(self.longestDelay19[0][0]) - int(self.resultArray[19][self.longestDelay19[0][0]]*eyeFactor)

        self.longestDelay20 = np.where(self.resultArray[20]==np.max(self.resultArray[20]))
        if len(self.longestDelay20[0])==1:
            self.sugDelay20 = int(self.longestDelay20[0]) - int(self.resultArray[20][self.longestDelay20]*eyeFactor)
        else:
            self.sugDelay20 = int(self.longestDelay20[0][0]) - int(self.resultArray[20][self.longestDelay20[0][0]]*eyeFactor)

        self.longestDelay21 = np.where(self.resultArray[21]==np.max(self.resultArray[21]))
        if len(self.longestDelay21[0])==1:
            self.sugDelay21 = int(self.longestDelay21[0]) - int(self.resultArray[21][self.longestDelay21]*eyeFactor)
        else:
            self.sugDelay21 = int(self.longestDelay21[0][0]) - int(self.resultArray[21][self.longestDelay21[0][0]]*eyeFactor)

        self.longestDelay22 = np.where(self.resultArray[22]==np.max(self.resultArray[22]))
        if len(self.longestDelay22[0])==1:
            self.sugDelay22 = int(self.longestDelay22[0]) - int(self.resultArray[22][self.longestDelay22]*eyeFactor)
        else:
            self.sugDelay22 = int(self.longestDelay22[0][0]) - int(self.resultArray[22][self.longestDelay22[0][0]]*eyeFactor)

        self.longestDelay23 = np.where(self.resultArray[23]==np.max(self.resultArray[23]))
        if len(self.longestDelay23[0])==1:
            self.sugDelay23 = int(self.longestDelay23[0]) - int(self.resultArray[23][self.longestDelay23]*eyeFactor)
        else:
            self.sugDelay23 = int(self.longestDelay23[0][0]) - int(self.resultArray[23][self.longestDelay23[0][0]]*eyeFactor)

        print("Suggested delay_0: " + str(self.sugDelay0))
        print("Suggested delay_1: " + str(self.sugDelay1))
        print("Suggested delay_2: " + str(self.sugDelay2))
        print("Suggested delay_3: " + str(self.sugDelay3))
        print("Suggested delay_4: " + str(self.sugDelay4))
        print("Suggested delay_5: " + str(self.sugDelay5))
        print("Suggested delay_6: " + str(self.sugDelay6))
        print("Suggested delay_7: " + str(self.sugDelay7))
        print("Suggested delay_8: " + str(self.sugDelay8))
        print("Suggested delay_9: " + str(self.sugDelay9))
        print("Suggested delay_10: " + str(self.sugDelay10))
        print("Suggested delay_11: " + str(self.sugDelay11))
        print("Suggested delay_12: " + str(self.sugDelay12))
        print("Suggested delay_13: " + str(self.sugDelay13))
        print("Suggested delay_14: " + str(self.sugDelay14))
        print("Suggested delay_15: " + str(self.sugDelay15))
        print("Suggested delay_16: " + str(self.sugDelay16))
        print("Suggested delay_17: " + str(self.sugDelay17))
        print("Suggested delay_18: " + str(self.sugDelay18))
        print("Suggested delay_19: " + str(self.sugDelay19))
        print("Suggested delay_20: " + str(self.sugDelay20))
        print("Suggested delay_21: " + str(self.sugDelay21))
        print("Suggested delay_22: " + str(self.sugDelay22))
        print("Suggested delay_23: " + str(self.sugDelay23))

        # apply suggested settings
        self.Delay0.set(self.sugDelay0)
        self.Delay1.set(self.sugDelay1)
        self.Delay2.set(self.sugDelay2)
        self.Delay3.set(self.sugDelay3)
        self.Delay4.set(self.sugDelay4)
        self.Delay5.set(self.sugDelay5)
        self.Delay6.set(self.sugDelay6)
        self.Delay7.set(self.sugDelay7)
        self.Delay8.set(self.sugDelay8)
        self.Delay9.set(self.sugDelay9)
        self.Delay10.set(self.sugDelay10)
        self.Delay11.set(self.sugDelay11)
        self.Delay12.set(self.sugDelay12)
        self.Delay13.set(self.sugDelay13)
        self.Delay14.set(self.sugDelay14)
        self.Delay15.set(self.sugDelay15)
        self.Delay16.set(self.sugDelay16)
        self.Delay17.set(self.sugDelay17)
        self.Delay18.set(self.sugDelay18)
        self.Delay19.set(self.sugDelay19)
        self.Delay20.set(self.sugDelay20)
        self.Delay21.set(self.sugDelay21)
        self.Delay22.set(self.sugDelay22)
        self.Delay23.set(self.sugDelay23)
        if noReSync == 0:
            self.Resync.set(True)
            time.sleep(1.0 / float(100))
            self.Resync.set(False)


    def fnSetFindAndSetDelays(self,dev,cmd,arg):
        """Find and set Monitoring ADC delays"""
        # parent = self.parent
        numDelayTaps = 512
        self.IDLE_PATTERN1 = 0xAAA83
        self.IDLE_PATTERN2 = 0xAA97C
        print("Executing delay test for ePixHr")

        #check adcs
        self.testResult = np.zeros((24,numDelayTaps))
        self.testDelay  = np.zeros((24,numDelayTaps))
        for delay in range (0, numDelayTaps):
            self.Delay0.set(delay)
            self.Delay1.set(delay)
            self.Delay2.set(delay)
            self.Delay3.set(delay)
            self.Delay4.set(delay)
            self.Delay5.set(delay)
            self.Delay6.set(delay)
            self.Delay7.set(delay)
            self.Delay8.set(delay)
            self.Delay9.set(delay)
            self.Delay10.set(delay)
            self.Delay11.set(delay)
            self.Delay12.set(delay)
            self.Delay13.set(delay)
            self.Delay14.set(delay)
            self.Delay15.set(delay)
            self.Delay16.set(delay)
            self.Delay17.set(delay)
            self.Delay18.set(delay)
            self.Delay19.set(delay)
            self.Delay20.set(delay)
            self.Delay21.set(delay)
            self.Delay22.set(delay)
            self.Delay23.set(delay)
            self.testDelay[0,delay] =  self.Delay0.get()
            self.testDelay[1,delay] =  self.Delay1.get()
            self.testDelay[2,delay] =  self.Delay2.get()
            self.testDelay[3,delay] =  self.Delay3.get()
            self.testDelay[4,delay] =  self.Delay4.get()
            self.testDelay[5,delay] =  self.Delay5.get()
            self.testDelay[6,delay] =  self.Delay6.get()
            self.testDelay[7,delay] =  self.Delay7.get()
            self.testDelay[8,delay] =  self.Delay8.get()
            self.testDelay[9,delay] =  self.Delay9.get()
            self.testDelay[10,delay] = self.Delay10.get()
            self.testDelay[11,delay] = self.Delay11.get()
            self.testDelay[12,delay] = self.Delay12.get()
            self.testDelay[13,delay] = self.Delay13.get()
            self.testDelay[14,delay] = self.Delay14.get()
            self.testDelay[15,delay] = self.Delay15.get()
            self.testDelay[16,delay] = self.Delay16.get()
            self.testDelay[17,delay] = self.Delay17.get()
            self.testDelay[18,delay] = self.Delay18.get()
            self.testDelay[19,delay] = self.Delay19.get()
            self.testDelay[20,delay] = self.Delay20.get()
            self.testDelay[21,delay] = self.Delay21.get()
            self.testDelay[22,delay] = self.Delay22.get()
            self.testDelay[23,delay] = self.Delay23.get()
            self.Resync.set(True)
            self.Resync.set(False)
            time.sleep(1.0 / float(100))
            IserdeseOut_value = self.IserdeseOut0_0.get()
            self.testResult[0,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut1_0.get()
            self.testResult[1,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut2_0.get()
            self.testResult[2,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut3_0.get()
            self.testResult[3,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut4_0.get()
            self.testResult[4,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut5_0.get()
            self.testResult[5,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut6_0.get()
            self.testResult[6,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut7_0.get()
            self.testResult[7,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut8_0.get()
            self.testResult[8,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut9_0.get()
            self.testResult[9,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut10_0.get()
            self.testResult[10,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut11_0.get()
            self.testResult[11,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut12_0.get()
            self.testResult[12,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut13_0.get()
            self.testResult[13,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut14_0.get()
            self.testResult[14,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut15_0.get()
            self.testResult[15,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut16_0.get()
            self.testResult[16,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut17_0.get()
            self.testResult[17,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut18_0.get()
            self.testResult[18,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut19_0.get()
            self.testResult[19,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut20_0.get()
            self.testResult[20,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut21_0.get()
            self.testResult[21,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut22_0.get()
            self.testResult[22,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut23_0.get()
            self.testResult[23,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))

        for i in range(0, 24):
            print("Test result adc %d:"%i)
            print(self.testResult[i,:]*self.testDelay)
        np.savetxt(str(self.name)+'_delayTestResultAll.csv', (self.testResult*self.testDelay), delimiter=',')

        self.resultArray =  np.zeros((24,numDelayTaps))
        for j in range(0, 24):
            for i in range(1, numDelayTaps):
                if (self.testResult[j,i] != 0):
                    self.resultArray[j,i] = self.resultArray[j,i-1] + self.testResult[j,i]

        self.longestDelay0 = np.where(self.resultArray[0]==np.max(self.resultArray[0]))
        if len(self.longestDelay0[0])==1:
            self.sugDelay0 = int(self.longestDelay0[0]) - int(self.resultArray[0][self.longestDelay0]/2)
        else:
            self.sugDelay0 = int(self.longestDelay0[0][0]) - int(self.resultArray[0][self.longestDelay0[0][0]]/2)

        self.longestDelay1 = np.where(self.resultArray[1]==np.max(self.resultArray[1]))
        if len(self.longestDelay1[0])==1:
            self.sugDelay1 = int(self.longestDelay1[0]) - int(self.resultArray[1][self.longestDelay1]/2)
        else:
            self.sugDelay1 = int(self.longestDelay1[0][0]) - int(self.resultArray[1][self.longestDelay1[0][0]]/2)

        self.longestDelay2 = np.where(self.resultArray[2]==np.max(self.resultArray[2]))
        if len(self.longestDelay2[0])==1:
            self.sugDelay2 = int(self.longestDelay2[0]) - int(self.resultArray[2][self.longestDelay2]/2)
        else:
            self.sugDelay2 = int(self.longestDelay2[0][0]) - int(self.resultArray[2][self.longestDelay2[0][0]]/2)

        self.longestDelay3 = np.where(self.resultArray[3]==np.max(self.resultArray[3]))
        if len(self.longestDelay3[0])==1:
            self.sugDelay3 = int(self.longestDelay3[0]) - int(self.resultArray[3][self.longestDelay3]/2)
        else:
            self.sugDelay3 = int(self.longestDelay3[0][0]) - int(self.resultArray[3][self.longestDelay3[0][0]]/2)

        self.longestDelay4 = np.where(self.resultArray[4]==np.max(self.resultArray[4]))
        if len(self.longestDelay4[0])==1:
            self.sugDelay4 = int(self.longestDelay4[0]) - int(self.resultArray[4][self.longestDelay4]/2)
        else:
            self.sugDelay4 = int(self.longestDelay4[0][0]) - int(self.resultArray[4][self.longestDelay4[0][0]]/2)

        self.longestDelay5 = np.where(self.resultArray[5]==np.max(self.resultArray[5]))
        if len(self.longestDelay5[0])==1:
            self.sugDelay5 = int(self.longestDelay5[0]) - int(self.resultArray[5][self.longestDelay5]/2)
        else:
            self.sugDelay5 = int(self.longestDelay5[0][0]) - int(self.resultArray[5][self.longestDelay5[0][0]]/2)

        self.longestDelay6 = np.where(self.resultArray[6]==np.max(self.resultArray[6]))
        if len(self.longestDelay6[0])==1:
            self.sugDelay6 = int(self.longestDelay6[0]) - int(self.resultArray[6][self.longestDelay6]/2)
        else:
            self.sugDelay6 = int(self.longestDelay6[0][0]) - int(self.resultArray[6][self.longestDelay6[0][0]]/2)

        self.longestDelay7 = np.where(self.resultArray[7]==np.max(self.resultArray[7]))
        if len(self.longestDelay7[0])==1:
            self.sugDelay7 = int(self.longestDelay7[0]) - int(self.resultArray[7][self.longestDelay7]/2)
        else:
            self.sugDelay7 = int(self.longestDelay7[0][0]) - int(self.resultArray[7][self.longestDelay7[0][0]]/2)

        self.longestDelay8 = np.where(self.resultArray[8]==np.max(self.resultArray[8]))
        if len(self.longestDelay8[0])==1:
            self.sugDelay8 = int(self.longestDelay8[0]) - int(self.resultArray[8][self.longestDelay8]/2)
        else:
            self.sugDelay8 = int(self.longestDelay8[0][0]) - int(self.resultArray[8][self.longestDelay8[0][0]]/2)

        self.longestDelay9 = np.where(self.resultArray[9]==np.max(self.resultArray[9]))
        if len(self.longestDelay9[0])==1:
            self.sugDelay9 = int(self.longestDelay9[0]) - int(self.resultArray[9][self.longestDelay9]/2)
        else:
            self.sugDelay9 = int(self.longestDelay9[0][0]) - int(self.resultArray[9][self.longestDelay9[0][0]]/2)

        self.longestDelay10 = np.where(self.resultArray[10]==np.max(self.resultArray[10]))
        if len(self.longestDelay10[0])==1:
            self.sugDelay10 = int(self.longestDelay10[0]) - int(self.resultArray[10][self.longestDelay10]/2)
        else:
            self.sugDelay10 = int(self.longestDelay10[0][0]) - int(self.resultArray[10][self.longestDelay10[0][0]]/2)

        self.longestDelay11 = np.where(self.resultArray[11]==np.max(self.resultArray[11]))
        if len(self.longestDelay11[0])==1:
            self.sugDelay11 = int(self.longestDelay11[0]) - int(self.resultArray[11][self.longestDelay11]/2)
        else:
            self.sugDelay11 = int(self.longestDelay11[0][0]) - int(self.resultArray[11][self.longestDelay11[0][0]]/2)

        self.longestDelay12 = np.where(self.resultArray[12]==np.max(self.resultArray[12]))
        if len(self.longestDelay12[0])==1:
            self.sugDelay12 = int(self.longestDelay12[0]) - int(self.resultArray[12][self.longestDelay12]/2)
        else:
            self.sugDelay12 = int(self.longestDelay12[0][0]) - int(self.resultArray[12][self.longestDelay12[0][0]]/2)

        self.longestDelay13 = np.where(self.resultArray[13]==np.max(self.resultArray[13]))
        if len(self.longestDelay13[0])==1:
            self.sugDelay13 = int(self.longestDelay13[0]) - int(self.resultArray[13][self.longestDelay13]/2)
        else:
            self.sugDelay13 = int(self.longestDelay13[0][0]) - int(self.resultArray[13][self.longestDelay13[0][0]]/2)

        self.longestDelay14 = np.where(self.resultArray[14]==np.max(self.resultArray[14]))
        if len(self.longestDelay14[0])==1:
            self.sugDelay14 = int(self.longestDelay14[0]) - int(self.resultArray[14][self.longestDelay14]/2)
        else:
            self.sugDelay14 = int(self.longestDelay14[0][0]) - int(self.resultArray[14][self.longestDelay14[0][0]]/2)

        self.longestDelay15 = np.where(self.resultArray[15]==np.max(self.resultArray[15]))
        if len(self.longestDelay15[0])==1:
            self.sugDelay15 = int(self.longestDelay15[0]) - int(self.resultArray[15][self.longestDelay15]/2)
        else:
            self.sugDelay15 = int(self.longestDelay15[0][0]) - int(self.resultArray[15][self.longestDelay15[0][0]]/2)

        self.longestDelay16 = np.where(self.resultArray[16]==np.max(self.resultArray[16]))
        if len(self.longestDelay16[0])==1:
            self.sugDelay16 = int(self.longestDelay16[0]) - int(self.resultArray[16][self.longestDelay16]/2)
        else:
            self.sugDelay16 = int(self.longestDelay16[0][0]) - int(self.resultArray[16][self.longestDelay16[0][0]]/2)

        self.longestDelay17 = np.where(self.resultArray[17]==np.max(self.resultArray[17]))
        if len(self.longestDelay17[0])==1:
            self.sugDelay17 = int(self.longestDelay17[0]) - int(self.resultArray[17][self.longestDelay17]/2)
        else:
            self.sugDelay17 = int(self.longestDelay17[0][0]) - int(self.resultArray[17][self.longestDelay17[0][0]]/2)

        self.longestDelay18 = np.where(self.resultArray[18]==np.max(self.resultArray[18]))
        if len(self.longestDelay18[0])==1:
            self.sugDelay18 = int(self.longestDelay18[0]) - int(self.resultArray[18][self.longestDelay18]/2)
        else:
            self.sugDelay18 = int(self.longestDelay18[0][0]) - int(self.resultArray[18][self.longestDelay18[0][0]]/2)

        self.longestDelay19 = np.where(self.resultArray[19]==np.max(self.resultArray[19]))
        if len(self.longestDelay19[0])==1:
            self.sugDelay19 = int(self.longestDelay19[0]) - int(self.resultArray[19][self.longestDelay19]/2)
        else:
            self.sugDelay19 = int(self.longestDelay19[0][0]) - int(self.resultArray[19][self.longestDelay19[0][0]]/2)

        self.longestDelay20 = np.where(self.resultArray[20]==np.max(self.resultArray[20]))
        if len(self.longestDelay20[0])==1:
            self.sugDelay20 = int(self.longestDelay20[0]) - int(self.resultArray[20][self.longestDelay20]/2)
        else:
            self.sugDelay20 = int(self.longestDelay20[0][0]) - int(self.resultArray[20][self.longestDelay20[0][0]]/2)

        self.longestDelay21 = np.where(self.resultArray[21]==np.max(self.resultArray[21]))
        if len(self.longestDelay21[0])==1:
            self.sugDelay21 = int(self.longestDelay21[0]) - int(self.resultArray[21][self.longestDelay21]/2)
        else:
            self.sugDelay21 = int(self.longestDelay21[0][0]) - int(self.resultArray[21][self.longestDelay21[0][0]]/2)

        self.longestDelay22 = np.where(self.resultArray[22]==np.max(self.resultArray[22]))
        if len(self.longestDelay22[0])==1:
            self.sugDelay22 = int(self.longestDelay22[0]) - int(self.resultArray[22][self.longestDelay22]/2)
        else:
            self.sugDelay22 = int(self.longestDelay22[0][0]) - int(self.resultArray[22][self.longestDelay22[0][0]]/2)

        self.longestDelay23 = np.where(self.resultArray[23]==np.max(self.resultArray[23]))
        if len(self.longestDelay23[0])==1:
            self.sugDelay23 = int(self.longestDelay23[0]) - int(self.resultArray[23][self.longestDelay23]/2)
        else:
            self.sugDelay23 = int(self.longestDelay23[0][0]) - int(self.resultArray[23][self.longestDelay23[0][0]]/2)

        print("Suggested delay_0: " + str(self.sugDelay0))
        print("Suggested delay_1: " + str(self.sugDelay1))
        print("Suggested delay_2: " + str(self.sugDelay2))
        print("Suggested delay_3: " + str(self.sugDelay3))
        print("Suggested delay_4: " + str(self.sugDelay4))
        print("Suggested delay_5: " + str(self.sugDelay5))
        print("Suggested delay_6: " + str(self.sugDelay6))
        print("Suggested delay_7: " + str(self.sugDelay7))
        print("Suggested delay_8: " + str(self.sugDelay8))
        print("Suggested delay_9: " + str(self.sugDelay9))
        print("Suggested delay_10: " + str(self.sugDelay10))
        print("Suggested delay_11: " + str(self.sugDelay11))
        print("Suggested delay_12: " + str(self.sugDelay12))
        print("Suggested delay_13: " + str(self.sugDelay13))
        print("Suggested delay_14: " + str(self.sugDelay14))
        print("Suggested delay_15: " + str(self.sugDelay15))
        print("Suggested delay_16: " + str(self.sugDelay16))
        print("Suggested delay_17: " + str(self.sugDelay17))
        print("Suggested delay_18: " + str(self.sugDelay18))
        print("Suggested delay_19: " + str(self.sugDelay19))
        print("Suggested delay_20: " + str(self.sugDelay20))
        print("Suggested delay_21: " + str(self.sugDelay21))
        print("Suggested delay_22: " + str(self.sugDelay22))
        print("Suggested delay_23: " + str(self.sugDelay23))

        # apply suggested settings
        self.Delay0.set(self.sugDelay0)
        self.Delay1.set(self.sugDelay1)
        self.Delay2.set(self.sugDelay2)
        self.Delay3.set(self.sugDelay3)
        self.Delay4.set(self.sugDelay4)
        self.Delay5.set(self.sugDelay5)
        self.Delay6.set(self.sugDelay6)
        self.Delay7.set(self.sugDelay7)
        self.Delay8.set(self.sugDelay8)
        self.Delay9.set(self.sugDelay9)
        self.Delay10.set(self.sugDelay10)
        self.Delay11.set(self.sugDelay11)
        self.Delay12.set(self.sugDelay12)
        self.Delay13.set(self.sugDelay13)
        self.Delay14.set(self.sugDelay14)
        self.Delay15.set(self.sugDelay15)
        self.Delay16.set(self.sugDelay16)
        self.Delay17.set(self.sugDelay17)
        self.Delay18.set(self.sugDelay18)
        self.Delay19.set(self.sugDelay19)
        self.Delay20.set(self.sugDelay20)
        self.Delay21.set(self.sugDelay21)
        self.Delay22.set(self.sugDelay22)
        self.Delay23.set(self.sugDelay23)
        self.Resync.set(True)
        time.sleep(1.0 / float(100))
        self.Resync.set(False)


    def fnRefineDelays(self,dev,cmd,arg):
        """Find and set Monitoring ADC delays"""
        # parent = self.parent
        numDelayTaps = 512
        self.IDLE_PATTERN1 = 0xAAA83
        self.IDLE_PATTERN2 = 0xAA97C
        print("Executing delay test for ePixHr")

        #check adcs
        self.testResult = np.zeros((24,numDelayTaps))
        self.testDelay  = np.zeros((24,numDelayTaps))
        for delay in range (0, numDelayTaps):
            self.Delay0.set(delay)
            self.Delay1.set(delay)
            self.Delay2.set(delay)
            self.Delay3.set(delay)
            self.Delay4.set(delay)
            self.Delay5.set(delay)
            self.Delay6.set(delay)
            self.Delay7.set(delay)
            self.Delay8.set(delay)
            self.Delay9.set(delay)
            self.Delay10.set(delay)
            self.Delay11.set(delay)
            self.Delay12.set(delay)
            self.Delay13.set(delay)
            self.Delay14.set(delay)
            self.Delay15.set(delay)
            self.Delay16.set(delay)
            self.Delay17.set(delay)
            self.Delay18.set(delay)
            self.Delay19.set(delay)
            self.Delay20.set(delay)
            self.Delay21.set(delay)
            self.Delay22.set(delay)
            self.Delay23.set(delay)
            time.sleep(1.0 / float(100))
            self.testDelay[0,delay] =  self.Delay0.get()
            self.testDelay[1,delay] =  self.Delay1.get()
            self.testDelay[2,delay] =  self.Delay2.get()
            self.testDelay[3,delay] =  self.Delay3.get()
            self.testDelay[4,delay] =  self.Delay4.get()
            self.testDelay[5,delay] =  self.Delay5.get()
            self.testDelay[6,delay] =  self.Delay6.get()
            self.testDelay[7,delay] =  self.Delay7.get()
            self.testDelay[8,delay] =  self.Delay8.get()
            self.testDelay[9,delay] =  self.Delay9.get()
            self.testDelay[10,delay] = self.Delay10.get()
            self.testDelay[11,delay] = self.Delay11.get()
            self.testDelay[12,delay] = self.Delay12.get()
            self.testDelay[13,delay] = self.Delay13.get()
            self.testDelay[14,delay] = self.Delay14.get()
            self.testDelay[15,delay] = self.Delay15.get()
            self.testDelay[16,delay] = self.Delay16.get()
            self.testDelay[17,delay] = self.Delay17.get()
            self.testDelay[18,delay] = self.Delay18.get()
            self.testDelay[19,delay] = self.Delay19.get()
            self.testDelay[20,delay] = self.Delay20.get()
            self.testDelay[21,delay] = self.Delay21.get()
            self.testDelay[22,delay] = self.Delay22.get()
            self.testDelay[23,delay] = self.Delay23.get()
            ###
            #self.Resync.set(True)
            #self.Resync.set(False)
            ###
            time.sleep(1.0 / float(100))
            for checks in range(0,10):

                IserdeseOut_value = self.IserdeseOut0_0.get()
                self.testResult[0,delay] = (((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))+(self.testResult[0,delay]))
                IserdeseOut_value = self.IserdeseOut1_0.get()
                self.testResult[1,delay] = (((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))+(self.testResult[1,delay]))
                IserdeseOut_value = self.IserdeseOut2_0.get()
                self.testResult[2,delay] = (((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2)) +(self.testResult[2,delay]))
                IserdeseOut_value = self.IserdeseOut3_0.get()
                self.testResult[3,delay] = (((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2)) +(self.testResult[3,delay]))
                IserdeseOut_value = self.IserdeseOut4_0.get()
                self.testResult[4,delay] = (((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2)) +(self.testResult[4,delay]))
                IserdeseOut_value = self.IserdeseOut5_0.get()
                self.testResult[5,delay] = (((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2)) +(self.testResult[5,delay]))
                IserdeseOut_value = self.IserdeseOut6_0.get()
                self.testResult[6,delay] = (((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))+(self.testResult[6,delay]))
                IserdeseOut_value = self.IserdeseOut7_0.get()
                self.testResult[7,delay] = (((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2)) +(self.testResult[7,delay]))
                IserdeseOut_value = self.IserdeseOut8_0.get()
                self.testResult[8,delay] = (((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2)) +(self.testResult[8,delay]))
                IserdeseOut_value = self.IserdeseOut9_0.get()
                self.testResult[9,delay] = (((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2)) +(self.testResult[9,delay]))
                IserdeseOut_value = self.IserdeseOut10_0.get()
                self.testResult[10,delay] = (((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2)) +(self.testResult[10,delay]))
                IserdeseOut_value = self.IserdeseOut11_0.get()
                self.testResult[11,delay] = (((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2)) +(self.testResult[11,delay]))
                IserdeseOut_value = self.IserdeseOut12_0.get()
                self.testResult[12,delay] = (((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))+(self.testResult[12,delay]))
                IserdeseOut_value = self.IserdeseOut13_0.get()
                self.testResult[13,delay] = (((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2)) +(self.testResult[13,delay]))
                IserdeseOut_value = self.IserdeseOut14_0.get()
                self.testResult[14,delay] = (((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2)) +(self.testResult[14,delay]))
                IserdeseOut_value = self.IserdeseOut15_0.get()
                self.testResult[15,delay] = (((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2)) +(self.testResult[15,delay]))
                IserdeseOut_value = self.IserdeseOut16_0.get()
                self.testResult[16,delay] = (((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2)) +(self.testResult[16,delay]))
                IserdeseOut_value = self.IserdeseOut17_0.get()
                self.testResult[17,delay] = (((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2)) +(self.testResult[17,delay]))
                IserdeseOut_value = self.IserdeseOut18_0.get()
                self.testResult[18,delay] = (((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2))+(self.testResult[18,delay]))
                IserdeseOut_value = self.IserdeseOut19_0.get()
                self.testResult[19,delay] = (((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2)) +(self.testResult[19,delay]))
                IserdeseOut_value = self.IserdeseOut20_0.get()
                self.testResult[20,delay] = (((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2)) +(self.testResult[20,delay]))
                IserdeseOut_value = self.IserdeseOut21_0.get()
                self.testResult[21,delay] = (((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2)) +(self.testResult[21,delay]))
                IserdeseOut_value = self.IserdeseOut22_0.get()
                self.testResult[22,delay] = (((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2)) +(self.testResult[22,delay]))
                IserdeseOut_value = self.IserdeseOut23_0.get()
                self.testResult[23,delay] = (((IserdeseOut_value==self.IDLE_PATTERN1)or(IserdeseOut_value==self.IDLE_PATTERN2)) +(self.testResult[23,delay]))
        for i in range(0, 24):
            print("Test result adc %d:"%i)
            print(self.testResult[i,:]*self.testDelay)
        #np.savetxt(str(self.name)+'_delayRefineTestResultAll.csv', (self.testResult*self.testDelay), delimiter=',')
        np.savetxt(str(self.name)+'_delayRefineTestResultAll.csv', (self.testResult), delimiter=',')

        self.resultArray =  np.zeros((24,numDelayTaps))
        for j in range(0, 24):
            for i in range(1, numDelayTaps):
                if (self.testResult[j,i] != 0):
                    self.resultArray[j,i] = self.resultArray[j,i-1] + 1 #self.testResult[j,i]

        self.longestDelay0 = np.where(self.resultArray[0]==np.max(self.resultArray[0]))
        if len(self.longestDelay0[0])==1:
            self.sugDelay0 = int(self.longestDelay0[0]) - int(self.resultArray[0][self.longestDelay0]/2)
        else:
            self.sugDelay0 = int(self.longestDelay0[0][0]) - int(self.resultArray[0][self.longestDelay0[0][0]]/2)

        self.longestDelay1 = np.where(self.resultArray[1]==np.max(self.resultArray[1]))
        if len(self.longestDelay1[0])==1:
            self.sugDelay1 = int(self.longestDelay1[0]) - int(self.resultArray[1][self.longestDelay1]/2)
        else:
            self.sugDelay1 = int(self.longestDelay1[0][0]) - int(self.resultArray[1][self.longestDelay1[0][0]]/2)

        self.longestDelay2 = np.where(self.resultArray[2]==np.max(self.resultArray[2]))
        if len(self.longestDelay2[0])==1:
            self.sugDelay2 = int(self.longestDelay2[0]) - int(self.resultArray[2][self.longestDelay2]/2)
        else:
            self.sugDelay2 = int(self.longestDelay2[0][0]) - int(self.resultArray[2][self.longestDelay2[0][0]]/2)

        self.longestDelay3 = np.where(self.resultArray[3]==np.max(self.resultArray[3]))
        if len(self.longestDelay3[0])==1:
            self.sugDelay3 = int(self.longestDelay3[0]) - int(self.resultArray[3][self.longestDelay3]/2)
        else:
            self.sugDelay3 = int(self.longestDelay3[0][0]) - int(self.resultArray[3][self.longestDelay3[0][0]]/2)

        self.longestDelay4 = np.where(self.resultArray[4]==np.max(self.resultArray[4]))
        if len(self.longestDelay4[0])==1:
            self.sugDelay4 = int(self.longestDelay4[0]) - int(self.resultArray[4][self.longestDelay4]/2)
        else:
            self.sugDelay4 = int(self.longestDelay4[0][0]) - int(self.resultArray[4][self.longestDelay4[0][0]]/2)

        self.longestDelay5 = np.where(self.resultArray[5]==np.max(self.resultArray[5]))
        if len(self.longestDelay5[0])==1:
            self.sugDelay5 = int(self.longestDelay5[0]) - int(self.resultArray[5][self.longestDelay5]/2)
        else:
            self.sugDelay5 = int(self.longestDelay5[0][0]) - int(self.resultArray[5][self.longestDelay5[0][0]]/2)

        self.longestDelay6 = np.where(self.resultArray[6]==np.max(self.resultArray[6]))
        if len(self.longestDelay6[0])==1:
            self.sugDelay6 = int(self.longestDelay6[0]) - int(self.resultArray[6][self.longestDelay6]/2)
        else:
            self.sugDelay6 = int(self.longestDelay6[0][0]) - int(self.resultArray[6][self.longestDelay6[0][0]]/2)

        self.longestDelay7 = np.where(self.resultArray[7]==np.max(self.resultArray[7]))
        if len(self.longestDelay7[0])==1:
            self.sugDelay7 = int(self.longestDelay7[0]) - int(self.resultArray[7][self.longestDelay7]/2)
        else:
            self.sugDelay7 = int(self.longestDelay7[0][0]) - int(self.resultArray[7][self.longestDelay7[0][0]]/2)

        self.longestDelay8 = np.where(self.resultArray[8]==np.max(self.resultArray[8]))
        if len(self.longestDelay8[0])==1:
            self.sugDelay8 = int(self.longestDelay8[0]) - int(self.resultArray[8][self.longestDelay8]/2)
        else:
            self.sugDelay8 = int(self.longestDelay8[0][0]) - int(self.resultArray[8][self.longestDelay8[0][0]]/2)

        self.longestDelay9 = np.where(self.resultArray[9]==np.max(self.resultArray[9]))
        if len(self.longestDelay9[0])==1:
            self.sugDelay9 = int(self.longestDelay9[0]) - int(self.resultArray[9][self.longestDelay9]/2)
        else:
            self.sugDelay9 = int(self.longestDelay9[0][0]) - int(self.resultArray[9][self.longestDelay9[0][0]]/2)

        self.longestDelay10 = np.where(self.resultArray[10]==np.max(self.resultArray[10]))
        if len(self.longestDelay10[0])==1:
            self.sugDelay10 = int(self.longestDelay10[0]) - int(self.resultArray[10][self.longestDelay10]/2)
        else:
            self.sugDelay10 = int(self.longestDelay10[0][0]) - int(self.resultArray[10][self.longestDelay10[0][0]]/2)

        self.longestDelay11 = np.where(self.resultArray[11]==np.max(self.resultArray[11]))
        if len(self.longestDelay11[0])==1:
            self.sugDelay11 = int(self.longestDelay11[0]) - int(self.resultArray[11][self.longestDelay11]/2)
        else:
            self.sugDelay11 = int(self.longestDelay11[0][0]) - int(self.resultArray[11][self.longestDelay11[0][0]]/2)

        self.longestDelay12 = np.where(self.resultArray[12]==np.max(self.resultArray[12]))
        if len(self.longestDelay12[0])==1:
            self.sugDelay12 = int(self.longestDelay12[0]) - int(self.resultArray[12][self.longestDelay12]/2)
        else:
            self.sugDelay12 = int(self.longestDelay12[0][0]) - int(self.resultArray[12][self.longestDelay12[0][0]]/2)

        self.longestDelay13 = np.where(self.resultArray[13]==np.max(self.resultArray[13]))
        if len(self.longestDelay13[0])==1:
            self.sugDelay13 = int(self.longestDelay13[0]) - int(self.resultArray[13][self.longestDelay13]/2)
        else:
            self.sugDelay13 = int(self.longestDelay13[0][0]) - int(self.resultArray[13][self.longestDelay13[0][0]]/2)

        self.longestDelay14 = np.where(self.resultArray[14]==np.max(self.resultArray[14]))
        if len(self.longestDelay14[0])==1:
            self.sugDelay14 = int(self.longestDelay14[0]) - int(self.resultArray[14][self.longestDelay14]/2)
        else:
            self.sugDelay14 = int(self.longestDelay14[0][0]) - int(self.resultArray[14][self.longestDelay14[0][0]]/2)

        self.longestDelay15 = np.where(self.resultArray[15]==np.max(self.resultArray[15]))
        if len(self.longestDelay15[0])==1:
            self.sugDelay15 = int(self.longestDelay15[0]) - int(self.resultArray[15][self.longestDelay15]/2)
        else:
            self.sugDelay15 = int(self.longestDelay15[0][0]) - int(self.resultArray[15][self.longestDelay15[0][0]]/2)

        self.longestDelay16 = np.where(self.resultArray[16]==np.max(self.resultArray[16]))
        if len(self.longestDelay16[0])==1:
            self.sugDelay16 = int(self.longestDelay16[0]) - int(self.resultArray[16][self.longestDelay16]/2)
        else:
            self.sugDelay16 = int(self.longestDelay16[0][0]) - int(self.resultArray[16][self.longestDelay16[0][0]]/2)

        self.longestDelay17 = np.where(self.resultArray[17]==np.max(self.resultArray[17]))
        if len(self.longestDelay17[0])==1:
            self.sugDelay17 = int(self.longestDelay17[0]) - int(self.resultArray[17][self.longestDelay17]/2)
        else:
            self.sugDelay17 = int(self.longestDelay17[0][0]) - int(self.resultArray[17][self.longestDelay17[0][0]]/2)

        self.longestDelay18 = np.where(self.resultArray[18]==np.max(self.resultArray[18]))
        if len(self.longestDelay18[0])==1:
            self.sugDelay18 = int(self.longestDelay18[0]) - int(self.resultArray[18][self.longestDelay18]/2)
        else:
            self.sugDelay18 = int(self.longestDelay18[0][0]) - int(self.resultArray[18][self.longestDelay18[0][0]]/2)

        self.longestDelay19 = np.where(self.resultArray[19]==np.max(self.resultArray[19]))
        if len(self.longestDelay19[0])==1:
            self.sugDelay19 = int(self.longestDelay19[0]) - int(self.resultArray[19][self.longestDelay19]/2)
        else:
            self.sugDelay19 = int(self.longestDelay19[0][0]) - int(self.resultArray[19][self.longestDelay19[0][0]]/2)

        self.longestDelay20 = np.where(self.resultArray[20]==np.max(self.resultArray[20]))
        if len(self.longestDelay20[0])==1:
            self.sugDelay20 = int(self.longestDelay20[0]) - int(self.resultArray[20][self.longestDelay20]/2)
        else:
            self.sugDelay20 = int(self.longestDelay20[0][0]) - int(self.resultArray[20][self.longestDelay20[0][0]]/2)

        self.longestDelay21 = np.where(self.resultArray[21]==np.max(self.resultArray[21]))
        if len(self.longestDelay21[0])==1:
            self.sugDelay21 = int(self.longestDelay21[0]) - int(self.resultArray[21][self.longestDelay21]/2)
        else:
            self.sugDelay21 = int(self.longestDelay21[0][0]) - int(self.resultArray[21][self.longestDelay21[0][0]]/2)

        self.longestDelay22 = np.where(self.resultArray[22]==np.max(self.resultArray[22]))
        if len(self.longestDelay22[0])==1:
            self.sugDelay22 = int(self.longestDelay22[0]) - int(self.resultArray[22][self.longestDelay22]/2)
        else:
            self.sugDelay22 = int(self.longestDelay22[0][0]) - int(self.resultArray[22][self.longestDelay22[0][0]]/2)

        self.longestDelay23 = np.where(self.resultArray[23]==np.max(self.resultArray[23]))
        if len(self.longestDelay23[0])==1:
            self.sugDelay23 = int(self.longestDelay23[0]) - int(self.resultArray[23][self.longestDelay23]/2)
        else:
            self.sugDelay23 = int(self.longestDelay23[0][0]) - int(self.resultArray[23][self.longestDelay23[0][0]]/2)
        print("Suggested delay_0: " + str(self.sugDelay0))
        print("Suggested delay_1: " + str(self.sugDelay1))
        print("Suggested delay_2: " + str(self.sugDelay2))
        print("Suggested delay_3: " + str(self.sugDelay3))
        print("Suggested delay_4: " + str(self.sugDelay4))
        print("Suggested delay_5: " + str(self.sugDelay5))
        print("Suggested delay_6: " + str(self.sugDelay6))
        print("Suggested delay_7: " + str(self.sugDelay7))
        print("Suggested delay_8: " + str(self.sugDelay8))
        print("Suggested delay_9: " + str(self.sugDelay9))
        print("Suggested delay_10: " + str(self.sugDelay10))
        print("Suggested delay_11: " + str(self.sugDelay11))
        print("Suggested delay_12: " + str(self.sugDelay12))
        print("Suggested delay_13: " + str(self.sugDelay13))
        print("Suggested delay_14: " + str(self.sugDelay14))
        print("Suggested delay_15: " + str(self.sugDelay15))
        print("Suggested delay_16: " + str(self.sugDelay16))
        print("Suggested delay_17: " + str(self.sugDelay17))
        print("Suggested delay_18: " + str(self.sugDelay18))
        print("Suggested delay_19: " + str(self.sugDelay19))
        print("Suggested delay_20: " + str(self.sugDelay20))
        print("Suggested delay_21: " + str(self.sugDelay21))
        print("Suggested delay_22: " + str(self.sugDelay22))
        print("Suggested delay_23: " + str(self.sugDelay23))
        # apply suggested settings
        self.Delay0.set(self.sugDelay0)
        self.Delay1.set(self.sugDelay1)
        self.Delay2.set(self.sugDelay2)
        self.Delay3.set(self.sugDelay3)
        self.Delay4.set(self.sugDelay4)
        self.Delay5.set(self.sugDelay5)
        self.Delay6.set(self.sugDelay6)
        self.Delay7.set(self.sugDelay7)
        self.Delay8.set(self.sugDelay8)
        self.Delay9.set(self.sugDelay9)
        self.Delay10.set(self.sugDelay10)
        self.Delay11.set(self.sugDelay11)
        self.Delay12.set(self.sugDelay12)
        self.Delay13.set(self.sugDelay13)
        self.Delay14.set(self.sugDelay14)
        self.Delay15.set(self.sugDelay15)
        self.Delay16.set(self.sugDelay16)
        self.Delay17.set(self.sugDelay17)
        self.Delay18.set(self.sugDelay18)
        self.Delay19.set(self.sugDelay19)
        self.Delay20.set(self.sugDelay20)
        self.Delay21.set(self.sugDelay21)
        self.Delay22.set(self.sugDelay22)
        self.Delay23.set(self.sugDelay23)
        ###
        #self.Resync.set(True)
        #time.sleep(1.0 / float(100))
        #self.Resync.set(False)
        ###


    @staticmethod
    def setDelay(var, value, write):
        iValue = value + 512
        var.dependencies[0].set(iValue, write)


    @staticmethod
    def getDelay(var, read):
        return var.dependencies[0].get(read)
