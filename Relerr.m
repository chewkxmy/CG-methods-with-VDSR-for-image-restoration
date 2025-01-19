% Calculate the relative error between the original and restored image
function relerr = Relerr(original, restored)
    %
    % Syntax: Relerr = compute_relerr(XS, X) in image_Restoration.m
    %
    % Inputs:
    %    orginal - Original image in double format
    %    restored- Restored image in double format
    %
    % Output:
    %    relerr - Relative error (percentage)

    restored = im2double(restored);

    % Calculate the difference between the original and restored image
    D = original - restored;
    
    % Compute the relative error
    relerr = 100 *(norm(D,'fro') / norm(original,'fro')) ;


end