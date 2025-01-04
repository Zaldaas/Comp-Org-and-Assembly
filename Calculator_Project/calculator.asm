; CPSC 240 Final Project - calculator.asm

section .bss
input		resb	256					; Reserve space for input string
result		resd	1					; Result storage (integer)

section .data
LF		equ	10
NULL		equ	0
SYS_exit	equ	60
EXIT_SUCCESS	equ	0
prompt		db	"Enter Operations String: ", ' ', NULL
invalid_error	db	"Error: Invalid input", NULL
negative_error	db	"Error: Negative result", NULL
div_zero_error	db	"Error: Division by zero", NULL
overflow_error	db	"Error: Overflow", NULL
newline		db	LF, NULL
equation_equals db	" = ", NULL

section .text
	global _start

_start:
	; Print the prompt message
	mov	eax, 4						; sys_write
	mov	ebx, 1						; file descriptor (stdout)
	mov	ecx, prompt
	mov	edx, 25						; length of prompt string
	int	0x80

	; Read user input
	mov	eax, 3						; sys_read
	mov	ebx, 0						; file descriptor (stdin)
	mov	ecx, input
	mov	edx, 256					; buffer length
	int 0x80

	; Initialize index and result
	mov	esi, input
	call	next_number					; Get first number as initial result
	mov	[result], eax

parse_loop:
	; Get the next character
	lodsb
	cmp	al, 10						; Newline
	je	print_result
	cmp	al, 0						; Null terminator
	je	print_result

	; Determine the operator
	call	evaluate_operation
	jmp	parse_loop

evaluate_operation:
	cmp	al, '+'
	je	add_operation
	cmp	al, '-'
	je	sub_operation
	cmp	al, '*'
	je	mul_operation
	cmp	al, '/'
	je	div_operation
	jmp	error

add_operation:
	call	next_number
	add	[result], eax
	jo	overflow_output
	ret

sub_operation:
	call	next_number
	sub	[result], eax
	jo	overflow_output
	ret
	
mul_operation:
	call	next_number
	mov	ebx, [result]					; Load the value from result into ebx
	imul	ebx, eax					; Multiply ebx by eax
	jo	overflow_output
	mov	[result], ebx					; Store the result back into the memory location
	ret

div_operation:
	call	next_number
	mov	ebx, eax					; Store the next number in ebx (divisor)
	test	ebx, ebx					; Check if the divisor is zero
	jz	div_zero_output					; Jump if zero

	mov	eax, [result]					; Load the current result into eax (dividend)
	xor	edx, edx					; Clear edx for division
	div	ebx						; Divide eax by ebx
	jo	overflow_output
	mov	[result], eax					; Store the result back
	ret

next_number:
	; Extract the next numeric value (single digit 0-9)
	lodsb
	sub	al, '0'
	cmp	al, 0
	jl	error
	cmp	al, 9
	jg	error
	movzx	eax, al
	ret

print_result:
	; Find the length of the input without the newline
	mov	esi, input
	mov	ebx, 256					; Maximum input length

find_end_of_input:
	cmp	byte [esi], 10					; Check for newline
	je	newline_found
	cmp	byte [esi], 0					; Check for null terminator
	je	end_of_input_found
	inc	esi
	dec	ebx
	jnz	find_end_of_input

newline_found:
	mov	byte [esi], 0					; Null-terminate at the newline
	dec	esi						; Move back to last valid char if newline present

end_of_input_found:
	; Calculate the length from the start of the input to the last valid character
	inc	esi						; Move esi to include last char before the null/newline
	mov	edx, esi					; Move end position to edx
	sub	edx, input					; Subtract start pos from end pos to find length

	; Print the user input without the trailing newline
	mov	eax, 4
	mov	ebx, 1
	mov	ecx, input
	int	0x80

	; Print '=' with space
	mov	eax, 4
	mov	ebx, 1
	mov	ecx, equation_equals
	mov	edx, 3						; Length of the " = " string
	int	0x80

	; Check and print the result
	mov	eax, [result]
	cmp	eax, 0
	jl	negative_output
	call	print_integer
	jmp	exit_program

print_integer:
	; Convert integer in EAX to string representation
	mov	edi, 10
	mov	ecx, newline + 1				; Start writing at newline position + 1
	mov	byte [ecx], 0

print_integer_loop:
	xor	edx, edx
	div	edi
	add	dl, '0'
	dec	ecx
	mov	[ecx], dl
	test	eax, eax
	jnz	print_integer_loop

	; Append newline after the integer string
	mov	byte [newline + 1], 10				; newline character
	mov	byte [newline + 2], 0				; null terminator

	; Print the integer string with newline
	mov	eax, 4
	mov	ebx, 1
	lea	edx, [newline + 3]				; point just past the newline char
	sub	edx, ecx					; calculate length of number + newline
	int	0x80
	ret
	
print_error_newline:
	mov	eax, 4						; sys_write
	mov	ebx, 1						; file descriptor (stdout)
	mov	ecx, newline					; address of newline character
	mov	edx, 1						; length to write
	int	0x80
	ret

error:
	; Print error message and exit
	mov	eax, 4
	mov	ebx, 1
	mov	ecx, invalid_error
	mov	edx, 20
	int	0x80
	call	print_error_newline
	mov	eax, 1
	xor	ebx, ebx
	int	0x80

negative_output:
	mov	eax, 4
	mov	ebx, 1
	mov	ecx, negative_error
	mov	edx, 22						; Length of the negative error message
	int	0x80
	call	print_error_newline
	jmp	exit_program
	
div_zero_output:
	mov	eax, 4
	mov	ebx, 1
	mov	ecx, div_zero_error
	mov	edx, 23						; Length of the division by zero message
	int	0x80
	call	print_error_newline
	jmp	exit_program
	
overflow_output:
	mov	eax, 4
	mov	ebx, 1
	mov	ecx, overflow_error
	mov	edx, 15						; Length of the overflow error message
	int	0x80
	call	print_error_newline
	jmp	exit_program
	
exit_program:
	; Exit program
	mov     rax, SYS_exit				;terminate excuting process
	mov     rdi, EXIT_SUCCESS			;exit status
	syscall						;calling system services

