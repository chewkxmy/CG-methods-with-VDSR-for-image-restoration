clc;
clear all;

% Pretrained model
load("trainedVDSRNet.mat");

% Get image
testImage = 'pcb1.png'
Ireference = imread(testImage);
Ireference = im2double(Ireference);
figure;
imshow(Ireference)
title("Original Image")

% Convert to YCbCr color space
Iycbcr = rgb2ycbcr(Ireference);
Iy = Iycbcr(:,:,1);
Icb = Iycbcr(:,:,2);
Icr = Iycbcr(:,:,3);

% Resize Y, Cb, and Cr channels
[nrows, ncols, np] = size(Ireference); % Ensure dimensions match the reference
Iy_bicubic = imresize(Iy, [nrows*4, ncols*4], "bicubic");
Icb_bicubic = imresize(Icb, [nrows*4, ncols*4], "bicubic");
Icr_bicubic = imresize(Icr, [nrows*4, ncols*4], "bicubic");

% Measure start time for VDSR process
tic;
Iresidual = activations(net, Iy_bicubic, 41);
Iresidual = double(Iresidual);
figure;
imshow(Iresidual, [])
title("Residual Image from VDSR")

% Generate high-resolution image
Isr = Iy_bicubic + Iresidual;
Ivdsr = ycbcr2rgb(cat(3, Isr, Icb_bicubic, Icr_bicubic));
figure;
imshow(Ivdsr)
title("High-Resolution Image Obtained Using VDSR")

% Low-resolution image creation
scaleFactor = 0.25;
Ilowres = imresize(Ivdsr, scaleFactor, "bicubic");
figure;
imshow(Ilowres)
title("Normal-Resolution Image")


vdsrTime = toc; % Time for VDSR processing

% Compute evaluation metrics
vdsrPSNR = psnr(Ilowres, Ireference);
vdsrSSIM = ssim(Ilowres, Ireference);

% Compute relative error
relativeError = norm(Ilowres - Ireference, 'fro') / norm(Ireference, 'fro');

% Display results
fprintf("PSNR: %.2f dB\n", vdsrPSNR);
fprintf("SSIM: %.4f\n", vdsrSSIM);
fprintf("Relative Error: %.4f\n", relativeError);
fprintf("VDSR Processing Time: %.4f seconds\n", vdsrTime);
