 .globl _start

 .data

carro: .word 0xFFFF0100

xy_goal:.word 73
    .word 1

 .text

_start:
    la a6, carro
    lw a6, (a6)
    loop:
    jal get_coordinates
    jal set_direction
    li a4, 1
    sb a4, 0x21(a6)
    j loop

# exit:   
#     li a0, 0
#     li a7, 93 # exit
#     ecall

get_coordinates:

    li t1, 1
    sb t1, 0x00(a6)

    wait:
        lb t1, 0x00(t1)
        beqz t1, wait_end
        jal wait
    wait_end:

    lw a0, 0x10(a6) #gets x from car
    lw a1, 0x14(a6) #gets y from car
    ret

set_direction:
    #lógica para direção
    #mas para esse lab basta ficar travado no -15...
    li a4, -15
    sb a4, 0x20(a6)
    ret

# break:
#     li t0, 1
#     li t1, 0
#     sb t1, 0x21(a6)
#     sb t0, 0x22(a6)
#     j exit