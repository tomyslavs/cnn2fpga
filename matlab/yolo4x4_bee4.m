clc; close all; clear all;
% Train cnn and compare 'YPredicted' with 'YPredicted2' produced by 'my_predict.m'
%% Create dataset
B = imread('./bee/star128.png'); % bee100.png star100.png
sizeB=size(B);
NT= 10; % Number of train images
NV= NT; % Number of validation images
my_NV = NV;
Grid=4;% 4x4
IL = 128; % Image len
XTrain=zeros(IL,IL,3,NT);
YTrain=zeros(NT,5*Grid^2); % Targer vector
XValidation=zeros(IL,IL,3,NV);
YValidation=zeros(NV,5*Grid^2); % Targer vector
%% Train dataset
for n=1:NT
%     ground_path = cat(2,'./ground/ground100-',num2str(floor(20*rand)+1));
    ground_path = './ground/ground128';
    ground_path = cat(2,ground_path,'.png');
%     ground_path = './ground/ground100-0.png';mano
    I = imread(ground_path); sizeI=size(I);
    Bs = imresize(B, 0.5+0.1*rand); % scale in 30-70% range
    ang=0;%rand*360;
    Br = imrotate(Bs,ang);
    sizeBr = size(Br);
    % ins_ym = sizeI(1)-sizeBr(1); % max bee shift by y
    % ins_xm = sizeI(2)-sizeBr(2); % max bee shift by x
    % ins_coord=round([rand*ins_ym rand*ins_xm]); % insertion coordinates
    ins_coord=round([rand*sizeI(1)-sizeBr(1)/2 rand*sizeI(2)-sizeBr(2)/2]); % insertion coordinates
    for y=1:sizeBr(1)
        for x=1:sizeBr(2)
            if ((ins_coord(1)+y>0 && ins_coord(2)+x>0) && (ins_coord(1)+y<=sizeI(1) && ins_coord(2)+x<=sizeI(2)) )
                if (Br(y,x,1)~=0) && (Br(y,x,2)~=0) && (Br(y,x,3)~=0)
                    I(ins_coord(1)+y,ins_coord(2)+x,:)=Br(y,x,:);
                end
            end
        end
    end
%     figure(n); imshow(I); title('Train image');
    %% Get bounding box
    bx=ins_coord(2)+sizeBr(2)*0.5; % center of bee by x
    by=ins_coord(1)+sizeBr(1)*0.5; % center of bee by y
    bh=sizeBr(1)*(0.5+0.2*abs(cos(4*pi*ang/360)));
    bw=sizeBr(2)*(0.5+0.2*abs(cos(4*pi*ang/360)));
%     rectangle('Position',[bx-bw/2,by-bh/2,bw,bh],'EdgeColor',[1 1 0]); pause(0.2);
    %% Target vector
%     y1 = [1 bx by bh bw]; % targer with object
%     y0 = [0 0 0 0 0]; % target w/o object
    XTrain(:,:,:,n) = double(I)/255;
%     YTrain(n,:) = [bx/sizeB(2) by/sizeB(1) bh/sizeB(1) bw/sizeB(2)]; % when Image = single ceil
    bx_c = ceil(bx*Grid/sizeI(2)); % object center ceil x index, [1,2,3,4]
    by_c = ceil(by*Grid/sizeI(1)); % object center ceil y index, [1,2,3,4]
    bx_n = (bx-32*(bx_c-1))*Grid/sizeI(2); % bx norm to ceil size, [0-1]
    by_n = (by-32*(by_c-1))*Grid/sizeI(1); % bx norm to ceil size, [0-1]
    bh_n = bh*Grid/sizeI(1); % bh norm to ceil hight, [0-4]
    bw_n = bw*Grid/sizeI(2); % bw norm to ceil width, [0-4]
    for y=1:Grid
       for x=1:Grid
           range = [20*(y-1)+5*(x-1)+1:20*(y-1)+5*x];
           if y==by_c && x==bx_c
               YTrain(n,range) = [1 bx_n by_n bh_n bw_n]; % with object
%                disp(['n=' num2str(n) ' y=' num2str(y) ' x=' num2str(x)]);
           else
               YTrain(n,range) = [0 0 0 0 0]; % no object
           end
       end
    end
end
%% Validation dataset
for n=1:NV
%     ground_path = cat(2,'./ground/ground100-',num2str(floor(20*rand)+1));
    ground_path = './ground/ground128';
    ground_path = cat(2,ground_path,'.png');
%     ground_path = './ground/ground100-0.png';
    I = imread(ground_path); sizeI=size(I);
    Bs = imresize(B, 0.5+0.1*rand); % scale in 20-70% range
    ang=0;%rand*360;
    Br = imrotate(Bs,ang);
    sizeBr = size(Br);
    % ins_ym = sizeI(1)-sizeBr(1); % max bee shift by y
    % ins_xm = sizeI(2)-sizeBr(2); % max bee shift by x
    % ins_coord=round([rand*ins_ym rand*ins_xm]); % insertion coordinates
    ins_coord=round([rand*sizeI(1)-sizeBr(1)/2 rand*sizeI(2)-sizeBr(2)/2]); % insertion coordinates
    for y=1:sizeBr(1)
        for x=1:sizeBr(2)
            if ((ins_coord(1)+y>0 && ins_coord(2)+x>0) && (ins_coord(1)+y<=sizeI(1) && ins_coord(2)+x<=sizeI(2)) )
                if (Br(y,x,1)~=0) && (Br(y,x,2)~=0) && (Br(y,x,3)~=0)
                    I(ins_coord(1)+y,ins_coord(2)+x,:)=Br(y,x,:);
                end
            end
        end
    end
    %% Get bounding box
    bx=ins_coord(2)+sizeBr(2)*0.5; % center of bee by x
    by=ins_coord(1)+sizeBr(1)*0.5; % center of bee by y
    bh=sizeBr(1)*(0.5+0.2*abs(cos(4*pi*ang/360)));
    bw=sizeBr(2)*(0.5+0.2*abs(cos(4*pi*ang/360)));
%     figure(4); imshow(I); title('Validation image'); hold on;
%     rectangle('Position',[bx-bw/2,by-bh/2,bw,bh],'EdgeColor',[1 1 0]); 
%     hold off; pause(0.2);
    %% Target vector
%     y1 = [1 bx by bh bw]; % targer with object
%     y0 = [0 0 0 0 0]; % target w/o object
    XValidation(:,:,:,n) = double(I)/256;
%     YValidation(n,:) = [bx/sizeB(2) by/sizeB(1) bh/sizeB(1) bw/sizeB(2)];
    bx_c = ceil(bx*Grid/sizeI(2)); % object center ceil x index, [1,2,3,4]
    by_c = ceil(by*Grid/sizeI(1)); % object center ceil y index, [1,2,3,4]
    bx_n = (bx-32*(bx_c-1))*Grid/sizeI(2); % bx norm to ceil size, [0-1]
    by_n = (by-32*(by_c-1))*Grid/sizeI(1); % bx norm to ceil size, [0-1]
    bh_n = bh*Grid/sizeI(1); % bh norm to ceil hight, [0-4]
    bw_n = bw*Grid/sizeI(2); % bw norm to ceil width, [0-4]
    for y=1:Grid
       for x=1:Grid
           range = [20*(y-1)+5*(x-1)+1:20*(y-1)+5*x];
           if (y==by_c && x==bx_c)
               YValidation(n,range) = [1 bx_n by_n bh_n bw_n]; % with object
           else
               YValidation(n,range) = [0 0 0 0 0]; % no object
           end
       end
    end
end
%% Regression CNN
%% set layers
layers = [
    imageInputLayer(sizeB,'Normalization','none') % [100 100 3]

    convolution2dLayer(3,32,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
    batchNormalizationLayer
    reluLayer%leakyReluLayer(2^-6) % ~0.016
    maxPooling2dLayer(2,'stride',2)

    convolution2dLayer(3,64,'Padding','same','WeightLearnRateFactor',1,'BiasLearnRateFactor',1)
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
options = set_net_options(100,1000,0.00002,'no',XValidation,YValidation);
net = trainNetwork(XTrain,YTrain,layers,options); % layers or net.Layers

%% Binarize weights
net_gold = net;                     % save gold net
net = bin_conv_weights(net);
layers = net.Layers;

%% Set options and train again CNN, but not conv layer
options2 = set_net_options(100,1000,0.00002,'no',XValidation,YValidation);
net = trainNetwork(XTrain,YTrain,layers,options2); % layers or net.Layers

%% Test CNN
% load ./nets/net_checkpoint__78100__2019_03_21__01_06_29
% YPredicted_gold = predict(net_gold,XValidation);
YPredicted = predict(net,XValidation(:,:,:,1:my_NV));
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
           x_i = 32*(YValidation(i,p_i+1)+x-1)-32*YValidation(i,p_i+4)/2;
           y_i = 32*(YValidation(i,p_i+2)+y-1)-32*YValidation(i,p_i+3)/2;
           h_i = 32*YValidation(i,p_i+3);
           w_i = 32*YValidation(i,p_i+4);
           bboxA = [x_i y_i h_i w_i];
           if (YValidation(i,p_i)>0.5 && bboxA(3)>0 && bboxA(4)>0) % probability = 1
               rectangle('Position',[x_i,y_i,h_i,w_i],'EdgeColor',[1 1 0]);
           end
           % Predicted
           x_i = 32*(YPredicted(i,p_i+1)+x-1)-32*YPredicted(i,p_i+4)/2;
           y_i = 32*(YPredicted(i,p_i+2)+y-1)-32*YPredicted(i,p_i+3)/2;
           h_i = 32*YPredicted(i,p_i+3);
           w_i = 32*YPredicted(i,p_i+4);
           bboxB = [x_i y_i h_i w_i];
           if (YPredicted(i,p_i)>0.5 && bboxB(3)>0 && bboxB(4)>0) % probability > 0.5
               rectangle('Position',[x_i,y_i,h_i,w_i],'EdgeColor',[1 0 0]);
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