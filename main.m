%%Author: Zarreen Naowal Reza
%%Email: zarreen.naowal.reza@gmail.com

            rgb = imread('input.jpg'); 
             rgb = imresize(rgb,[512,512]);
             rgb = imadjust(rgb,stretchlim(rgb));
             %figure, imshow(rgb);title('Contrast Enhanced');

%--------------------image threshoiding-------------------------------
            hsv = rgb2hsv(rgb);
           % hsv =histeq(hsv);
            h = hsv(:, :, 1); % Hue image.cx
            s = hsv(:, :, 2); % Saturation image.
            v = hsv(:, :, 3); % Value (intensity) image.
           % imshow(hsv);
            %     i = medfilt2(s);
            %subplot(1,3,2);imshow(h);title('h');
            %subplot(1,3,3); imshow(s);title('s');
            %subplot(1,3,1);imshow(v);title('v');


           threshold =  max(s(:)) .* 0.0999;
            %threshold =    0.03;

            mask = s > threshold  ;
            %imshow(mask);

            Inew = h.*mask;

            threshold =   0.5;
            mask2 = (Inew > threshold);

%--------------------morphological analysis-------------------------------     
            a = strel('square',2); 
            %a=[1 1 1; 1 1 1 ; 1 1 1];
            erodedBW=imdilate(mask2,a);
            se = strel('rectangle',[2 1]);        
            mask2= imerode(erodedBW,se);
            %imshow(mask2);

%--------------------blob detection-------------------------------
            mask2 = ExtractNLargestBlobs(mask2, 1);

%--------------------converting image back to rbg-------------------------------
            Inew2 = h.*mask2;
            Inew3 = s.*mask2;
            Inew4 = v.*mask2;

            f3 = Inew2 & Inew3 & Inew4;

            %imshow(f3);

            maskrgb = zeros(size(f3)); % Initialize
            maskrgb(:,:,1) = hsv(:,:,1) .* f3;
            maskrgb(:,:,2) = hsv(:,:,2) .* f3;
            maskrgb(:,:,3) = hsv(:,:,3) .* f3;
 
             Inew5 = hsv2rgb(maskrgb);
            %imshow(Inew5);

%--------------------again morphological analysis (optional)------------------------------- 
            a=strel('square',2);
            f4=imdilate(Inew5,a);
            se = strel('rectangle',[2 1]);        
            erodedBW2 = imerode(f4,se);
            seg_img = erodedBW2;
             imshow(rgb), figure, imshow(erodedBW2);

           %-------------------Use This For Saving Extracted Image---------------------------
            imwrite(erodedBW2,'C:\xampp\htdocs\upload\downloads\output.jpg'); 

%---------------------------------------------feature extraction--------------------------------------
            if ndims(seg_img) == 3
               img = rgb2gray(seg_img);
            end

%----------------------- Create the Gray Level Cooccurance Matrices (GLCMs)------------------------
            glcms = graycomatrix(img);
    
            % Derive Statistics from GLCM
            stats = graycoprops(glcms,'Contrast Correlation Energy Homogeneity');
            Contrast = stats.Contrast;
            Correlation = stats.Correlation;
            Energy = stats.Energy;
            Homogeneity = stats.Homogeneity;
            Mean = mean2(seg_img);
            Standard_Deviation = std2(seg_img);
            Entropy = entropy(seg_img);
            RMS = mean2(rms(seg_img));
            Variance = mean2(var(double(seg_img)));
            a = sum(double(seg_img(:)));
            Smoothness = 1-(1/(1+a));
            Kurtosis = kurtosis(double(seg_img(:)));
            Skewness = skewness(double(seg_img(:)));
            % Inverse Difference Movement
            m = size(seg_img,1);
            n = size(seg_img,2);
            in_diff = 0;
            for i = 1:m
                for j = 1:n
                    temp = seg_img(i,j)./(1+(i-j).^2);
                    in_diff = in_diff+temp;
                end
            end
            IDM = double(in_diff);
%----------------------save extracted features in an array--------------------------------------------------    
            feat_disease = [Contrast,Correlation,Energy,Homogeneity, Mean, Standard_Deviation, Entropy, RMS, Variance, Smoothness, Kurtosis, Skewness, IDM];
           disp(feat_disease);