function [v] = LinProgL1(data)
    
    x = data(:,1);
    y = data(:,2);
    
    N = length(x);
    %to use linprog we need to put it in form minv f.v such that Av <= b
    % after simplification let v = [a;b;t1;t2 ....;t100]
    % A = [x,-1*ones(N,1),-1*eye(N) ; -x, 1*ones(N,1),1*eye(N)]
    A = [x , ones(N,1), -1* eye(N) ; -x ,-1*ones(N,1), -1*eye(N)];
    b = [y;-y];
    %in objective function f.v, min ti
    f = [0,0,ones(1,N)];
    
    %get parameters v using linprog
    
    v = linprog(f,A,b);
    
%     x_syn = -10:1:10;
%     plot(x_syn, v(1)*x_syn + v(2),'g-');
%     hold on;
    
    
end