module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [2:0]  op,
    output logic [31:0] result
);

always_comb begin
    case (op)
        3'd0: result = a + b;
        3'd1: result = a - b;
        3'd2: result = a & b;
        3'd3: result = a | b;
        3'd4: result = a ^ b;
        3'd5: result = a * b;
        default: result = 32'd0;
    endcase
end

endmodule