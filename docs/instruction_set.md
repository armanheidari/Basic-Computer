# Instruction Set Reference

The Basic Computer implements the 25 fundamental instructions defined by M. Morris Mano, classified into three primary categories:

1. **Memory-Reference Instructions (MRI)** (7 instructions, direct and indirect modes)
2. **Register-Reference Instructions** (12 instructions)
3. **Input-Output Instructions** (6 instructions)

---

## Instruction Formats

### 1. Memory-Reference Format
```
 15  14     12 11                                    0
+---+---------+---------------------------------------+
| I | Opcode  |           Effective Address           |
+---+---------+---------------------------------------+
```
* **Bit 15 (\(I\))**: Addressing mode bit (0 = Direct, 1 = Indirect).
* **Bits 14–12**: Opcode (\(D_0\) through \(D_6\)).
* **Bits 11–0**: 12-bit memory address (`0x000` to `0xFFF`).

### 2. Register-Reference Format (\(Opcode = 111\), \(I = 0\))
```
 15  14     12 11                                    0
+---+---------+---------------------------------------+
| 0 |  1 1 1  |           Register Operation          |
+---+---------+---------------------------------------+
```
* **Bit 15**: `0`
* **Bits 14–12**: `111` (Hex prefix `7`)
* **Bits 11–0**: 1-hot bit corresponding to a specific register micro-operation.

### 3. Input-Output Format (\(Opcode = 111\), \(I = 1\))
```
 15  14     12 11                                    0
+---+---------+---------------------------------------+
| 1 |  1 1 1  |              I/O Operation            |
+---+---------+---------------------------------------+
```
* **Bit 15**: `1`
* **Bits 14–12**: `111` (Hex prefix `F`)
* **Bits 11–0**: 1-hot bit specifying the I/O operation.

---

## 1. Memory-Reference Instructions (MRI)

| Mnemonic | Hex (Direct, \(I=0\)) | Hex (Indirect, \(I=1\)) | Description & Micro-operations |
| :--- | :--- | :--- | :--- |
| **AND** | `0xxx` | `8xxx` | **AND to AC**<br>\(D_0 T_4: DR \leftarrow M[AR]\)<br>\(D_0 T_5: AC \leftarrow AC \land DR, SC \leftarrow 0\) |
| **ADD** | `1xxx` | `9xxx` | **Add to AC**<br>\(D_1 T_4: DR \leftarrow M[AR]\)<br>\(D_1 T_5: AC \leftarrow AC + DR, E \leftarrow C_{out}, SC \leftarrow 0\) |
| **LDA** | `2xxx` | `Axxx` | **Load to AC**<br>\(D_2 T_4: DR \leftarrow M[AR]\)<br>\(D_2 T_5: AC \leftarrow DR, SC \leftarrow 0\) |
| **STA** | `3xxx` | `Bxxx` | **Store AC to Memory**<br>\(D_3 T_4: M[AR] \leftarrow AC, SC \leftarrow 0\) |
| **BUN** | `4xxx` | `Cxxx` | **Branch Unconditionally**<br>\(D_4 T_4: PC \leftarrow AR, SC \leftarrow 0\) |
| **BSA** | `5xxx` | `Dxxx` | **Branch and Save Return Address**<br>\(D_5 T_4: M[AR] \leftarrow PC, AR \leftarrow AR + 1\)<br>\(D_5 T_5: PC \leftarrow AR, SC \leftarrow 0\) |
| **ISZ** | `6xxx` | `Exxx` | **Increment and Skip if Zero**<br>\(D_6 T_4: DR \leftarrow M[AR]\)<br>\(D_6 T_5: DR \leftarrow DR + 1\)<br>\(D_6 T_6: M[AR] \leftarrow DR\), if \((DR = 0)\) then \(PC \leftarrow PC + 1, SC \leftarrow 0\) |

---

## 2. Register-Reference Instructions

All executed in cycle \(r T_3\) where \(r = D_7 \cdot I' \cdot T_3\):

| Mnemonic | Hex Code | Bit Condition | Operation |
| :--- | :--- | :--- | :--- |
| **CLA** | `7800` | \(B_{11}\) | Clear Accumulator: \(AC \leftarrow 0\) |
| **CLE** | `7400` | \(B_{10}\) | Clear Extended Bit: \(E \leftarrow 0\) |
| **CMA** | `7200` | \(B_9\) | Complement Accumulator: \(AC \leftarrow \overline{AC}\) |
| **CME** | `7100` | \(B_8\) | Complement Extended Bit: \(E \leftarrow \overline{E}\) |
| **CIR** | `7080` | \(B_7\) | Circulate Right: \(AC \leftarrow \text{shr}(AC), AC[15] \leftarrow E, E \leftarrow AC[0]\) |
| **CIL** | `7040` | \(B_6\) | Circulate Left: \(AC \leftarrow \text{shl}(AC), AC[0] \leftarrow E, E \leftarrow AC[15]\) |
| **INC** | `7020` | \(B_5\) | Increment Accumulator: \(AC \leftarrow AC + 1\) |
| **SPA** | `7010` | \(B_4\) | Skip if Positive: if \((AC[15] = 0)\) then \(PC \leftarrow PC + 1\) |
| **SNA** | `7008` | \(B_3\) | Skip if Negative: if \((AC[15] = 1)\) then \(PC \leftarrow PC + 1\) |
| **SZA** | `7004` | \(B_2\) | Skip if Zero: if \((AC = 0)\) then \(PC \leftarrow PC + 1\) |
| **SZE** | `7002` | \(B_1\) | Skip if \(E\) is Zero: if \((E = 0)\) then \(PC \leftarrow PC + 1\) |
| **HLT** | `7001` | \(B_0\) | Halt Computer: \(S \leftarrow 0\) |

---

## 3. Input-Output Instructions

Executed in cycle \(p T_3\) where \(p = D_7 \cdot I \cdot T_3\):

| Mnemonic | Hex Code | Operation |
| :--- | :--- | :--- |
| **INP** | `F800` | Input character: \(AC[7:0] \leftarrow INPR, FGI \leftarrow 0\) |
| **OUT** | `F400` | Output character: \(OUTR \leftarrow AC[7:0], FGO \leftarrow 0\) |
| **SKI** | `F200` | Skip on input flag: if \((FGI = 1)\) then \(PC \leftarrow PC + 1\) |
| **SKO** | `F100` | Skip on output flag: if \((FGO = 1)\) then \(PC \leftarrow PC + 1\) |
| **ION** | `F080` | Interrupt On: \(IEN \leftarrow 1\) |
| **IOF** | `F040` | Interrupt Off: \(IEN \leftarrow 0\) |
