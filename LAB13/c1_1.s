.data
.global my_var
.align 2
my_var: .word 10       # int my_var (variável global inicializada de 32 bits com valor 10)

.text
.global increment_my_var
increment_my_var:
    la t0, my_var
    lw t1, 0(t0)
    addi t1, t1, 1
    sw t1, 0(t0)
    ret