; #begin define print(addr, n)
; 	rax = 1;
; 	rdi = 1;
; 	rsi = addr of string;
; 	rdx = n;
; 	syscall;
; #end
; #begin define scan(addr, n)
; 	rax = 1;
; 	rdi = 1;
; 	rsi = addr of buffer;
; 	rdx = n;
; 	syscall;
; #end
; void main() {
; 	char buffer[4];
; 	int n;
; 	int sumN;
; 	char ascii[10];
; 	char msg1[26] = "Input a number (004~999): ";
; 	char msg2[16] = "1 + 2 + 3 +...+ ";
; 	char msg3[4] = " = ";
; 
; 	print(msg1, 26);
; 	scan(buffer, 4);
; 	call toInteger(n, buffer);
; 	call calculate(n, sumN);
; 	call toString(n, ascii);
; 	print(msg2, 16);
; 	print(buffer, 3);
; 	print(msg3, 3);
; 	print(ascii, 6);
; }
; void toInteger(n, buffer) {
; 	n = atoi(buffer);
; }
; void calculate(n, sumN) {
; 	for(ecx=0; ecx<=n; ecx++) {
; 		sumN += ecx;
; 	}
; }
; void toString(sumN, ascii) {
; 	ascii = itoa(sumN);
; }

%macro	print 	2
        mov     rax, 1					;SYS_write
        mov     rdi, 1					;standard output device
        mov     rsi, %1					;output string address
        mov     rdx, %2					;number of character
        syscall						;calling system services
%endmacro

%macro	scan 	2
        mov     rax, 0					;SYS_read
        mov     rdi, 0					;standard input device
        mov     rsi, %1					;input buffer address
        mov     rdx, %2					;number of character
        syscall						;calling system services
%endmacro

section .bss
buffer		resb	4
n		resd	1
sumN		resd    1
ascii		resb    10

section .data
LF		equ	10
NULL		equ	0
SYS_exit	equ	60
EXIT_SUCCESS	equ	0
msg1		db	"Input a number (004~999): "
msg2		db      "1 + 2 + 3 +...+ "
msg3		db	" = ", NULL

section .text
        global _start
_start:
	print	msg1, 26				;cout << msg1
	scan	buffer, 4				;cin >> buffer
	mov	rbx, buffer				;rbx = address of buffer
	call	toInteger
	
	; Restore ASCII characters in buffer
	mov	rsi, 0					;reset index to 0
	call	toRestore

	; calculates 1+2+3+...+N
	mov	rcx, 0					;rcx = 0
	mov	edi, dword[n]				;edi = n
	call 	calculate				;call calculate

	; converts sum100 into ascii
	mov	rcx, 3
	mov	edi, dword[sumN]			;edi = sumN
	call	toString

	; display message and result
	print	msg2, 16				;cout << str1
	print	buffer, 3				;cout << buffer
	print	msg3, 3					;cout << msg3
	print	ascii, 7				;cout << ascii

        mov     rax, SYS_exit				;terminate excuting process
        mov     rdi, EXIT_SUCCESS			;exit status
        syscall						;calling system services

; ascii to number function
toInteger:
	mov	rax, 0					;clear rax
	mov	rdi, 10					;rdi = 10
	mov	rsi, 0					;counter = rsi = 0
next0:
	and	byte[rbx+rsi], 0fh			;convert ascii to number
	add	al, byte[rbx+rsi]			;al = number
	adc	ah, 0					;ah = 0
	cmp	rsi, 2					;compare rsi with 2
	je	skip0					;if rsi=2 goto skip0
	mul	edi					;edx:eax = eax * edi
skip0:
	inc	rsi					;rcx++
	cmp	rsi, 3					;compare rcx with 3
	jl	next0					;if rcx<3 goto next0
	mov	dword[n], eax				;n = ax
	ret

toRestore:
	mov	al, byte[rbx+rsi]			;load the numeric value
	or	al, 30h					;convert back to ASCII
	mov	byte[rbx+rsi], al			;store back
	inc	rsi					;increment index
	cmp	rsi, 3					;check if we processed 3 characters
	jl	toRestore				;if not, loop back
	ret

; calculation function
calculate:
next1:
	add	dword[sumN], ecx			;sumN += ecx
	inc	ecx					;cx++
	cmp	ecx, edi				;compare ecx and edi=100
	jbe	next1					;if(cx<=di) jump to next1
	ret

; converts sumN into ascii
toString:
	; Part A - Successive division
	mov 	eax, dword[sumN] 			;get integer
	mov 	rcx, 0 					;digitCount = 0
	mov 	ebx, 10 				;set for dividing by 10
divideLoop:
	mov 	edx, 0
	div 	ebx 					;divide number by 10
	push 	rdx 					;push remainder
	inc 	rcx 					;increment digitCount
	cmp 	eax, 0 					;if (result > 0)
	jne 	divideLoop 				;goto divideLoop

	; Part B - Convert remainders and store
	mov 	rbx, ascii 				;get addr of ascii
	mov 	rdi, 0 					;rdi = 0
popLoop:
	pop 	rax 					;pop intDigit
	add 	al, "0" 				;al = al + 0x30
	mov 	byte [rbx+rdi], al 			;string[rdi] = al
	inc 	rdi 					;increment rdi
	loop 	popLoop 				;if (digitCount > 0) goto popLoop
	mov 	byte [rbx+rdi], 10 			;string[rdi] = newline
	ret
