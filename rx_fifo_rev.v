
module FIFObuffer(
                    clock,
                    reset,                
                    i_Data, 
                    o_Data, 
                    i_ReadRequest, 
                    i_WriteRequest,                                          
                    o_Empty, 
                    o_Full,
                    o_Overrun
                   ); 
                   
input   clock, reset;
input  [7:0]   i_Data;
output [7:0]   o_Data;
reg    [7:0]   r_DataOut;

input   i_ReadRequest, i_WriteRequest;

output  o_Empty, o_Full;
output reg o_Overrun;


reg [3:0]   r_ReadIndex;
reg [3:0]   r_WriteIndex;

reg [7:0]   r_FIFO  [0:8];

reg r_Do_Write;
reg r_Do_Read;
reg r_Circle;
assign o_Empty  =  (r_WriteIndex ==  r_ReadIndex);
assign o_Full   =  r_Circle;
 
assign o_Data = r_DataOut;

always  @(posedge clock)
    begin
        if ((r_Circle  && r_WriteIndex == r_ReadIndex))
            o_Overrun <= 1'b1;
        if (reset)
            begin
                r_ReadIndex  <= 0;
                r_WriteIndex <= 0;    
                r_Do_Write  <= 0;
                r_Do_Read   <= 0;   
                r_DataOut   <=  0;        
            end
        else
            begin
                if (r_Do_Read)
                    begin
                        r_DataOut <= r_FIFO[r_ReadIndex];
                        r_ReadIndex    <=  r_ReadIndex + 'h1;
                        r_Do_Read   <=  1'b0;
                        if (r_ReadIndex == 8'h7)
                            begin
                                r_ReadIndex <=  'h0;
                                r_Circle    <=  'h0;
                            end
                    end
                else if (r_Do_Write)
                    begin
                        r_FIFO[r_WriteIndex]    <=  i_Data;
                        r_WriteIndex    <=  r_WriteIndex + 'h1;
                        r_Do_Write      <=  1'b0;
                        if (r_WriteIndex == 8'h7)
                            begin
                                r_Circle    <=  'h1;  
                                r_WriteIndex    <=  'h0;
                            end
                    end
                else if (i_ReadRequest)
                    begin
                        r_Do_Read      <=  1'b1;
                    end
                else if (i_WriteRequest)
                    begin                      
                        r_Do_Write      <=  1'b1;
                    end
                
            end
    end
endmodule

                   
                   
