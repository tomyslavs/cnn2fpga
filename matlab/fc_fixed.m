function net = fc_fixed(net,N)
% in all fc layers convert weights and biases to fixed
% N - FractionLength, N bits after comma
net_new = net.saveobj;                          % load to new net
for idx = 1:length(net_new.Layers)
    lname = net.Layers(idx).Name;               % extract layer name
    lname = lname(1:2);                         % leave 'fc' from 'fc_1' or 'fc_2' or ...
    if strcmp(lname,'fc')                       % is it fc layer?
        W=net_new.Layers(idx).Weights;
        B=net_new.Layers(idx).Bias;
        
        W=round(W*(N^2))./(N^2);
        B=round(B*(N^2))./(N^2);
        
        net_new.Layers(idx).Weights=W;         % modified weighs
        net_new.Layers(idx).Bias=B;            % modified biases
    end
end
net = net.loadobj(net_new);                                 % load back from new net