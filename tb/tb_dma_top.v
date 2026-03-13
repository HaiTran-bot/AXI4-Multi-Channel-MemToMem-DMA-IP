`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2026 12:40:37 AM
// Design Name: 
// Module Name: tb_dma_top
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
module tb_dma_top();

    // =========================================================================
    // 1. SIGNAL DECLARATIONS
    // =========================================================================
    reg clk;
    reg rst_n;

    // AXI-Lite Connections (CPU <-> DMA)
    wire [7:0]  s_axi_awaddr; wire        s_axi_awvalid; wire        s_axi_awready;
    wire [31:0] s_axi_wdata;  wire        s_axi_wvalid;  wire        s_axi_wready;
    wire [1:0]  s_axi_bresp;  wire        s_axi_bvalid;  wire        s_axi_bready;
    wire [7:0]  s_axi_araddr; wire        s_axi_arvalid; wire        s_axi_arready;
    wire [31:0] s_axi_rdata;  wire [1:0]  s_axi_rresp;   
    wire        s_axi_rvalid; wire        s_axi_rready;

    // AXI4 Full Connections (DMA <-> RAM)
    wire [31:0] m_axi_araddr; wire        m_axi_arvalid; wire        m_axi_arready;
    wire [7:0]  m_axi_arlen;  wire [2:0]  m_axi_arsize;  wire [1:0]  m_axi_arburst;
    wire [31:0] m_axi_rdata;  wire        m_axi_rvalid;  wire        m_axi_rready;
    wire        m_axi_rlast;  wire [1:0]  m_axi_rresp;
    
    wire [31:0] m_axi_awaddr; wire        m_axi_awvalid; wire        m_axi_awready;
    wire [7:0]  m_axi_awlen;  wire [2:0]  m_axi_awsize;  wire [1:0]  m_axi_awburst;
    wire [31:0] m_axi_wdata;  wire        m_axi_wvalid;  wire        m_axi_wready;
    wire        m_axi_wlast;  
    wire [1:0]  m_axi_bresp;  wire        m_axi_bvalid;  wire        m_axi_bready;

    // =========================================================================
    // 2. MODULE INSTANTIATIONS
    // =========================================================================
    
    // 2.1 Simulated CPU (BFM)
    axi_lite_master_bfm cpu (
        .clk(clk),
        .awaddr(s_axi_awaddr), .awvalid(s_axi_awvalid), .awready(s_axi_awready),
        .wdata(s_axi_wdata),   .wvalid(s_axi_wvalid),   .wready(s_axi_wready),
        .bresp(s_axi_bresp),   .bvalid(s_axi_bvalid),   .bready(s_axi_bready)
    );
    // (Note: This BFM only connects the Write channel, as we configure the DMA mainly via Write commands)

    // 2.2 Design Under Test (DUT)
    dma_top dut (
        .clk(clk), .rst_n(rst_n),
        // Connect to CPU
        .s_axi_awaddr(s_axi_awaddr), .s_axi_awvalid(s_axi_awvalid), .s_axi_awready(s_axi_awready),
        .s_axi_wdata(s_axi_wdata),   .s_axi_wvalid(s_axi_wvalid),   .s_axi_wready(s_axi_wready),
        .s_axi_bresp(s_axi_bresp),   .s_axi_bvalid(s_axi_bvalid),   .s_axi_bready(s_axi_bready),
        .s_axi_araddr(s_axi_araddr), .s_axi_arvalid(s_axi_arvalid), .s_axi_arready(s_axi_arready),
        .s_axi_rdata(s_axi_rdata),   .s_axi_rresp(s_axi_rresp),     .s_axi_rvalid(s_axi_rvalid), .s_axi_rready(s_axi_rready),
        
        // Connect to RAM
        .m_axi_araddr(m_axi_araddr), .m_axi_arvalid(m_axi_arvalid), .m_axi_arready(m_axi_arready),
        .m_axi_arlen(m_axi_arlen),   .m_axi_arsize(m_axi_arsize),   .m_axi_arburst(m_axi_arburst),
        .m_axi_rdata(m_axi_rdata),   .m_axi_rvalid(m_axi_rvalid),   .m_axi_rready(m_axi_rready),
        .m_axi_rlast(m_axi_rlast),   .m_axi_rresp(m_axi_rresp),
        .m_axi_awaddr(m_axi_awaddr), .m_axi_awvalid(m_axi_awvalid), .m_axi_awready(m_axi_awready),
        .m_axi_awlen(m_axi_awlen),   .m_axi_awsize(m_axi_awsize),   .m_axi_awburst(m_axi_awburst),
        .m_axi_wdata(m_axi_wdata),   .m_axi_wvalid(m_axi_wvalid),   .m_axi_wready(m_axi_wready),
        .m_axi_wlast(m_axi_wlast),   .m_axi_bresp(m_axi_bresp),     .m_axi_bvalid(m_axi_bvalid), .m_axi_bready(m_axi_bready)
    );

    // 2.3 Simulated RAM (AXI4 Slave BFM)
    axi_ram_model ram (
        .clk(clk), .rst_n(rst_n),
        .s_axi_awaddr(m_axi_awaddr), .s_axi_awvalid(m_axi_awvalid), .s_axi_awready(m_axi_awready),
        .s_axi_awlen(m_axi_awlen),
        .s_axi_wdata(m_axi_wdata),   .s_axi_wvalid(m_axi_wvalid),   .s_axi_wready(m_axi_wready),
        .s_axi_wlast(m_axi_wlast),   
        .s_axi_bresp(m_axi_bresp),   .s_axi_bvalid(m_axi_bvalid),   .s_axi_bready(m_axi_bready),
        .s_axi_araddr(m_axi_araddr), .s_axi_arvalid(m_axi_arvalid), .s_axi_arready(m_axi_arready),
        .s_axi_arlen(m_axi_arlen),
        .s_axi_rdata(m_axi_rdata),   .s_axi_rvalid(m_axi_rvalid),   .s_axi_rready(m_axi_rready),
        .s_axi_rlast(m_axi_rlast),   .s_axi_rresp(m_axi_rresp)
    );

    // =========================================================================
    // 3. CLOCK GENERATION (100MHz)
    // =========================================================================
    always #5 clk = ~clk;

    // =========================================================================
    // 4. VERIFICATION TASKS (SCOREBOARD)
    // =========================================================================
    integer i;
    integer error_count;
    reg [31:0] check_data;
    
    task check_transfer;
        input [31:0] src_addr;
        input [31:0] dst_addr;
        input [31:0] bytes_len;
        integer i;
        reg [31:0] expect_data, actual_data;
        begin
            $display("  => Checking data from 0x%h to 0x%h (Size: %0d bytes)...", src_addr, dst_addr, bytes_len);
            for (i = 0; i < (bytes_len/4); i = i + 1) begin
                expect_data = ram.read_mem(src_addr + (i*4));
                actual_data = ram.read_mem(dst_addr + (i*4));
                if (expect_data !== actual_data) begin
                    $display("     [ERROR] At offset %0d | Expected: %h | Actual: %h", (i*4), expect_data, actual_data);
                    error_count = error_count + 1;
                end
            end
        end
    endtask

    // =========================================================================
    // 5. MAIN TEST SCENARIOS
    // =========================================================================
    integer j;
    initial begin
        // --- INITIALIZATION ---
        clk = 0; rst_n = 0; error_count = 0;
        #20 rst_n = 1;
        
        $display("\n=======================================================");
        $display("   [START] UVM-LIKE VERIFICATION FOR MULTI-CHANNEL DMA");
        $display("=======================================================\n");

        // Prepare dummy data (Backdoor write) for 3 different source memory regions
        for (j = 0; j < 16; j = j + 1) begin
            ram.write_mem(32'h1000 + (j*4), 32'hAAAA_0000 + j); // Source Channel 0
            ram.write_mem(32'h3000 + (j*4), 32'hBBBB_0000 + j); // Source Channel 1
            ram.write_mem(32'h5000 + (j*4), 32'hCCCC_0000 + j); // Source Channel 2
        end

        // ---------------------------------------------------------------------
        // TESTCASE 1: CONCURRENT EXECUTION OF CHANNEL 0 AND CHANNEL 1
        // ---------------------------------------------------------------------
        $display("[%0t] [TEST 1] Activating Channel 0 and Channel 1 simultaneously!", $time);
        
        // Configure Channel 0 (Offset 0x00)
        cpu.write_reg(8'h00, 32'h0000_1000); // SRC = 0x1000
        cpu.write_reg(8'h04, 32'h0000_2000); // DST = 0x2000
        cpu.write_reg(8'h08, 32'd64);        // LEN = 64 bytes
        
        // Configure Channel 1 (Offset 0x10)
        cpu.write_reg(8'h10, 32'h0000_3000); // SRC = 0x3000
        cpu.write_reg(8'h14, 32'h0000_4000); // DST = 0x4000
        cpu.write_reg(8'h18, 32'd64);        // LEN = 64 bytes

        // Trigger both channels almost simultaneously
        cpu.write_reg(8'h0C, 32'h0000_0001); // Channel 0 START
        cpu.write_reg(8'h1C, 32'h0000_0001); // Channel 1 START

        // Wait for the system to process both (estimated time)
        #2000; 

        $display("[%0t] Checking TEST 1 results:", $time);
        check_transfer(32'h1000, 32'h2000, 64); // Score channel 0
        check_transfer(32'h3000, 32'h4000, 64); // Score channel 1


        // ---------------------------------------------------------------------
        // TESTCASE 2: HARDWARE INTERLOCK CHECK ON CHANNEL 2
        // ---------------------------------------------------------------------
        $display("\n[%0t] [TEST 2] Trigger Channel 2 and intentionally overwrite address!", $time);
        
        cpu.write_reg(8'h20, 32'h0000_5000); // SRC = 0x5000
        cpu.write_reg(8'h24, 32'h0000_6000); // DST = 0x6000
        cpu.write_reg(8'h28, 32'd64);        // LEN = 64 bytes
        
        cpu.write_reg(8'h2C, 32'h0000_0001); // Channel 2 START
        
        // Wait a bit for Channel 2 to report BUSY
        #50; 
        $display("[%0t] Intentionally using CPU to corrupt Channel 2 Source address to 0x9999...", $time);
        cpu.write_reg(8'h20, 32'h0000_9999); // This command must be rejected by Reg_Bank!

        // Wait for Channel 2 to finish
        #1000;
        
        $display("[%0t] Checking TEST 2 results:", $time);
        // If Hardware Lock works, it must still copy from 0x5000, not 0x9999
        check_transfer(32'h5000, 32'h6000, 64); 

        // ---------------------------------------------------------------------
        // FINAL REPORT
        // ---------------------------------------------------------------------
        $display("\n=======================================================");
        if (error_count == 0) begin
            $display("  [PASSED] EXCELLENT! DESIGN PASSED ALL CORNER CASES!");
        end else begin
            $display("  [FAILED] FAILED! DETECTED %0d ERRORS DURING TEST!", error_count);
        end
        $display("=======================================================\n");

        $finish;
    end
endmodule