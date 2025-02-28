module TEST_PB_LED ( 
    input wire button,
    output wire[2:0] led
);

assign led[0] = ~button;
assign led[1] = button;
assign led[2] = ~button;
  
endmodule