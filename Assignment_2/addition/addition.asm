; unsigned short num1 = 50000, num2 = 40000;
; unsigned int sum = 0;
; sum = int(num1 + num2);

section .data
SYS_exit	equ	60
EXIT_SUCCESS	equ	0
num1		dw	50000			;num1 = C350h
num2		dw	40000			;num2 = 9C40h
sum		dd	0			;sum = 00000000h

section .text
        global _start
_start:
	mov	dx, 0
        mov     ax, word[num1]			;ax = num1 = C350h
        add     ax, word[num2]			;ax = ax + num2 = 5F90h
	adc	dx, 0				;dx = dx + 0 + CF = 01h
        mov     [sum], ax        		;sum = ax = 3CB0h
        mov	[sum+2], dx			;sum = dx = FFFFh
						
        mov     rax, SYS_exit			;terminate excuting process
        mov     rdi, EXIT_SUCCESS		;exit status
        syscall					;calling system services
