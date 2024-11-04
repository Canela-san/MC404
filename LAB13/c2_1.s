# int swap_int(int *a, int *b){
#     int aux = *a;
#     *a = *b;
#     *b = aux;
#     return 0;
# };
# int swap_short(short *a, short *b){
#     short aux = *a;
#     *a = *b;
#     *b = aux;
#     return 0;
# };
# int swap_char(char *a, char *b){
#     char aux = *a;
#     *a = *b;
#     *b = aux;
#     return 0;
# };

.text
.global swap_int
.global swap_short
.global swap_char
swap_int:
    lw t0, (a0)
    lw t1, (a1)
    sw t0, (a1)
    sw t1, (a0)
    li a0, 0
    ret

swap_short:
    lh t0, (a0)
    lh t1, (a1)
    sh t0, (a1)
    sh t1, (a0)
    li a0, 0
    ret

swap_char:
    lb t0, (a0)
    lb t1, (a1)
    sb t0, (a1)
    sb t1, (a0)
    li a0, 0
    ret

