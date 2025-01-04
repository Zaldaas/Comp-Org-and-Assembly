; unsigned long num1 = 50000000000;
; unsigned int num2 = 3333333;
; unsigned int quotient = 0, remainder = 0;
; quotient = num1 / num2;
; remainder = num1 % num2;

section .data
SYS_exit	equ	60
EXIT_SUCCESS	equ	0
num1		dq	50000000000		;num1 = 50000000000 = BA43 B7400h
num2		dd	3333333			;num2 = 3333333 = 32DCD5h
quotient	dd	0			;quotient = 0000h
remainder	dd	0			;remainder = 0000h

section .text
        global _start

_start:
	mov	edx, dword[num1+4]		;edx = num1+4 = BA43h
        mov     eax, dword[num1+0]		;eax = num1+0 = B7400h
        div     dword[num2]			;eax=eax/num2=3A98h=15000
						;edx=eax%num2=1388h=5000
        mov     dword[quotient], eax		;quotient =eax=3A98h=15000
        mov     dword[remainder], edx		;remainder=edx=1388h=5000

        mov     rax, SYS_exit			;terminate excuting process
        mov     rdi, EXIT_SUCCESS		;exit status
        syscall					;calling system services

