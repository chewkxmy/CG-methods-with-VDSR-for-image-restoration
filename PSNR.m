% Calculate the PSNR between the original and restored image
function psnr = PSNR(original, restored)
    %
    % Syntax: PSNR = compute_psnr(original, restored) in image_Restoration.m
    %
    % Inputs:
    %    original - Original image in double format
    %    restored - Restored image in double format
    %
    % Output:
    %    PSNR - Peak Signal-to-Noise Ratio (in decibels)
   
    original = im2double(original);
    [mx,nx]=size(restored);
    restored = im2double(restored);
    
    % Calculate the difference between the original and restored image
    D = original - restored;
    
    psnr = 10 * log10((255^2) / ((1/mx*nx)*norm(D,'fro')^2)); 
end