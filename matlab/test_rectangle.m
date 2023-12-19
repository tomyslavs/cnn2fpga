clc; close all; clear all;
% Train cnn and compare 'YPredicted' with 'YPredicted2' produced by 'my_predict.m'
%% Create dataset
B = imread('./bee/star128.png'); % bee100.png star100.png
sizeB=size(B);
NV=5; % Number of validation images
my_NV = NV;
Grid=4;% 4x4
IL = 128; % Image len
XValidation=zeros(IL,IL,3,NV);
YValidation=zeros(NV,5*Grid^2); % Targer vector
%% Validation dataset
for n=1:NV
    ground_path = './ground/ground128';
    ground_path = cat(2,ground_path,'.png');
    I = imread(ground_path); sizeI=size(I);
    Bs = imresize(B, 0.3+0.4*rand); % scale in 20-70% range
    ang=0;%rand*360;
    Br = imrotate(Bs,ang);
    sizeBr = size(Br);
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
    XValidation(:,:,:,n) = double(I)/255;
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
           if (YValidation(i,p_i)==1) % probability = 1
               rectangle('Position',[x_i,y_i,h_i,w_i],'EdgeColor',[1 1 0]);
           end

       end
    end
%     rectangle('Position',[128*YValidation(i,1)-128*YValidation(i,4)/2,...
%                           128*YValidation(i,2)-128*YValidation(i,3)/2,...
%                           128*YValidation(i,3),128*YValidation(i,4)],'EdgeColor',[1 1 0]); hold on;
end

