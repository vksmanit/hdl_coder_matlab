MAT_SIZE = int32(2);

%A = rand (MAT_SIZE, MAT_SIZE)
%B = rand (MAT_SIZE, MAT_SIZE)
%A = [ 1 2 3 4 ; 5 6 7 8 ; 9 10 11 12; 13 14 15 16];
%B = [ 2 3 4 5 ; 6 7 8 9 ; 10 11 12 13; 14 15 16 17];
A = int32([ 1 2 ; 9 10]);
B = int32([ 2 8  ; 10 11]); 
C = int32(zeros (MAT_SIZE, MAT_SIZE));

%data input phase
for i = 1:MAT_SIZE
   for j = 1:MAT_SIZE
        [c_out, state] = hdl_matmul_new (A(i,j), B(i,j));
   end
end
% computation phase
for i = 1:MAT_SIZE
   for j = 1:MAT_SIZE
       [c_out,state] = hdl_matmul_new(int32(0),int32(0))
   end
end
% readout phase
for i = 1:MAT_SIZE
   for j = 1:MAT_SIZE
       [c_out,state ] = hdl_matmul_new(int32(0),int32(0))
       C(i,j) = c_out;
   end
end
%max (max (abs (A*B - C)))
