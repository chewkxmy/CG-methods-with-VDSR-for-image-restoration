clc;
clear all;

% Pretrained model
load("trainedVDSRNet.mat");

% Get image
testImage = 'pcb5.png'
Ireference = imread(testImage);
Ireference = im2double(Ireference);
figure;
imshow(Ireference)
title("High-Resolution Reference Image")

% Low-resolution image creation
scaleFactor = 0.05;
Ilowres = imresize(Ireference, scaleFactor, "bicubic");
figure;
imshow(Ilowres)
title("Low-Resolution Image")

% add CG method code here

% Convert to YCbCr color space
Iycbcr = rgb2ycbcr(Ilowres);
Iy = Iycbcr(:,:,1);
Icb = Iycbcr(:,:,2);
Icr = Iycbcr(:,:,3);

% Resize Y, Cb, and Cr channels
[nrows, ncols, ~] = size(Ireference); % Ensure dimensions match the reference
Iy_bicubic = imresize(Iy, [nrows ncols], "bicubic");
Icb_bicubic = imresize(Icb, [nrows ncols], "bicubic");
Icr_bicubic = imresize(Icr, [nrows ncols], "bicubic");

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
vdsrTime = toc; % Time for VDSR processing

% Compute evaluation metrics
vdsrPSNR = psnr(Ivdsr, Ireference);
vdsrSSIM = ssim(Ivdsr, Ireference);

% Compute relative error
relativeError = norm(Ivdsr - Ireference, 'fro') / norm(Ireference, 'fro');

% Display results
fprintf("PSNR: %.2f dB\n", vdsrPSNR);
fprintf("SSIM: %.4f\n", vdsrSSIM);
fprintf("Relative Error: %.4f\n", relativeError);
fprintf("VDSR Processing Time: %.4f seconds\n", vdsrTime);
