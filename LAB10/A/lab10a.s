.globl linked_list_search  
.globl puts
.globl gets
.globl atoi
.globl itoa
.globl exit


# puts:
# gets:
# atoi:
# itoa:
# exit:


linked_list_search:
    addi  sp, sp, -16      
    sw    ra, 12(sp)       
    sw    s0, 8(sp)        

    li    s0, 0          

loop:
    beqz  a0, not_found      
    lw    t0, 0(a0)      
    lw    t1, 4(a0)   
    add   t2, t0, t1       
    beq   t2, a1, found     
    lw    a0, 8(a0)         
    addi  s0, s0, 1        
    j     loop          

not_found:
    li    a0, -1        
    j     end             

found:
    mv    a0, s0             

end:
    lw    ra, 12(sp)      
    lw    s0, 8(sp)        
    addi  sp, sp, 16         
    ret                    

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------

atoi:
    li t0, 0          #t0
    li t1, 0          #sinal
    li t2, 10         #base

    # Ignora espaços em branco no início
skip_spaces:
    lbu t3, 0(a0) 
    beqz t3, end_atoi    
    li t4, 32     
    beq t3, t4, skip_next 
    j check_sign 

skip_next:
    addi a0, a0, 1  
    j skip_spaces

check_sign:
    lbu t3, 0(a0)   
    li t4, 45   
    beq t3, t4, set_negative 
    li t4, 43        
    beq t3, t4, skip_sign 
    j convert_digits

set_negative:
    li t1, 1        
    j skip_sign

skip_sign:
    addi a0, a0, 1   

convert_digits:
    lbu t3, 0(a0)   
    beqz t3, apply_sign 
    li t4, 48     
    blt t3, t4, end_atoi  
    li t5, 57     
    bgt t3, t5, end_atoi  

    sub t3, t3, t4    
    mul t0, t0, t2   
    add t0, t0, t3   

    addi a0, a0, 1 
    j convert_digits

apply_sign:
    beqz t1, end_atoi     
    neg t0, t0       

end_atoi:
    mv a0, t0        
    ret           

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------

# itoa - Converte um número inteiro em uma string ASCII.
# a0: número inteiro a ser convertido
# a1: endereço da string de saída
# a2: base (por exemplo, 10 para decimal, 16 para hexadecimal)
# Retorna o endereço da string em a0 (mesmo valor recebido em a1).

itoa:
    addi sp, sp, -16        
    sw ra, 12(sp)         
    sw s0, 8(sp)             
    sw a0, 4(sp)            
    sw a1, 0(sp)           
    mv s0, a1           
    li t0, 0             
    li t1, 0             

    blt a0, zero, negative  
    j convert             

negative:
    neg a0, a0            
    li t1, 1               

convert:
    # Loop de conversão do número para a string
convert_loop:
    rem t2, a0, a2         
    div a0, a0, a2        
    addi t2, t2, '0'       
    li  t3, '9'
    addi t3, t3, 1           
    blt t2, t3, store  

    # Para bases maiores que 10, converter letras (A-F, a-f)
    addi t2, t2, 7          

store:
    sb t2, 0(s0)           
    addi s0, s0, 1          
    addi t0, t0, 1          
    bnez a0, convert_loop   

    # Se o número original era negativo, adicionar o sinal de menos
    beqz t1, done          
    li t2, '-'              
    sb t2, 0(s0)            
    addi s0, s0, 1          
    addi t0, t0, 1        

done:
    sb zero, 0(s0)           # Terminar a string com NULL ('\0')

    # Inverter a string (pois os dígitos foram armazenados de trás para frente)
    mv a1, s0              
    sub a1, a1, t0          
    mv a0, a1             

    # Restaurar registradores e encerrar
    lw ra, 12(sp)            
    lw s0, 8(sp)            
    addi sp, sp, 16          
    jr ra 

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------

gets:

    mv a1, a0           # buffer
    li a0, 0            # file descriptor = 0 (stdin)
    li a2, 20           # size - Reads 20 bytes.
    li a7, 63           # syscall read (63)
    ecall
    mv a0, a1           # a0 = buffer
    ret

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------

puts:
    mv t0, a0      
    li t1, 1           

find_length:
    lb t2, 0(t0)  
    beq t2, zero, end_length 
    addi t1, t1, 1     
    addi t0, t0, 1   
    j find_length  

end_length:

    # Substitui '\0' por '\n'
    li t2, '\n'
    sb t2, 0(t0) 

    # Prepara os argumentos para a chamada do syscall
    mv a1, a0          # a1: endereço da string (passado em a0)
    li a0, 1           # file descriptor = 1 (stdout)
    mv a2, t1          # a2: tamanho da string (em t1)
    li a7, 64          # syscall write (64)
    ecall              # Chama o syscall

    ret   

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------

exit: 
    li a0, 0
    li a7, 93 # exit
    ecall


.bss
input_address: .skip 0xAA
