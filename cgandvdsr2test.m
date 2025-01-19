clc;
clear all;

% Load pretrained VDSR model
load("trainedVDSRNet.mat");

%------------------------ IMAGE SETUP ----------------------------
% Input image filename
testImage = 'pcb6.png';
Ireference = imread(testImage);
Ireference = im2double(Ireference);
figure;
imshow(Ireference);
title("Original Image");

%------------------------ ADD NOISE ----------------------------
% Define noise type and degree
noise = 'salt & pepper';       % Type of noise
noise_degree = 0.30;           % Noise degree

% Add noise to the low-resolution image
Inoise = imnoise(Ireference, noise, noise_degree);
figure;
imshow(Inoise);
title('Noisy Original Image');

%------------------------ UPSCALE IMAGE USING VDSR ----------------------------

% Convert to YCbCr color space
Iycbcr = rgb2ycbcr(Inoise);
Iy = Iycbcr(:,:,1);
Icb = Iycbcr(:,:,2);
Icr = Iycbcr(:,:,3);

% Resize Y, Cb, and Cr channels
[nrows, ncols, np] = size(Inoise); % Ensure dimensions match the reference
sc=2; % set scale factor
Iy_bicubic = imresize(Iy, [nrows*sc, ncols*sc], "bicubic");
Icb_bicubic = imresize(Icb, [nrows*sc, ncols*sc], "bicubic");
Icr_bicubic = imresize(Icr, [nrows*sc, ncols*sc], "bicubic");

% Measure start time for VDSR process
tic;
Iresidual = activations(net, Iy_bicubic, 41);
Iresidual = double(Iresidual);
figure;
imshow(Iresidual, [])
title("Residual Image from VDSR")

% Generate high-resolution image
Isr = Iy_bicubic + Iresidual;
Xp = ycbcr2rgb(cat(3, Isr, Icb_bicubic, Icr_bicubic));
figure;
imshow(Xp)
title("High-Resolution Noise Image Obtained Using VDSR")

fprintf('Starting restoration');

%------------------------ RESTORE NOISE ----------------------------
% Define global variables used in optimization
global alpha X N m n LN NhMat;

% Optimization parameters
delta = 0.0001;
MaxIter = 10000;
Tolerance = (10)^(-6);
LambdaInitial = 1;
CRestart = (10)^(-10);
ro = 0.95;
minimumofalpha = (10)^(-10);
maxiterLS = 1000;

% Initialize global variables
alpha = 1;

% Prepare image for restoration
[nrows,ncols,np] = size(Xp);
Ibicubic = imresize(Ireference,[nrows ncols],"bicubic");
X = im2double(Ibicubic);     % Original low-resolution image
Xp = im2double(Xp);         % Noisy low-resolution image
[m, n] = size(X);           % Image dimensions
[row, col, v] = find(X - Xp); % Find noisy pixels
LN = length(row);           % Number of noisy pixels

fprintf('Done prepare');

% Initialize neighborhood data structure and initial estimates
N = zeros(LN, 3);
uInitial = zeros(LN, 1);

% Fill neighborhood matrix `N` and initial guess `uInitial`
fprintf('Filling neighborhood matrix and initial estimates...\n');

% Fill neighborhood matrix `N` and initial guess `uInitial`
for k = 1:LN
    N(k, 1) = row(k);                     % Row of noisy pixel
    N(k, 2) = col(k);                     % Column of noisy pixel
    N(k, 3) = Xp(row(k), col(k));         % Value of noisy pixel in the noisy image
    uInitial(k) = LambdaInitial * X(row(k), col(k)) + (1 - LambdaInitial) * Xp(row(k), col(k));
    
    % Display progress every 100 iterations
    if mod(k, 100) == 0 || k == LN
        fprintf('Processed %d/%d pixels.\n', k, LN);
    end
end

fprintf('Neighborhood matrix and initial estimates completed.\n');


% Extract neighborhoods for noisy pixels
NhMat = ExtractNeighborhoods(N, X);  % External function placeholder

fprintf('Done neighbour');

tic;

fprintf('Starting optimization...\n');
hWaitbar = waitbar(0, 'Optimization in progress...');

for iter = 1:MaxIter
    [uopt, galphaopt, gradientopt, NI, Nf] = PRP('gAlpha', 'NablagAlpha', uInitial, ...
        Tolerance, CRestart, iter, delta, ro, minimumofalpha, maxiterLS);

    for k = 1:LN
        X(N(k, 1), N(k, 2)) = uopt(k);
    end

    waitbar(iter / MaxIter, hWaitbar, sprintf('Iteration %d of %d', iter, MaxIter));

    if norm(gradientopt) < Tolerance
        fprintf('Converged at iteration %d.\n', iter);
        break;
    end
end

close(hWaitbar);

% Display the restored low-resolution image
figure;
imshow(X);
title('Restored High-Resolution Image');

%------------------------ DOWNSCALE IMAGE USING VDSR ----------------------------
% Convert restored image back to RGB
X = im2uint8(X);

% Low-resolution image creation
scaleFactor = 1/sc;
Ivdsr = imresize(X, scaleFactor, "bicubic");
figure;
imshow(Ivdsr)
title("Normal-Resolution Image")

restoreTime = toc; % Time for VDSR processing

%------------------------ EVALUATION METRICS ----------------------------
% Compute evaluation metrics
Ivdsr = im2double(Ivdsr);
vdsrPSNR = psnr(Ivdsr, Ireference);
vdsrSSIM = ssim(Ivdsr, Ireference);
relativeError = norm(Ivdsr - Ireference, 'fro') / norm(Ireference, 'fro');

% Display results
fprintf("PSNR: %.2f dB\n", vdsrPSNR);
fprintf("SSIM: %.4f\n", vdsrSSIM);
fprintf("Relative Error: %.4f\n", relativeError);
fprintf("Processing Time: %.4f seconds\n", restoreTime);
