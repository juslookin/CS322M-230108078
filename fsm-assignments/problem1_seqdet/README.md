# 1101 Mealy Sequence Detector

A **Mealy FSM** that detects the serial bit pattern **`1101`** on a **1-bit-per-clock** input (`din`), with **overlap allowed**.  
When the last `1` of `1101` arrives, the module pulses **`y`** high for **exactly one clock**.

---

# Sequence Detector 1101 (Mealy FSM, Overlap) 
- *FSM type*: Mealy  
- *Reset*: synchronous, active-high  
- **Output y**: 1-cycle pulse when the final 1 of 1101 arrives  

---



# Sequence Detector 1101 (Mealy FSM, Overlap)

## Tested stream
- din(input given in testbench)=   11011011101
- y(expected)  =                   00010010001
  
<img width="1472" height="126" alt="image" src="https://github.com/user-attachments/assets/6f3bef6e-6948-4ae9-a121-91e6ca544207" />

- Dectected at cycle 4, 6, 10 as expected.




## Simulation Commands
```bash
iverilog -o sim.out seq_det_mealy.v tb_seq_detect_mealy.v
vvp sim.out
gtkwave dump.vcd
