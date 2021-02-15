;
; lab4_2.asm
;
; Created: 7/5/2020 11:43:48 AM
; Author : joseph Morales	
;

.include "atxmega128a1udef.inc"

.equ stackInit = 0x3FFF
.equ io_start_addr = 0x019000
.equ io_end_addr = 0x01903F

.CSEG

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

ldi r16, 0b00000001 ;8331 pg 335 [6:2=size][1:0= mode] 
sts EBI_CS1_CTRLA, r16

ldi r16, high(io_start_addr)
sts EBI_CS1_BASEADDR, r16
ldi r16, byte3(io_start_addr)
sts EBI_CS1_BASEADDR+1, r16

ldi XL, low(io_start_addr)
ldi XH, high(io_start_addr)
ldi r16, byte3(io_start_addr)
out CPU_RAMPX, r16

LOOP:
ld r16, X
st X, r16
rjmp LOOP

END:
rjmp END