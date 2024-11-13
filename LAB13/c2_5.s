.text
.global node_creation
node_creation:
    addi sp, sp, -12
    li a0, 30
    sw a0, 0(sp)
    li a0, 25
    sb a0, 4(sp)
    li a0, 64
    sb a0, 5(sp)
    li a0, -12
    sh a0, 6(sp)
    sw ra, 8(sp)
    mv a0, sp
    jal mystery_function
    lw ra, 8(sp)
    addi sp, sp, 12
    ret