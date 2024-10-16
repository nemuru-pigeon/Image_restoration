function [corrupted_img, MSE, PSNR] = BUPT_noise(img,type,sigma)
% type : 1 for salt & pepper; 2 for gaussian
% sigma : the parameter of gaussian noise

    [row,column]=size(img);
    if type == 1
        corrupted_img = imnoise(img,'salt & pepper'); % add salt & pepper noise
    else
        corrupted_img = imnoise(img,'gaussian',0,sigma); % add gaussian noise,the standard deviation of the noise is sigma
    end
    
    % iterate to find the sum of squared errors
    sum = 0;
    for i=1:row
        for j=1:column
            sum = sum + (double(img(i,j))-double(corrupted_img(i,j)))^2;
        end
    end
    MSE = sum / (row*column); % calculate the MSE
    PSNR = 10 * log10(255^2/MSE); % calculate the PSNR
end