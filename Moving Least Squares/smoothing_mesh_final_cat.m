% Smoothing meshes FOR CAT
%% Initialisation
clear;
sigma = [90;70;50;20;10;1;0.5;0.1;0.05];

addpath('mesh_io\mesh');
addpath('mesh_io\normals');
%% Calculating f(x)
for z=1:length(sigma)
    
    [V,F,~,~,~] = readOFF( 'cat.off' );
    N = per_vertex_normals(V,F);
    
    P=V;
    f_x = zeros(length(P),3);
    for i=1:length(P)
        % calculating ||x-xi||
        for points = 1:length(V)
            euc(points) = norm(P(i,:)-V(points,:));
            sq_euc(points) = euc(points).^2; 
        % calculating phi = e^(-||x-xi||/(sigma)^2)
            phi(points) = exp((-sq_euc(points))/(sigma(z)^2)); %size: 1 x N -> where N is number of vertices
        % calculating (x-xi)
            diff(points,:) = P(i,:) - V(points,:); %size: N x 3
        % derivative of phi
            der_phi(points,:)=(-2/(sigma(z)^2)) .* phi(points) .* diff(points,:);
            %f_x(points,:) = sum(phi(points) .* (N(points,:)'*(diff(points,:))))/sum(phi(points)) ;
        end
        %calcuating f(x) for each grid point
        f_x(i,:) = sum(phi * dot(N',diff')')/sum(phi) ;%sum(phi .*(dot(N',diff'))')/sum(phi) ;
        A1 = phi.*N';
        NiX = dot(N',diff');
        sub = NiX - f_x(i,1)';
        A2 = der_phi .* sub'; 
        der_f_x(i,:) = sum(A1'+A2)/sum(phi);
    end
       
    
    %product of derivative of f(x) and f(x)
    pdt = f_x .* der_f_x;
    V_new = V - pdt;
    filename = ['cat_sigma',num2str(sigma(z)),'_final.off'];
    N_new = per_vertex_normals(V_new,F);
    writeOFF(filename, V_new, F, [], [], N_new);
end

patch('Vertices',V_new,'Faces',F,...
      'FaceVertexCData',hsv(366),'FaceColor','interp')
view(3)

figure(2)
patch('Vertices',V,'Faces',F,...
      'FaceVertexCData',hsv(366),'FaceColor','interp')
view(3)