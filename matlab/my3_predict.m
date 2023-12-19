function [y,ka1,be1,ka2,be2,ka3,be3,C1,C2,C3] = my3_predict(net,x)
% It works same as 'predict.m', c=ka*x+be to single DSP
% x = XValidation(:,:,:,1:10);
y = zeros(length(x(1,1,1,:)),net.Layers(12).OutputSize);
for n=1:length(x(1,1,1,:))
    I=x(:,:,:,n)-net.Layers(1).AverageImage;
    %% --------------------------------------------------------------------- %%
    %% 1 Conv + BN
    NumCh1=net.Layers(2).NumChannels;
    NumF1=net.Layers(2).NumFilters;
    A1(1:NumCh1,1:NumF1) = abs(net.Layers(2).Weights(1,1,:,:));
    gamma_ivar1(1:NumF1) = net.Layers(3).Scale./sqrt(net.Layers(3).TrainedVariance + net.Layers(3).Epsilon);
    ka1=A1.*gamma_ivar1;
    be1(1:NumF1)=net.Layers(3).Offset-net.Layers(3).TrainedMean.*net.Layers(3).Scale./sqrt(net.Layers(3).TrainedVariance + net.Layers(3).Epsilon);
    w1 = sign(net.Layers(2).Weights);             w1 = rot90(w1,2);
    C1 = zeros(net.Layers(1).InputSize(1),net.Layers(1).InputSize(2),NumF1);
    for f=1:NumF1           % filter
        for ch=1:NumCh1     % channel
            C1(:,:,f) = C1(:,:,f) + ka1(ch,f).*conv2(I(:,:,ch),w1(:,:,ch,f),'same');
        end
        C1(:,:,f) = C1(:,:,f) + be1(f);
    end
    % surf(C1(:,:,7)); view(0,90);
    %% 1 Stride 2x2
    C1n = C1(2:2:end,2:2:end,:);
    %% 1 ReLU
    C1nLReLU = max(0,C1n) + min(0,C1n)*net.Layers(4).Scale; % LeakyReLU pos + neg*scale

    %% --------------------------------------------------------------------- %%
    %% 2 Conv.
    NumCh2=net.Layers(5).NumChannels;
    NumF2=net.Layers(5).NumFilters;
    A2(1:NumCh2,1:NumF2) = abs(net.Layers(5).Weights(1,1,:,:));
    gamma_ivar2(1:NumF2) = net.Layers(6).Scale./sqrt(net.Layers(6).TrainedVariance + net.Layers(6).Epsilon);
    ka2=A2.*gamma_ivar2;
    be2(1:NumF2)=net.Layers(6).Offset-net.Layers(6).TrainedMean.*net.Layers(6).Scale./sqrt(net.Layers(6).TrainedVariance + net.Layers(6).Epsilon);
    w2 = sign(net.Layers(5).Weights);             w2 = rot90(w2,2);
    C2 = zeros(length(C1nLReLU(:,1,1)),length(C1nLReLU(1,:,1)),NumF2);
    for f=1:NumF2           % filter
        for ch=1:NumCh2     % channel
            C2(:,:,f) = C2(:,:,f) + ka2(ch,f).*conv2(C1nLReLU(:,:,ch),w2(:,:,ch,f),'same');
        end
        C2(:,:,f) = C2(:,:,f) + be2(f);
    end
    % surf(C2(:,:,7)); view(0,90);
    %% 2 Stride 2x2
    C2n = C2(2:2:end,2:2:end,:);
    %% 2 ReLU
    C2nLReLU = max(0,C2n) + min(0,C2n)*net.Layers(7).Scale; % LeakyReLU pos + neg*scale

    %% --------------------------------------------------------------------- %%
    %% 3 Conv.
    NumCh3=net.Layers(8).NumChannels;
    NumF3=net.Layers(8).NumFilters;
    A3(1:NumCh3,1:NumF3) = abs(net.Layers(8).Weights(1,1,:,:));
    gamma_ivar3(1:NumF3) = net.Layers(9).Scale./sqrt(net.Layers(9).TrainedVariance + net.Layers(9).Epsilon);
    ka3=A3.*gamma_ivar3;
    be3(1:NumF3)=net.Layers(9).Offset-net.Layers(9).TrainedMean.*net.Layers(9).Scale./sqrt(net.Layers(9).TrainedVariance + net.Layers(9).Epsilon);
    w3 = sign(net.Layers(8).Weights);             w3 = rot90(w3,2);
    C3 = zeros(length(C2nLReLU(:,1,1)),length(C2nLReLU(1,:,1)),NumF3);
    for f=1:NumF3           % filter
        for ch=1:NumCh3     % channel
            C3(:,:,f) = C3(:,:,f) + ka3(ch,f).*conv2(C2nLReLU(:,:,ch),w3(:,:,ch,f),'same');
        end
        C3(:,:,f) = C3(:,:,f) + be3(f);
    end
    % surf(C2(:,:,7)); view(0,90);
    %% 3 Stride 2x2
    C3n = C3(1:2:end,1:2:end,:);
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