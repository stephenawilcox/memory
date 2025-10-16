/*
Copyright (c) 2025 Stephen Wilcox. All rights reserved.
Not for use in commercial or non-commercial products or projects without explicit permission from author.
*/
`timescale 1ns/1ps
module memory_dp_tb();
    parameter integer num_mem_entries = 8;
    parameter integer data_bit_width = 32;
    parameter integer addr_bit_width = $clog2(num_mem_entries);

    reg clk;
    wire wr_clk, rd_clk;
    assign wr_clk = clk;
    assign rd_clk = clk;

    reg wr_en, rd_en;
    reg [addr_bit_width-1:0] wr_addr, rd_addr;
    reg [data_bit_width-1:0] wr_data;
    wire [data_bit_width-1:0] rd_data;

    integer i, j;

    reg [data_bit_width-1:0] data [256];

    memory_dp #(.num_mem_entries(num_mem_entries), .data_bit_width(data_bit_width)) mem_inst (
        .wr_clk(wr_clk),
        .wr_en(wr_en),
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        .rd_clk(rd_clk),
        .rd_en(rd_en),
        .rd_addr(rd_addr),
        .rd_data(rd_data)
    );


    initial begin
        $dumpfile("memory_dp.vcd");
        $dumpvars(0, memory_dp_tb);

        clk = 0;
        #20;
        wr_en = 0;
        wr_addr = 0;
        wr_data = 0;
        rd_en = 0;
        rd_addr = 0;
        
        //setting data
        for (i = 0; i < 256; i++) begin
            data[i] = i;
            //$display("i: %d, data[i]: %d", i, data[i]);
        end

        // testing writing to memory
        $display("testing writing to memory");
        wr_en = 1;
        for (i = 0; i < num_mem_entries; i++) begin
            wr_data = data[i];
            #10;
            wr_addr = wr_addr + 1;
        end
        wr_addr = 0;
        wr_en = 0;
        wr_data = 0;

        // testing reading from mem
        $display("testing reading from mem");
        rd_en = 1;
        for (i = 0; i < num_mem_entries; i++) begin
            #10;
            if (rd_data != data[i]) begin
                $display("Error: i: %d, rd_addr: %d, rd_data: %h, data[i]: %h", i, rd_addr, rd_data, data[i]);
            end
            rd_addr = rd_addr + 1;
        end
        rd_addr = 0;
        rd_en = 0;

        // testing dual port
        $display("testing dual port");
        wr_en = 1;
        rd_en = 1;
        wr_addr = 0;
        wr_data = 0;
        rd_addr = 0;
        #10
        for (i = 1; i < 32; i++) begin
            wr_data = data[i];
            #10;
            if (rd_data != data[i-1]) begin
                $display("Error: i-1: %d, rd_data: %h, data[i-1]: %h", i-1, rd_data, data[i-1]);
            end
        end

        $finish;
    end

    always #5 clk = ~clk;  // 100 MHz clock with 10ns period
    //at multiples of 10, clk is low

endmodule