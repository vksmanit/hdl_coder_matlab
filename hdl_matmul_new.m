function [c_out, state_store] =  hdl_matmul_new (a_in,b_in)

    persistent state;
    persistent A;
    persistent B;
    persistent C;
    persistent y_in;
    persistent x_in;
% interchange y_in and x_in for correct columns and rows order

    MAT_SIZE = int32(2);
    
    % state : 
    % 0 => input is being read,
    % 1 => multiplication started,
    % 2 => readout

    if isempty(state)
        state = (0);
    end
    if isempty(A)
        A = int32(zeros(MAT_SIZE,MAT_SIZE));
    end
    if isempty(B)
        B =int32( zeros(MAT_SIZE,MAT_SIZE));
    end
    if isempty(C)
        C = int32(zeros(MAT_SIZE,MAT_SIZE));
    end
    if isempty(y_in)
        y_in = int32(1);
    end
    if isempty(x_in)
        x_in = int32(1);
    end

    c_out = int32(0) ;
    if ((0) == state)
        A(x_in, y_in) = a_in;
        B(x_in, y_in) = b_in;
        if (MAT_SIZE == y_in)
            y_in = int32(1);
            if(MAT_SIZE == x_in)
                state = (1);
                x_in = int32(1);
            else
                x_in = x_in + int32(1);
            end
        else
            y_in = y_in +int32 (1);
        end
    end
    persistent temp;
    if isempty (temp)
        temp = int32(0);
    end

    if ((1) == state)
        for k = 1:MAT_SIZE
            temp = temp + int32(A(x_in,k))* int32(B(k,y_in));
        end
        %C(x_in,y_in) =int32(( A(x_in,:)) *( B (:,y_in)));
        if (MAT_SIZE == y_in)
            y_in = int32(1);
            if (MAT_SIZE == x_in)
                state = (2);
                x_in = int32(1);
            else 
                x_in = x_in + int32(1);
            end
        else 
            y_in = y_in + int32(1);
        end
    end

    if ((2) == state)
        c_out = int32(C(x_in,y_in));
        if (MAT_SIZE == y_in)
            y_in =int32 (1);
            if (MAT_SIZE == x_in)
                state = (0);
                x_in = int32(1);
            else 
                x_in = x_in + int32(1);
            end
        else 
            y_in = y_in + int32(1);
        end
    end
    state_store= int32(state);

end
