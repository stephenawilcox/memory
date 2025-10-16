/*
Copyright (c) 2025 Stephen Wilcox. All rights reserved.
Not for use in commercial or non-commercial products or projects without explicit permission from author.
*/
module memory_mb_dp #(
    parameter integer data_bit_width = 32,
    parameter integer num_banks = 4,
    parameter integer num_bank_entries = 64
)
(
    input wire wr_clk,
    input wire [num_banks-1:0] wr_en,
    input wire [addr_bit_width-1:0] wr_addr [num_banks],
    input wire [data_bit_width-1:0] wr_data [num_banks],
    input wire rd_clk,
    input wire [num_banks-1:0] rd_en,
    input wire [addr_bit_width-1:0] rd_addr [num_banks],
    output reg [data_bit_width-1:0] rd_data [num_banks]
);

localparam integer addr_bit_width = $clog2(num_bank_entries);

genvar i;
generate
    for (i = 0; i < num_banks; i++) begin
        memory_dp #(.num_mem_entries(num_bank_entries), .data_bit_width(data_bit_width)) mem_dp_inst (
            .wr_clk(wr_clk),
            .wr_en(wr_en[i]),
            .wr_addr(wr_addr[i]),
            .wr_data(wr_data[i]),
            .rd_clk(rd_clk),
            .rd_en(rd_en[i]),
            .rd_addr(rd_addr[i]),
            .rd_data(rd_data[i])
        );
    end
endgenerate


endmodule