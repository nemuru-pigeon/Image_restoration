function convolved_img = BUPT_lowpass(img,sigma)
% sigma is the standard deviation of gaussian distribution

    img = double(img);
    [row,column] = size(img);
    Z = zeros(row,column);
    convolved_img = zeros(row,column);
    
    % generate gaussian filter
    difference = round(3*sigma);
    window = difference * 2 + 1;
    center = difference + 1;
    gaussian = zeros(1, window);
    for i=1:window
    	gaussian(i) = exp(-(i-center)^2 / 2*sigma^2);
    end
    gaussian_2D = gaussian' * gaussian;
    S = sum(sum(gaussian_2D));
    gaussian = gaussian / sqrt(S); % Normalised seperate filter
    
    % mirror the borders
    img_extended = img;
    for i=1:(difference)
        img_extended = [img(:,1+i), img_extended, img(:,column-i)];
    end
    
    % first calculate the convolution of rows
    for i=1:row
        for j=(1+difference):(column+difference)
            Z(i,j-difference) = sum(img_extended(i,(j-difference):(j+difference)) .* gaussian);
        end
    end
    
    % mirror the borders
    img_extended = Z;
    for i=1:(difference)
        img_extended = [Z(1+i,:); img_extended; Z(row-i,:)];
    end
    
    % first calculate the convolution of rows
    for j=1:column
        for i=(1+difference):(row+difference)
            convolved_img(i-difference,j) = sum(img_extended((i-difference):(i+difference),j) .* gaussian');
        end
    end
    
    convolved_img = uint8(convolved_img);
end