clc;
clear all;

% Load pretrained VDSR model
load("trainedVDSRNet.mat");

%------------------------ IMAGE SETUP ----------------------------
% Input image filename
testImage = 'pcb3.jpg';
Ireference = imread(testImage);
Ireference = im2double(Ireference);
figure;
imshow(Ireference);
title("High-Resolution Reference Image");

%------------------------ IDENTIFY SCALE ----------------------------
% Get image size (height, width, and number of color channels)
[height, width, numChannels] = size(Ireference);

% Calculate the total number of pixels
totalPixels = height * width;

%result = totalPixels / 100000;

% Display the result
%fprintf('Total number of pixels: %d\n', totalPixels);

%------------------------ LOW-RESOLUTION IMAGE ----------------------------
% Create low-resolution image
scaleFactor = sqrt(100000/totalPixels); % later train at 100,000 pixel
Ilowres = imresize(Ireference, scaleFactor, "bicubic");
figure;
imshow(Ilowres);
title("Low-Resolution Image");

%------------------------ ADD NOISE ----------------------------
% Define noise type and degree
noise = 'salt & pepper';       % Type of noise
noise_degree = 0.30;           % Noise degree

% Add noise to the low-resolution image
Xp = imnoise(Ilowres, noise, noise_degree);
figure;
imshow(Xp);
title('Noisy Low-Resolution Image');

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
X = im2double(Ilowres);     % Original low-resolution image
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
[uopt, galphaopt, gradientopt, NI, Nf] = PRP('gAlpha', 'NablagAlpha', uInitial, ...
    Tolerance, CRestart, MaxIter, delta, ro, minimumofalpha, maxiterLS);

% Update noisy pixels in the image with optimized values
for k = 1:LN
    X(N(k, 1), N(k, 2)) = uopt(k);
end

% Display the restored low-resolution image
figure;
imshow(X);
title('Restored Low-Resolution Image');

%------------------------ UPSCALE IMAGE USING VDSR ----------------------------
% Convert restored image back to RGB
X = im2uint8(X);

% Convert to YCbCr color space
Iycbcr = rgb2ycbcr(X);
Iy = Iycbcr(:,:,1);
Icb = Iycbcr(:,:,2);
Icr = Iycbcr(:,:,3);

% Resize Y, Cb, and Cr channels
[nrows, ncols, ~] = size(Ireference); % Ensure dimensions match the reference
Iy_bicubic = imresize(Iy, [nrows ncols], "bicubic");
Icb_bicubic = imresize(Icb, [nrows ncols], "bicubic");
Icr_bicubic = imresize(Icr, [nrows ncols], "bicubic");

% VDSR process
Iresidual = activations(net, Iy_bicubic, 41);
Iresidual = double(Iresidual);
figure;
imshow(Iresidual, []);
title("Residual Image from VDSR");

% Generate high-resolution image
Iy_bicubic = double(Iy_bicubic);
Isr = Iy_bicubic + Iresidual;
Ivdsr = ycbcr2rgb(cat(3, Isr, Icb_bicubic, Icr_bicubic));
figure;
imshow(Ivdsr);
title("High-Resolution Image Obtained Using VDSR");
Time = toc; % Time for CG&VDSR processing

%------------------------ EVALUATION METRICS ----------------------------
% Compute evaluation metrics
Ivdsr = im2double(Ivdsr);
vdsrPSNR = psnr(Ivdsr, Ireference);
vdsrSSIM = ssim(Ivdsr, Ireference);
relativeError = norm(Ivdsr - Ireference, 'fro') / norm(Ireference, 'fro');

% Display results
fprintf('Original image pixels: %d\n', totalPixels);
fprintf("PSNR: %.2f dB\n", vdsrPSNR);
fprintf("SSIM: %.4f\n", vdsrSSIM);
fprintf("Relative Error: %.4f\n", relativeError);
fprintf("Processing Time: %.4f seconds\n", Time);
