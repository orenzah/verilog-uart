module reset_buffer(clock, i_Reset, o_Reset, o_LED4);

input clock, i_Reset;
output reg o_Reset;
output o_LED4;
assign o_LED4 = o_Reset;
always @(posedge clock)
	begin					
			o_Reset <= i_Reset;				
	end
endmodule
