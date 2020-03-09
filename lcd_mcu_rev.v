module lcd_rev (
                clock,
                reset,
                o_LCD,
                o_LCD_RS,
                o_LCD_RW,
                o_LCD_E,
                o_Display_Ready,
                i_Data_Valid,
                i_Data_Character
                );
localparam   INIT    = 'h0;
localparam   GETCOMMAND    = 'h1;
localparam   SHIFT    = 'h2;
localparam   WAIT    = 'h3;

input       clock, reset;
input       i_Data_Valid;
input [7:0] i_Data_Character;

output          o_LCD_RS, o_LCD_RW, o_LCD_E;
output  [7:0]   o_LCD;
output          o_Display_Ready;

reg [17:0]  r_Counter = 1'b0;
reg [7:0]   r_LCD_State = 'h0;
reg [1:0]   r_Stage  =   1'b0;
reg         r_Display_Ready =   1'b0;
reg [6:0]   r_Shift_Counter =   'd0;
reg         r_LCD_RS, r_LCD_RW, r_LCD_E;


assign      o_Display_Ready = r_Display_Ready;
assign o_LCD    =   r_LCD_State;
assign o_LCD_RS =   r_LCD_RS;
assign o_LCD_E  =   r_LCD_E;
assign o_LCD_RW =   r_LCD_RW;

always  @(posedge clock)
    begin
        if (reset)
            begin
                r_Shift_Counter <=  'h0;
                r_Stage         <=  INIT;
                r_Display_Ready <=  1'b0;
                r_LCD_State     <=  8'h0;
                r_LCD_E     <=  1'b0;
                r_LCD_RS    <=  1'b0;                                              
                r_LCD_RW    <=  1'b0;
                r_Counter   <=  'b0;                  
            end
        else
            begin                
                r_Counter   <=  r_Counter + 1'b1;        
                case (r_Stage)
                    INIT:
                        begin
                                r_LCD_E     <=  1'b1;
                                r_LCD_RS    <=  1'b0;                                              
                                r_LCD_RW    <=  1'b0;      
                            case (r_Counter[17:7])
                                11'h01C:        //Function Set
                                    begin
                                        r_LCD_State <=  8'h37;
                                    end
                                11'h038:        //Function Set
                                    begin
                                        r_LCD_State <=  8'h37;
                                    end         
                                11'h054:        //Display On/Off
                                    begin
                                        r_LCD_State <=  8'h0F;
                                    end
                                11'h070:        //Display Clear
                                    begin
                                        r_LCD_State <=  8'h01;
                                    end
                                11'h498:        //Entry Mode Set
                                    begin
                                        r_LCD_State     <=  8'h06;                                            
                                    end
                                11'h4B4:
                                    begin
                                        r_LCD_State     <=  8'h0;
                                        r_Stage         <=  GETCOMMAND;                                        
                                        r_Counter       <=  17'h0;      
                                        r_Display_Ready <=  1'b1;
                                    end
                                default:
                                    begin
                                        r_LCD_E <= 1'b0;
                                    end                                        
                            endcase              
                        end
                    GETCOMMAND:
                        begin                            
                            if (i_Data_Valid)
                                begin
                                    r_Display_Ready <=  1'b0;
                                    r_LCD_RW            <= 0;                                    
                                    r_LCD_RS            <= 1;
                                    if (i_Data_Character == 8'hA || i_Data_Character == 8'hD || r_Shift_Counter == 'h49)
                                        begin
                                            // Got Return Carriage
                                            //Clear Display
                                            r_Stage  <= INIT;
                                            r_Counter[17:8]     <=  10'h038;   
                                            r_Shift_Counter     <=  'h0;
                                        end
                                    else if (r_Shift_Counter >= 'd15)
                                        begin
                                            r_Stage             <=  SHIFT;
                                            r_LCD_State         <=  8'h18;
                                            r_LCD_E             <=  1'b1;
                                            r_Counter[6:2]      <=  'h000;
                                            r_LCD_RS            <=  1'b0;
                                        end
                                    else
                                        begin
                                            // Data to put on screen
                                            r_Stage     <=  WAIT;
                                            case (i_Data_Character)
                                                8'h70:
                                                    begin
                                                        r_LCD_State <=  8'hF0;
                                                    end
                                                8'h71:
                                                    begin
                                                        r_LCD_State <=  8'hF1;
                                                    end
                                                8'h79:
                                                    begin
                                                        r_LCD_State <=  8'hF9;
                                                    end
                                                8'h67:
                                                    begin
                                                        r_LCD_State <=  8'hE7;
                                                    end
                                                8'h70:
                                                    begin
                                                    end
                                                default:
                                                    begin
                                                        r_LCD_State <=  i_Data_Character;
                                                    end
                                            endcase
                                            r_Shift_Counter <=  r_Shift_Counter + 'b1;
                                            r_Counter[7:2]     <=  'h000;
                                            r_LCD_E <= 1'b1;
                                        end
                                end
                            else
                                begin
                                    r_LCD_E <= 1'b0;
                                    r_LCD_State <=  8'h0;
                                end
                        end
                    SHIFT:
                        begin      
                            if (r_Counter[5:3] == 'h7)
                                begin
                                    r_LCD_E <= 1'b0;
                                end
                            if (r_Counter[17:8] == 10'h00E)
                                begin
                                    r_Stage             <=  WAIT;
                                    case (i_Data_Character)
                                        8'h70:
                                            begin
                                                r_LCD_State <=  8'hF0;
                                            end
                                        8'h71:
                                            begin
                                                r_LCD_State <=  8'hF1;
                                            end
                                        8'h79:
                                            begin
                                                r_LCD_State <=  8'hF9;
                                            end
                                        8'h67:
                                            begin
                                                r_LCD_State <=  8'hE7;
                                            end
                                        8'h70:
                                            begin
                                            end
                                        default:
                                            begin
                                                r_LCD_State <=  i_Data_Character;
                                            end
                                    endcase
                                    r_LCD_RW            <= 0;                                    
                                    r_LCD_RS            <= 1;
                                    r_Counter[17:8]     <=  10'h000;
                                    r_Shift_Counter     <= r_Shift_Counter + 'b1;
                                    r_LCD_E <= 1'b1;
                                end
                        end
                    WAIT:
                        begin                            
                            if (r_Counter[5:3] == 'h7)
                                begin
                                    r_LCD_E <= 1'b0;
                                end
                            if (r_Counter[17:8] == 10'h00E)
                                begin
                                    r_LCD_State         <=  8'h0;
                                    r_Counter[17:8]     <=  10'h000;
                                    r_Display_Ready     <=  1'b1;
                                    r_LCD_RW            <= 0;                                    
                                    r_LCD_RS            <= 0;
                                    r_Stage             <=  GETCOMMAND;
                                end                
                        end
                    default:
                            begin
                                r_LCD_E <= 1'b0;
                            end       
                endcase
            end
    end
endmodule



                


