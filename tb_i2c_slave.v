`timescale 1ns/1ps

module tb_i2c_slave;

reg clk;
reg rst;
reg scl;
reg sda_drv;

tri1 sda;

// DUT
top_i2c_axi uut (
    .clk(clk),
    .rst(rst),
    .scl(scl),
    .sda(sda)
);

// Clock generation
always #5 clk = ~clk;

// SDA control
assign sda = (sda_drv == 0) ? 1'b0 : 1'bz;

//////////////////////////////////////////////////
// I2C TASKS
//////////////////////////////////////////////////

// START
task i2c_start;
begin
    sda_drv = 1;
    scl = 1;
    #20;

    sda_drv = 0;   // START
    #20;

    scl = 0;
    #20;
end
endtask

// STOP
task i2c_stop;
begin
    scl = 0;
    sda_drv = 0;
    #20;

    scl = 1;
    #20;

    sda_drv = 1;   // STOP
    #20;
end
endtask

// WRITE BYTE (stable version)
task i2c_write_byte(input [7:0] data);
integer i;
begin
    for (i = 7; i >= 0; i = i - 1) begin
        scl = 0;
        sda_drv = data[i];
        #20;

        scl = 1;   // rising edge
        #20;
    end

    // ACK cycle (IMPORTANT)
    scl = 0;
    sda_drv = 1;   // release SDA
    #20;

    scl = 1;       // slave pulls SDA low
    #20;

    scl = 0;
    #20;
end
endtask

//////////////////////////////////////////////////
// MAIN TEST
//////////////////////////////////////////////////

initial begin
    // Initialize
    clk = 0;
    rst = 1;
    scl = 1;
    sda_drv = 1;

    #50;
    rst = 0;

    // I2C WRITE TRANSACTION
    i2c_start();

    i2c_write_byte(8'h02);  // address
    #50;                    // IMPORTANT GAP

    i2c_write_byte(8'h55);  // data
    #50;

    i2c_stop();

    #300;

    $finish;
end

endmodule