function [forw_warped_img,forw_warped_img_sim,forw_warped_img_rigid]= visualise_results(p,q,img_y,img_x,f_a_v,f_s_v,f_r_v,image)

    
    for i=1:img_y
        for j=1:img_x
            if f_a_v(i,j,1)>0 && f_a_v(i,j,2) >0
                forw_warped_img(f_a_v(i,j,2),f_a_v(i,j,1),:) = image(i,j,:);
            else
                forw_warped_img(i,j,:) = image(i,j,:);
            end
            if f_s_v(i,j,1)>0 && f_s_v(i,j,2) >0
                forw_warped_img_sim(f_s_v(i,j,2),f_s_v(i,j,1),:) = image(i,j,:);
            else
                forw_warped_img_sim(i,j,:) = image(i,j,:);
            end
            if f_r_v(i,j,1)>0 && f_r_v(i,j,2) >0
                forw_warped_img_rigid(f_r_v(i,j,2),f_r_v(i,j,1),:) = image(i,j,:);
            else
                forw_warped_img_rigid(i,j,:) = image(i,j,:);
            end

        end
    end
    figure
    subplot(2,2,1)
    imshow(image)
    hold on;
    plot(p(1,:), p(2,:), 'go')
    plot(q(1,:), q(2,:), 'rx')
    title("Original image")
    hold off;
    subplot(2,2,2)
    imshow(forw_warped_img)
    hold on;
    plot(p(1,:), p(2,:), 'go')
    plot(q(1,:), q(2,:), 'rx')
    title("Affine Transform");
    hold off;
    subplot(2,2,3)
    imshow(forw_warped_img_sim)
    hold on;
    plot(p(1,:), p(2,:), 'go')
    plot(q(1,:), q(2,:), 'rx')
    title("Similarity Transform");
    hold off;
    subplot(2,2,4)
    imshow(forw_warped_img_rigid)
    hold on;
    plot(p(1,:), p(2,:), 'go')
    plot(q(1,:), q(2,:), 'rx')
    title("Rigid Transform");
    hold off;
end