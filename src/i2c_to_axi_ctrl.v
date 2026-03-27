`timescale 1ns/1ps

module i2c_to_axi_ctrl (
    input wire clk,
    input wire rst,

    // I2C side
    input wire [7:0] i2c_data,
    input wire i2c_valid,

    // AXI WRITE ADDRESS CHANNEL
    output reg [31:0] AWADDR,
    output reg AWVALID,
    input wire AWREADY,

    // AXI WRITE DATA CHANNEL
    output reg [31:0] WDATA,
    output reg WVALID,
    input wire WREADY,

    // AXI RESPONSE CHANNEL
    input wire BVALID,
    output reg BREADY
);

// FSM states
reg [2:0] state;

localparam IDLE     = 0;
localparam GET_DATA = 1;
localparam AXI_AW   = 2;
localparam AXI_W    = 3;
localparam AXI_B    = 4;
localparam DONE     = 5;

// Internal registers
reg [7:0] reg_addr;
reg [7:0] reg_data;

// Edge detection (VERY IMPORTANT)
reg i2c_valid_prev;
wire i2c_valid_pulse;

assign i2c_valid_pulse = i2c_valid & ~i2c_valid_prev;

// FSM
always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        AWVALID <= 0;
        WVALID <= 0;
        BREADY <= 0;
        AWADDR <= 0;
        WDATA <= 0;
        reg_addr <= 0;
        reg_data <= 0;
        i2c_valid_prev <= 0;
    end else begin
        // update previous valid
        i2c_valid_prev <= i2c_valid;

        case (state)

        // ---------------- IDLE ----------------
        IDLE: begin
            AWVALID <= 0;
            WVALID  <= 0;
            BREADY  <= 0;

            if (i2c_valid_pulse) begin
                reg_addr <= i2c_data;
                state <= GET_DATA;
            end
        end

        // ---------------- GET DATA ----------------
        GET_DATA: begin
            if (i2c_valid_pulse) begin
                reg_data <= i2c_data;
                state <= AXI_AW;
            end
        end

        // ---------------- AXI ADDRESS ----------------
        AXI_AW: begin
            AWADDR  <= {24'd0, reg_addr};
            AWVALID <= 1;

            state <= AXI_W;   // move next cycle (IMPORTANT)
        end

        // ---------------- AXI DATA ----------------
        AXI_W: begin
            AWVALID <= 0;   // turn off previous signal

            WDATA  <= {24'd0, reg_data};
            WVALID <= 1;

            state <= AXI_B;
        end

        // ---------------- AXI RESPONSE ----------------
        AXI_B: begin
            WVALID <= 0;
            BREADY <= 1;

            state <= DONE;
        end

        // ---------------- DONE ----------------
        DONE: begin
            BREADY <= 0;
            state <= IDLE;
        end

        endcase
    end
end

endmodule