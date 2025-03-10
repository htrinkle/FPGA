
`include "../verilog/TEST_PB_LED.v"

module tbBoardTest();

reg button_press;
wire [2:0] led_display;

TEST_PB_LED dut(button_press, led_display);

initial begin
    $display("Starting");
    button_press = 1'b0;
    # 100
    button_press = 1'b1;
    # 100
    button_press = 1'b0;
    # 100
    $finish;
    $display("Finished");
end

// Setup Dump File
initial begin
    $dumpfile("tbBoardTest.vcd");
    $dumpvars(2, tbBoardTest);
end

endmodule