MAT_SIZE = 4
A = rand (MAT_SIZE, MAT_SIZE);
B = rand (MAT_SIZE, MAT_SIZE);
C = zeros (MAT_SIZE, MAT_SIZE);

% data input phase
for i=1:MAT_SIZE
  for j=1:MAT_SIZE
    [c_out, state] = hdl_mm (A(i,j), B(i,j));
  end
end

% computation phase
for i=1:MAT_SIZE
  for j=1:MAT_SIZE
    [c_out, state] = hdl_mm (0, 0);
  end
end

% readout phase
for i=1:MAT_SIZE
  for j=1:MAT_SIZE
    [c_out, state] = hdl_mm (0, 0);
    C(i, j) = c_out;
  end
end

max (max (abs (A*B - C)))
