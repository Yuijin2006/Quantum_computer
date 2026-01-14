# Quantum Computer Simulator

A hardware description language (HDL) implementation of quantum computing components using Verilog, including fixed-point arithmetic, quantum gates, quantum state management, and a MIPS-based Quantum Processing Unit (QPU) controller.

## Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Modules Description](#modules-description)
- [Simulation](#simulation)
- [Contributing](#contributing)
- [License](#license)

## Overview

This project implements a quantum computer simulator in Verilog HDL, demonstrating key quantum computing concepts including:

- **Fixed-point arithmetic** for quantum state representation (Q15.16 and Q16.16 formats)
- **Quantum gates** (Hadamard, Pauli-X, Pauli-Y, Pauli-Z)
- **Quantum state management** with probability calculations
- **Bell state generation** demonstrating quantum entanglement
- **MIPS-QPU integration** allowing classical CPU to control quantum operations

The implementation uses fixed-point arithmetic to represent quantum amplitudes and probabilities, making it suitable for hardware synthesis while maintaining reasonable precision for quantum simulations.

## Project Structure

```
Quantum_computer/
├── fixed_point_floating_point_/    # Fixed-point arithmetic modules
│   ├── arithmetic_core.v            # Basic fixed-point operations
│   ├── complex_alu.v                # Complex number arithmetic
│   └── tb_arithmetic.v              # Testbenches
├── quantum_gate_and_controller/     # Single qubit quantum system
│   ├── quantum_gate.v               # Quantum gate implementations
│   ├── quantum_state.v              # Qubit state register
│   ├── quantum_controller.v         # FSM controller
│   └── tb_quantum_system.v          # System testbench
├── quantum-bell-state/              # Bell state entanglement demo
│   ├── rtl/                         # RTL source files
│   │   ├── core/                    # Core modules
│   │   ├── gates/                   # Gate implementations
│   │   └── utils/                   # Utility modules
│   └── tb/                          # Testbenches
└── mips/                            # MIPS-QPU integration
    ├── mips_qpu_top.v               # Top-level integration
    ├── mips_decoder.v               # Instruction decoder
    ├── instruction_memory.v         # Program memory
    └── tb_mips_qpu_top.v            # Integration testbench
```

## Features

### 1. Fixed-Point Arithmetic Library

- **Q15.16 and Q16.16 formats** for representing quantum amplitudes
- **Saturation arithmetic** to prevent overflow
- **Complex number multiplication** using fixed-point operations
- Support for quantum state calculations (α, β coefficients)

### 2. Quantum Gates

Implementation of fundamental quantum gates:

- **Hadamard (H)**: Creates superposition states
- **Pauli-X**: Quantum NOT gate (bit flip)
- **Pauli-Y**: Rotation around Y-axis
- **Pauli-Z**: Phase flip gate
- **CNOT**: Controlled-NOT for entanglement

### 3. Quantum State Management

- **State register** for storing qubit amplitudes (α, β)
- **Probability calculation**: P(|0⟩) = |α|², P(|1⟩) = |β|²
- **State initialization** to |0⟩
- **State update mechanism** after gate operations

### 4. Bell State Generation

Demonstrates quantum entanglement by creating Bell states:
- Circuit: H(qubit0) → CNOT(qubit0, qubit1)
- Generates maximally entangled state: |Φ+⟩ = (|00⟩ + |11⟩)/√2
- Achieves 50/50 probability distribution between |00⟩ and |11⟩

### 5. MIPS-QPU Integration

- **Classical-quantum hybrid architecture**
- **Custom COP2 instructions** for quantum operations
- **Program counter and instruction memory**
- **Decoder for quantum instruction dispatch**
- Example program creating Bell state using MIPS assembly

## Prerequisites

To build and simulate this project, you need:

- **Icarus Verilog** (iverilog) - Verilog compiler and simulator
- **GTKWave** - Waveform viewer (optional, for visualization)
- **Make** - Build automation tool (optional)

### Installation on Ubuntu/Debian:

```bash
sudo apt-get update
sudo apt-get install iverilog gtkwave
```

### Installation on macOS:

```bash
brew install icarus-verilog gtkwave
```

### Installation on Windows:

Download and install from:
- Icarus Verilog: https://bleez.sourceforge.net/ or https://github.com/steveicarus/iverilog
- GTKWave: https://gtkwave.sourceforge.net/

## Installation

Clone the repository:

```bash
git clone https://github.com/Yuijin2006/Quantum_computer.git
cd Quantum_computer
```

## Usage

### Running Individual Testbenches

#### 1. Fixed-Point Arithmetic Test

```bash
cd fixed_point_floating_point_
iverilog -o tb_arithmetic.vvp tb_arithmetic.v arithmetic_core.v complex_alu.v
vvp tb_arithmetic.vvp
gtkwave wave.vcd  # View waveforms (optional)
```

#### 2. Quantum System Test (Single Qubit)

```bash
cd quantum_gate_and_controller
iverilog -o tb_quantum_system.vvp tb_quantum_system.v quantum_gate.v quantum_state.v quantum_controller.v fixed_point_mult.v
vvp tb_quantum_system.vvp
gtkwave quantum_system.vcd  # View waveforms (optional)
```

#### 3. Bell State Entanglement Test

```bash
cd quantum-bell-state
chmod +x sim/run_sim.sh
./sim/run_sim.sh
# Or manually:
cd tb
iverilog -o bell_sim -I../rtl/core -I../rtl/gates -I../rtl/utils tb_bell_state.v \
    ../rtl/core/quantum_circuit.v ../rtl/core/qubit_register.v \
    ../rtl/gates/hadamard_gate.v ../rtl/gates/cnot_gate.v \
    ../rtl/utils/fixed_point_add.v ../rtl/utils/fixed_point_mult.v
vvp bell_sim
cat bell_state_result.txt  # View results
```

Expected output shows Bell state |Φ+⟩ with:
- |00⟩ ≈ 0.707, |11⟩ ≈ 0.707
- P(|00⟩) = 50%, P(|11⟩) = 50%

#### 4. MIPS-QPU Integration Test

```bash
cd mips
iverilog -o tb_mips_qpu_top.vvp tb_mips_qpu_top.v mips_qpu_top.v mips_decoder.v \
    instruction_memory.v program_counter.v \
    ../quantum_gate_and_controller/quantum_controller.v \
    ../quantum_gate_and_controller/quantum_state.v \
    ../quantum_gate_and_controller/quantum_gate.v \
    ../quantum_gate_and_controller/fixed_point_mult.v
vvp tb_mips_qpu_top.vvp
gtkwave mips_qpu.vcd  # View waveforms (optional)
```

## Modules Description

### Fixed-Point Arithmetic (`fixed_point_floating_point_/`)

#### `arithmetic_core.v`

Contains fundamental fixed-point operations:

- **`fixed_point_add`**: Adds two Q15.16 numbers with saturation on overflow
- **`fixed_point_mult`**: Multiplies two Q15.16 numbers, shifts back to Q15.16 format with saturation

#### `complex_alu.v`

- **`complex_mult`**: Multiplies two complex numbers (ar + i·ai) × (br + i·bi)
  - Uses 4× `fixed_point_mult` and 2× `fixed_point_add`
  - Essential for quantum gate operations on qubit amplitudes

### Quantum System (`quantum_gate_and_controller/`)

#### `quantum_gate.v`

Implements quantum gates operating on single qubit (α, β in Q16.16 format):

- **Hadamard (H)**: α' = (α+β)/√2, β' = (α-β)/√2
- **Pauli-X**: Swaps α and β
- **Pauli-Z**: Flips sign of β
- **Pauli-Y**: Combination of X and Z (simplified, phase ignored)

#### `quantum_state.v`

Qubit state register module:

- Stores current state (α_out, β_out)
- Resets to |0⟩ state (α=1, β=0)
- Updates state when `update_en=1`
- Calculates measurement probabilities: P(|0⟩)=|α|², P(|1⟩)=|β|²

#### `quantum_controller.v`

Finite State Machine (FSM) controller:

- Receives `cmd_gate` (gate selection) and `cmd_execute` (trigger)
- Executes gate operation with configurable `GATE_DELAY`
- Outputs status signals: `idle`, `busy`, `done`
- Provides `display_alpha` and `display_beta` for monitoring

### Bell State System (`quantum-bell-state/`)

#### `quantum_circuit.v`

Top-level module implementing Bell state creation:

1. Initialize to |00⟩
2. Apply Hadamard to qubit 0: (|00⟩ + |10⟩)/√2
3. Apply CNOT(0→1): (|00⟩ + |11⟩)/√2

#### `hadamard_gate.v` & `cnot_gate.v`

Gate implementations for 2-qubit system with fixed-point arithmetic.

### MIPS Integration (`mips/`)

#### `mips_qpu_top.v`

Integrates classical MIPS processor with quantum controller:

- Fetches instructions from memory
- Decodes opcodes (standard MIPS + COP2 quantum)
- Routes quantum instructions to QPU
- Manages program counter and control flow

#### `mips_decoder.v`

Instruction decoder with quantum extension:

- Standard MIPS: R-type, ADDI, JUMP
- **COP2 (opcode 010010)**: Quantum instructions
  - Sets `quantum_en=1` to activate QPU
  - Disables register/memory writes during quantum operations

#### `instruction_memory.v`

ROM containing example program:

```assembly
ADDI $t0, $0, 5      # Classical initialization
Q_H $1               # Hadamard on qubit 1
Q_CNOT $1, $2        # CNOT: control=Q1, target=Q2
J loop               # Jump back (infinite loop)
```

## Simulation

All testbenches generate `.vcd` (Value Change Dump) files that can be viewed with GTKWave:

```bash
gtkwave <filename>.vcd
```

### Key Signals to Monitor:

**For quantum_system.vcd:**
- `alpha_real`, `beta_real`: Real-valued qubit amplitudes
- `prob_0`, `prob_1`: Measurement probabilities
- `status`: Controller state (idle/busy/done)

**For bell_state.vcd:**
- `state_00`, `state_01`, `state_10`, `state_11`: All basis state amplitudes
- `prob_00`, `prob_11`: Measurement probabilities
- `state`: FSM state (IDLE/APPLY_H/APPLY_CNOT/DONE)

**For mips_qpu.vcd:**
- `pc`: Program counter
- `instr`: Current instruction
- `quantum_en`: QPU activation signal
- `q_alpha`, `q_beta`: Quantum state

## Technical Details

### Fixed-Point Format

- **Q15.16**: 1 sign bit + 15 integer bits + 16 fractional bits (used in arithmetic core)
- **Q16.16**: 1 sign bit + 15 integer bits + 16 fractional bits (used in quantum gates)
- Range: approximately -32768 to +32767.999...
- Precision: ~0.0000152 (1/65536)

### Quantum State Representation

A single qubit is represented as: |ψ⟩ = α|0⟩ + β|1⟩

Where:
- α, β are complex amplitudes (simplified to real numbers in this implementation)
- Normalization: |α|² + |β|² = 1
- α, β stored in Q16.16 fixed-point format

### Gate Delay

The `GATE_DELAY` parameter in `quantum_controller.v` simulates realistic gate execution time, useful for:
- Modeling physical quantum computers
- Testing timing-sensitive control logic
- Educational demonstrations

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

### Development Guidelines:

1. Follow existing coding style and naming conventions
2. Add testbenches for new modules
3. Test with Icarus Verilog before submitting
4. Document complex algorithms and fixed-point calculations
5. Update this README for significant changes

## License

This project is available for educational purposes. Please check with the repository owner for specific licensing terms.

## Acknowledgments

This project demonstrates fundamental quantum computing concepts using hardware description languages, suitable for:

- Digital design courses
- Quantum computing education
- FPGA implementation projects
- Computer architecture research

## References

- Nielsen & Chuang, "Quantum Computation and Quantum Information"
- Fixed-point arithmetic in HDL design
- MIPS architecture and instruction set
- Verilog HDL synthesis and simulation

---

**Note**: This is a simulation/educational implementation. For actual quantum computing applications, consider using established frameworks like Qiskit, Cirq, or Q# that interface with real quantum hardware.
