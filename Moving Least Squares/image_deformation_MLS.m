%%Initialisation
clear;
alpha = 2;

%To view with puppy please
%image = imread('puppy.jpg');
image = imread('ginger.png');
[img_y,img_x,~] = size(image);
figure
imshow(image)
% [x,y] = getpts;
hold on;
n = 0;
while true
   [x, y, button] = ginput(2);
   if button == 51 % terminates if 3 is pressed twice
       break; 
   end
   n = n+1;
   p_x(n)= x(1)
   p_y(n) = y(1)
   plot(p_x(n),p_y(n),'bo')
   
   q_x(n)= x(2)
   q_y(n) = y(2)
   plot(q_x(n),q_y(n),'ro')
end
% load('p.mat');
% load('q.mat');
p = [p_x;p_y]; %2 x n size where n is the numberof points selected

q = [q_x;q_y]; %2 x n
disp(q)

% p = [2 4 6;1 2 3];
% q = [1 2 3;5 6 7];
for i=1:img_y
    for j=1:img_x
        %point v column wise
        v = [j,i];
        
        %calculate weight for each point
        euc = pdist2(v,p','euclidean');
        sq_euc= euc.^(2*alpha);
        w = 1./sq_euc;
        
        %Calcuate p* and q* weighted centroids
        pstar = sum(w.*p,2)/sum(w,2); % 2x1 : first row is for x, second for y
        qstar = sum(w.*q,2)/sum(w,2); % 2x1
        
        %Calculate p_hat and q_hat
        p_hat = p - pstar;
        q_hat = q - qstar;
        
        %% Affine Transform
          len = size(p_hat,2);
          B = zeros(2,2);
          for a=1:len
              b = w(a)*p_hat(:,a)';
              B = B + (p_hat(:,a)*b);
          end
          inv_B = inv(B);
          
          %calculating Aq
          for q_idx=1:len
             
              A(q_idx) = (v - pstar') * (inv_B * w(q_idx) * p_hat(:,q_idx)); %size of A:1xn
          end
          
          f_a = sum(A.*q_hat,2) + qstar;
          
          f_a_v(i,j,1)= f_a(1);
          f_a_v(i,j,2) = f_a(2);
          f_a_v = round(f_a_v);
          
          %% Similarity Transform
          
          for m=1:length(p')
              mu_s(m) = w(m)* p_hat(:,m)' * p_hat(:,m);
          end
          
          mu = sum(mu_s,2);
          
                    % (x,y) to (-y,x) in p_perp
          p_hat_perp = [(-p_hat(2,:));p_hat(1,:)];
          %p_hat_norm_perp = [p_hat;-(p_hat_perp)];%2 x 2n
          v_pstar= v - pstar';
          v_pstar_perp = [(-v_pstar(2)), v_pstar(1)];
          v_pstar_norm_perp_mat = [v_pstar;-(v_pstar_perp)]; %2x2
          
          %A matrix for similarity transform
          for p_idx=1:len
              
              A_s = w(p_idx) * [p_hat(:,p_idx)';-p_hat_perp(:,p_idx)'] * v_pstar_norm_perp_mat'; %size of A:1xn
              sim(p_idx,:) = q_hat(:,p_idx)' * (1/mu * A_s);
              rigid(p_idx,:) = q_hat(:,p_idx)' * A_s;
          end

          f_s = sum(sim,1) + qstar';
          
          f_s_v(i,j,1)= f_s(1);
          f_s_v(i,j,2) = f_s(2);
          f_s_v = round(f_s_v);
          
          %% Rigid Transformation
          %Use A_s from Similarity Transformation
          
          f_r_arrow= sum(rigid,1);
          
          f_r = (pdist2(v,pstar','euclidean') * (f_r_arrow / norm(f_r_arrow))) + qstar';
          
          f_r_v(i,j,1)= f_r(1);
          f_r_v(i,j,2) = f_r(2);
          f_r_v = round(f_r_v);
          
    end 
end
% x = 1:img_x;
% y=1:img_y;
% [X,Y] = meshgrid(x,y);
% % rows = length(y);
% % col = length(x);
% coord = [X(:),Y(:)];
% 

[affine_forw,sim_forward,rigid_forward] = visualise_results(p,q,img_y,img_x,f_a_v,f_s_v,f_r_v,image);

% %% Backwards warping
% 
