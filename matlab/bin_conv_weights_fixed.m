function net = bin_conv_weights_fixed(net,learn_conv_layer,N)
% in all conv layers modify w to B(binary: +1,-1)*A
net_new = net.saveobj;                                      % load to new net
for idx = 1:length(net_new.Layers)
    if isprop(net_new.Layers(idx),'FilterSize')             % it is conv layer?
        W=net_new.Layers(idx).Weights;
        for ch = 1:net_new.Layers(idx).NumChannels          % through all channels
            for f = 1:net_new.Layers(idx).NumFilters        % through all filters
                w=W(:,:,ch,f);
                A=mean(abs(w(:)));                          % mean of filter weights
                B=sign(w);                                  % binary weights
                w_mod = B*A; % B | B*A
%                 w_mod=round(w_mod*(N^2))./(N^2);            % to sfixed
                net_new.Layers(idx).Weights(:,:,ch,f)=w_mod;% modified weighs
            end
        end
%         B=net_new.Layers(idx).Bias;
%         B=round(B*(N^2))./(N^2);                            % to sfixed
%         net_new.Layers(idx).Bias=B;                         % modified biases
        if strcmp(learn_conv_layer,'no')
            net_new.Layers(idx).WeightLearnRateFactor = 0;  % do not train w
            net_new.Layers(idx).BiasLearnRateFactor = 0;    % do not train b
        end
    end
end
net = net.loadobj(net_new);                                 % load back from new net