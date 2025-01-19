function ImageRestorationGUI()
    % Create a simple GUI for image restoration
    clc;
    clear;

    % Define global variables used in optimization
    global alpha X N m n LN NhMat

    % Optimization parameters
    delta = 0.0001;                % Step size for iterations
    MaxIter = 10000;               % Maximum number of iterations
    Tolerance = 1e-6;              % Convergence criterion
    LambdaInitial = 1;             % Initial lambda value for blending
    CRestart = 1e-10;              % Restart criterion
    ro = 0.95;                     % Line search parameter
    minimumofalpha = 1e-10;        % Minimum step size for alpha
    maxiterLS = 1000;              % Maximum iterations for line search

    % Initial global variables
    alpha = 1;

    % Create the GUI
    fig = uifigure('Name', 'Image Restoration', 'Position', [100, 100, 800, 600]);

    % Create UI components
    uploadBtn = uibutton(fig, 'Text', 'Upload Image', 'Position', [50, 550, 100, 30], ...
        'ButtonPushedFcn', @(btn, event) uploadImage());

    restoreBtn = uibutton(fig, 'Text', 'Restore Image', 'Position', [200, 550, 100, 30], ...
        'ButtonPushedFcn', @(btn, event) restoreImage());

    noisyAx = uiaxes(fig, 'Position', [50, 150, 300, 300]);
    noisyAx.Title.String = 'Noisy Image';

    restoredAx = uiaxes(fig, 'Position', [450, 150, 300, 300]);
    restoredAx.Title.String = 'Restored Image';

    % Global variables for GUI
    global noisyImage restoredImage filepath;
    noisyImage = [];
    restoredImage = [];
    filepath = '';

    % Callback for uploading image
    function uploadImage()
        [file, path] = uigetfile({'*.jpg;*.png;*.bmp', 'Image Files (*.jpg, *.png, *.bmp)'}, ...
            'Select a Noisy Image', 'C:\Users\nicet\Downloads\Kai Xian\Mathematics Research\Code\Combine\Demo Image');
        
        if isequal(file, 0)
            uialert(fig, 'No file selected', 'Error');
            return;
        end

        filepath = fullfile(path, file);
        noisyImage = imread(filepath);

        % Display the noisy image
        imshow(noisyImage, 'Parent', noisyAx);
        noisyAx.Title.String = 'Noisy Image';
    end

    % Callback for restoring image
    function restoreImage()
        if isempty(noisyImage)
            uialert(fig, 'Please upload a noisy image first', 'Error');
            return;
        end

        % Convert noisy image to double
        X = im2double(noisyImage);
        XS = X;               % Save the original image for comparison
        Xp = X;               % Assume noisy image for simplicity

        % Image dimensions
        [m, n] = size(X);

        % Find noisy pixels (assuming salt & pepper noise for simplicity)
        [row, col, v] = find(X - Xp);

        % Number of noisy pixels
        LN = length(row);

        % Initialize neighborhood data structure and initial estimates
        N = zeros(LN, 3);
        uInitial = zeros(LN, 1);

        % Fill neighborhood matrix `N` and initial guess `uInitial`
        for k = 1:LN
            N(k, 1) = row(k);                     % Row of noisy pixel
            N(k, 2) = col(k);                     % Column of noisy pixel
            N(k, 3) = Xp(row(k), col(k));         % Value of noisy pixel in the noisy image

            % Linear blending between noisy and original pixel value
            uInitial(k) = LambdaInitial * X(row(k), col(k)) + (1 - LambdaInitial) * Xp(row(k), col(k));
        end

        % Extract neighborhoods for noisy pixels
        NhMat = ExtractNeighborhoods(N, X);  % External function placeholder

        % Call optimization function
        [uopt, ~, ~, ~, ~] = RMIL('gAlpha', 'NablagAlpha', uInitial, ...
            Tolerance, CRestart, MaxIter, delta, ro, minimumofalpha, maxiterLS);

        % Update noisy pixels in the image with optimized values
        for k = 1:LN
            X(N(k, 1), N(k, 2)) = uopt(k);
        end

        % Convert restored image back to uint8 format
        restoredImage = im2uint8(X);

        % Display the restored image
        imshow(restoredImage, 'Parent', restoredAx);
        restoredAx.Title.String = 'Restored Image';
    end
end

% Placeholder for `ExtractNeighborhoods` function
function NhMat = ExtractNeighborhoods(N, X)
    % Dummy implementation for demonstration purposes
    NhMat = []; % Replace with actual neighborhood extraction logic
end

% Placeholder for `RMIL` optimization function
function [uopt, galphaopt, gradientopt, NI, Nf] = RMIL(fname, dfname, uInitial, ...
        Tolerance, CRestart, MaxIter, delta, ro, minimumofalpha, maxiterLS)
    % Dummy implementation for demonstration purposes
    uopt = uInitial; % Replace with actual optimization logic
    galphaopt = [];
    gradientopt = [];
    NI = 0;
    Nf = 0;
end
