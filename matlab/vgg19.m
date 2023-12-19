clc; close all; clear all;
%% Create dataset
sizeB=[224 224 3];
NT= 10; % Number of train images
NV= 10; % Number of validation images
Nout = 1000; 
XTrain=rand(sizeB(1),sizeB(2),3,NT);
YTrain=rand(NT,Nout); % Targer vector
XValidation=rand(sizeB(1),sizeB(2),3,NV);
YValidation=rand(NV,Nout); % Targer vector

%% Set layers in regression CNN
layers = [
    imageInputLayer(sizeB,'Normalization','none') % [100 100 3]
% 1
    convolution2dLayer(3,64,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
    batchNormalizationLayer
% 2
    convolution2dLayer(3,64,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
    batchNormalizationLayer
    maxPooling2dLayer(2,'stride',2)
% 3
    convolution2dLayer(3,128,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
    batchNormalizationLayer
% 4
    convolution2dLayer(3,128,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
    batchNormalizationLayer
    maxPooling2dLayer(2,'stride',2)
% 5
    convolution2dLayer(3,256,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
    batchNormalizationLayer
% 6
    convolution2dLayer(3,256,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
    batchNormalizationLayer
% 7
    convolution2dLayer(3,256,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
    batchNormalizationLayer
% 8
    convolution2dLayer(3,256,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
    batchNormalizationLayer
    maxPooling2dLayer(2,'stride',2)
% 9
    convolution2dLayer(3,512,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
    batchNormalizationLayer
% 10
    convolution2dLayer(3,512,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
    batchNormalizationLayer
% 11
    convolution2dLayer(3,512,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
    batchNormalizationLayer
% 12
    convolution2dLayer(3,512,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
    batchNormalizationLayer
    maxPooling2dLayer(2,'stride',2)
% 13
    convolution2dLayer(3,512,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
    batchNormalizationLayer
% 14
    convolution2dLayer(3,512,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
    batchNormalizationLayer
% 15
    convolution2dLayer(3,512,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
    batchNormalizationLayer
% 16
    convolution2dLayer(3,512,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
    batchNormalizationLayer
    maxPooling2dLayer(2,'stride',2)
% 17
    fullyConnectedLayer(4096,'WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
% 18
%     fullyConnectedLayer(4096,'WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
% 19
    fullyConnectedLayer(1000,'WeightLearnRateFactor',1,'BiasLearnRateFactor',1) % 4x4 ceils % fullyConnectedLayer(4) % 1 ceil
    regressionLayer];

%     convolution2dLayer(3,64,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
%     batchNormalizationLayer
%     reluLayer%leakyReluLayer(2^-6) % ~0.016
%     maxPooling2dLayer(2,'stride',2)

%     softmaxLayer;
%     classificationLayer;]

%% Set options and train golden
options = set_net_options(100,1000,0.00002,'no',XValidation,YValidation);
net = trainNetwork(XTrain,YTrain,layers,options); % layers or net.Layers

%% Binarize weights
% net_gold = net;                     % save gold net
% net = bin_conv_weights(net);
% layers = net.Layers;

%% Set options and train again CNN, but not conv layer
% options2 = set_net_options(100,1000,0.00002,'no',XValidation,YValidation);
% net = trainNetwork(XTrain,YTrain,layers,options2); % layers or net.Layers
