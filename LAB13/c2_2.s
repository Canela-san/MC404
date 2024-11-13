.text
.global middle_value_int
.global middle_value_short
.global middle_value_char
.global value_matrix


middle_value_int:
    srli a1, a1, 1
    slli a1, a1, 2
    add a0, a0, a1
    lw a0, 0(a0)
    ret

middle_value_short:
    srli a1, a1, 1
    slli a1, a1, 1
    add a0, a0, a1
    lw a0, 0(a0)
    ret

middle_value_char:
    srli a1, a1, 1
    add a0, a0, a1
    lw a0, 0(a0)
    ret

value_matrix:
    li t0, 168
    mul a1, a1, t0
    slli a2, a2, 2
    add a1, a1, a2
    add a0, a0, a1
    lw a0, 0(a0)
    ret

