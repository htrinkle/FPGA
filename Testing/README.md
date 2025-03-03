# Testing the FPGA Analog Board

## Approach

The board was built and tested in stages.  

| Stage | PCB Assembly | Tests | Status |
|-|-|-|-|
| Power | Populate LM1117-3.3 and LM1117-1.2 plus surrounding capacitors | Apply VCC (current limit to several milliamps), measure voltages | OK |
| FPGA | Polulate FPGA, FPGA decoupling caps, 10K + 1K pin strapping resistors, FPGA prog header | Connect to USB-Blaster, apply VCC and check if FPGA detected in JTAG scan from within Quartus | OK |
| FPGA | Populate push button, LED1,2,3 and associated resistors | Upload TEST_PB_LED.  Expect LED 1 and 3 to light if button pushed, LED 2 in inverse of LED 1 and 3 | OK |
| FPGA | Populate PROM | Verify PROM programming via JTAG.  Config should auto-run on power up. | OK |
| FPGA | Populate 24MHz Osc | Verify Osc with CRO | OK |
| FPGA | Polulate 56r resistor OSC-FPGA | Upload TEST_OSC_1.  Expect LEDs to display binary count with 0.5 sec LSB clock on LED1 | OK |
| Power | Populate analog LM1117-3.3 plus surrounding capacitors | measure AVDD == 3.3V | OK |
| DAC A | Populate AD9708 for channel A, including surrounding capacitors and resistors. | Create verilog code to output ramp. Measure signall at output resistors.  Check ramp lienartiy problems - e.g. stuck bits. | TODO |
| DAC A | Populate OP-AMP buffer | Verify output signall, centered at AVDD/2 | TODO |
| PLL | Test high frequency output to 100MSPS | Enable PLL for 100MHz internal clock and verify analog output. | TODO |

## File Structure

./FPGA contains all FPGA related test code.

./FPGA/verilog contains verilog code.  The idea is to keep verilog hdl separate from tool-chain files.  This will allow different tool-chains to be used.  Also allows for simulation using various open source packages such as ikarus verilog.

./FPGA/quartus contains the Quartus project as well as any constraint files such as pin configuration files.

./ESP32 contains all MSU code.

## DAC Component Selection

<img src=https://github.com/htrinkle/FPGA/blob/main/images/DAC_Components.jpg>

## DAC Testing

### DAC Ramp, measured at load resistors.  Noise in output is probably due to poor earthing of scope probes.  Also note that this waveform was captured before installation of any output fultering capacitors.

<img src=https://github.com/htrinkle/FPGA/blob/main/images/DAC_Ramp_No_OpAmp.bmp>
