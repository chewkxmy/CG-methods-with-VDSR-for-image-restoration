% IMAGE RESTORATION
clc;
clear all;

% Define global variables used in optimization
global alpha X N m n LN NhMat

%------------------------OPTIMIZATION PARAMETERS----------------------------
delta = 0.0001;                % Step size for iterations
MaxIter = 10000;               % Maximum number of iterations
Tolerance = (10)^(-6);         % Convergence criterion
LambdaInitial = 1;             % Initial lambda value for blending
CRestart = (10)^(-10);         % Restart criterion
ro = 0.95;                     % Line search parameter
minimumofalpha = (10)^(-10);   % Minimum step size for alpha
maxiterLS = 1000;              % Maximum iterations for line search
%--------------------------------------------------------------------------

% Initial global variables
alpha = 1;
%--------------------------------------------------------------------------

%------------------------ IMAGE AND NOISE SETUP ----------------------------
% Input image filename
imname = ['PCB image2.jpg'];   

% Type and degree of noise to add
noise = 'salt & pepper';       
noise_degree = 0.30;  

fname = 'gAlpha';
dfname = 'NablagAlpha';

% Read the original image
X = imread(imname); 

% Add noise to the image
Xp = imnoise(X, noise, noise_degree);

% Display the noisy image
figure;
imshow(Xp);
title('Noisy Image');

X = im2double(X);     
XS = X;               % Save the original image for comparison
Xp = im2double(Xp);   

% Image dimensions
[m, n] = size(X);     

% Find noisy pixels
[row, col, v] = find(X - Xp);

% Number of noisy pixels
LN = length(row);     

% Initialize neighborhood data structure and initial estimates
N = zeros(LN, 3);     
uInitial = zeros(LN, 1);

dimnum = LN;

% Fill neighborhood matrix `N` and initial guess `uInitial`
for k = 1:LN
    N(k, 1) = row(k);                     % Row of noisy pixel
    N(k, 2) = col(k);                     % Column of noisy pixel
    N(k, 3) = Xp(row(k), col(k));         % Value of noisy pixel in the noisy image
    
    % Linear blending between noisy and original pixel value
    uInitial(k) = LambdaInitial * X(row(k), col(k)) + (1 - LambdaInitial) * Xp(row(k), col(k));
end

% Extract neighborhoods for noisy pixels
NhMat = ExtractNeighborhoods(N, X);  % External function placeholder
%--------------------------------------------------------------------------

%------------------------ OPTIMIZATION ALGORITHM --------------------------
    % Start timing the optimization process
    t0 = tic;
    
    % Call optimization function
    [uopt, galphaopt, gradientopt, NI, Nf] = RMIL(fname, dfname, uInitial, ...
        Tolerance, CRestart, MaxIter, delta, ro, minimumofalpha, maxiterLS);
    
    % Record elapsed time
    Time = toc(t0);
    
    % Update noisy pixels in the image with optimized values
    for k = 1:LN
        X(N(k, 1), N(k, 2)) = uopt(k);
    end
%--------------------------------------------------------------------------

%------------------------ DISPLAY RESTORED IMAGE ---------------------------
% Convert restored image back to uint8 format
X = im2uint8(X);

% Display the restored image
figure;
imshow(X);
title('Restored Image');

[mx,nx]=size(X);
X = im2double(X);
    
% Calculate the difference between the original and restored image
D = XS-X;

relerr = 100 *(norm(D) / norm(XS,'fro')) ;    
psnr = 10 * log10((255^2) / ((1/mx*nx)*norm(D,'fro')^2));

% Display the computed metrics
fprintf('Processing Time: %.4f\n', Time);
fprintf('Relative Error: %.4f\n', relerr);
fprintf('PSNR: %.4f\n', psnr);
%--------------------------------------------------------------------------