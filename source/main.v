// Top-level module integrating UART and HDMI display
module UART_HDMI_Gray(
    input  wire clk,
    input  wire UART_rxd,
    output wire hdmi_clk_p,
    output wire hdmi_clk_n,
    output wire [2:0] hdmi_tx_p,
    output wire [2:0] hdmi_tx_n
);

    reg [7:0] gray_value = 8'h00;

    wire [7:0] rx_data;
    wire rx_valid;

    uart_rx #(
        .CLK_FREQ(100_000_000),
        .BAUD_RATE(115200)
    ) uart_inst (
        .clk(clk),
        .rx(UART_rxd),
        .data(rx_data),
        .valid(rx_valid)
    );

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
