module rx(
        clock,
       	reset,
       	i_RX_Serial,
       	o_DataOut,
       	i_ParityEn,
       	i_BaudrateMode,
       	i_Datalength,
        o_ParityError,        
       	o_FrameError, 
         o_DataReady
        );
        
        
        
    input clock, reset;
    input           i_ParityEn, i_Datalength,   i_BaudrateMode;
    input           i_RX_Serial;
    output          o_DataReady;
    output  [7:0]   o_DataOut;
    output o_ParityError;
    output o_FrameError;
        
    parameter CLKS_PER_BIT9600 = 5208;
    parameter CLKS_PER_BIT = 420;
    parameter IDLE         = 3'b000;
    parameter RX_START_BIT = 3'b001;
    parameter RX_DATA_BITS = 3'b010;
    parameter RX_STOP_BIT  = 3'b011;
    parameter RX_PARITY_BIT  = 3'b100;
    parameter CLEANUP      = 3'b110;

    reg [15:0]    r_Clock_Count = 0;
    reg [3:0]     r_Bit_Index   = 0; //11 bits total
    reg [8:0]     r_RX_Byte     = 0;
    reg [8:0]     r_RX_ByteOutput = 0;
    reg           r_RX_DV       = 0;
    reg [2:0]     r_SM_Main     = 0;
    reg [3:0]     r_BaudDivider = 0;    
    reg [3:0]     r_FrameError  = 0;
    wire w_LocalParity;
    
    assign o_DataReady   = r_RX_DV;
    assign o_DataOut = r_RX_ByteOutput[7:0];
    
    
    assign w_LocalParity  =   ^(r_RX_ByteOutput[7:0]);
    assign o_ParityError  =   (^{w_LocalParity, r_RX_ByteOutput[8]}) && i_ParityEn;
    assign o_FrameError   =    r_FrameError[3];
    // Purpose: Control RX state machine
    always @(posedge clock)
    begin
        if (reset)
            begin
                    r_Clock_Count <= 0;
                    r_Bit_Index   <= 0; //11 bits total
                    r_RX_Byte     <= 0;
                    r_RX_ByteOutput <= 0;
                    r_RX_DV       <= 0;
                    r_SM_Main     <= 0;
                    r_BaudDivider <= 0;    
                    r_FrameError  <= 0;
            end
        else
            begin
                case (r_SM_Main)
                    IDLE:
                        begin
                            r_RX_DV       <= 1'b0;
                            r_Clock_Count <= 0;
                            r_Bit_Index   <= 0;              
                            if (i_RX_Serial == 1'b0)          // Start bit detected
                                r_SM_Main <= RX_START_BIT;
                            else
                                r_SM_Main <= IDLE;
                        end
                  
                    // Check middle of start bit to make sure it's still low
                    RX_START_BIT:
                        begin
                            if (!i_BaudrateMode)
                                begin
                                    if (r_Clock_Count == (CLKS_PER_BIT9600)/2)
                                        begin
                                            if (i_RX_Serial == 1'b0)
                                                begin
                                                    r_Clock_Count <= 0;  // reset counter, found the middle
                                                    r_SM_Main     <= RX_DATA_BITS;
                                                end
                                            else
                                                r_SM_Main <= IDLE;
                                        end
                                    else
                                        begin
                                            r_Clock_Count <= r_Clock_Count + 1;
                                            r_SM_Main     <= RX_START_BIT;                            
                                        end                            
                                end
                            else
                                    begin
                                if (r_Clock_Count == (CLKS_PER_BIT-1)/2)
                                    begin
                                        if (i_RX_Serial == 1'b0)
                                            begin
                                                r_Clock_Count <= 0;  // reset counter, found the middle
                                                r_SM_Main     <= RX_DATA_BITS;
                                            end
                                        else
                                            r_SM_Main <= IDLE;
                                    end
                                else
                                    begin
                                        r_Clock_Count <= r_Clock_Count + 1;
                                        r_SM_Main     <= RX_START_BIT;                            
                                    end
                            end
                        end // case: RX_START_BIT
                      
                    // Wait CLKS_PER_BIT-1 clock cycles to sample serial data
                    RX_DATA_BITS :
                        begin
                            if (r_Clock_Count < CLKS_PER_BIT-1)
                                begin
                                    r_Clock_Count <= r_Clock_Count + 1;
                                    r_SM_Main     <= RX_DATA_BITS;
                                end
                            else
                                begin
                                    if (!i_BaudrateMode)
                                        begin
                                            r_BaudDivider   <=  r_BaudDivider   + 1'b1;
                                            r_Clock_Count   <=  'h0;
                                        end
                                    if ((!i_BaudrateMode && r_BaudDivider[3:2] == 2'h3) || i_BaudrateMode)
                                        begin
                                            r_Clock_Count          <= 0;
                                            r_RX_Byte[r_Bit_Index] <= i_RX_Serial;
                                            r_BaudDivider   <=  'h0;
                                            // Check if we have received all bits
                                            if (r_Bit_Index  < 6 + i_Datalength)
                                                begin
                                                    r_Bit_Index <= r_Bit_Index + 1;
                                                    r_SM_Main   <= RX_DATA_BITS;
                                                end
                                            else
                                                begin
                                                    if (i_ParityEn)
                                                        begin                          
                                                            if(r_Bit_Index[3])                        
                                                                r_SM_Main   <= RX_STOP_BIT;
                                                            r_Bit_Index <= 4'h8;
                                                        end
                                                    else
                                                        begin
                                                            r_Bit_Index <= 0;
                                                            r_SM_Main   <= RX_STOP_BIT;
                                                        end
                                                end
                                        end
                                end
                        end // case: RX_DATA_BITS
                    
                    // Receive Stop bit.  Stop bit = 1            
                    RX_STOP_BIT :
                        begin
                            // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
                            if (r_Clock_Count < (CLKS_PER_BIT-1)/2)
                                begin
                                    r_Clock_Count <= r_Clock_Count + 1;
                                    r_SM_Main     <= RX_STOP_BIT;
                                    if (i_RX_Serial)
                                        begin
                                            r_FrameError    <=  r_FrameError + 1'b1;
                                        end
                                end
                            else
                                begin
                                    r_RX_DV       <= 1'b1;                            
                                    r_Clock_Count <= 0;
                                    r_SM_Main     <= CLEANUP;
                                    r_RX_ByteOutput   <=  r_RX_Byte;
                                end
                        end // case: RX_STOP_BIT
                    
                    // Stay here 1 clock
                    CLEANUP :
                        begin
                            r_SM_Main <= IDLE;
                            r_RX_DV   <= 1'b0;
                            r_FrameError    <=  'h0;
                            r_RX_Byte   <=  'h0;
                        end
                        
                    default :
                        r_SM_Main <= IDLE;
                  
                endcase
            end
        end    


  
endmodule
