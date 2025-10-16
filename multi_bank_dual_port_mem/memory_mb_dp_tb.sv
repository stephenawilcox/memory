/*
Copyright (c) 2025 Stephen Wilcox. All rights reserved.
Not for use in commercial or non-commercial products or projects without explicit permission from author.
*/
`timescale 1ns/1ps
module memory_mb_dp_tb();
    parameter integer num_bank_entries = 8;
    parameter integer data_bit_width = 32;
    parameter integer num_banks = 4;
    parameter integer addr_bit_width = $clog2(num_bank_entries);

    reg clk;
    wire wr_clk, rd_clk;
    assign wr_clk = clk;
    assign rd_clk = clk;

    reg [num_banks-1:0] wr_en;
    reg [num_banks-1:0] rd_en;
    reg [addr_bit_width-1:0] wr_addr [num_banks];
    reg [addr_bit_width-1:0] rd_addr [num_banks];
    reg [data_bit_width-1:0] wr_data [num_banks];
    wire [data_bit_width-1:0] rd_data [num_banks];

    integer i, j;

    reg [data_bit_width-1:0] data [256];

    memory_mb_dp #(.data_bit_width(data_bit_width), .num_banks(num_banks), .num_bank_entries(num_bank_entries)) mem_inst (
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
        $dumpfile("memory_mb_dp.vcd");
        $dumpvars(0, memory_mb_dp_tb);

        clk = 0;
        #20;
        wr_en   = '0;
        rd_en   = '0;
        for (j = 0; j < num_banks; j++) begin
            wr_addr[j] = '0;
            wr_data[j] = '0;
            rd_addr[j] = '0;
        end

        
        //setting data
        for (i = 0; i < 256; i++) begin
            data[i] = i;
            //$display("i: %d, data[i]: %d", i, data[i]);
        end

        // testing writing to memory
        $display("testing writing to memory");
        wr_en = '1;
        for (i = 0; i < num_bank_entries; i++) begin
            for (j = 0; j < num_banks; j++) begin
                wr_data[j] = data[i];
            end
            #10;
            for (j = 0; j < num_banks; j++) begin
                wr_addr[j] = wr_addr[j] + 1;
            end
        end
        wr_en   = '0;
        for (j = 0; j < num_banks; j++) begin
            wr_addr[j] = '0;
            wr_data[j] = '0;
        end

        // testing reading from mem
        $display("testing reading from mem");
        rd_en = '1;
        for (i = 0; i < num_bank_entries; i++) begin
            #10;
            for (j = 0; j < num_banks; j++) begin
                if (rd_data[j] != data[i]) begin
                    $display("Error: i: %d, j: %d, rd_addr[j]: %d, rd_data[j]: %h, data[i]: %h", i, j, rd_addr[j], rd_data[j], data[i]);
                end
            end
            for (j = 0; j < num_banks; j++) begin
                rd_addr[j] = rd_addr[j] + 1;
            end
        end
        // rd_en   = '0;
        // rd_addr = '{default: '0};

        // testing dual port
        $display("testing dual port");
        wr_en   = '1;
        rd_en   = '1;
        for (j = 0; j < num_banks; j++) begin
            wr_addr[j] = '0;
            wr_data[j] = '0;
            rd_addr[j] = '0;
        end
        #10
        for (i = 1; i < 32; i++) begin
            for (j = 0; j < num_banks; j++) begin
                wr_data[j] = data[i];
            end
            #10;
            for (j = 0; j < num_banks; j++) begin
                if (rd_data[j] != data[i-1]) begin
                    $display("Error: i-1: %d, j: %d, rd_data[j]: %h, data[i-1]: %h", i-1, j, rd_data[j], data[i-1]);
                end
            end
        end

        $finish;
    end

    always #5 clk = ~clk;  // 100 MHz clock with 10ns period
    //at multiples of 10, clk is low

endmodule