function [XT,YT,XV,YV,Xt,Yt,N,sizeI,Gridx,Gridy,Anchors,ILx,ILy,stepx,stepy,Nout,ds,Anchors_gt,YT_gt] = prepare_dataset_ARC(img_dir)
        % ClassID
        % 0 Pedestrian
        % 1 Occluded
        % 2 Body-parts
        % 3 Cyclist
        % 4 Motorcyclist
        % 5 Scooterist
        % 6 Unknowns?
        % 7 Baby_carriage
        % 8 Pets_&_Animals

%% read info
dinfo_jpg = dir(cat(2,img_dir,'/*.jpg'));
dinfo_txt = dir(cat(2,img_dir,'/*.txt')); % reikia praleisti pirma 'classes.txt'
N = length(dinfo_jpg); % ilgis pagal nuotrauku skaiciu

%% Set sizes
tik_su_anotacijomis = 1;
disp_on = 0; cnt = 0;
ClassID = [0 1 2 3]; % aptikti tik 'Pedestrian' 'Occluded' 'Body-parts' 'Cyclist' klases
Colors = 1;
ds = 2;
Gridx = 4; Gridy = 3; % 16 12 | 8 6 | 4 3
Anchors = 4;                               Anchors_gt = Anchors * 4;
ILx = 640/ds; ILy = 480/ds; % Image len
stepx = ILx/Gridx; stepy = ILy/Gridy; % 80x80 if Grid 8x6
Nout = Anchors*5*Gridx*Gridy;              Nout_gt = Anchors_gt*5*Gridx*Gridy;
XT=zeros(ILy,ILx,Colors,N);
YT=zeros(N,Nout); % Targer vector
YT_gt=zeros(N,Nout_gt); % Targer vector ground truth, 4x daugiau anchoriu
% XV=zeros(ILy,ILx,Colors,N);
% YV=zeros(N,Nout); % Validation vector
disp(['cell size: ' num2str(stepx) 'x' num2str(stepy)]); % minimal cell size 20x20!

%% Scan through all annotation files
for n=1:N
    if mod(n,500) == 0 % plot kas 100 figure if (n==1 || n<1)
        disp_on = 1;
    else
        disp_on = 0;
    end
    
    %% read annotations
    txt_path = cat(2,img_dir,'/');
    txt_path = cat(2,txt_path,dinfo_txt(n+1).name); % +1 nes reikia praleisti pirma 'classes.txt', +0 jei nera pirmo 'classes.txt'
    fileID = fopen(txt_path,'r');
    formatSpec = '%f';
    A = fscanf(fileID,formatSpec);
    fclose(fileID);
    NA = fix(length(A)/5); % number of annotations in image
    disp(['Img ' num2str(n) ' bboxes ' num2str(NA)]);
    
    
    %% ar yra mus dominancios anotacijos?
    if (tik_su_anotacijomis == 1)
        turime_bent_viena_anotacija = 0;
        for i=1:NA % eik per visas anotacijas
            class = A((i-1)*5+1);
            if (class==ClassID(1) || class==ClassID(2) || class==ClassID(3) || class==ClassID(4)) % jei 'Pedestrian' 'Occluded' 'Body-parts' 'Cyclist'
                turime_bent_viena_anotacija = 1;
            end
        end
    else
        turime_bent_viena_anotacija = 1;
    end
    
    %% read image
    if (turime_bent_viena_anotacija == 1) % jei yra 'pedestrian' anotacija, tada skaityk ta nuotrauka
        cnt = cnt + 1; % skaiciuok, kiek nuotrauku su anotacijomis
        img_path = extractBefore(txt_path,'txt'); % cut 'jpg'
        img_path = cat(2,img_path,'jpg'); % append 'txt'
        I = imread(img_path);
        if (ds==2)
            I = downsample2x(I); % labai uzlaiko!
        elseif (ds==4)
            I = downsample2x(I); I = downsample2x(I); % labai uzlaiko!
        end
        if (Colors==1)
            I = I(:,:,1); % take one layer for grayscale
        end
        sizeI = size(I);
        if (disp_on==1)
            figure(n); imshow(uint8(I)); title(cat(2,'FIR image ',num2str(n))); hold on;
%             imwrite(uint8(I),cat(2,'data',cat(2,num2str(n),'.png')));
            for y=1:Gridy-1
                line([1 ILx],[stepy*y stepy*y],'color','r')
            end
            for x=1:Gridx-1
                line([stepx*x stepx*x],[1 ILy],'color','r')
            end
        end
    end
    
    %% get bounding boxes
    for i=1:NA % eik per visas anotacijas
        class = A((i-1)*5+1);
        if (class==ClassID(1) || class==ClassID(2) || class==ClassID(3) || class==ClassID(4)) % jei 'Pedestrian', ... klases
            xc = A((i-1)*5+1+1); yc = A((i-1)*5+1+2);
            w  = A((i-1)*5+1+3);  h = A((i-1)*5+1+4);
%             disp(['   xc ' num2str(xc) ' yc ' num2str(yc) ' w ' num2str(w) ' h ' num2str(h)]);
            bx=xc*ILx; by=yc*ILy; bw=w*ILx; bh=h*ILy; % conv to pixels
            if (disp_on==1)
                rectangle('Position',[bx-bw/2,by-bh/2,bw,bh],'EdgeColor',[0 1 0]);
            end
            %% Target vector
            bx_c = ceil(bx*Gridx/ILx); % object center ceil x index, [1,2,3,4,...]
            by_c = ceil(by*Gridy/ILy); % object center ceil y index, [1,2,3,4,...]
            bx_n = (bx-(ILx/Gridx)*(bx_c-1))*Gridx/ILx; % bx norm to ceil size, [0-1]
            by_n = (by-(ILy/Gridy)*(by_c-1))*Gridy/ILy; % bx norm to ceil size, [0-1]
            bw_n = bw*Gridx/ILx; % bw norm to ceil width, [0-4]
            bh_n = bh*Gridy/ILy; % bh norm to ceil hight, [0-4]
            break_true = 0;
            for y=1:Gridy
                for x=1:Gridx
                    for k=1:Anchors_gt
                        p = Gridx*Anchors_gt*5*(y-1)+Anchors_gt*5*(x-1)+5*(k-1)+1; % anchor start idx in target vector
                        range = (p:p+4); % with anchors
                        if (y==by_c && x==bx_c) % jei objektas (x,y) kvadrate
%                             YT_gt(cnt,range) = [1 bx_n by_n bw_n bh_n];
                            if (YT_gt(cnt,p) == 0) % jei target vektoriuje anchor yra laisvas
                                YT_gt(cnt,range) = [1 bx_n by_n bw_n bh_n]; % irasyk bbox i ta anchori target vektoriuje
                                break; % break, nes issaugojai ta anotacija targer vektoriuje
                            end
                        end
                    end
                    for k=1:Anchors
%                         range = [Gridx*5*(y-1)+5*(x-1)+1:Gridx*5*(y-1)+5*x] % without anchors
                        p = Gridx*Anchors*5*(y-1)+Anchors*5*(x-1)+5*(k-1)+1; % anchor start idx in target vector
                        range = (p:p+4); % with anchors
                        if (y==by_c && x==bx_c) % jei objektas (x,y) kvadrate
%                             disp(['y=' num2str(y) ' x=' num2str(x)]);
                            if (YT(cnt,p) == 0) % jei target vektoriuje anchor yra laisvas
                                YT(cnt,range) = [1 bx_n by_n bw_n bh_n]; % irasyk bbox i ta anchori target vektoriuje
%                                 disp(['Saved in Anchor ' num2str(k) ' on idx ' num2str(p)]);
                                break_true = 1;
                                break; % break, nes issaugojai ta anotacija targer vektoriuje
                            end
                        end
                    end
                    if (break_true == 1)
                        break;
                    end
                end
                if (break_true == 1)
                    break;
                end
            end
        end
    end
    if (disp_on==1)
        hold off;
    end
    
    %% save image to train dataset
    if (turime_bent_viena_anotacija == 1) % jei yra 'pedestrian' anotacija, tada skaityk ta nuotrauka
        XT(:,:,:,cnt) = double(I)/255; % Collect images
    end
end
N = cnt;
XT = XT(:,:,:,1:N);
YT = YT(1:N,:);
YT_gt = YT_gt(1:N,:);
%% Validation dataset
XV = XT; YV = YT;
Xt = XT; Yt = YT;
disp(['N ' num2str(N)]);

end
