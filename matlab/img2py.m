close all;
idx = 1;
Img = XTest(:,:,:,idx);
% imwrite(uint8(Img*256),'C:\Users\koefi\Dropbox\tmp\CNN_VHDL\python\img1.bmp'); % FPGA input image
%% Predict
YPredicted0 = predict(net,Img)';

%% Compare with FPGA
FC2_FPGA = csvread('C:\Users\koefi\Dropbox\tmp\CNN_VHDL\python\FC2_FPGA.csv');
figure(16); plot(YPredicted0,'b'); hold on; %title('FPGA FC2');
% plot(fc2out,'g'); hold on; % FixedMatlab
% plot(FC2,'g'); hold on; % Float2
plot(FC2_FPGA,'r--');
legend Float FixedFPGA; grid on; ylabel('Amplitude'); xlabel('Neurono indeksas'); hold off;
Mdiff=mean(abs(FC2_FPGA-YPredicted0));
disp(['Mean error ', num2str(Mdiff)]);

%% Display markers
img_path = cat(2,'./img/img',num2str(idx)); img_path = cat(2,img_path,'.png'); I = imread(img_path);
figure(10); imshow(I); hold on;
for y=1:Grid
   for x=1:Grid
       p_i = 20*(y-1)+5*(x-1)+1; % prob index
       %% FPGA
       x_i = (ds*IL/Grid)*(FC2_FPGA(p_i+1)+x-1)-(ds*IL/Grid)*FC2_FPGA(p_i+4)/2;
       y_i = (ds*IL/Grid)*(FC2_FPGA(p_i+2)+y-1)-(ds*IL/Grid)*FC2_FPGA(p_i+3)/2;
       h_i = (ds*IL/Grid)*FC2_FPGA(p_i+3);
       w_i = (ds*IL/Grid)*FC2_FPGA(p_i+4);
       bboxA = [x_i y_i h_i w_i];
       if (FC2_FPGA(p_i)>0.5 && bboxA(3)>0 && bboxA(4)>0) % probability = 1
           rectangle('Position',[x_i,y_i,w_i,h_i],'EdgeColor',[1 0 0],'LineWidth',3);
       end
       %% Matlab
       x_i = (ds*IL/Grid)*(YPredicted0(p_i+1)+x-1)-(ds*IL/Grid)*YPredicted0(p_i+4)/2;
       y_i = (ds*IL/Grid)*(YPredicted0(p_i+2)+y-1)-(ds*IL/Grid)*YPredicted0(p_i+3)/2;
       h_i = (ds*IL/Grid)*YPredicted0(p_i+3);
       w_i = (ds*IL/Grid)*YPredicted0(p_i+4);
       bboxB = [x_i y_i h_i w_i];
       if (YPredicted0(p_i)>0.5 && bboxB(3)>0 && bboxB(4)>0) % probability > 0.5
           rectangle('Position',[x_i,y_i,w_i,h_i],'EdgeColor',[0 1 0],'LineWidth',3);
       end
   end
end
hold off;