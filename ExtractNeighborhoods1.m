function NhMat = ExtractNeighborhoods1(N, X)
    % ExtractNeighborhoods computes the neighborhood structure for noisy pixels.
    %
    % Inputs:
    %   N  - A matrix (LN x 2) where each row contains the [row, col] indices
    %        of noisy pixels.
    %   X  - The noisy image (2D matrix).
    %
    % Outputs:
    %   NhMat - A matrix where each row describes the relationship between
    %           a noisy pixel and its neighbors:
    %           Column 1: Row index of the neighbor
    %           Column 2: Column index of the neighbor
    %           Column 3: Noise number k (center pixel index in N)
    %           Column 4: Indicates if the neighbor is noisy (1) or not (-1)
    %           Column 5: If noisy, the index of the neighbor in N, else 0

    LN = size(N, 1); % Number of noisy pixels in the list N
    NhMat = zeros(4 * LN, 5); % Pre-allocate for 4 neighbors per noisy pixel

    % Precompute for efficiency: Create a map for fast noise pixel lookup
    [~, noiseIndex] = ismember(N, N, 'rows');

    for k = 1:LN
        % Get the row and column of the k-th noisy pixel
        noisyRow = N(k, 1);
        noisyCol = N(k, 2);

        % Find the neighbors using 4-connectivity
        Nh = Vij(noisyRow, noisyCol, X);

        % Filter valid neighbors (ignoring out-of-bound neighbors)
        validNeighbors = Nh(:, 1) > 0 & Nh(:, 2) > 0;

        % Assign neighbors to NhMat
        NhMat(4 * k - 3:4 * k, 1:2) = Nh(:, 1:2); % Neighbor indices
        NhMat(4 * k - 3:4 * k, 3) = k;           % Center pixel index

        % Check if neighbors are noisy using precomputed indices
        neighbors = Nh(validNeighbors, :); % Filter out-of-bound neighbors
        [isNoisy, idx] = ismember(neighbors, N, 'rows');

        % Update columns 4 and 5
        NhMat(4 * k - 3:4 * k, 4) = -1;    % Default to non-noisy
        NhMat(4 * k - 3:4 * k, 5) = 0;     % Default index 0 for non-noisy
        NhMat(4 * k - 3 + find(validNeighbors), 4) = isNoisy * 2 - 1; % 1 if noisy, -1 if not
        NhMat(4 * k - 3 + find(validNeighbors), 5) = idx; % Index in N if noisy
    end

    % Post-processing to handle non-noisy neighbors
    for kk = 1:4 * LN
        if NhMat(kk, 4) == -1 % If the neighbor is not noisy
            NhMat(kk, 5) = NhMat(kk, 3); % Set the center pixel index
            % Trick: in the function gAlpha we get u(k) - u(k) = 0, no effect!
        end
    end
end