`timescale 1ns / 1ps

module DataPath (
    input  logic       clk,
    input  logic       rst,
    input  logic       ASrcMuxSel,
    input  logic       AEn,
    input  logic       OutBuf,
    output logic       ALt10,
    output logic [7:0] OutPort
);

endmodule


module register (
    input  logic       clk,
    input  logic       reset,
    input  logic       en,
    input  logic [7:0] d,
    output logic [7:0] q
);

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            q <= 0;
        end else begin
            if (en) begin
                q <= d;
            end
        end
    end

endmodule


module adder (
    input  logic [7:0] a,
    input  logic [7:0] b,
    output logic [7:0] sum
);
    assign sum = a + b;

endmodule


module comparator (
    input  logic [7:0] a,
    input  logic [7:0] b,
    output logic       lt
);
    assign lt = a < b;

endmodule
