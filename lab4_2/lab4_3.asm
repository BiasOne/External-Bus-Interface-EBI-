;lab4_3.asm

.include "atxmega128a1udef.inc"

.equ stackInit = 0x3FFF
.equ io_start_addr = 0x9000
.equ io_end_addr = 0x9FFF

.equ sram_start_addr = 0x3000
.equ sram_end_addr = 0x3FFF

.equ NULL = 0x00

.org 0x200
IN_TABLE:
.db 1, 2, 4, 8, 16, 32, 64, NULL

.CSEG
.org TCC0_OVF_vect
rjmp ISR

.org 0x0
rjmp main

.org 0x100
main:
ldi r16, low(stackInit)
out CPU_SPL, r16
ldi r16, high(stackInit)
out CPU_SPH, r16


ldi r16, 0b00110011
sts PORTH_OUTSET, r16

ldi r16, 0b00110111
sts PORTH_DIRSET, r16

ldi r16, 0xFF
sts PORTJ_DIRSET, r16 
ldi r16, 0xFF
sts PORTK_DIRSET, r16

ldi r16, 0b0001 ;8331 pg 329 [3:2=srmode][1:0 = ifmode]
sts EBI_CTRL, r16

ldi r16, 0b0011101
sts EBI_CS0_CTRLA, r16

ldi r16, 0b00000001 ;8331 pg 335 [6:2=size][1:0= mode] 
sts EBI_CS1_CTRLA, r16

ldi r16, high(sram_start_addr)
sts EBI_CS0_BASEADDR, r16
ldi r16, byte3(sram_start_addr)
sts EBI_CS0_BASEADDR+1, r16

ldi r16, high(io_start_addr)
sts EBI_CS1_BASEADDR, r16
ldi r16, byte3(io_start_addr)
sts EBI_CS1_BASEADDR+1, r16

ldi XL, low(0x1903F)
ldi XH, high(0x1903F)
ldi r16, byte3(0x1903F)
out CPU_RAMPX, r16

ldi YL, low(sram_start_addr)
ldi YH, high(sram_start_addr)
ldi r16, byte3(sram_start_addr)
out CPU_RAMPY, r16

ldi ZL, low(IN_TABLE << 1)
ldi ZH, high(IN_TABLE <<1)


STORE:
lpm r16, Z+
cpi r16, NULL
breq prog
st Y+, r16
rjmp STORE


Prog:
ldi r16, low(0x3D09)
sts TCC0_PER, r16
ldi r16, high(0x3D09)
sts TCC0_PER+1, r16

ldi r16, 0x01
sts TCC0_INTCTRLA, r16

ldi r16, TC_CLKSEL_DIV64_gc
sts TCC0_CTRLA, r16

rcall reset


sts PMIC_CTRL, r16
sei

END:
rjmp END

ISR:
push r16
lds r16, CPU_SREG
push r16
ldi r16, 0x01
sts TCC0_INTFLAGS, r16

LOOP:
ld r16, Y+
cpi r16, NULL
breq RESET

st X, r16

pop r16
sts CPU_SREG, r16
pop r16
reti

RESET:
ldi YL, low(sram_start_addr)
ldi YH, high(sram_start_addr)
ldi r16, byte3(sram_start_addr)
out CPU_RAMPY, r16
ret
