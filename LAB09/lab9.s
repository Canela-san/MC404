 .globl _start  

_start:
    jal read
    jal ascii_to_int
    li t3, 0 #Contador de nós
    la t0, head_node # Endereço inicial
loop_search:

    lw t1, 0(t0)
    lw t2, 4(t0)
    add t1, t1, t2
    beq a0, t1, resposta
    addi t3, t3, 1
    lw t0, 8(t0)
    bne t0, x0, loop_search
    la t2, result
    li t3, '-'
    sb t3, 0(t2)
    li t3, '1'
    sb t3, 1(t2)
    li t3, '\n'
    sb t3, 2(t2)
    li a2, 3
    la a1, result
    j end
    
resposta:
    li t6, 10
    li a0, 0 
    mv t0, t3
    la a1, result 
    beq t0, x0, convert_zero 

convert:
    li t1, 0
    li t2, 1000           
    li t4, 0            
    li a2, 0              # Inicializa a2 com 0 para contar o número de bytes

    # Loop para converter cada dígito decimal
convert_decimal_loop:
    beq t2, zero, end
    div t4, t0, t2              
    rem t0, t0, t2              
    addi t4, t4, 48             
    sb t4, 0(a1)                
    addi a1, a1, 1              # Avança o endereço da memória para o próximo caractere
    addi a2, a2, 1              # Incrementa a contagem de bytes
    div t2, t2, t6              # Reduz t2 por um fator de 10 para o próximo dígito
    bne t2, zero, convert_decimal_loop  

    # Adiciona o terminador '\n'
    li t4, '\n'                  
    sb t4, 0(a1)                
    addi a2, a2, 1              # Incrementa a contagem de bytes
    
    
    la a1, result
    addi a1, a1, -1
    li t1, '0'
    loop_print:
    addi a1, a1, 1
    lb t0, 0(a1)
    beq t0, t1, loop_print 
    
    j end                

convert_zero:
    li t4, '0'                   
    sb t4, 0(a1)               
    addi a1, a1, 1              # Avança para o próximo byte
    li t4, '\n' 
    sb t4, 0(a1)      
    la a1, result
    li a2, 2                    # Contagem de bytes para '0' e '\n'
    j end                       # Fim da execução


end:
    jal write
    li a0, 0
    li a7, 93 # exit
    ecall

read:
    li a0, 0            # file descriptor = 0 (stdin)
    la a1, input_address # buffer
    li a2, 7           # size
    li a7, 63           # syscall read (63)
    ecall
    ret

write:
    li a0, 1            # file descriptor = 1 (stdout)
    li a7, 64           # syscall write (64)
    ecall
    ret

ascii_to_int:
    la t0, input_address 
    li a1, 0
    li t1, 1 

    # Verificar se o número é negativo
    lb t2, 0(t0)         
    li t3, 45        
    beq t2, t3, is_negative
    j convert_number

is_negative:
    li t1, -1
    addi t0, t0, 1       # Avança o ponteiro para ignorar o '-'

convert_number:
    # Loop para converter cada dígito
convert_loop:
    lb t2, 0(t0)         # Carregar caractere atual (ASCII)
    li t3, '0' 
    li t4, '9'
    blt t2, t3, end_conversion 
    bgt t2, t4, end_conversion

    # Converter o caractere de ASCII para número
    sub t2, t2, t3      
    li t3, 10
    mul a1, a1, t3
    add a1, a1, t2   

    # Avança para o próximo caractere
    addi t0, t0, 1
    j convert_loop       # Repetir o loop para o próximo dígito

end_conversion:
    mul a0, a1, t1       # Multiplica pelo sinal (positivo ou negativo)
    # Retornar o resultado em a0
    ret

.bss

input_address: .skip 0x7

result: .skip 0x5