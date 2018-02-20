/*
 * File: multiplication.c
 *
 * MATLAB Coder version            : 2.7
 * C/C++ source code generated on  : 12-Feb-2018 12:34:47
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "multiplication.h"

/* Function Definitions */

/*
 * Arguments    : int a
 *                int b
 * Return Type  : int
 */
int multiplication(int a, int b)
{
  long i0;
  i0 = (long)a * b;
  if (i0 > 2147483647L) {
    i0 = 2147483647L;
  } else {
    if (i0 < -2147483648L) {
      i0 = -2147483648L;
    }
  }

  return (int)i0;
}

/*
 * File trailer for multiplication.c
 *
 * [EOF]
 */
