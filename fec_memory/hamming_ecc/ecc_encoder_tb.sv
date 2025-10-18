/*
Copyright (c) 2025 Stephen Wilcox. All rights reserved.
Not for use in commercial or non-commercial products or projects without explicit permission from author.
*/
`timescale 1ns/1ps
module ecc_encoder_tb();
    parameter integer data_bit_width = 64;
    parameter integer redundant_bit_width = 8;

    reg clk;

    reg [data_bit_width-1:0] data_in;
    wire [redundant_bit_width+data_bit_width-1:0] data_out;

    ecc_encoder #(.data_bit_width(data_bit_width), .redundant_bit_width(redundant_bit_width)) enc_inst (
        .enc_data_in(data_in),
        .enc_data_out(data_out)
    );


    initial begin
        $dumpfile("ecc_encoder.vcd");
        $dumpvars(0, ecc_encoder_tb);

        clk = 0;
        #20;
        
        

        $finish;
    end

    always #5 clk = ~clk;  // 100 MHz clock with 10ns period
    //at multiples of 10, clk is low

endmodule