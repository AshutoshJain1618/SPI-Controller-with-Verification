`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.02.2026 13:09:41
// Design Name: 
// Module Name: spi_slaves
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


module spi_slave (
    input  wire       sclk,
    input  wire       cs_n,
    input  wire       mosi,
    output reg        miso,
    input  wire [7:0] slave_tx, // Data slave wants to send
    output reg  [7:0] slave_rx  // Data slave received
);

    reg [7:0] shift_tx;
    reg [2:0] bit_cnt;

    // Shift out data on Falling Edge
    always @(negedge sclk or posedge cs_n) begin
        if (cs_n) begin
            shift_tx <= slave_tx;
            miso     <= slave_tx[7];
        end else begin
            // Shift left, update MISO with the next bit
            miso <= shift_tx[6];
            shift_tx <= {shift_tx[6:0], 1'b0};
        end
    end

    // Sample data on Rising Edge
    always @(posedge sclk) begin
        if (!cs_n) begin
            slave_rx <= {slave_rx[6:0], mosi};
        end
    end
endmodule

