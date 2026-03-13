`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2026 10:42:11 PM
// Design Name: 
// Module Name: dma_arbiter
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
`include "dma_defines.v"

module dma_arbiter (
    input  wire                     clk,
    input  wire                     rst_n,

    input  wire [`NUM_CHANNELS-1:0] ch_req,      //4 chanel

    input  wire                     engine_idle,

    output reg                      grant_valid, //channel chosen
    output reg  [1:0]               grant_ch_id, 
    output reg  [`NUM_CHANNELS-1:0] ch_engine_busy
);

    reg [1:0] last_granted;    
    reg [1:0] next_grant_id;   
    reg       next_grant_valid; //any channel valid

    always @(*) begin
        next_grant_valid = 1'b0;
        next_grant_id    = 2'b00;
        
        if (engine_idle && (ch_req != 4'b0000)) begin
            next_grant_valid = 1'b1;
            
            case (last_granted)
                2'd0: begin
                    if      (ch_req[1]) next_grant_id = 2'd1;
                    else if (ch_req[2]) next_grant_id = 2'd2;
                    else if (ch_req[3]) next_grant_id = 2'd3;
                    else                next_grant_id = 2'd0;
                end
                2'd1: begin 
                    if      (ch_req[2]) next_grant_id = 2'd2;
                    else if (ch_req[3]) next_grant_id = 2'd3;
                    else if (ch_req[0]) next_grant_id = 2'd0;
                    else                next_grant_id = 2'd1;
                end
                2'd2: begin
                    if      (ch_req[3]) next_grant_id = 2'd3;
                    else if (ch_req[0]) next_grant_id = 2'd0;
                    else if (ch_req[1]) next_grant_id = 2'd1;
                    else                next_grant_id = 2'd2;
                end
                2'd3: begin 
                    if      (ch_req[0]) next_grant_id = 2'd0;
                    else if (ch_req[1]) next_grant_id = 2'd1;
                    else if (ch_req[2]) next_grant_id = 2'd2;
                    else                next_grant_id = 2'd3;
                end
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            grant_valid  <= 1'b0;
            grant_ch_id  <= 2'b00;
            last_granted <= 2'b11; // so that when initiate it goes to 1
        end else begin
            //have result but not granted
            if (next_grant_valid && !grant_valid) begin
                grant_valid  <= 1'b1;
                grant_ch_id  <= next_grant_id;
                last_granted <= next_grant_id;
            end 
            else if (!engine_idle) begin
                grant_valid  <= 1'b0;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ch_engine_busy <= 4'b0000;
        end else begin
            if (next_grant_valid && !grant_valid) begin
                ch_engine_busy[next_grant_id] <= 1'b1;
            end
            if (ch_engine_busy[0] && !ch_req[0]) ch_engine_busy[0] <= 1'b0;
            if (ch_engine_busy[1] && !ch_req[1]) ch_engine_busy[1] <= 1'b0;
            if (ch_engine_busy[2] && !ch_req[2]) ch_engine_busy[2] <= 1'b0;
            if (ch_engine_busy[3] && !ch_req[3]) ch_engine_busy[3] <= 1'b0;
        end
    end

endmodule
