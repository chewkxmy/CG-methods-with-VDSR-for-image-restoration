% Vij.m
function Nh = Vij(i, j, X)
    %
    % Finding 4-connectivity neighbors of the node (i, j) in NEWS format.
    %
    % Inputs:
    %   i, j - Row and column indices of the current pixel
    %   X    - Input image (matrix)
    %
    % Output:
    %   Nh   - A 4x3 matrix where each row represents a neighbor:
    %          [row_index, col_index, intensity_value]
    %          For out-of-bound neighbors, the row is [0, 0, 0].

    [m, n] = size(X);  % Get dimensions of the image

    % North neighbor
    if i - 1 >= 1
        nd = [i-1, j, X(i-1,j)];
      else
        nd = [0, 0, 0];
    end

    % West neighbor
    if j - 1 >= 1
        wd = [i, j-1, X(i,j-1)];
      else
        wd = [0, 0, 0];
    end

    % East neighbor
    if j + 1 <= n
       ed = [i, j+1, X(i,j+1)];
    else
        ed = [0, 0, 0];
    end

    % South neighbor
    if i + 1 <= m
        sd = [i+1, j, X(i+1,j)];
    else
        sd = [0, 0, 0];
    end

    Nh = [nd; ed; wd; sd];
end