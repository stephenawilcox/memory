/*
Copyright (c) 2025 Stephen Wilcox. All rights reserved.
Not for use in commercial or non-commercial products or projects without explicit permission from author.
*/
module one_hot_encoder #(
    parameter integer in_bit_width = 7,
    parameter integer out_bit_width = 1<<(in_bit_width)
)
(
    input wire [in_bit_width-1:0] oh_in,
    output wire [out_bit_width-1:0] oh_out
);

wire [in_bit_width-1:0] w0 [out_bit_width];
genvar i, j;
generate
    for (i = 0; i < out_bit_width; i++) begin
        for (j = 0; j < in_bit_width; j++) begin
            assign w0[i][j] = i[j] ? oh_in[j] : ~oh_in[j];
        end
    end
    for (i = 0; i < out_bit_width; i++) begin
        assign oh_out[i] = &w0[i];
    end
endgenerate

endmodule