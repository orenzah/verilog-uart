module main_mcu_rev(
                    clock,
                    reset,
                    o_Rx_FIFO_ReadRequest,
                    i_Rx_FIFO_DataOut,
                    i_Rx_FIFO_Buffer_EMPTY,
                    i_Rx_FIFO_Buffer_FULL,
                    o_Tx_UART_WriteEnable,
                    o_Tx_UART_Data,
                    i_Tx_UART_Busy,
                    i_Rx_UART_DataReady,
                    o_LCD_Valid_Data,
                    i_LCD_Done_Display,
                    o_LED3               
                    );
input   clock;
input   reset;


///////////////////
// RX FIFO BLOCK //
///////////////////
output          o_Rx_FIFO_ReadRequest;
reg             r_Rx_FIFO_ReadRequest;
assign          o_Rx_FIFO_ReadRequest = r_Rx_FIFO_ReadRequest;
input   [7:0]   i_Rx_FIFO_DataOut;
reg     [7:0]   r_Rx_FIFO_Loaded_Data;
input   i_Rx_FIFO_Buffer_EMPTY;
input   i_Rx_FIFO_Buffer_FULL;
///////////////////
///////////////////
///////////////////

///////////////////
// TX UART BLOCK //
///////////////////
output          o_Tx_UART_WriteEnable;
output  [7:0]   o_Tx_UART_Data;
input           i_Tx_UART_Busy;
reg             r_Tx_UART_Busy;

reg     r_Tx_UART_WriteEnable;
assign  o_Tx_UART_WriteEnable = r_Tx_UART_WriteEnable;
///////////////////
///////////////////
///////////////////


///////////////////
// RX UART BLOCK //
///////////////////
input   i_Rx_UART_DataReady;
///////////////////
///////////////////
///////////////////

reg         r_Error_Detected;
reg [2:0]   r_State;

wire    w_Rx_Overrun_Detector;
// Combining these two inputs to one wire, detects an overrun error.
assign  w_Rx_Overrun_Detector = i_Rx_FIFO_Buffer_FULL &&
                                                    i_Rx_UART_DataReady;
                                                    
                                                    
parameter IDLE		        = 3'd0;
parameter READ_BYTE_WAIT_CLK= 3'd5;
parameter READ_BYTE         = 3'd1;
parameter WAIT_DEVICES_DONE = 3'd2;
parameter RX_STOP_BIT	    = 3'd3;
parameter CLEAN		        = 3'd4;



///////////////////
output  o_LCD_Valid_Data;
reg     r_LCD_Valid_Data;
assign  o_LCD_Valid_Data = r_LCD_Valid_Data;  
input   i_LCD_Done_Display;
reg     r_LCD_Done_Display;

///////////////////

reg r_DenyRead;
reg r_DataUpdated;
reg r_DevicesBusy;
reg r_UART_FlowControl;
reg r_Tx_FlowControl;
reg r_Tx_Flag_FlowControl = 0;
reg r_Disable_LCD_Data = 0;
reg r_FIFO_FULL_FlowControl_Flag = 0;
localparam  XOFF    =   8'h13;   
localparam  XON     =   8'h11;


//////FIFO///////
reg [2:0] r_Counter_WaitData;


assign o_Tx_UART_Data = r_Rx_FIFO_Loaded_Data;

output reg o_LED3;
 
always @(posedge clock)
    begin
        if (reset)
            begin
                r_UART_FlowControl      <=  1'b0;                
                r_LCD_Valid_Data        <=  1'b0;
                r_Tx_UART_WriteEnable   <=  1'b0;
                r_DenyRead              <=  1'b1;
                r_DevicesBusy           <=  1'b0;
                r_LCD_Done_Display      <=  1'b0;
            end
        else
            begin
                if (!r_DenyRead && r_DevicesBusy)
                    begin
                        r_DevicesBusy  <= 1'b0;
                    end
                if (! r_DenyRead && !r_DevicesBusy)
                    begin
                        r_DenyRead  <= 1'b1;
                    end                    
                else if (r_DataUpdated == 1'b1 && ! r_DevicesBusy)
                    begin                        
                        // There is data to transmit
                        if (r_Rx_FIFO_Loaded_Data == 'h13 && ! r_Tx_FlowControl)
                            begin
                                // Rcvd a XOFF, disable echoing
                                r_UART_FlowControl  <=  1'b1;
                            end
                        else if (r_Rx_FIFO_Loaded_Data == 'h11 && ! r_Tx_FlowControl)
                            begin
                                // Rcvd a XON, enable echoing
                                r_UART_FlowControl  <=  1'b0;                                
                            end
                        else 
                            begin                                
                                if (r_UART_FlowControl == 'b0)
                                    begin
                                        // Echo is enabled
                                        r_Tx_UART_WriteEnable   <= 1'b1;
                                    end
                                else
                                    r_Tx_UART_Busy  <=  1'b1;
                                if (r_Rx_FIFO_Loaded_Data != 'h11 && r_Rx_FIFO_Loaded_Data != 'h13)
                                    begin
                                        r_LCD_Valid_Data        <= 1'b1;
                                    end
                                else
                                    begin
                                        r_Disable_LCD_Data  <=  'h1;                                        
                                    end
                                r_DevicesBusy           <= 1'b1;                                
                            end                        
                    end
                else if (r_DevicesBusy && r_DenyRead)
                    begin
                        
                        if (i_Tx_UART_Busy)
                            begin
                                r_Tx_UART_WriteEnable   <=  1'b0;
                                r_Tx_UART_Busy <= i_Tx_UART_Busy;
                            end                         
                        if (!i_LCD_Done_Display)
                            begin
                                r_LCD_Done_Display  <= i_LCD_Done_Display;
                                r_LCD_Valid_Data    <= 1'b0;                                
                            end
                        if ((r_Tx_UART_Busy && ! i_Tx_UART_Busy) && ((i_LCD_Done_Display && !r_LCD_Done_Display) || r_Disable_LCD_Data))
                            begin
                                // Devices had been done   
                                r_Tx_UART_Busy      <=  1'b0;
                                r_Disable_LCD_Data  <=  1'b0;
                                r_Tx_UART_WriteEnable   <=  1'b0;
                                r_LCD_Valid_Data    <= 1'b0;
                                r_LCD_Done_Display  <=  1'b1;                             
                                r_DenyRead          <=  1'b0;
                            end
                        
                    end                
            end      
    end
    
always @(posedge clock)
    begin
        if (reset)
            begin
                r_Error_Detected    <= 1'b0;
                r_State             <= IDLE;                
                r_DataUpdated       <= 1'b0;  
                r_Counter_WaitData  <= 'h0;  
                o_LED3              <= 'h0;            
                
            end
        else 
            begin
                r_Error_Detected    <= w_Rx_Overrun_Detector;
                case (w_Rx_Overrun_Detector || r_Error_Detected)
                    /*'b1:    //Error had been detected
                        begin
                            // Do nothing, wait to reset to release it
                        end*/
                    default:    // Normal State
                        begin
                            case (r_State)
                                IDLE:
                                    begin
                                        if (i_Rx_FIFO_Buffer_FULL && !r_FIFO_FULL_FlowControl_Flag)
                                            begin
                                                r_Tx_FlowControl        <=  1'b1;
                                                r_Tx_Flag_FlowControl   <=  1'b1;                                                
                                                r_Rx_FIFO_Loaded_Data   <=  8'h13;
                                                o_LED3                  <=  1'h1;
                                                r_DataUpdated         <= 1'b1;  
                                                r_State <= WAIT_DEVICES_DONE;
                                                r_FIFO_FULL_FlowControl_Flag    <=  'h1;
                                            end
                                        else if (i_Rx_FIFO_Buffer_EMPTY && r_Tx_Flag_FlowControl)
                                            begin
                                                // Buffer have been emptied after had been fulled.
                                                r_Tx_FlowControl        <=  1'b1;
                                                r_Tx_Flag_FlowControl   <=  1'b0;
                                                r_Rx_FIFO_Loaded_Data   <=  8'h11;
                                                o_LED3                  <=  1'h0;
                                                r_FIFO_FULL_FlowControl_Flag    <=  'h0;
                                                r_DataUpdated         <= 1'b1;  
                                                r_State <= WAIT_DEVICES_DONE;
                                            end                                        
                                        else if (!i_Rx_FIFO_Buffer_EMPTY)
                                            begin                                            
                                                //There is byte to read                                                
                                                r_State <= READ_BYTE_WAIT_CLK;
                                                r_Rx_FIFO_ReadRequest <= 1'b1;
                                            end
                                        
                                    end
                                READ_BYTE_WAIT_CLK:
                                    begin
                                        r_State <= READ_BYTE;
                                        r_Rx_FIFO_ReadRequest <= 1'b0;
                                    end
                                READ_BYTE:
                                    begin
                                        r_Counter_WaitData <= r_Counter_WaitData + 1'b1;
                                        if (r_Counter_WaitData == 'h3)
                                            begin
                                                r_Counter_WaitData  <= 'h0;
                                                r_Rx_FIFO_Loaded_Data <= i_Rx_FIFO_DataOut;                                        
                                                r_DataUpdated         <= 1'b1;  
                                                r_State <= WAIT_DEVICES_DONE;                                                                                                        
                                            end
                                    end
                                WAIT_DEVICES_DONE:
                                    begin                                               
                                            if (r_Counter_WaitData == 'h7)
                                                begin                                                    
                                                    r_DataUpdated         <= 1'b0;  
                                                end                                            
                                            else
                                                r_Counter_WaitData <= r_Counter_WaitData + 1'b1;
                                            if (! r_DenyRead)
                                                begin
                                                    r_State <=  IDLE;
                                                    r_Counter_WaitData  <= 'h0;
                                                end
                                            
                                    end
                            endcase
                                    
                        end
                endcase
            end
    end
endmodule
