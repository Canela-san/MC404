.globl _start  
Peripherals: .word 0xFFFF0300
la s6, Peripherals
lw s6, 0(s6)
_start:
    li t0, 0 #contagem de caractere
    li t1, 0 # contagem de \n
    li t2, '\n'
    la s1, buffer
    addi s1, s1, -1

#Leitura byte a byte, salva em S1
    read_loop:
    addi t0, t0, 1
    addi s1, s1, 1
    jal read
    lb t3, 0(s1)
    bne t3, t2, read_loop

    count_n:
    addi t1, t1, 1
    li t3, 2
    bne t1, t3, read_loop
    mv s0, t0
    
    la s1, buffer
    la s2, result
    lb a0, 0(s1)
    addi a0, a0, -48
    addi s1, s1, 2
    addi s0, s0, -2

#caso 1 (não presisa fazer nada, ele vai escrever o que está em s1)
    li t0, 1
    bne a0, t0, 1f

#caso 2, inverte o que está em s1 e salva em s2
    1:
    li t0, 2
    bne a0, t0, 1f
    addi t0, s0, -1
    mv t1, s1            
    mv t2, s2            
    2:
    lb t3, 0(t1)         
    add t4, t0, s2          
    sb t3, 0(t4)          
    addi t1, t1, 1           
    addi t0, t0, -1        
    bnez t0, 2b         
    li t0, '\n'
    add t1, s2, s0
    sb t0, 0(t1)
    addi s0, s0, 1
    la s1, result

#caso 3 converte para hex o que esta no s1 
    1:
    li t0, 3
    bne a0, t0, 1f
    li t4, 0
    li t5, 10
    addi t0, s0, -1
    mv t1, s1
    mv t2, s2
    3:
    mul t4, t4, t5
    lb t3, 0(t1)
    addi t0, t0, -1
    addi t1, t1, 1
    addi t3, t3, -48
    add t4, t4, t3
    bnez t0, 3b

    li s0, 0 # contador
    la s1, buffer        

    li t0, 0              
    li t1, 16            

    convert_loop:
 
    beq t4, zero, finish_zero

  
    rem t2, t4, t1        
    li t3, 10            
    blt t2, t3, to_digit   
    addi t2, t2, 87       
    j store_character

    to_digit:
    addi t2, t2, 48      

    store_character:
    sb t2, 0(s1)        
    addi s0, s0, 1
    addi s1, s1, 1     
    div t4, t4, t1        
    j convert_loop      

    finish_zero:
    li t0, 0
    sb t0, 0(s1)
    addi s0, s0, 1
    addi s1, s1, 1
    finish_conversion:
 
    li t0, '\n'
    sb t0, 0(s1)     
    addi s0, s0, 1
    la s1, buffer
    la s2, result
    addi t0, s0, -1
    mv t1, s1            
    mv t2, s2            
    2:
    lb t3, 0(t1)         
    add t4, t0, s2          
    sb t3, 0(t4)          
    addi t1, t1, 1           
    addi t0, t0, -1        
    bnez t0, 2b         
    li t0, '\n'
    add t1, s2, s0
    sb t0, 0(t1)
    addi s0, s0, 1
    la s1, result


#caso 4 lê a equação faz o calculo, (a parte de converter para ascii está com bug, mas o resultado das contas está correto)
    1:
    li t0, 4
    bne a0, t0, 1f
    

    li t4, 0
    li t5, 10
    li t6, ' '

    mv t1, s1
    4:
    lb t3, 0(t1)
    addi t1, t1, 1
    beq t6, t3, 4f
    mul t4, t4, t5
    addi t3, t3, -48
    add t4, t4, t3
    j 4b
    4:
    lb a0, 0(t1)
    mv a1, t4
    li t4, 0
    addi t1, t1, 2
    li t6, '\n'
    4:
    lb t3, 0(t1)
    addi t1, t1, 1
    beq t6, t3, 4f
    mul t4, t4, t5
    addi t3, t3, -48
    add t4, t4, t3
    j 4b
    4:
    mv a2, t4
    li t0, '+'
    bne a0, t0, 4f
    add a0, a1, a2
    j fim
    4:
    li t0, '-'
    bne a0, t0, 4f
    li t0, -1
    mul a2, a2, t0
    add a0, a1, a2
    j fim
    4:
    li t0, '*'
    bne a0, t0, 4f
    mul a0, a1, a2
    j fim
    4:
    li t0, '/'
    bne a0, t0, 4f
    div a0, a1, a2
    j fim
    4:
    fim:

    la s1, buffer
  
    li t0, 0
    mv t0, a0      
    li s0, 0     
    li s2, 0

    convert_loop2:
    li t1, 10       
    div t2, t0, t1  
    rem t3, t0, t1 

    addi t3, t3, 48 
    add s2, s1, s0  
    
    sb t3, 0(s1)   
    addi t0, t0, 1

    mv t0, t2   
    addi s0, s0, 1 

    bnez t0, convert_loop2

    
    add s2, s1, s0
    li t0, '\n'
    sb t0, 0(s2)

    la s1, buffer

    1:
    jal write
    j exit




exit:
    li a0, 0
    li a7, 93 # exit
    ecall



# read:
#     li a0, 0       # file descriptor = 0 (stdin)
#     mv a1, s1      # buffer
#     li a2, 1       # size
#     li a7, 63      # syscall read (63)
#     ecall
#     ret

# write:
#     li a0, 1                # file descriptor = 1 (stdout)
#     mv a1, s1           # buffer
#     mv a2, s0          # size - Writes t0 bytes.
#     li a7, 64               # syscall write (64)
#     ecall
#     ret


#Não funciona com o serial não sei porque

read:
    li t6, 1
    sb t6, 0x02(s6)
    1:
    lb t6, 0x02(s6)
    bnez t6, 1b
    lb t6, 0x03(s6)
    sb t6, 0(s1)
    ret

write:
    li t0, 1
    li t2, '\n'
    1:
    lb t1, 0(s1)
    beq t1, t2, 1f
    sb t1, 0x01(s6)
    sb t0, 0x00(s6)
    addi s1, s1, 1
    2:
    lb t0, 0x00(s6)
    bnez t0, 2b
    j 1b
    1:
    ret



.bss
buffer: .skip 0xAA
result: .skip 0xAA

