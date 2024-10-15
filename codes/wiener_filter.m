function restore_img = wiener_filter(noisy_motion_I1, I1, noise_I1, h_motion)
    % 获取图像的尺寸
    [M, N] = size(I1);

    % 使用 psf2otf 生成运动模糊核的 OTF（光学传递函数）
    fft_H_motion = psf2otf(h_motion, [M, N]);  % 使用 psf2otf 而不是 fft2
    pow2_H_motion = abs(fft_H_motion).^2;  % H^2

    % 计算噪声功率谱和图像功率谱
    noise_power_spectrum = abs(fft2(noise_I1, M, N)).^2;  % 噪声功率谱
    image_power_spectrum = abs(fft2(I1, M, N)).^2;        % 原始图像的功率谱

    % 计算 NSR (噪声与信号比率)
    nsr_spectrum = noise_power_spectrum ./ (image_power_spectrum);

    % 计算维纳滤波器
    H_w = conj(fft_H_motion) ./ (pow2_H_motion + nsr_spectrum);

    % 对退化图像进行傅里叶变换
    fft_noisy_motion_I1 = fft2(noisy_motion_I1);

    % 使用维纳滤波器恢复图像
    restore_img_fft = fft_noisy_motion_I1 .* H_w;

    % 进行傅里叶逆变换，恢复图像
    restore_img = ifft2(restore_img_fft);

    % 取实部，并限制像素值范围
    restore_img = real(restore_img);  % 取实部
    restore_img = max(0, min(255, restore_img));  % 限制像素值在 0 到 255 之间
    
end