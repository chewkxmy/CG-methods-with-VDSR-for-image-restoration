function NhMat = ExtractNeighborhoods(N, X)
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

    LN = length(N); % Number of noisy pixels in the list N
    NhMat = zeros(4 * LN, 5); % Pre-allocate for 4 neighbors per noisy pixel

    % Uncomment one of the following for progress tracking:
    % Option 1: Command-line progress tracking with fprintf
    fprintf('Extracting neighborhoods for %d noisy pixels...\n', LN);

    % Option 2: Graphical progress tracking with waitbar
    % hWaitbar = waitbar(0, 'Extracting neighborhoods...');

    for k = 1:LN
        % Get the row and column of the k-th noisy pixel
        noisyRow = N(k, 1);
        noisyCol = N(k, 2);

        % Find the neighbors using 4-connectivity
        Nh = Vij(noisyRow, noisyCol, X);

        w = (Nh(1:4, 1) ~= 0);

        NhMat(4 * k - 3:4 * k, 1:2) = Nh(1:4, 1:2);
        NhMat(4 * k - 3:4 * k, 3) = k;
        FN = [FindN(Nh(1, 1), Nh(1, 2), N); 
              FindN(Nh(2, 1), Nh(2, 2), N); 
              FindN(Nh(3, 1), Nh(3, 2), N); 
              FindN(Nh(4, 1), Nh(4, 2), N)];
        NhMat(4 * k - 3:4 * k, 4) = w .* FN(:, 1);
        NhMat(4 * k - 3:4 * k, 5) = w .* FN(:, 2);

        % Update progress
        if mod(k, 100) == 0 || k == LN
            % Option 1: Command-line output
            fprintf('Processed %d/%d pixels.\n', k, LN);

            % Option 2: Update waitbar
            % waitbar(k / LN, hWaitbar, sprintf('Processing pixel %d of %d...', k, LN));
        end
    end

    % Close waitbar if used
    % if exist('hWaitbar', 'var')
    %     close(hWaitbar);
    % end

    % Post-processing to handle non-noisy neighbors
    for kk = 1:4 * LN
        if NhMat(kk, 4) == -1 % If the neighbor is not noisy
            NhMat(kk, 5) = NhMat(kk, 3); % Set the center pixel index
            % Trick: in the function gAlpha we get u(k) - u(k) = 0, no effect!
        end
    end

    fprintf('Neighborhood extraction completed.\n');
end
