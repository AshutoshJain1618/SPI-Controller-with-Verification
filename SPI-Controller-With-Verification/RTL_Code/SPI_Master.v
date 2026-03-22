`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.02.2026 13:05:36
// Design Name: 
// Module Name: SPI_Master
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


module spi_master (
    input  wire       clk,      // System Clock
    input  wire       rst,      // Active High Reset
    input  wire       start,    // Trigger pulse
    input  wire [7:0] tx_data,  // Data to send
    output reg  [7:0] rx_data,  // Data received
    output reg        done,     // High for 1 cycle when finished
    output reg        sclk,     // SPI Clock
    output reg        mosi,     // Master Out Slave In
    input  wire       miso,     // Master In Slave Out
    output reg        cs_n      // Chip Select (Active Low)
);

    reg [3:0] bit_cnt;
    reg [7:0] shift_reg;
    reg [1:0] state;

    localparam IDLE     = 2'b00;
    localparam TRANSFER = 2'b01;
    localparam FINISH   = 2'b10;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state    <= IDLE;
            sclk     <= 0;
            mosi     <= 0;
            cs_n     <= 1;
            done     <= 0;
            bit_cnt  <= 0;
            rx_data  <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    sclk <= 0;
                    if (start) begin
                        shift_reg <= tx_data;
                        mosi      <= tx_data[7]; // Pre-load MSB
                        cs_n      <= 0;
                        bit_cnt   <= 0;
                        state     <= TRANSFER;
                    end
                end

                TRANSFER: begin
                    sclk <= ~sclk;
                    if (sclk) begin // Falling Edge of SCLK
                        if (bit_cnt == 7) begin
                            state <= FINISH;
                        end else begin
                            bit_cnt   <= bit_cnt + 1;
                            shift_reg <= {shift_reg[6:0], 1'b0};
                            mosi      <= shift_reg[6]; // Shift out next bit
                        end
                    end else begin // Rising Edge of SCLK
                        rx_data <= {rx_data[6:0], miso}; // Sample MISO
                    end
                end

                FINISH: begin
                    sclk  <= 0;
                    cs_n  <= 1;
                    done  <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
