/*
Copyright (c) 2025 Stephen Wilcox. All rights reserved.
Not for use in commercial or non-commercial products or projects without explicit permission from author.
*/
`timescale 1ns/1ps
module one_hot_encoder_tb();
    parameter integer in_bit_width = 7;
    parameter integer out_bit_width = 1<<(in_bit_width);

    //reg clk;

    reg [in_bit_width-1:0] data_in;
    wire [out_bit_width-1:0] data_out;
    reg [out_bit_width-1:0] exp_data_out;


    one_hot_encoder #(.in_bit_width(in_bit_width), .out_bit_width(out_bit_width)) oh_enc_inst (
        .oh_in(data_in),
        .oh_out(data_out)
    );



    integer i;
    initial begin
        $dumpfile("one_hot_encoder.vcd");
        $dumpvars(0, one_hot_encoder_tb);

        //clk = 0;
        #20;
        
        for (i = 0; i < out_bit_width; i++) begin
            data_in = i;
            exp_data_out = '0;
            exp_data_out[data_in] = 1'b1;
            #10;
            if (data_out != exp_data_out) begin
                $display("Error: i: %d, data_out: %h, exp_data_out: %h", i, data_out, exp_data_out);
            end
        end


        $finish;
    end

    //always #5 clk = ~clk;  // 100 MHz clock with 10ns period
    //at multiples of 10, clk is low

endmodule