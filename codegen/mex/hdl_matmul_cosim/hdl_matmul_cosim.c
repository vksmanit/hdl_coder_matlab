/*
 * hdl_matmul_cosim.c
 *
 * Code generation for function 'hdl_matmul_cosim'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "hdl_matmul_cosim.h"
#include "hdl_matmul_cosim_data.h"

/* Variable Definitions */
static emlrtRSInfo emlrtRSI = { 21, "hdl_matmul_cosim",
  "/home/vipinsoni/MTP/hdl_coder_matlab/codegen/hdl_matmul/cosim/hdl_matmul_cosim.m"
};

static emlrtMCInfo emlrtMCI = { 24, 1, "hdl_matmul_cosim",
  "/home/vipinsoni/MTP/hdl_coder_matlab/codegen/hdl_matmul/cosim/hdl_matmul_cosim.m"
};

static emlrtMCInfo b_emlrtMCI = { 27, 1, "hdl_matmul_cosim",
  "/home/vipinsoni/MTP/hdl_coder_matlab/codegen/hdl_matmul/cosim/hdl_matmul_cosim.m"
};

static emlrtMCInfo c_emlrtMCI = { 28, 1, "hdl_matmul_cosim",
  "/home/vipinsoni/MTP/hdl_coder_matlab/codegen/hdl_matmul/cosim/hdl_matmul_cosim.m"
};

static emlrtDCInfo emlrtDCI = { 39, 11, "hdl_matmul",
  "/home/vipinsoni/MTP/hdl_coder_matlab/hdl_matmul.m", 1 };

static emlrtBCInfo emlrtBCI = { 1, 2, 39, 11, "A", "hdl_matmul",
  "/home/vipinsoni/MTP/hdl_coder_matlab/hdl_matmul.m", 0 };

static emlrtDCInfo b_emlrtDCI = { 39, 17, "hdl_matmul",
  "/home/vipinsoni/MTP/hdl_coder_matlab/hdl_matmul.m", 1 };

static emlrtBCInfo b_emlrtBCI = { 1, 2, 39, 17, "A", "hdl_matmul",
  "/home/vipinsoni/MTP/hdl_coder_matlab/hdl_matmul.m", 0 };

static emlrtDCInfo c_emlrtDCI = { 56, 28, "hdl_matmul",
  "/home/vipinsoni/MTP/hdl_coder_matlab/hdl_matmul.m", 1 };

static emlrtBCInfo c_emlrtBCI = { 1, 2, 56, 28, "A", "hdl_matmul",
  "/home/vipinsoni/MTP/hdl_coder_matlab/hdl_matmul.m", 0 };

static emlrtDCInfo d_emlrtDCI = { 40, 11, "hdl_matmul",
  "/home/vipinsoni/MTP/hdl_coder_matlab/hdl_matmul.m", 1 };

static emlrtBCInfo d_emlrtBCI = { 1, 2, 40, 11, "B", "hdl_matmul",
  "/home/vipinsoni/MTP/hdl_coder_matlab/hdl_matmul.m", 0 };

static emlrtDCInfo e_emlrtDCI = { 40, 17, "hdl_matmul",
  "/home/vipinsoni/MTP/hdl_coder_matlab/hdl_matmul.m", 1 };

static emlrtBCInfo e_emlrtBCI = { 1, 2, 40, 17, "B", "hdl_matmul",
  "/home/vipinsoni/MTP/hdl_coder_matlab/hdl_matmul.m", 0 };

static emlrtDCInfo f_emlrtDCI = { 56, 45, "hdl_matmul",
  "/home/vipinsoni/MTP/hdl_coder_matlab/hdl_matmul.m", 1 };

static emlrtBCInfo f_emlrtBCI = { 1, 2, 56, 45, "B", "hdl_matmul",
  "/home/vipinsoni/MTP/hdl_coder_matlab/hdl_matmul.m", 0 };

static emlrtDCInfo g_emlrtDCI = { 56, 11, "hdl_matmul",
  "/home/vipinsoni/MTP/hdl_coder_matlab/hdl_matmul.m", 1 };

static emlrtBCInfo g_emlrtBCI = { 1, 2, 56, 11, "C", "hdl_matmul",
  "/home/vipinsoni/MTP/hdl_coder_matlab/hdl_matmul.m", 0 };

static emlrtDCInfo h_emlrtDCI = { 56, 16, "hdl_matmul",
  "/home/vipinsoni/MTP/hdl_coder_matlab/hdl_matmul.m", 1 };

static emlrtBCInfo h_emlrtBCI = { 1, 2, 56, 16, "C", "hdl_matmul",
  "/home/vipinsoni/MTP/hdl_coder_matlab/hdl_matmul.m", 0 };

static emlrtBCInfo i_emlrtBCI = { 1, 2, 71, 24, "C", "hdl_matmul",
  "/home/vipinsoni/MTP/hdl_coder_matlab/hdl_matmul.m", 0 };

static emlrtDCInfo i_emlrtDCI = { 71, 24, "hdl_matmul",
  "/home/vipinsoni/MTP/hdl_coder_matlab/hdl_matmul.m", 1 };

static emlrtBCInfo j_emlrtBCI = { 1, 2, 71, 29, "C", "hdl_matmul",
  "/home/vipinsoni/MTP/hdl_coder_matlab/hdl_matmul.m", 0 };

static emlrtDCInfo j_emlrtDCI = { 71, 29, "hdl_matmul",
  "/home/vipinsoni/MTP/hdl_coder_matlab/hdl_matmul.m", 1 };

static emlrtRSInfo b_emlrtRSI = { 28, "hdl_matmul_cosim",
  "/home/vipinsoni/MTP/hdl_coder_matlab/codegen/hdl_matmul/cosim/hdl_matmul_cosim.m"
};

static emlrtRSInfo c_emlrtRSI = { 27, "hdl_matmul_cosim",
  "/home/vipinsoni/MTP/hdl_coder_matlab/codegen/hdl_matmul/cosim/hdl_matmul_cosim.m"
};

static emlrtRSInfo d_emlrtRSI = { 24, "hdl_matmul_cosim",
  "/home/vipinsoni/MTP/hdl_coder_matlab/codegen/hdl_matmul/cosim/hdl_matmul_cosim.m"
};

/* Function Declarations */
static void hdl_matmul_sysobj_cosim(const emlrtStack *sp, const mxArray *b,
  const mxArray *c, emlrtMCInfo *location, const mxArray **d, const mxArray **e);
static void hdlverifier_assert(const emlrtStack *sp, const mxArray *b, const
  mxArray *c, const mxArray *d, emlrtMCInfo *location);

/* Function Definitions */
static void hdl_matmul_sysobj_cosim(const emlrtStack *sp, const mxArray *b,
  const mxArray *c, emlrtMCInfo *location, const mxArray **d, const mxArray **e)
{
  const mxArray *pArrays[2];
  const mxArray *mv0[2];
  pArrays[0] = b;
  pArrays[1] = c;
  emlrtAssign(d, emlrtCallMATLABR2012b(sp, 2, &mv0[0], 2, pArrays,
    "hdl_matmul_sysobj_cosim", true, location));
  emlrtAssign(e, mv0[1]);
}

static void hdlverifier_assert(const emlrtStack *sp, const mxArray *b, const
  mxArray *c, const mxArray *d, emlrtMCInfo *location)
{
  const mxArray *pArrays[3];
  pArrays[0] = b;
  pArrays[1] = c;
  pArrays[2] = d;
  emlrtCallMATLABR2012b(sp, 0, NULL, 3, pArrays, "hdlverifier.assert", true,
                        location);
}

void hdl_matmul_cosim(const emlrtStack *sp, int8_T a_in, int8_T b_in, const
                      mxArray **c_out, const mxArray **state_store)
{
  int8_T ref_c_out;
  int32_T i;
  int32_T i0;
  real_T y;
  int8_T ref_state_store;
  const mxArray *b_y;
  const mxArray *m0;
  const mxArray *c_y;
  const mxArray *b_state_store = NULL;
  const mxArray *b_c_out = NULL;
  const mxArray *d_y;
  const mxArray *e_y;
  static const int32_T iv0[2] = { 1, 5 };

  char_T cv0[5];
  static const char_T cv1[5] = { 'c', '_', 'o', 'u', 't' };

  const mxArray *f_y;
  const mxArray *g_y;
  static const int32_T iv1[2] = { 1, 11 };

  char_T cv2[11];
  static const char_T cv3[11] = { 's', 't', 'a', 't', 'e', '_', 's', 't', 'o',
    'r', 'e' };

  emlrtStack st;
  st.prev = sp;
  st.tls = sp->tls;
  *state_store = NULL;
  *c_out = NULL;

  /*  Auto generated function to simulate the generated HDL code using cosimulation */
  /*   */
  /*  Generated by MATLAB 8.4 and HDL Coder 3.5 */
  /*  Declare persistent variables */
  /*  Initialize persistent variables */
  /*  Call the original MATLAB function to get reference signal */
  st.site = &emlrtRSI;

  /*  interchange y_in and x_in for correct columns and rows order */
  /*  state :  */
  /*  0 => input is being read, */
  /*  1 => multiplication started, */
  /*  2 => readout */
  ref_c_out = 0;
  if (0.0 == state) {
    i = (int32_T)emlrtIntegerCheckFastR2012b(x_in, &emlrtDCI, &st);
    i0 = (int32_T)emlrtIntegerCheckFastR2012b(y_in, &b_emlrtDCI, &st);
    A[(emlrtDynamicBoundsCheckFastR2012b(i, 1, 2, &emlrtBCI, &st) +
       ((emlrtDynamicBoundsCheckFastR2012b(i0, 1, 2, &b_emlrtBCI, &st) - 1) << 1))
      - 1] = a_in;
    i = (int32_T)emlrtIntegerCheckFastR2012b(x_in, &d_emlrtDCI, &st);
    i0 = (int32_T)emlrtIntegerCheckFastR2012b(y_in, &e_emlrtDCI, &st);
    B[(emlrtDynamicBoundsCheckFastR2012b(i, 1, 2, &d_emlrtBCI, &st) +
       ((emlrtDynamicBoundsCheckFastR2012b(i0, 1, 2, &e_emlrtBCI, &st) - 1) << 1))
      - 1] = b_in;
    if (2.0 == y_in) {
      y_in = 1.0;
      if (2.0 == x_in) {
        state = 1.0;
        x_in = 1.0;
      } else {
        x_in++;
      }
    } else {
      y_in++;
    }
  }

  if (1.0 == state) {
    /* C(x_in,y_in) =int8(double( A(x_in,:)) *double( B (:,y_in))); */
    i = (int32_T)emlrtIntegerCheckFastR2012b(x_in, &c_emlrtDCI, &st);
    emlrtDynamicBoundsCheckFastR2012b(i, 1, 2, &c_emlrtBCI, &st);
    i = (int32_T)emlrtIntegerCheckFastR2012b(y_in, &f_emlrtDCI, &st);
    emlrtDynamicBoundsCheckFastR2012b(i, 1, 2, &f_emlrtBCI, &st);
    y = 0.0;
    for (i = 0; i < 2; i++) {
      y += A[((int32_T)x_in + (i << 1)) - 1] * B[i + (((int32_T)y_in - 1) << 1)];
    }

    i = (int32_T)emlrtIntegerCheckFastR2012b(x_in, &g_emlrtDCI, &st);
    i0 = (int32_T)emlrtIntegerCheckFastR2012b(y_in, &h_emlrtDCI, &st);
    C[(emlrtDynamicBoundsCheckFastR2012b(i, 1, 2, &g_emlrtBCI, &st) +
       ((emlrtDynamicBoundsCheckFastR2012b(i0, 1, 2, &h_emlrtBCI, &st) - 1) << 1))
      - 1] = y;
    if (2.0 == y_in) {
      y_in = 1.0;
      if (2.0 == x_in) {
        state = 2.0;
        x_in = 1.0;
      } else {
        x_in++;
      }
    } else {
      y_in++;
    }
  }

  if (2.0 == state) {
    i = (int32_T)emlrtIntegerCheckFastR2012b(x_in, &i_emlrtDCI, &st);
    i0 = (int32_T)emlrtIntegerCheckFastR2012b(y_in, &j_emlrtDCI, &st);
    y = muDoubleScalarRound(C[(emlrtDynamicBoundsCheckFastR2012b(i, 1, 2,
      &i_emlrtBCI, &st) + ((emlrtDynamicBoundsCheckFastR2012b(i0, 1, 2,
      &j_emlrtBCI, &st) - 1) << 1)) - 1]);
    if (y < 128.0) {
      if (y >= -128.0) {
        ref_c_out = (int8_T)y;
      } else {
        ref_c_out = MIN_int8_T;
      }
    } else if (y >= 128.0) {
      ref_c_out = MAX_int8_T;
    } else {
      ref_c_out = 0;
    }

    if (2.0 == y_in) {
      y_in = 1.0;
      if (2.0 == x_in) {
        state = 0.0;
        x_in = 1.0;
      } else {
        x_in++;
      }
    } else {
      y_in++;
    }
  }

  y = muDoubleScalarRound(state);
  if (y < 128.0) {
    if (y >= -128.0) {
      ref_state_store = (int8_T)y;
    } else {
      ref_state_store = MIN_int8_T;
    }
  } else if (y >= 128.0) {
    ref_state_store = MAX_int8_T;
  } else {
    ref_state_store = 0;
  }

  /*  Run cosimulation */
  b_y = NULL;
  m0 = emlrtCreateNumericMatrix(1, 1, mxINT8_CLASS, mxREAL);
  *(int8_T *)mxGetData(m0) = a_in;
  emlrtAssign(&b_y, m0);
  c_y = NULL;
  m0 = emlrtCreateNumericMatrix(1, 1, mxINT8_CLASS, mxREAL);
  *(int8_T *)mxGetData(m0) = b_in;
  emlrtAssign(&c_y, m0);
  st.site = &d_emlrtRSI;
  hdl_matmul_sysobj_cosim(&st, b_y, c_y, &emlrtMCI, &b_c_out, &b_state_store);
  emlrtAssign(c_out, emlrtAlias(b_c_out));
  emlrtAssign(state_store, emlrtAlias(b_state_store));

  /*  Verify the cosimulation output */
  d_y = NULL;
  m0 = emlrtCreateNumericMatrix(1, 1, mxINT8_CLASS, mxREAL);
  *(int8_T *)mxGetData(m0) = ref_c_out;
  emlrtAssign(&d_y, m0);
  e_y = NULL;
  m0 = emlrtCreateCharArray(2, iv0);
  for (i = 0; i < 5; i++) {
    cv0[i] = cv1[i];
  }

  emlrtInitCharArrayR2013a(sp, 5, m0, cv0);
  emlrtAssign(&e_y, m0);
  st.site = &c_emlrtRSI;
  hdlverifier_assert(&st, emlrtAlias(*c_out), d_y, e_y, &b_emlrtMCI);
  f_y = NULL;
  m0 = emlrtCreateNumericMatrix(1, 1, mxINT8_CLASS, mxREAL);
  *(int8_T *)mxGetData(m0) = ref_state_store;
  emlrtAssign(&f_y, m0);
  g_y = NULL;
  m0 = emlrtCreateCharArray(2, iv1);
  for (i = 0; i < 11; i++) {
    cv2[i] = cv3[i];
  }

  emlrtInitCharArrayR2013a(sp, 11, m0, cv2);
  emlrtAssign(&g_y, m0);
  st.site = &b_emlrtRSI;
  hdlverifier_assert(&st, emlrtAlias(*state_store), f_y, g_y, &c_emlrtMCI);
  emlrtDestroyArray(&b_c_out);
  emlrtDestroyArray(&b_state_store);
}

void hdl_matmul_cosim_init(void)
{
}

void initialized_not_empty_init(void)
{
}

/* End of code generation (hdl_matmul_cosim.c) */
