`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/12/2016 07:06:54 AM
// Design Name: 
// Module Name: clock_200khz
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

module clock_200khz   (input reset, input clock, output reg slow_clock);
    //assume incoming signal is 25 mhz, so we need to slow clock down by 12.5*100
    //every 250 posedges of clock we will toggle slow_clock state
    reg [7:0] count=0;
    always @(posedge clock)begin
        if (reset) begin
            count <=0;
            slow_clock <=1;
        end else begin
            if (count ==63)begin
                count <=0;
                slow_clock <= !slow_clock;
            end else begin
                count <= count +1;
            end
        end
    end
endmodule