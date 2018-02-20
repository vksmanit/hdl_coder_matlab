/* 
 * File: _coder_multiplication_api.h 
 *  
 * MATLAB Coder version            : 2.7 
 * C/C++ source code generated on  : 12-Feb-2018 12:34:34 
 */

#ifndef ___CODER_MULTIPLICATION_API_H__
#define ___CODER_MULTIPLICATION_API_H__
/* Include Files */ 
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"

/* Function Declarations */ 
extern void multiplication_initialize(emlrtContext *aContext);
extern void multiplication_terminate(void);
extern void multiplication_atexit(void);
extern void multiplication_api(const mxArray * const prhs[2], const mxArray *plhs[1]);
extern int32_T multiplication(int32_T a, int32_T b);
extern void multiplication_xil_terminate(void);

#endif
/* 
 * File trailer for _coder_multiplication_api.h 
 *  
 * [EOF] 
 */
