%% Initialisation
clear;
sigma = [1;0.5;0.1;0.05;0.01;0.005;0.001;0.0005;0.0001];
e = 1e-4;
addpath('\TASK1');
%% Creating grid
x_values = -2:0.05:2;
y_values = -2:0.05:2;

%grid creation
[grid_x, grid_y] = meshgrid(x_values,y_values);
% reshape it to make each point in a row
P = [grid_x,grid_y];
P= reshape(P,[],2);

%% Importing data
for n=1:3
  filename = sprintf('curve_data%d.mat',n) ;
  S = load(filename);

%Loading xi and yi points
    P_i = [S.xi',S.yi'];
%Loading normals
    N_i = [S.nix',S.niy'];


    for z=1:length(sigma)
        %% Calculating C0

        for i=1:length(P)
            % calculating ||x-xi||
            for points = 1:length(P_i)
                euc(points) = norm(P(i,:)-P_i(points,:));
            
                sq_euc(points)  = euc(points).^2;
            
                % calculating phi = e^(-||x-xi||/(sigma)^2)
                phi(points) = exp(-sq_euc(points)/(sigma(z)^2));
                
                % calculating (x-xi)
                diff(points,:) = P(i,:) - P_i(points,:);
                %calcuating c0 for each grid point
            end
            c0(i) = sum(phi * (dot(N_i',diff'))')/sum(phi) ;
        end
        x_size = length(x_values');
        y_size = length(y_values');
%       %reshape c0 into grid of x's and y's
        c0_reshape = reshape(c0,x_size,y_size);
        within_0 = abs(c0_reshape) < e;
        [index_within0_y,index_within0_x] = find(within_0);
        
        figure(n)
        subplot(3,3,z)
        imagesc(x_values,y_values,c0_reshape);
        title(['f(x) for sigma=' , num2str(sigma(z))]);
        hold on;
        plot(S.xi,S.yi,'-r');
        hold on;
        plot(x_values(index_within0_x),y_values(index_within0_y))
        colorbar
    
    end
end

