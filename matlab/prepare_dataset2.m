function [XT,YT,XV,YV,Xt] = prepare_dataset2(img_dir,N,Nout,ds)
% N Number of train images
% ds = downsample rate
% N=5; img_dir='./img'; ds=4;
% Nout - isejimu skaicius
%% Create dataset
Grid=4;% 4x4
IL = 512/ds; % Image len
XT=zeros(IL,IL,3,N);
YT=zeros(N,Nout); % YT=zeros(N,5*Grid^2); % Targer vector
XV=zeros(IL,IL,3,N);
YV=zeros(N,Nout);% YV=zeros(N,5*Grid^2); % Targer vector

%% Train dataset
for c=1:5 % classes
    switch c
        case 1
            class_name = '/bookcase';
        case 2
            class_name = '/chair';
        case 3
            class_name = '/door';
        case 4
            class_name = '/table';
        otherwise
            class_name = '/window';
    end
    disp(class_name);
    for n=1:N
        img_path = img_dir;
        img_path = cat(2,img_path,class_name); img_path = cat(2,img_path,class_name);
        img_path = cat(2,img_path,num2str(n));
        img_path = cat(2,img_path,'.png');
        I = imread(img_path); 
%         I = downsample2x(I); I = downsample2x(I); sizeI=size(I);
        switch ds
            case 4
                I = downsample2x(I); I = downsample2x(I); sizeI=size(I);
            case 2
                I = downsample2x(I); sizeI=size(I);
            otherwise
                sizeI=size(I);
        end
        
    %     figure(n); imshow(I); title('Train image');
        %% Target vector
        m=n+N*(c-1);
        XT(:,:,:,m) = double(I)/255;
        YT(m,c) = 1;
    end
end
%% Validation/Test dataset
XV = XT; YV = YT;
Xt = XT;

% end
