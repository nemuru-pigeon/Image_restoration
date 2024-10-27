function frequency = to_frequency(origin)
% 生成频谱图
% origin 原图 double [0, 1]
    origin = origin * 255;
    frequency = fft2(origin); % 快速傅里叶变换生成频谱图
    frequency = fftshift(frequency); % 将零频分量移到频谱中心
    frequency = abs(frequency); % 取模
    frequency = log(frequency + 1); % 使用对数分度
end