; ==============================================================================
; Mano's Basic Computer - Sample Test Program
; Architecture: M. Morris Mano ("Computer System Architecture")
; Word size: 16-bit | Memory: 4096 x 16 (High byte: DATA.BIN, Low byte: DATA2.BIN)
; Designers: Sina Jani, Arman Heidari, Amirmohammad Anvari
; Supervisor: Eng. Moradi
; ==============================================================================
;
; Instruction Encoding:
;   Bit 15      : Addressing Mode (I): 0 = Direct, 1 = Indirect
;   Bits 14-12  : Opcode (D0 to D7)
;   Bits 11-0   : Memory Address (0x000 - 0xFFF) or Register / IO Operation
;
; Memory Reference Instructions (MRI):
;   Opcode  Direct (I=0)  Indirect (I=1)  Description
;   000     AND 0xxx      AND 8xxx        Logical AND memory word to AC
;   001     ADD 1xxx      ADD 9xxx        Add memory word to AC (carry to E)
;   010     LDA 2xxx      LDA Axxx        Load memory word into AC
;   011     STA 3xxx      STA Bxxx        Store AC into memory word
;   100     BUN 4xxx      BUN Cxxx        Branch unconditionally
;   101     BSA 5xxx      BSA Dxxx        Branch and save return address
;   110     ISZ 6xxx      ISZ Exxx        Increment operand and skip if zero
;
; Register Reference Instructions (Opcode 111, I = 0):
;   CLA (7800)  Clear AC
;   CLE (7400)  Clear E flip-flop
;   CMA (7200)  Complement AC
;   CME (7100)  Complement E
;   CIR (7080)  Circulate right AC and E
;   CIL (7040)  Circulate left AC and E
;   INC (7020)  Increment AC
;   SPA (7010)  Skip next instruction if AC positive
;   SNA (7008)  Skip next instruction if AC negative
;   SZA (7004)  Skip next instruction if AC is zero
;   SZE (7002)  Skip next instruction if E is zero
;   HLT (7001)  Halt computer
; ==============================================================================

            ORG 000         ; Program starts at memory address 0x000

START:      LDA 082         ; Hex: 2082 | Direct: Load AC from memory location 0x082 (AC <- 0xA937)
            AND 041 I       ; Hex: 8041 | Indirect: Read pointer at 0x041 (points to 0x083), AC <- AC & M[083]
            ADD 084         ; Hex: 1084 | Direct: Add value at location 0x084 (0xB8F2) to AC
            LDA 085         ; Hex: 2085 | Direct: Load AC with value from location 0x085 (0xB8F2)
            STA 086         ; Hex: 3086 | Direct: Store contents of AC into memory location 0x086
            INC             ; Hex: 7020 | Register Op: Increment Accumulator (AC <- AC + 1)
            CMA             ; Hex: 7200 | Register Op: 1's Complement Accumulator (AC <- ~AC)

; ------------------------------------------------------------------------------
; Pointers & Data Variables
; ------------------------------------------------------------------------------
            ORG 041
PTR_VAR:    HEX 0083        ; Hex: 0083 | Pointer referencing address 0x083 for indirect test

            ORG 082
DATA_1:     HEX A937        ; Hex: A937 | Test data operand 1
DATA_2:     HEX B8F2        ; Hex: B8F2 | Test data operand 2 (accessed indirectly via 0x041)
DATA_3:     HEX B8F2        ; Hex: B8F2 | Test data operand 3
DATA_4:     HEX B8F2        ; Hex: B8F2 | Test data operand 4
DATA_DEST:  HEX 0000        ; Hex: 0000 | Destination address for STA 086 result

            END
