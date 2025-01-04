; #begin define print(string, numOfChar)
; 	rax = 1;
; 	rdi = 1;
; 	rsi = &string;
; 	rdx = numOfChar;
; 	syscall;
; #end
; #begin define scan(buffer, numOfChar)
; 	rax = 0;
; 	rdi = 0;
; 	rsi = &buffer;
; 	rdx = numOfChar;
; 	syscall;
; #end
; 
; char buffer[4];
; int n;
; int sumN;
; char msg1[26] = "Input a number (004~999): ";
; char msg2[16] = "1 + 2 + 3 +...+ ";
; char msg3[4] = " = ";
; char ascii[10];
; 
; print(msg1, 26);
; scan(buffer, 4);
; n = atoi(buffer);
; rsi = 0;
; do {
;     sumN += rsi;
; } while(rsi >= 0);
; ascii = itoa(sumN);
; print(msg2, 16);
; print(buffer, 3);
; print(msg3, 3);
; print(ascii, 7);

%macro	print 	2
        mov     rax, 1					; SYS_write
        mov     rdi, 1					; standard output device
        mov     rsi, %1					; output string address
        mov     rdx, %2					; number of characters
        syscall							; calling system services
%endmacro

%macro	scan 	2
        mov     rax, 0					; SYS_read
        mov     rdi, 0					; standard input device
        mov     rsi, %1					; input buffer address
        mov     rdx, %2					; number of characters
        syscall						; calling system services
%endmacro

section .bss
buffer	resb	4
n	resd	1
sumN	resd    1
ascii	resb    10

section .data
LF		equ	10
NULL		equ	0
SYS_exit	equ	60
EXIT_SUCCESS	equ	0
msg1	db	"Input a number (004~999): ", NULL
msg2	db      "1 + 2 + 3 +...+ ", NULL
msg3	db	" = ", NULL

section .text
        global _start
_start:
	print	msg1, 26				;cout << msg1
	scan	buffer, 4				;cin >> buffer
	mov	eax, 0					;clear eax
	mov	ebx, 10					;ebx = 10
	mov	rsi, 0					;counter = 0
inputLoop:
	and	byte[buffer+rsi], 0fh			;convert ascii to number
	add	al, byte[buffer+rsi]			;al = number
	adc	ah, 0					;ah = 0
	cmp	rsi, 2					;compare rcx with 2
	je	skipMul					;if rcx=2 goto skipMul
	mul	ebx					;edx:eax = eax * ebx
skipMul:
	inc	rsi					;rsi++
	cmp	rsi, 3					;compare rsi with 3
	jl	inputLoop				;if rsi<3 goto inputLoop
	mov	dword[n], eax				;n = eax

	mov 	rsi, 0                            	;reset index to 0
restoreLoop:
    	mov 	al, byte[buffer+rsi]          		;load the numeric value
    	or 	al, 30h                        		;convert back to ASCII
    	mov 	byte[buffer+rsi], al          		;store back
    	inc 	rsi                           		;increment index
    	cmp 	rsi, 3                        		;check if we processed three characters
    	jl restoreLoop                   		;if not, loop back
	
	; calculates 1+2+3+...+N
	mov	ecx, 0					;ecx = 0
sumLoop:
	add	dword[sumN], ecx			;sumN += ecx
	inc	ecx					;ecx++
	cmp	ecx, dword[n]				;compare ecx with n
	jbe	sumLoop					;if(ecx<=100) goto sumLoop

	; converts sumN into ascii
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
	mov 	byte [rbx+rdi], LF 			;string[rdi] = newline

	print	msg2, 16				;cout << msg2
	print	buffer, 3				;cout << buffer
	print	msg3, 3					;cout << msg3
	print	ascii, 7				;cout << ascii

        mov     rax, SYS_exit				;terminate excuting process
        mov     rdi, EXIT_SUCCESS			;exit status
        syscall						;calling system services
