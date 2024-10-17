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
        : "=r"(ret_val)
        : "r"(__fd), "r"(__buf), "r"(__n)
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
        :  
        :"r"(__fd), "r"(__buf), "r"(__n) 
        : "a0", "a1", "a2", "a7"
    );
}

void exit(int code){
    __asm__ __volatile__(
        "mv a0, %0           # return code\n"
        "li a7, 93           # syscall exit (93) \n"
        "ecall"
        : 
        :"r"(code)   
        : "a0", "a7"
    );
}

int strcmp_custom(char *str1, char *str2, int n_char) {
    for (int i = 0; i < n_char; i++) {
        if (str1[i] < str2[i])
            return -1;
        else if (str1[i] > str2[i])
            return 1;
    }
    return 0;
}

void hex_code(int val) {
    char hex[11];
    unsigned int uval = (unsigned int)val, aux;

    hex[0] = '0';
    hex[1] = 'x';
    hex[10] = '\n';

    for (int i = 9; i > 1; i--) {
        aux = uval % 16;
        if (aux >= 10)
            hex[i] = aux - 10 + 'A';
        else
            hex[i] = aux + '0';
        uval = uval / 16;
    }
    write(STDOUT_FD, hex, 11);
}

int extract_reg_num(char *reg) {
    return (reg[1] - '0') * 10 + (reg[2] - '0');
}

int parse_immediate(char *imm) {
    int value = 0;
    int sign = 1;
    if (*imm == '-') {
        sign = -1;
        imm++;
    }
    while (*imm) {
        value = value * 10 + (*imm - '0');
        imm++;
    }
    return value * sign;
}

int parse_instruction(char *str) {
    int rd, rs1, rs2, imm, opcode, funct3, funct7, instruction = 0;


    if (strcmp_custom(str, "lb", 2) == 0) {
        opcode = 0x03; 
        funct3 = 0x0;  

        rd = extract_reg_num(&str[3]);  
        imm = parse_immediate(&str[6]);  
        rs1 = extract_reg_num(&str[8]); 


        instruction = ((imm & 0xFFF) << 20) |  
                      (rs1 << 15) |         
                      (funct3 << 12) |      
                      (rd << 7) |           
                      opcode;               

        return instruction;
    }

    if (strcmp_custom(str, "and", 3) == 0) {
        opcode = 0x33;  
        funct3 = 0x7;   
        funct7 = 0x00;  

        rd = extract_reg_num(&str[4]);    
        rs1 = extract_reg_num(&str[8]); 
        rs2 = extract_reg_num(&str[12]);  

        instruction = (funct7 << 25) |  
                      (rs2 << 20) |    
                      (rs1 << 15) |    
                      (funct3 << 12) | 
                      (rd << 7) |      
                      opcode;          

        return instruction;
    }

 
    if (strcmp_custom(str, "slti", 4) == 0) {
        opcode = 0x13;
        funct3 = 0x2; 

        rd = extract_reg_num(&str[5]);    
        rs1 = extract_reg_num(&str[9]);  
        imm = parse_immediate(&str[13]); 

  
        if (imm < 0) {
            imm = imm & 0xFFF; 
        }


        instruction = ((imm & 0xFFF) << 20) |  
                      (rs1 << 15) |         
                      (funct3 << 12) |      
                      (rd << 7) |           
                      opcode;               

        return instruction;
    }


    if (strcmp_custom(str, "bge", 3) == 0) {
        opcode = 0x63; 
        funct3 = 0x5; 

        rs1 = extract_reg_num(&str[4]);  
        rs2 = extract_reg_num(&str[8]); 
        imm = parse_immediate(&str[12]); 

        int imm_11 = (imm >> 11) & 0x1;  
        int imm_4_1 = (imm >> 1) & 0xF;   
        int imm_10_5 = (imm >> 5) & 0x3F;  
        int imm_12 = (imm >> 12) & 0x1;  

        instruction = (imm_12 << 31) |     
                      (imm_10_5 << 25) |    
                      (rs2 << 20) |   
                      (rs1 << 15) |   
                      (funct3 << 12) |   
                      (imm_11 << 7) |     
                      (imm_4_1 << 8) |     
                      opcode;            

        return instruction;
    }

    if (strcmp_custom(str, "jalr", 4) == 0) {
        opcode = 0x67; 
        funct3 = 0x0; 

        rd = extract_reg_num(&str[5]);    
        imm = parse_immediate(&str[8]);   
        rs1 = extract_reg_num(&str[12]);   

  
        if (imm < 0) {
            imm = imm & 0xFFF; 
        }

        instruction = ((imm & 0xFFF) << 20) |  
                      (rs1 << 15) |         
                      (funct3 << 12) |      
                      (rd << 7) |           
                      opcode;               

        return instruction;
    }

    return 0;
}

int main() {
    char str[40];
    int n = read(STDIN_FD, str, 40);

    if (n > 0) {
        int instruction = parse_instruction(str);
        hex_code(instruction);
    }

    return 0;
}

void _start() {
    int ret_code = main();
    exit(ret_code);
}
