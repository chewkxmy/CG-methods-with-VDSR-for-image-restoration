% Example data for the methods and metrics
noise_degree = [30, 50, 80];
HS_SSIM = [0.9349, 0.8653, 0.6303];
PRP_SSIM = [0.9363, 0.8664, 0.6375];
DY_SSIM = [0.9342, 0.8649, 0.6408];
RMIL_SSIM = [0.9367, 0.8670, 0.6781];

HS_PSNR = [16.1154, 13.1087, 8.8521];
PRP_PSNR = [16.2085, 13.1472, 8.9600];
DY_PSNR = [16.0701, 13.0904, 9.0110];
RMIL_PSNR = [16.2182, 13.1578, 9.6040];

HS_RelErr = [9.6699, 13.6695, 22.3142];
PRP_RelErr = [9.5668, 13.6091, 22.0390];
DY_RelErr = [9.7204, 13.6983, 21.9099];
RMIL_RelErr = [9.5561, 13.5925, 20.4639];

HS_Time = [39.7275, 57.8115, 301.2051];
PRP_Time = [46.1584, 61.3370, 297.9027];
DY_Time = [71.8770, 132.3636, 154.4097];
RMIL_Time = [35.0379, 76.4280, 119.2304];

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
title('SSIM for PCB Image 1');
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
title('PSNR for PCB Image 1');
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
title('Relative Error for PCB Image 1');
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
title('Processing Time to restore PCB Image 1');
legend('Location', 'best');
grid on;


% Adjust layout
sgtitle('Comparison of Metrics for Different Methods');