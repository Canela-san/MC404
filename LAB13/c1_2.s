.text
.global my_function

#memória: first value, second value, third value, sum 1, call 1, diff 1, sum 2, ra. total of 8 values = 32 bytes
my_function:
    addi sp, sp, -32 # alocanto toda a pilha que será usada logo de inicio (32 bytes) já que a quantidade é fixa.
    sw a2, 28(sp) #third value
    sw a1, 24(sp) #second value
    sw a0, 20(sp) #first value
    mv a2, a0
    add a0, a0, a1
    mv a1, a2
    sw a0, 16(sp) #sum 1

    #a0 e a1 já são os parametros da mystery_function.
    #salva o ra e chama outra rotina
    
    
    sw ra, 12(sp)
    jal mystery_function
    lw ra, 12(sp)
    
    sw a0, 12(sp) #call 1
    lw a1, 24(sp)
    sub a0, a1, a0
    sw a0, 8(sp) # diff 1
    lw a1, 28(sp)
    add a0, a0, a1
    sw a0, 4(sp) # sum 2
    lw a1, 24(sp)

    sw ra, 0(sp)
    jal mystery_function
    lw ra, 0(sp)
    lw a1, 28(sp)
    sub a0, a1, a0
    lw a1, 4(sp)
    add a0, a0, a1 # sum 3
    addi sp, sp, 32
    ret