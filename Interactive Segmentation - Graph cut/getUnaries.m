function unaries = getUnaries(I,lambda,hist_fg,hist_bg, seed_fg, seed_bg)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get Unaries for all pixels in inputImg, using the foreground and
% background color histograms, and enforcing hard constraints on pixels
% marked by the user as foreground and background
% 
% INPUT :
% - I       : color image
% - Lamda   : regularization parameter
% - hist_fg : foreground color histogram
% - hist_bg : background color histogram
% - seed_fg : pixels marked as foreground by the user
% - seed_bg : pixels marked as background by the user
% 
% OUTPUT :
% - unaries : Nx2 matrix containing the unary cost for every pixels in I
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%initialisation
%Focusing only on t-links here
K =inf;

%N is the number of pixels in image
[img_y,img_x,~] = size(I);
N = img_y * img_x;

unaries = zeros(N,2);

%% for {p,S} where S is the object/foreground terminal
%Now get only seed pixel for object: first get positions of the pixels
seed_y_fg = seed_fg(:,2);
seed_x_fg = seed_fg(:,1);

% seeds for background
seed_y_bg = seed_bg(:,2);
seed_x_bg = seed_bg(:,1);

% flatten indices of image into number of pixels: N numbers
obj_seed_index = sub2ind([img_y img_x],seed_y_fg,seed_x_fg);

% flatten indices of image into number of pixels: N numbers
bg_seed_index = sub2ind([img_y img_x],seed_y_bg,seed_x_bg);

for obj=1:length(obj_seed_index)
    unaries(obj_seed_index(obj),1) = 0;%connected to background(sink)
    unaries(obj_seed_index(obj),2) = K; %connected to fg(object)
end

% for those pixels not connected to obj or bg
connected = [bg_seed_index;obj_seed_index];
range_N = 1:1:N;
not_connected_index = setdiff(range_N,connected)';

    
% need histograms for the calculation of Rp -> hence take each color
% channel
R_img = I(:,:,1);
G_img = I(:,:,2);
B_img = I(:,:,3);

%take hist_fg(as object/foreground terminal - {p,S})

for nc=1:length(not_connected_index)
    
    bins_red = floor(double(R_img(not_connected_index(nc)))/(256/32)) + 1;
    bins_green = floor(double(G_img(not_connected_index(nc)))/(256/32)) + 1;
    bins_blue = floor(double(B_img(not_connected_index(nc)))/(256/32)) + 1;
    
    %hist_bg(bins_red,bins_green,bins_blue) = hist_bg(bins_red,bins_green,bins_blue)+ (10^-10);
    
    Rp_bg = -log(hist_bg(bins_red,bins_green,bins_blue)+ 1e-10);
    
    %connected to object terminal
    unaries(not_connected_index(nc),2) = lambda * Rp_bg;
    
end
%% for {p,T} where T is the background terminal

for bg=1:length(bg_seed_index)
    unaries(bg_seed_index(bg),1) = K;%connected to background(sink)
    unaries(bg_seed_index(bg),2) = 0; %connected to fg(object)
end

for nc_bg=1:length(not_connected_index)
    
    bins_red = floor(double(R_img(not_connected_index(nc_bg)))/(256/32)) + 1;
    bins_green = floor(double(G_img(not_connected_index(nc_bg)))/(256/32)) + 1;
    bins_blue = floor(double(B_img(not_connected_index(nc_bg)))/(256/32)) + 1;
    
    %hist_fg(bins_red,bins_green,bins_blue) = hist_fg(bins_red,bins_green,bins_blue)+ (10^-10);
    
    Rp_fg = -log(hist_fg(bins_red,bins_green,bins_blue) + 1e-10);
    
    %connected to object terminal
    unaries(not_connected_index(nc_bg),1) = lambda * Rp_fg;
    
end
