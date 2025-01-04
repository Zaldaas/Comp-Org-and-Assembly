; unsigned short num = 225
; unsigned short mul_3 = 0, other = 0;
; if(num % 3 == 0 && num % 5; != 0) {
;    mul_3++
; } else {
;    other++;
; }

section .data
SYS_exit	equ	60
EXIT_SUCCESS	equ	0
num		dw	225			;num = E1h
mul_3		dw	0			;mul_3 = 00h
other		dw	0			;other = 00h
    
section .text
        global _start
_start:
        mov     ax, word[num]			;ax = num = E1h
        mov	dx, 0				;dx = 00h
        mov	bx, 3				;bx = 3h
        div     bx				;dx = 00h
        					;ax = 4Bh
        cmp     dx, 0				;dx-0 = 0-0
        jne     not_mul_3			;if(num % 3 != 0) goto not_mul_3
        
        mov	ax, word[num]			;ax = num = E1h
        mov	dx, 0				;dx = 0h
        mov	bx, 5				;bx = 5h
        div	bx				;dx = 00h
        					;ax = 2Dh
        cmp	dx, 0				;dx-0 = 0-0
        je	not_mul_3			;if(num % 5 = 0) goto not_mul_3
        			
        mov	ax, 1				;ax = 1h
        add     ax, word[mul_3]			;ax = 1 + mul_3 = 1h
        mov	word[mul_3], ax			;mul_3 = ax = 1h
	jmp	done
not_mul_3:
	mov	ax, 1				;ax = 1h
	add	ax, word[other]			;ax = 1 + other = 1h
	mov	word[other], ax			;other = ax = 1h
done:
        mov     rax, SYS_exit			;terminate excuting process
        mov     rdi, EXIT_SUCCESS		;exit status
        syscall					;calling system services
