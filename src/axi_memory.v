`timescale 1ns/1ps

module axi_memory (
    input wire clk,

    input wire [31:0] AWADDR,
    input wire AWVALID,
    output wire AWREADY,

    input wire [31:0] WDATA,
    input wire WVALID,
    output wire WREADY,

    output reg BVALID,
    input wire BREADY
);

// Always ready
assign AWREADY = 1;
assign WREADY  = 1;

// memory
reg [7:0] memory [0:255];
reg [7:0] addr_reg;

// delay flag (IMPORTANT)
reg write_done;

initial begin
    BVALID = 0;
    write_done = 0;
end

always @(posedge clk) begin

    // ---------------- ADDRESS ----------------
    if (AWVALID) begin
        addr_reg <= AWADDR[7:0];
    end

    // ---------------- DATA ----------------
    if (WVALID) begin
        memory[addr_reg] <= WDATA[7:0];
        write_done <= 1;   // mark write complete
    end

    // ---------------- RESPONSE ----------------
    if (write_done) begin
        BVALID <= 1;
        write_done <= 0;
    end

    else if (BVALID && BREADY) begin
        BVALID <= 0;
    end
end

endmodule