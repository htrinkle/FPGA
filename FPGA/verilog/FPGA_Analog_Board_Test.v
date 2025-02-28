`define TEST_PB_LED

module FPGA_Analog_Board_Test ( 
    input wire button,
    output wire[2:0] led
);

`ifdef TEST_PB_LED
TEST_PB_LED inst_TEST_PB_LED(button, led);
`endif // TEST_PB_LED
  
endmodule