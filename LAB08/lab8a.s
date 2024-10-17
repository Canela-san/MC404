.data
input_file: .asciz "image.pgm"    # Nome do arquivo que contém a imagem a ser lida.

.bss
input_buffer: .skip 262159        # Buffer onde o conteúdo do arquivo será armazenado, tamanho suficiente para a imagem.

.text
.globl _start
.align 2
_start:
    jal main                      # Pula para a função principal (main).
    li a0, 0                      # Define o código de saída como 0.
    li a7, 93                     # Syscall para encerrar o programa.
    ecall

.align 2
main:
    addi sp, sp, -4               # Reserva espaço na pilha para salvar o retorno.
    sw ra, 0(sp)                  # Salva o endereço de retorno.

    jal open                      # Abre o arquivo.
    jal read                      # Lê o conteúdo do arquivo.
    la s1, input_buffer           # Carrega o endereço do buffer onde os dados estão armazenados.

    # Leitura do cabeçalho da imagem
    addi s1, s1, 3  # Pula os primeiros 3 bytes (formato P5).

    li t1, '0'                    # Preparação para converter a largura do texto para número.
    li t2, 10                     # Base decimal.
    li s2, 0                      # Inicializa largura (s2) como zero.
1:
    mv a0, s2                     # Move o valor de s2 para a0.
    lbu t3, 0(s1)                 # Carrega o próximo byte da string.
    addi s1, s1, 1                # Incrementa o ponteiro do buffer.
    bgt t1, t3, 1f                # Se o byte não for um número, pula para o fim da conversão.
    addi t3, t3, -48              # Converte o caractere ASCII para seu valor numérico.
    mul s2, s2, t2                # Multiplica s2 por 10 (deslocamento da posição decimal).
    add s2, s2, t3                # Adiciona o dígito à largura (s2).
    j 1b                          # Continua o loop.
1:

    li t1, '0'                    # Preparação para converter a altura da imagem.
    li t2, 10
    li s3, 0                      # Inicializa altura (s3) como zero.
1:
    mv a0, s2
    lbu t3, 0(s1)
    addi s1, s1, 1
    bgt t1, t3, 1f
    addi t3, t3, -48
    mul s3, s3, t2                # Multiplica s3 por 10 (para leitura decimal da altura).
    add s3, s3, t3
    j 1b
1:

    addi s1, s1, 4 #255\n         # Pula a parte final do cabeçalho da imagem (valor máximo de cor).

    mv a0, s2                     # Passa a largura (s2) como argumento.
    mv a1, s3                     # Passa a altura (s3) como argumento.
    jal setCanvasSize             # Chama a função para configurar o tamanho da "tela".

test:

    li a1, 0                      # Inicializa a variável de controle de altura.
1:
    bge a1, s3, 1f                # Se a altura atingir o valor máximo, finaliza o loop.
    li a0, 0                      # Inicializa a variável de controle de largura.
2:
    bge a0, s2, 2f                # Se a largura atingir o valor máximo, vai para a próxima linha.

    lbu a2, 0(s1)                 # Carrega o valor de cor do próximo pixel.
    addi s1, s1, 1                # Avança para o próximo byte do buffer.
    jal set_pixel                 # Chama a função para desenhar o pixel.

    addi a0, a0, 1                # Incrementa a posição horizontal.
    j 2b                          # Continua o loop para a largura.
2:
    addi a1, a1, 1                # Incrementa a posição vertical.
    j 1b                          # Continua o loop para a altura.
1:

    lw ra, 0(sp)                  # Restaura o endereço de retorno.
    addi sp, sp, 4                # Libera o espaço da pilha.
    ret                           # Retorna da função.


# set_pixel
# params:
#   a0 -> coordenada x (horizontal)
#   a1 -> coordenada y (vertical)
#   a2 -> valor de cor (escala de cinza)
.align 2
set_pixel:
    mv a3, a2                     # Faz uma cópia do valor de cor.

    slli a2, a2, 8                # Ajusta o valor de cor para RGB (mantendo o cinza).
    or a2, a2, a3

    slli a2, a2, 8
    or a2, a2, a3

    slli a2, a2, 8
    ori a2, a2, 0x000000FF        # Preenche o último byte para manter a cor no formato RGBA.

    li a7, 2200                   # Syscall customizada para desenhar o pixel.
    ecall
    ret

# open
# returns:
#   a0 -> descritor de arquivo
.align 2
open:
    la a0, input_file             # Carrega o caminho do arquivo.
    li a1, 0                      # Somente leitura.
    li a2, 0                      # Modo padrão.
    li a7, 1024                   # Syscall para abrir arquivo.
    ecall
    ret

# read
# params:
#   a0 -> descritor de arquivo
.align 2
read:
    la a1, input_buffer           # Carrega o endereço do buffer.
    li a2, 262159                 # Tamanho a ser lido.
    li a7, 63                     # Syscall para leitura de arquivo.
    ecall
    ret

# setCanvasSize
# params: 
#   a0 -> largura da tela
#   a1 -> altura da tela
setCanvasSize:
    li a7, 2201                   # Syscall customizada para definir o tamanho da tela.
    ecall
    ret
