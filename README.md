# 🌌 Quantum Computer Simulator

> **Mô phỏng máy tính lượng tử bằng Verilog HDL** – kết hợp giữa kiến trúc phần cứng cổ điển và các khái niệm điện toán lượng tử hiện đại.

---

## 📑 Mục lục

* [📘 Giới thiệu](#-giới-thiệu)
* [📂 Cấu trúc dự án](#-cấu-trúc-dự-án)
* [✨ Tính năng chính](#-tính-năng-chính)
* [🧰 Yêu cầu hệ thống](#-yêu-cầu-hệ-thống)
* [⬇️ Cài đặt](#️-cài-đặt)
* [🚀 Hướng dẫn sử dụng](#-hướng-dẫn-sử-dụng)
* [🧩 Mô tả các module](#-mô-tả-các-module)
* [🧪 Mô phỏng & Kiểm thử](#-mô-phỏng--kiểm-thử)
* [⚙️ Chi tiết kỹ thuật](#️-chi-tiết-kỹ-thuật)
* [🤝 Đóng góp](#-đóng-góp)
* [📜 Giấy phép](#-giấy-phép)
* [📚 Tài liệu tham khảo](#-tài-liệu-tham-khảo)

---

## 📘 Giới thiệu

Dự án **Quantum Computer Simulator** là một hệ thống mô phỏng máy tính lượng tử được xây dựng hoàn toàn bằng **Verilog HDL**, nhằm minh họa cách các khái niệm điện toán lượng tử có thể được hiện thực hóa ở mức **phần cứng số**.

🎯 Mục tiêu chính:

* Kết hợp **CPU cổ điển (MIPS)** với **QPU (Quantum Processing Unit)**
* Mô phỏng **cổng lượng tử**, **trạng thái qubit**, và **hiện tượng vướng víu lượng tử (entanglement)**
* Sử dụng **số học cố định (fixed-point)** để phù hợp cho tổng hợp phần cứng (FPGA/ASIC)

---

## 📂 Cấu trúc dự án

```text
Quantum_computer/
├── fixed_point_floating_point_/    # Thư viện số học fixed-point
│   ├── arithmetic_core.v
│   ├── complex_alu.v
│   └── tb_arithmetic.v
├── quantum_gate_and_controller/     # Hệ thống 1 qubit
│   ├── quantum_gate.v
│   ├── quantum_state.v
│   ├── quantum_controller.v
│   └── tb_quantum_system.v
├── quantum-bell-state/              # Demo trạng thái Bell (2 qubit)
│   ├── rtl/
│   │   ├── core/
│   │   ├── gates/
│   │   └── utils/
│   └── tb/
└── mips/                            # Tích hợp MIPS + QPU
    ├── mips_qpu_top.v
    ├── mips_decoder.v
    ├── instruction_memory.v
    └── tb_mips_qpu_top.v
```

---

## ✨ Tính năng chính

### 🔢 1. Thư viện số học Fixed-Point

* Định dạng **Q15.16** và **Q16.16** (32-bit)
* Có **saturation** chống tràn số
* Hỗ trợ **số phức** cho biên độ lượng tử

---

### 🧠 2. Các cổng lượng tử

| Cổng            | Mô tả                     |
| --------------- | ------------------------- |
| 🌀 Hadamard (H) | Tạo trạng thái chồng chập |
| 🔁 Pauli-X      | Quantum NOT               |
| 🎭 Pauli-Y      | X + Z (bỏ qua pha)        |
| 🔷 Pauli-Z      | Đảo pha                   |
| 🔗 CNOT         | Tạo vướng víu lượng tử    |

---

### 📊 3. Quản lý trạng thái lượng tử

* Lưu trữ biên độ **α, β** của qubit
* Tính xác suất đo:

  * P(|0⟩) = |α|²
  * P(|1⟩) = |β|²
* Reset mặc định về trạng thái |0⟩

---

### 🔗 4. Tạo trạng thái Bell (Entanglement)

⚛️ Mạch lượng tử:

```
H(q0) → CNOT(q0, q1)
```

📌 Kết quả:

* |Φ⁺⟩ = (|00⟩ + |11⟩) / √2
* Xác suất:

  * P(|00⟩) ≈ 50%
  * P(|11⟩) ≈ 50%

---

### 🖥️ 5. Tích hợp MIPS – QPU

* Kiến trúc **lai cổ điển – lượng tử**
* Sử dụng **COP2 instruction** cho lệnh lượng tử
* CPU MIPS điều khiển QPU thông qua decoder

---

## 🧰 Yêu cầu hệ thống

🔧 Phần mềm cần thiết:

* **Icarus Verilog (iverilog)** – trình biên dịch & mô phỏng
* **GTKWave** – xem waveform (khuyến nghị)
* **Make** – tùy chọn

### 🐧 Ubuntu / Debian

```bash
sudo apt update
sudo apt install iverilog gtkwave
```

### 🍎 macOS

```bash
brew install icarus-verilog gtkwave
```

---

## ⬇️ Cài đặt

```bash
git clone https://github.com/Yuijin2006/Quantum_computer.git
cd Quantum_computer
```

---

## 🚀 Hướng dẫn sử dụng

### ▶️ Test Fixed-Point

```bash
cd fixed_point_floating_point_
iverilog -o tb_arithmetic.vvp tb_arithmetic.v arithmetic_core.v complex_alu.v
vvp tb_arithmetic.vvp
gtkwave wave.vcd
```

---

### ▶️ Test hệ thống 1 qubit

```bash
cd quantum_gate_and_controller
iverilog -o tb_quantum_system.vvp tb_quantum_system.v quantum_gate.v quantum_state.v quantum_controller.v fixed_point_mult.v
vvp tb_quantum_system.vvp
gtkwave quantum_system.vcd
```

---

### ▶️ Test trạng thái Bell

```bash
cd quantum-bell-state
chmod +x sim/run_sim.sh
./sim/run_sim.sh
```

📈 Kết quả mong đợi:

* |00⟩ ≈ 0.707
* |11⟩ ≈ 0.707

---

### ▶️ Test MIPS – QPU

```bash
cd mips
iverilog -o tb_mips_qpu_top.vvp tb_mips_qpu_top.v mips_qpu_top.v mips_decoder.v instruction_memory.v program_counter.v \
../quantum_gate_and_controller/quantum_controller.v \
../quantum_gate_and_controller/quantum_state.v \
../quantum_gate_and_controller/quantum_gate.v \
../quantum_gate_and_controller/fixed_point_mult.v
vvp tb_mips_qpu_top.vvp
gtkwave mips_qpu.vcd
```

---

## ⚙️ Chi tiết kỹ thuật

### 🔢 Fixed-Point Q16.16

* 32-bit signed
* 16 bit phần thập phân
* 1.0 = `0x00010000`
* Độ chính xác ≈ 1 / 65536

---

### ⚛️ Biểu diễn qubit

|ψ⟩ = α|0⟩ + β|1⟩

* α, β: số thực fixed-point
* Chuẩn hóa: |α|² + |β|² = 1

---

## 🤝 Đóng góp

💡 Mọi đóng góp đều được hoan nghênh:

1. Tuân thủ coding style hiện có
2. Viết testbench cho module mới
3. Test bằng Icarus Verilog
4. Cập nhật README khi thay đổi lớn

---

## 📜 Giấy phép

📌 Dự án phục vụ **mục đích học tập & nghiên cứu**.

Vui lòng liên hệ tác giả repository để biết chi tiết giấy phép.

---

## 📚 Tài liệu tham khảo

* Nielsen & Chuang – *Quantum Computation and Quantum Information*
* Verilog HDL & Fixed-point arithmetic
* Kiến trúc MIPS
* Giáo trình Thiết kế Hệ thống số

---

