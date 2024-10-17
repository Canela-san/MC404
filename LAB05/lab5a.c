#define STDIN_FD  0
#define STDOUT_FD 1

int read(int __fd, const void *__buf, int __n){
    int ret_val;
    __asm__ __volatile__(
        "mv a0, %1           # file descriptor\n"
        "mv a1, %2           # buffer \n"
        "mv a2, %3           # size \n"
        "li a7, 63           # syscall read code (63) \n"
        "ecall               # invoke syscall \n"
        "mv %0, a0           # move return value to ret_val\n"
        : "=r"(ret_val)  // Output list
        : "r"(__fd), "r"(__buf), "r"(__n)    // Input list
        : "a0", "a1", "a2", "a7"
    );
    return ret_val;
}

void write(int __fd, const void *__buf, int __n){
    __asm__ __volatile__(
        "mv a0, %0           # file descriptor\n"
        "mv a1, %1           # buffer \n"
        "mv a2, %2           # size \n"
        "li a7, 64           # syscall write (64) \n"
        "ecall"
        :   // Output list
        :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
        : "a0", "a1", "a2", "a7"
    );
}

void exit(int code){
    __asm__ __volatile__(
        "mv a0, %0           # return code\n"
        "li a7, 93           # syscall exit (93) \n"
        "ecall"
        :   // Output list
        :"r"(code)    // Input list
        : "a0", "a7"
    );
}

void hex_code(int val){
    char hex[11];
    unsigned int uval = (unsigned int) val, aux;

    hex[0] = '0';
    hex[1] = 'x';
    hex[10] = '\n';

    for (int i = 9; i > 1; i--){
        aux = uval % 16;
        if (aux >= 10)
            hex[i] = aux - 10 + 'A';
        else
            hex[i] = aux + '0';
        uval = uval / 16;
    }
    write(STDOUT_FD, hex, 11);
}

void write_string(const char *str) {
    int len = 0;
    while (str[len] != '\0') len++;
    write(STDOUT_FD, str, len);
}

void pack(int input, int start_bit, int end_bit, int *val) {
    int bit_length = end_bit - start_bit + 1;
    int mask = (1 << bit_length) - 1;
    *val |= (input & mask) << start_bit;
}

int main(){
    char str[30];
    int numbers[5] = {0};
    int packed_value = 0;
    int sign, value, i, j, idx = 0;

    int n = read(STDIN_FD, str, 30);
    if (n < 1) {
        return 1;
    }

    for (i = 0; i < 5; i++) {
        sign = (str[idx] == '-') ? -1 : 1;
        value = 0;
        for (j = 1; j <= 4; j++) {
            value = value * 10 + (str[idx + j] - '0');
        }  
        numbers[i] = sign * value;
        idx += 6;
    }

    pack(numbers[0], 0, 2, &packed_value);
    pack(numbers[1], 3, 10, &packed_value);
    pack(numbers[2], 11, 15, &packed_value);
    pack(numbers[3], 16, 20, &packed_value);
    pack(numbers[4], 21, 31, &packed_value);

    hex_code(packed_value);

    return 0;
}

void _start(){
    int ret_code = main();
    exit(ret_code);
}
