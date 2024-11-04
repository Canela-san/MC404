.text
.global operation
operation:
    addi sp, sp, -28
    li a0, -14
    sw a0, 20(sp)
    li a0, 13
    sw a0, 16(sp)
    li a0, -12
    sw a0, 12(sp)
    li a0, 11
    sw a0, 8(sp)
    li a0, -10
    sw a0, 4(sp)
    li a0, 9
    sw a0, 0(sp)
    
    li a0, 1
    li a1, -2
    li a2, 3
    li a3, -4
    li a4, 5
    li a5, -6
    li a6, 7
    li a7, -8
    
    sw ra, 24(sp)
    jal ra, mystery_function
    lw ra, 24(sp)
    addi sp, sp, 28
    ret