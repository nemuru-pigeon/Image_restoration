%% 处理数据
% 加载数据
data = load('img_restoration (1).mat');

% 参数设置
gaussian_size = 5;        % 高斯核大小
gaussian_sigma = 5;       % 高斯噪声标准差
motion_len = 20;          % 运动模糊长度
motion_theta = 60;        % 运动模糊角度

% 原始图像
I1 = data.I1;  
I2 = data.I2;
I1 = double(I1);          % 转换为 double 类型
I2 = double(I2);

% 创建运动模糊核
h_motion = fspecial('motion', motion_len, motion_theta);

% 应用运动模糊 
motion_I1 = imfilter(I1, h_motion, 'conv', 'same', 'circular'); % 只有运动模糊
motion_I2 = imfilter(I2, h_motion, 'conv', 'same', 'circular');

% 添加加性高斯噪声
noise_sigma = 5; % 设置噪声强度
noise_I1 = randn(size(motion_I1)) * noise_sigma;
noise_I2 = randn(size(motion_I2)) * noise_sigma;
noisy_motion_I1 = motion_I1 + noise_I1;  % 运动模糊+高斯噪声
noisy_motion_I2 = motion_I2 + noise_I2;

%% 维纳滤波
restore_img = wiener_filter(noisy_motion_I1, I1, noise_I1, h_motion);

% 显示结果
figure;
subplot(1, 3, 1); imshow(uint8(I1)); title('原始图像');
subplot(1, 3, 2); imshow(uint8(noisy_motion_I1)); title('退化图像');
subplot(1, 3, 3); imshow(uint8(restore_img)); title('维纳恢复图像');

%% 直接逆滤波
% 直接逆滤波存在很多问题，在某些特定角度没办法完成滤波会导致画面崩坏
inverse_filter(h_motion, motion_I1);
inverse_filter(h_motion, motion_I2);

%% 正则化逆滤波
regularized_inverse_filter(h_motion, motion_I1);
regularized_inverse_filter(h_motion, motion_I2);
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

function restore_img = inverse_filter(h_motion, motion_I1)
    % 非正则化逆滤波器
    % 有个问题是，当运动模糊为90度的时候，没办法处理

    [M, N] = size(motion_I1);   % 获取图像的尺寸
    H_motion = psf2otf(h_motion, [M, N]);   % 将 PSF (点扩散函数) 转换为 OTF (光学传递函数)
    fft_motion_I1 = fft2(motion_I1);    % 对退化图像进行傅里叶变换
    H_motion_conj = conj(H_motion);% 运动模糊核的复共轭
    restore_freq = (fft_motion_I1 .* H_motion_conj) ./ abs(H_motion).^2;  % 频域恢复
    restore_img = real(ifft2(restore_freq));    % 逆傅里叶变换回到空间域

    % 显示退化图像和恢复后的图像
    figure;
    subplot(1, 2, 1); imshow(uint8(motion_I1)); title('退化图像');
    subplot(1, 2, 2); imshow(uint8(restore_img)); title('直接逆滤波恢复图像');
end

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
