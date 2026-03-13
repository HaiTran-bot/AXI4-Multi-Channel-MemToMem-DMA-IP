`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2026 12:29:20 AM
// Design Name: 
// Module Name: axi_ram_model
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
module axi_ram_model #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter MEM_DEPTH  = 1024 // Tương đương 4KB RAM (1024 * 4 bytes)
)(
    input  wire                   clk,
    input  wire                   rst_n,

    // --- Giao tiếp AXI4 Ghi (Write Channels) ---
    input  wire [ADDR_WIDTH-1:0]  s_axi_awaddr,
    input  wire [7:0]             s_axi_awlen,
    input  wire                   s_axi_awvalid,
    output reg                    s_axi_awready,
    
    input  wire [DATA_WIDTH-1:0]  s_axi_wdata,
    input  wire                   s_axi_wlast,
    input  wire                   s_axi_wvalid,
    output reg                    s_axi_wready,
    
    output reg  [1:0]             s_axi_bresp,
    output reg                    s_axi_bvalid,
    input  wire                   s_axi_bready,

    // --- Giao tiếp AXI4 Đọc (Read Channels) ---
    input  wire [ADDR_WIDTH-1:0]  s_axi_araddr,
    input  wire [7:0]             s_axi_arlen,
    input  wire                   s_axi_arvalid,
    output reg                    s_axi_arready,
    
    output reg  [DATA_WIDTH-1:0]  s_axi_rdata,
    output reg  [1:0]             s_axi_rresp,
    output reg                    s_axi_rlast,
    output reg                    s_axi_rvalid,
    input  wire                   s_axi_rready
);

    reg [DATA_WIDTH-1:0] ram_memory [0:MEM_DEPTH-1];
    
    reg [ADDR_WIDTH-1:0] wr_addr_reg;
    reg [ADDR_WIDTH-1:0] rd_addr_reg;
    reg [7:0]            rd_len_reg;

    reg [1:0] wr_state;
    localparam WR_IDLE = 2'd0, WR_DATA = 2'd1, WR_RESP = 2'd2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_state      <= WR_IDLE;
            s_axi_awready <= 1'b0;
            s_axi_wready  <= 1'b0;
            s_axi_bvalid  <= 1'b0;
            s_axi_bresp   <= 2'b00;
        end else begin
            case (wr_state)
                WR_IDLE: begin
                    s_axi_awready <= 1'b1;
                    s_axi_wready  <= 1'b0;
                    s_axi_bvalid  <= 1'b0;
                    if (s_axi_awvalid && s_axi_awready) begin
                        wr_addr_reg   <= s_axi_awaddr;
                        s_axi_awready <= 1'b0;
                        wr_state      <= WR_DATA;
                    end
                end
                
                WR_DATA: begin
                    s_axi_wready <= 1'b1;
                    if (s_axi_wvalid && s_axi_wready) begin
                  
                        ram_memory[wr_addr_reg[ADDR_WIDTH-1:2]] <= s_axi_wdata;
                        wr_addr_reg <= wr_addr_reg + 4; 
                        
                        if (s_axi_wlast) begin
                            s_axi_wready <= 1'b0;
                            wr_state     <= WR_RESP; 
                        end
                    end
                end
                
                WR_RESP: begin
                    s_axi_bvalid <= 1'b1;
                    if (s_axi_bvalid && s_axi_bready) begin
                        s_axi_bvalid <= 1'b0;
                        wr_state     <= WR_IDLE; 
                    end
                end
            endcase
        end
    end

    reg [1:0] rd_state;
    localparam RD_IDLE = 2'd0, RD_BURST = 2'd1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_state      <= RD_IDLE;
            s_axi_arready <= 1'b0;
            s_axi_rvalid  <= 1'b0;
            s_axi_rlast   <= 1'b0;
            s_axi_rresp   <= 2'b00;
        end else begin
            case (rd_state)
                RD_IDLE: begin
                    s_axi_arready <= 1'b1;
                    s_axi_rvalid  <= 1'b0;
                    s_axi_rlast   <= 1'b0;
                    if (s_axi_arvalid && s_axi_arready) begin
                        rd_addr_reg   <= s_axi_araddr;
                        rd_len_reg    <= s_axi_arlen;
                        s_axi_arready <= 1'b0;
                        rd_state      <= RD_BURST;
                    end
                end
                
                RD_BURST: begin
                    s_axi_rvalid <= 1'b1;

                    s_axi_rdata  <= ram_memory[rd_addr_reg[ADDR_WIDTH-1:2]];
                    
                    if (rd_len_reg == 0) s_axi_rlast <= 1'b1;
                    else                 s_axi_rlast <= 1'b0;
                    
                    if (s_axi_rvalid && s_axi_rready) begin 
                        rd_addr_reg <= rd_addr_reg + 4;
                        if (rd_len_reg == 0) begin 
                            s_axi_rvalid <= 1'b0;
                            s_axi_rlast  <= 1'b0;
                            rd_state     <= RD_IDLE; // Xong việc, quay về nghỉ
                        end else begin
                            rd_len_reg <= rd_len_reg - 1; // Giảm bộ đếm đi 1
                        end
                    end
                end
            endcase
        end
    end
    
    task write_mem;
        input [ADDR_WIDTH-1:0] addr;
        input [DATA_WIDTH-1:0] data;
        begin
            ram_memory[addr[ADDR_WIDTH-1:2]] = data;
        end
    endtask

    function [DATA_WIDTH-1:0] read_mem;
        input [ADDR_WIDTH-1:0] addr;
        begin
            read_mem = ram_memory[addr[ADDR_WIDTH-1:2]];
        end
    endfunction

endmodule
