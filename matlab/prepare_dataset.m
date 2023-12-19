function [XT,YT,XV,YV,Xt] = prepare_dataset(img_dir,N,ds)
% N Number of train images
% ds = downsample rate

%% Create dataset
Grid=4;% 4x4
IL = 512/ds; % Image len
XT=zeros(IL,IL,3,N);
YT=zeros(N,5*Grid^2); % Targer vector
XV=zeros(IL,IL,3,N);
YV=zeros(N,5*Grid^2); % Targer vector

xy = [139 168 440 274;...
       63 200 400 327;...
      147  36 500 200;...
      189  56 507 287;...
      109 139 327 263;...
      127  82 388 200;...
      106 156 453 306;...
        0   0   0   0;...
        0   0   0   0;...
        0   0   0   0]/ds;
% bx by bh bw [in pixels]
bbox=zeros(N,5);
for n=1:7
    bx = round(mean([xy(n,1) xy(n,3)]));
    by = round(mean([xy(n,2) xy(n,4)]));
    bh = abs(xy(n,2)-xy(n,4));
    bw = abs(xy(n,1)-xy(n,3));
    bbox(n,:) = [1 bx by bh bw];
end
% bbox
%% Train dataset
for n=1:N
%     ground_path = cat(2,'./ground/ground100-',num2str(floor(20*rand)+1));
    img_path = img_dir;
    img_path = cat(2,img_path,'/img');
    img_path = cat(2,img_path,num2str(n));
    img_path = cat(2,img_path,'.png');
    I = imread(img_path); 
    I = downsample2x(I); I = downsample2x(I);
    sizeI=size(I);
%     figure(n); imshow(I); title('Train image');
    %% Get bounding box
    bx=bbox(n,2); % center of bee by x
    by=bbox(n,3); % center of bee by y
    bh=bbox(n,4);
    bw=bbox(n,5);
    figure(4); imshow(uint8(I)); title('Validation image'); hold on;
    rectangle('Position',[bx-bw/2,by-bh/2,bw,bh],'EdgeColor',[1 1 0]); 
    hold off; pause(0.1);
    %% Target vector
    XT(:,:,:,n) = double(I)/255;
    bx_c = ceil(bx*Grid/sizeI(2)); % object center ceil x index, [1,2,3,4]
    by_c = ceil(by*Grid/sizeI(1)); % object center ceil y index, [1,2,3,4]
    bx_n = (bx-(IL/Grid)*(bx_c-1))*Grid/sizeI(2); % bx norm to ceil size, [0-1]
    by_n = (by-(IL/Grid)*(by_c-1))*Grid/sizeI(1); % bx norm to ceil size, [0-1]
    bh_n = bh*Grid/sizeI(1); % bh norm to ceil hight, [0-4]
    bw_n = bw*Grid/sizeI(2); % bw norm to ceil width, [0-4]
    for y=1:Grid
       for x=1:Grid
           range = [20*(y-1)+5*(x-1)+1:20*(y-1)+5*x];
           if (y==by_c && x==bx_c) %if bbox(n,1)==1 % jei yra objektas
               YT(n,range) = [1 bx_n by_n bh_n bw_n]; % with object
%                disp(['n=' num2str(n) ' y=' num2str(y) ' x=' num2str(x)]);
           else
               YT(n,range) = [0 0 0 0 0]; % no object
           end
       end
    end
end
%% Validation dataset
XV = XT; YV = YT;
Xt = XT;
end
