function [iter,T_x,T_y,inliers_lb,inliers_ub,inlier_indices,outlier_indices] = runScript

%% Initialisation
Points = importdata('data/ListInputPoints.mat');

i_left = imread('data/InputLeftImage.png');
i_right = imread('data/InputRightImage.png');
inlier_threshold = 3;

[img_y,img_x,dim] = size(i_left); 

n = length(Points);
given_bounds = make_struct([-img_x,-img_y],[img_x,img_y],[],[],[]);

[x0,P0] = LP_solver(Points,given_bounds,inlier_threshold, n);
%P0 gives the Tx,Ty,upper bound and lower bound for inliers

%After getting upper and lower bound for number of inliers, we start branch
%and bound

%% Branch and Bound
%initialising opt (upper and lower bound for inliers)
opt_inliers = [-inf, inf];

struct_list = [P0];
flag= 0;

iter=0;
while(flag==0 || length(struct_list)>0) 
    %choose best candidate from struct_list 
    iter=iter+1;
    list_length = length(struct_list);
    candidate = struct_list(list_length);
    struct_list(length(struct_list)) = [];

    aTable = struct2table(struct_list);
    disp(aTable)
    %if the upper bound of inliers is less than m*(least lower bound) --
    %removed and skipped
    if candidate.ObjUpperBound < opt_inliers(1)
        continue;
    end
       
    
    if candidate.ObjLowerBound >= opt_inliers(1) && candidate.ObjUpperBound < opt_inliers(2)
        opt_inliers = [candidate.ObjLowerBound , candidate.ObjUpperBound];
        opt_ThetaBounds = [candidate.ThetaLowerBound, candidate.ThetaUpperBound];
        opt_ThetaOpt  = [candidate.ThetaOptimizer(1), candidate.ThetaOptimizer(2)];
        [opt_x,~] = LP_solver(Points,candidate,inlier_threshold,n);
    end
    
    
    if candidate.ObjUpperBound - candidate.ObjLowerBound <= 1
        flag=1;
    end
    Evolution_lb(iter,1) = opt_inliers(1);
    Evolution_ub(iter,1) = opt_inliers(2);
    
    %Split candidate into children and put in struct_list. Splitting done
    %along the longest dimension
    
    x_dim = candidate.ThetaUpperBound(1) - candidate.ThetaLowerBound(1);
    y_dim = candidate.ThetaUpperBound(2) - candidate.ThetaLowerBound(2); %2*opt_ThetaBounds(4);
    
    if x_dim<y_dim
 
        %First child split along y_dimension
        ThetaLB1 = [candidate.ThetaLowerBound(1),candidate.ThetaLowerBound(2)];
        ThetaUB1 = [candidate.ThetaUpperBound(1), floor((candidate.ThetaLowerBound(2) + candidate.ThetaUpperBound(2))/2)];%[img_x, floor(opt_ThetaBounds(2) + y_dim/2)];
        child1 = make_struct(ThetaLB1,ThetaUB1,[],[],[]);
        
        %Second child split along y_dimension
        ThetaLB2 = [candidate.ThetaLowerBound(1),ceil((candidate.ThetaLowerBound(2) + candidate.ThetaUpperBound(2))/2)];%[-img_x,ceil(opt_ThetaBounds(2) + y_dim/2)];
        ThetaUB2 = [candidate.ThetaUpperBound(1),candidate.ThetaUpperBound(2)];
        child2 = make_struct(ThetaLB2,ThetaUB2,[],[],[]);
        
    else
        
        %First child split along x_dimension
        ThetaLB1 = [candidate.ThetaLowerBound(1),candidate.ThetaLowerBound(2)];
        ThetaUB1 = [floor((candidate.ThetaLowerBound(1) + candidate.ThetaUpperBound(1))/2), candidate.ThetaUpperBound(2)];% [(floor(opt_ThetaBounds(1) + x_dim/2)), img_y];
        child1 = make_struct(ThetaLB1,ThetaUB1,[],[],[]);
        
        %Second child split along x_dimension
        ThetaLB2 = [ceil((candidate.ThetaLowerBound(1) + candidate.ThetaUpperBound(1))/2), candidate.ThetaLowerBound(2)];%[ceil(opt_ThetaBounds(1) + x_dim/2),-img_y];
        ThetaUB2 = [candidate.ThetaUpperBound(1), candidate.ThetaUpperBound(2)];
        child2 = make_struct(ThetaLB2,ThetaUB2,[],[],[]);
    end
    
    %using LP to find the best candidate that gives the best number of
    %inliers
    
    [x_child1,P_child1] = LP_solver(Points,child1,inlier_threshold, n);
    [x_child2,P_child2] = LP_solver(Points,child2,inlier_threshold, n);
    
    %Now choose best candidate from both and then add to list with second
    %best in first position and best candidate in the last position of the
    %stack
    
    if P_child1.ObjLowerBound > P_child2.ObjLowerBound && P_child1.ObjUpperBound > P_child2.ObjUpperBound
        best_candidate = P_child1;
        second_best = P_child2;
    elseif P_child2.ObjLowerBound > P_child1.ObjLowerBound && P_child2.ObjUpperBound > P_child1.ObjUpperBound
        best_candidate = P_child2;
        second_best  = P_child1; 
    else
        best_candidate = P_child1;
        second_best = P_child2;
    end

    
    struct_list = [struct_list,second_best,best_candidate];
    
     
end

T_x = opt_ThetaOpt(1);
T_y = opt_ThetaOpt(2);
inliers_lb = opt_inliers(1);
inliers_ub = opt_inliers(2);
opt_x = opt_x;

%% Inliers from optimal solution
%checking the optimal solution to get inliers and outliers
thresh = (abs(Points(:,1) + T_x - Points(:,3)) <= inlier_threshold) & (abs(Points(:,2) + T_y - Points(:,4)) <= inlier_threshold);

% also can be checked with opt_x
% inliers = opt_x(3:n+2);
% 
% if any(inliers)
%     index_inl = find(inliers >0.5);
%     index_outl = find(inliers <= 0.5);
% end

inlier_indices = find(thresh);
outlier_indices = find(thresh==0);

%% Inlier and Outlier correspondence on the left and right images
inlier_pts_left = Points(inlier_indices,1:2);
inlier_pts_rt = Points(inlier_indices,3:4);

outlier_pts_left = Points(outlier_indices,1:2);
outlier_pts_rt = Points(outlier_indices,3:4);
figure(1)

i_left = imread('data/InputLeftImage.png');
i_right = imread('data/InputRightImage.png');

showMatchedFeatures(i_left,i_right,Points(:,1:2),Points(:,3:4),'montage','PlotOptions',{'b.','b.','b-'})
title('All corresponding points');

figure(2)
% showMatchedFeatures(i_left,i_right,inlier_pts_left,inlier_pts_rt,'montage','PlotOptions',{'g.','g.','g-'},outlier_pts_left,outlier_pts_rt,'montage','PlotOptions',{'r.','r.','r-'})
% hold on;
% % showMatchedFeatures(i_left,i_right,outlier_pts_left,outlier_pts_rt,'montage','PlotOptions',{'r.','r.','r-'})
% % hold off;
Jointimg = cat(2, i_left, i_right); % Places the two images side by side
imshow(Jointimg);
width = size(i_left, 2);
hold on;
num_inliers = length(inlier_pts_left);
num_outliers = length(outlier_pts_left);
for i = 1 : num_inliers
    plot(inlier_pts_left(i, 1), inlier_pts_left(i, 2), 'g.', inlier_pts_rt(i, 1) + width,inlier_pts_rt(i, 2), 'g.');
    line([inlier_pts_left(i, 1) inlier_pts_rt(i, 1) + width], [inlier_pts_left(i, 2) inlier_pts_rt(i, 2)],'Color', 'green');
end
hold on;
for i = 1:num_outliers
    plot(outlier_pts_left(i, 1), outlier_pts_left(i, 2), 'r.', outlier_pts_rt(i, 1) + width,outlier_pts_rt(i, 2), 'r.');
    line([outlier_pts_left(i, 1) outlier_pts_rt(i, 1) + width], [outlier_pts_left(i, 2) outlier_pts_rt(i, 2)],'Color', 'red');
end
hold off;
title("Corresponding inliers and outliers");

%Convergence of bounds figure

 figure(3)
 iter = 1:1:length(Evolution_lb);
 plot(iter,Evolution_lb(:,1),'b-');
 hold on;
 plot(iter,Evolution_ub(:,1),'r-');
 hold on;
 legend('lower','upper')
 title('Convergence of bounds')
 xlabel('Number of iterations')
 ylabel('Upper and lower bounds')
 hold off;
end
            
    
    
        
    
