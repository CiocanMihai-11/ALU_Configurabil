module alu_apb (
    input         PCLK,
    input         PRESETn,

    input  [7:0]  PADDR,
    input         PSEL,
    input         PENABLE,
    input         PWRITE,
    input  [31:0] PWDATA,

    output        PREADY,
    output reg    PSLVERR,
    output reg [31:0] PRDATA,

    output reg    req,
    input         ack,

    output reg [31:0] result
);

//////////////////////////////////////////////////
// REGISTERS
//////////////////////////////////////////////////

reg [31:0] op1_reg, op2_reg;
reg [2:0]  ctrl_reg;

//////////////////////////////////////////////////
// FSM
//////////////////////////////////////////////////

localparam IDLE     = 2'b00;
localparam EXEC     = 2'b01;
localparam MUL_OP   = 2'b10;
localparam REQ_WAIT = 2'b11;

reg [1:0] state, next_state;

//////////////////////////////////////////////////
// OPCODES
//////////////////////////////////////////////////

localparam ADD = 3'b000;
localparam SUB = 3'b001;
localparam AND = 3'b010;
localparam OR  = 3'b011;
localparam XOR = 3'b100;
localparam MUL = 3'b101;

//////////////////////////////////////////////////
// APB PROPER COMPLIANCE
//////////////////////////////////////////////////

wire apb_setup  = PSEL && !PENABLE;
wire apb_access = PSEL && PENABLE;
wire write_en   = apb_setup && PWRITE;

assign PREADY = 1'b1;   // simplu, UVM-friendly

//////////////////////////////////////////////////
// REGISTER WRITE
//////////////////////////////////////////////////

always @(posedge PCLK or negedge PRESETn) begin
    if(!PRESETn) begin
        op1_reg  <= 0;
        op2_reg  <= 0;
        ctrl_reg <= 0;
    end
    else if(apb_setup && PWRITE && state == IDLE) begin
        case(PADDR)
            8'h00: ctrl_reg <= PWDATA[2:0];
            8'h04: op1_reg  <= PWDATA;
            8'h08: op2_reg  <= PWDATA;
        endcase
    end
end

//////////////////////////////////////////////////
// START DETECT (CLEAN EDGE)
//////////////////////////////////////////////////

reg start_op_r;

always @(posedge PCLK or negedge PRESETn) begin
    if(!PRESETn)
        start_op_r <= 0;
    else
        start_op_r <= (apb_access && PWRITE && (PADDR == 8'h08));
end

//////////////////////////////////////////////////
// FSM NEXT STATE
//////////////////////////////////////////////////

always @(*) begin
    case(state)

        IDLE: begin
            if(start_op_r && ctrl_reg == MUL)
                next_state = MUL_OP;
            else if(start_op_r)
                next_state = EXEC;
            else
                next_state = IDLE;
        end

        EXEC:
            next_state = REQ_WAIT;

        MUL_OP:
            next_state = REQ_WAIT;

        REQ_WAIT:
            next_state = (ack) ? IDLE : REQ_WAIT;

        default:
            next_state = IDLE;

    endcase
end

//////////////////////////////////////////////////
// STATE REGISTER
//////////////////////////////////////////////////

always @(posedge PCLK or negedge PRESETn) begin
    if(!PRESETn)
        state <= IDLE;
    else
        state <= next_state;
end

//////////////////////////////////////////////////
// ALU LOGIC
//////////////////////////////////////////////////

always @(posedge PCLK or negedge PRESETn) begin
    if(!PRESETn)
        result <= 0;
    else if(state == EXEC) begin
        case(ctrl_reg)
            ADD: result <= op1_reg + op2_reg;
            SUB: result <= op1_reg - op2_reg;
            AND: result <= op1_reg & op2_reg;
            OR : result <= op1_reg | op2_reg;
            XOR: result <= op1_reg ^ op2_reg;
            default: result <= 0;
        endcase
    end
end

//////////////////////////////////////////////////
// MULTIPLY (SHIFT-ADD SIMPLE)
//////////////////////////////////////////////////

reg [31:0] mul_a, mul_b, mul_res;
reg [5:0]  mul_cnt;

always @(posedge PCLK or negedge PRESETn) begin
    if(!PRESETn) begin
        mul_a   <= 0;
        mul_b   <= 0;
        mul_res <= 0;
        mul_cnt <= 0;
    end

    else if(state == IDLE && start_op_r && ctrl_reg == MUL) begin
        mul_a   <= op1_reg;
        mul_b   <= op2_reg;
        mul_res <= 0;
        mul_cnt <= 0;
    end

    else if(state == MUL_OP) begin
        if(mul_b[0])
            mul_res <= mul_res + mul_a;

        mul_a   <= mul_a << 1;
        mul_b   <= mul_b >> 1;
        mul_cnt <= mul_cnt + 1;

        if(mul_cnt == 6'd31)
            result <= mul_res;
    end
end

//////////////////////////////////////////////////
// REQUEST SIGNAL (CLEAN)
//////////////////////////////////////////////////

always @(posedge PCLK or negedge PRESETn) begin
    if(!PRESETn)
        req <= 0;
    else
        req <= (state == REQ_WAIT);
end

endmodule