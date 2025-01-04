; char msg1[] = "Input a number (1~9): ";
; char msg2[] = " is Multiple of 3.";
; char buffer;
; char num;
; char ascii[10];

; register int r10 = 0;
; do {
; 	cout << msg1;
; 	cin >> buffer;
; 	ascii[r10] = buffer;
; 	r10++;
; } while(r10 < 9);
; r10 = 0;
; do {
; 	num = atoi(ascii[r10]);
; 	if(num%3 == 0) {
; 		cout << ascii[r10] << msg2;
; 	}
; r10++;
; } while(r10 < 9);

section .bss
buffer		resb    1			;reserve 1-byte for buffer
num		resb	1			;reserve 1-byte for num
ascii		resb	10			;reserve 10-bytes for ascii

section .data
LF		equ	10
NULL		equ	0
SYS_exit	equ	60
EXIT_SUCCESS	equ	0
msg1		db	"Input a number (1~9): "	;input message
msg2		db	" is Multiple of 3.", 10	;multiple of 3 message

section .text
        global _start
_start:
	mov	r10, 0				;r10 = 0
doloop1:
        ; cout << msg1
        mov     rax, 1				;SYS_write
        mov     rdi, 1				;write to STD_OUT
        mov     rsi, msg1			;address of msg1
        mov     rdx, 22				;22 characters to write
        syscall					;calling system services

	; cin >> buffer
read_input:	
	mov	rax, 0				;SYS_read
	mov	rdi, 0				;read from STD_IN
	mov	rsi, buffer			;address of the buffer
	mov	rdx, 1				;input length = 1
	syscall					;calling system services
	cmp	byte [buffer], LF		;compare buffer to LF
	je	read_input			;read again if newline

	mov	al, [buffer]			;al = buffer (ex: '5'=35h)
	mov	[ascii+r10], al			;store in ascii array at position r10
	
	inc	r10				;r10++
	cmp	r10, 9				;compare r10 and 9
	jb	doloop1				;loop back if r10 < 9
	
	mov	r10, 0				;reset r10 for next loop

doloop2:
	; num = atoi(ascii[r10])
	mov	al, [ascii+r10]			;load byte from ascii
	mov	[num], al			;store in num (temporary conversion for checking)

	; if(num%3 == 0)
	mov	al, [num]
	mov	bl, 3				;bl = 3h
	xor	ah, ah				;clear ah before div
	div	bl				;al = num/3, ah = num%3
	cmp	ah, 0				;check remainder
	jne	end_of_loop			;skip printing if not multiple of 3
	
	; cout << ascii[r10]
	mov     rax, 1				;SYS_write
        mov     rdi, 1				;where to write
        lea     rsi, [ascii+r10]		;address of ascii element at r10
        mov     rdx, 1				;1 character to write
        syscall					;calling system services
        
        ; cout << msg2
        mov     rax, 1				;SYS_write
        mov     rdi, 1				;where to write
        mov     rsi, msg2			;address of msg2
        mov     rdx, 19				;19 characters to write
        syscall					;calling system services
        
end_of_loop:
        inc	r10				;r10++
        cmp	r10, 9				;compare r10 and 9
        jb	doloop2				;loop back if r10 < 9

done:
        mov     rax, SYS_exit			;terminate executing process
        mov     rdi, EXIT_SUCCESS		;exit status
        syscall					;calling system services
