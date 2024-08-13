
/* read
 * Parameters:
 *  __fd:  file descriptor of the file to be read.
 *  __buf: buffer to store the data read.
 *  __n:   maximum amount of bytes to be read.
 * Return:
 *  Number of bytes read.
 */

/* write
 * Parameters:
 *  __fd:  files descriptor where that will be written.
 *  __buf: buffer with data to be written.  
 *  __n:   amount of bytes to be written.
 * Return:
 *  Number of bytes effectively written.
 */

int read(int __fd, const void *__buf, int __n)
{
    int ret_val;
  __asm__ __volatile__(
    "mv a0, %1           # file descriptor\n"
    "mv a1, %2           # buffer \n"
    "mv a2, %3           # size \n"
    "li a7, 63           # syscall read code (63) \n"
    "ecall               # invoke syscall \n"
    "mv %0, a0           # move return value to ret_val\n"
    : "=r"(ret_val)                   // Output list
    : "r"(__fd), "r"(__buf), "r"(__n) // Input list
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

char input_buffer[6]; /* Buffer to store the data read */
int main() {
  read(0,input_buffer,6);
  char res[3];
  int n;
  input_buffer[0] -= '0';
  input_buffer[4] -= '0';

  if (input_buffer[2] == '+')
    n = (int)input_buffer[0] + (int)input_buffer[4];
  if (input_buffer[2] == '-')
    n = (int)input_buffer[0] - (int)input_buffer[4];
  if (input_buffer[2] == '*')
    n = (int)input_buffer[0] * (int)input_buffer[4];
  if (n >= 0 && n <= 9) {
      res[0] = n + '0';
      res[1] = '\n';
      write(1, res, 2);
  } else {
      res[0] = (n / 10) + '0';
      res[1] = (n % 10) + '0';
      res[2] = '\n';
      write(1, res, 3);
  }
}
void exit(int code)
{
  __asm__ __volatile__(
    "mv a0, %0           # return code\n"
    "li a7, 93           # syscall exit (64) \n"
    "ecall"
    :             // Output list
    :"r"(code)    // Input list
    : "a0", "a7"
  );
}
void _start()
{
  int ret_code = main();
  exit(ret_code);
}
