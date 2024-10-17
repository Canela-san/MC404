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

void write(int __fd, const void *__buf, int __n)
{
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

void exit(int code)
{
  __asm__ __volatile__(
    "mv a0, %0           # return code\n"
    "li a7, 93           # syscall exit (93) \n"
    "ecall"
    :   // Output list
    :"r"(code)    // Input list
    : "a0", "a7"
  );
}

void write_string(const char *str) {
    int len = 0;
    while (str[len] != '\0') len++;
    write(STDOUT_FD, str, len);
}

void int_to_str(int num, char *str, int base) {
    int i = 0, is_negative = 0;
    unsigned int n = (unsigned int)num;

    if (num < 0 && base == 10) {
        is_negative = 1;
        n = (unsigned int)(-num);
    }

    do {
        int digit = n % base;
        str[i++] = (digit > 9) ? (digit - 10) + 'a' : digit + '0';
    } while ((n /= base) > 0);

    if (is_negative) {
        str[i++] = '-';
    }

    str[i] = '\0';

    for (int j = 0; j < i / 2; j++) {
        char temp = str[j];
        str[j] = str[i - j - 1];
        str[i - j - 1] = temp;
    }
}

void uint_to_str(unsigned int num, char *str, int base) {
    int i = 0;

    do {
        int digit = num % base;
        str[i++] = (digit > 9) ? (digit - 10) + 'a' : digit + '0';
    } while ((num /= base) > 0);

    str[i] = '\0';

    for (int j = 0; j < i / 2; j++) {
        char temp = str[j];
        str[j] = str[i - j - 1];
        str[i - j - 1] = temp;
    }
}

unsigned int swap_endian(unsigned int num) {
    return ((num >> 24) & 0xFF) |
           ((num << 8) & 0xFF0000) |
           ((num >> 8) & 0xFF00) |
           ((num << 24) & 0xFF000000);
}

void remove_leading_zeros(char *bin_str) {
    int i = 0;

    // Encontre o primeiro '1' ou o final da string
    while (bin_str[i] == '0') {
        i++;
    }

    // Se o número for composto apenas por zeros, mantenha apenas um zero
    if (bin_str[i] == '\0') {
        bin_str[1] = '\0';
        return;
    }

    // Copie a string começando do primeiro '1'
    int j = 0;
    while (bin_str[i] != '\0') {
        bin_str[j++] = bin_str[i++];
    }
    bin_str[j] = '\0';
}

int str_to_int(const char *str, int base) {
    int result = 0, sign = 1, i = 0;

    if (str[0] == '-') {
        sign = -1;
        i++;
    }

    for (; str[i] != '\0'; ++i) {
        if (base == 10) {
            result = result * 10 + (str[i] - '0');
        } else if (base == 16) {
            if (str[i] >= '0' && str[i] <= '9') {
                result = result * 16 + (str[i] - '0');
            } else if (str[i] >= 'a' && str[i] <= 'f') {
                result = result * 16 + (str[i] - 'a' + 10);
            }
        }
    }

    return sign * result;
}

int main() {
    char str[20];
    char output[35];
    int n = read(STDIN_FD, str, 20);

    // Se não ler nada, sai do programa
    if (n < 1) {
        return 1;
    }

    // Verificação do tipo de entrada
    str[n-1] = '\0';
    int number;
    if (str[0] == '0' && str[1] == 'x') {
        number = str_to_int(&str[2], 16);
    } else {
        number = str_to_int(str, 10);
    }

    // Binário
    write_string("0b");
    for (int i = 31; i >= 0; i--) {
        output[31-i] = ((number >> i) & 1) ? '1' : '0';
    }
    output[32] = '\n';
    output[33] = '\0';
    remove_leading_zeros(output);
    write_string(output);

    // Decimal (Com sinal)
    int_to_str(number, output, 10);
    write_string(output);
    write_string("\n");

    // Hexadecimal
    write_string("0x");
    uint_to_str((unsigned int)number, output, 16);
    write_string(output);
    write_string("\n");

    // Endian swapped decimal (Sem sinal)
    unsigned int swapped = swap_endian((unsigned int)number);
    uint_to_str(swapped, output, 10);
    write_string(output);
    write_string("\n");

    return 0;
}

void _start()
{
  int ret_code = main();
  exit(ret_code);
}