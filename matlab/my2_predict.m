function [y] = my2_predict(net,x)
% It works same as 'predict.m', c*A *BN marged to single DSP
% x = XValidation(:,:,:,1:10);
y = zeros(length(x(1,1,1,:)),net.Layers(12).OutputSize);
for n=1:length(x(1,1,1,:))
    I=x(:,:,:,n)-net.Layers(1).AverageImage;
    %% --------------------------------------------------------------------- %%
    %% 1 Conv.
    A1 = abs(net.Layers(2).Weights);
    gamma_ivar1 = net.Layers(3).Scale./sqrt(net.Layers(3).TrainedVariance + net.Layers(3).Epsilon); % 1 Batch norm.
    w1 = sign(net.Layers(2).Weights);             w1 = rot90(w1,2);
%     b1 = net.Layers(2).Bias;
    C1 = zeros(net.Layers(1).InputSize(1),net.Layers(1).InputSize(2),net.Layers(2).NumFilters);
    for f=1:net.Layers(2).NumFilters        % filter
        for ch=1:net.Layers(2).NumChannels	% channel
            C1(:,:,f) = C1(:,:,f) + gamma_ivar1(:,:,f).*A1(1,1,ch,f).*conv2(I(:,:,ch),w1(:,:,ch,f),'same');
        end
%         C1(:,:,f) = C1(:,:,f);% + b1(:,:,f); % in conv layer bias=0
    end
    % surf(C1(:,:,7)); view(0,90);
    %% 1 Stride 2x2
    C1s = C1(2:2:end,2:2:end,:);
    %% 1 Batch norm.
    C1n = C1s + net.Layers(3).Offset - net.Layers(3).TrainedMean.*gamma_ivar1;
    %% 1 ReLU
    C1nLReLU = max(0,C1n) + min(0,C1n)*net.Layers(4).Scale; % LeakyReLU pos + neg*scale

    %% --------------------------------------------------------------------- %%
    %% 2 Conv.
    A2 = abs(net.Layers(5).Weights);
    gamma_ivar2 = net.Layers(6).Scale./sqrt(net.Layers(6).TrainedVariance + net.Layers(6).Epsilon); % 2 Batch norm.
    w2 = sign(net.Layers(5).Weights);             w2 = rot90(w2,2);
%     b2 = net.Layers(5).Bias;
    C2 = zeros(length(C1nLReLU(:,1,1)),length(C1nLReLU(1,:,1)),net.Layers(5).NumFilters);
    for f=1:net.Layers(5).NumFilters        % filter
        for ch=1:net.Layers(5).NumChannels	% channel
            C2(:,:,f) = C2(:,:,f) + gamma_ivar2(:,:,f).*A2(1,1,ch,f).*conv2(C1nLReLU(:,:,ch),w2(:,:,ch,f),'same');
        end
%         C2(:,:,f) = C2(:,:,f);% + b2(:,:,f); % in conv layer bias=0
    end
    % surf(C2(:,:,7)); view(0,90);
    %% 2 Stride 2x2
    C2s = C2(2:2:end,2:2:end,:);
    %% 2 Batch norm.
    C2n = C2s + net.Layers(6).Offset - net.Layers(6).TrainedMean.*gamma_ivar2;
    %% 2 ReLU
    C2nLReLU = max(0,C2n) + min(0,C2n)*net.Layers(7).Scale; % LeakyReLU pos + neg*scale

    %% --------------------------------------------------------------------- %%
    %% 3 Conv.
    A3 = abs(net.Layers(8).Weights);
    gamma_ivar3 = net.Layers(9).Scale./sqrt(net.Layers(9).TrainedVariance + net.Layers(9).Epsilon); % 3 Batch norm.
    w3 = sign(net.Layers(8).Weights);             w3 = rot90(w3,2);
%     b3 = net.Layers(8).Bias;
    C3 = zeros(length(C2nLReLU(:,1,1)),length(C2nLReLU(1,:,1)),net.Layers(8).NumFilters);
    for f=1:net.Layers(8).NumFilters        % filter
        for ch=1:net.Layers(8).NumChannels	% channel
            C3(:,:,f) = C3(:,:,f) + gamma_ivar3(:,:,f).*A3(1,1,ch,f).*conv2(C2nLReLU(:,:,ch),w3(:,:,ch,f),'same');
        end
%         C3(:,:,f) = C3(:,:,f);% + b3(:,:,f); % in conv layer bias=0
    end
    % surf(C2(:,:,7)); view(0,90);
    %% 3 Stride 2x2
    C3s = C3(1:2:end,1:2:end,:);
    %% 3 Batch norm.
    C3n = C3s + net.Layers(9).Offset - net.Layers(9).TrainedMean.*gamma_ivar3;
    %% 3 ReLU
    C3nLReLU = max(0,C3n) + min(0,C3n)*net.Layers(10).Scale; % LeakyReLU pos + neg*scale
    %% --------------------------------------------------------------------- %%
    %% FC1
    fc1in = C3nLReLU(:)';
    fc1out = repelem(fc1in,net.Layers(11).OutputSize,1).*net.Layers(11).Weights;
    fc1out = sum(fc1out,2) + net.Layers(11).Bias;

    %% FC2
    fc2in = fc1out';
    fc2out = repelem(fc2in,net.Layers(12).OutputSize,1).*net.Layers(12).Weights;
    fc2out = sum(fc2out,2) + net.Layers(12).Bias;
    y(n,:) = fc2out';
    disp(['n=' num2str(n)])
end

% YPredicted2 = y;