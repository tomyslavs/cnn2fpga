function net = bn_fixed(net,N)
% in all bn layers convert parameters to fixed
% N - FractionLength, N bits after comma
net_new = net.saveobj;                                          % load to new net
for idx = 1:length(net_new.Layers)
    lname = net.Layers(idx).Name;                               % extract layer name
    lname = lname(1:2);                                         % leave 'ba' from 'batchnorm_1' or 'batchnorm_2' or ...
    if strcmp(lname,'ba')                                       % is it 'ba' layer?
        TrainedMean=net_new.Layers(idx).TrainedMean;
        TrainedVariance=net_new.Layers(idx).TrainedVariance;
        Offset=net_new.Layers(idx).Offset;
        Scale=net_new.Layers(idx).Scale;
        
        TrainedMean=round(TrainedMean*(N^2))./(N^2);
        TrainedVariance=round(TrainedVariance*(N^2))./(N^2);
        Offset=round(Offset*(N^2))./(N^2);
        Scale=round(Scale*(N^2))./(N^2);
        
        net_new.Layers(idx).TrainedMean=TrainedMean;            % modified Mean
        net_new.Layers(idx).TrainedVariance=TrainedVariance;    % modified Variance
        net_new.Layers(idx).Offset=Offset;                      % modified Offset
        net_new.Layers(idx).Scale=Scale;                        % modified Scale
    end
end
net = net.loadobj(net_new);                                     % load back from new net