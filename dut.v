module apb_alu_dut (
    input  logic        PCLK,
    input  logic        PRESETn,
    input  logic        PSEL,
    input  logic        PENABLE,
    input  logic        PWRITE,
    input  logic [7:0]  PADDR,
    input  logic [31:0] PWDATA,
    output logic [31:0] PRDATA,
    output logic        PREADY,

    // req/ack interface
    output logic        req,
    input  logic        ack
);

    // Registers
    logic [31:0] reg_a, reg_b;
    logic [2:0]  reg_op;
    logic        reg_start;
    logic        reg_done;
    logic [31:0] reg_result;

    // ALU wires
    logic [31:0] alu_result;

    alu u_alu (
        .a(reg_a),
        .b(reg_b),
        .op(reg_op),
        .result(alu_result)
    );

    // APB ready (always ready simplificat)
    assign PREADY = 1'b1;

    // WRITE
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            reg_a     <= 0;
            reg_b     <= 0;
            reg_op    <= 0;
            reg_start <= 0;
        end else begin
            if (PSEL && PENABLE && PWRITE) begin
                case (PADDR)
                    8'h00: reg_a <= PWDATA;
                    8'h04: reg_b <= PWDATA;
                    8'h08: reg_op <= PWDATA[2:0];
                    8'h0C: reg_start <= PWDATA[0];
                endcase
            end else begin
                // clear start după un ciclu
                reg_start <= 1'b0;
            end
        end
    end

    // READ
    always_comb begin
        case (PADDR)
            8'h00: PRDATA = reg_a;
            8'h04: PRDATA = reg_b;
            8'h08: PRDATA = {29'd0, reg_op};
            8'h0C: PRDATA = {31'd0, reg_start};
            8'h10: PRDATA = {31'd0, reg_done};
            8'h14: PRDATA = reg_result;
            default: PRDATA = 32'd0;
        endcase
    end

    // FSM req/ack
    typedef enum logic [1:0] {
        IDLE,
        WAIT_ACK,
        DONE
    } state_t;

    state_t state, next_state;

    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        next_state = state;
        req = 1'b0;
        reg_done = 1'b0;

        case (state)
            IDLE: begin
                if (reg_start)
                    next_state = WAIT_ACK;
            end

            WAIT_ACK: begin
                req = 1'b1;
                if (ack)
                    next_state = DONE;
            end

            DONE: begin
                reg_done = 1'b1;
                next_state = IDLE;
            end
        endcase
    end

    // Capture result când ack vine
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            reg_result <= 0;
        end else begin
            if (state == WAIT_ACK && ack) begin
                reg_result <= alu_result;
            end
        end
    end

endmodule