# Testing the FPGA Analog Board

## Approach

The board was built and tested in stages.  

| Stage | PCB Assembly | Tests | Status |
|-|-|-|-|
| Power | Populate LM1117-3.3 and LM1117-1.2 plus surrounding capacitors | Apply VCC (current limit to several milliamps), measure voltages | OK |
| FPGA | Polulate FPGA, FPGA decoupling caps, 10K + 1K pin strapping resistors, FPGA prog header | Connect to USB-Blaster, apply VCC and check if FPGA detected in JTAG scan from within Quartus | OK |
| FPGA | Populate push button, LED1,2,3 and associated resistors | Upload TEST_PB_LED.  Expect LED 1 and 3 to light if button pushed, LED 2 in inverse of LED 1 and 3 | TODO |
| FPGA | Populate PROM | Verify PROM programming via JTAG.  Config should auto-run on power up. | TODO |
| FPGA | Populate 24MHz Osc | Verify Osc with CRO | TODO |
| FPGA | Polulate 56r resistor OSC-FPGA | Upload TEST_OSC_1.  Expect LEDs to display binary count with 0.5 sec LSB clock on LED1 | TODO |

