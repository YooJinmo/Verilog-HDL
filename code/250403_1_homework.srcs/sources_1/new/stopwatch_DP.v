`timescale 1ns / 1ps

module stopwatch_DP (
    input clk,
    input reset,
    input run,
    input clear,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
);

    wire w_clk_100hz, w_msec_tick, w_sec_tick, w_min_tick, w_hour_tick;

    // msec
    time_counter #(
        .TICK_COUNT(100),
        .BIT_WIDTH (7)
    ) U_Time_Msec (
        .clk(clk),
        .reset(reset),
        .tick(w_clk_100hz),
        .clear(clear),
        .o_time(msec),
        .o_tick(w_msec_tick)
    );
    // sec
    time_counter #(
        .TICK_COUNT(60),
        .BIT_WIDTH (6)
    ) U_Time_sec (
        .clk(clk),
        .reset(reset),
        .tick(w_msec_tick),
        .clear(clear),
        .o_time(sec),
        .o_tick(w_sec_tick)
    );
    // min
    time_counter #(
        .TICK_COUNT(60),
        .BIT_WIDTH (6)
    ) U_Time_min (
        .clk(clk),
        .reset(reset),
        .tick(w_sec_tick),
        .clear(clear),
        .o_time(min),
        .o_tick(w_min_tick)
    );
    // hour
    time_counter #(
        .TICK_COUNT(24),
        .BIT_WIDTH (5)
    ) U_Time_hour (
        .clk(clk),
        .reset(reset),
        .tick(w_min_tick),
        .clear(clear),
        .o_time(hour),
        .o_tick()
    );

    clk_div_100 U_clk_div (
        .clk  (clk),
        .reset(reset),
        .run  (run),
        .clear(clear),
        .o_clk(w_clk_100hz)
    );
endmodule


module time_counter #(
    parameter TICK_COUNT = 100,
    parameter BIT_WIDTH  = 7
) (
    input clk,
    input reset,
    input tick,
    input clear,
    output [6:0] o_time,
    output o_tick
);
    reg [$clog2(TICK_COUNT)-1:0] count_reg, count_next;
    reg tick_reg, tick_next;

    assign o_time = count_reg;
    assign o_tick = tick_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count_reg <= 0;
            tick_reg  <= 0;
        end else begin
            count_reg <= count_next;
            tick_reg  <= tick_next;
        end
    end

    always @(*) begin
        count_next = count_reg;
        tick_next  = 0;
        if (clear == 1'b1) begin
            count_next = 0;
        end else if (tick == 1'b1) begin
            if (count_reg == TICK_COUNT - 1) begin
                count_next = 0;
                tick_next  = 1'b1;
            end else begin
                count_next = count_reg + 1;
                tick_next  = 1'b0;
            end
        end
    end
endmodule


module clk_div_100 (
    input  clk,
    input  reset,
    input  run,
    input  clear,
    output o_clk
);

    parameter FCOUNT = 1_000_000; //1_000_000; // 10; //test를 위해 10으로 설정 가능
    reg [$clog2(FCOUNT)-1:0] count_reg, count_next;
    reg clk_reg, clk_next;  // 출력을 F-F으로 내보내기 위해서.

    assign o_clk = clk_reg;  // 최종 출력.

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count_reg <= 0;
            clk_reg   <= 0;
        end else begin
            count_reg <= count_next;
            clk_reg   <= clk_next;
        end
    end
    // next
    always @(*) begin
        count_next = count_reg;
        clk_next   = 1'b0;
        if (run == 1'b1) begin
            if (count_reg == FCOUNT - 1) begin
                count_next = 0;
                clk_next   = 1'b1;  // 출력 High
            end else begin
                count_next = count_reg + 1;
                clk_next   = 1'b0;
            end
        end else if (clear == 1'b1) begin
            count_next = 0;
            clk_next   = 0;
        end
    end

endmodule

