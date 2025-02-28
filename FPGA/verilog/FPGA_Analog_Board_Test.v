#define TEST_PB_LED

`include "TEST_PB_LED.v"

module FPGA_Analog_Board_Test.v ( 
    input wire button;
    output wire[2..0] led;
);

#ifdef TEST_PB_LED
TEST_PB_LED inst_TEST_PB_LED(button, led);
#endif // TEST_PB_LED
  
endmodule