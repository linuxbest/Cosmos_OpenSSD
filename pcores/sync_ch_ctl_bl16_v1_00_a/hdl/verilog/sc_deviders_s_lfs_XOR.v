//////////////////////////////////////////////////////////////////////////////////
// sc_deviders_s_lfs_XOR.v for Cosmos OpenSSD
// Copyright (c) 2015 Hanyang University ENC Lab.
// Contributed by Ilyong Jung <iyjung@enc.hanyang.ac.kr>
//                Yong Ho Song <yhsong@enc.hanyang.ac.kr>
//
// This file is part of Cosmos OpenSSD.
//
// Cosmos OpenSSD is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3, or (at your option)
// any later version.
//
// Cosmos OpenSSD is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Cosmos OpenSSD; see the file COPYING.
// If not, see <http://www.gnu.org/licenses/>. 
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Company: ENC Lab. <http://enc.hanyang.ac.kr>
// Engineer: Ilyong Jung <iyjung@enc.hanyang.ac.kr>
// 
// Project Name: Cosmos OpenSSD
// Design Name: BCH Decoder
// Module Name: sc_serial_lfs_XOR_***
// File Name: sc_deviders_s_lfs_XOR.v
//
// Version: v1.0.2-2KB_T32
//
// Description: 
//   - serial Linear Feedback Shift XOR
//   - for data area
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.2
//   - temporary roll-back for releasing
//   - coding style of this version is not unified
//
// * v1.0.1
//   - minor modification for releasing
//
// * v1.0.0
//   - first draft
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

	/////////////////////////////////////////////
	////////// GENERATED BY C PROGRAMA //////////
	/////
	///
	
	// This file was generated by C program.
	
	// total: 32
	
	                                          ///
	                                        /////	
	////////// GENERATED BY C PROGRAMA //////////
	/////////////////////////////////////////////

module sc_serial_lfs_XOR_001(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1100000000000001;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_003(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1100010000100001;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_005(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1101000000001001;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_007(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1101010101010101;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_009(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1110110000100001;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_011(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1110001100010001;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_013(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1111001100000001;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_015(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1011111111111111;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_017(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1001010011100001;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_019(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1011110000001001;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_021(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1000001111110101;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_023(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1000110000100001;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_025(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1010101110011001;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_027(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1001010101100001;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_029(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1010000001100111;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_031(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1111100011100001;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_033(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1001000110101001;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_035(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1101101111111101;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_037(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1010110100000101;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_039(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1100100011111001;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_041(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1000011100110001;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_043(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1110000001000111;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_045(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1100000000011111;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_047(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1111101101101001;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_049(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1100110101010101;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_051(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1110000000110101;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_053(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1111010101010001;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_055(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1110110010011001;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_057(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1110000101111111;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_059(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1110010001110011;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_061(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1001001011001001;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule

module sc_serial_lfs_XOR_063(message, cur_remainder, nxt_remainder);
`include "SC_parameters.vh"
    parameter [0:15] MIN_POLY = 16'b1011100111110101;
    input wire message;
    input wire [`REMAINDERS_SIZE-1:0] cur_remainder;
    output wire [`REMAINDERS_SIZE-1:0] nxt_remainder;
    wire FB_term;
    assign FB_term = cur_remainder[`REMAINDERS_SIZE-1];
    assign nxt_remainder[0] = message ^ FB_term;
    genvar i;
    generate
        for (i=1; i<`REMAINDERS_SIZE; i=i+1)
        begin: linear_function
            if (MIN_POLY[i] == 1)
            begin
                assign nxt_remainder[i] = cur_remainder[i-1] ^ FB_term;
            end
            else
            begin
                assign nxt_remainder[i] = cur_remainder[i-1];
            end
        end
    endgenerate
endmodule
