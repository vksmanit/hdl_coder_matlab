/*
 * File: _coder_multiplication_info.c
 *
 * MATLAB Coder version            : 2.7
 * C/C++ source code generated on  : 12-Feb-2018 12:34:47
 */

/* Include Files */
#include "_coder_multiplication_info.h"

/* Function Definitions */

/*
 * Arguments    : void
 * Return Type  : const mxArray *
 */
const mxArray *emlrtMexFcnResolvedFunctionsInfo(void)
{
  const mxArray *nameCaptureInfo;
  static const int32_T iv0[2] = { 0, 1 };

  const mxArray *m0;
  nameCaptureInfo = NULL;
  m0 = emlrtCreateNumericArray(2, iv0, mxDOUBLE_CLASS, mxREAL);
  emlrtAssign(&nameCaptureInfo, m0);
  return nameCaptureInfo;
}

MEXFUNCTION_LINKAGE mxArray *emlrtMexFcnProperties(void);
mxArray *emlrtMexFcnProperties()
{
  const char *mexProperties[] = {
    "Version",
    "ResolvedFunctions",
    "EntryPoints",
    "CoverageInfo",
    NULL };

  const char *epProperties[] = {
    "Name",
    "NumberOfInputs",
    "NumberOfOutputs",
    "ConstantInputs" };

  mxArray *xResult = mxCreateStructMatrix(1,1,4,mexProperties);
  mxArray *xEntryPoints = mxCreateStructMatrix(1,1,4,epProperties);
  mxArray *xInputs = NULL;
  xInputs = mxCreateLogicalMatrix(1, 2);
  mxSetFieldByNumber(xEntryPoints, 0, 0, mxCreateString("multiplication"));
  mxSetFieldByNumber(xEntryPoints, 0, 1, mxCreateDoubleScalar(2));
  mxSetFieldByNumber(xEntryPoints, 0, 2, mxCreateDoubleScalar(1));
  mxSetFieldByNumber(xEntryPoints, 0, 3, xInputs);
  mxSetFieldByNumber(xResult, 0, 0, mxCreateString("8.4.0.150421 (R2014b)"));
  mxSetFieldByNumber(xResult, 0, 1, (mxArray*)emlrtMexFcnResolvedFunctionsInfo());
  mxSetFieldByNumber(xResult, 0, 2, xEntryPoints);
  return xResult;
}

/*
 * File trailer for _coder_multiplication_info.c
 *
 * [EOF]
 */
