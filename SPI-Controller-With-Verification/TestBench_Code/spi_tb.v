`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.02.2026 13:11:05
// Design Name: 
// Module Name: spi_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns/1ps

module spi_tb;
    reg clk, rst, start;
    reg [7:0] tx_data;
    wire [7:0] rx_data;
    wire done, sclk, mosi, miso, cs_n;

    // Instantiate Master
    spi_master u_master (
        .clk(clk), .rst(rst), .start(start), .tx_data(tx_data),
        .rx_data(rx_data), .done(done), .sclk(sclk), .mosi(mosi),
        .miso(miso), .cs_n(cs_n)
    );

    // Instantiate Slave (Sending 0xA5 back)
    spi_slave u_slave (
        .sclk(sclk), .cs_n(cs_n), .mosi(mosi), .miso(miso),
        .slave_tx(8'hA5), .slave_rx()
    );

    // Clock Generation
    always #5 clk = ~clk;

    initial begin
        // Initialize
        clk = 0; rst = 1; start = 0; tx_data = 0;
        #20 rst = 0;

        // Transaction 1: Send 0x55
        #20;
        tx_data = 8'h55;
        start = 1;
        #10 start = 0;

        // Wait for completion
        wait(done);
        $display("Time: %t | Master Sent: %h | Master Received: %h", $time, tx_data, rx_data);

        // Small delay before next test
        #50;
        
        // Transaction 2: Send 0xC3
        tx_data = 8'hC3;
        start = 1;
        #10 start = 0;

        wait(done);
        $display("Time: %t | Master Sent: %h | Master Received: %h", $time, tx_data, rx_data);

        #100 $finish;
    end
endmodule


