/* 
 * File: _coder_multiplication_fixpt_api.h 
 *  
 * MATLAB Coder version            : 2.7 
 * C/C++ source code generated on  : 13-Feb-2018 17:53:04 
 */

#ifndef ___CODER_MULTIPLICATION_FIXPT_API_H__
#define ___CODER_MULTIPLICATION_FIXPT_API_H__
/* Include Files */ 
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"

/* Function Declarations */ 
extern void multiplication_fixpt_initialize(emlrtContext *aContext);
extern void multiplication_fixpt_terminate(void);
extern void multiplication_fixpt_atexit(void);
extern void multiplication_fixpt_api(const mxArray * const prhs[2], const mxArray *plhs[1]);
extern uint8_T multiplication_fixpt(uint8_T a, uint8_T b);
extern void multiplication_fixpt_xil_terminate(void);

#endif
/* 
 * File trailer for _coder_multiplication_fixpt_api.h 
 *  
 * [EOF] 
 */
