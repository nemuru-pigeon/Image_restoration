function restore_img = regularized_inverse_filter(h_motion, motion_I1)
    % 正则化逆滤波函数
    % 注意可以调整lambda

    [M, N] = size(motion_I1);               % 获取图像的尺寸
    H_motion = psf2otf(h_motion, [M, N]);   % 将 PSF (点扩散函数) 转换为 OTF (光学传递函数)
    fft_motion_I1 = fft2(motion_I1);        % 对退化图像进行傅里叶变换
    H_motion_conj = conj(H_motion);         % 运动模糊核的复共轭
    lambda = 0.01;                          % 正则化参数 lambda,  可以根据需要调整这个参数
    restore_freq = (fft_motion_I1 .* H_motion_conj) ./ (abs(H_motion).^2 + lambda); % 正则化逆滤波计算
    restore_img = real(ifft2(restore_freq));  % 逆傅里叶变换回到空间域
    
    % 显示退化图像和恢复后的图像
    figure;
    subplot(1, 2, 1); imshow(uint8(motion_I1)); title('退化图像');
    subplot(1, 2, 2); imshow(uint8(restore_img)); title('正则化逆滤波恢复图像');
end