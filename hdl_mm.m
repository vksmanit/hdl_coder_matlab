function [c_out, state] = hdl_mm (a_in, b_in)
  MAT_SIZE = 4;
  % state : 0 => input is being read, 1 => multiplication started, 2 => readout
  persistent state;
  persistent A, B, C;
  persistent x_in, y_in;
  if isempty (state)
    state = 0;
  end
  if isempty (A)
    A = zeros (MAT_SIZE, MAT_SIZE);
  end
  if isempty (B)
    B = zeros (MAT_SIZE, MAT_SIZE);
  end
  if isempty (C)
    C = zeros (MAT_SIZE, MAT_SIZE);
  end
  if isempty (x_in)
    x_in = 1;
  end
  if isempty (y_in)
    y_in = 1;
  end
  c_out = 0;
  if (0 == state)
    A(x_in, y_in) = a_in;
    B(x_in, y_in) = b_in;
    if (MAT_SIZE == x_in)
      x_in = 1;
      if (MAT_SIZE == y_in)
         state = 1;
         y_in = 1;
      else
         y_in = y_in + 1
      end
    else
      x_in = x_in + 1;
    end
  end
  if (1 == state)
    C(x_in, y_in) = A(x_in, :) * B(:, y_in);
    if (MAT_SIZE == x_in)
      x_in = 1;
      if (MAT_SIZE == y_in)
         state = 2;
         y_in = 1;
      else
         y_in = y_in + 1
      end
    else
      x_in = x_in + 1;
    end
  end
  if (2 == state)
    c_out = C(x_in, y_in);
    if (MAT_SIZE == x_in)
      x_in = 1;
      if (MAT_SIZE == y_in)
         state = 0;
         y_in = 1;
      else
         y_in = y_in + 1
      end
    else
      x_in = x_in + 1;
    end
  end
end
