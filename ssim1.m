function ssim_value = ssim1(X, XS)
    % SSIM: Compute the Structural Similarity Index between two images
    %
    % Inputs:
    %   X  - Restored image (grayscale, double format, range [0, 1]).
    %   XS - Original (reference) image (grayscale, double format, range [0, 1]).
    %
    % Output:
    %   ssim_value - Structural Similarity Index (scalar between -1 and 1).
    
    % Constants for numerical stability (default values in SSIM)
    K1 = 0.01; % Constant for luminance
    K2 = 0.03; % Constant for contrast
    L = 1;     % Dynamic range of pixel values (1 for normalized images)
    
    % Compute constants C1 and C2
    C1 = (K1 * L)^2;
    C2 = (K2 * L)^2;

    % Work in floating-point precision
    X = double(X);
    XS = double(XS);

    % Image dimensions
    [m, n] = size(X);
    
    % Define Gaussian filter for local computation (11x11 window)
    h = fspecial('gaussian', [11 11], 1.5);  % 11x11 window, sigma=1.5
    
    % Compute local means (using Gaussian filter)
    mu_X = imfilter(X, h, 'symmetric');
    mu_XS = imfilter(XS, h, 'symmetric');
    
    % Compute local variances
    sigma_X2 = imfilter(X.^2, h, 'symmetric') - mu_X.^2;
    sigma_XS2 = imfilter(XS.^2, h, 'symmetric') - mu_XS.^2;
    
    % Compute local covariance
    sigma_X_XS = imfilter(X .* XS, h, 'symmetric') - mu_X .* mu_XS;
    
    % Compute SSIM map
    numerator = (2 * mu_X .* mu_XS + C1) .* (2 * sigma_X_XS + C2);
    denominator = (mu_X.^2 + mu_XS.^2 + C1) .* (sigma_X2 + sigma_XS2 + C2);
    map = numerator ./ denominator;
    
    % Compute the mean of SSIM map (final SSIM value)
    ssim_value = mean(map(:));
end