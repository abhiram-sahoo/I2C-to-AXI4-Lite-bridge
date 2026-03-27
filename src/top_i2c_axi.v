module top_i2c_axi (
    input wire clk,
    input wire rst,
    input wire scl,
    inout wire sda
);

// I2C
wire [7:0] i2c_data;
wire i2c_valid;

// AXI signals
wire [31:0] AWADDR;
wire AWVALID;
wire AWREADY;

wire [31:0] WDATA;
wire WVALID;
wire WREADY;

wire BVALID;
wire BREADY;

// ---------------- I2C SLAVE ----------------
i2c_slave i2c_inst (
    .clk(clk),
    .rst(rst),
    .scl(scl),
    .sda(sda),
    .data_out(i2c_data),
    .data_valid(i2c_valid)
);

// ---------------- AXI CONTROLLER ----------------
i2c_to_axi_ctrl ctrl_inst (
    .clk(clk),
    .rst(rst),
    .i2c_data(i2c_data),
    .i2c_valid(i2c_valid),

    .AWADDR(AWADDR),
    .AWVALID(AWVALID),
    .AWREADY(AWREADY),

    .WDATA(WDATA),
    .WVALID(WVALID),
    .WREADY(WREADY),

    .BVALID(BVALID),
    .BREADY(BREADY)
);

// ---------------- MEMORY ----------------
axi_memory mem_inst (
    .clk(clk),

    .AWADDR(AWADDR),
    .AWVALID(AWVALID),
    .AWREADY(AWREADY),

    .WDATA(WDATA),
    .WVALID(WVALID),
    .WREADY(WREADY),

    .BVALID(BVALID),
    .BREADY(BREADY)
);
endmodule