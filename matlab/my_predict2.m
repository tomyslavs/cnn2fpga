function [y] = my_predict2(net,x)
% It works same as 'predict.m'
% x = XValidation(:,:,:,1:10);
y = zeros(length(x(1,1,1,:)),net.Layers(5).OutputSize);
for n=1:length(x(1,1,1,:))
%     I = x(:,:,:,n);
    I = x(:,:,:,n)-net.Layers(1).AverageImage;
%% --------------------------------------------------------------------- %%
    %% 1 Conv.
    w1 = net.Layers(2).Weights;
%     w1(:,:,1) = rot90(w1(:,:,1),2);
%     w1(:,:,2) = rot90(w1(:,:,2),2);
%     w1(:,:,3) = rot90(w1(:,:,3),2);
    w1 = rot90(w1,2);
    b1 = net.Layers(2).Bias;
    C1 = zeros(net.Layers(1).InputSize(1),net.Layers(1).InputSize(2),net.Layers(2).NumFilters);
    for f=1:net.Layers(2).NumFilters        % filter
        for ch=1:net.Layers(2).NumChannels	% channel
%             C1(:,:) = C1(:,:) + conv2(I(:,:,ch),w1(:,:,ch),'same');
            C1(:,:,f) = C1(:,:,f) + conv2(I(:,:,ch),w1(:,:,ch,f),'same');
        end
        C1(:,:,f) = C1(:,:,f) + b1(:,:,f);
%     C1 = sum(C1,3);
%         C1 = C1 + b1;
    end
    %% 1 Stride 2x2
%     C1 = rot90(C1,2);
    C1s = C1(2:2:end,2:2:end,:);
    %% 1 Batch norm.
    C1_xmu = C1s - net.Layers(3).TrainedMean;
    C1_sqrtvar = sqrt(net.Layers(3).TrainedVariance + net.Layers(3).Epsilon);
    C1_ivar = 1./C1_sqrtvar;
    C1_xhat = C1_xmu .* C1_ivar;
    C1_gammax = net.Layers(3).Scale .* C1_xhat;
    C1n = C1_gammax + net.Layers(3).Offset;
%       C1n = C1s;
    %% 1 ReLU
%     C1nLReLU = C1s;
%     C1nLReLU(C1nLReLU<0)=0;
%     C1nLReLU = C1n;
%     C1nLReLU(C1nLReLU<0)=0;                 % replace negative with zeros
    C1nLReLU = max(0,C1n) + min(0,C1n)*net.Layers(4).Scale; % LeakyReLU pos + neg*scale
%% --------------------------------------------------------------------- %%
    %% FC
%     C1nLReLU = rot90(C1nLReLU,1);
    fc1in = C1nLReLU(:)'; % C1s(:); % C1nLReLU(:)
%     fc1out = zeros(1,net.Layers(5).OutputSize);
%     fc1out = sum(fc1in.*net.Layers(5).Weights(k,:)) + net.Layers(5).Bias(k);
    fc1out = repelem(fc1in,net.Layers(5).OutputSize,1).*net.Layers(5).Weights;
    fc1out = sum(fc1out,2) + net.Layers(5).Bias;
    y(n,1:net.Layers(5).OutputSize) = fc1out;
%     disp(['n=' num2str(n)])
end
% YPredicted2 = y;
