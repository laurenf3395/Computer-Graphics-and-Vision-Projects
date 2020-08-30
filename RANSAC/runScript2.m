function [data_line,v_L1,v_Linf,param_IRLS] = runScript2(a,b,tau)

%random seed initialisation
rng('shuffle','twister');

%parameters (given)
N = 100; %number of points

r = [0;10];


%initialising parameters

v_L1 = zeros(N+2,2);
v_Linf = zeros(3,2);
param_IRLS = zeros(2,2);

warning('off', 'MATLAB:singularMatrix');
%% data generation
for i=1:length(r)
    
%     n_out = int32(N * (r(i)/100));
%     n_in = int32(N* ((100-r(i))/100)); 
%     in_line = zeros(n_in,3);
        %data generation
    [data_line(:,:,i),nb_in,nb_out] = data_gen_line(a,b,N,r(i),[-0.1 0.1],-10,10,-10,10,tau);
   
    disp(['Ratio of outliers after verifying outliers and inliers', num2str(int32(nb_out/(nb_in+nb_out)))])
    
    
%% Fitting line with Linear Programming- L1 norm

    [v_L1(:,i)] = LinProgL1(data_line(:,:,i));

%% Fitting line with Linear Programming- Linf norm
    [v_Linf(:,i)] = LinProgLinf(data_line(:,:,i));

%% IRLS ALGO

    [param_IRLS(:,i)] = IRLSL1(data_line(:,:,i),tau);
    

%% Plot
end

for i=1:length(r)
    
    figure(i)
    
    %plot points from data_gen_line
    figure(i),plot(data_line(:,1,i),data_line(:,2,i),'bo');
    
    hold on;
    
    x_ideal = -10:0.01:10;
    %Linear Programming L1 norm
    
    figure(i),plot(x_ideal, v_L1(1,i)*x_ideal + v_L1(2,i),'m-','LineWidth',1);
    hold on;
     
    %LP - Linfinity norm
     
    figure(i),plot(x_ideal, v_Linf(1,i)*x_ideal + v_Linf(2,i),'y-','LineWidth',1);
    hold on;
     
    %IRLS algo with L1 norm
    figure(i),plot(x_ideal, param_IRLS(1,i)*x_ideal + param_IRLS(2,i),'k-','LineWidth',1);
    hold on;
    
    % synthetic model
    y_ideal = (a * x_ideal) + b;
    figure(i),plot(x_ideal,y_ideal,'g-');
    hold on;
    
    
    title(['r = ',num2str(r(i))]);
    legend('Data pts.','LP-L1','LP-Linf','IRLS','synth. model');
    hold off;
    
    
end
end

