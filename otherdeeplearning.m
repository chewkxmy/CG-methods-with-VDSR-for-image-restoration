clc;
clear all;

% Add deep learning toolbox (ensure DnCNN is available)
if ~exist('denoisingNetwork', 'file')
    error('Deep Learning Toolbox is required for this script.');
end

%------------------------ IMAGE AND NOISE SETUP ----------------------------
% Input image filename
imname = 'pcb2.bmp';   % Replace with your image file

% Read the original image
X = imread(imname);

% Convert to grayscale if the image is RGB
if size(X, 3) == 3
    X = rgb2gray(X);
end

% Convert the image to double for processing
X = im2double(X);
XS = X; % Save the original image for comparison

% Noise levels to test
noise_levels = [0.2, 0.3, 0.5, 0.8];

% Initialize results for all methods
results = struct('NoiseLevel', {}, 'Method', {}, 'PSNR', {}, 'SSIM', {}, 'Time', {}, 'RelErr', {});

%------------------------ DnCNN METHOD ----------------------------
% Load the pre-trained DnCNN network
denNet = denoisingNetwork('DnCNN');

for i = 1:length(noise_levels)
    % Add salt & pepper noise
    noise_degree = noise_levels(i);
    Xp = imnoise(X, 'salt & pepper', noise_degree);

    % Start timing the restoration process
    t0 = tic;

    % Apply the DnCNN network for denoising
    restored = denoiseImage(Xp, denNet);

    % Record elapsed time
    Time = toc(t0);

    % Compute metrics
    PSNR = 10 * log10(1 / mean((XS(:) - restored(:)).^2)); % Peak Signal-to-Noise Ratio
    SSIMValue = ssim(restored, XS);                        % Structural Similarity Index
    RelErr = norm(XS(:) - restored(:)) / norm(XS(:));      % Relative Error

    % Save results
    results(end+1) = struct('NoiseLevel', noise_degree, 'Method', 'DnCNN', 'PSNR', PSNR, 'SSIM', SSIMValue, 'Time', Time, 'RelErr', RelErr);
end

%------------------------ AUTOENCODER METHOD ----------------------------
% Train or load an autoencoder (example here uses a placeholder)
% Train an autoencoder (requires noisy-clean image pairs)
autoenc = trainAutoencoder(XS, XS, 'MaxEpochs', 100, 'L2WeightRegularization', 0.001, 'SparsityRegularization', 4);

for i = 1:length(noise_levels)
    % Add salt & pepper noise
    noise_degree = noise_levels(i);
    Xp = imnoise(X, 'salt & pepper', noise_degree);

    % Start timing the restoration process
    t0 = tic;

    % Apply the autoencoder for denoising
    restored = predict(autoenc, Xp);

    % Record elapsed time
    Time = toc(t0);

    % Compute metrics
    PSNR = 10 * log10(1 / mean((XS(:) - restored(:)).^2)); % Peak Signal-to-Noise Ratio
    SSIMValue = ssim(restored, XS);                        % Structural Similarity Index
    RelErr = norm(XS(:) - restored(:)) / norm(XS(:));      % Relative Error

    % Save results
    results(end+1) = struct('NoiseLevel', noise_degree, 'Method', 'Autoencoder', 'PSNR', PSNR, 'SSIM', SSIMValue, 'Time', Time, 'RelErr', RelErr);
end

%------------------------ MEDIAN FILTER (BASELINE) ----------------------------
% Median filtering for comparison (non-deep learning)
for i = 1:length(noise_levels)
    % Add salt & pepper noise
    noise_degree = noise_levels(i);
    Xp = imnoise(X, 'salt & pepper', noise_degree);

    % Start timing the restoration process
    t0 = tic;

    % Apply median filter for denoising
    restored = medfilt2(Xp, [3 3]);

    % Record elapsed time
    Time = toc(t0);

    % Compute metrics
    PSNR = 10 * log10(1 / mean((XS(:) - restored(:)).^2)); % Peak Signal-to-Noise Ratio
    SSIMValue = ssim(restored, XS);                        % Structural Similarity Index
    RelErr = norm(XS(:) - restored(:)) / norm(XS(:));      % Relative Error

    % Save results
    results(end+1) = struct('NoiseLevel', noise_degree, 'Method', 'Median Filter', 'PSNR', PSNR, 'SSIM', SSIMValue, 'Time', Time, 'RelErr', RelErr);
end

%------------------------ DISPLAY RESULTS ----------------------------
% Display summary results in a table
resultsTable = struct2table(results);
disp(resultsTable);

% Optionally, plot the results
figure;
groupedMethods = unique(resultsTable.Method);
for i = 1:length(groupedMethods)
    methodResults = resultsTable(strcmp(resultsTable.Method, groupedMethods{i}), :);
    plot(methodResults.NoiseLevel, methodResults.PSNR, '-o', 'DisplayName', groupedMethods{i});
    hold on;
end
xlabel('Salt & Pepper Noise Level');
ylabel('PSNR');
title('PSNR Comparison for Different Methods');
legend;
grid on;
