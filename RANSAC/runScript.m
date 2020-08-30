% run Script
function [data,iter_RANSAC,best_model_RANSAC] = runScript(xc,yc,R,tau)

%random seed initialisation
rng('shuffle','twister');

%parameters (given)
N = 100; %number of points
noise_param=[-0.1,0.1]; %noise between [-0.1 0.1]
x_min = -10;
x_max = 10;
y_min = -10;
y_max = 10;
p = 0.99; %success rate
s = 3 ; %number of samples chosen for circle
r = [5;20;30;70];

%initialising variable with zeros
data = zeros(N,2,length(r));
iter_RANSAC = zeros(length(r),1);
model_RANSAC = zeros(5,1000,length(r));
best_model_RANSAC = zeros(5,1,length(r));

warning('off', 'MATLAB:singularMatrix');
%% data generation
for i=1:length(r)
    
    %data generation
    [data(:,:,i),no_inl,no_out] = data_gen(xc,yc,R,N,r(i),noise_param,x_min,x_max,y_min,y_max,tau);
    disp(['After verifying: number of inliers = ', num2str(no_inl), ', number of outlier = ', num2str(no_out)])
    disp(['Ratio of outliers is =', num2str(int32(no_out*100/(no_inl+no_out)))])
    
%% RANSAC algorithm
    for m=1:1000
        
        [iter_RANSAC(i) , model_RANSAC(:,m,i)] = RANSACircle(data(:,:,i),r(i),p,s,tau);
        if best_model_RANSAC(1,1,i)<model_RANSAC(1,m,i) %inliers comparison
            best_model_RANSAC(:,:,i) = model_RANSAC(:,m,i);
        end
       
    end
    
    disp('best result of ransac = ')
    disp(best_model_RANSAC(:,:,i))
    
    %plotting histogram and RANSAC result
    
    
    subplot(2,length(r),i);
    histogram(model_RANSAC(1,:,i),0:N);
    xlim([0 100])
   
    xlabel('No. of detected inliers')
    ylabel('No. of experiments')
    
    %plotting RANSAC plot with best RANSAC model
    
    theta = 0:pi/50:2*pi;
    subplot(2,length(r),i + length(r));
    
    x_circlefit = zeros(length(theta),length(r));
    y_circlefit = zeros(length(theta),length(r));
    x_circlefit(:,i) = best_model_RANSAC(3,1,i) + best_model_RANSAC(5,1,i) * cos(theta);
    y_circlefit(:,i) = best_model_RANSAC(4,1,i) + best_model_RANSAC(5,1,i) * sin(theta);
    plot(x_circlefit(:,i),y_circlefit(:,i),'g-','LineWidth',2);
    axis([-10 10 -10 10])
    hold on;
    
    %plotting synthetic
    x_syn = xc + R*cos(theta);
    y_syn = yc + R*sin(theta);

    plot(x_syn,y_syn,'k-');
    hold on;
   
    %plotting RANSAC inliers and outliers
    PlotRANSACinout(data(:,:,i),best_model_RANSAC(:,1,i),tau);
    axis([-10 10 -10 10])
    hold on;
    legend({'RANSAC model','synth. model','RANSAC inliers','RANSAC outliers'},'location','southoutside','FontSize',8);
    hold off;
end
end

