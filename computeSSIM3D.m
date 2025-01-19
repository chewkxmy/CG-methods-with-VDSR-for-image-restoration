function ssim_value = computeSSIM3D(restored_image, reference_image)
    % Compute SSIM for 3D images (e.g., color images)
    %
    % Inputs:
    %    restored_image - Restored 3D image (double format)
    %    reference_image - Reference 3D image (double format)
    %
    % Output:
    %    ssim_value - Structural Similarity Index (average across channels)
    
    % Check if input images have the same size
    if size(restored_image) ~= size(reference_image)
        error('Images must have the same dimensions.');
    end
    
    % Convert images to double if not already
    restored_image = im2double(restored_image);
    reference_image = im2double(reference_image);
    
    % Constants for SSIM computation
    C1 = (0.01 * 255)^2; % L = 255 (assuming 8-bit images)
    C2 = (0.03 * 255)^2;
    
    % Initialize SSIM for each channel
    [m, n, d] = size(restored_image);
    ssim_channels = zeros(1, d);
    
    % Loop through each channel (R, G, B for 3D images)
    for channel = 1:d
        % Extract channel data
        restored = restored_image(:, :, channel);
        reference = reference_image(:, :, channel);
        
        % Compute means
        mu_x = mean2(restored);
        mu_y = mean2(reference);
        
        % Compute variances and covariance
        sigma_x2 = var(restored(:)); % Variance of restored channel
        sigma_y2 = var(reference(:)); % Variance of reference channel
        sigma_xy = mean2((restored - mu_x) .* (reference - mu_y)); % Covariance
        
        % Compute SSIM for the channel
        numerator = (2 * mu_x * mu_y + C1) * (2 * sigma_xy + C2);
        denominator = (mu_x^2 + mu_y^2 + C1) * (sigma_x2 + sigma_y2 + C2);
        ssim_channels(channel) = numerator / denominator;
    end
    
    % Average SSIM across channels
    ssim_value = mean(ssim_channels);
end