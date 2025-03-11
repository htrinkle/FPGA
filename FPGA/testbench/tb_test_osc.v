
`include "../verilog/test_code/test_osc.v"

module tb_test_osc();

reg button_press;
reg clk = 0;
wire [2:0] led_display;

test_osc #(.OscF(5)) dut(.clk(clk), .button(~button_press), .led(led_display));

initial begin
    $display("Starting");
    button_press = 1'b0;
    # 100
    button_press = 1'b1;
    # 100
    button_press = 1'b0;
    # 100000
    $finish;
    $display("Finished");
end

// Setup Dump File
initial begin
    $dumpfile("tb_test_osc.vcd");
    $dumpvars(2, tb_test_osc);
end

// Clock
initial forever begin
  #5 clk <= ~clk;
end

endmodule