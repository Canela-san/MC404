
# void play_note(int ch, int inst, int note, int vel, int dur);

.globl _start
.global play_note
.global _system_time

.section .bss
.align 4
isr_stack_end: # Final da pilha das ISRs
.skip 1024 # Aloca 1024 bytes para a pilha
isr_stack: # Base da pilha das ISRs

.section .bss
.align 4
user_stack_end: # Final da pilha das ISRs
.skip 1024 # Aloca 1024 bytes para a pilha
user_stack: # Base da pilha das ISRs

.section .bss
.align 4
_system_time: .word 0x0

.section .text
.align 2

_start:

    la sp, user_stack
    la t0, isr_stack
    csrw mscratch, t0

    # Habilita Interrupções Externas
    csrr t1, mie # Seta o bit 11 (MEIE)
    li t2, 0x800 # do registrador mie
    or t1, t1, t2
    csrw mie, t1
    
    # Habilita Interrupções Global
    csrr t1, mstatus # Seta o bit 3 (MIE)
    ori t1, t1, 0x8 # do registrador mstatus
    csrw mstatus, t1

    la t0, main_isr # Grava o endereço da ISR principal
    csrw mtvec, t0 # no registrador mtvec
    li s0, 0xFFFF0300 # MIDI Synthesizer
    li s1, 0xFFFF0100 # General Purpose Timer

    li t2, 100
    sw t2, 0x08(s1) # Configura o GPT para gerar interrupção a cada 100 ms

    jal main


play_note:
    li s0, 0xFFFF0300
    sh a1, 0x02(s0)
    sb a2, 0x04(s0)
    sb a3, 0x05(s0)
    sh a4, 0x06(s0)
    sb a0, 0x00(s0)
    ret

main_isr:
    # Salvar o contexto
    csrrw sp, mscratch, sp # Troca sp com mscratch
    addi sp, sp, -8 # Aloca espaço na pilha da ISR
    sw a0, 0(sp) # Salva a0
    sw a1, 4(sp) # Salva a1
   
    la a0, _system_time
    lw a1, 0(a0)
    addi a1, a1, 100
    sw a1, 0(a0)    

    li s1, 0xFFFF0100 # General Purpose Timer
    li a1, 100
    sw a1, 0x08(s1)

    lw a1, 4(sp) # Recupera a1
    lw a0, 0(sp) # Salva a0
    addi sp, sp, 8 # Desaloca espaço da pilha da ISR
    csrrw sp, mscratch, sp # Troca sp com mscratch novamente
    mret # Retorna da interrupção
