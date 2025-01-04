; ex_hello.asm
; char text[] = "Hello, World!\n"
; cout << text;

section .data
	LF equ 10
	NULL equ 0
	SYS_exit equ 60
	EXIT_SUCCESS equ 0
	text db "Hello, World!", LF, NULL
	
section .text
	global _start
_start:
	mov rax, 1
	mov rdi, 1
	mov rsi, text
	mov rdx, 14
	syscall
	
	mov rax, SYS_exit
	mov rdi, EXIT_SUCCESS
	syscall
