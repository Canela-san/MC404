main.x: main.o
	ld.lld main.o -o main.x

main.s: main.c
	clang --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax main.c -S -o main.s

main.o: main.s
	clang --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax main.s -c -o main.o


