.text
.global fill_array_int
.global fill_array_short
.global fill_array_char


fill_array_int:
    addi sp, sp, -404
    mv a0, sp
    li t0, 0
    li t1, 100
    1:
    slli t2, t0, 2
    add t3, t2, sp
    sw t0, 0(t3)
    addi t0, t0, 1
    blt t0, t1, 1b
    sw ra, 400(sp)
    jal mystery_function_int
    lw ra, 400(sp)
    addi sp, sp, 404
    ret

fill_array_short:
    addi sp, sp, -204
    mv a0, sp
    li t0, 0
    li t1, 100
    1:
    slli t2, t0, 1
    add t3, t2, sp
    sw t0, 0(t3)
    addi t0, t0, 1
    blt t0, t1, 1b
    sw ra, 200(sp)
    jal mystery_function_short
    lw ra, 200(sp)
    addi sp, sp, 204
    ret
    
fill_array_char:
    addi sp, sp, -104
    mv a0, sp
    li t0, 0
    li t1, 100
    1:
    add t2, t0, sp
    sw t0, 0(t2)
    addi t0, t0, 1
    blt t0, t1, 1b
    sw ra, 100(sp)
    jal mystery_function_char
    lw ra, 100(sp)
    addi sp, sp, 104
    ret
