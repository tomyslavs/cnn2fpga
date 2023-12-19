function [C1nLReLU,C2nLReLU,C3nLReLU,FC1,FC2] = my_predict_cmp(net,x)
C1nLReLU=0; C2nLReLU=0; C3nLReLU=0; 
% It works same as 'predict.m'
% x = XValidation(:,:,:,1:10);
% y = zeros(length(x(1,1,1,:)),net.Layers(12).OutputSize);
I=x(:,:,:);%-net.Layers(1).AverageImage;
%% --------------------------------------------------------------------- %%
%% 1 Conv.
w1 = net.Layers(2).Weights;             w1 = rot90(w1,2);
b1 = net.Layers(2).Bias;
C1 = zeros(net.Layers(1).InputSize(1),net.Layers(1).InputSize(2),net.Layers(2).NumFilters);
for f=1:net.Layers(2).NumFilters        % filter
    for ch=1:net.Layers(2).NumChannels	% channel
        C1(:,:,f) = C1(:,:,f) + conv2(I(:,:,ch),w1(:,:,ch,f),'same');
    end
    C1(:,:,f) = C1(:,:,f) + b1(:,:,f);
end

% C1(1,1,:)
% surf(C1(:,:,7)); view(0,90);
%% 1 Stride 2x2
C1s = C1;%C1(2:2:end,2:2:end,:);
%% 1 Batch norm.
C1_xmu = C1s - net.Layers(3).TrainedMean;
C1_sqrtvar = sqrt(net.Layers(3).TrainedVariance + net.Layers(3).Epsilon);
C1_ivar = 1./C1_sqrtvar;
C1_xhat = C1_xmu .* C1_ivar;
C1_gammax = net.Layers(3).Scale .* C1_xhat;
C1n = C1_gammax + net.Layers(3).Offset;
%% 1 ReLU
% C1nLReLU = max(0,C1n) + min(0,C1n)*net.Layers(4).Scale; % LeakyReLU pos + neg*scale
C1nLReLU = C1n;
C1nLReLU(C1nLReLU < 0) = 0; % neg. to zero
%% 1 MaxPool
disp(['C1 ' num2str(min(min(min(C1)))) ' ' num2str(max(max(max(C1))))]);
disp(['BN1 ' num2str(min(min(min(C1n)))) ' ' num2str(max(max(max(C1n))))]);
disp(['ReLU1 ' num2str(min(min(min(C1nLReLU)))) ' ' num2str(max(max(max(C1nLReLU))))]);
C1nLReLU = MaxPool(C1nLReLU);
disp(['Pool1 ' num2str(min(min(min(C1nLReLU)))) ' ' num2str(max(max(max(C1nLReLU))))]); disp(' ');
%% --------------------------------------------------------------------- %%
%% 2 Conv.
w2 = net.Layers(6).Weights;             w2 = rot90(w2,2);
b2 = net.Layers(6).Bias;
C2 = zeros(length(C1nLReLU(:,1,1)),length(C1nLReLU(1,:,1)),net.Layers(6).NumFilters);
for f=1:net.Layers(6).NumFilters        % filter
    for ch=1:net.Layers(6).NumChannels	% channel
        C2(:,:,f) = C2(:,:,f) + conv2(C1nLReLU(:,:,ch),w2(:,:,ch,f),'same');
    end
    C2(:,:,f) = C2(:,:,f) + b2(:,:,f);
end
% surf(C2(:,:,7)); view(0,90);
%% 2 Stride 2x2
C2s = C2;%C2(2:2:end,2:2:end,:);
%% 2 Batch norm.
C2_xmu = C2s - net.Layers(7).TrainedMean; 
C2_sqrtvar = sqrt(net.Layers(7).TrainedVariance + net.Layers(7).Epsilon);
C2_ivar = 1./C2_sqrtvar;
C2_xhat = C2_xmu .* C2_ivar;
C2_gammax = net.Layers(7).Scale .* C2_xhat;
C2n = C2_gammax + net.Layers(7).Offset;
%% 2 ReLU
% C2nLReLU = max(0,C2n) + min(0,C2n)*net.Layers(7).Scale; % LeakyReLU pos + neg*scale
C2nLReLU = C2n;
C2nLReLU(C2nLReLU < 0) = 0; % neg. to zero
%% 2 MaxPool
disp(['C2 ' num2str(min(min(min(C2)))) ' ' num2str(max(max(max(C2))))]);
disp(['BN2 ' num2str(min(min(min(C2n)))) ' ' num2str(max(max(max(C2n))))]);
disp(['ReLU2 ' num2str(min(min(min(C2nLReLU)))) ' ' num2str(max(max(max(C2nLReLU))))]);
C2nLReLU = MaxPool(C2nLReLU);
disp(['Pool2 ' num2str(min(min(min(C2nLReLU)))) ' ' num2str(max(max(max(C2nLReLU))))]); disp(' ');
%% --------------------------------------------------------------------- %%
%% 3 Conv.
w3 = net.Layers(10).Weights;             w3 = rot90(w3,2);
b3 = net.Layers(10).Bias;
C3 = zeros(length(C2nLReLU(:,1,1)),length(C2nLReLU(1,:,1)),net.Layers(10).NumFilters);
for f=1:net.Layers(10).NumFilters        % filter
    for ch=1:net.Layers(10).NumChannels	% channel
        C3(:,:,f) = C3(:,:,f) + conv2(C2nLReLU(:,:,ch),w3(:,:,ch,f),'same');
    end
    C3(:,:,f) = C3(:,:,f) + b3(:,:,f);
end
% surf(C2(:,:,7)); view(0,90);
%% 3 Stride 2x2
C3s = C3;%C3(1:2:end,1:2:end,:);
%% 3 Batch norm.
C3_xmu = C3s - net.Layers(11).TrainedMean;
C3_sqrtvar = sqrt(net.Layers(11).TrainedVariance + net.Layers(11).Epsilon);
C3_ivar = 1./C3_sqrtvar;
C3_xhat = C3_xmu .* C3_ivar;
C3_gammax = net.Layers(11).Scale .* C3_xhat;
C3n = C3_gammax + net.Layers(11).Offset;
%% 3 ReLU
% C3nLReLU = max(0,C3n) + min(0,C3n)*net.Layers(10).Scale; % LeakyReLU pos + neg*scale
C3nLReLU = C3n;
C3nLReLU(C3nLReLU < 0) = 0; % neg. to zero
%% 3 MaxPool
disp(['C3 ' num2str(min(min(min(C3)))) ' ' num2str(max(max(max(C3))))]);
disp(['BN3 ' num2str(min(min(min(C3n)))) ' ' num2str(max(max(max(C3n))))]);
disp(['ReLU3 ' num2str(min(min(min(C1nLReLU)))) ' ' num2str(max(max(max(C3nLReLU))))]);
C3nLReLU = MaxPool(C3nLReLU);
disp(['Pool3 ' num2str(min(min(min(C3nLReLU)))) ' ' num2str(max(max(max(C3nLReLU))))]); disp(' ');
%% --------------------------------------------------------------------- %%
%% FC1
fc1in = C3nLReLU(:)';
fc1out = repelem(fc1in,net.Layers(14).OutputSize,1).*net.Layers(14).Weights;
fc1out = sum(fc1out,2) + net.Layers(14).Bias;

%% FC2
fc2in = fc1out';
fc2out = repelem(fc2in,net.Layers(15).OutputSize,1).*net.Layers(15).Weights;
fc2out = sum(fc2out,2) + net.Layers(15).Bias;

%%
FC2 = fc2out;
FC1 = fc1out;

