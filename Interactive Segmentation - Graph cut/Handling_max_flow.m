addpath(genpath('Graphs'));

%Creating the graph with 3 nodes with source and sink
model = BK_Create(3,10);

%setting unaries
unary_cost = [4 9;7 7;8 5]; %1st column: to sink ; 2nd column: t-links with source
BK_SetUnary(model,unary_cost');

%edge cost between nodes
pairwise_cost = [1 2 0 3 0 0; 2 1 0 2 0 0; 2 3 0 5 0 0; 3 2 0 1 0 0];
BK_SetPairwise(model, pairwise_cost);

%Optimising
E = BK_Minimize(model);
disp(["Energy = ",E]);

%Labels
labels_model = BK_GetLabeling(model);
disp(labels_model);

