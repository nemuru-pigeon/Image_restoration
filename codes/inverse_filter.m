function restore_img = inverse_filter(h_motion, motion_I1, wpass)
    % This function performs inverse filtering to restore an image degraded by motion blur.
    % Note: May have limitations if motion blur angle is exactly 90 degrees.
    %
    % Inputs:
    %   h_motion    - A 2D matrix (kernel) representing motion blur.
    %   motion_I1   - A 2D matrix (image) representing the degraded motion-blurred image.
    %   wpass       - (Optional) A scalar value representing the cutoff frequency for low-pass filtering.
    %
    % Output:
    %   restore_img  - A 2D matrix (image) representing the restored image after applying inverse filtering.

    [M, N] = size(motion_I1);   % Get the size of the degraded image
    H_motion = psf2otf(h_motion, [M, N]);   % Convert PSF to OTF
    
    if nargin > 2
        H_motion = lowpass(H_motion, wpass);   % Apply low-pass filtering if specified
    end
    
    fft_motion_I1 = fft2(motion_I1);   % Compute Fourier transform of degraded image
    H_motion_conj = conj(H_motion);   % Compute conjugate of the motion blur kernel
    restore_freq = (fft_motion_I1 .* H_motion_conj) ./ abs(H_motion).^2;   % Frequency domain restoration
    restore_img = real(ifft2(restore_freq));   % Convert back to spatial domain
end
