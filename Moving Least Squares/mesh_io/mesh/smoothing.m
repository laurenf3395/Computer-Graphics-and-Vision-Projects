% Smoothing meshes
%% Initialisation
clear;
sigma = [1;0.5;0.1;0.05;0.04;0.03;0.02;0.01;0.001];

addpath('mesh_io\mesh');
addpath('mesh_io\normals');
%% Calculating f(x)
for z=1:length(sigma)
    
    [V,F,~,~,~] = readOFF( 'bunny.off' );
    N = per_vertex_normals(V,F);
    F_x = zeros(3,length(V));
    P=V;
    for i=1:length(P)
        % calculating ||x-xi||
        for points = 1:length(V)
            euc(points) = norm(P(i,:)-V(points,:));
            sq_euc(points) = euc(points).^2; 
        % calculating phi = e^(-||x-xi||/(sigma)^2)
            phi(points) = exp((-sq_euc(points))/(sigma(z)^2)); %size: 1 x N -> where N is number of vertices
        % calculating (x-xi)
            diff(points,:) = P(i,:) - V(points,:); %size: N x 3
        
        end
        %calcuating f(x) for each grid point
        f_x = sum(phi .*(dot(N',diff')))/sum(phi) ; %one value
    end
end

%         F_x(:,i) = f_x;
%        
%         A1 = phi.*N';
%         NiX = dot(N',diff');
%         sub = NiX - f_x;
%         der_phi=(-2/(sigma(z)^2)) * phi .* diff';
%         A2 = der_phi' .* sub';
%         der_f_x = sum(A1'+A2)/sum(phi);
%         Der_F_x(:,i) = der_f_x;
%     end
%      pdt = F_x .* Der_F_x;
%      V_new = V - pdt';
%      filename = ['bunny_sigma',num2str(sigma(z)),'_new.off'];
%      N_new = per_vertex_normals(V_new,F);
%      writeOFF(filename, V_new, F, [], [], N_new);
% end
