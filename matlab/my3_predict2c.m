function [w1,ka1,be1,ka2,be2,I2,I3,fc1out,fc2out] = my3_predict2c(net,x)
% It works same as 'predict.m', c=ka*x+be to single DSP
% x = XValidation(:,:,:,1:10);
% y = zeros(length(x(1,1,1,:)),net.Layers(7).OutputSize);
PRE = 2^8; % 2^8; % float bits
I1=x(:,:,:,1);%+net.Layers(1).AverageImage; % AverageImage was disabled in train stage
%% --------------------------------------------------------------------- %%
%% 1 Conv + BN
NumCh1=net.Layers(2).NumChannels;
NumF1=net.Layers(2).NumFilters;
A1(1:NumCh1,1:NumF1) = abs(net.Layers(2).Weights(1,1,:,:));
gamma_ivar1(1:NumF1) = net.Layers(3).Scale./sqrt(net.Layers(3).TrainedVariance + net.Layers(3).Epsilon);
ka1=A1.*gamma_ivar1;
be1(1:NumF1)=net.Layers(3).Offset-net.Layers(3).TrainedMean.*net.Layers(3).Scale./sqrt(net.Layers(3).TrainedVariance + net.Layers(3).Epsilon);
w1 = sign(net.Layers(2).Weights);             w1 = rot90(w1,2);
C1 = zeros(net.Layers(1).InputSize(1),net.Layers(1).InputSize(2),NumF1);
for f=1:NumF1           % filter
    for ch=1:NumCh1     % channel
%         C1(:,:,f) = C1(:,:,f) + ka1(ch,f).*conv2(I1(:,:,ch),w1(:,:,ch,f),'same');
        C1(:,:,f) = C1(:,:,f) + (round(PRE*ka1(ch,f))/PRE.*(fix(PRE*conv2(fix(PRE*I1(:,:,ch))/PRE,w1(:,:,ch,f),'same'))/PRE)); 
    end
%     C1(:,:,f) = C1(:,:,f) + be1(f);
    C1(:,:,f) = C1(:,:,f) + round(PRE*be1(f))/PRE;
end
% surf(C1(:,:,7)); view(0,90);

%% 1 ReLU
C1ReLU = C1;
C1ReLU(C1ReLU < 0) = 0; % neg. to zero
% C1nLReLU = max(0,C1n) + min(0,C1n)*net.Layers(4).Scale; % LeakyReLU pos + neg*scale

%% 1 Max Pool
s = size(C1ReLU);
I2 = zeros(s(1)/2,s(2)/2,s(3));
for ch=1:s(3) % loop over channels
    for yy=1:2:s(1) % loop over row
        for xx=1:2:s(2) % loop over col
            if     (C1ReLU(yy,xx,ch)>=C1ReLU(yy,xx+1,ch) && C1ReLU(yy,xx,ch)>=C1ReLU(yy+1,xx,ch) && C1ReLU(yy,xx,ch)>=C1ReLU(yy+1,xx+1,ch))
                I2(1+(yy-1)/2,1+(xx-1)/2,ch)=C1ReLU(yy,xx,ch);
            elseif (C1ReLU(yy,xx+1,ch)>=C1ReLU(yy,xx,ch) && C1ReLU(yy,xx+1,ch)>=C1ReLU(yy+1,xx,ch) && C1ReLU(yy,xx,ch)>=C1ReLU(yy+1,xx+1,ch))
                I2(1+(yy-1)/2,1+(xx-1)/2,ch)=C1ReLU(yy,xx+1,ch);
            elseif (C1ReLU(yy+1,xx,ch)>=C1ReLU(yy,xx,ch) && C1ReLU(yy+1,xx,ch)>=C1ReLU(yy,xx+1,ch) && C1ReLU(yy+1,xx,ch)>=C1ReLU(yy+1,xx+1,ch))
                I2(1+(yy-1)/2,1+(xx-1)/2,ch)=C1ReLU(yy+1,xx,ch);
            elseif (C1ReLU(yy+1,xx+1,ch)>=C1ReLU(yy,xx,ch) && C1ReLU(yy+1,xx+1,ch)>=C1ReLU(yy,xx+1,ch) && C1ReLU(yy+1,xx+1,ch)>=C1ReLU(yy+1,xx,ch))
                I2(1+(yy-1)/2,1+(xx-1)/2,ch)=C1ReLU(yy+1,xx+1,ch);
            end
        end
    end
end
I2 = fix(PRE*I2)/PRE; 
I2size = size(I2);

%% 2 Conv + BN
NumCh2=net.Layers(6).NumChannels;
NumF2=net.Layers(6).NumFilters;
A2(1:NumCh2,1:NumF2) = abs(net.Layers(6).Weights(1,1,:,:));
gamma_ivar2(1:NumF2) = net.Layers(7).Scale./sqrt(net.Layers(7).TrainedVariance + net.Layers(7).Epsilon);
ka2=A2.*gamma_ivar2;
be2(1:NumF2)=net.Layers(7).Offset-net.Layers(7).TrainedMean.*net.Layers(7).Scale./sqrt(net.Layers(7).TrainedVariance + net.Layers(7).Epsilon);
w2 = sign(net.Layers(6).Weights);             w2 = rot90(w2,2);
C2 = zeros(I2size(1),I2size(2),NumF2);
for f=1:NumF2           % filter
    for ch=1:NumCh2     % channel
%         C2(:,:,f) = C2(:,:,f) + ka2(ch,f).*conv2(I2(:,:,ch),w2(:,:,ch,f),'same');
        C2(:,:,f) = C2(:,:,f) + (round(PRE*ka2(ch,f))/PRE.*(fix(PRE*conv2(fix(PRE*I2(:,:,ch))/PRE,w2(:,:,ch,f),'same'))/PRE));
    end
%     C2(:,:,f) = C2(:,:,f) + be2(f);
    C2(:,:,f) = C2(:,:,f) + round(PRE*be2(f))/PRE;
end
% surf(C1(:,:,7)); view(0,90);

%% 2 ReLU
C2ReLU = C2;
C2ReLU(C2ReLU < 0) = 0; % neg. to zero
% C1nLReLU = max(0,C1n) + min(0,C1n)*net.Layers(4).Scale; % LeakyReLU pos + neg*scale

%% 2 Max Pool
s = size(C2ReLU);
I3 = zeros(s(1)/2,s(2)/2,s(3));
for ch=1:s(3) % loop over channels
    for yy=1:2:s(1) % loop over row
        for xx=1:2:s(2) % loop over col
            if     (C2ReLU(yy,xx,ch)>=C2ReLU(yy,xx+1,ch) && C2ReLU(yy,xx,ch)>=C2ReLU(yy+1,xx,ch) && C2ReLU(yy,xx,ch)>=C2ReLU(yy+1,xx+1,ch))
                I3(1+(yy-1)/2,1+(xx-1)/2,ch)=C2ReLU(yy,xx,ch);
            elseif (C2ReLU(yy,xx+1,ch)>=C2ReLU(yy,xx,ch) && C2ReLU(yy,xx+1,ch)>=C2ReLU(yy+1,xx,ch) && C2ReLU(yy,xx,ch)>=C2ReLU(yy+1,xx+1,ch))
                I3(1+(yy-1)/2,1+(xx-1)/2,ch)=C2ReLU(yy,xx+1,ch);
            elseif (C2ReLU(yy+1,xx,ch)>=C2ReLU(yy,xx,ch) && C2ReLU(yy+1,xx,ch)>=C2ReLU(yy,xx+1,ch) && C2ReLU(yy+1,xx,ch)>=C2ReLU(yy+1,xx+1,ch))
                I3(1+(yy-1)/2,1+(xx-1)/2,ch)=C2ReLU(yy+1,xx,ch);
            elseif (C2ReLU(yy+1,xx+1,ch)>=C2ReLU(yy,xx,ch) && C2ReLU(yy+1,xx+1,ch)>=C2ReLU(yy,xx+1,ch) && C2ReLU(yy+1,xx+1,ch)>=C2ReLU(yy+1,xx,ch))
                I3(1+(yy-1)/2,1+(xx-1)/2,ch)=C2ReLU(yy+1,xx+1,ch);
            end
        end
    end
end
% I3 = fix(PRE*I3)/PRE;

%% FC1 - iki cia ok, conv teisingas
% FPGA skaiciuoja x*w poromis ir prideda prie neurono, jei pora uzejimu, tai nuskaito praeita 16b neurono verte ir perraso.
fc1in = I3(:)';
fc1out = repelem(fc1in,net.Layers(10).OutputSize,1).*round(PRE*net.Layers(10).Weights)/PRE;
% fc1out = round(PRE*16*fc1out)/PRE/16; % cia taisyti apvalinima,
fc1out = sum(fc1out,2) + round(PRE*net.Layers(10).Bias)/PRE; 
fc1out = fix(PRE*fc1out)/PRE;
% fc1out = repelem(fc1in,net.Layers(10).OutputSize,1).*net.Layers(10).Weights;
% fc1out = sum(fc1out,2) + net.Layers(10).Bias; 

%% FC2
fc2in = fc1out';
fc2out = repelem(fc2in,net.Layers(11).OutputSize,1).*round(PRE*net.Layers(11).Weights)/PRE;
% fc2out = round(PRE*16*fc2out)/PRE/16; % cia taisyti apvalinima,
fc2out = sum(fc2out,2) + round(PRE*net.Layers(11).Bias)/PRE; 
fc2out = fix(PRE*fc2out)/PRE;
% fc2out = repelem(fc2in,net.Layers(11).OutputSize,1).*net.Layers(11).Weights;
% fc2out = sum(fc2out,2) + net.Layers(11).Bias; 
