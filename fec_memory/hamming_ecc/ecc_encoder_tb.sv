/*
Copyright (c) 2025 Stephen Wilcox. All rights reserved.
Not for use in commercial or non-commercial products or projects without explicit permission from author.
*/
`timescale 1ns/1ps
module ecc_encoder_tb();
    parameter integer data_bit_width = 64;
    parameter integer redundant_bit_width = 8;

    //reg clk;

    reg [data_bit_width-1:0] data_in;
    wire [redundant_bit_width+data_bit_width-1:0] data_out;
    reg [redundant_bit_width+data_bit_width-1:0] exp_data_out;

    ecc_encoder #(.data_bit_width(data_bit_width), .redundant_bit_width(redundant_bit_width)) enc_inst (
        .enc_data_in(data_in),
        .enc_data_out(data_out)
    );

    bit [redundant_bit_width-1:0] func_p;  // to see in the waveform
    function automatic bit [redundant_bit_width+data_bit_width-1:0] calc_ecc(input bit [data_bit_width-1:0] data);
        bit [redundant_bit_width+data_bit_width-1:0] output_data = '0;
        bit [redundant_bit_width-1:0] p;
        integer j, k;
        for (j = 1; j < redundant_bit_width; j++) begin
            for (k = 0; k < redundant_bit_width+data_bit_width; k++) begin
                if (k != 0) begin
                    // if (k & (1 << (j-1))) begin
                    //     p[j] ^= data[k - $clog2(k) - 1];
                    // end
                    if (k[j-1]) begin
                        p[j] ^= data[k - $clog2(k) - 1];
                    end
                end
            end
        end
        p[0] = ^{data, p[redundant_bit_width-1:1]};
        func_p = p;
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

    integer i;

    initial begin
        $dumpfile("ecc_encoder.vcd");
        $dumpvars(0, ecc_encoder_tb);
        for (int j = 0; j < redundant_bit_width; j++) begin
            $dumpvars(0, ecc_encoder_tb.enc_inst.masked_bits[j]);
        end

        //clk = 0;
        #20;
        
        for (i = 0; i < 10; i++) begin
            data_in = {$urandom, $urandom};
            exp_data_out = calc_ecc(data_in);
            #10;
            if (data_out != exp_data_out) begin
                $display("Error: data_out: %h, exp_data_out: %h", data_out, exp_data_out);
            end
            #10;
        end


        $finish;
    end

    //always #5 clk = ~clk;  // 100 MHz clock with 10ns period
    //at multiples of 10, clk is low

endmodule