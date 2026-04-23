`timescale 1ns/1ps

module tb_apb_alu;

    logic        PCLK;
    logic        PRESETn;
    logic        PSEL;
    logic        PENABLE;
    logic        PWRITE;
    logic [7:0]  PADDR;
    logic [31:0] PWDATA;
    logic [31:0] PRDATA;
    logic        PREADY;

    logic req;
    logic ack;

    // DUT
    apb_alu_dut dut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .req(req),
        .ack(ack)
    );

    // Clock
    always #5 PCLK = ~PCLK;

    // ---------------- APB TASKS ----------------

    task apb_write(input [7:0] addr, input [31:0] data);
    begin
        @(posedge PCLK);
        PSEL    <= 1;
        PWRITE  <= 1;
        PENABLE <= 0;
        PADDR   <= addr;
        PWDATA  <= data;

        @(posedge PCLK);
        PENABLE <= 1;

        @(posedge PCLK);
        PSEL    <= 0;
        PENABLE <= 0;
        PWRITE  <= 0;
    end
    endtask

    task apb_read(input [7:0] addr, output [31:0] data);
    begin
        @(posedge PCLK);
        PSEL    <= 1;
        PWRITE  <= 0;
        PENABLE <= 0;
        PADDR   <= addr;

        @(posedge PCLK);
        PENABLE <= 1;

        @(posedge PCLK);
        data = PRDATA;

        PSEL    <= 0;
        PENABLE <= 0;
    end
    endtask

    // ---------------- ACK GENERATOR ----------------
    // Simulează un "peripheral" care răspunde după câteva cicluri

    initial begin
        ack = 0;
        forever begin
            @(posedge PCLK);
            if (req) begin
                repeat (3) @(posedge PCLK); // delay
                ack <= 1;
                @(posedge PCLK);
                ack <= 0;
            end
        end
    end

    // ---------------- TEST ----------------

    initial begin
        PCLK = 0;
        PRESETn = 0;
        PSEL = 0;
        PENABLE = 0;
        PWRITE = 0;
        PADDR = 0;
        PWDATA = 0;

        // Reset
        repeat (5) @(posedge PCLK);
        PRESETn = 1;

        // ---------------- TEST 1: ADD ----------------
        apb_write(8'h00, 10); // A
        apb_write(8'h04, 20); // B
        apb_write(8'h08, 0);  // ADD
        apb_write(8'h0C, 1);  // START

        // Wait done
        wait_done();

        check_result(30);

        // ---------------- TEST 2: SUB ----------------
        apb_write(8'h00, 50);
        apb_write(8'h04, 15);
        apb_write(8'h08, 1); // SUB
        apb_write(8'h0C, 1);

        wait_done();

        check_result(35);

        // ---------------- TEST 3: AND ----------------
        apb_write(8'h00, 32'hF0F0);
        apb_write(8'h04, 32'h0FF0);
        apb_write(8'h08, 2); // AND
        apb_write(8'h0C, 1);

        wait_done();

        check_result(32'h00F0);

        $display("ALL TESTS PASSED ✅");
        $finish;
    end

    // ---------------- HELPERS ----------------

    task wait_done();
        logic [31:0] status;
        begin
            do begin
                apb_read(8'h10, status);
            end while (status[0] == 0);
        end
    endtask

    task check_result(input [31:0] expected);
        logic [31:0] result;
        begin
            apb_read(8'h14, result);

            if (result !== expected) begin
                $display("ERROR: expected=%0d got=%0d", expected, result);
                $stop;
            end else begin
                $display("OK: result=%0d", result);
            end
        end
    endtask

endmodule