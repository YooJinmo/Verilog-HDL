`timescale 1ns / 1ps

module fnd_controller (
    input clk,
    input reset,
    input [13:0] fndData,
    output [3:0] fndCom,
    output [7:0] fndFont
);

    wire tick;
    wire [1:0] digit_sel;
    wire [3:0] digit_1, digit_10, digit_100, digit_1000, digit;

    clk_div_1khz U_clk_div_1khz (
        .clk  (clk),
        .reset(reset),
        .tick (tick)
    );

    counter_2bit U_counter_2bit (
        .clk  (clk),
        .reset(reset),
        .tick (tick),
        .count(digit_sel)
    );

    decoder_2x4 U_decoder_2x4 (
        .x(digit_sel),
        .y(fndCom)
    );

    digit_splitter U_digit_splitter (
        .fndData(fndData),
        .digit_1(digit_1),
        .digit_10(digit_10),
        .digit_100(digit_100),
        .digit_1000(digit_1000)
    );

    mux_4x1 U_mux_4x1 (
        .sel(digit_sel),
        .x0 (digit_1),
        .x1 (digit_10),
        .x2 (digit_100),
        .x3 (digit_1000),
        .y  (digit)
    );

    bcdtoseg U_bcdtoseg (
        .bcd(digit),
        .seg(fndFont)
    );

endmodule


module clk_div_1khz (
    input clk,
    input reset,
    output reg tick
);
    reg [$clog2(100_000)-1:0] div_counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            div_counter <= 0;
            tick <= 1'b0;
        end else begin
            if (div_counter == 100_000 - 1) begin
                div_counter <= 0;
                tick <= 1'b1;
            end else begin
                div_counter = div_counter + 1;
                tick <= 1'b0;
            end
        end
    end

endmodule


module counter_2bit (
    input            clk,
    input            reset,
    input            tick,
    output reg [1:0] count
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 0;
        end else begin
            if (tick) begin
            count <= count + 1;
            end
        end
    end

endmodule


module decoder_2x4 (
    input [1:0] x,
    output reg [3:0] y
);
    always @(*) begin
        y = 4'b1111;
        case (x)
            2'b00: y = 4'b1110;
            2'b01: y = 4'b1101;
            2'b10: y = 4'b1011;
            2'b11: y = 4'b0111;
            // default: 
        endcase
    end

endmodule


module digit_splitter (
    input  [13:0] fndData,
    output [ 3:0] digit_1,
    output [ 3:0] digit_10,
    output [ 3:0] digit_100,
    output [ 3:0] digit_1000
);
    assign digit_1    = fndData % 10;
    assign digit_10   = (fndData / 10) % 10;
    assign digit_100  = (fndData / 100) % 10;
    assign digit_1000 = (fndData / 1000) % 10;

endmodule


module mux_4x1 (
    input [1:0] sel,
    input [3:0] x0,
    input [3:0] x1,
    input [3:0] x2,
    input [3:0] x3,
    output reg [3:0] y
);

    always @(*) begin
        y = 4'b0000;
        case (sel)
            2'b00: y = x0;
            2'b01: y = x1;
            2'b10: y = x2;
            2'b11: y = x3;
        endcase
    end

endmodule


module bcdtoseg (
    input [3:0] bcd,
    output reg [7:0] seg
);
    always @(bcd) begin
        case (bcd)
            4'h0: seg = 8'hC0;  // 0
            4'h1: seg = 8'hF9;  // 1
            4'h2: seg = 8'hA4;  // 2
            4'h3: seg = 8'hB0;  // 3
            4'h4: seg = 8'h99;  // 4
            4'h5: seg = 8'h92;  // 5
            4'h6: seg = 8'h82;  // 6
            4'h7: seg = 8'hF8;  // 7
            4'h8: seg = 8'h80;  // 8
            4'h9: seg = 8'h90;  // 9
            4'hA: seg = 8'h88;  // A
            4'hB: seg = 8'h83;  // b
            4'hC: seg = 8'hC6;  // C
            4'hD: seg = 8'hA1;  // d
            4'hE: seg = 8'h7F;  // E (dot만 display 등으로 수정 가능)
            4'hF: seg = 8'hFF;  // 모두 off
            default: seg = 8'hFF;
        endcase
    end

endmodule
