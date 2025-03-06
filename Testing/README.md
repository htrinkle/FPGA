# Building and Testing the FPGA Analog Board

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
| DAC A | Populate AD9708 for channel A, including surrounding capacitors and resistors. | Create verilog code to output ramp. Measure signall at output resistors.  Check ramp lienartiy problems - e.g. stuck bits. | OK |
| DAC A | Populate OP-AMP buffer | Verify output signal, centered at AVDD/2 | OK (inverted) |
| PLL | Test high frequency output to 100MSPS | Enable PLL for 100MHz internal clock and verify analog output. | TODO |
| DAC B | Populate DAC B and op-amp | Repeat as per DAC A. | TODO |
| MCU | Populate power LED and resistor (if desired) as this will be impossible after MCU headers installed. Populate any unpopulated resistors near MCU headers.  Populate MCU. Note that MCU USB port is facing into the PCB.  This was done to keep the WiFi antenna at the edge.  (Copper ground planes are also omitted under antenna.) | Test MCU with blink sketch.  Test ability to power board from MCU. | TODO | 

## File Structure

./FPGA contains all FPGA related test code.

./FPGA/verilog contains verilog code.  The idea is to keep verilog hdl separate from tool-chain files.  This will allow different tool-chains to be used.  Also allows for simulation using various open source packages such as ikarus verilog.

./FPGA/quartus contains the Quartus project as well as any constraint files such as pin configuration files.

./ESP32 contains all MSU code.

## DAC Component Selection

<img src=https://github.com/htrinkle/FPGA/blob/main/images/DAC_Components_1.jpg>

## DAC Testing

### DAC Ramp, measured at load resistors.  Noise in output is probably due to poor earthing of scope probes.  Also note that this waveform was captured before installation of any output fultering capacitors.

<img src=https://github.com/htrinkle/FPGA/blob/main/images/DAC_Ramp_No_OpAmp.bmp>

# For next time

Following is a list of hardwar errors or things that could be improved.

| Issue | Suggested Improvement | Comment |
|-|-|-|
| VCC Power led is sandwitched between two headers.  Need to solder before header installation | Omit LED and current limiting resistor. | LEDs on 3.3V rail and AVDD rail are sufficient. |
| R0402 x 4 resistor arrays are hard to hand-solder. | Extend solder pads so that it is easier to get heat from iron onto pad. | R0402 was selected to keep wiring short and lengths approximately matched.  Don't want to upgrade to R0603x4 footprint for that reason. |
| VUSB to VCC jumper is too close to PMOD header strip | Move slightly toward mounting hole | |
| DAC buffer op-amp layout includes separate feedback resistor and capacitor, but no capacitor included in non-inverting network. |  Could simply piggy-back capacitor and resistor.  Alternatively, add filter capacitor to non-inverting input. | Prefer to piggy-back as this keeps stray capacitances lowest. |
| Buffered ADC ref voltage ouput not that useful. | Ideally want V_offset from DAC buffers.  Then it would be possible to reference ADC inputs against DAC offset. |  Not an issue if using AC-coupling.  Also DAC offset is AVDD/2, so can generate in analog shield if needed. |

