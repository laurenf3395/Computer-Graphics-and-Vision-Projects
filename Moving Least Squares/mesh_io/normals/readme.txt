How to get normals for the bunny mesh:

    [V,F,~,~,~] = readOFF( 'bunny.off' );
    N = per_vertex_normals(V,F);
	
Afterwards, use V,F and N normally.
