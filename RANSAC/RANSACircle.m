 function [iter,best_model] = RANSACircle(data,r,p,s,tau)

    r = r/100;

    %Find number of iterations for RANSAC
    N = ceil(log(1-p)/(log(1-(1-r)^s))); %took ceil to round number to greatest integer (as done in class)

    iter = N;
 
    best_model = zeros(5,1); %contains data about no_inliers, a,b,radius,iteration
    
    for i=1:N
        %% Sampling data
        
        %Sample data randomly
        sampled_data = datasample(data,s);
        %sampled_data = [2 1;0 5;-1 2];
        
        %% fit the circle with the three points
        %have 3 points (x_p,y_p),(x_q,y_q) and (x_r,y_r), whose distance to center is equal: use that to get center (a,b) and radius rad: Ax = B form
        
        %A = [x_p-x_q y_p-y_q;x_q-x_r y_q-y_r]
        %B = [x_p^2 - x_q^2 + y_p^2 - y_q^2; x_q^2 - x_r^2 + y_q^2 - y_r^2]
        %x = [a;b] --> Center of circle (a,b)
        A = [sampled_data(1,1)- sampled_data(2,1) sampled_data(1,2)-sampled_data(2,2);sampled_data(2,1)- sampled_data(3,1) sampled_data(2,2)-sampled_data(3,2)];
        B = 0.5 *[(sampled_data(1,1)^2) - (sampled_data(2,1)^2) + (sampled_data(1,2)^2) - (sampled_data(2,2)^2) ; (sampled_data(2,1)^2) - (sampled_data(3,1)^2) + (sampled_data(2,2))^2 - (sampled_data(3,2)^2)];
        result =mldivide(A,B);
        
        
        %get radius of this circle that needs to be fit
        %take distance between (x_p,y_p) and (a,b)
        P = [sampled_data(1,1) sampled_data(1,2)];
        center = [result(1), result(2)];
        rad = pdist2(P,center);

        %% Calculating number of inliers. Error chosen is Euclidean distance
        n_in_fitted = 0;
        n_out_fitted = 0;
        within_thresh = abs(pdist2(data,center) - rad) <=tau;
        outside_thresh = abs(pdist2(data,center) - rad) > tau;
        if any(within_thresh)
            z = find(within_thresh);
            n_in_fitted = length(z);
        end
        if any(outside_thresh)
             o = find(outside_thresh);
             n_out_fitted = length(o);
        end
       
       
        %% compare model for each iteration (more number of inliers - the better)
        if best_model(1) < n_in_fitted
            best_model = [n_in_fitted;n_out_fitted;center(1);center(2);rad];
        end
        
    end
 
end