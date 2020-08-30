function [data_gener_line,in_nb,out_nb] = data_gen_line(a,b,N,r,noise_param,x_min,x_max,y_min,y_max,tau)
    % a,b = Parameters of line model
    % N = number of data points
    % tau = inlier distance threshold
    % [xmin,xmax] = [-10,10]
    % [ymin,ymax] = [-10,10]
    % r = Ratio of outliers
    % noise_param = [-0.1,0.1]
    
    %% number of outliers and inliers
    n_out = int32(N * (r/100));
    n_in = int32(N* ((100-r)/100)); %need to typecast into integer
    
    %% generating inliers
    
    %first generating inliers without noise
    x_in = zeros(n_in,1);
    y_in = zeros(n_in,1);
    for i=1:n_in
        x_in(i) =  x_min + (x_max-x_min)* rand;
        y_in(i) = a*(x_in(i)) + b;
    end
   
    %adding noise
    A = noise_param(1);
    B = noise_param(2);
    
    %preallocating x_in_noisy and y_in_noisy to improve speed
    x_in_noisy = zeros(n_in,1);
    y_in_noisy = zeros(n_in,1);
    
    for i=1:n_in
        x_in_noisy(i) = x_in(i) + (A + (B-A)* rand);
        y_in_noisy(i) = y_in(i) + (A + (B-A)*rand);
    
    
%         if (x_min > x_in_noisy(i) && x_in_noisy(i) > x_max && y_min > y_in_noisy(i) && y_in_noisy(i) > y_max)
%             continue
%         end
    end
 
 %to check if it verifies inliers 
 %    x_in_noisy(n_in)= 1;
%     y_in_noisy(n_in) = 2;

%     
    %% Verifying inliers with tau using vertical cost; if not inlier, replace it
    flag_inl=true;
    while(flag_inl)
        %Inliers should be within the threshold: use vertical cost =
        %|yi-(axi + b)|
        vert_dist = abs(y_in_noisy - (a*x_in_noisy + b));
        out_thresh = vert_dist > tau;
        if (any(out_thresh))
            %fprintf("Not all inliers");
            flag_inl = true;
            %To see how many values are not inliers and get their indices
            z=find(out_thresh);
            x_in_noisy(z(1:length(z))) = x_in_noisy(z(1:length(z))) + (A + (B-A)* rand);
            y_in_noisy(z(1:length(z))) = a*(x_in_noisy(1:length(z))) + b;
        else
            flag_inl = false;
        end
    end


    %% generating outliers between [-10,10]
    
    x_out = zeros(n_out,1);
    y_out = zeros(n_out,1);
    for i=1:n_out-1
        x_out(i) = x_min +(x_max - x_min)*rand;
        y_out(i) = y_min +(y_max - y_min)*rand;
    end

%     
    %% Verifying outliers with tau
%     x_out(n_out) = 1;
%     y_out(n_out) = 5;
    flag_out=true;
    while(flag_out)
        %Outliers should be outside the threshold: use vertical cost |yi-(axi + b)|
        vert_dist_outl = abs(y_out - (a*x_out + b));
        in_thresh = vert_dist_outl <= tau;
        if any(in_thresh)
            fprintf("Not all outliers");
            flag_out = true;
            %To see how many values are not inliers and get their indices
            in_nmb=find(in_thresh);
            x_out(in_nmb(1:length(in_nmb))) = x_min +(x_max - x_min)*rand;
            y_out(in_nmb(1:length(in_nmb))) = y_min +(y_max - y_min)*rand;
        else
            flag_out = false;
        end
    end
  
    %% Data generated
    inlier_data = [x_in_noisy,y_in_noisy];
    outlier_data = [x_out,y_out];
    data_gener_line = [inlier_data;outlier_data];
    in_nb = length(inlier_data);
    out_nb = length(outlier_data);
    %% To check plot of inliers and outliers synthesized
%     plot(inlier_data(:,1),inlier_data(:,2),'bo',outlier_data(:,1),outlier_data(:,2),'ro');
%     axis([x_min x_max y_min y_max]);
%     hold on;
end
