/*
 * File: _coder_multiplication_fixpt_api.c
 *
 * MATLAB Coder version            : 2.7
 * C/C++ source code generated on  : 13-Feb-2018 17:53:04
 */

/* Include Files */
#include "_coder_multiplication_fixpt_api.h"

/* Variable Definitions */
static const mxArray *eml_mx;
static const mxArray *b_eml_mx;
static const mxArray *c_eml_mx;
static const mxArray *d_eml_mx;
static emlrtMCInfo emlrtMCI = { -1, -1, "", "" };

/* Function Declarations */
static void multiplication_fixpt_once(const emlrtStack *sp);
static uint8_T emlrt_marshallIn(const emlrtStack *sp, const mxArray *a, const
  char_T *identifier);
static uint8_T b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId);
static uint8_T c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *b, const
  char_T *identifier);
static uint8_T d_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId);
static const mxArray *emlrt_marshallOut(const emlrtStack *sp, const uint8_T u);
static const mxArray *fimath(const emlrtStack *sp, const char * b, const char
  * c, const char * d, const char * e, const char * f, const char * g, const
  char * h, const char * i, const char * j, const char * k, const char * l,
  real_T m, const char * n, real_T o, const char * p, real_T q, const char * r,
  real_T s, const char * t, real_T u, const char * v, real_T w, const char * x,
  real_T y, const char * ab, const char * bb, const char * cb, real_T db, const
  char * eb, real_T fb, const char * gb, real_T hb, const char * ib, real_T jb,
  const char * kb, real_T lb, const char * mb, real_T nb, const char * ob,
  real_T pb, const char * qb, boolean_T rb, emlrtMCInfo *location);
static const mxArray *numerictype(const emlrtStack *sp, const char * b,
  boolean_T c, const char * d, const char * e, const char * f, real_T g, const
  char * h, real_T i, const char * j, real_T k, const char * l, real_T m, const
  char * n, real_T o, emlrtMCInfo *location);
static uint8_T e_emlrt_marshallIn(const mxArray *src);
static uint8_T f_emlrt_marshallIn(const mxArray *src);

/* Function Definitions */

/*
 * Arguments    : const emlrtStack *sp
 * Return Type  : void
 */
static void multiplication_fixpt_once(const emlrtStack *sp)
{
  emlrtAssignP(&d_eml_mx, NULL);
  emlrtAssignP(&c_eml_mx, NULL);
  emlrtAssignP(&b_eml_mx, NULL);
  emlrtAssignP(&eml_mx, NULL);
  emlrtAssignP(&d_eml_mx, numerictype(sp, "SignednessBool", false, "Signedness",
    "Unsigned", "WordLength", 6.0, "FractionLength", 0.0, "BinaryPoint", 0.0,
    "Slope", 1.0, "FixedExponent", 0.0, &emlrtMCI));
  emlrtAssignP(&c_eml_mx, numerictype(sp, "SignednessBool", false, "Signedness",
    "Unsigned", "WordLength", 4.0, "FractionLength", 0.0, "BinaryPoint", 0.0,
    "Slope", 1.0, "FixedExponent", 0.0, &emlrtMCI));
  emlrtAssignP(&b_eml_mx, numerictype(sp, "SignednessBool", false, "Signedness",
    "Unsigned", "WordLength", 3.0, "FractionLength", 0.0, "BinaryPoint", 0.0,
    "Slope", 1.0, "FixedExponent", 0.0, &emlrtMCI));
  emlrtAssignP(&eml_mx, fimath(sp, "RoundMode", "floor", "RoundingMethod",
    "Floor", "OverflowMode", "wrap", "OverflowAction", "Wrap", "ProductMode",
    "FullPrecision", "ProductWordLength", 32.0, "MaxProductWordLength", 128.0,
    "ProductFractionLength", 30.0, "ProductFixedExponent", -30.0, "ProductSlope",
    9.3132257461547852E-10, "ProductSlopeAdjustmentFactor", 1.0, "ProductBias",
    0.0, "SumMode", "FullPrecision", "SumWordLength", 32.0, "MaxSumWordLength",
    128.0, "SumFractionLength", 30.0, "SumFixedExponent", -30.0, "SumSlope",
    9.3132257461547852E-10, "SumSlopeAdjustmentFactor", 1.0, "SumBias", 0.0,
    "CastBeforeSum", true, &emlrtMCI));
}

/*
 * Arguments    : emlrtContext *aContext
 * Return Type  : void
 */
void multiplication_fixpt_initialize(emlrtContext *aContext)
{
  emlrtStack st = { NULL, NULL, NULL };

  emlrtCreateRootTLS(&emlrtRootTLSGlobal, aContext, NULL, 1);
  st.tls = emlrtRootTLSGlobal;
  emlrtClearAllocCountR2012b(&st, false, 3U, "ForceOff");
  emlrtEnterRtStackR2012b(&st);
  if (emlrtFirstTimeR2012b(emlrtRootTLSGlobal)) {
    multiplication_fixpt_once(&st);
  }
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void multiplication_fixpt_terminate(void)
{
  emlrtStack st = { NULL, NULL, NULL };

  st.tls = emlrtRootTLSGlobal;
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void multiplication_fixpt_atexit(void)
{
  emlrtStack st = { NULL, NULL, NULL };

  emlrtCreateRootTLS(&emlrtRootTLSGlobal, &emlrtContextGlobal, NULL, 1);
  st.tls = emlrtRootTLSGlobal;
  emlrtEnterRtStackR2012b(&st);
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
  multiplication_fixpt_xil_terminate();
  emlrtDestroyArray(&eml_mx);
  emlrtDestroyArray(&b_eml_mx);
  emlrtDestroyArray(&c_eml_mx);
  emlrtDestroyArray(&d_eml_mx);
}

/*
 * Arguments    : const mxArray * const prhs[2]
 *                const mxArray *plhs[1]
 * Return Type  : void
 */
void multiplication_fixpt_api(const mxArray * const prhs[2], const mxArray *
  plhs[1])
{
  uint8_T a;
  uint8_T b;
  emlrtStack st = { NULL, NULL, NULL };

  st.tls = emlrtRootTLSGlobal;

  /* Marshall function inputs */
  a = emlrt_marshallIn(&st, emlrtAliasP(prhs[0]), "a");
  b = c_emlrt_marshallIn(&st, emlrtAliasP(prhs[1]), "b");

  /* Invoke the target function */
  a = multiplication_fixpt(a, b);

  /* Marshall function outputs */
  plhs[0] = emlrt_marshallOut(&st, a);
}

/*
 * Arguments    : const emlrtStack *sp
 *                const mxArray *a
 *                const char_T *identifier
 * Return Type  : uint8_T
 */
static uint8_T emlrt_marshallIn(const emlrtStack *sp, const mxArray *a, const
  char_T *identifier)
{
  uint8_T y;
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = identifier;
  thisId.fParent = NULL;
  y = b_emlrt_marshallIn(sp, emlrtAlias(a), &thisId);
  emlrtDestroyArray(&a);
  return y;
}

/*
 * Arguments    : const emlrtStack *sp
 *                const mxArray *u
 *                const emlrtMsgIdentifier *parentId
 * Return Type  : uint8_T
 */
static uint8_T b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId)
{
  uint8_T y;
  emlrtCheckFiR2012b(sp, parentId, u, false, 0U, 0, eml_mx, b_eml_mx);
  y = e_emlrt_marshallIn(emlrtAlias(u));
  emlrtDestroyArray(&u);
  return y;
}

/*
 * Arguments    : const emlrtStack *sp
 *                const mxArray *b
 *                const char_T *identifier
 * Return Type  : uint8_T
 */
static uint8_T c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *b, const
  char_T *identifier)
{
  uint8_T y;
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = identifier;
  thisId.fParent = NULL;
  y = d_emlrt_marshallIn(sp, emlrtAlias(b), &thisId);
  emlrtDestroyArray(&b);
  return y;
}

/*
 * Arguments    : const emlrtStack *sp
 *                const mxArray *u
 *                const emlrtMsgIdentifier *parentId
 * Return Type  : uint8_T
 */
static uint8_T d_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId)
{
  uint8_T y;
  emlrtCheckFiR2012b(sp, parentId, u, false, 0U, 0, eml_mx, c_eml_mx);
  y = f_emlrt_marshallIn(emlrtAlias(u));
  emlrtDestroyArray(&u);
  return y;
}

/*
 * Arguments    : const emlrtStack *sp
 *                const uint8_T u
 * Return Type  : const mxArray *
 */
static const mxArray *emlrt_marshallOut(const emlrtStack *sp, const uint8_T u)
{
  const mxArray *y;
  const mxArray *b_y;
  const mxArray *m0;
  y = NULL;
  b_y = NULL;
  m0 = emlrtCreateNumericMatrix(1, 1, mxUINT8_CLASS, mxREAL);
  *(uint8_T *)mxGetData(m0) = u;
  emlrtAssign(&b_y, m0);
  emlrtAssign(&y, emlrtCreateFIR2013b(sp, eml_mx, d_eml_mx, "simulinkarray", b_y,
    true, false));
  return y;
}

/*
 * Arguments    : const emlrtStack *sp
 *                const char * b
 *                const char * c
 *                const char * d
 *                const char * e
 *                const char * f
 *                const char * g
 *                const char * h
 *                const char * i
 *                const char * j
 *                const char * k
 *                const char * l
 *                real_T m
 *                const char * n
 *                real_T o
 *                const char * p
 *                real_T q
 *                const char * r
 *                real_T s
 *                const char * t
 *                real_T u
 *                const char * v
 *                real_T w
 *                const char * x
 *                real_T y
 *                const char * ab
 *                const char * bb
 *                const char * cb
 *                real_T db
 *                const char * eb
 *                real_T fb
 *                const char * gb
 *                real_T hb
 *                const char * ib
 *                real_T jb
 *                const char * kb
 *                real_T lb
 *                const char * mb
 *                real_T nb
 *                const char * ob
 *                real_T pb
 *                const char * qb
 *                boolean_T rb
 *                emlrtMCInfo *location
 * Return Type  : const mxArray *
 */
static const mxArray *fimath(const emlrtStack *sp, const char * b, const char
  * c, const char * d, const char * e, const char * f, const char * g, const
  char * h, const char * i, const char * j, const char * k, const char * l,
  real_T m, const char * n, real_T o, const char * p, real_T q, const char * r,
  real_T s, const char * t, real_T u, const char * v, real_T w, const char * x,
  real_T y, const char * ab, const char * bb, const char * cb, real_T db, const
  char * eb, real_T fb, const char * gb, real_T hb, const char * ib, real_T jb,
  const char * kb, real_T lb, const char * mb, real_T nb, const char * ob,
  real_T pb, const char * qb, boolean_T rb, emlrtMCInfo *location)
{
  const mxArray *pArrays[42];
  const mxArray *m1;
  pArrays[0] = emlrtCreateString(b);
  pArrays[1] = emlrtCreateString(c);
  pArrays[2] = emlrtCreateString(d);
  pArrays[3] = emlrtCreateString(e);
  pArrays[4] = emlrtCreateString(f);
  pArrays[5] = emlrtCreateString(g);
  pArrays[6] = emlrtCreateString(h);
  pArrays[7] = emlrtCreateString(i);
  pArrays[8] = emlrtCreateString(j);
  pArrays[9] = emlrtCreateString(k);
  pArrays[10] = emlrtCreateString(l);
  pArrays[11] = emlrtCreateDoubleScalar(m);
  pArrays[12] = emlrtCreateString(n);
  pArrays[13] = emlrtCreateDoubleScalar(o);
  pArrays[14] = emlrtCreateString(p);
  pArrays[15] = emlrtCreateDoubleScalar(q);
  pArrays[16] = emlrtCreateString(r);
  pArrays[17] = emlrtCreateDoubleScalar(s);
  pArrays[18] = emlrtCreateString(t);
  pArrays[19] = emlrtCreateDoubleScalar(u);
  pArrays[20] = emlrtCreateString(v);
  pArrays[21] = emlrtCreateDoubleScalar(w);
  pArrays[22] = emlrtCreateString(x);
  pArrays[23] = emlrtCreateDoubleScalar(y);
  pArrays[24] = emlrtCreateString(ab);
  pArrays[25] = emlrtCreateString(bb);
  pArrays[26] = emlrtCreateString(cb);
  pArrays[27] = emlrtCreateDoubleScalar(db);
  pArrays[28] = emlrtCreateString(eb);
  pArrays[29] = emlrtCreateDoubleScalar(fb);
  pArrays[30] = emlrtCreateString(gb);
  pArrays[31] = emlrtCreateDoubleScalar(hb);
  pArrays[32] = emlrtCreateString(ib);
  pArrays[33] = emlrtCreateDoubleScalar(jb);
  pArrays[34] = emlrtCreateString(kb);
  pArrays[35] = emlrtCreateDoubleScalar(lb);
  pArrays[36] = emlrtCreateString(mb);
  pArrays[37] = emlrtCreateDoubleScalar(nb);
  pArrays[38] = emlrtCreateString(ob);
  pArrays[39] = emlrtCreateDoubleScalar(pb);
  pArrays[40] = emlrtCreateString(qb);
  pArrays[41] = emlrtCreateLogicalScalar(rb);
  return emlrtCallMATLABR2012b(sp, 1, &m1, 42, pArrays, "fimath", true, location);
}

/*
 * Arguments    : const emlrtStack *sp
 *                const char * b
 *                boolean_T c
 *                const char * d
 *                const char * e
 *                const char * f
 *                real_T g
 *                const char * h
 *                real_T i
 *                const char * j
 *                real_T k
 *                const char * l
 *                real_T m
 *                const char * n
 *                real_T o
 *                emlrtMCInfo *location
 * Return Type  : const mxArray *
 */
static const mxArray *numerictype(const emlrtStack *sp, const char * b,
  boolean_T c, const char * d, const char * e, const char * f, real_T g, const
  char * h, real_T i, const char * j, real_T k, const char * l, real_T m, const
  char * n, real_T o, emlrtMCInfo *location)
{
  const mxArray *pArrays[14];
  const mxArray *m2;
  pArrays[0] = emlrtCreateString(b);
  pArrays[1] = emlrtCreateLogicalScalar(c);
  pArrays[2] = emlrtCreateString(d);
  pArrays[3] = emlrtCreateString(e);
  pArrays[4] = emlrtCreateString(f);
  pArrays[5] = emlrtCreateDoubleScalar(g);
  pArrays[6] = emlrtCreateString(h);
  pArrays[7] = emlrtCreateDoubleScalar(i);
  pArrays[8] = emlrtCreateString(j);
  pArrays[9] = emlrtCreateDoubleScalar(k);
  pArrays[10] = emlrtCreateString(l);
  pArrays[11] = emlrtCreateDoubleScalar(m);
  pArrays[12] = emlrtCreateString(n);
  pArrays[13] = emlrtCreateDoubleScalar(o);
  return emlrtCallMATLABR2012b(sp, 1, &m2, 14, pArrays, "numerictype", true,
    location);
}

/*
 * Arguments    : const mxArray *src
 * Return Type  : uint8_T
 */
static uint8_T e_emlrt_marshallIn(const mxArray *src)
{
  uint8_T ret;
  const mxArray *mxInt;
  mxInt = emlrtImportFiIntArrayR2008b(src);
  ret = *(uint8_T *)mxGetData(mxInt);
  emlrtDestroyArray(&mxInt);
  emlrtDestroyArray(&src);
  return ret;
}

/*
 * Arguments    : const mxArray *src
 * Return Type  : uint8_T
 */
static uint8_T f_emlrt_marshallIn(const mxArray *src)
{
  uint8_T ret;
  const mxArray *mxInt;
  mxInt = emlrtImportFiIntArrayR2008b(src);
  ret = *(uint8_T *)mxGetData(mxInt);
  emlrtDestroyArray(&mxInt);
  emlrtDestroyArray(&src);
  return ret;
}

/*
 * File trailer for _coder_multiplication_fixpt_api.c
 *
 * [EOF]
 */
