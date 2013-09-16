numb: numb.asm
	nasm -f elf numb.asm 
	ld -m elf_i386 -s -o numb numb.o
	rm numb.o
