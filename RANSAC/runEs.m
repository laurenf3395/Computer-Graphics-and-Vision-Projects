function [best_modelES] = runEs(xc,yc,R,N,s,tau)

% s : sample size
% data is the (x,y) coordinates of the points
%tau : inlier distance threshold
% r : outlier ratio

r= [10;20;30;70];

%initialising parameters
best_modelES = zeros(5,length(r));

for i=1:length(r)
    
    %data generation
    [data(:,:,i),n_in,n_out] = data_gen(xc,yc,R,N,r(i),[-0.1 0.1],-10,10,-10,10,tau);
    [ExSearch_iter, best_modelES(:,i)] = ExhaustiveSearch(s,data(:,:,i),tau)
    
    disp(['Number of iterations', num2str(ExSearch_iter)]);
    disp(['Number of inliers ' num2str(best_modelES(1,i))]);
    disp(['Number of outliers ' num2str(best_modelES(2,i))]);
    disp(['Center of circle fitted (' num2str(best_modelES(3,i)),',',num2str(best_modelES(4,i))]);
    disp(['Radius of circle ' num2str(best_modelES(5,i))]);
end