//////////////////////////////////////////////////////////////////////////////////
// Course: Digital Logic
// Engineer(s): Ryan Parhizi (rypa7834) and Aidan Penders (aipe5108)
//
// Module Name: main
// Project Name: FPGA Video Card
// Description: Top-level module for out FPGA Video Card project. Wires the UART receiver module to the HDMI display controller.
//////////////////////////////////////////////////////////////////////////////////

// Top-level module integrating UART and HDMI display
module UART_HDMI_Gray(
    input  wire clk,
    input  wire UART_rxd,
    output wire hdmi_clk_p,
    output wire hdmi_clk_n,
    output wire [2:0] hdmi_tx_p,
    output wire [2:0] hdmi_tx_n
);
    // Wires linking the UART receiver to the HDMI display controller
    wire [7:0] rx_data;
    wire rx_valid;

    // Deserializes the incoming serial stream into 8-bit parallel bytes
    uart #(
        .CLK_FREQ(100_000_000),
        .BAUD_RATE(115200)
    ) uart_inst (
        .clk(clk),
        .rx(UART_rxd),
        .data(rx_data),
        .valid(rx_valid)
    );

    // Receives the pixel bytes, stores them in BRAM, and generates the active HDMI signal
    DisplayHDMI hdmi_inst (
        .clk(clk),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .hdmi_clk_p(hdmi_clk_p),
        .hdmi_clk_n(hdmi_clk_n),
        .hdmi_tx_p(hdmi_tx_p),
        .hdmi_tx_n(hdmi_tx_n)
    );

endmodule
