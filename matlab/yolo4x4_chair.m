clc; close all; clear all;
% Train cnn and compare 'YPredicted' with 'YPredicted2' produced by 'my_predict.m'
%% Create dataset
B = imread('./img/img1.png');
B = downsample2x(B); B = downsample2x(B); ds = 4;
sizeB=size(B);
NT= 10; % Number of train images
NV= NT; % Number of validation images
my_NV = NV;
Grid=4;% 4x4
IL = sizeB(1); % Image len

%% Prepare dataset
[XTrain,YTrain,XValidation,YValidation,XTest] = prepare_dataset('./img',10,ds);

%% Regression CNN
%% set layers
layers = [
    imageInputLayer(sizeB,'Normalization','none') % [100 100 3]

    convolution2dLayer(3,16,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
    batchNormalizationLayer
    reluLayer%leakyReluLayer(2^-6) % ~0.016
    maxPooling2dLayer(2,'stride',2)

    convolution2dLayer(3,32,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
    batchNormalizationLayer
    reluLayer%leakyReluLayer(2^-6) % ~0.016
    maxPooling2dLayer(2,'stride',2)

%     convolution2dLayer(3,64,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
%     batchNormalizationLayer
%     reluLayer%leakyReluLayer(2^-6) % ~0.016
%     maxPooling2dLayer(2,'stride',2)
%     
%     convolution2dLayer(3,64,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
%     batchNormalizationLayer
%     reluLayer%leakyReluLayer(2^-6) % ~0.016
%     maxPooling2dLayer(2,'stride',2)
%     
%     convolution2dLayer(3,8,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
%     batchNormalizationLayer
%     reluLayer%leakyReluLayer(2^-6) % ~0.016
%     maxPooling2dLayer(2,'stride',2)
% 
    fullyConnectedLayer(128,'WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
    fullyConnectedLayer(80,'WeightLearnRateFactor',1,'BiasLearnRateFactor',1) % 4x4 ceils % fullyConnectedLayer(4) % 1 ceil
    regressionLayer];
%     softmaxLayer;
%     classificationLayer;]

%% Reduce amplitude
% XValidation = XValidation*4;
% XTrain = XTrain*4;

%% Set options and train golden
options = set_net_options(10,100,0.00002,'no',XValidation,YValidation);
net = trainNetwork(XValidation,YValidation,layers,options); % layers or net.Layers % XTrain,YTrain

%% Binarize weights
net_gold = net;                     % save gold net
net = bin_conv_weights(net);
layers = net.Layers;

%% Set options and train again CNN, but not conv layer
options2 = set_net_options(10,100,0.00002,'no',XValidation,YValidation);
net = trainNetwork(XTrain,YTrain,layers,options2); % layers or net.Layers % XTrain,YTrain

%% Test CNN
% load ./nets/net_checkpoint__78100__2019_03_21__01_06_29
% YPredicted_gold = predict(net_gold,XValidation);
YPredicted = predict(net,XTest(:,:,:,1:my_NV));
% YPredicted = my_predict(net,XValidation(:,:,:,1:my_NV));
% YPredicted2 = my2_predict(net,XValidation(:,:,:,1:my_NV));
% [YPredicted3,ka1,be1,ka2,be2,ka3,be3,C1,C2,C3] = my3_predict(net,XValidation(:,:,:,1:my_NV));

%% Plot few bounding boxes
overlapRatio = 0; k = 0;
for i=1:NV % my_NV % NV
    figure(i); imshow(uint8(XValidation(:,:,:,i)*255)); hold on;
    for y=1:Grid
       for x=1:Grid
           p_i = 20*(y-1)+5*(x-1)+1; % prob index
           % Validation
           x_i = (IL/Grid)*(YValidation(i,p_i+1)+x-1)-(IL/Grid)*YValidation(i,p_i+4)/2;
           y_i = (IL/Grid)*(YValidation(i,p_i+2)+y-1)-(IL/Grid)*YValidation(i,p_i+3)/2;
           h_i = (IL/Grid)*YValidation(i,p_i+3);
           w_i = (IL/Grid)*YValidation(i,p_i+4);
           bboxA = [x_i y_i h_i w_i];
           if (YValidation(i,p_i)>0.5 && bboxA(3)>0 && bboxA(4)>0) % probability = 1
               rectangle('Position',[x_i,y_i,w_i,h_i],'EdgeColor',[1 1 0]);
           end
           % Predicted
           x_i = (IL/Grid)*(YPredicted(i,p_i+1)+x-1)-(IL/Grid)*YPredicted(i,p_i+4)/2;
           y_i = (IL/Grid)*(YPredicted(i,p_i+2)+y-1)-(IL/Grid)*YPredicted(i,p_i+3)/2;
           h_i = (IL/Grid)*YPredicted(i,p_i+3);
           w_i = (IL/Grid)*YPredicted(i,p_i+4);
           bboxB = [x_i y_i h_i w_i];
           if (YPredicted(i,p_i)>0.5 && bboxB(3)>0 && bboxB(4)>0) % probability > 0.5
               rectangle('Position',[x_i,y_i,w_i,h_i],'EdgeColor',[1 0 0]);
%                overlapRatio = overlapRatio + bboxOverlapRatio(bboxA,bboxB);
               k=k+1;
           end
       end
    end
%     rectangle('Position',[128*YValidation(i,1)-128*YValidation(i,4)/2,...
%                           128*YValidation(i,2)-128*YValidation(i,3)/2,...
%                           128*YValidation(i,3),128*YValidation(i,4)],'EdgeColor',[1 1 0]); hold on;
%     rectangle('Position',[128*YPredicted(i,1)-128*YPredicted(i,4)/2,...
%                           128*YPredicted(i,2)-128*YPredicted(i,3)/2,...
%                           128*YPredicted(i,3),128*YPredicted(i,4)],'EdgeColor',[1 0 0]);
    pause(0.1);
end
% overlapRatio = overlapRatio/k