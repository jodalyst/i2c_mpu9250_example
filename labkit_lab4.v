`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// 
// Create Date: 10/1/2015 V1.0
// Design Name: 
// Module Name: labkit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module labkit(
   input CLK100MHZ,
   input[15:0] SW, 
   input BTNC, BTNU, BTNL, BTNR, BTND,
   output[3:0] VGA_R, 
   output[3:0] VGA_B, 
   output[3:0] VGA_G,
   inout[7:0] JA, 
   output VGA_HS, 
   output VGA_VS, 
   output LED16_B, LED16_G, LED16_R,
   output LED17_B, LED17_G, LED17_R,
   output[15:0] LED,
   output[7:0] SEG,  // segments A-G (0-6), DP (7)
   output[7:0] AN    // Display 0-7
   );
   

// create 25mhz system clock
    wire clock_25mhz;
    clock_quarter_divider clockgen(.clk100_mhz(CLK100MHZ), .clock_25mhz(clock_25mhz));

//  instantiate 7-segment display;  
    wire [31:0] data;
    wire [6:0] segments;
    display_8hex display(.clk(clock_25mhz),.data(data), .seg(segments), .strobe(AN));    
    assign SEG[6:0] = segments;
    assign SEG[7] = 1'b1;

//////////////////////////////////////////////////////////////////////////////////
//
//  remove these lines and insert your lab here

//    assign LED = SW;     
//    assign JA[7:0] = 8'b0;
//    assign data = {28'h0123456, SW[3:0]};   // display 0123456 + SW
//    assign LED16_R = BTNL;                  // left button -> red led
//    assign LED16_G = BTNC;                  // center button -> green led
//    assign LED16_B = BTNR;                  // right button -> blue led
//    assign LED17_R = BTNL;
//    assign LED17_G = BTNC;
//    assign LED17_B = BTNR; 
    
    wire debounce_BTNC;
    wire debounce_BTNU;
    wire debounce_BTNL;
    wire debounce_BTNR;
    wire debounce_BTND;
    wire debounce_SW7;
     
    
    //assign data = {3'b000,SW[15],2'b00,SW[7],debounce_SW7, 8'h00, curr_state,time_left, 2'b00,SW[5:4], SW[3:0]};
    wire [4:0] state_display;
    wire [15:0] value;
    i2c_master my_master(.clock(clock_25mhz), .reset(SW[15]), .scl(JA[3]), .sda(JA[2]), .reading(value), .state_out(state_display), .sys_clock(JA[1]));
    assign data = {4'h0,SW[14:12], state_display[4:0],4'h0,value[15:0]};
//
//////////////////////////////////////////////////////////////////////////////////




 
//////////////////////////////////////////////////////////////////////////////////
// sample Verilog to generate color bars
    
    wire [9:0] hcount;
    wire [9:0] vcount;
    wire hsync, vsync, at_display_area;
    vga vga1(.vga_clock(clock_25mhz),.hcount(hcount),.vcount(vcount),
          .hsync(hsync),.vsync(vsync),.at_display_area(at_display_area));
        
    assign VGA_R = at_display_area ? {4{hcount[7]}} : 0;
    assign VGA_G = at_display_area ? {4{hcount[6]}} : 0;
    assign VGA_B = at_display_area ? {4{hcount[5]}} : 0;
    assign VGA_HS = ~hsync;
    assign VGA_VS = ~vsync;
endmodule

module clock_quarter_divider(input clk100_mhz, output reg clock_25mhz = 0);
    reg counter = 0;
    
    always @(posedge clk100_mhz) begin
        counter <= counter + 1;
        if (counter == 0) begin
            clock_25mhz <= ~clock_25mhz;
        end
    end
endmodule

module vga(input vga_clock,
            output reg [9:0] hcount = 0,    // pixel number on current line
            output reg [9:0] vcount = 0,	 // line number
            output vsync, hsync, at_display_area);
    // Counters.
    always @(posedge vga_clock) begin
        if (hcount == 799) begin
            hcount <= 0;
        end
        else begin
            hcount <= hcount +  1;
        end
        if (vcount == 524) begin
            vcount <= 0;
        end
        else if(hcount == 799) begin
            vcount <= vcount + 1;
        end
    end
    
    assign hsync = (hcount < 96);
    assign vsync = (vcount < 2);
    assign at_display_area = (hcount >= 144 && hcount < 784 && vcount >= 35 && vcount < 515);
endmodule

        
