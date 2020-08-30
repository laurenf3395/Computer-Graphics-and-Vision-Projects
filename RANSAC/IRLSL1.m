function [param_new,cost_new,w] = IRLSL1(data,tau)

x = data(:,1);
y = data(:,2);
N = length(x);

W = eye(N);
X =[x,ones(N,1)];


%param = (inv(A) * B)

%Weights initialised to I (dimensions N*N)
done = false;
param_new = [0;0];
cost_new = 0;
while(~done)
    
    %Let Weights be initialised to identity matrix(100x100). Solve closed
    %form to get parameters a and b
    
    params = (X'*W*X) \ (X'*W*y);
    param_old = param_new;
    param_new = params;
    
    %now calculate w for L1 norm
    w = 0.5* abs(y -(param_new(1)*x + param_new(2))).^(-1);
    W = diag(w);
    
    %cost d(x,y)^2 : |y-(ax+b)|^2 
    %MATRIX FORM : C(X,W) = |Y-X*THETA|^2. THETA is the parameter (a,b)
    cost_old = cost_new; 
    cost_new = (y - X * params)' * W * (y - X*params); %d(x,y)^2
    
    if abs(cost_new - cost_old) < (tau^2)
        done = true;
    else
        done=false;
    end
end
% x = -10:1:10;
% plot(x,param_new(1)*x + param_new(2),'k-');

end