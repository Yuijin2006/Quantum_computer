/*******************************************************************************
* Testbench: tb_bell_state
* Description:  Complete Bell state |Φ+⟩ creation test with logging
* 
* Circuit: H(0) → CNOT(0,1)
* Expected: |Φ+⟩ = (|00⟩ + |11⟩)/√2
*******************************************************************************/

`timescale 1ns/1ps

module tb_bell_state;

    // Clock and reset
    reg clk;
    reg rst_n;
    reg start;
    
    // DUT outputs
    wire done;
    wire [1:0] state;
    wire signed [31:0] state_00, state_01, state_10, state_11;
    wire signed [31:0] prob_00, prob_11;
    
    // File handle
    integer log_file;
    
    // Conversion function
    function real fp_to_real;
        input [31:0] fp;
        fp_to_real = $itor($signed(fp)) / 65536.0;
    endfunction
    
    // DUT instantiation
    quantum_circuit dut (
        . clk(clk),
        .rst_n(rst_n),
        .start(start),
        .done(done),
        .state(state),
        .state_00(state_00),
        .state_01(state_01),
        .state_10(state_10),
        .state_11(state_11),
        .prob_00(prob_00),
        .prob_11(prob_11)
    );
    
    // Clock generation (10ns period = 100MHz)
    always #5 clk = ~clk;
    
    // Test sequence
    initial begin
        // Initialize
        clk = 0;
        rst_n = 0;
        start = 0;
        
        // Open log file
        log_file = $fopen("bell_state_result.txt", "w");
        if (log_file == 0) begin
            $display("ERROR: Cannot open log file!");
            $finish;
        end
        
        // VCD dump
        $dumpfile("bell_state. vcd");
        $dumpvars(0, tb_bell_state);
        
        // Write header
        $fwrite(log_file, "================================================================================\n");
        $fwrite(log_file, "           BELL STATE ENTANGLEMENT TEST - H(0) → CNOT(0,1)\n");
        $fwrite(log_file, "================================================================================\n");
        $fwrite(log_file, "Target State: |Φ+⟩ = (|00⟩ + |11⟩)/√2\n");
        $fwrite(log_file, "Expected:  |00⟩ ≈ 0.707, |11⟩ ≈ 0.707, |01⟩ = 0, |10⟩ = 0\n");
        $fwrite(log_file, "================================================================================\n\n");
        
        $display("================================================================================");
        $display("           BELL STATE ENTANGLEMENT TEST - H(0) → CNOT(0,1)");
        $display("================================================================================");
        $display("Target State: |Φ+⟩ = (|00⟩ + |11⟩)/√2");
        $display("Expected: |00⟩ ≈ 0.707, |11⟩ ≈ 0.707, |01⟩ = 0, |10⟩ = 0");
        $display("================================================================================\n");
        
        // Reset
        #20 rst_n = 1;
        #20;
        
        // Log initial state
        $fwrite(log_file, "INITIAL STATE (|00⟩):\n");
        $fwrite(log_file, "  |00⟩ = %. 6f\n", fp_to_real(state_00));
        $fwrite(log_file, "  |01⟩ = %.6f\n", fp_to_real(state_01));
        $fwrite(log_file, "  |10⟩ = %.6f\n", fp_to_real(state_10));
        $fwrite(log_file, "  |11⟩ = %. 6f\n\n", fp_to_real(state_11));
        
        $display("INITIAL STATE (|00⟩):");
        $display("  |00⟩ = %. 6f", fp_to_real(state_00));
        $display("  |01⟩ = %. 6f", fp_to_real(state_01));
        $display("  |10⟩ = %.6f", fp_to_real(state_10));
        $display("  |11⟩ = %.6f\n", fp_to_real(state_11));
        
        // Start circuit
        start = 1;
        #10 start = 0;
        
        // Monitor state transitions
        $fwrite(log_file, "EXECUTION LOG:\n");
        $fwrite(log_file, "Time(ns)  State      |00⟩       |01⟩       |10⟩       |11⟩\n");
        $fwrite(log_file, "----------------------------------------------------------------\n");
        
        $display("EXECUTION LOG:");
        $display("Time(ns)  State      |00⟩       |01⟩       |10⟩       |11⟩");
        $display("----------------------------------------------------------------");
        
        // Wait for completion
        while (! done) begin
            @(posedge clk);
            #1;
            $fwrite(log_file, "%7t   ", $time);
            case (state)
                2'b00: $fwrite(log_file, "IDLE     ");
                2'b01: $fwrite(log_file, "APPLY_H  ");
                2'b10: $fwrite(log_file, "APPLY_CNOT");
                2'b11: $fwrite(log_file, "DONE     ");
            endcase
            $fwrite(log_file, " %. 6f  %. 6f  %.6f  %. 6f\n",
                    fp_to_real(state_00), fp_to_real(state_01),
                    fp_to_real(state_10), fp_to_real(state_11));
            
            if ($time % 20 == 0) begin
                $display("%7t   ", $time, $sformatf("%s", 
                         (state == 2'b00) ? "IDLE     " :
                         (state == 2'b01) ? "APPLY_H  " : 
                         (state == 2'b10) ? "APPLY_CNOT" :  "DONE     "),
                         " %. 6f  %.6f  %. 6f  %.6f",
                         fp_to_real(state_00), fp_to_real(state_01),
                         fp_to_real(state_10), fp_to_real(state_11));
            end
        end
        
        // Wait a bit more
        repeat (5) @(posedge clk);
        
        // Final results
        $fwrite(log_file, "\n================================================================================\n");
        $fwrite(log_file, "                              FINAL RESULTS\n");
        $fwrite(log_file, "================================================================================\n");
        $fwrite(log_file, "State Amplitudes:\n");
        $fwrite(log_file, "  |00⟩ = %.6f\n", fp_to_real(state_00));
        $fwrite(log_file, "  |01⟩ = %.6f\n", fp_to_real(state_01));
        $fwrite(log_file, "  |10⟩ = %. 6f\n", fp_to_real(state_10));
        $fwrite(log_file, "  |11⟩ = %.6f\n\n", fp_to_real(state_11));
        
        $fwrite(log_file, "Measurement Probabilities:\n");
        $fwrite(log_file, "  P(|00⟩) = %.6f  (%.2f%%)\n", 
                fp_to_real(prob_00), fp_to_real(prob_00)*100);
        $fwrite(log_file, "  P(|11⟩) = %.6f  (%.2f%%)\n",
                fp_to_real(prob_11), fp_to_real(prob_11)*100);
        $fwrite(log_file, "  Total   = %.6f  (%.2f%%)\n\n",
                fp_to_real(prob_00) + fp_to_real(prob_11),
                (fp_to_real(prob_00) + fp_to_real(prob_11))*100);
        
        $display("\n================================================================================");
        $display("                              FINAL RESULTS");
        $display("================================================================================");
        $display("State Amplitudes:");
        $display("  |00⟩ = %.6f", fp_to_real(state_00));
        $display("  |01⟩ = %.6f", fp_to_real(state_01));
        $display("  |10⟩ = %.6f", fp_to_real(state_10));
        $display("  |11⟩ = %.6f\n", fp_to_real(state_11));
        
        $display("Measurement Probabilities:");
        $display("  P(|00⟩) = %.6f  (%.2f%%)", 
                fp_to_real(prob_00), fp_to_real(prob_00)*100);
        $display("  P(|11⟩) = %.6f  (%.2f%%)",
                fp_to_real(prob_11), fp_to_real(prob_11)*100);
        $display("  Total   = %.6f  (%. 2f%%)\n",
                fp_to_real(prob_00) + fp_to_real(prob_11),
                (fp_to_real(prob_00) + fp_to_real(prob_11))*100);
        
        // Verify Bell state
        if ((fp_to_real(state_00) >= 0.70 && fp_to_real(state_00) <= 0.72) &&
            (fp_to_real(state_11) >= 0.70 && fp_to_real(state_11) <= 0.72) &&
            (fp_to_real(state_01) < 0.01 && fp_to_real(state_10) < 0.01)) begin
            $fwrite(log_file, "✓ SUCCESS: Bell state |Φ+⟩ achieved!\n");
            $fwrite(log_file, "  Qubits are now in maximally entangled state.\n");
            $display("✓ SUCCESS: Bell state |Φ+⟩ achieved!");
            $display("  Qubits are now in maximally entangled state.");
        end else begin
            $fwrite(log_file, "✗ FAILED: Bell state not achieved.\n");
            $fwrite(log_file, "  Expected: |00⟩≈0.707, |11⟩≈0.707, |01⟩≈0, |10⟩≈0\n");
            $display("✗ FAILED: Bell state not achieved.");
            $display("  Expected: |00⟩≈0.707, |11⟩≈0.707, |01⟩≈0, |10⟩≈0");
        end
        
        $fwrite(log_file, "================================================================================\n");
        $display("================================================================================");
        $display("Log saved to:  bell_state_result.txt");
        $display("Waveform saved to: bell_state.vcd\n");
        
        $fclose(log_file);
        $finish;
    end
    
    // Timeout protection
    initial begin
        #10000;
        $display("\nERROR: Simulation timeout!");
        $fwrite(log_file, "\nERROR: Simulation timeout!\n");
        $fclose(log_file);
        $finish;
    end

endmodule