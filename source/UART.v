//////////////////////////////////////////////////////////////////////////////////
// Course: Digital Logic
// Engineer(s): Ryan Parhizi (rypa7834)
//  
// Module Name: uart
// Project Name: FPGA Video Card
// Description: Creates a parameterized UART reciever that listens to a serial line and uses a state machine to 
//              deserialize the incoming 8 data bit, 0 parity, 1 stop bit frames into 8-bit parallel byte. Then a 
//              valid pulse is created to indicate that a byte had been successfully transferred.
//////////////////////////////////////////////////////////////////////////////////

module uart #(
    parameter CLK_FREQ  = 100_000_000,
    parameter BAUD_RATE = 115200
)(
    input  wire clk,
    input  wire rx,
    output reg [7:0] data = 8'd0,
    output reg valid = 1'b0
);

    // Calculate the number of clock cycles per UART bit, and half bit
    localparam integer CLKS_PER_BIT  = CLK_FREQ / BAUD_RATE;
    localparam integer HALF_BIT_CLKS = CLKS_PER_BIT / 2;

    // Flip-Flop synchronizer for metastability prevention
    reg rx_sync_0 = 1'b1;
    reg rx_sync_1 = 1'b1;

    always @(posedge clk) begin
        rx_sync_0 <= rx;
        rx_sync_1 <= rx_sync_0;
    end

    reg [1:0] state = 0; // Current state of the state machine
    reg [15:0] clk_count = 0; // Counts clock cycles to measure baud rate duration
    reg [2:0] bit_index = 0; // Tracks which of the 8 bits are currently being recieved
    reg [7:0] rx_shift = 0; // Shift register to assemble the incoming byte of data

    // State machine parameters
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
                // UART idles high, a drop to 0 indicates a START bit
                if (rx_sync_1 == 1'b0)
                    state <= START;
            end

            START: begin
                // Wait until the exact middle of the START bit
                if (clk_count == HALF_BIT_CLKS) begin
                    clk_count <= 0;
                    // Check if the line is still low. If so it was a valid START bit else it was an error
                    if (rx_sync_1 == 1'b0)
                        state <= DATA;
                    else
                        state <= IDLE;
                end else begin
                    clk_count <= clk_count + 1;
                end
            end

            DATA: begin
                // Wait one full bit of time or until the middle of a DATA bit
                if (clk_count == CLKS_PER_BIT - 1) begin
                    clk_count <= 0;
                    // Place the bit into a shift register
                    rx_shift[bit_index] <= rx_sync_1;

                    // Check to see if all 8-bits were received =
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
                // Wait for the entire duration of the stop bit
                if (clk_count == CLKS_PER_BIT - 1) begin
                    clk_count <= 0;
                    // Send the fully assembled byte of data to the output
                    data <= rx_shift;
                    // Pulse valid high so the rest of the system knows new data has arrived
                    valid <= 1'b1;
                    // Return to IDLE state whilst waiting for the next byte of data
                    state <= IDLE;
                end else begin
                    clk_count <= clk_count + 1;
                end
            end
        endcase
    end

endmodule