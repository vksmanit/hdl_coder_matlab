/*
 * _coder_hdl_matmul_cosim_mex.c
 *
 * Code generation for function 'hdl_matmul_cosim'
 *
 */

/* Include files */
#include "mex.h"
#include "_coder_hdl_matmul_cosim_api.h"
#include "hdl_matmul_cosim_initialize.h"
#include "hdl_matmul_cosim_terminate.h"

/* Function Declarations */
static void hdl_matmul_cosim_mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);

/* Variable Definitions */
emlrtContext emlrtContextGlobal = { true, false, EMLRT_VERSION_INFO, NULL, "hdl_matmul_cosim", NULL, false, {2045744189U,2170104910U,2743257031U,4284093946U}, NULL };
void *emlrtRootTLSGlobal = NULL;

/* Function Definitions */
static void hdl_matmul_cosim_mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  const mxArray *outputs[2];
  const mxArray *inputs[2];
  int n = 0;
  int nOutputs = (nlhs < 1 ? 1 : nlhs);
  int nInputs = nrhs;
  emlrtStack st = { NULL, NULL, NULL };
  /* Module initialization. */
  hdl_matmul_cosim_initialize(&emlrtContextGlobal);
  st.tls = emlrtRootTLSGlobal;
  /* Check for proper number of arguments. */
  if (nrhs != 2) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:WrongNumberOfInputs", 5, mxINT32_CLASS, 2, mxCHAR_CLASS, 16, "hdl_matmul_cosim");
  } else if (nlhs > 2) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:TooManyOutputArguments", 3, mxCHAR_CLASS, 16, "hdl_matmul_cosim");
  }
  /* Temporary copy for mex inputs. */
  for (n = 0; n < nInputs; ++n) {
    inputs[n] = prhs[n];
  }
  /* Call the function. */
  hdl_matmul_cosim_api(inputs, outputs);
  /* Copy over outputs to the caller. */
  for (n = 0; n < nOutputs; ++n) {
    plhs[n] = emlrtReturnArrayR2009a(outputs[n]);
  }
  /* Module finalization. */
  hdl_matmul_cosim_terminate();
}

void hdl_matmul_cosim_atexit_wrapper(void)
{
   hdl_matmul_cosim_atexit();
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  /* Initialize the memory manager. */
  mexAtExit(hdl_matmul_cosim_atexit_wrapper);
  /* Dispatch the entry-point. */
  hdl_matmul_cosim_mexFunction(nlhs, plhs, nrhs, prhs);
}
/* End of code generation (_coder_hdl_matmul_cosim_mex.c) */
