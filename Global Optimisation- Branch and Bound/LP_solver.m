function [x, bounds_given] = LP_solver(Points,bounds_given,inl_threshold,N)


constraint1 = Points(:,1) - Points(:,3) - inl_threshold;
A_1a = [zeros(N,2) , diag(constraint1), eye(N),zeros(N)];
constraint2 = - Points(:,1) + Points(:,3) - inl_threshold;
A_1b = [zeros(N,2) , diag(constraint2), -1 * eye(N),zeros(N)];
constraint3 = Points(:,2) - Points(:,4) - inl_threshold;
A_1c = [zeros(N,2) , diag(constraint3), zeros(N),eye(N)];
constraint4 = -Points(:,2) + Points(:,4) - inl_threshold;
A_1d = [zeros(N,2) , diag(constraint4), zeros(N),-1*eye(N)];

A_1 = [A_1a;A_1b;A_1c;A_1d];
b_1 = zeros(N*4,1);

A_2 = [zeros(N,2), bounds_given.ThetaLowerBound(1)*eye(N), -1*eye(N), zeros(N)];
b_2 = zeros(N,1);

A_3 = [ones(N,1),zeros(N,1),bounds_given.ThetaUpperBound(1)*eye(N),-1*eye(N),zeros(N)];
b_3 = bounds_given.ThetaUpperBound(1) * ones(N,1);

A_4 = [-1*ones(N,1),zeros(N,1),-bounds_given.ThetaLowerBound(1)*eye(N),eye(N), zeros(N)];
b_4 = -bounds_given.ThetaLowerBound(1) * ones(N,1);

A_5 = [zeros(N,2),-bounds_given.ThetaUpperBound(1)*eye(N),eye(N),zeros(N)];
b_5 = zeros(N,1);

A_6 = [zeros(N,2), bounds_given.ThetaLowerBound(2)*eye(N), zeros(N),-1*eye(N)];
b_6 = zeros(N,1);

A_7 = [zeros(N,1),ones(N,1),bounds_given.ThetaUpperBound(2)*eye(N),zeros(N),-1*eye(N)];
b_7 = bounds_given.ThetaUpperBound(2) * ones(N,1);

A_8 = [zeros(N,1),-1*ones(N,1),-bounds_given.ThetaLowerBound(2)*eye(N), zeros(N),eye(N)];
b_8 = -bounds_given.ThetaLowerBound(2) * ones(N,1);

A_9 = [zeros(N,2),-bounds_given.ThetaUpperBound(2)*eye(N),zeros(N),eye(N)];
b_9 = zeros(N,1);

A = [A_1;A_2;A_3;A_4;A_5;A_6;A_7;A_8;A_9];
b= [b_1;b_2;b_3;b_4;b_5;b_6;b_7;b_8;b_9];

f = [0;0;-1*ones(N,1);zeros(N*2,1)];

[x,zval] = linprog(f,A,b);

T_x = x(1);
T_y = x(2);

%here zval gives us the number of inliers as it is the objective function value at the solution
no_inliers_u = -zval; %upper bound of inliers

%for computing lower bound of inliers test model obtained T_x,T_y with the
%constraints |x+T_x-x'| <= inl_threshold and |y + T_y - y'| <= inl_threshold
thresh = (abs(Points(:,1) + T_x - Points(:,3)) <= inl_threshold) & (abs(Points(:,2) + T_y - Points(:,4)) <= inl_threshold);
no_inliers_l = nnz(thresh);

bounds_given.ObjLowerBound = no_inliers_l;
bounds_given.ObjUpperBound = no_inliers_u;
bounds_given.ThetaOptimizer = [T_x,T_y];


end
