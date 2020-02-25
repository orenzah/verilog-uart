//////////////////////////////////////////////////
//////////////////////////////////////////////////
//////////////////////////////////////////////////
//////////////PARITY PHRASE DETECTOR//////////////
//////////////////////////////////////////////////
//////////////////////////////////////////////////
//////////////////////////////////////////////////
module parity_detector (
                        clock,
                        reset,                        
                        i_Data, 
                        i_Enable,
                        i_Parity,
                        o_Parity,
                        o_Valid                   
                        );

localparam Ascii_P          = 'h50;
localparam Ascii_a          = 'h61;
localparam Ascii_r          = 'h72;
localparam Ascii_i          = 'h69;
localparam Ascii_t          = 'h74;
localparam Ascii_y          = 'h79;
localparam Ascii_Space      = 'h20;


input clock;
input reset;
input [7:0] i_Data;
input i_Enable;
input i_Parity;


output o_Parity;
output o_Valid;

reg [3:0] r_State;
reg r_Parity;
reg r_Valid;
reg [1:0] r_isEnabled;
reg r_InputParity;

assign o_Valid = r_Valid;
assign o_Parity = r_Parity;


always @(posedge clock)
    begin
        if (reset)
            begin
                r_State     <= 'd0;        
                r_Valid     <= 'd0;  
                r_Parity    <= 'd0;      
                r_isEnabled <= 'd0;
            end        
        if (i_Enable == 'd1 && r_isEnabled == 'd0)
            begin
                r_isEnabled <= 'd1;                
            end
        else if (i_Enable == 'd0 && r_isEnabled == 'd2)
            begin
                r_isEnabled <= 'd0;
            end
        r_InputParity   <= i_Parity;
        if (r_InputParity != i_Parity)
            begin
                r_Valid     <= 'd0;  
            end
                
        if (r_isEnabled == 'd1)
            begin
                r_isEnabled <= 'd2;                
                case (r_State)
                    'd0:
                        begin                            
                            if (i_Data == Ascii_P)
                                begin
                                    
                                    r_State <= r_State + 'd1;
                                end
                            else
                                r_State <= 'd0;                    
                        end
                    'd1:
                        begin
                            if (i_Data == Ascii_a)
                                begin
                                    r_State <= r_State + 'd1;
                                end
                            else
                                r_State <= 'd0;                    
                        end
                    'd2:
                        begin
                            if (i_Data == Ascii_r)
                                begin
                                    r_State <= r_State + 'd1;
                                end
                            else
                                r_State <= 'd0;                    
                        end                  
                    'd3:
                        begin
                            if (i_Data == Ascii_i)
                                begin
                                    r_State <= r_State + 'd1;
                                end
                            else
                                r_State <= 'd0;                    
                        end
                    'd4:
                        begin
                            if (i_Data == Ascii_t)
                                begin
                                    r_State <= r_State + 'd1;
                                end
                            else
                                r_State <= 'd0;                    
                        end
                    'd5:
                        begin
                            if (i_Data == Ascii_y)
                                begin
                                    r_State <= r_State + 'd1;
                                end
                            else
                                r_State <= 'd0;                    
                        end            
                    'd6:
                        begin
                            if (i_Data == Ascii_Space)
                                begin
                                    r_State <= r_State + 'd1;
                                end
                            else
                                r_State <= 'd0;                    
                        end
                    'd7:
                        begin
                            if (i_Data == 'h30)
                                begin
                                    r_Valid     <= 'd1;
                                    r_Parity    <= 'd0;
                                end
                            else if (i_Data == 'h31)
                                begin
                                    r_Valid     <= 'd1;
                                    r_Parity    <= 'd1;
                                end                           
                            r_State <= 'd0;                            
                        end
                endcase
            end
    end
endmodule




//////////////////////////////////////////////////
//////////////////////////////////////////////////
//////////////////////////////////////////////////
////////////DATALENGTH PHRASE DETECTOR////////////
//////////////////////////////////////////////////
//////////////////////////////////////////////////
//////////////////////////////////////////////////
module datalength_detector (
                        clock,
                        reset,                        
                        i_Data, 
                        i_Enable,
                        o_Datalength,
                        o_Valid                   
                        );

localparam Ascii_D          = 'h44;
localparam Ascii_a          = 'h61;
localparam Ascii_t          = 'h74;
localparam Ascii_l          = 'h6c;
localparam Ascii_e          = 'h65;
localparam Ascii_n          = 'h6e;
localparam Ascii_g          = 'h67;
localparam Ascii_h          = 'h68;
localparam Ascii_Space      = 'h20;


input clock;
input reset;
input [7:0] i_Data;
input i_Enable;

output o_Datalength;
output o_Valid;

reg [4:0] r_State;
reg r_Datalength;
reg r_Valid;
reg [1:0] r_isEnabled;

assign o_Valid = r_Valid;
assign o_Datalength = r_Datalength;

always @(posedge clock)
    begin
        if (reset)
            begin
                r_State     <= 'd0;        
                r_Valid     <= 'd0;  
                r_Datalength<= 'd0;      
                r_isEnabled <= 'd0;                
            end        
        if (i_Enable == 'd1 && r_isEnabled == 'd0)
            begin
                r_isEnabled <= 'd1;                
            end
        else if (i_Enable == 'd0 && r_isEnabled == 'd2)
            begin
                r_isEnabled <= 'd0;
            end
        
        
                
        if (r_isEnabled == 'd1)
            begin
                r_isEnabled <= 'd2;                
                case (r_State)
                    'd0:
                        begin                            
                            if (i_Data == Ascii_D)
                                begin
                                    
                                    r_State <= r_State + 'd1;
                                end
                            else
                                r_State <= 'd0;                    
                        end
                    'd1:
                        begin
                            if (i_Data == Ascii_a)
                                begin
                                    r_State <= r_State + 'd1;
                                end
                            else
                                r_State <= 'd0;                    
                        end
                    'd2:
                        begin
                            if (i_Data == Ascii_t)
                                begin
                                    r_State <= r_State + 'd1;
                                end
                            else
                                r_State <= 'd0;                    
                        end                  
                    'd3:
                        begin
                            if (i_Data == Ascii_a)
                                begin
                                    r_State <= r_State + 'd1;
                                end
                            else
                                r_State <= 'd0;                    
                        end
                    'd4:
                        begin
                            if (i_Data == Ascii_l)
                                begin
                                    r_State <= r_State + 'd1;
                                end
                            else
                                r_State <= 'd0;                    
                        end
                    'd5:
                        begin
                            if (i_Data == Ascii_e)
                                begin
                                    r_State <= r_State + 'd1;
                                end
                            else
                                r_State <= 'd0;                    
                        end            
                    'd6:
                        begin
                            if (i_Data == Ascii_n)
                                begin
                                    r_State <= r_State + 'd1;
                                end
                            else
                                r_State <= 'd0;                    
                        end
                    'd7:
                        begin
                            if (i_Data == Ascii_g)
                                begin
                                    r_State <= r_State + 'd1;
                                end
                            else
                                r_State <= 'd0;                    
                        end
                    'd8:
                        begin
                            if (i_Data == Ascii_t)
                                begin
                                    r_State <= r_State + 'd1;
                                end
                            else
                                r_State <= 'd0;                    
                        end
                    'd9:
                        begin
                            if (i_Data == Ascii_h)
                                begin
                                    r_State <= r_State + 'd1;
                                end
                            else
                                r_State <= 'd0;                    
                        end                                                                                                
                    'd10:
                        begin
                            if (i_Data == Ascii_Space)
                                begin
                                    r_State <= r_State + 'd1;
                                end
                            else
                                r_State <= 'd0;                    
                        end
                    'd11:
                        begin
                            if (i_Data == 'h37)
                                begin                                    
                                    r_Datalength    <= 'd0;
                                    r_Valid     <= 'd1;
                                    //r_State         <= 'd12;                            
                                    //r_Wait  <=  1'b1;
                                end
                            else if (i_Data == 'h38)
                                begin                                    
                                    r_Datalength    <= 'd1;
                                    r_Valid     <= 'd1;
                                    //r_State         <= 'd12;                            
                                    //r_Wait  <=  1'b1;
                                end                          
                            r_State <= 'd0;                            
                        end
                endcase
            end
    end
endmodule

//////////////////////////////////////////////////
//////////////////////////////////////////////////
//////////////////////////////////////////////////
////////////BAUD RATE PHRASE DETECTOR/////////////
//////////////////////////////////////////////////
//////////////////////////////////////////////////
//////////////////////////////////////////////////
module baudrate_detector (
                        clock,
                        reset,                        
                        i_Data, 
                        i_Enable,
                        o_Baudrate,
                        o_Valid                   
                        );

localparam Ascii_B          = 'h42;
localparam Ascii_a          = 'h61;
localparam Ascii_u          = 'h75;
localparam Ascii_d          = 'h64;
localparam Ascii_r          = 'h72;
localparam Ascii_t          = 'h74;
localparam Ascii_e          = 'h65;
localparam Ascii_Space      = 'h20;


input clock;
input reset;
input [7:0] i_Data;
input i_Enable;

output o_Baudrate;
output o_Valid;

reg [4:0] r_State   = 'h0;
reg [1:0] r_Stage_State;
reg r_Baudrate;
reg r_Valid;
reg [1:0] r_isEnabled;

assign o_Valid = r_Valid;
assign o_Baudrate = r_Baudrate;

always @(posedge clock)
    begin
        if (reset)
            begin
                r_State         <= 'd0;
                r_Stage_State   <= 'd0;        
                r_Valid         <= 'd0;  
                r_Baudrate      <= 'd0;      
                r_isEnabled     <= 'd0;
            end        
        if (i_Enable == 'd1 && r_isEnabled == 'd0)
            begin
                r_isEnabled <= 'd1;                
            end
        else if (i_Enable == 'd0 && r_isEnabled == 'd2)
            begin
                r_isEnabled <= 'd0;
            end
        
        
                
        if (r_isEnabled == 'd1)
            begin
                r_isEnabled <= 'd2;
                case (r_Stage_State)
                    'd0:
                        begin
                            case (r_State)
                                'd0:
                                    begin                            
                                        if (i_Data == Ascii_B)
                                            begin
                                                
                                                r_State <= r_State + 'd1;
                                            end
                                        else
                                            r_State <= 'd0;                    
                                    end
                                'd1:
                                    begin
                                        if (i_Data == Ascii_a)
                                            begin
                                                r_State <= r_State + 'd1;
                                            end
                                        else
                                            r_State <= 'd0;                    
                                    end
                                'd2:
                                    begin
                                        if (i_Data == Ascii_u)
                                            begin
                                                r_State <= r_State + 'd1;
                                            end
                                        else
                                            r_State <= 'd0;                    
                                    end                  
                                'd3:
                                    begin
                                        if (i_Data == Ascii_d)
                                            begin
                                                r_State <= r_State + 'd1;
                                            end
                                        else
                                            r_State <= 'd0;                    
                                    end
                                'd4:
                                    begin
                                        if (i_Data == Ascii_r)
                                            begin
                                                r_State <= r_State + 'd1;
                                            end
                                        else
                                            r_State <= 'd0;                    
                                    end
                                'd5:
                                    begin
                                        if (i_Data == Ascii_a)
                                            begin
                                                r_State <= r_State + 'd1;
                                            end
                                        else
                                            r_State <= 'd0;                    
                                    end            
                                'd6:
                                    begin
                                        if (i_Data == Ascii_t)
                                            begin
                                                r_State <= r_State + 'd1;
                                            end
                                        else
                                            r_State <= 'd0;                    
                                    end
                                'd7:
                                    begin
                                        if (i_Data == Ascii_e)
                                            begin
                                                r_State <= r_State + 'd1;
                                            end
                                        else
                                            r_State <= 'd0;                    
                                    end                                                                                               
                                'd8:
                                    begin
                                        if (i_Data == Ascii_Space)
                                            begin
                                                r_State <= r_State + 'd1;
                                            end
                                        else
                                            r_State <= 'd0;                    
                                    end
                                'd9:
                                    begin
                                        if (i_Data == 'h39)
                                            begin
                                                r_Stage_State <= 'd1;                                                
                                            end
                                        else if (i_Data == 'h31)
                                            begin
                                                r_Stage_State <= 'd2;
                                            end                           
                                        r_State <= 'd0;                            
                                    end
                            endcase
                        end
                    'd1: //9600
                        begin
                            case (r_State)
                                'd0:
                                    begin
                                       if (i_Data == 'h36)
                                            begin
                                                r_State <= r_State + 'd1;
                                            end
                                        else
                                            r_State <= 'd0;   
                                    end
                                'd1:
                                    begin
                                       if (i_Data == 'h30)
                                            begin
                                                r_State <= r_State + 'd1;
                                            end
                                        else
                                            r_State <= 'd0;   
                                    end                                    
                                'd2:
                                    begin
                                       if (i_Data == 'h30)
                                            begin
                                                r_Valid         <= 'd1;                                                
                                                r_Baudrate      <= 'd0;
                                                r_Stage_State   <= 'd0;
                                            end                        
                                        r_State <= 'd0;   
                                    end
                            endcase
                        end
                    'd2: //115200
                        begin
                            case (r_State)
                                'd0:
                                    begin
                                       if (i_Data == 'h31)
                                            begin
                                                r_State <= r_State + 'd1;
                                            end
                                        else
                                            r_State <= 'd0;   
                                    end
                                'd1:
                                    begin
                                       if (i_Data == 'h35)
                                            begin
                                                r_State <= r_State + 'd1;
                                            end
                                        else
                                            r_State <= 'd0;   
                                    end                                    
                                'd2:
                                    begin
                                       if (i_Data == 'h32)
                                            begin
                                                r_State <= r_State + 'd1;
                                            end
                                        else
                                            r_State <= 'd0;   
                                    end
                                'd3:
                                    begin
                                       if (i_Data == 'h30)
                                            begin
                                                r_State <= r_State + 'd1;
                                                
                                            end
                                        else
                                            r_State <= 'd0;    
                                    end
                                'd4:
                                    begin

                                       if (i_Data == 'h30)
                                            begin
                                                r_Valid         <= 'd1;                                                
                                                r_Baudrate      <= 'd1;
                                                r_Stage_State   <= 'd0;                                                
                                            end                        
                                        r_State <= 'd0;   
                                    end                                                                        
                            endcase                        
                        end
                endcase
            end
    end
endmodule
