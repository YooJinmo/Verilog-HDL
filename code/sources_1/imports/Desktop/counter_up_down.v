`timescale 1ns / 1ps

module top_counter_up (
    input clk,
    input reset,
    input mode,
    output [3:0] fndCom,
    output [7:0] fndFont
);

    wire [13:0] fndData;

    counter_up_down U_counter_up_down (
        .clk  (clk),
        .reset(reset),
        .mode (mode),
        .count(fndData)
    );

    fnd_controller U_fnd_controller (
        .clk(clk),
        .reset(reset),
        .fndData(fndData),
        .fndCom(fndCom),
        .fndFont(fndFont)
    );

endmodule


module counter_up_down (
    input         clk,
    input         reset,
    input         mode,
    output [13:0] count
);

    wire tick;

    clk_div_10hz U_clk_div_10hz (
        .clk  (clk),
        .reset(reset),
        .tick (tick)
    );

    counter U_counter_Up_Down (
        .clk  (clk),
        .reset(reset),
        .tick (tick),
        .mode (mode),
        .count(count)
    );

endmodule


module counter (
    input         clk,
    input         reset,
    input         tick,
    input         mode,
    output [13:0] count
);
    reg [$clog2(10_000)-1:0] counter;

    assign count = counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter <= 0;
        end else begin
            if (mode == 1'b0) begin
                if (tick) begin
                    if (counter == 9999) begin
                        counter <= 0;
                    end else begin
                        counter <= counter + 1;
                    end
                end
            end else begin
                if (tick) begin
                    if (counter == 0) begin
                        counter <= 9999;
                    end else begin
                        counter <= counter - 1;
                    end
                end
            end
        end
    end

endmodule


module clk_div_10hz (
    input clk,
    input reset,
    output reg tick
);
    reg [$clog2(10_000_000)-1:0] div_counter;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            div_counter <= 0;
            tick <= 0;
        end else begin
            if (div_counter == 10_000_000 - 1) begin
                div_counter <= 0;
                tick <= 1'b1;
            end else begin
                div_counter <= div_counter + 1;
                tick <= 1'b0;
            end
        end
    end

endmodule
