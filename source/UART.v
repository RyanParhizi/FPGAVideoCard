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

    always @(posedge clk) begin
        if (rx_valid)
            gray_value <= rx_data;
    end

    DisplayHDMI hdmi_inst (
        .clk(clk),
        .gray(gray_value),
        .hdmi_clk_p(hdmi_clk_p),
        .hdmi_clk_n(hdmi_clk_n),
        .hdmi_tx_p(hdmi_tx_p),
        .hdmi_tx_n(hdmi_tx_n)
    );

endmodule


module uart_rx #(
    parameter CLK_FREQ  = 100_000_000,
    parameter BAUD_RATE = 115200
)(
    input  wire clk,
    input  wire rx,
    output reg [7:0] data = 8'd0,
    output reg valid = 1'b0
);

    localparam integer CLKS_PER_BIT  = CLK_FREQ / BAUD_RATE;
    localparam integer HALF_BIT_CLKS = CLKS_PER_BIT / 2;

    reg rx_sync_0 = 1'b1;
    reg rx_sync_1 = 1'b1;

    always @(posedge clk) begin
        rx_sync_0 <= rx;
        rx_sync_1 <= rx_sync_0;
    end

    reg [1:0] state = 0;
    reg [15:0] clk_count = 0;
    reg [2:0] bit_index = 0;
    reg [7:0] rx_shift = 0;

    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATA  = 2'd2;
    localparam STOP  = 2'd3;

    always @(posedge clk) begin
        valid <= 1'b0;

        case (state)
            IDLE: begin
                clk_count <= 0;
                bit_index <= 0;
                if (rx_sync_1 == 1'b0)
                    state <= START;
            end

            START: begin
                if (clk_count == HALF_BIT_CLKS) begin
                    clk_count <= 0;
                    if (rx_sync_1 == 1'b0)
                        state <= DATA;
                    else
                        state <= IDLE;
                end else begin
                    clk_count <= clk_count + 1;
                end
            end

            DATA: begin
                if (clk_count == CLKS_PER_BIT - 1) begin
                    clk_count <= 0;
                    rx_shift[bit_index] <= rx_sync_1;

                    if (bit_index == 3'd7) begin
                        bit_index <= 0;
                        state <= STOP;
                    end else begin
                        bit_index <= bit_index + 1;
                    end
                end else begin
                    clk_count <= clk_count + 1;
                end
            end

            STOP: begin
                if (clk_count == CLKS_PER_BIT - 1) begin
                    clk_count <= 0;
                    data <= rx_shift;
                    valid <= 1'b1;
                    state <= IDLE;
                end else begin
                    clk_count <= clk_count + 1;
                end
            end
        endcase
    end

endmodule