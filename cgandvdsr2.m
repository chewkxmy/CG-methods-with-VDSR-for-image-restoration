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

%------------------------ IDENTIFY SCALE ----------------------------
% Get image size (height, width, and number of color channels)
[height, width, numChannels] = size(Inoise);

% Calculate the total number of pixels
totalPixels = height * width;

%result = totalPixels / 100000;

% Display the result
fprintf('Total number of pixels: %d\n', totalPixels);

%------------------------ UPSCALE IMAGE USING VDSR ----------------------------

% Convert to YCbCr color space
Iycbcr = rgb2ycbcr(Inoise);
Iy = Iycbcr(:,:,1);
Icb = Iycbcr(:,:,2);
Icr = Iycbcr(:,:,3);

% Resize Y, Cb, and Cr channels
[nrows, ncols, np] = size(Inoise); % Ensure dimensions match the reference
sc = sqrt(100000/3/totalPixels); % set scale factor later train at 300,000 pixel
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

% Initialize neighborhood data structure and initial estimates
N = zeros(LN, 3);
uInitial = zeros(LN, 1);

% Fill neighborhood matrix `N` and initial guess `uInitial`
for k = 1:LN
    N(k, 1) = row(k);                     % Row of noisy pixel
    N(k, 2) = col(k);                     % Column of noisy pixel
    N(k, 3) = Xp(row(k), col(k));         % Value of noisy pixel in the noisy image
    uInitial(k) = LambdaInitial * X(row(k), col(k)) + (1 - LambdaInitial) * Xp(row(k), col(k));
end

% Extract neighborhoods for noisy pixels
NhMat = ExtractNeighborhoods(N, X);  % External function placeholder

tic;

% Call optimization function
[uopt, galphaopt, gradientopt, NI, Nf] = DY('gAlpha', 'NablagAlpha', uInitial, ...
    Tolerance, CRestart, MaxIter, delta, ro, minimumofalpha, maxiterLS);

% Update noisy pixels in the image with optimized values
for k = 1:LN
    X(N(k, 1), N(k, 2)) = uopt(k);
end

% Display the restored low-resolution image
figure;
imshow(X);
title('Restored High-Resolution Image');

%------------------------ DOWNSCALE IMAGE USING VDSR ----------------------------
% Convert restored image back to RGB
X = im2uint8(X);

% Low-resolution image creation
%scaleFactor = 1/sc;
%Ivdsr = imresize(X, scaleFactor, "bicubic");

% Get the reference image size
referenceSize = size(Ireference); % Assuming Ireference is the reference image

% Resize the image X to match the reference size using bicubic interpolation
Ivdsr = imresize(X, referenceSize(1:2), "bicubic");
figure;
imshow(Ivdsr)
title("Normal-Resolution Image")

restoreTime = toc; % Time for VDSR processing

%------------------------ EVALUATION METRICS ----------------------------
% Compute evaluation metrics
Ivdsr = im2double(Ivdsr);
vdsrPSNR = psnr(Ivdsr, Ireference);
vdsrSSIM = ssim(Ivdsr, Ireference);
relativeError = 100*norm(Ivdsr - Ireference, 'fro') / norm(Ireference, 'fro');

% Display results
fprintf("PSNR: %.2f dB\n", vdsrPSNR);
fprintf("SSIM: %.4f\n", vdsrSSIM);
fprintf("Relative Error: %.4f\n", relativeError);
fprintf("Processing Time: %.4f seconds\n", restoreTime);
