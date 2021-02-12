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

class OscilloscopeRegisters(pr.Device):
    def __init__(self, trigChEnum, inChaEnum, inChbEnum, **kwargs):
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

        self.add(pr.RemoteVariable(name='ArmReg',          description='Arm',               offset=0x00000000, bitSize=1,  bitOffset=0, base=pr.Bool, mode='RW', verify=False, pollInterval = 1))
        self.add(pr.RemoteVariable(name='TrigReg',         description='Trig',              offset=0x00000004, bitSize=1,  bitOffset=0, base=pr.Bool, mode='RW', verify=False, pollInterval = 1))
        self.add((
            pr.RemoteVariable(name='ScopeEnable',     description='Setting1', offset=0x00000008, bitSize=1,  bitOffset=0,  base=pr.Bool, mode='RW'),
            pr.RemoteVariable(name='TriggerEdge',     description='Setting1', offset=0x00000008, bitSize=1,  bitOffset=1,  mode='RW', enum={0:'Falling', 1:'Rising'}),
            pr.RemoteVariable(name='TriggerChannel',  description='Setting1', offset=0x00000008, bitSize=4,  bitOffset=2,  mode='RW', enum=trigChEnum),
            pr.RemoteVariable(name='TriggerMode',     description='Setting1', offset=0x00000008, bitSize=2,  bitOffset=6,  mode='RW', enum={0:'Never', 1:'ArmReg', 2:'AcqStart', 3:'Always'}),
            pr.RemoteVariable(name='TriggerAdcThresh',description='Setting1', offset=0x00000008, bitSize=16, bitOffset=16, base=pr.UInt, disp = '{}', mode='RW')))
        self.add((
            pr.RemoteVariable(name='TriggerHoldoff',  description='Setting2', offset=0x0000000C, bitSize=13, bitOffset=0,  base=pr.UInt, disp = '{}', mode='RW'),
            pr.RemoteVariable(name='TriggerOffset',   description='Setting2', offset=0x0000000C, bitSize=13, bitOffset=13, base=pr.UInt, disp = '{}', mode='RW')))
        self.add((
            pr.RemoteVariable(name='TraceLength',     description='Setting3', offset=0x00000010, bitSize=13, bitOffset=0,  base=pr.UInt, disp = '{}', mode='RW'),
            pr.RemoteVariable(name='SkipSamples',     description='Setting3', offset=0x00000010, bitSize=13, bitOffset=13, base=pr.UInt, disp = '{}', mode='RW')))
        self.add((
            pr.RemoteVariable(name='InputChannelA',   description='Setting4', offset=0x00000014, bitSize=2,  bitOffset=0,  mode='RW', enum=inChaEnum),
            pr.RemoteVariable(name='InputChannelB',   description='Setting4', offset=0x00000014, bitSize=2,  bitOffset=5,  mode='RW', enum=inChbEnum)))
        self.add(pr.RemoteVariable(name='TriggerDelay',    description='TriggerDelay',      offset=0x00000018, bitSize=13, bitOffset=0, base=pr.UInt, disp = '{}', mode='RW'))


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
