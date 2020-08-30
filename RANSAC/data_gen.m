function [data_gener,nmb_inliers,nmb_outliers] = data_gen(xc,yc,R,N,r,noise_param,x_min,x_max,y_min,y_max,tau)
    % (xc,yc) = circle center
    % R = circle radius
    % N = number of data points
    % tau = inlier distance threshold
    % [xmin,xmax] = [-10,10]
    % [ymin,ymax] = [-10,10]
    % r = Ratio of outliers
    % noise_param = [-0.1,0.1]
    
    %% number of outliers and inliers
    n_out = int32(N * (r/100));
    n_in = int32(N* ((100-r)/100)); 
    %need to typecast into integer
    
    %% generating inliers
    t = linspace(0,2*pi,n_in); %randomly spaced between [0,2*pi]
    x_in = xc + R*cos(t);
    y_in = yc + R*sin(t);
    
    %adding noise
    A = noise_param(1);
    B = noise_param(2);
    
    %preallocating x_in_noisy and y_in_noisy to improve speed
    x_in_noisy = zeros(n_in,1);
    y_in_noisy = zeros(n_in,1);
    
    for i=1:n_in-1
        x_in_noisy(i) = x_in(i) + (A + (B-A)* rand);
        y_in_noisy(i) = y_in(i) + (A + (B-A)* rand);
    end
    
    %to check if it verifies inliers (adding last point as (-9,9) which is
    %not an inlier
    x_in_noisy(n_in)= -9;
    y_in_noisy(n_in) = 9;
    
    disp(x_in_noisy);
    disp(y_in_noisy);
    
    %% Verifying inliers with tau where dist you want to find is between(x_in_noisy,y_in_noisy) and (xc,yc); if not inlier, replace it
    flag_inl=true;
    while(flag_inl)
        a = [x_in_noisy,y_in_noisy];
        b = [xc,yc];
        dist_inl = pdist2(a,b);
        thresh = abs(dist_inl-R);
        verify = thresh>tau;
        if any(verify)
            %fprintf("Not all inliers");
            flag_inl = true;
            %To see how many values are not inliers and get their indices
            z=find(verify);
            for i= 1:length(z)
                theta = 2*pi*rand;
                x_in_noisy(z(i)) = xc + R*cos(theta) + (A + (B-A)* rand);
                y_in_noisy(z(i)) = yc + R*sin(theta) + (A + (B-A)* rand);
            end
        else
            flag_inl = false;
        end
    end

    %% generating outliers between [-10,10]
    
    x_out = zeros(n_out,1);
    y_out = zeros(n_out,1);
    for i=1:n_out
        x_out(i) = x_min +(x_max - x_min)*rand;
        y_out(i) = y_min +(y_max - y_min)*rand;
    end
    
    %% Verifying outliers with tau
    flag_out = true;
    while(flag_out)
        c = [x_out,y_out];
        d = [xc,yc];
        dist_out = pdist2(c,d);
        thresh_out = abs(dist_out-R);
        verify_out = thresh_out<tau;
        if any(verify_out)
            %fprintf("Not all outliers");
            flag_out = true;
            %To see how many values are not outliers and get their indices
            %and replace them
            z_out=find(verify_out);
            for i= 1:length(z_out)
                x_out(z_out(i)) = x_min +(x_max - x_min)*rand;
                y_out(z_out(i)) = y_min +(y_max - y_min)*rand;
            end
        else
            flag_out = false;
        end
    end
    
    %% Data generated
    inlier_data = [x_in_noisy,y_in_noisy];
    outlier_data = [x_out,y_out];
    data_gener = [inlier_data;outlier_data];
    nmb_inliers = length(inlier_data);
    nmb_outliers = length(outlier_data);
    
