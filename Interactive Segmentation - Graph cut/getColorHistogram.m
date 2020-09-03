function hist = getColorHistogram(I,seed, histRes)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute a color histograms based on selected points from an image
% 
% INPUT
% - I       : color image
% - seed    : Nx2 matrix containing the the position of pixels which will be
%             uset to compute the color histogram
% - histRes : resolution of the histogram
% 
% OUTPUT
% - hist : color histogram
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%get different color channel images
R_img = I(:,:,1);
G_img = I(:,:,2);
B_img = I(:,:,3);

%Initialisation
seed_red = zeros(length(seed),1);
seed_green = zeros(length(seed),1);
seed_blue = zeros(length(seed),1);
hist =zeros([histRes histRes histRes]);
    
%Now get only seed pixel: first get positions of the pixels, then get
%intensities for each channel
seed_y = seed(:,2);
seed_x = seed(:,1);

for i = 1:length(seed_y)
    seed_red(i) = R_img(seed_y(i),seed_x(i));
    seed_green(i) = G_img(seed_y(i),seed_x(i));
    seed_blue(i) = B_img(seed_y(i),seed_x(i));
    
    bins_red = floor(seed_red(i)/(256/histRes)) + 1;
    bins_green = floor(seed_green(i)/(256/histRes)) + 1;
    bins_blue = floor(seed_blue(i)/(256/histRes)) + 1;
    
    hist(bins_red,bins_green,bins_blue)=hist(bins_red,bins_green,bins_blue)+1;
end


%smooth histogram using smooth3
hist = smooth3(hist, 'gaussian',[7 7 7]);

%normalise histogram
%L2 normalisation
%hist = normc(hist);
%L1 norm
H = hist(:);
hist = hist./sum(H);
end