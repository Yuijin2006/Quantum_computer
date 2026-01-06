`timescale 1ns/1ps

module tb_mips_qpu_top;
    // Clock & reset
    reg clk;
    reg reset;

    // Monitor signals from top
    wire [31:0] pc;
    wire [31:0] instr;
    wire        quantum_en;
    wire [1:0]  q_status;
    wire [31:0] q_alpha;
    wire [31:0] q_beta;
    wire        q_busy;

    // Fixed-point to real for monitoring (Q16.16)
    real alpha_real, beta_real;

    function real fp_to_real;
        input [31:0] fp_val;
        begin
            fp_to_real = $itor(fp_val) / 65536.0;
        end
    endfunction

    always @(*) begin
        alpha_real = fp_to_real(q_alpha);
        beta_real  = fp_to_real(q_beta);
    end

    // DUT
    mips_qpu_top dut (
        .clk(clk),
        .reset(reset),
        .pc(pc),
        .instr(instr),
        .quantum_en(quantum_en),
        .q_status(q_status),
        .q_alpha(q_alpha),
        .q_beta(q_beta),
        .q_busy(q_busy)
    );

    // Clock: 100 MHz (10 ns period)
    always #5 clk = ~clk;

    initial begin
        // Waveform dump
        $dumpfile("mips_qpu.vcd");
        $dumpvars(0, tb_mips_qpu_top);

        // Init
        clk   = 0;
        reset = 1;

        #50;
        reset = 0;

        $display("Time    PC        INSTR       Q_EN  Q_STATUS  Q_BUSY   alpha      beta");
        $display("--------------------------------------------------------------------------------");

        // Run for some time to see the loop ADDI -> Q_H -> Q_CNOT -> J
        repeat (40) begin
            #50; // 50 ns between prints
            $display("%5t  %h  %h   %b     %b       %b   %8.5f  %8.5f",
                     $time, pc, instr, quantum_en, q_status, q_busy,
                     alpha_real, beta_real);
        end

        $display("\n=== MIPS+QPU SIMULATION FINISHED ===");
        $finish;
    end

endmodule
