/* Allocates a global string with 5 bytes.
 *   Note: the break line character, \n is encoded
 *       with a single byte */
char my_string[] = "1969\n";

int main()
{
  /* Prints the first 5 characters from the string on
   * the standard output, in other words, 1, 9, 6, 9 and break line. */
  write(1, my_string, 5);

  return 0;
}

