/*
Copyright (c) 2025 Stephen Wilcox. All rights reserved.
Not for use in commercial or non-commercial products or projects without explicit permission from author.
*/
module ecc_decoder #(
    parameter integer data_bit_width = 64,
    parameter integer redundant_bit_width = 8
)
(
    input wire [redundant_bit_width+data_bit_width-1:0] dec_data_in,
    output wire [data_bit_width-1:0] dec_data_out,
    output wire [1:0] err
);
// single error correction, double error detection hamming code
/*
0   1   2   3   4   5   6   7   8   9   10  11  12  13  14  15  16  17  18  ...
p0  p1  p2  d0  p4  d1  d2  d3  p8  d4  d5  d6  d7  d8  d9  d10 p16 d11 d12
i = 3   -> cur_data = 0     i-3     $clog2(i)=2
i = 5   -> cur_data = 1     i-4     $clog2(i)=3
i = 6   -> cur_data = 2     i-4     $clog2(i)=3
i = 7   -> cur_data = 3     i-4     $clog2(i)=3
i = 9   -> cur_data = 4     i-5     $clog2(i)=4
i = 10  -> cur_data = 5     i-5     $clog2(i)=4
i = 11  -> cur_data = 6     i-5     $clog2(i)=4
i = 12  -> cur_data = 7     i-5     $clog2(i)=4
i = 13  -> cur_data = 8     i-5     $clog2(i)=4
i = 14  -> cur_data = 9     i-5     $clog2(i)=4
i = 15  -> cur_data = 10    i-5     $clog2(i)=4
i = 17  -> cur_data = 11    i-6     $clog2(i)=5
i = 18  -> cur_data = 12    i-6     $clog2(i)=5
cur_data = i - $clog2(i) - 1;
*/

wire [redundant_bit_width-1:0] parity_r;
genvar i;
generate
    for (i = 0; i < redundant_bit_width+data_bit_width; i++) begin
        if ((i & (i-1)) == 0) begin
            if (i == 0) begin
                assign parity_r[0] = dec_data_in[0];
            end
            else begin
                assign parity_r[$clog2(i) + 1] = dec_data_in[i];
            end
        end
    end
endgenerate


wire [redundant_bit_width-1:0] parity_e;
wire [redundant_bit_width+data_bit_width-1:0] masked_bits [redundant_bit_width];
genvar j,k;
generate
    for (j = 1; j < redundant_bit_width; j++) begin
        for (k = 0; k < redundant_bit_width+data_bit_width; k++) begin
            if(k == 0) begin
                assign masked_bits[j][k] = 1'b0;
            end
            else begin
                if (k == (1<<(j-1))) begin
                    assign masked_bits[j][k - $clog2(k) - 1] = 1'b0;
                end
                else begin
                    assign masked_bits[j][k] = k[j-1] ? dec_data_in[k] : 1'b0;
                end
            end
        end
    end
endgenerate


wire [redundant_bit_width-1:0] discepancy;
genvar n;
generate
    for (n = 1; n < redundant_bit_width; n++) begin
        assign parity_e[n] = ^masked_bits[n];
    end
endgenerate
assign parity_e[0] = ^{dec_data_in[redundant_bit_width+data_bit_width-1:1]};
assign discepancy = parity_e ^ parity_r;


wire [redundant_bit_width+data_bit_width-1:0] oh_out;
one_hot_encoder #(.in_bit_width(redundant_bit_width-1), .out_bit_width(redundant_bit_width+data_bit_width)) oh_enc_inst (
    .oh_in(discepancy[redundant_bit_width-1:1]),
    .oh_out(oh_out)
);
// genvar i;
generate
    for (i = 0; i < data_bit_width; i++) begin
        if (i == 0) begin
            assign dec_data_out[i] = oh_out[i] ^ dec_data_in[3];
        end
        else begin
            assign dec_data_out[i] = oh_out[i] ^ dec_data_in[i + $clog2(i) + 1];
        end
    end
endgenerate
assign err[0] = 0;//FIXME
assign err[1] = 0;

endmodule