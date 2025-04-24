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

class sDacRegisters(pr.Device):
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


        # Setup registers & variables

        # Add Five DAC Registers
        for i in range(5):
            self.add(pr.RemoteVariable(
                name = f'dac_{i}',
                offset = i * 4,
                bitSize = 16,
                bitOffset = 0,
                base = pr.UInt,
                disp = '{:#x}',
                mode = 'RW'))
        
        # Add Dummy Register
        self.add(pr.RemoteVariable(
        name = 'dummy',
        description = '',
        offset = 0x00014,
        bitSize = 32,
        bitOffset = 0,
        base = pr.UInt,
        disp = '{:#x}',
        mode = 'RW'))

        # Add DAC Voltage Linker Variables
        for i in range(5):
            self.add(pr.LinkVariable(
                name = f'Vdac_{i}',
                units = 'V',
                disp = '{:1.3f}', # Only display the 1st 3 decimal points
                linkedGet = self.convtFloat,
                linkedSet = self.revConvtFloat,
                dependencies = [self.variables[f'dac_{i}']]
            ))

        #####################################
        # Create commands
        #####################################

        # A command has an associated function. The function can be a series of
        # python commands in a string. Function calls are executed in the command scope
        # the passed arg is available as 'arg'. Use 'dev' to get to device scope.
        # A command can also be a call to a local function with local scope.
        # The command object and the arg are passed

    def convtFloat(self, var, read):
        intValue = var.dependencies[0].get(read=read)
        return float(intValue)*(3.0/65536.0)

    def revConvtFloat(self, var, value, write):
        assert 0 <= value <= 3.0, f"Value {value} is outside reference voltage range: 0 V to 2.999 V"
        intValue = int(value*(65536.0/3.0))
        var.dependencies[0].set(value=intValue, write=write)
        return f'{intValue:04X}'

    def frequencyConverter(self):
        def func(dev, var):
            return '{:.3f} kHz'.format(1/(self.clkPeriod * self._count(var.dependencies)) * 1e-3)
        return func
