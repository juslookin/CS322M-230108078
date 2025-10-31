# RVX10-P: A 5-Stage Pipelined RISC-V Core

A high-performance, 5-stage pipelined processor for the **RISC-V (RV32I)** instruction set. This core includes the full base integer instruction set and is extended with **10 custom RVX10 instructions** for advanced bitwise and arithmetic operations.

---

## ⚙️ Core Design & Features

This processor implements a classic 5-stage RISC pipeline (IF, ID, EX, MEM, WB) with full support for hazard detection and data forwarding.

### 1. Pipeline Architecture
* **Classic 5-Stage Design:** Instruction Fetch (IF) $\rightarrow$ Instruction Decode (ID) $\rightarrow$ Execute (EX) $\rightarrow$ Memory Access (MEM) $\rightarrow$ Write Back (WB).
* **RISC-V RV32I ISA:** Implements the 32-bit base integer instruction set.
* **Register File:** Contains 32 general-purpose 32-bit registers (x0-x31), with `x0` hardwired to zero.
* **Harvard Architecture:** Uses separate, dedicated memories for instructions and data.

### 2. Hazard & Forwarding Unit
* **Full Data Forwarding:** Implements comprehensive forwarding logic to minimize data hazards. Results are forwarded from the EX/MEM and MEM/WB pipeline registers directly to the Execute stage.
* **Load-Use Hazard Detection:** The pipeline automatically inserts a 1-cycle stall (bubble) when a load instruction (`lw`) is immediately followed by an instruction that uses the destination register.
* **Store Data Forwarding:** Ensures correct data is written to memory during back-to-back store operations.
* **Branch Handling:** Uses a static **predict-not-taken** strategy. Taken branches or jumps (like `jal`, `jalr`, `beq`) incur a 1-cycle penalty and flush the pipeline stages (IF, ID, EX).

### 3. Custom Extensions (RVX10)
Ten new ALU operations are added using the RISC-V `CUSTOM-0` opcode:
* **Bitwise:** `andn` (AND-NOT), `orn` (OR-NOT), `xnor`
* **Rotation:** `rol` (Rotate Left), `ror` (Rotate Right)
* **Comparison:** `min` (Min Signed), `max` (Max Signed), `minu` (Min Unsigned), `maxu` (Max Unsigned)
* **Arithmetic:** `abs` (Absolute Value)

## 📊 Performance Metrics

* **Average CPI:** **1.2 - 1.3** on typical test programs.
* **Pipeline Efficiency:** **~77-83%** (including stalls and flushes).
* **Target Clock:** ~500 MHz (2ns period).
* **Peak Throughput:** ~400 MIPS.

## 📁 Project File Structure

The repository is organized into source, testbench, and documentation folders.

```
rvx10_P/
├── src/
│   ├── datapath.sv           # Main pipeline datapath
│   ├── riscvpipeline.sv      # Top-level wrapper
│   ├── controller.sv         # Instruction decoder
│   ├── forwarding_unit.sv    # Data forwarding logic
│   └── hazard_unit.sv        # Load-use hazard detection
├── tb/
│   ├── tb_pipeline.sv        # Basic testbench
│   └── tb_pipeline_hazard.sv # Comprehensive hazard tests
├── tests/
│   ├── rvx10_pipeline.hex    # Basic functionality test
│   └── rvx10_hazard_test.hex # Hazard stress test
├── docs/
│   └── REPORT.md             # Detailed design documentation
└── README.md                 # This file
```

---

## 🛠️ Getting Started

### Prerequisites

- **Icarus Verilog** (iverilog) - Open-source Verilog simulator
- **GTKWave** (optional) - Waveform viewer
- **Make** (optional) - Build automation

**Installation (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install iverilog gtkwave
```

**Installation (macOS):**
```bash
brew install icarus-verilog gtkwave
```

### Quick Start

**1. Clone the repository:**
```bash
git clone https://github.com/yourusername/rvx10_P.git
cd rvx10_P
```

**2. Compile the design:**
```bash
iverilog -g2012 -o pipeline_tb src/*.sv tb/tb_pipeline.sv
```

**3. Run simulation:**
```bash
vvp pipeline_tb
```

**4. Expected output:**
```
STORE @ 96 = 0x00000000 (t=55000)
WB stage: Writing 5 to x10  t=75000
WB stage: Writing 3 to x11  t=85000
...
RVX10 EX stage: ALU result = 4 -> x5  t=105000
FORWARDING: EX-to-EX detected for x5 at t=120000
...
STORE @ 100 = 0x00000019 (t=325000)
Simulation succeeded
CHECKSUM (x28) = 25 (0x00000019)

========== PIPELINE PERFORMANCE SUMMARY ==========
Total cycles:        30
Instructions retired: 25
Stall cycles:        0
Flush cycles:        0
Average CPI:         1.20
Pipeline efficiency: 83.3%
==================================================
```

---

## 🧪 Running Tests

### Basic Functionality Test

Tests core pipeline operation and RVX10 instructions:

```bash
iverilog -g2012 -o pipeline_tb src/*.sv tb/tb_pipeline.sv
vvp pipeline_tb
```

**Test program:** `tests/rvx10_pipeline.hex`

**Expected metrics:**
```
Load-use stalls:    3
Forwarding events:  18
Total stores:       8
Average CPI:        1.35
```

### Generate Waveforms

```bash
iverilog -g2012 -o pipeline_tb src/*.sv tb/tb_pipeline.sv
vvp pipeline_tb -vcd
gtkwave dump.vcd
```

RVX10-P: A Five-Stage Pipelined RISC-V Core supporting RV32I + 10 Custom
ALU Instructions, developed under the course Digital Logic and Computer
Architecture taught by Dr. Satyajit Das, IIT Guwahati.

---
