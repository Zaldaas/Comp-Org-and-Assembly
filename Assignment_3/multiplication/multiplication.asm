; unsigned int num1 = 300000, num2 = 400000;
; unsigned long product = 0;
; product = long(num1 * num2);

section .data
SYS_exit	equ	60
EXIT_SUCCESS	equ	0
num1		dd	300000			;num1 = 493E0h
num2		dd	400000			;num2 = 61A80h
product		dq	0			;product = 00000000h

section .text
        global _start

_start:
        mov     eax, dword[num1]		;eax = num1 = 493E0h
        mul     dword[num2]			;edx:eax = eax * num2 = 1BF08:EB000
        mov     dword[product], eax		;product = eax = EB000h
        mov     dword[product+4], edx		;product+4 = edx = 1BF08h

        mov     rax, SYS_exit			;terminate excuting process
        mov     rdi, EXIT_SUCCESS		;exit status
        syscall					;calling system services

