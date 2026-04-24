`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Course: Digital Logic
// Engineer(s): Aidan Penders (aipe5108)
//
// Module Name: DisplayHDMI
// Project Name: FPGA Video Card
// Description: Takes in the 8-bit UART pixel data and stores it into the BRAM acting as a framebuffer.
//              Whilst simultaneously generating clock timings and a 2x upscaled 640x480 image to fill the screen.
// IP Used: AMD/Vivado's Clocking Wizard and Digilent's rgb2dvi
//////////////////////////////////////////////////////////////////////////////////

module DisplayHDMI(
    input wire clk,
    input wire [7:0] rx_data,
    input wire rx_valid,
    output wire hdmi_clk_p,
    output wire hdmi_clk_n,
    output wire [2:0] hdmi_tx_p,
    output wire [2:0] hdmi_tx_n
    );
    
    wire pixelClock; // Clock used to determine the color of 1 pixel
    wire serialClock; // Clock used to send data over the HDMI cable to the monitor
    wire locked; // High when Clock Wizard is stablized
    
    // Clock Generation with Clock Wizard
    clk_wiz_0 clockWizard (
        .clk_in1(clk),
        .clk_out1(pixelClock),
        .clk_out2(serialClock),
        .locked(locked)
    );
    
    // Framebuffer for using Boolean Board BRAM
    reg [7:0] frameBuffer [0:76799];
    reg [16:0] writeAddress = 0;
    
    // Write incoming UART bytes into Boolean Board memory
    always @(posedge clk) begin
        if (rx_valid) begin
         frameBuffer[writeAddress] <= rx_data;
         
            if (writeAddress == 76799)
                writeAddress <= 0;
            else
                writeAddress <= writeAddress + 1;
        end
    end
    
    // HDMI Timing Parameters - 640x480 @ 60Hz Timing
    parameter hDisplay = 640; // Active Horizontal Pixels
    parameter hFront = 16; // Horizontal Front Porch - Ensures the signal is processed correctly
    parameter hSync = 96; // Horizontal Sync Pulse Width
    parameter hBack = 48; // Horizontal Back Porch - Gives the signal time to stabilize just before the next line
    parameter hTotal = 800; // Total Horizontal Clocks Per Line
    
    parameter vDisplay = 480; // Active Vertical Pixels
    parameter vFront = 10; // Vertical Front Porch - Ensures the signal is processed correctly
    parameter vSync = 2; // Vertical Sync Pulse Width
    parameter vBack = 33; // Vertical Back Porch - Gives the signal time to stabilize just before the next line
    parameter vTotal = 525; // Total Vertical Clocks Per Column
    
    reg [9:0] hCount = 0; // Defines the current horizontal position
    reg [9:0] vCount = 0; // Defines the current vertical position
    wire Hsync, Vsync, video;
    
    // Tracks the current pixel position on the screen
    always @(posedge pixelClock) begin
        if (hCount == hTotal - 1) begin
            hCount <= 0;
            if (vCount == vTotal - 1)
                vCount <= 0; // Reset to the top-left of the screen
            else
                vCount <= vCount + 1;
        end else begin
            hCount <= hCount + 1;
        end
    end
    
    // Defines the active video region (640x480)
    assign video = (hCount < hDisplay) && (vCount < vDisplay);
    
    // Horizontal and Vertical Sync Pulses - Indicates the end of a line/column and the creation of a new line/column
    assign Hsync = ~((hCount >= hDisplay + hFront) && (hCount < hDisplay + hFront + hSync));
    assign Vsync = ~((vCount >= vDisplay + vFront) && (vCount < vDisplay + vFront + vSync));
    
    // Upscale from 320x240 to 640x480 by shifting 1 rightward effectively halving the coordinates which doubles the pixel count
    wire [16:0] readAddress = (vCount[9:1] * 320) + hCount[9:1];
    reg [7:0] grayPixel;
    
    // Read pixel data from BRAM during active video sections
    always @(posedge pixelClock) begin
        if (video)
            grayPixel <= frameBuffer[readAddress];
        else
            grayPixel <= 8'h00;
    end

    // Pipeline video registers to sync with pixel data
    reg regVideo, regHsync, regVsync;
    always @(posedge pixelClock) begin
        regVideo <= video;
        regHsync <= Hsync;
        regVsync <= Vsync;
    end
    
    // Convert the 8-bit grayscale value to 24-bit RGB (R=G=B makes grey)
    wire [7:0] red = regVideo ? grayPixel : 8'd0;
    wire [7:0] green = regVideo ? grayPixel : 8'd0;
    wire [7:0] blue = regVideo ? grayPixel : 8'd0;
    wire [23:0] rgbData = {red, green, blue};
    
    // Digilent IP that encodes the image to be sent over HDMI
    rgb2dvi_0 rgb2dvi (
        // HDMI Outputs
        .TMDS_Clk_p(hdmi_clk_p),
        .TMDS_Clk_n(hdmi_clk_n),
        .TMDS_Data_p(hdmi_tx_p),
        .TMDS_Data_n(hdmi_tx_n),
        
        // Video Signals
        .vid_pData(rgbData),
        .vid_pVDE(regVideo),
        .vid_pHSync(regHsync),
        .vid_pVSync(regVsync),
        
        // Clocks and Resets
        .PixelClk(pixelClock),
        .SerialClk(serialClock),
        .aRst(1'b0)
    );
   
endmodule