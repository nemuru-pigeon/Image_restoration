function restore_img = wiener_filter(noisy_motion_I1, I1, noise_I1, h_motion)
    % This function applies Wiener filtering to restore a noisy motion-blurred image.
    %
    % Inputs:
    %   noisy_motion_I1 - A 2D matrix (image) representing the motion-blurred image with additive noise.
    %   I1              - A 2D matrix (image) representing the original (clear) image.
    %   noise_I1        - A 2D matrix (image) representing the Gaussian noise present in the image.
    %   h_motion        - A 2D matrix (kernel) representing motion blur function
    %
    % Output:
    %   restore_img     - A 2D matrix (image) representing the restored image after applying 
    %                     Wiener filtering.

    [M, N] = size(I1);  % Get the size of the original image

    fft_H_motion = psf2otf(h_motion, [M, N]);  % Generate OTF for the motion blur kernel
    pow2_H_motion = abs(fft_H_motion).^2;  % Compute H^2

    noise_power_spectrum = abs(fft2(noise_I1, M, N)).^2;  % Compute noise power spectrum
    image_power_spectrum = abs(fft2(I1, M, N)).^2;  % Compute power spectrum of the original image

    nsr_spectrum = noise_power_spectrum ./ (image_power_spectrum);  % Compute noise-to-signal ratio

    H_w = conj(fft_H_motion) ./ (pow2_H_motion + nsr_spectrum);  % Compute Wiener filter

    fft_noisy_motion_I1 = fft2(noisy_motion_I1);  % Perform Fourier transform of the noisy image

    restore_img_fft = fft_noisy_motion_I1 .* H_w;  % Apply Wiener filter to restore image in frequency domain

    restore_img = ifft2(restore_img_fft);  % Perform inverse Fourier transform to recover the image

    restore_img = real(restore_img);  % Take the real part
    restore_img = max(0, min(255, restore_img));  % Clip pixel values to the range [0, 255]
end
