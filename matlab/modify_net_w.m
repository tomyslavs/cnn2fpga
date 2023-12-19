net_new = net.saveobj;


% net_new.Layers(7,1).Weights=net_new.Layers(7,1).Weights/10;
% net_new.Layers(6,1).Weights=net_new.Layers(6,1).Weights/10
net_new.Layers(14,1).Bias=net_new.Layers(14,1).Bias*0;
net_new.Layers(15,1).Bias=net_new.Layers(15,1).Bias*0;

net = net.loadobj(net_new);
YPredicted = predict(net,0*zeros(128,128,3,1)+1);

