function [c_out, state_store] =  hdl_matmul (a_in,b_in)

    persistent state;
    persistent A;
    persistent B;
    persistent C;
    persistent y_in;
    persistent x_in;
% interchange y_in and x_in for correct columns and rows order

    MAT_SIZE = 2;
    
    % state : 
    % 0 => input is being read,
    % 1 => multiplication started,
    % 2 => readout

    if isempty(state)
        state = 0;
    end
    if isempty(A)
        A = zeros(MAT_SIZE,MAT_SIZE);
    end
    if isempty(B)
        B = zeros(MAT_SIZE,MAT_SIZE);
    end
    if isempty(C)
        C = zeros(MAT_SIZE,MAT_SIZE);
    end
    if isempty(y_in)
        y_in = 1;
    end
    if isempty(x_in)
        x_in = 1;
    end

    c_out = int8(0) ;
    if (0 == state)
        A(x_in, y_in) = a_in;
        B(x_in, y_in) = b_in;
        if (MAT_SIZE == y_in)
            y_in = 1;
            if(MAT_SIZE == x_in)
                state = 1;
                x_in = 1;
            else
                x_in = x_in + 1;
            end
        else
            y_in = y_in + 1;
        end
    end

    if (1 == state)
        %C(x_in,y_in) =int8(double( A(x_in,:)) *double( B (:,y_in)));
        C(x_in,y_in) =(( A(x_in,:)) *( B (:,y_in)));
        if (MAT_SIZE == y_in)
            y_in = 1;
            if (MAT_SIZE == x_in)
                state = 2;
                x_in = 1;
            else 
                x_in = x_in + 1;
            end
        else 
            y_in = y_in + 1;
        end
    end

    if (2 == state)
        c_out = int8(C(x_in,y_in));
        if (MAT_SIZE == y_in)
            y_in = 1;
            if (MAT_SIZE == x_in)
                state = 0;
                x_in = 1;
            else 
                x_in = x_in + 1;
            end
        else 
            y_in = y_in + 1;
        end
    end
    state_store= int8(state);

end
