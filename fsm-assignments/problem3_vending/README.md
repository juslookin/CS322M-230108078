# Vending Machine Mealy FSM (with Change)

A **Mealy finite state machine** implementing a vending machine for coins where the **goal price is 20**.  
Accepts coins of **5** or **10** (coin input: `01=5`, `10=10`, `00=idle`).  
When the running total reaches **20 or more**, the module pulses **`dispense`** high for **exactly one clock**.  
If the total is **25**, the module also pulses **`chg5`** high for one clock.  
After vending, the total resets to zero.  
**Reset is synchronous and active-high.**

---

# Simulation Commands
```bash
iverilog -o sim.out vending_mealy.v tb_vending_mealy.v
vvp sim.out
gtkwave dump.vcd
```

## Testbench Behaviour & Expected Results

#### Test Sequences:

1. **Insert 10, 10**  
    Total: 10 + 10 = 20  
    - **Dispense = 1** pulse (when total hits 20)

2. **Insert 5, 5, 10**  
    Total: 5 +5 + 10 = 20  
    - **Dispense = 1** pulse (when total hits 20)

3. **Insert 5, 10, 10**  
    Total: 5 + 10 + 10 = 25  
    - **Dispense = 1** pulse (when total hits/exceeds 20)
    - **chg5 = 1** pulse (when returning 5 as change)

Each pulse is **high for one clock** at the instant vending or change occurs, as required and shown in the waveform.

---