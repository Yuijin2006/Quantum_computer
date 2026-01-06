`timescale 1ns/1ps

module tb_quantum_system;

    // ==================== LOG FILE ====================
    integer logfile;

    // ==================== TEST SIGNALS ====================
    reg clk;
    reg reset;
    
    reg [2:0] cmd_gate;
    reg cmd_execute;
    
    wire [1:0] status;
    wire [31:0] display_alpha;
    wire [31:0] display_beta;
    wire gate_busy;
    
    // ==================== REAL VALUES ====================
    real alpha_real, beta_real;
    real prob0_real, prob1_real;
    
    // Q16.16 -> real
    function real fp_to_real;
        input [31:0] fp_val;
        begin
            fp_to_real = $itor(fp_val) / 65536.0;
        end
    endfunction
    
    always @(*) begin
        alpha_real = fp_to_real(display_alpha);
        beta_real  = fp_to_real(display_beta);
        prob0_real = alpha_real * alpha_real;
        prob1_real = beta_real * beta_real;
    end
    
    // ==================== STATE NAME ====================
    function [90:0] get_state_name;
        input [31:0] alpha, beta;
        real a, b;
        begin
            a = fp_to_real(alpha);
            b = fp_to_real(beta);
            
            if (a > 0.99 && b < 0.01) get_state_name = "|0>";
            else if (a < 0.01 && b > 0.99) get_state_name = "|1>";
            else if (a > 0.707 && a < 0.708 && b > 0.707 && b < 0.708) 
                get_state_name = "|+> (H|0>)";
            else if (a > 0.707 && a < 0.708 && b < -0.707 && b > -0.708)
                get_state_name = "|-> (H|1>)";
            else 
                get_state_name = "Superposition";
        end
    endfunction
    
    // ==================== DUT ====================
    quantum_controller dut (
        .clk(clk),
        .reset(reset),
        .cmd_gate(cmd_gate),
        .cmd_execute(cmd_execute),
        .status(status),
        .display_alpha(display_alpha),
        .display_beta(display_beta),
        .gate_busy(gate_busy)
    );
    
    // ==================== CLOCK ====================
    always #5 clk = ~clk; // 100MHz
    
    // ==================== APPLY GATE TASK ====================
    task apply_gate;
        input [2:0] gate_code;
        input [79:0] gate_name;
        begin
            while (gate_busy) #10;
            
            cmd_gate = gate_code;
            #10;
            cmd_execute = 1;
            #10;
            cmd_execute = 0;

            $display("  [APPLY] %s at time %t ns", gate_name, $time);
            
            #1100;
            
            $display("    -> alpha = %8.6f, beta = %8.6f", alpha_real, beta_real);
            $display("    -> state = %s", get_state_name(display_alpha, display_beta));
            $display("    -> P(|0>) = %6.2f%%, P(|1>) = %6.2f%%\n",
                     prob0_real*100, prob1_real*100);

            // ===== LOG FILE =====
            $fdisplay(logfile, "TIME = %0t ns", $time);
            $fdisplay(logfile, "Gate Executed: %s", gate_name);
            $fdisplay(logfile, "|psi> = [ %8.6f , %8.6f ]", alpha_real, beta_real);
            $fdisplay(logfile, "P(|0>) = %6.2f%%   P(|1>) = %6.2f%%",
                      prob0_real*100, prob1_real*100);
            $fdisplay(logfile, "-------------------------------------------");
        end
    endtask
    
    // ==================== MAIN TEST ====================
    initial begin
        
        // === OPEN LOG FILE ===
        logfile = $fopen("quantum_log.txt", "w");
        $fdisplay(logfile, "===== QUANTUM SIMULATION LOG =====\n");

        // === WAVEFORM ===
        $dumpfile("quantum_system.vcd");
        $dumpvars(0, tb_quantum_system);
        
        clk = 0;
        reset = 1;
        cmd_gate = 3'b000;
        cmd_execute = 0;
        
        #100 reset = 0;
        
        $display("\n==========================================");
        $display("   QUANTUM CONTROLLER SIMULATION");
        $display("==========================================\n");
        
        $display("Initial state after reset:");
        $display("  alpha = %8.6f, beta = %8.6f\n", alpha_real, beta_real);
        
        // ===== TEST 1 =====
        $display("=== TEST 1: BASIC GATE SEQUENCE ===");
        apply_gate(3'b001, "Hadamard (H)");
        apply_gate(3'b010, "Pauli-X (X)");
        apply_gate(3'b001, "Hadamard (H)");
        apply_gate(3'b010, "Pauli-X (X)");
        apply_gate(3'b001, "Hadamard (H)");
        
        // ===== TEST 2 =====
        $display("\n=== TEST 2: Z GATE EFFECT ===");
        apply_gate(3'b001, "Hadamard (H)");
        apply_gate(3'b001, "Hadamard (H)");
        apply_gate(3'b001, "Hadamard (H)");
        apply_gate(3'b010, "Pauli-X (X)");
        apply_gate(3'b001, "Hadamard (H)");
        apply_gate(3'b011, "Pauli-Z (Z)");
        
        // ===== TEST 3 =====
        $display("\n=== TEST 3: Y GATE ===");
        reset = 1;
        #100 reset = 0;
        apply_gate(3'b100, "Pauli-Y (Y)");
        
        // ===== TEST 4 =====
        $display("\n=== TEST 4: GATE CHAINING ===");
        reset = 1;
        #100 reset = 0;
        apply_gate(3'b001, "H");
        apply_gate(3'b011, "Z");
        apply_gate(3'b001, "H");

        // Finish
        $display("\n=== SIMULATION COMPLETE ===");
        $display("Total simulation time: %t ns", $time);

        $fdisplay(logfile, "\n===== SIMULATION FINISHED =====");
        $fclose(logfile);

        $finish;
    end
    
    // ==================== MONITOR ====================
    initial begin
        #10;
        $monitor("Time %t ns | status=%b | alpha=%8.6f | beta=%8.6f", 
                 $time, status, alpha_real, beta_real);
    end
    
endmodule
