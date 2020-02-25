`timescale 10ns/10ns

`include "project_top.v"


module project_top_tb;

output o_Rx_UART;
output o_Tx_UART;
output o_LCD_RS;
output o_LCD_RW;
output [7:0] o_LCD_Data;
output o_LCD_E;

output o_LED;
output o_LED2;
output o_LED3;
output o_LED4;
output o_LED5;
output o_LED6;
output o_LED7;

reg r_Clock = 0;
wire w_Rx_UART;
reg r_SW_Reset = 0;
reg r_SW_Datalength = 0;
reg r_SW_Baudrate = 0;
reg r_SW_Parity = 1;

reg [7:0]   r_Tx_UART_Data = 0;
reg         r_Tx_UART_Enable = 0;
wire        w_Tx_UART_Busy;
integer i = 0;    

always begin
        #1 r_Clock = ~r_Clock;
    end

initial begin
        $dumpvars(0);
        $display("Start");
        r_SW_Reset  = 1;        
        #10;
        r_SW_Reset  = 0;
        #350000;

        r_Tx_UART_Enable <= 1'b0;
        for (i = 0; i < 20; i = i + 1)
            begin
                $display("Before %d", $time);
                #100000;
                $display("After  %d", $time);
                r_Tx_UART_Data  <=   'h50 + i;
                #1;
                r_Tx_UART_Enable <= 1'b1;
                #20;
                r_Tx_UART_Enable <= 1'b0;
                #20;
                $display("Transmitting: %h", r_Tx_UART_Data);
                while (w_Tx_UART_Busy)
                    begin
                        #1;                        
                    end                    
                
            end                
        #1000000;
        $display("Done!");
        $finish(0);
    end
tx Generator (
            .clock(r_Clock),
            .reset(r_SW_Reset), 
            .i_ParityEn(r_SW_Parity), 
            .i_Datalength(r_SW_Datalength),
            .i_Baudrate(r_SW_Baudrate), 
            .i_Data(r_Tx_UART_Data), 
            .i_WriteEnable(r_Tx_UART_Enable), 
            .o_DataOut(w_Rx_UART), //the tx output
            .o_Busy(w_Tx_UART_Busy));

project_top top(
                    .i_Clock(r_Clock),                    
                    
                    .i_Rx_UART(w_Rx_UART),
                    .o_Rx_UART(o_Rx_UART),
                    .o_Tx_UART(o_Tx_UART),
                    
                    .i_SW_Reset(r_SW_Reset),
                    .i_SW_Datalength(r_SW_Datalength),
                    .i_SW_Baudrate(r_SW_Baudrate),
                    .i_SW_Parity(r_SW_Parity),
                    
                    .o_LCD_RS(o_LCD_RS),
                    .o_LCD_RW(o_LCD_RW),
                    .o_LCD_Data(o_LCD_Data),
                    .o_LCD_E(o_LCD_E),
                    
                    .o_LED(o_LED),
                    .o_LED2(o_LED2),
                    .o_LED3(o_LED3),
                    .o_LED4(o_LED4),
                    .o_LED5(o_LED5),
                    .o_LED6(o_LED6),
                    .o_LED7(o_LED7)
                    );
endmodule
