% Example data for the methods and metrics
noise_degree = [30, 50, 80];
HS_SSIM = [0.9690, 0.9421, 0.8898];
PRP_SSIM = [0.9697, 0.9426, 0.8909];
DY_SSIM = [0.9686, 0.9432, 0.8897];
RMIL_SSIM = [0.9698, 0.9418, 0.8898];

HS_PSNR = [24.4257, 21.8151, 19.3219];
PRP_PSNR = [24.5047, 21.8607, 19.4058];
DY_PSNR = [24.3208, 21.8915, 19.3332];
RMIL_PSNR = [24.5382, 21.8437, 19.3450];

HS_RelErr = [3.4251, 4.6260, 6.1641];
PRP_RelErr = [3.3941, 4.6018, 6.1048];
DY_RelErr = [3.4667, 4.5855, 6.1560];
RMIL_RelErr = [3.3810, 4.6108, 6.1477];

HS_Time = [35.4083, 113.1364, 80.8718];
PRP_Time = [38.4333, 67.1938, 73.1058];
DY_Time = [63.6301, 117.8929, 80.6126];
RMIL_Time = [72.0681, 115.8810, 75.9384];

% Plot SSIM
figure;
subplot(2, 2, 1);
plot(noise_degree, HS_SSIM, '-o', 'Color', 'b', 'LineWidth', 1.5, 'DisplayName', 'HS');
hold on;
plot(noise_degree, PRP_SSIM, '-s', 'Color', 'g', 'LineWidth', 1.5, 'DisplayName', 'PRP');
plot(noise_degree, DY_SSIM, '-^', 'Color', 'm', 'LineWidth', 1.5, 'DisplayName', 'DY');
plot(noise_degree, RMIL_SSIM, '-d', 'Color', 'r', 'LineWidth', 1.5, 'DisplayName', 'RMIL');
xlabel('Noise Degree (%)');
ylabel('SSIM');
title('SSIM for PCB Image 2');
legend('Location', 'best');
grid on;

% Plot PSNR
subplot(2, 2, 2);
plot(noise_degree, HS_PSNR, '-o', 'Color', 'b', 'LineWidth', 1.5, 'DisplayName', 'HS');
hold on;
plot(noise_degree, PRP_PSNR, '-s', 'Color', 'g', 'LineWidth', 1.5, 'DisplayName', 'PRP');
plot(noise_degree, DY_PSNR, '-^', 'Color', 'm', 'LineWidth', 1.5, 'DisplayName', 'DY');
plot(noise_degree, RMIL_PSNR, '-d', 'Color', 'r', 'LineWidth', 1.5, 'DisplayName', 'RMIL');
xlabel('Noise Degree (%)');
ylabel('PSNR (dB)');
title('PSNR for PCB Image 2');
legend('Location', 'best');
grid on;

% Plot RelErr
subplot(2, 2, 3);
plot(noise_degree, HS_RelErr, '-o', 'Color', 'b', 'LineWidth', 1.5, 'DisplayName', 'HS');
hold on;
plot(noise_degree, PRP_RelErr, '-s', 'Color', 'g', 'LineWidth', 1.5, 'DisplayName', 'PRP');
plot(noise_degree, DY_RelErr, '-^', 'Color', 'm', 'LineWidth', 1.5, 'DisplayName', 'DY');
plot(noise_degree, RMIL_RelErr, '-d', 'Color', 'r', 'LineWidth', 1.5, 'DisplayName', 'RMIL');
xlabel('Noise Degree (%)');
ylabel('Relative Error');
title('Relative Error for PCB Image 2');
legend('Location', 'best');
grid on;

% Plot Processing Time
subplot(2, 2, 4);
plot(noise_degree, HS_Time, '-o', 'Color', 'b', 'LineWidth', 1.5, 'DisplayName', 'HS');
hold on;
plot(noise_degree, PRP_Time, '-s', 'Color', 'g', 'LineWidth', 1.5, 'DisplayName', 'PRP');
plot(noise_degree, DY_Time, '-^', 'Color', 'm', 'LineWidth', 1.5, 'DisplayName', 'DY');
plot(noise_degree, RMIL_Time, '-d', 'Color', 'r', 'LineWidth', 1.5, 'DisplayName', 'RMIL');
xlabel('Noise Degree (%)');
ylabel('Processing Time (s)');
title('Processing Time to restore PCB Image 2');
legend('Location', 'best');
grid on;


% Adjust layout
sgtitle('Comparison of Metrics for Different Methods');