numb: numb.s
	nasm -f elf numb.s 
	ld -m elf_i386 -s -o numb numb.o
	rm numb.o
