function [ExSearchiter,best_modelES] = ExhaustiveSearch(s,data,tau)

    %C = nchoosek(v,k) returns a matrix containing all possible combinations of the elements of vector v taken k at a time
    ExSamples_i = nchoosek(1:length(data),s); %different combinations of choosing 3 points from data_indices
    best_modelES = zeros(5,1);
    
    ExSearchiter = length(ExSamples_i);
  
    for i=1:ExSearchiter
        samples_ExS = data(ExSamples_i(i,:),:);
        
        %fit circle
        A = [samples_ExS(1,1)- samples_ExS(2,1) samples_ExS(1,2)-samples_ExS(2,2);samples_ExS(2,1)- samples_ExS(3,1) samples_ExS(2,2)-samples_ExS(3,2)];
        B = 0.5 *[(samples_ExS(1,1)^2) - (samples_ExS(2,1)^2) + (samples_ExS(1,2)^2) - (samples_ExS(2,2)^2) ; (samples_ExS(2,1)^2) - (samples_ExS(3,1)^2) + (samples_ExS(2,2))^2 - (samples_ExS(3,2)^2)];
        result = A\B;
        %get radius of this circle that needs to be fit
        %take distance between (x_p,y_p) and (a,b)
        P = [samples_ExS(1,1) samples_ExS(1,2)];
        center = [result(1), result(2)];
        rad = pdist2(P,center);
        
        %% Calculating number of inliers. Error chosen is Euclidean distance
        n_inl = 0;
        n_out= 0;
        within_thresh = abs(pdist2(data,center) - rad) <=tau;
        outside_thresh = abs(pdist2(data,center) - rad) > tau;
        if any(within_thresh)
            z = find(within_thresh);
            n_inl = length(z);
        end
        if any(outside_thresh)
             o = find(outside_thresh);
             n_out = length(o);
        end
       
        %% Choosing best model
        if best_modelES(1)<n_inl
            best_modelES = [n_inl;n_out;center(1);center(2);rad];
        end
        
    end
end
        
        