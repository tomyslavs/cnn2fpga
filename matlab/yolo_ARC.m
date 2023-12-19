clc; close all; clear all;
% Train cnn and compare 'YPredicted' with 'YPredicted2' produced by 'my_predict.m'
%% Create dataset
% B = imread('./fir/frameIndex_0_2019-12-28_16.04.15.jpg'); % Pagal nuotraukos dydi paskaiciuojama iejimo sluoksnio raiska
% ds = 2; % Downsample rate: 1, 2 or 4
% switch ds
%     case 4
%         B = downsample2x(B); B = downsample2x(B); sizeB=size(B); disp(['Image size=', num2str(sizeB)]);
%     case 2
%         B = downsample2x(B); sizeB=size(B); disp(['Image size=', num2str(sizeB)]);
%     otherwise
%         sizeB=size(B); disp(['Image size=' num2str(sizeB)]);
% end
% NT= 5; % Number of train images
% NV= NT; % Number of validation images

%% Prepare dataset './fir_pedestrians_only'
folder = './2019-12-28_16.04.15_done_b'; % './fir' '2019-12-28_16.04.15_done_b' '2019-12-28_15.46.42' '2019-12-20_22.53.32' '2019-12-20_22.43.45_done_b'
[XTrain,YTrain,XValidation,YValidation,XTest,YTest,N,sizeI,Gridx,Gridy,Anchors,ILx,ILy,stepx,stepy,Nout,ds,Anchors_gt,YT_gt] = prepare_dataset_ARC(folder);

%% Regression CNN, set layers
layers = [
    imageInputLayer(sizeI,'Normalization','none') % [100 100 3]

    convolution2dLayer(3,16,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2,'stride',2)

    convolution2dLayer(3,24,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2,'stride',2)

%     convolution2dLayer(3,32,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
%     batchNormalizationLayer
%     reluLayer
%     maxPooling2dLayer(2,'stride',2)

%     convolution2dLayer(3,64,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
%     batchNormalizationLayer
%     reluLayer%leakyReluLayer(2^-6) % ~0.016
%     maxPooling2dLayer(2,'stride',2)

    fullyConnectedLayer(1024,'WeightLearnRateFactor',1,'BiasLearnRateFactor',1) % turi buti kartotinis 2x
    fullyConnectedLayer(Nout,'WeightLearnRateFactor',1,'BiasLearnRateFactor',1) % 4x4 ceils % fullyConnectedLayer(4) % 1 ceil
    regressionLayer];
%     softmaxLayer;
%     classificationLayer;]

%% Reduce amplitude
% XValidation = XValidation*4;
% XTrain = XTrain*4;

%% Set options and train golden
MiniBatchSize = 20;
MaxEpochs = 1000;
options = set_net_options(MiniBatchSize,MaxEpochs,0.00002,'no',XValidation,YValidation);
net = trainNetwork(XTrain,YTrain,layers,options); % layers or net.Layers % XTrain,YTrain

% %% Binarize weights
% net_gold = net;                     % save gold net
% net = bin_conv_weights(net);
% layers = net.Layers;
% 
% %% Set options and train again CNN, but not conv layer
% options2 = set_net_options(MiniBatchSize,MaxEpochs,0.00002,'no',XValidation,YValidation);
% net = trainNetwork(XTrain,YTrain,layers,options2); % layers or net.Layers % XTrain,YTrain
% 
%% Test CNN
% load ./nets/net_checkpoint__78100__2019_03_21__01_06_29
% YPredicted_gold = predict(net_gold,XValidation);
% YPredicted = predict(net,XTest(:,:,:,:));
[Precision,Recall,IoU_avg] = test_ARC(net,XTest,YTest,N,sizeI,Gridx,Gridy,Anchors,ILx,ILy,stepx,stepy,Nout,ds,Anchors_gt,YT_gt);






