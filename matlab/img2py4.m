close all;
idx = 1;
% Img = XTest(:,:,:,idx);
Img = imread('C:\CNN_VHDL\python\image128x32.bmp');
% imwrite(uint8(Img*256),'C:\Users\koefi\Dropbox\tmp\CNN_VHDL\python\image26.bmp'); % FPGA input image
%% Predict
YPredicted0 = predict(net,Img)';
% YPredicted0 = classify(net,Img)';


%% Compare with FPGA
FC2_FPGA = csvread('C:\CNN_VHDL\python\FC2_FPGA.csv');
FC2_FPGA = FC2_FPGA(1:2); YPredicted0 = YPredicted0(1:2);
figure(16); % plot(YPredicted0,'b'); hold on; %title('FPGA FC2');
% plot(fc2out,'g'); hold on; % FixedMatlab
% plot(FC2,'g'); hold on; % Float2
plot(FC2_FPGA,'r--');
bar([1 2],[YPredicted0'; FC2_FPGA']);

legend Float FixedFPGA; grid on; ylabel('Amplitude'); xlabel('Neurono indeksas'); hold off;
Mdiff=mean(abs(FC2_FPGA-YPredicted0));
disp(['Mean error ', num2str(Mdiff)]);

%% Disp class
% img_path = cat(2,'./img/image',num2str(idx)); img_path = cat(2,img_path,'.png'); I = imread(img_path);
% figure(10); imshow(I);
% [M,C] = max(YPredicted0);
% switch C
%     case 1
%         class_name = 'bookcase';
%     case 2
%         class_name = 'chair';
%     case 3
%         class_name = 'door';
%     case 4
%         class_name = 'table';
%     case 5
%         class_name = 'window';
%     otherwise
%         class_name = 'other';
% end
% disp(['Matlab: ' class_name]);
% [M,C] = max(FC2_FPGA);
% switch C
%     case 1
%         class_name = 'bookcase';
%     case 2
%         class_name = 'chair';
%     case 3
%         class_name = 'door';
%     case 4
%         class_name = 'table';
%     case 5
%         class_name = 'window';
%     otherwise
%         class_name = 'other';
% end
% disp(['FPGA: ' class_name]);