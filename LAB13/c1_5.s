# int operation(int a, int b, int c, int d, int e, int f, int g, int h, int i, int j, int k, int l, int m, int n){
#     return mystery_function(n, m, l, k, j, i, h, g, f, e, d, c, b, a);
# };
.text
.global operation
operation:
    addi sp, sp, -28
    sw a0, 20(sp)
    sw a1, 16(sp)
    sw a2, 12(sp)
    sw a3, 8(sp)
    sw a4, 4(sp)
    sw a5, 0(sp)
   
    mv t0, a6
    mv a6, a7
    mv a7, t0

    lw a0, 48(sp)
    lw a1, 44(sp)
    lw a2, 40(sp)
    lw a3, 36(sp)
    lw a4, 32(sp)
    lw a5, 28(sp)
    

    sw ra, 24(sp)
    jal ra, mystery_function
    lw ra, 24(sp)
    addi sp, sp, 28
    
    ret