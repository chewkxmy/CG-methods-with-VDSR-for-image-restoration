function ssim_value = ssim(X, XS)
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

    % Compute means, variances, and covariance
    mu_X = mean2(X);
    mu_XS = mean2(XS);

    sigma_X2 = var(X(:)); % Variance of X
    sigma_XS2 = var(XS(:)); % Variance of XS
    sigma_X_XS = cov(X(:), XS(:)); % Covariance
    sigma_X_XS = sigma_X_XS(1, 2); % Extract covariance value

    % Compute SSIM
    numerator = (2 * mu_X * mu_XS + C1) * (2 * sigma_X_XS + C2);
    denominator = (mu_X^2 + mu_XS^2 + C1) * (sigma_X2 + sigma_XS2 + C2);
    ssim_value = numerator / denominator;
end