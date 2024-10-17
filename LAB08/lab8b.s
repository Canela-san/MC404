.data
input_file: .asciz "image.pgm"

.bss
b: .space 12312
buffer: .space 262159
canvasSize: .space 929292


.text
.globl _start

.align 2
open:
    la a0, input_file    # address for the file path
    li a1, 0             # flags (0: rdonly, 1: wronly, 2: rdwr)
    li a2, 0             # mode
    li a7, 1024          # syscall open
    ecall
    ret

.align 2
sys_write:
# syscall para escrever na tela (sys_write)
    li a7, 64             # Número da chamada de sistema para sys_write
    li a0, 1              # File descriptor para stdout (1)
    la a1, b         # Endereço do buffer com a entrada do usuário
    li a2, 20             # Número de bytes a serem escritos (pode ser menor se menos bytes forem lidos)
    ecall                 # Chamada de sistema
    jr s11

.align 2
setCanvasSize:
    la t0, canvasSize
    lw a0, 0(t0)
    lw a1, 4(t0)
    li a7, 2201
    ecall

.align 2
setPixel:
    la t0, canvasSize
    lw t1, 0(t0)
    lw t2, 4(t0)
    rem a0, s2, t1
    div a1, s2, t1
    
    mv a3, a2
    
    slli a2, a2, 8
    or a2, a2, a3
    
    slli a2, a2, 8
    or a2, a2, a3

    slli a2, a2, 8
    ori a2, a2, 0x000000FF

    li a7, 2200 # syscall setPixel (2200)
    ecall
    ret

.align 2
read:
    la a1, buffer
    mv a0, s0
    li a2, 262159    # size
    li a7, 63   # syscall read (63)
    ecall
    ret

.align 2


get_value:
    /Receives x(a2),y(a3) and returns the value in [x,y]/
    la t1, canvasSize
    lw t2, 0(t1)    //width
    mul t2, t2, a3  //y*Width
    add t2, t2, a2  //y*width + x
    add t2, t2, s1  //y*width + x + base_pointer
    lbu t1, 0(t2)
    jr gp

.align 2
_start:
    jal open
    mv s0, a0
    jal read

    la s1, buffer
    la s2, canvasSize
    addi s1, s1, 3

    li s3, 0
    jal sp, check
    sw s3, 0(s2)

    li s3, 0
    jal sp, check
    sw s3, 4(s2)

    addi s1,s1,4

    jal setCanvasSize

    li s2, 0    //Contador

    jal sp, loop

exit:
    li a0, 0
    li a7, 93 # exit
    ecall

check:
    lbu a0, 0(s1)
    addi s1, s1, 1
    li t0, ' '
    beq t0, a0, done_loop
    li t0, '\n'
    beq t0, a0, done_loop
    addi a0,a0,-'0'
    li t0,10
    mul s3, s3, t0
    add s3, s3, a0
    j check

loop:
    la t0, canvasSize
    lw t1, 0(t0)    //Widht
    lw t2, 4(t0)    //Height
    mul t0, t1, t2  //Num itens
    beq s2, t0, done_loop

    rem a0, s2, t1  //j
    div a1, s2, t1  //i

    //Checking border
    beq a0, zero, border
    beq a1, zero, border
    addi t5, t1, -1
    beq a0, t5, border
    addi t5, t2, -1
    beq a1, t5, border
    
    //If not:
    li s6, 0
    jal sum_out
    li t0, 0
    blt s6, t0, blw_0
    li t0, 255
    bge s6, t0, big_m
    mv a2, s6
    jal setPixel
    addi s2, s2, 1
    j loop

    big_m:
        li a2, 255
        jal setPixel
        addi s2, s2, 1
        j loop

    blw_0:
        li a2, 0
        jal setPixel
        addi s2, s2, 1
        j loop

    //If yes
    border:
        li a2, 0
        jal setPixel
        addi s2, s2, 1
        j loop

sum_out:
    addi t1, a0, -1
    mv a2, t1
    mv a3, a1
    jal gp, get_value
    add s6, s6, t1

    addi t1, a0, 1
    mv a2, t1
    mv a3, a1
    jal gp, get_value
    add s6, s6, t1

    addi t1, a1, -1
    mv a3, t1
    mv a2, a0
    jal gp, get_value
    add s6, s6, t1

    addi t1, a1, 1
    mv a3, t1
    mv a2, a0
    jal gp, get_value
    add s6, s6, t1

    addi t1, a1, -1
    addi t2, a0, -1
    mv a3, t1
    mv a2, t2
    jal gp, get_value
    add s6, s6, t1

    addi t1, a1, 1
    addi t2, a0, -1
    mv a3, t1
    mv a2, t2
    jal gp, get_value
    add s6, s6, t1

    addi t1, a1, -1
    addi t2, a0, 1
    mv a3, t1
    mv a2, t2
    jal gp, get_value
    add s6, s6, t1

    addi t1, a1, 1
    addi t2, a0, 1
    mv a3, t1
    mv a2, t2
    jal gp, get_value
    add s6, s6, t1

    mv a2, a0
    mv a3, a1
    jal gp, get_value
    slli t1, t1, 3

    sub s6, t1, s6
    jr ra

done_loop:
    jr sp
done_tp:
    j tp