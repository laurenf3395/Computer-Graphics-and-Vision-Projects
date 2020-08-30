## RANSAC for circle fitting

`runScript.m`
Inputs are coordinates of the center of the circle (xc,yc), radius R and inlier distance threshold (tau).
Outputs: Distribution of RANSAC results with different outlier ratios.

`RANSACircle.m` : RANSAC algorithm for circle fitting

For obtained RANSAC results for circle fitting, the command could be for instance:  
`[data,iter_RANSAC,best_model_RANSAC]= runScript(0,0,4,0.1)`
where (0,0) is the center, radius is 4 and tau is 0.1.

## Exhaustive Search

`runEs.m`: Runs Exhaustive Search implemented for different values of outlier ratios  

For running Exhaustive search, the command could be for instance:  
`[best_modelES] = runEs(0,0,4,100,3,0.1)`
where (0,0) is the center, radius is 4, N=100, sample size=3 and tau = 0.1.

## IRLS for Line fitting

`runScript2.m`: Plots the line fitting using L1 norm(Linear Programming and IRLS) and L_(infinity)- Linear Programming.  
`LinProgL1.m`: Line fitting using L1 norm employing Linear Programming.  
`LinProgLinf.m`: Line fitting using Linf norm employing LP.  
`IRLSL1.m` : Line fitting using L1 norm employing Iterative re-weighted Least Squares algorithm (IRLS).  

For IRLs and LP, the command could be:  
`[data_line,v_L1,v_Linf,param_IRLS] = runScript2(2,3,0.1)`
where a=2, b=3 and tau=0.1.
