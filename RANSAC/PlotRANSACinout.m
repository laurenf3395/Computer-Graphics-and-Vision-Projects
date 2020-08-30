function PlotRANSACinout(data,best_model,tau)
    
    in_thresh = find(abs(pdist2(data,[best_model(3),best_model(4)]) - best_model(5))<=tau);%gets indices of inliers within threshold
    inliers = data(in_thresh(1:length(in_thresh)),:)
    out_thresh = find(abs(pdist2(data,[best_model(3),best_model(4)]) - best_model(5))>tau);%gets indices of outliers not within threshold
    outliers = data(out_thresh(1:length(out_thresh)),:)
    
    plot(inliers(:,1), inliers(:,2),'bo');
    hold on;
    plot(outliers(:,1),outliers(:,2),'ro');
    hold on;
end