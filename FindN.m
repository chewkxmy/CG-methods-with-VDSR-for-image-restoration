% FindN.m
function NF = FindN(i, j, N)
    %
    % Determine if (i, j) is a noise position in N.
    %
    % Inputs:
    %   i, j - Row and column indices of the pixel.
    %   N    - A matrix where each row represents a noise position [row, col].
    %
    % Output:
    %   NF   - A 1x2 vector:
    %          [1, k] if (i, j) is found at the k-th position in N.
    %          [-1, 0] if (i, j) is not found in N.
    %

    LN = length(N);
    firsttrying = 1;
    k = 1;

    % Initialize output as not found
    NF = [-1, 0];

    % Search for (i, j) in N
    while k <= LN && firsttrying
        if N(k, 1) == i && N(k, 2) == j
            NF = [1, k];  % Found: set flag and index
           firsttrying = 0;
        end
       k = k + 1; 
    end
    
end
