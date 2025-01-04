; Calculates  1+2+3+...+99 and displays the result in a terminal window
; char str1[] = "1+2+3+...+99=";
; short sum = 0;
; char ascii[5] = "0000\n";
; register char cx = 1;
; for(cx=1; cx<=99; cx++)
;     sum += cx;
; ascii = itoa(sum);
; cout << str1 << ascii;


section .data
LF		equ	10
NULL		equ	0
SYS_exit	equ	60
EXIT_SUCCESS	equ	0
str1		db	"1 + 2 + 3 +...+ 99 = ", NULL
sum		dw	0
ascii		db	"0000", LF, NULL

section .text
        global _start
_start:
	xor	cx, cx				;cx = 0
	inc	cx				;cx = 1
next1:
	add	word[sum], cx			;sum += cx
	inc	cx				;cx++
	cmp	cx, 99				;compare cx with 99
	jbe	next1				;if(cx<=99) goto next1

	; converts sum into ascii
	mov	rcx, 3
	mov	ax, word[sum]			;ax = [sum]
next2:
	mov	dx, 0				;dx = 0
	mov	bx, 10				;bx = 10
	div	bx				;dx=(dx:ax)%10, ax=(dx:ax)/10
	add     word[ascii+rcx], dx
	dec	rcx
	cmp	rcx, 0
	jge	next2

	; cout << str1
        mov     rax, 1				;SYS_write
        mov     rdi, 1				;where to write
        mov     rsi, str1			;address of str1
        mov     rdx, 21				;22 character to write
        syscall					;calling system services

	; cout << ascii
        mov     rax, 1				;SYS_write
        mov     rdi, 1				;where to write
        mov     rsi, ascii			;address of ascii
        mov     rdx, 5				;5 character to write
        syscall					;calling system services

	; exit program
        mov     rax, SYS_exit			;terminate excuting process
        mov     rdi, EXIT_SUCCESS		;exit status
        syscall					;calling system services
