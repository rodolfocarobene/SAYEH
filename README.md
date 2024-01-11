# SAYEH

Simple Architecture Yet Enough Hardware is a processor implemented in the book
"VHDL: Modular Design and Synthesis of Cores and Systems" by Zainalabedin
Navabi.

## Processor Design

The design of the SAYEH processor is as follows:

[SAYEH](sayeh/SAYEH.vhd)<br>
└── [Datapath](sayeh/DataPath.vhd)<br>
    ├── [Addressing Unit](sayeh/AddresingUnit.vhd)<br>
    │   ├── [Program Counter](sayeh/ProgramCounter.vhd)<br>
    │   └── [Address logic](sayeh/AddressLogic.vhd)<br>
    ├── [Arithmetic Unit](sayeh/ArithmeticUnit.vhd)<br>
    │   └── [bit8x8](sayeh/bit8x8.vhd)<br>
    │       └── [bit1x1](sayeh/bit1x1.vhd)<br>
    ├── [Register File](sayeh/RegisterFile.vhd)<br>
    ├── [Instruction Register](sayeh/InstructionRegister.vhd)<br>
    └── [Window Pointer](sayeh/WindowPointer.vhd)<br>

All of the required files are in the [sayeh](sayeh/) directory.

## Testbench

To test the SAYEH processor, a testbench is available in the
[testbench](sayeh/testbench) directory. The testbench loads with the memorysayeh
component a program from a `prog.txt` file and execute it when simulated. The
output is N files `memN.hex` with the hexadecimal memory of SAYEH. Two different
programs are loaded as examples

[Test SAYEH](sayeh/testbench/test_sayeh.vhd)<br>
├── [SAYEH processor](sayeh/)<br>
├── [Memory Sayeh](sayeh/testbench/sayehmemory.vhd)<br>
├── [prog.txt](sayeh/testbench/prog.txt)<br>
└── [prog.txt.1](sayeh/testbench/prog.txt.1)<br>

## Assembly language

| Memonic | Description          | Bits         | Comment                        |
| ------- | -------------------- | ------------ | ------------------------------ |
| nop     | No operation         | 0000-00-00   | No operation                   |
| hlt     | Halt                 | 0000-00-01   | Halt - Fetching stops          |
| szf     | Set zero flag        | 0000-00-10   | Z <= '1'                       |
| czf     | Clear zero flag      | 0000-00-11   | Z <= '0'                       |
| scf     | Set carry flag       | 0000-01-00   | C <= '1'                       |
| ccf     | Clear carry flag     | 0000-01-01   | C <= '0'                       |
| cwp     | Clear window pointer | 0000-01-10   | WP <= "000"                    |
| mvr     | Move register        | 0001-D-S     | Rd <= Rs                       |
| lda     | Load addressed       | 0010-D-S     | Rd <= (Rs)                     |
| sta     | Store addressed      | 0011-D-S     | (Rd) <= Rs                     |
| inp     | Input from port      | 0100-D-S     | In from Rs write to Rd         |
| oup     | Output from port     | 0101-D-S     | Out to port Rd write from Rs   |
| and     | And registers        | 0110-D-S     | Rd <= Rd & Rs                  |
| orr     | Or registers         | 0111-D-S     | Rd <= Rd or Rs                 |
| not     | Not registers        | 1000-D-S     | Rd <= not Rs                   |
| shl     | Shift left           | 1001-D-S     | Rd <= shift_left Rs            |
| shr     | Shift right          | 1010-D-S     | Rd <= shift_right Rs           |
| add     | Add registers        | 1011-D-S     | Rd <= Rd + Rs + C              |
| sub     | Sub registers        | 1100-D-S     | Rd <= Rd - Rs - C              |
| mul     | Multiply registers   | 1101-D-S     | Rd <= Rd \* Rs                 |
| cmp     | Compare registers    | 1110-D-S     | If equal Z='1', if Rd<Rs C='0' |
| mil     | Move I low           | 1111-D-00-I  | Rd <= {8b'Z, I}                |
| mih     | Move I high          | 1111-D-01-I  | Rd <= {I, 8b'Z}                |
| spc     | Sve PC               | 1111-D-10-I  | Rd <= PC + I                   |
| jpa     | Jump addressed       | 1111-D-11-I  | PC <= Rd + I                   |
| jpr     | Jump relative        | 0000-01-11-I | PC <= PC + I                   |
| brz     | Branch if zero       | 0000-10-00-I | PC <= PC + I if Z is '1'       |
| brc     | Branch if carry      | 0000-10-01-I | PC <= PC + I if C is '1'       |
| awp     | Add window pointer   | 0000-10-10-I | WP <= WP + I                   |
