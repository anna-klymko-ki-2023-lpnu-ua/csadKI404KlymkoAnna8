`timescale 1ns / 1ps

module tb_Lab3_APKS;

    reg        clk;
    reg        reset_n;
    reg        start;
    reg [6:0]  addr;
    reg        rw;
    reg [7:0]  data_in;
    wire [7:0] data_out;
    wire       scl;
    wire       sda;
    wire       busy;
    wire       ack_error;

    Lab3_APKS #(
        .input_clk_freq(50000000),
        .i2c_freq(100000)
    ) uut (
        .clk(clk),
        .reset_n(reset_n),
        .start(start),
        .addr(addr),
        .rw(rw),
        .data_in(data_in),
        .data_out(data_out),
        .scl(scl),
        .sda(sda),
        .busy(busy),
        .ack_error(ack_error)
    );

    always #10 clk = ~clk;

    initial begin
        clk = 0;
        reset_n = 0;
        start = 0;
        addr = 7'h50; 
        rw = 1'b0;    
        data_in = 8'hA5; 

        #100;
        reset_n = 1;
        
        #200;
        start = 1;
        
        #10000; 
        start = 0;

        #40000;
        
        $stop;
    end

endmodule