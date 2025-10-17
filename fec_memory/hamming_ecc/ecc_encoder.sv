/*
Copyright (c) 2025 Stephen Wilcox. All rights reserved.
Not for use in commercial or non-commercial products or projects without explicit permission from author.
*/
module ecc_encoder #(
    parameter integer data_bit_width = 64,
    parameter integer redundant_bit_width = 8
)
(
    input wire [data_bit_width-1:0] enc_data_in,
    output wire [redundant_bit_width+data_bit_width-1:0] enc_data_out
);
// single error correction, double error detection hamming code
wire [redundant_bit_width-1:0] parity;

wire [redundant_bit_width+data_bit_width-1:0] data;
genvar i;
generate
    for (i = 0; i < redundant_bit_width+data_bit_width; i++) begin
        if (i & (i-1) == 0) begin
            if (i == 0) begin
                assign enc_data_out[i] = parity[0];
            end
            else begin
                assign enc_data_out[i] = parity[$clog2(i)+1];
            end
        end
        else begin
            //FIXME how to index enc_data_in based on i????
            assign enc_data_out[i] = enc_data_in[cur_d];
            assign data[i] = enc_data_in[cur_d];
        end
    end
endgenerate

wire [data_bit_width-1:0] masked_bits [redundant_bit_width];
genvar j,k;
generate
    for (j = 1; j < redundant_bit_width; j++) begin
        for (k = 0; k < redundant_bit_width+data_bit_width; k++) begin
            assign masked_bits[j][k] = k[2**(j-1)] ? data[k] : 1'b0;
        end
    end
endgenerate

always_comb begin
    for (int n = 1; n < redundant_bit_width; n++) begin
        assign parity[n] = ^masked_bits[n];
    end
end
assign parity[0] = ^{enc_data_in, parity[1:redundant_bit_width-1]};

endmodule