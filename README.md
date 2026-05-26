# FIFO Verification Project

## Overview
This project implements a SystemVerilog-based verification environment for verifying the functionality of a synchronous FIFO (First-In First-Out) design.

The verification environment is developed using:
- Transaction Class
- Generator
- Driver
- Monitor
- Scoreboard
- Mailbox Communication
- Event Synchronization

The testbench performs randomized write and read operations to validate FIFO behavior under different conditions.

---

# Features

- Randomized FIFO write data generation
- FIFO write operation until FULL condition
- FIFO read operation until EMPTY condition
- Mailbox-based communication between components
- Event-based synchronization
- Functional transaction monitoring
- Scoreboard logging for write/read verification
- Waveform dumping using VCD

---

# Verification Environment Architecture

```text
                 +----------------+
                 |   Generator    |
                 +----------------+
                          |
                       Mailbox
                          |
                          v
                 +----------------+
                 |     Driver     |
                 +----------------+
                          |
                    Virtual Interface
                          |
                          v
                 +----------------+
                 |    FIFO DUT    |
                 +----------------+
                          |
                          v
                 +----------------+
                 |    Monitor     |
                 +----------------+
                          |
                       Mailbox
                          |
                          v
                 +----------------+
                 |   Scoreboard   |
                 +----------------+
```

---

# Components Description

## 1. Transaction Class

The transaction class defines all signals required for FIFO communication.

### Signals Used

| Signal | Description |
|--------|-------------|
| `rst` | Reset signal |
| `clk` | Clock signal |
| `w_en` | Write enable |
| `r_en` | Read enable |
| `w_d` | Write data |
| `r_d` | Read data |
| `full` | FIFO full flag |
| `emt` | FIFO empty flag |

### Randomized Variable

```systemverilog
randc bit [7:0] w_d;
```

- `randc` generates cyclic random values
- Ensures all values appear before repetition

---

## 2. Generator

The generator creates randomized transactions and sends them to the driver through a mailbox.

### Generator Features
- Generates 32 transactions
- Randomizes write data
- Uses event synchronization
- Sends transactions continuously

### Generator Flow

```systemverilog
for(int i=0;i<32;i++) begin
    assert(t.randomize);
    mbx.put(t);
    @(next);
end
```

---

## 3. Driver

The driver receives transactions from the generator and drives them to the FIFO DUT through the virtual interface.

### Driver Operations
- Performs reset
- Writes data until FIFO becomes FULL
- Reads data until FIFO becomes EMPTY

---

## Reset Operation

```systemverilog
task reset();
    @(posedge fi.clk);
    fi.rst <= 1'b1;
    repeat(5) @(posedge fi.clk);
    fi.rst <= 1'b0;
endtask
```

---

## Write Operation

```systemverilog
task write_till_full();

    fi.rst <= 1'b0;

    fi.w_en <= 1'b1;
    fi.r_en <= 1'b0;
    fi.w_d  <= td.w_d;

    @(posedge fi.clk);

    fi.w_en <= 1'b0;

    @(posedge fi.clk);

endtask
```

### Functionality
- Enables write operation
- Sends randomized data into FIFO
- Continues until FIFO FULL flag is asserted

---

## Read Operation

```systemverilog
task read_till_empty();

    fi.rst <= 1'b0;

    fi.r_en <= 1'b1;
    fi.w_en <= 1'b0;

    @(posedge fi.clk);

    fi.r_en <= 1'b0;

    @(posedge fi.clk);

endtask
```

### Functionality
- Enables FIFO read
- Reads stored FIFO data
- Continues until FIFO EMPTY flag is asserted

---

## 4. Monitor

The monitor passively observes DUT activity and captures transaction information.

### Captured Signals
- Write enable
- Read enable
- Write data
- Read data

### Monitor Flow

```systemverilog
@(posedge fi.clk);

tm.w_en = fi.w_en;
tm.r_en = fi.r_en;
tm.w_d  = fi.w_d;

@(posedge fi.clk);

tm.r_d = fi.r_d;

mbx.put(tm);
```

---

## 5. Scoreboard

The scoreboard receives monitored transactions and displays FIFO activity.

### Scoreboard Features
- Displays written data
- Displays read data
- Tracks transaction sequence

### Example Output

```text
W--------------------- 45
W--------------------- 120
W--------------------- 87

R--------------------- 45
R--------------------- 120
R--------------------- 87
```

---

# Testbench Operation

The complete verification flow works as follows:

1. Generator creates randomized write data
2. Driver receives transactions
3. Driver writes data into FIFO
4. FIFO becomes FULL
5. Driver starts reading FIFO contents
6. FIFO becomes EMPTY
7. Monitor captures transactions
8. Scoreboard displays results

---

# Clock Generation

```systemverilog
initial begin
    fi.clk <= 0;
end

always #10 fi.clk <= ~fi.clk;
```

### Clock Details
- Clock period = 20 time units
- Positive edge used for synchronization

---

# Waveform Dumping

```systemverilog
initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
end
```

### Supported Waveform Viewers
- GTKWave
- EPWave
- ModelSim

---

# Mailbox Communication

Two mailboxes are used:

| Mailbox | Purpose |
|---------|----------|
| `mbx1` | Generator → Driver |
| `mbx2` | Monitor → Scoreboard |

### Benefits
- Safe communication between components
- Synchronization support
- Transaction passing mechanism

---

# Event Synchronization

Events used in the project:

| Event | Purpose |
|------|----------|
| `done` | Indicates generation completion |
| `next` | Synchronizes generator and scoreboard |

---

# Technologies Used

- SystemVerilog
- Object-Oriented Verification
- Mailbox Communication
- Event Synchronization
- Virtual Interfaces
- Constrained Random Verification

---

# Simulation Commands

## Compile

```bash
iverilog -g2012 *.sv -o fifo_sim
```

## Run Simulation

```bash
vvp fifo_sim
```

## Open Waveform

```bash
gtkwave dump.vcd
```

---

# Expected FIFO Behavior

## Write Phase

Data is written continuously while:

```systemverilog
!fi.full
```

---

## Read Phase

Data is read continuously while:

```systemverilog
!fi.emt
```

---

# Project Structure

```text
FIFO_Verification/
│
├── fifo_design.sv
├── fifo_interface.sv
├── transaction.sv
├── generator.sv
├── driver.sv
├── monitor.sv
├── scoreboard.sv
├── fifo_tb.sv
└── dump.vcd
```

---

# Key Verification Concepts Demonstrated

- Class-Based Verification
- Randomized Testing
- Mailbox Communication
- Event Handling
- Virtual Interfaces
- DUT Monitoring
- Functional Checking
- FIFO Verification Methodology

---

# Future Improvements

Possible future enhancements include:
- Self-checking scoreboard
- SystemVerilog Assertions (SVA)
- Functional Coverage
- FIFO Overflow Testing
- FIFO Underflow Testing
- Error Injection
- Coverage-Driven Verification
- UVM Migration

---

# Learning Outcomes

This project demonstrates:
- Modular verification environment development
- FIFO verification methodology
- Communication between verification components
- Constrained random verification concepts
- Event-driven synchronization
- Transaction-based verification

---

# Author

**Shyam Prabhu P**

---

# License

This project is intended for educational and learning purposes related to:
- Digital Design Verification
- SystemVerilog Verification
- FIFO Verification Methodologies
