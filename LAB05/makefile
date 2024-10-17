lab4.x: lab4.o
	ld.lld lab4.o -o lab4.x

lab4.s: lab4.c
	clang --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax lab4.c -S -o lab4.s

lab4.o: lab4.s
	clang --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax lab4.s -c -o lab4.o


