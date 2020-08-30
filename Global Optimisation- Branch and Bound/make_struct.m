function new_struct_bounds = make_struct(ThetaLowerBound,ThetaUpperBound,ObjLowerBound,ObjUpperBound,ThetaOptimizer)

new_struct_bounds = struct('ThetaLowerBound', ThetaLowerBound, 'ThetaUpperBound',ThetaUpperBound, 'ObjLowerBound', ObjLowerBound, 'ObjUpperBound',ObjUpperBound,'ThetaOptimizer', ThetaOptimizer);
end