clc;
clear all;

% Pretrained VDSR model
load("trainedVDSRNet.mat");

% Input image filename
testImage = 'pcb3.jpg';
Ireference = imread(testImage);
Ireference = im2double(Ireference);
figure;
imshow(Ireference);
title("High-Resolution Reference Image");

%------------------------ LOW-RESOLUTION IMAGE GENERATION -----------------
scaleFactor = 0.25; % Downscale factor for low-resolution image
Ilowres = imresize(Ireference, scaleFactor, "bicubic");
figure;
imshow(Ilowres);
title("Low-Resolution Image");

%------------------------ ADD NOISE TO IMAGE ------------------------------
noiseType = 'salt & pepper'; % Type of noise
noiseDegree = 0.10; % Noise level
Inoisy = imnoise(Ilowres, noiseType, noiseDegree);
figure;
imshow(Inoisy);
title("Noisy Low-Resolution Image");

%------------------------ IMAGE RESTORATION -------------------------------
% Convert noisy image to double for processing
Inoisy = im2double(Inoisy);

% Image dimensions
[m, n, ~] = size(Inoisy);

% Separate YCbCr channels
Iycbcr_noisy = rgb2ycbcr(Inoisy);
Iy_noisy = Iycbcr_noisy(:,:,1);
Icb_noisy = Iycbcr_noisy(:,:,2);
Icr_noisy = Iycbcr_noisy(:,:,3);

% Initialize restored Y channel
Iy_restored = medfilt2(Iy_noisy, [3, 3]); % Median filter for noise removal

% Combine restored Y with original Cb and Cr
Iycbcr_restored = cat(3, Iy_restored, Icb_noisy, Icr_noisy);
Irestored = ycbcr2rgb(Iycbcr_restored);
figure;
imshow(Irestored);
title("Restored Low-Resolution Image");

%------------------------ SUPER-RESOLUTION USING VDSR ---------------------
% Resize Y, Cb, and Cr channels to match high-resolution dimensions
[nrows, ncols, ~] = size(Ireference);
Iy_restored_bicubic = imresize(Iy_restored, [nrows ncols], "bicubic");
Icb_bicubic = imresize(Icb_noisy, [nrows ncols], "bicubic");
Icr_bicubic = imresize(Icr_noisy, [nrows ncols], "bicubic");

% Measure start time for VDSR process
tic;
Iresidual = activations(net, Iy_restored_bicubic, 41);
Iresidual = double(Iresidual);

% Generate high-resolution image
Isr = Iy_restored_bicubic + Iresidual;
Ivdsr = ycbcr2rgb(cat(3, Isr, Icb_bicubic, Icr_bicubic));
figure;
imshow(Ivdsr);
title("High-Resolution Image Obtained Using VDSR");
vdsrTime = toc; % Time for VDSR processing

%------------------------ EVALUATION METRICS ------------------------------
% Compute evaluation metrics
vdsrPSNR = psnr(Ivdsr, Ireference);
vdsrSSIM = ssim(Ivdsr, Ireference);
relativeError = norm(Ivdsr - Ireference, 'fro') / norm(Ireference, 'fro');

% Display results
fprintf("PSNR: %.2f dB\n", vdsrPSNR);
fprintf("SSIM: %.4f\n", vdsrSSIM);
fprintf("Relative Error: %.4f\n", relativeError);
fprintf("VDSR Processing Time: %.4f seconds\n", vdsrTime);
