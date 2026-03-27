`timescale 1ns/1ps

module i2c_slave (
    input wire clk,
    input wire rst,
    input wire scl,
    inout wire sda,

    output reg [7:0] data_out,
    output reg data_valid
);

// Internal signals
reg [7:0] shift_reg;
reg [2:0] bit_count;
reg sda_prev;
reg scl_prev;
reg ack_en;

wire sda_in;
assign sda_in = sda;

// SDA control (ACK)
assign sda = (ack_en) ? 1'b0 : 1'bz;

// Edge detection
wire scl_rising = (scl_prev == 0 && scl == 1);

// START and STOP detection
wire start = (sda_prev == 1 && sda_in == 0 && scl == 1);
wire stop  = (sda_prev == 0 && sda_in == 1 && scl == 1);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        bit_count  <= 0;
        shift_reg  <= 0;
        data_out   <= 0;
        data_valid <= 0;
        ack_en     <= 0;
        sda_prev   <= 1;
        scl_prev   <= 0;
    end else begin
        // Store previous values
        sda_prev <= sda_in;
        scl_prev <= scl;

        // START condition
        if (start) begin
            bit_count  <= 0;
            data_valid <= 0;
        end

        // Sample on SCL rising edge
        if (scl_rising) begin
            shift_reg <= {shift_reg[6:0], sda_in};

            if (bit_count == 7) begin
                data_out   <= {shift_reg[6:0], sda_in};
                data_valid <= 1;
                ack_en     <= 1;
                bit_count  <= 0;
            end else begin
                bit_count <= bit_count + 1;
                ack_en    <= 0;
            end
        end

        // STOP condition
        if (stop) begin
            data_valid <= 0;
            ack_en     <= 0;
        end
    end
end

endmodule