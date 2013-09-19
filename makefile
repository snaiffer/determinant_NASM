det: det.asm
	nasm -f elf det.asm 
	ld -m elf_i386 -s -o det det.o
	rm det.o
