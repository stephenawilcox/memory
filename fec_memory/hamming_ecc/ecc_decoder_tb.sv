/*
Copyright (c) 2025 Stephen Wilcox. All rights reserved.
Not for use in commercial or non-commercial products or projects without explicit permission from author.
*/
`timescale 1ns/1ps
module ecc_decoder_tb();
    parameter integer data_bit_width = 64;
    parameter integer redundant_bit_width = 8;

    //reg clk;

    reg [redundant_bit_width+data_bit_width-1:0] data_in;
    wire [data_bit_width-1:0] data_out;
    reg [data_bit_width-1:0] exp_data_out;

    wire [redundant_bit_width+data_bit_width-1:0] enc_data_out;

    ecc_encoder #(.data_bit_width(data_bit_width), .redundant_bit_width(redundant_bit_width)) enc_inst (
        .enc_data_in(exp_data_out),
        .enc_data_out(enc_data_out)
    );

    ecc_decoder #(.data_bit_width(data_bit_width), .redundant_bit_width(redundant_bit_width)) dec_inst (
        .dec_data_in(data_in),
        .dec_data_out(data_out)
    );

    function automatic bit [redundant_bit_width+data_bit_width-1:0] ecc_encode(input bit [data_bit_width-1:0] data);
        bit [redundant_bit_width+data_bit_width-1:0] output_data = '0;
        bit [redundant_bit_width-1:0] p;
        integer j, k;
        for (j = 1; j < redundant_bit_width; j++) begin
            for (k = 0; k < redundant_bit_width+data_bit_width; k++) begin
                if (k != 0) begin
                    if (k[j-1]) begin
                        p[j] ^= data[k - $clog2(k) - 1];
                    end
                end
            end
        end
        p[0] = ^{data, p[redundant_bit_width-1:1]};
        for (j = 0; j < redundant_bit_width+data_bit_width; j++) begin
            if (j == 0) begin
                    output_data[j] = p[0];
            end
            else if ((j & (j-1)) == 0) begin
                output_data[j] = p[$clog2(j)+1];
            end
            else begin
                output_data[j] = data[j - $clog2(j) - 1];
            end
        end
        return output_data;
    endfunction

    integer i, j;
    initial begin
        $dumpfile("ecc_decoder.vcd");
        $dumpvars(0, ecc_decoder_tb);
        for (j = 0; j < redundant_bit_width; j++) begin
            $dumpvars(0, ecc_decoder_tb.dec_inst.masked_bits[j]);
        end


        //clk = 0;
        #20;
        
        for (i = 0; i < redundant_bit_width+data_bit_width; i++) begin
            exp_data_out = {$urandom(), $urandom()};
            // data_in = ecc_encode(exp_data_out);
            data_in = enc_data_out;
            data_in[i] = ~data_in[i];
            #10;
            if (data_out != exp_data_out) begin
                $display("Error: i: %d, data_out: %h, exp_data_out: %h", i, data_out, exp_data_out);
            end
            #10;
        end


        $finish;
    end

    //always #5 clk = ~clk;  // 100 MHz clock with 10ns period
    //at multiples of 10, clk is low

endmodule