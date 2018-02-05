%simple_vec_dot_product_tb(

a = int32([ 1 2 3 4; 2 3 4 5]) ;
b = int32([ 3 4 5 6;7 8 9 4]) ;
%c = [ 2 3 4 5];
%d = [ 7 8 9 4];

for i = 1:2
    out = simple_vec_dot_product(a(i,:),b(i,:))
end

