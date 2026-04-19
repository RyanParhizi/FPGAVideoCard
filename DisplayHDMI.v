`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/14/2026 04:48:34 PM
// Design Name: 
// Module Name: DisplayHDMI
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


module DisplayHDMI(
    input wire clk,
    output wire hdmi_clk_p,
    output wire hdmi_clk_n,
    output wire [2:0] hdmi_tx_p,
    output wire [2:0] hdmi_tx_n
    );
    
    wire pixelClock;
    wire serialClock;
    wire locked;
    
    clk_wiz_0 clockWizard (
        .clk_in1(clk),
        .clk_out1(pixelClock),
        .clk_out2(serialClock),
        .reset(1'b0),
        .locked(locked)
    );
    
    parameter hDisplay = 640;
    parameter hFront = 16;
    parameter hSync = 96;
    parameter hBack = 48;
    parameter hTotal = 800;
    
    parameter vDisplay = 480;
    parameter vFront = 10;
    parameter vSync = 2;
    parameter vBack = 33;
    parameter vTotal = 525;
    
    reg [9:0] hCount = 0;
    reg [9:0] vCount = 0;
    wire Hsync, Vsync, video;
    
    always @(posedge pixelClock) begin
        if (hCount == hTotal - 1) begin
            hCount <= 0;
            if (vCount == vTotal - 1)
                vCount <= 0;
            else
                vCount <= vCount + 1;
        end else begin
            hCount <= hCount + 1;
        end
    end
    
    assign video = (hCount < hDisplay) && (vCount < vDisplay);
    assign Hsync = ~((hCount >= hDisplay + hFront) && (hCount < hDisplay + hFront + hSync));
    assign Vsync = ~((vCount >= vDisplay + vFront) && (vCount < vDisplay + vFront + vSync));
    
    wire [7:0] red;
    wire [7:0] green;
    wire [7:0] blue;
    
    assign red = video ? hCount[7:0] : 8'd0;
    assign green = video ? vCount[7:0] : 8'd0;
    assign blue = video ? 8'hFF : 8'd0;
    
    wire [23:0] rgbData = {red, green, blue};
   
endmodule
