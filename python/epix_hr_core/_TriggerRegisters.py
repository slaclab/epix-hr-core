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
class TriggerRegisters(pr.Device):
    def __init__(self, triggerFreq = 1e8, axiFreq = 156.25e6, **kwargs):
        super().__init__(description='Trigger Registers', **kwargs)

        # Creation. memBase is either the register bus server (srp, rce mapped memory, etc) or the device which
        # contains this object. In most cases the parent and memBase are the same but they can be
        # different in more complex bus structures. They will also be different for the top most node.
        # The setMemBase call can be used to update the memBase for this Device. All sub-devices and local
        # blocks will be updated.

        #############################################
        # Create block / variable combinations
        #############################################
        runDaqEnum = {0: "Run", 1: "Daq"}

        #Setup registers & variables
        self.add(pr.LocalVariable(
            name        = 'AxilFrequency',
            description = '',
            mode        = 'RO',
            value       = axiFreq*1e-6,
            units       = 'Mhz',
             disp       = '{:1.3f}'
        ))
        self.add(pr.RemoteVariable(name='RunTriggerEnable',      description='RunTriggerEnable',  offset=0x00000000, bitSize=1,  bitOffset=0, base=pr.Bool, mode='RW'))
        self.add(pr.RemoteVariable(name='TimingRunTriggerEnable',description='RunTriggerEnable',  offset=0x00000000, bitSize=1,  bitOffset=1, base=pr.Bool, mode='RW'))
        self.add(pr.RemoteVariable(name='RunTriggerDelay',       description='RunTriggerDelay',   offset=0x00000004, bitSize=32, bitOffset=0, base=pr.UInt, disp = '{}', mode='RW'))
        self.add(pr.RemoteVariable(name='DaqTriggerEnable',      description='DaqTriggerEnable',  offset=0x00000008, bitSize=1,  bitOffset=0, base=pr.Bool, mode='RW'))
        self.add(pr.RemoteVariable(name='TimingDaqTriggerEnable',description='DaqTriggerEnable',  offset=0x00000008, bitSize=1,  bitOffset=1, base=pr.Bool, mode='RW'))
        self.add(pr.RemoteVariable(name='DaqTriggerDelay',       description='DaqTriggerDelay',   offset=0x0000000C, bitSize=32, bitOffset=0, base=pr.UInt, disp = '{}', mode='RW'))
        self.add(pr.RemoteVariable(name='AutoRunEn',             description='AutoRunEn',         offset=0x00000010, bitSize=1,  bitOffset=0, base=pr.Bool, mode='RW'))
        self.add(pr.RemoteVariable(name='AutoDaqEn',             description='AutoDaqEn',         offset=0x00000014, bitSize=1,  bitOffset=0, base=pr.Bool, mode='RW'))
        self.add(pr.RemoteVariable(name='AutoTrigPeriod',        description='AutoTrigPeriod',    offset=0x00000018, bitSize=32, bitOffset=0, base=pr.UInt, disp = '{}', mode='RW'))
        self.add(pr.RemoteVariable(name='PgpTrigEn',             description='PgpTrigEn',         offset=0x0000001C, bitSize=1,  bitOffset=0, base=pr.Bool, mode='RW'))
        self.add(pr.RemoteVariable(name='AcqCount',              description='RunCount',          offset=0x00000024, bitSize=32, bitOffset=0, base=pr.UInt, disp = '{}', mode='RO', pollInterval = 1))
        self.add(pr.RemoteVariable(name='DaqCount',              description='DaqCount',          offset=0x00000028, bitSize=32, bitOffset=0, base=pr.UInt, disp = '{}', mode='RO', pollInterval = 1))
        self.add(pr.RemoteVariable(name='numberTrigger',         description='numberTrigger',     offset=0x0000002C, bitSize=32, bitOffset=0, base=pr.UInt, disp = '{}', mode='RW'))
        self.add(pr.RemoteVariable(name='numberTriggerType',     description='numTriggersType',     offset=0x0000003C, bitSize=1, bitOffset=0, base=pr.UInt, mode='RW', enum = runDaqEnum))
        self.add(pr.RemoteVariable(name='daqPauseEn',            description='daqPauseEn',         offset=0x00000038, bitSize=1,  bitOffset=0, base=pr.Bool, mode='RW'))
        self.add(pr.RemoteVariable(name='RunPauseCount',         description='RunPauseCount',     offset=0x00000030, bitSize=32, bitOffset=0, base=pr.UInt, disp = '{}', mode='RO', pollInterval = 1))
        self.add(pr.RemoteVariable(name='DaqPauseCount',         description='DaqPauseCount',     offset=0x00000034, bitSize=32, bitOffset=0, base=pr.UInt, disp = '{}', mode='RO', pollInterval = 1))
        self.add(pr.RemoteVariable(name='daqPauseCycleCntMaxH',  description='daqPauseCycleCntMax',     offset=0x00000040, bitSize=32, bitOffset=0, base=pr.UInt, disp = '{}', mode='RO', pollInterval = 1, hidden = True))
        self.add(pr.RemoteVariable(name='daqPauseCycleCntMinH',  description='daqPauseCycleCntMin',     offset=0x00000044, bitSize=32, bitOffset=0, base=pr.UInt, disp = '{}', mode='RO', pollInterval = 1, hidden = True))

        self.add(pr.LinkVariable(  name='daqPauseCycleCntMax',      description='Max daqPauseCycleCnt in uS (app clk domain)',    mode='RO', units='uS', disp='{:1.3f}', linkedGet=self.timeConverterAppClock, dependencies = [self.daqPauseCycleCntMaxH, self.AxilFrequency]))
        self.add(pr.LinkVariable(  name='daqPauseCycleCntMin',      description='Min daqPauseCycleCnt in uS (app clk domain)',    mode='RO', units='uS', disp='{:1.3f}', linkedGet=self.timeConverterAppClock, dependencies = [self.daqPauseCycleCntMinH, self.AxilFrequency]))
        #####################################
        # Create commands
        #####################################

        # A command has an associated function. The function can be a series of
        # python commands in a string. Function calls are executed in the command scope
        # the passed arg is available as 'arg'. Use 'dev' to get to device scope.
        # A command can also be a call to a local function with local scope.
        # The command object and the arg are passed
        self.add(pr.RemoteCommand(name='AcqCountReset', description='Resets Acq counter', offset=0x00000020, bitSize=1, bitOffset=0, function=pr.Command.touchOne))

        @self.command(description = 'Set Auto Trigger period (Hz)', value=1000)
        def SetAutoTrigger (arg):
            print('Set Auto Trigger command executed')
            self.TimingDaqTriggerEnable.set(False)
            self.TimingRunTriggerEnable.set(False)
            period = int(1/arg*triggerFreq)
            self.AutoTrigPeriod.set(period)
            self.AutoRunEn.set(True)
            self.AutoDaqEn.set(True)

        @self.command(description = 'Start and enable auto triggers')
        def StartAutoTrigger ():
            print('Start Auto Trigger command executed')
            # DaqCount AND AcqCount must be identical, otherwise triggers are
            # being sent to the ASICs without reseting the fifos OR warning the
            # logic! Fifos get full and overflow is detected, but not because the
            # logic is not catching up
            self.AutoDaqEn.set(True)
            self.DaqTriggerEnable.set(True)
            self.AutoRunEn.set(True)
            self.RunTriggerEnable.set(True)

        @self.command(description = 'Stop all trigger sources')
        def StopTriggers ():
            print('Stop Triggers command executed')
            self.PgpTrigEn.set(False)
            self.AutoRunEn.set(False)
            self.TimingRunTriggerEnable.set(False)
            self.RunTriggerEnable.set(False)
            self.AutoDaqEn.set(False)
            self.TimingDaqTriggerEnable.set(False)
            self.DaqTriggerEnable.set(False)

        @self.command(description = 'Set Timing Trigger input', )
        def SetTimingTrigger ():
            print('Set Timing Trigger command executed')
            self.AutoRunEn.set(False)
            self.AutoDaqEn.set(False)
            self.TimingDaqTriggerEnable.set(True)
            self.TimingRunTriggerEnable.set(True)
            self.RunTriggerEnable.set(True)
            self.DaqTriggerEnable.set(True)
            self.PgpTrigEn.set(True)

    @staticmethod
    def frequencyConverter(self):
        def func(dev, var):
            return '{:.3f} kHz'.format(1/(self.clkPeriod * self._count(var.dependencies)) * 1e-3)
        return func

    @staticmethod
    def timeConverterAppClock(var, read):
        """Converts a number of cycles in micro seconds."""
        raw = var.dependencies[0].get(read=read)
        return ((raw)/ (var.dependencies[1].value()))
