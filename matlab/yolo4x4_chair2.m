clc; close all; clear all;
% Train cnn and compare 'YPredicted' with 'YPredicted2' produced by 'my_predict.m'
%% Create dataset
B = imread('./img/bookcase/bookcase1.png'); % Pagal nuotraukos dydi paskaiciuojama iejimo sluoksnio raiska
ds = 2; % Downsample rate: 1, 2 or 4
switch ds
    case 4
        B = downsample2x(B); B = downsample2x(B); sizeB=size(B); disp(['Image size=', num2str(sizeB)]);
    case 2
        B = downsample2x(B); sizeB=size(B); disp(['Image size=', num2str(sizeB)]);
    otherwise
        sizeB=size(B); disp(['Image size=' num2str(sizeB)]);
end
NT= 5; % Number of train images
NV= NT; % Number of validation images
Grid=4;% 4x4
IL = sizeB(1); % Image len
Nout = 8; % 5*Grid^2 = 5*16 = 80 % turi buti kartotinis 2x

%% Prepare dataset
[XTrain,YTrain,XValidation,YValidation,XTest] = prepare_dataset2('./img',NT,Nout,ds);

%% Regression CNN
%% set layers
layers = [
    imageInputLayer(sizeB,'Normalization','none') % [100 100 3]

    convolution2dLayer(3,16,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2,'stride',2)

    convolution2dLayer(3,32,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2,'stride',2)

    convolution2dLayer(3,64,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2,'stride',2)

%     convolution2dLayer(3,64,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
%     batchNormalizationLayer
%     reluLayer%leakyReluLayer(2^-6) % ~0.016
%     maxPooling2dLayer(2,'stride',2)

    fullyConnectedLayer(128,'WeightLearnRateFactor',1,'BiasLearnRateFactor',1) % turi buti kartotinis 2x
    fullyConnectedLayer(Nout,'WeightLearnRateFactor',1,'BiasLearnRateFactor',1) % 4x4 ceils % fullyConnectedLayer(4) % 1 ceil
    regressionLayer];
%     softmaxLayer;
%     classificationLayer;]

%% Reduce amplitude
% XValidation = XValidation*4;
% XTrain = XTrain*4;

%% Set options and train golden
MiniBatchSize = 10;
MaxEpochs = 1; % 1000
options = set_net_options(MiniBatchSize,MaxEpochs,0.00002,'no',XValidation,YValidation);
net = trainNetwork(XValidation,YValidation,layers,options); % layers or net.Layers % XTrain,YTrain

%% Binarize weights
net_gold = net;                     % save gold net
net = bin_conv_weights(net);
layers = net.Layers;

%% Set options and train again CNN, but not conv layer
options2 = set_net_options(MiniBatchSize,MaxEpochs,0.00002,'no',XValidation,YValidation);
net = trainNetwork(XTrain,YTrain,layers,options2); % layers or net.Layers % XTrain,YTrain

%% Test CNN
% load ./nets/net_checkpoint__78100__2019_03_21__01_06_29
% YPredicted_gold = predict(net_gold,XValidation);
YPredicted = predict(net,XTest(:,:,:,:));
% YPredicted = my_predict(net,XValidation(:,:,:,1:my_NV));
% YPredicted2 = my2_predict(net,XValidation(:,:,:,1:my_NV));
% [YPredicted3,ka1,be1,ka2,be2,ka3,be3,C1,C2,C3] = my3_predict(net,XValidation(:,:,:,1:my_NV));

%% Plot classes
% for c=1:5 % classes
%     for i=1:NV % my_NV % NV
% %         figure(i); imshow(uint8(XValidation(:,:,:,i)*255)); hold on;
%         m=i+NV*(c-1);
%         [M,C] = max(YPredicted(m,:));
%         switch C
%             case 1
%                 class_name = '/bookcase';
%             case 2
%                 class_name = '/chair';
%             case 3
%                 class_name = '/door';
%             case 4
%                 class_name = '/table';
%             case 5
%                 class_name = '/window';
%             otherwise
%                 class_name = '/other';
%         end
%         disp(class_name)
%         pause(0.1);
%     end
% end