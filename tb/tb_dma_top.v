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

    // ---------------- AXI-Lite (CPU <-> DMA) ----------------
    wire [7:0]  s_axi_awaddr;
    wire        s_axi_awvalid;
    wire        s_axi_awready;

    wire [31:0] s_axi_wdata;
    wire        s_axi_wvalid;
    wire        s_axi_wready;

    wire [1:0]  s_axi_bresp;
    wire        s_axi_bvalid;
    wire        s_axi_bready;

    wire [7:0]  s_axi_araddr;
    wire        s_axi_arvalid;
    wire        s_axi_arready;

    wire [31:0] s_axi_rdata;
    wire [1:0]  s_axi_rresp;
    wire        s_axi_rvalid;
    wire        s_axi_rready;

    // ---------------- AXI4 Full (DMA <-> RAM) ----------------
    wire [31:0] m_axi_araddr;
    wire        m_axi_arvalid;
    wire        m_axi_arready;
    wire [7:0]  m_axi_arlen;
    wire [2:0]  m_axi_arsize;
    wire [1:0]  m_axi_arburst;

    wire [31:0] m_axi_rdata;
    wire        m_axi_rvalid;
    wire        m_axi_rready;
    wire        m_axi_rlast;
    wire [1:0]  m_axi_rresp;

    wire [31:0] m_axi_awaddr;
    wire        m_axi_awvalid;
    wire        m_axi_awready;
    wire [7:0]  m_axi_awlen;
    wire [2:0]  m_axi_awsize;
    wire [1:0]  m_axi_awburst;

    wire [31:0] m_axi_wdata;
    wire        m_axi_wvalid;
    wire        m_axi_wready;
    wire        m_axi_wlast;

    wire [1:0]  m_axi_bresp;
    wire        m_axi_bvalid;
    wire        m_axi_bready;

    assign s_axi_arvalid = 1'b0;
    assign s_axi_araddr  = 8'h00;
    assign s_axi_rready  = 1'b0;

    // =========================================================================
    // 2. MODULE INSTANTIATIONS
    // =========================================================================

    // ---------------------------------------------------------
    // 2.1 CPU BFM (AXI-Lite Master)
    // ---------------------------------------------------------
    axi_lite_master_bfm cpu (
        .clk(clk),

        .awaddr(s_axi_awaddr),
        .awvalid(s_axi_awvalid),
        .awready(s_axi_awready),

        .wdata(s_axi_wdata),
        .wvalid(s_axi_wvalid),
        .wready(s_axi_wready),

        .bresp(s_axi_bresp),
        .bvalid(s_axi_bvalid),
        .bready(s_axi_bready)
    );

    // ---------------------------------------------------------
    // 2.2 DUT : DMA Controller
    // ---------------------------------------------------------
    dma_top dut (
        .clk(clk),
        .rst_n(rst_n),

        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),

        .s_axi_wdata(s_axi_wdata),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),

        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),

        .s_axi_araddr(s_axi_araddr),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),

        .s_axi_rdata(s_axi_rdata),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready),

        .m_axi_araddr(m_axi_araddr),
        .m_axi_arvalid(m_axi_arvalid),
        .m_axi_arready(m_axi_arready),

        .m_axi_arlen(m_axi_arlen),
        .m_axi_arsize(m_axi_arsize),
        .m_axi_arburst(m_axi_arburst),

        .m_axi_rdata(m_axi_rdata),
        .m_axi_rvalid(m_axi_rvalid),
        .m_axi_rready(m_axi_rready),
        .m_axi_rlast(m_axi_rlast),
        .m_axi_rresp(m_axi_rresp),

        .m_axi_awaddr(m_axi_awaddr),
        .m_axi_awvalid(m_axi_awvalid),
        .m_axi_awready(m_axi_awready),

        .m_axi_awlen(m_axi_awlen),
        .m_axi_awsize(m_axi_awsize),
        .m_axi_awburst(m_axi_awburst),

        .m_axi_wdata(m_axi_wdata),
        .m_axi_wvalid(m_axi_wvalid),
        .m_axi_wready(m_axi_wready),
        .m_axi_wlast(m_axi_wlast),

        .m_axi_bresp(m_axi_bresp),
        .m_axi_bvalid(m_axi_bvalid),
        .m_axi_bready(m_axi_bready)
    );

    // ---------------------------------------------------------
    // 2.3 AXI RAM Model
    // ---------------------------------------------------------
    axi_ram_model #(
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32),
        .MEM_DEPTH(8192)     // 32KB RAM
    ) ram (
        .clk(clk),
        .rst_n(rst_n),

        .s_axi_awaddr(m_axi_awaddr),
        .s_axi_awvalid(m_axi_awvalid),
        .s_axi_awready(m_axi_awready),
        .s_axi_awlen(m_axi_awlen),

        .s_axi_wdata(m_axi_wdata),
        .s_axi_wvalid(m_axi_wvalid),
        .s_axi_wready(m_axi_wready),
        .s_axi_wlast(m_axi_wlast),

        .s_axi_bresp(m_axi_bresp),
        .s_axi_bvalid(m_axi_bvalid),
        .s_axi_bready(m_axi_bready),

        .s_axi_araddr(m_axi_araddr),
        .s_axi_arvalid(m_axi_arvalid),
        .s_axi_arready(m_axi_arready),
        .s_axi_arlen(m_axi_arlen),

        .s_axi_rdata(m_axi_rdata),
        .s_axi_rvalid(m_axi_rvalid),
        .s_axi_rready(m_axi_rready),
        .s_axi_rlast(m_axi_rlast),
        .s_axi_rresp(m_axi_rresp)
    );

    // =========================================================================
    // 3. CLOCK GENERATION (100 MHz)
    // =========================================================================
    always #5 clk = ~clk;

    // =========================================================================
    // 4. SCOREBOARD
    // =========================================================================
    integer error_count;

    task check_transfer;
        input [31:0] src_addr;
        input [31:0] dst_addr;
        input [31:0] bytes_len;

        integer i;
        integer local_errors;

        reg [31:0] expect_data;
        reg [31:0] actual_data;

        begin
            local_errors = 0;

            $display("  => Verifying: SRC(0x%h) -> DST(0x%h) | %0d bytes",
                     src_addr, dst_addr, bytes_len);

            for (i = 0; i < (bytes_len/4); i = i + 1) begin

                expect_data = ram.read_mem(src_addr + (i*4));
                actual_data = ram.read_mem(dst_addr + (i*4));

                if (expect_data !== actual_data) begin
                    $display("Mismatch @ +0x%0h | Expected: %h | Got: %h",
                             (i*4), expect_data, actual_data);

                    error_count = error_count + 1;
                    local_errors = local_errors + 1;
                end
            end

            if (local_errors == 0)
                $display("Transfer verified successfully (%0d words)",
                          (bytes_len/4));
            else
                $display("Found %0d corrupted words", local_errors);

        end
    endtask


    // =========================================================================
    // 5. MAIN TEST SEQUENCE
    // =========================================================================
    integer j;

    initial begin

        clk = 0;
        rst_n = 0;
        error_count = 0;

        #20
        rst_n = 1;

        $display("\n==============================================");
        $display("  START DMA CONTROLLER VERIFICATION");
        $display("==============================================\n");


        // -----------------------------------------------------
        // MEMORY INITIALIZATION
        // -----------------------------------------------------
        // [FIX QUAN TRỌNG 2]: Dọn dẹp sạch sẽ 8192 ô nhớ RAM về 0 trước (chống lỗi Unknown 'X')
        for (j = 0; j < 8192; j = j + 1) begin
            ram.write_mem(j * 4, 32'h0000_0000);
        end

        // Ghi dữ liệu Pattern để test DMA
        for (j = 0; j < 256; j = j + 1) begin
            ram.write_mem(32'h1000 + (j*4), 32'hA0A0_0000 + j);
            ram.write_mem(32'h2000 + (j*4), 32'hB0B0_0000 + j);
            ram.write_mem(32'h3000 + (j*4), 32'hC0C0_0000 + j);
            ram.write_mem(32'h4000 + (j*4), 32'hD0D0_0000 + j);
        end


        // -----------------------------------------------------
        // TEST 1 : SINGLE CHANNEL
        // -----------------------------------------------------
        $display("\nTEST 1 : Single Channel Transfer");

        cpu.write_reg(8'h00, 32'h00001000);
        cpu.write_reg(8'h04, 32'h00001500);
        cpu.write_reg(8'h08, 32'd128);
        cpu.write_reg(8'h0C, 32'h1);

        #5000;

        check_transfer(32'h1000, 32'h1500, 128);


        // -----------------------------------------------------
        // TEST 2 : HARDWARE INTERLOCK
        // -----------------------------------------------------
        $display("\nTEST 2 : Interlock Protection");

        cpu.write_reg(8'h10, 32'h00002000);
        cpu.write_reg(8'h14, 32'h00002500);
        cpu.write_reg(8'h18, 32'd256);
        cpu.write_reg(8'h1C, 32'h1);

        #80

        cpu.write_reg(8'h10, 32'hDEADBEEF); // illegal overwrite

        #5000;

        check_transfer(32'h2000, 32'h2500, 256);


        // -----------------------------------------------------
        // TEST 3 : 4 CHANNEL CONCURRENCY
        // -----------------------------------------------------
        $display("\nTEST 3 : Multi-Channel Stress");

        cpu.write_reg(8'h00, 32'h00001000);
        cpu.write_reg(8'h04, 32'h00001800);
        cpu.write_reg(8'h08, 32'd256);

        cpu.write_reg(8'h10, 32'h00002000);
        cpu.write_reg(8'h14, 32'h00002800);
        cpu.write_reg(8'h18, 32'd128);

        cpu.write_reg(8'h20, 32'h00003000);
        cpu.write_reg(8'h24, 32'h00003800);
        cpu.write_reg(8'h28, 32'd64);

        cpu.write_reg(8'h30, 32'h00004000);
        cpu.write_reg(8'h34, 32'h00004800);
        cpu.write_reg(8'h38, 32'd512);

        cpu.write_reg(8'h0C, 32'h1);
        cpu.write_reg(8'h1C, 32'h1);
        cpu.write_reg(8'h2C, 32'h1);
        cpu.write_reg(8'h3C, 32'h1);
        
        cpu.write_reg(8'h0C, 32'h3);
        cpu.write_reg(8'h1C, 32'h3);
        cpu.write_reg(8'h2C, 32'h3);
        cpu.write_reg(8'h3C, 32'h3);

        #50000;

        check_transfer(32'h1000, 32'h1800, 256);
        check_transfer(32'h2000, 32'h2800, 128);
        check_transfer(32'h3000, 32'h3800, 64);
        check_transfer(32'h4000, 32'h4800, 512);


        // -----------------------------------------------------
        // FINAL REPORT
        // -----------------------------------------------------
        $display("\n==============================================");

        if (error_count == 0)
            $display("PASSED : No data corruption detected.");
        else
            $display("FAILED : %0d mismatches detected.", error_count);

        $display("==============================================\n");

        $finish;

    end

endmodule