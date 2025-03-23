
`include "../verilog/test_code/test_led_button.v"

module tb_test_led_button();

reg button_press;
wire [2:0] led_display;

test_led_button dut(~button_press, led_display);

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
    $dumpfile("tb_test_led_button.vcd");
    $dumpvars(2, tb_test_led_button);
end

endmodule