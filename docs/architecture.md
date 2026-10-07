# Basic Computer Architecture

This document details the architectural design and schematic implementation of the **Basic Computer**, based on the classical architecture specified by **M. Morris Mano** in *Computer System Architecture* (Chapter 5), simulated and realized using **Proteus Design Suite**.

---

## 1. Architectural Overview

The Basic Computer is an educational, accumulator-based 16-bit computer. It features:

* **Word Size**: 16 bits
* **Memory Capacity**: 4096 words of 16 bits each (4K × 16), addressed by a 12-bit address bus (`0x000` to `0xFFF`)
* **Data Bus**: 16-bit Common Bus system implemented using 8-to-1 digital multiplexers (74151/74153 ICs)
* **Control Mechanism**: Hardwired control unit driven by a 4-bit Sequence Counter (`SC`), a 3-to-8 instruction opcode decoder, and a 4-to-16 timing decoder
* **Simulation Environment**: Proteus 8.13+

---

## 2. Register Organization

The processor contains registers of varying bit lengths, each serving a dedicated function:

| Register | Name | Size (Bits) | Description |
| :--- | :--- | :--- | :--- |
| **AR** | Address Register | 12 | Holds memory addresses (`0x000` to `0xFFF`) |
| **PC** | Program Counter | 12 | Holds the address of the next instruction to fetch |
| **DR** | Data Register | 16 | Holds memory operands read from RAM |
| **AC** | Accumulator | 16 | General-purpose register and target of arithmetic/logic operations |
| **IR** | Instruction Register | 16 | Holds the fetched instruction currently being decoded |
| **TR** | Temporary Register | 16 | Stores scratchpad data during execution |
| **SC** | Sequence Counter | 4 | Outputs timing states \(T_0\) through \(T_{15}\) |
| **I** | Mode Flip-Flop | 1 | Indicates direct (\(I=0\)) or indirect (\(I=1\)) addressing |
| **E** | Extended Flip-Flop | 1 | Holds carry bit out of the Accumulator |
| **S** | Start/Stop Flip-Flop | 1 | Controls machine run/halt state |

---

## 3. Common Bus Architecture

Communication between registers and memory is coordinated through a shared **16-bit Common Bus**. Multiplexer select lines \(S_2, S_1, S_0\) determine which unit drives the bus:

| \(S_2\) | \(S_1\) | \(S_0\) | Selected Source | Active Output on Bus |
| :---: | :---: | :---: | :--- | :--- |
| 0 | 0 | 0 | **None** | High-impedance / Inactive |
| 0 | 0 | 1 | **AR** | Address Register (bits 11–0; upper bits 0) |
| 0 | 1 | 0 | **PC** | Program Counter (bits 11–0; upper bits 0) |
| 0 | 1 | 1 | **DR** | Data Register (bits 15–0) |
| 1 | 0 | 0 | **AC** | Accumulator (bits 15–0) |
| 1 | 0 | 1 | **IR** | Instruction Register (bits 15–0) |
| 1 | 1 | 0 | **TR** | Temporary Register (bits 15–0) |
| 1 | 1 | 1 | **Memory** | Memory word addressed by \(M[AR]\) (bits 15–0) |

Loading into a specific register is governed by individual write/load strobe lines (`LD`), increment lines (`INR`), and clear lines (`CLR`).

---

## 4. Memory Subsystem

* **Configuration**: 4096 words × 16 bits.
* **Implementation in Proteus**: Realized using two parallel **27512 (64K × 8)** digital memory chips:
  * **High Byte**: `DATA.BIN` provides bits 15–8.
  * **Low Byte**: `DATA2.BIN` provides bits 7–0.
* **Control Lines**:
  * **Read**: Connects \(M[AR]\) onto the Common Bus (\(S_2 S_1 S_0 = 111\)).
  * **Write**: Writes the value currently present on the Common Bus into \(M[AR]\).

---

## 5. Arithmetic Logic Unit (ALU) & Adder Logic

The ALU executes combinational arithmetic and logic functions directly tied to the Accumulator (`AC`):

1. **AND**: \(AC \leftarrow AC \land DR\)
2. **ADD**: \(AC \leftarrow AC + DR\), \(E \leftarrow C_{out}\) (Implemented using 74283 4-bit binary adders)
3. **DR Transfer**: \(AC \leftarrow DR\)
4. **Complement (CMA)**: \(AC \leftarrow \overline{AC}\)
5. **Circulate Right (CIR)**: \(AC \leftarrow \text{shr}(AC)\), \(AC[15] \leftarrow E\), \(E \leftarrow AC[0]\)
6. **Circulate Left (CIL)**: \(AC \leftarrow \text{shl}(AC)\), \(AC[0] \leftarrow E\), \(E \leftarrow AC[15]\)
7. **Clear (CLA)**: \(AC \leftarrow 0\)
8. **Increment (INC)**: \(AC \leftarrow AC + 1\)

---

## 6. Hardwired Control Unit

The Control Unit orchestrates timing and micro-operations through hardwired logic gates and decoders:

* **Instruction Opcode Decoder**: 3-to-8 decoder (74HC238 / 74154) decodes bits `IR[14:12]` into opcode signals \(D_0\) through \(D_7\).
* **Timing Decoder**: 4-to-16 line decoder decodes 4-bit Sequence Counter (`SC`) into active-high timing signals \(T_0, T_1, \dots, T_{15}\).
* **Control Logic Gates**: Synthesize control signals for:
  * Register operations: `AR(LD)`, `AR(INR)`, `AR(CLR)`, `PC(LD)`, `PC(INR)`, `DR(LD)`, `AC(LD)`, `IR(LD)`, `TR(LD)`
  * Memory operations: `Read`, `Write`
  * Bus selector lines: \(S_0, S_1, S_2\)
  * Sequence counter: `SC(CLR)`, `SC(INR)`

---

## 7. Basic Computer Cycle

Every instruction executes across well-defined phases:

1. **Fetch**:
   * \(T_0\): \(AR \leftarrow PC\)
   * \(T_1\): \(IR \leftarrow M[AR]\), \(PC \leftarrow PC + 1\)
2. **Decode**:
   * \(T_2\): \(D_0 \dots D_7 \leftarrow \text{Decode}(IR[12:14])\), \(AR \leftarrow IR[0:11]\), \(I \leftarrow IR[15]\)
3. **Indirect Resolution / Register Execution**:
   * \(T_3\):
     * If \(D_7' I = 1\) (Memory Reference, Indirect): \(AR \leftarrow M[AR]\)
     * If \(D_7 I' = 1\) (Register Reference): Execute Register micro-operation; \(SC \leftarrow 0\)
4. **Execute**:
   * \(T_4, T_5, T_6\): Execute specific memory-reference instruction (e.g., `ADD`, `LDA`, `STA`), then clear sequence counter (\(SC \leftarrow 0\)).
