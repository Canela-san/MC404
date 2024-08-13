/* Buffer to store the data read */
char input_buffer[10];

int main()
{
  /* fd = 0 : reads from standard input (STDIN) */
  int n = read(0, (void*) input_buffer, 10);
  /* … */
  return 0;
}

