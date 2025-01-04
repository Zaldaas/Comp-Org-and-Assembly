; unsigned short array[7] = {12, 1003, 6543, 24680, 789, 30123, 32766};
; unsigned short even[7];
; register long rsi = 0, rdi = 0;
; do {
;	if(array[rsi] % 2 == 0) {
;		even[rdi] = array[rsi];
;		rdi++;
;	}
;	rsi++;
; } while(rsi < 7);


section .data
SYS_exit	equ	60
EXIT_SUCCESS	equ	0
array		dw	12, 1003, 6543, 24680, 789, 30123, 32766

section .bss
even		resw	7

section .text
        global _start
_start:
	mov	rsi, 0				;rsi = 0
	mov	rdi, 0				;rdi = 0
doloop:
	mov	ax, word[array+(rsi*2)]		;ax = array[rsi]
	test	ax, 1				
	jnz	not_even			;if(array[rsi] % 2 != 0) goto not_even
	mov	word[even+(rdi*2)], ax		;even[rdi] = array[rsi]
	inc	rdi				;rdi = rdi + 1
not_even:					;{
        inc     rsi				;rsi = rsi + 1
        cmp	rsi, 7				;compare rsi and 7
	jb	doloop				;if(rsi<7) goto doloop

        mov     rax, SYS_exit			;terminate excuting process
        mov     rdi, EXIT_SUCCESS		;exit status
        syscall					;calling system services
