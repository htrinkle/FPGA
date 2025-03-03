module TEST_ADC_RAMP (
    input wire clk,
    input wire button,
    output wire [2:0] led,
    output wire [7:0] dac_a_d,
    output wire dac_a_c
);

reg [7:0] ramp = 8'd0, buf1, buf2;

assign dac_a_c = clk;
assign dac_a_d = buf2;
assign led = {ramp[7:6], button};

always @(posedge clk) 
    ramp <= ramp + 1'd1;

always @(negedge clk) begin
    buf1 <= ramp;
    buf2 <= buf1;
end

endmodule