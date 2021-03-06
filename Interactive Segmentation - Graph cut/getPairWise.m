function pairWise = getPairWise(I)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get pairwise terms for each pairs of pixels on image I and for
% regularizer lambda.
% 
% INPUT :
% - I      : color image
% 
% OUTPUT :
% - pairwise : sparse square matrix containing the pairwise costs for image
%              I and parameter lambda
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sigma = 5;
[img_y,img_x,~] = size(I);

%total number of pixels
N = img_y * img_x;

%total number of connections betweens edges
%From corners: only 3 connections per corner
corners = 4;
corner_conn = corners * 3;
boundary = 2*(img_y-2) + 2*(img_x-2) + corners;

%connections from edges(not taking corners into consideration) = 5 per
%pixel at edge
edge_conn = (2*(img_y-2) + 2*(img_x-2)) * 5;

%connections from interior(not edges or corners) = Neighbourhood of 8
interior_conn = (N - boundary) * 8;

total_conn = corner_conn + edge_conn + interior_conn;

index=1;
%for each p, see neighbourhood - q(around it - 8 neighbourhood)
for p = 1:N
    %neighbourhood q
    [p_x,p_y] = ind2sub([img_y img_x],p);
    q = [p_x-1 p_y-1;p_x-1 p_y;p_x-1 p_y+1;p_x p_y-1;p_x p_y+1;p_x+1 p_y-1;p_x+1 p_y;p_x+1 p_y+1];
    q = q(q(:,1)>0 & q(:,2)>0 & q(:,1)<=img_y & q(:,2)<=img_x,:);
    q = sub2ind([img_y img_x],q(:,1),q(:,2));
    
    
    i(index:index+length(q)-1,1)= p*ones(length(q),1);
    j(index:index+length(q)-1,1)= q;
    %ad-hoc function for boundary penalties
    %Intensities for each channel
    R_img = double(I(:,:,1));
    G_img = double(I(:,:,2));
    B_img = double(I(:,:,3));

    Ip = [R_img(p) G_img(p) B_img(p)];
    Iq = [R_img(q) G_img(q) B_img(q)];
    [q_x,q_y] = ind2sub([img_y img_x],q);

    Ip_Iq = pdist2(Ip,Iq);
    sq_Ip_Iq = (Ip_Iq).^2;
    Bpq = exp(- sq_Ip_Iq /(2 * sigma^2))./pdist2([p_x, p_y], [q_x, q_y]);

    v(index:index+length(q)-1,1) = Bpq';
    index = index + length(q);
end    
sparse = zeros(length(i),1);
pairWise = [i,j,sparse,v,sparse,sparse];
%     q = [p-img_x-1;p-img_x;p-img_x+1;p-1;p+1;p+img_x-1;p+img_x;p+img_x+1];
%     q = q(mod(p-img_x-1,img_x);
end