/*
Copyright (c) 2025 Stephen Wilcox. All rights reserved.
Not for use in commercial or non-commercial products or projects without explicit permission from author.
*/
module memory_dp #(
parameter integer num_mem_entries = 8,
parameter integer data_bit_width = 32
)
(
input wire wr_clk,
input wire wr_en,
input wire [addr_bit_width-1:0] wr_addr,
input wire [data_bit_width-1:0] wr_data,
input wire rd_clk,
input wire rd_en,
input wire [addr_bit_width-1:0] rd_addr,
output reg [data_bit_width-1:0] rd_data
);

localparam integer addr_bit_width = $clog2(num_mem_entries);

// attribute to force URAM (UltraRAM) use
(* ram_style = "ultra" *) 

reg [data_bit_width-1:0] mem [0:num_mem_entries-1];

always @ (posedge wr_clk) begin
    if (wr_en) begin
        mem[wr_addr] <= wr_data;
    end
end

always @ (posedge rd_clk) begin
    if (rd_en) begin
        rd_data <= mem[rd_addr];
    end
end

endmodule