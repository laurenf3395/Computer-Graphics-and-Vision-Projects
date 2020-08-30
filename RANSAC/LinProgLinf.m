function [v] = LinProgLinf(data)
    
    x = data(:,1);
    y = data(:,2);
    
    N = length(x);
    %to use linprog we need to put it in form minv f.v such that Av <= b
    % after simplification let v = [a;b;t]
    % A = [x,-1*ones(N,1),-1*eye(N) ; -x, 1*ones(N,1),1*eye(N)]
    A= [x , ones(N,1), -1* ones(N,1) ; -x ,-1*ones(N,1), -1*ones(N,1)];
    b = [y;-y];
    %in objective function f.v, min t
    f = [0 0 1];
    
    %get parameters v using linprog
    
    v= linprog(f,A,b);
    
%     x_syn = -10:1:10;
%     plot(x_syn, v(1)*x_syn + v(2),'b-');
    
end