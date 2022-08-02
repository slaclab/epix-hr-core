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

class AsicDeserHr16bRegisters6St(pr.Device):
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
        self.add(pr.RemoteVariable(name='StreamsEn_n',  description='Enable/Disable', offset=0x00000000, bitSize=6,  bitOffset=0,  base=pr.UInt, mode='RW'))
        self.add(pr.RemoteVariable(name=('IdelayRst'),     description='iDelay reset',  offset=0x00000008, bitSize=6, bitOffset=0, base=pr.UInt,  disp = '{:#x}', mode='RW'))
        self.add(pr.RemoteVariable(name=('IserdeseRst'),   description='iSerdese3 reset',  offset=0x0000000C, bitSize=6, bitOffset=0, base=pr.UInt,  disp = '{:#x}', mode='RW'))
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

        for i in range(0, 6):
            self.add(pr.RemoteVariable(name=('LockErrors%d'%i),  description='LockErrors',     offset=0x00000100+i*4, bitSize=16, bitOffset=0,  base=pr.UInt, disp = '{}', mode='RO'))
            self.add(pr.RemoteVariable(name=('Locked%d'%i),      description='Locked',         offset=0x00000100+i*4, bitSize=1,  bitOffset=16, base=pr.Bool, mode='RO'))

        for j in range(0, 6):
            for i in range(0, 2):
                self.add(pr.RemoteVariable(name=('IserdeseOut%d_%d' % (j, i)),   description='IserdeseOut'+str(i),  offset=0x00000300+i*4+j*8, bitSize=20, bitOffset=0, base=pr.UInt,  disp = '{:#x}', mode='RO'))

        self.add(pr.RemoteVariable(name='FreezeDebug',      description='Restart BERT',  offset=0x00000400, bitSize=1,  bitOffset=0, base=pr.Bool, mode='RW'))
        self.add(pr.RemoteVariable(name='BERTRst',      description='Restart BERT',      offset=0x00000400, bitSize=1,  bitOffset=1, base=pr.Bool, mode='RW'))
        for i in range(0, 6):
            self.add(pr.RemoteVariable(name='BERTCounter'+str(i),   description='Counter value.'+str(i),  offset=0x00000404+i*8, bitSize=44, bitOffset=0, base=pr.UInt,  disp = '{}', mode='RO'))

        for i in range(0,6):
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
            self.testDelay[0,delay] =  self.Delay0.get()
            self.testDelay[1,delay] =  self.Delay1.get()
            self.testDelay[2,delay] =  self.Delay2.get()
            self.testDelay[3,delay] =  self.Delay3.get()
            self.testDelay[4,delay] =  self.Delay4.get()
            self.testDelay[5,delay] =  self.Delay5.get()

            if noReSync == 0:
                self.Resync.set(True)
                self.Resync.set(False)
            time.sleep(1.0 / float(100))
            IserdeseOut_value = self.IserdeseOut0_0.get()
            self.testResult[0,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1) or (IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut1_0.get()
            self.testResult[1,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1) or (IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut2_0.get()
            self.testResult[2,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1) or (IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut3_0.get()
            self.testResult[3,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1) or (IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut4_0.get()
            self.testResult[4,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1) or (IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut5_0.get()
            self.testResult[5,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1) or (IserdeseOut_value==self.IDLE_PATTERN2))


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


        print("Suggested delay_0: " + str(self.sugDelay0))
        print("Suggested delay_1: " + str(self.sugDelay1))
        print("Suggested delay_2: " + str(self.sugDelay2))
        print("Suggested delay_3: " + str(self.sugDelay3))
        print("Suggested delay_4: " + str(self.sugDelay4))
        print("Suggested delay_5: " + str(self.sugDelay5))

        # apply suggested settings
        self.Delay0.set(self.sugDelay0)
        self.Delay1.set(self.sugDelay1)
        self.Delay2.set(self.sugDelay2)
        self.Delay3.set(self.sugDelay3)
        self.Delay4.set(self.sugDelay4)
        self.Delay5.set(self.sugDelay5)
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
        self.testResult = np.zeros((6,numDelayTaps))
        self.testDelay  = np.zeros((6,numDelayTaps))
        for delay in range (0, numDelayTaps):
            self.Delay0.set(delay)
            self.Delay1.set(delay)
            self.Delay2.set(delay)
            self.Delay3.set(delay)
            self.Delay4.set(delay)
            self.Delay5.set(delay)
            self.testDelay[0,delay] = self.Delay0.get()
            self.testDelay[1,delay] = self.Delay1.get()
            self.testDelay[2,delay] = self.Delay2.get()
            self.testDelay[3,delay] = self.Delay3.get()
            self.testDelay[4,delay] = self.Delay4.get()
            self.testDelay[5,delay] = self.Delay5.get()
            self.Resync.set(True)
            self.Resync.set(False)
            time.sleep(1.0 / float(100))
            IserdeseOut_value = self.IserdeseOut0_0.get()
            self.testResult[0,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1) or (IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut1_0.get()
            self.testResult[1,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1) or (IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut2_0.get()
            self.testResult[2,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1) or (IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut3_0.get()
            self.testResult[3,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1) or (IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut4_0.get()
            self.testResult[4,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1) or (IserdeseOut_value==self.IDLE_PATTERN2))
            IserdeseOut_value = self.IserdeseOut5_0.get()
            self.testResult[5,delay] = ((IserdeseOut_value==self.IDLE_PATTERN1) or (IserdeseOut_value==self.IDLE_PATTERN2))
        print("Test result adc 0:")
        print(self.testResult[0,:]*self.testDelay)
        print("Test result adc 1:")
        print(self.testResult[1,:]*self.testDelay)
        print("Test result adc 2:")
        print(self.testResult[2,:]*self.testDelay)
        print("Test result adc 3:")
        print(self.testResult[3,:]*self.testDelay)
        print("Test result adc 4:")
        print(self.testResult[4,:]*self.testDelay)
        print("Test result adc 5:")
        print(self.testResult[5,:]*self.testDelay)
        np.savetxt(str(self.name)+'_delayTestResultAll.csv', (self.testResult*self.testDelay), delimiter=',')




        self.resultArray =  np.zeros((6,numDelayTaps))
        for j in range(0, 6):
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
        #self.longestDelay1 = np.where(self.resultArray1==np.max(self.resultArray1))
        #if len(self.longestDelay1[0])==1:
        #    self.sugDelay1 = int(self.longestDelay1[0]) - int(self.resultArray1[self.longestDelay1]/2)
        #else:
        #    self.sugDelay1 = int(self.longestDelay1[0][0]) - int(self.resultArray1[self.longestDelay1[0][0]]/2)
        print("Suggested delay_0: " + str(self.sugDelay0))
        print("Suggested delay_1: " + str(self.sugDelay1))
        print("Suggested delay_2: " + str(self.sugDelay2))
        print("Suggested delay_3: " + str(self.sugDelay3))
        print("Suggested delay_4: " + str(self.sugDelay4))
        print("Suggested delay_5: " + str(self.sugDelay5))
        # apply suggested settings
        self.Delay0.set(self.sugDelay0)
        self.Delay1.set(self.sugDelay1)
        self.Delay2.set(self.sugDelay2)
        self.Delay3.set(self.sugDelay3)
        self.Delay4.set(self.sugDelay4)
        self.Delay5.set(self.sugDelay5)
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
        self.testResult = np.zeros((6,numDelayTaps))
        self.testDelay  = np.zeros((6,numDelayTaps))
        for delay in range (0, numDelayTaps):
            self.Delay0.set(delay)
            self.Delay1.set(delay)
            self.Delay2.set(delay)
            self.Delay3.set(delay)
            self.Delay4.set(delay)
            self.Delay5.set(delay)
            time.sleep(1.0 / float(100))
            self.testDelay[0,delay] = self.Delay0.get()
            self.testDelay[1,delay] = self.Delay1.get()
            self.testDelay[2,delay] = self.Delay2.get()
            self.testDelay[3,delay] = self.Delay3.get()
            self.testDelay[4,delay] = self.Delay4.get()
            self.testDelay[5,delay] = self.Delay5.get()
            ###
            #self.Resync.set(True)
            #self.Resync.set(False)
            ###
            time.sleep(1.0 / float(100))
            for checks in range(0,10):
                IserdeseOut_value = self.IserdeseOut0_0.get()
                self.testResult[0,delay] = (((IserdeseOut_value==self.IDLE_PATTERN1) or (IserdeseOut_value==self.IDLE_PATTERN2))+(self.testResult[0,delay]))
                IserdeseOut_value = self.IserdeseOut1_0.get()
                self.testResult[1,delay] = (((IserdeseOut_value==self.IDLE_PATTERN1) or (IserdeseOut_value==self.IDLE_PATTERN2))+(self.testResult[1,delay]))
                IserdeseOut_value = self.IserdeseOut2_0.get()
                self.testResult[2,delay] = (((IserdeseOut_value==self.IDLE_PATTERN1) or (IserdeseOut_value==self.IDLE_PATTERN2))+(self.testResult[2,delay]))
                IserdeseOut_value = self.IserdeseOut3_0.get()
                self.testResult[3,delay] = (((IserdeseOut_value==self.IDLE_PATTERN1) or (IserdeseOut_value==self.IDLE_PATTERN2))+(self.testResult[3,delay]))
                IserdeseOut_value = self.IserdeseOut4_0.get()
                self.testResult[4,delay] = (((IserdeseOut_value==self.IDLE_PATTERN1) or (IserdeseOut_value==self.IDLE_PATTERN2))+(self.testResult[4,delay]))
                IserdeseOut_value = self.IserdeseOut5_0.get()
                self.testResult[5,delay] = (((IserdeseOut_value==self.IDLE_PATTERN1) or (IserdeseOut_value==self.IDLE_PATTERN2))+(self.testResult[5,delay]))
        print("Test result adc 0:")
        print(self.testResult[0,:]*self.testDelay)
        print("Test result adc 1:")
        print(self.testResult[1,:]*self.testDelay)
        print("Test result adc 2:")
        print(self.testResult[2,:]*self.testDelay)
        print("Test result adc 3:")
        print(self.testResult[3,:]*self.testDelay)
        print("Test result adc 4:")
        print(self.testResult[4,:]*self.testDelay)
        print("Test result adc 5:")
        print(self.testResult[5,:]*self.testDelay)
        #np.savetxt(str(self.name)+'_delayRefineTestResultAll.csv', (self.testResult*self.testDelay), delimiter=',')
        np.savetxt(str(self.name)+'_delayRefineTestResultAll.csv', (self.testResult), delimiter=',')

        self.resultArray =  np.zeros((6,numDelayTaps))
        for j in range(0, 6):
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
        print("Suggested delay_0: " + str(self.sugDelay0))
        print("Suggested delay_1: " + str(self.sugDelay1))
        print("Suggested delay_2: " + str(self.sugDelay2))
        print("Suggested delay_3: " + str(self.sugDelay3))
        print("Suggested delay_4: " + str(self.sugDelay4))
        print("Suggested delay_5: " + str(self.sugDelay5))
        # apply suggested settings
        self.Delay0.set(self.sugDelay0)
        self.Delay1.set(self.sugDelay1)
        self.Delay2.set(self.sugDelay2)
        self.Delay3.set(self.sugDelay3)
        self.Delay4.set(self.sugDelay4)
        self.Delay5.set(self.sugDelay5)
        ###
        #self.Resync.set(True)
        #time.sleep(1.0 / float(100))
        #self.Resync.set(False)
        ###


    @staticmethod
    def setDelay(var, value, write):
        iValue = value + 512
        var.dependencies[0].set(iValue, write)
        var.dependencies[0].set(value, write)

    @staticmethod
    def getDelay(var, read):
        return var.dependencies[0].get(read)
