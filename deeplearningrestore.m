clc;
clear all;

% Add deep learning toolbox (ensure DnCNN is available)
if ~exist('denoisingNetwork', 'file')
    error('DnCNN network requires the Deep Learning Toolbox.');
end

%------------------------ IMAGE AND NOISE SETUP ----------------------------
% Input image filename
imname = 'pcb3.jpg';   % Replace with your image file

% Read the original image
X = imread(imname);

% Save the original image for comparison
XS = im2double(X); 

% Noise levels to test
noise_levels = [0.1, 0.2, 0.3];

% Initialize results
results = struct('NoiseLevel', {}, 'PSNR', {}, 'SSIM', {}, 'Time', {}, 'RelErr', {});

% Load the pre-trained DnCNN network
denNet = denoisingNetwork('DnCNN');

for i = 1:length(noise_levels)
    % Add salt & pepper noise
    noise_degree = noise_levels(i);
    Xp = imnoise(im2double(X), 'salt & pepper', noise_degree);

    % Display the noisy image
    figure;
    imshow(Xp);
    title(['Noisy Image (Salt & Pepper, Noise Level = ', num2str(noise_degree), ')']);

    % Start timing the restoration process
    t0 = tic;

    % Initialize restored image
    restored = zeros(size(Xp));

    % Denoise each channel separately
    for c = 1:size(Xp, 3)
        restored(:, :, c) = denoiseImage(Xp(:, :, c), denNet);
    end

    % Record elapsed time
    Time = toc(t0);

    % Compute metrics
    PSNR = 10 * log10(1 / mean((XS(:) - restored(:)).^2)); % Peak Signal-to-Noise Ratio
    SSIMValue = ssim(restored, XS);                        % Structural Similarity Index
    RelErr = norm(XS(:) - restored(:)) / norm(XS(:));      % Relative Error

    % Save results
    results(i).NoiseLevel = noise_degree;
    results(i).PSNR = PSNR;
    results(i).SSIM = SSIMValue;
    results(i).Time = Time;
    results(i).RelErr = RelErr;

    % Convert restored image back to uint8 for display
    restored_rgb = im2uint8(restored);

    % Display the restored image
    figure;
    imshow(restored_rgb);
    title(['Restored Image (Noise Level = ', num2str(noise_degree), ')']);

    % Display metrics
    fprintf('--- Noise Level: %.1f ---\n', noise_degree);
    fprintf('Processing Time: %.4f seconds\n', Time);
    fprintf('PSNR: %.4f\n', PSNR);
    fprintf('SSIM: %.4f\n', SSIMValue);
    fprintf('Relative Error: %.4f\n', RelErr);
    fprintf('\n');
end

% Display summary results
disp('Summary of Results:');
for i = 1:length(results)
    fprintf('Noise Level: %.1f | PSNR: %.4f | SSIM: %.4f | Time: %.4f s | RelErr: %.4f\n', ...
        results(i).NoiseLevel, results(i).PSNR, results(i).SSIM, results(i).Time, results(i).RelErr);
end
