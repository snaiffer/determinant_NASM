section	.data
	SYS_EXIT		equ	1
	SYS_WRITE	equ	4
	SYS_READ		equ	3
	STDIN			equ	2
	STDOUT		equ	1

	dimen				db	0
	miss				db 0
	print_invert	db	0	; for print_num procedure: if you want inverted output set it to 1

; Messages
	msg_intro db 'The program for calculating the determinant of the matrix', 0xa, 0xa
	msg_intro_len	equ	$ - msg_intro

	msg_dimen db 'Dimension of the matrix = '
	msg_dimen_len	equ	$ - msg_dimen

	msg_GenInvit db 0xa, 'Input values for elements of the matrix:', 0xa
	msg_GenInvit_len	equ	$ - msg_GenInvit

	msg_invit1 db 'matrix['
	msg_invit1_len	equ	$ - msg_invit1

	msg_invit2 db ']['
	msg_invit2_len	equ	$ - msg_invit2

	msg_invit3 db '] = '
	msg_invit3_len	equ	$ - msg_invit3

	msg_IncorInput db 'The value is not correct. Try again: '
	msg_IncorInput_len	equ	$ - msg_IncorInput


	matrix	times 16 dw '0'

section	.bss
	i		resb	1
	j		resb	1
	num	resw	1
	temp	resb	1
	rank	resb	1
	cur_rank	resb	1
	nod	resb	1
	tempd	resd	1




section	.text
    global  _start    ;must be declared for linker (ld)
	 _start:    ;tell linker entry point

	 mov	eax, SYS_WRITE
	 mov	ebx, STDOUT
	 mov	ecx, msg_intro
	 mov	edx, msg_intro_len
	 int	0x80

	 mov	eax, SYS_WRITE
	 mov	ebx, STDOUT
	 mov	ecx, msg_dimen
	 mov	edx, msg_dimen_len
	 int	0x80

	 call read_num
	 mov [dimen], al

	 lea esi, [matrix]
	 mov byte [i], 0
	 mov byte [j], 0

	 mov al, [dimen]
	 mov dl, [dimen]
	 mul dl
	 mov cl, dl

	 L2:
		pusha

		 mov	eax, SYS_WRITE
		 mov	ebx, STDOUT
		 mov	ecx, msg_invit1
		 mov	edx, msg_invit1_len
		 int	0x80

		 mov al, [i]
		 call print_num

		 mov	eax, SYS_WRITE
		 mov	ebx, STDOUT
		 mov	ecx, msg_invit2
		 mov	edx, msg_invit2_len
		 int	0x80

		 mov al, [j]
		 call print_num

		 mov	eax, SYS_WRITE
		 mov	ebx, STDOUT
		 mov	ecx, msg_invit3
		 mov	edx, msg_invit3_len
		 int	0x80

		 call read_num
		 mov [esi+2], al

		 mov al, [num]
		 call print_num

		popa
	 dec cl
	 JNZ L2


		mov	eax,1       ;system call number (sys_exit)
		int	0x80        ;call kernel






print_num:
	cmp al, 0
		JE print_0

	mov [num], al

	mov byte [nod], 0
	mov [tempd], esp

	extract_no:
		cmp word [num], 0
			JE print_no

		inc byte [nod]
		mov dx, 0
		mov ax, word [num]
		mov bx, 10
		div bx
		push dx

		mov word [num], ax

		JMP extract_no

	print_no:
		cmp byte [nod], 0
			JE end_print

		dec byte [nod]

		cmp byte [print_invert], 1
			JE invert
		pop dx
		JMP not_invert
		invert:
			mov ebp, esp
			mov al, [nod]
			mov dx, [ebp + eax*2]
		not_invert:

		mov byte [temp], dl

		add byte [temp], '0'
		mov eax, SYS_WRITE
		mov ebx, STDOUT
		mov ecx, temp
		mov edx, 1
		int 0x80

		JMP print_no

	end_print:
	mov esp, [tempd]
	ret

	print_0:
		mov byte [temp], '0'
		mov eax, SYS_WRITE
		mov ebx, STDOUT
		mov ecx, temp
		mov edx, 1
		int 0x80
	ret



read_num:
		 mov byte [miss], 0
		 mov byte [rank], 0
		 mov byte [cur_rank], 0
	read_NewChar:
		 mov	eax, SYS_READ
		 mov	ebx, STDIN
		 mov	ecx, temp
		 mov	edx, 1
		 int	0x80


		 cmp byte [miss], '1'
			JE not_num

		 cmp byte [temp], '0'
			JL not_num
		 cmp byte [temp], '9'
			JG not_num

		 mov al, byte [temp]
		 push ax

		 inc byte [rank]

		 JMP read_NewChar

	not_num:
		 cmp byte [temp], 0xa
			 JE end_read

		 mov byte [miss], 1

		 JMP read_NewChar

	end_read:
		 cmp byte [miss], 0
			JNE input_error

		 cmp byte [rank], 0
			JE input_error

	get_new_rank:
		 pop dx

		 sub dl, '0'	;convert from ascii to decimal

		 cmp byte [cur_rank], 0
			 JG cur_rank_more_0

		 mov bl, dl
		 mov [num], bl

		 JMP cur_rank_0


	cur_rank_more_0:
		 mov al, 1
		 mov cl, [cur_rank]
		 L1:
			 mov bl, 10
			 mul bl
		 dec cl
		 JNZ L1

		 mul dl

		 add [num], ax

	cur_rank_0:
		 inc byte [cur_rank]

		 mov al, [rank]
		 cmp byte [cur_rank], al
			JNE get_new_rank

		mov al, [num]
	ret

	input_error:
			 mov	eax, SYS_WRITE
			 mov	ebx, STDOUT
			 mov	ecx, msg_IncorInput
			 mov	edx, msg_IncorInput_len
			 int	0x80
			 JMP read_num




