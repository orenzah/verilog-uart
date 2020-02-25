module tx (
            clock,
            reset, 
            i_ParityEn, 
            i_Datalength,
            i_Baudrate, 
            i_Data, 
            i_WriteEnable, 
            o_DataOut, //the tx output
            o_Busy);

localparam BAUD_9600_BIT_PER=5208;// 9600 baud rate, 1bit.
localparam BAUD_115200_BIT_PER=434;// 115200b/s baud rate baud rate, 1bit.
//localparam BAUD_9600_BIT_PER=2605;// 9600 baud rate, 1bit.
//localparam BAUD_115200_BIT_PER=434;// 115200b/s baud rate baud rate, 1bit.



input clock, reset;
input i_ParityEn;
input i_Datalength;
input i_Baudrate;
input [7:0] i_Data ;
input i_WriteEnable ;

output o_DataOut; 
output o_Busy;


reg r_Busy;



wire [12:0] bit_period;

reg [12:0] bit_passed;
reg datao_r;
reg [3:0]cnt_bit;

reg [1:0]sw_case;

wire write_enable_w;
wire baud_rate_w;
wire parityout_w;
wire data_length_w;

assign bit_period = baud_rate_w ? BAUD_115200_BIT_PER : BAUD_9600_BIT_PER;
assign parity_w = i_ParityEn;
assign parityout_w = ^i_Data;
assign data_length_w = i_Datalength;
assign o_Busy = r_Busy;
assign o_DataOut = datao_r;
assign baud_rate_w = i_Baudrate;
assign write_enable_w = i_WriteEnable;
always @(posedge clock)
	begin
		bit_passed <= bit_passed+ 1;
		if(reset)
			begin
				r_Busy <= 'b0;
				datao_r <= 'b1;
				cnt_bit <= 'd0;
				bit_passed <= 'd0;
				sw_case <= 'd0;
				
			end
		else
			begin
				if (write_enable_w && !r_Busy)
					begin			
						bit_passed <= 'd0;						
						sw_case <= 'd0;	
						r_Busy <= 'b1;
						datao_r <= 'b0;
						sw_case <= 'd1;
						cnt_bit <= 'd0;
					end
				if (bit_passed == bit_period)
					begin
						bit_passed <= 'd0;						
						case (sw_case)
							0:	begin
								end
							1:	begin
									if (cnt_bit == (7+data_length_w))
										begin
											
											
											cnt_bit <= cnt_bit + 'b1;								
											if (parity_w)
												begin
													sw_case <= 'd2;
													datao_r <= parityout_w;
											
												end
											else
												begin
													sw_case <= 'd3;
													datao_r <= 'b1;
												end
														
										end
									else
										begin
											datao_r <= i_Data[cnt_bit];											
											cnt_bit <= cnt_bit + 'b1;											
										end
								end
							2:	begin
									datao_r <= 'b1;
									sw_case <= 'd3;
									cnt_bit <= cnt_bit + 'b1;
									
								end
							3:	begin
									sw_case <= 'd0;
									r_Busy <= 'b0;								
									cnt_bit <= 'd0;
									bit_passed <= 'd0;
								end

						endcase
					end
			end
	end
endmodule


