/*
 * hdl_matmul_cosim.h
 *
 * Code generation for function 'hdl_matmul_cosim'
 *
 */

#ifndef __HDL_MATMUL_COSIM_H__
#define __HDL_MATMUL_COSIM_H__

/* Include files */
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include "mwmathutil.h"
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include "blas.h"
#include "rtwtypes.h"
#include "hdl_matmul_cosim_types.h"

/* Function Declarations */
extern void hdl_matmul_cosim(const emlrtStack *sp, int8_T a_in, int8_T b_in,
  const mxArray **c_out, const mxArray **state_store);
extern void hdl_matmul_cosim_init(void);
extern void initialized_not_empty_init(void);

#endif

/* End of code generation (hdl_matmul_cosim.h) */
