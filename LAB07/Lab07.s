.bss
.align 2
input_address: .skip 0x1F  # buffer para 13 bytes (5 da 1ª linha + 8 da 2ª linha)
.align 2
result: .skip 0x1F         # buffer de 13 bytes para a saída (caso precise manipular a entrada)
.align 2
.text
.global _start  
.align 2
_start:
    jal read

        # Convert the ASCII input into actual bits
    la a0, input_address    # t0 points to input buffer
    
    lb t0, 0(a0)         #(d1)
    lb t1, 1(a0)         #(d2)
    lb t2, 2(a0)         #(d3)
    lb t3, 3(a0)         #(d4)

    #Converte para inteiro
    addi t0, t0, -48      
    addi t1, t1, -48
    addi t2, t2, -48
    addi t3, t3, -48

    # Encoding using Hamming(7,4)
    # p1 = d1 XOR d2 XOR d4
    xor t4, t0, t1       # t5 = d1 XOR d2
    xor t4, t4, t3       # t5 = (d1 XOR d2) XOR d4

    # p2 = d1 XOR d3 XOR d4
    xor t5, t0, t2       # t6 = d1 XOR d3
    xor t5, t5, t3       # t6 = (d1 XOR d3) XOR d4

    # p3 = d2 XOR d3 XOR d4
    xor t6, t1, t2       # t7 = d2 XOR d3
    xor t6, t6, t3       # t7 = (d2 XOR d3) XOR d4


#Voltando para char
    addi t0, t0, 48      
    addi t1, t1, 48
    addi t2, t2, 48
    addi t3, t3, 48
    addi t4, t4, 48      
    addi t5, t5, 48
    addi t6, t6, 48

#escrever na memória
    la a0, result
    #p1p2d1p3d2d3d4
    sb t4, 0(a0) #p1
    sb t5, 1(a0) #p2
    sb t0, 2(a0) #d1
    sb t6, 3(a0) #p3
    sb t1, 4(a0) #d2
    sb t2, 5(a0) #d3
    sb t3, 6(a0) #d4
    
    li t0, 10        # Carrega o valor ASCII de '\n' (10) no registrador t0
    sb t0, 7(a0)

    # Carrega a segunda entrada nos registradores
    la a0, input_address
    lb t0, 7(a0)            #(d1)
    lb t1, 9(a0)            #(d2)
    lb t2, 10(a0)           #(d3)
    lb t3, 11(a0)           #(d4)
    lb t4, 5(a0)            #(p1)
    lb t5, 6(a0)            #(p2)
    lb t6, 8(a0)            #(p3)


    #store
    la a0, result
    sb t0, 8(a0)     #d1
    sb t1, 9(a0)     #d2
    sb t2, 10(a0)    #d3
    sb t3, 11(a0)    #d4
    li a1, 10        # Carrega o valor ASCII de '\n' (10) no registrador t0
    sb a1, 12(a0)

    #convert to int:
    addi t0, t0, -48 #(d1)
    addi t1, t1, -48 #(d2)
    addi t2, t2, -48 #(d3)
    addi t3, t3, -48 #(d4)
    addi t4, t4, -48 #(p1)
    addi t5, t5, -48 #(p2)
    addi t6, t6, -48 #(p3)

    #Verifica o erro
    #A combinação xor de todos os valores
    xor t4, t4, t0     
    xor t4, t4, t1     
    xor t4, t4, t3      

    xor t5, t5, t0      
    xor t5, t5, t2      
    xor t5, t5, t3     

    xor t6, t6, t1      
    xor t6, t6, t2      
    xor t6, t6, t3    

    or t4, t4, t5
    or t4, t4, t6
    
    addi t4, t4, 48
    sb t4, 13(a0) 
    li a1, 10        # Carrega o valor ASCII de '\n' (10) no registrador t0
    sb a1, 14(a0)

    jal write
    li a0, 0
    li a7, 93 # exit
    ecall


write:
    li a0, 1               # file descriptor = 1 (stdout)
    la a1, result    # buffer onde está a entrada lida (escrevendo o mesmo conteúdo de volta)
    li a2, 15              # escreve 15 bytes (o conteúdo completo lido)
    li a7, 64              # syscall write (64)
    ecall
    ret


read:
    li a0, 0               # file descriptor = 0 (stdin)
    la a1, input_address    # buffer onde a entrada será armazenada
    li a2, 5              # lê 13 bytes (4 bits + \n da 1ª linha e 7 bits + \n da 2ª linha)
    li a7, 63              # syscall read (63)
    ecall
    li a0, 0
    la a1, input_address  
    addi a1, a1, 5
    li a2, 8              # lê 13 bytes (4 bits + \n da 1ª linha e 7 bits + \n da 2ª linha)
    li a7, 63
    ecall
    ret