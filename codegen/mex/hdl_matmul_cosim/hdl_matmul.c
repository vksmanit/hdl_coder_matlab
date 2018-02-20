/*
 * hdl_matmul.c
 *
 * Code generation for function 'hdl_matmul'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "hdl_matmul_cosim.h"
#include "hdl_matmul.h"
#include "hdl_matmul_cosim_data.h"

/* Function Definitions */
void A_not_empty_init(void)
{
}

void B_not_empty_init(void)
{
}

void C_not_empty_init(void)
{
}

void hdl_matmul_init(void)
{
  int32_T i1;
  state = 0.0;
  for (i1 = 0; i1 < 4; i1++) {
    A[i1] = 0.0;
    B[i1] = 0.0;
    C[i1] = 0.0;
  }

  y_in = 1.0;
  x_in = 1.0;
}

void state_not_empty_init(void)
{
}

void x_in_not_empty_init(void)
{
}

void y_in_not_empty_init(void)
{
}

/* End of code generation (hdl_matmul.c) */
