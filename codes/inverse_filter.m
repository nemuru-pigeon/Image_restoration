function restore_img = inverse_filter(h_motion, motion_I1, wpass)
    % 非正则化逆滤波器
    % 有个问题是，当运动模糊为90度的时候，没办法处理

    [M, N] = size(motion_I1);   % 获取图像的尺寸
    H_motion = psf2otf(h_motion, [M, N]);   % 将 PSF (点扩散函数) 转换为 OTF (光学传递函数)
    if nargin > 2
        H_motion = lowpass(H_motion, wpass);
    end
    fft_motion_I1 = fft2(motion_I1);    % 对退化图像进行傅里叶变换
    H_motion_conj = conj(H_motion);% 运动模糊核的复共轭
    restore_freq = (fft_motion_I1 .* H_motion_conj) ./ abs(H_motion).^2;  % 频域恢复
    restore_img = real(ifft2(restore_freq));    % 逆傅里叶变换回到空间域

end