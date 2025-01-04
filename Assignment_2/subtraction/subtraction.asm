; signed short num1 = 20000, num2 = 30000;
; signed int dif = 0;
; dif = int(num1 - num2);

section .data
SYS_exit	equ	60
EXIT_SUCCESS	equ	0
num1		dw	20000			;num1 = 4E20h
num2		dw	30000			;num2 = 7530h = 30000
dif		dd	0			;dif = 00000000h

section .text
	global _start
_start:
        mov     ax, word[num1]			;ax = num1 = 4E20h
        sub     ax, word[num2]			;ax = ax - num2 = -2710h
	sbb	dx, 0				;dx = dx - 0 - CF = 0h
        mov     [dif], ax			;dif = ax = 7530h
        mov     [dif+2], dx			;dif = ah = 7FFh
						
        mov     rax, SYS_exit			;terminate excuting process
        mov     rdi, EXIT_SUCCESS		;exit status
        syscall					;calling system services
