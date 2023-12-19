function [w1,ka1,be1,C1nLPool,fc1out,fc2out] = my3_predict1c(net,x)
% It works same as 'predict.m', c=ka*x+be to single DSP
% x = XValidation(:,:,:,1:10);
% y = zeros(length(x(1,1,1,:)),net.Layers(7).OutputSize);
PRE = 2^10; % float bits
for n=1:length(x(1,1,1,:))
    I=x(:,:,:,n);%+net.Layers(1).AverageImage;
    %% --------------------------------------------------------------------- %%
    %% 1 Conv + BN
    NumCh1=net.Layers(2).NumChannels;
    NumF1=net.Layers(2).NumFilters;
    A1(1:NumCh1,1:NumF1) = abs(net.Layers(2).Weights(1,1,:,:));
    gamma_ivar1(1:NumF1) = net.Layers(3).Scale./sqrt(net.Layers(3).TrainedVariance + net.Layers(3).Epsilon);
    ka1=A1.*gamma_ivar1;
    be1(1:NumF1)=net.Layers(3).Offset-net.Layers(3).TrainedMean.*net.Layers(3).Scale./sqrt(net.Layers(3).TrainedVariance + net.Layers(3).Epsilon);
%     be1(8) = 0.0625; % 0.0386329
%     be1(7) = 0; % -0.1144611
    w1 = sign(net.Layers(2).Weights);             w1 = rot90(w1,2);
    C1 = zeros(net.Layers(1).InputSize(1),net.Layers(1).InputSize(2),NumF1);
    for f=1:NumF1           % filter
        for ch=1:NumCh1     % channel
%             C1(:,:,f) = C1(:,:,f) + ka1(ch,f).*conv2(I(:,:,ch),w1(:,:,ch,f),'same');
            C1(:,:,f) = C1(:,:,f) + (round(PRE*ka1(ch,f))/PRE.*(fix(PRE*conv2(fix(PRE*I(:,:,ch))/PRE,w1(:,:,ch,f),'same'))/PRE));
        end
        C1(:,:,f) = C1(:,:,f) + round(PRE*be1(f))/PRE;
    end
    % surf(C1(:,:,7)); view(0,90);
    %% 1 ReLU
    C1nLReLU = C1;
    C1nLReLU(C1nLReLU < 0) = 0; % neg. to zero
%     C1nLReLU = max(0,C1n) + min(0,C1n)*net.Layers(4).Scale; % LeakyReLU pos + neg*scale
    %% Max Pool
    s = size(C1nLReLU);
    C1nLPool = zeros(s(1)/2,s(2)/2,s(3));
    for ch=1:s(3) % loop over channels
        for yy=1:2:s(1) % loop over row
            for xx=1:2:s(2) % loop over col
                if     (C1nLReLU(yy,xx,ch)>=C1nLReLU(yy,xx+1,ch) && C1nLReLU(yy,xx,ch)>=C1nLReLU(yy+1,xx,ch) && C1nLReLU(yy,xx,ch)>=C1nLReLU(yy+1,xx+1,ch))
                    C1nLPool(1+(yy-1)/2,1+(xx-1)/2,ch)=C1nLReLU(yy,xx,ch);
                elseif (C1nLReLU(yy,xx+1,ch)>=C1nLReLU(yy,xx,ch) && C1nLReLU(yy,xx+1,ch)>=C1nLReLU(yy+1,xx,ch) && C1nLReLU(yy,xx,ch)>=C1nLReLU(yy+1,xx+1,ch))
                    C1nLPool(1+(yy-1)/2,1+(xx-1)/2,ch)=C1nLReLU(yy,xx+1,ch);
                elseif (C1nLReLU(yy+1,xx,ch)>=C1nLReLU(yy,xx,ch) && C1nLReLU(yy+1,xx,ch)>=C1nLReLU(yy,xx+1,ch) && C1nLReLU(yy+1,xx,ch)>=C1nLReLU(yy+1,xx+1,ch))
                    C1nLPool(1+(yy-1)/2,1+(xx-1)/2,ch)=C1nLReLU(yy+1,xx,ch);
                elseif (C1nLReLU(yy+1,xx+1,ch)>=C1nLReLU(yy,xx,ch) && C1nLReLU(yy+1,xx+1,ch)>=C1nLReLU(yy,xx+1,ch) && C1nLReLU(yy+1,xx+1,ch)>=C1nLReLU(yy+1,xx,ch))
                    C1nLPool(1+(yy-1)/2,1+(xx-1)/2,ch)=C1nLReLU(yy+1,xx+1,ch);
                end
            end
        end
    end
    C1nLPool = fix(PRE*C1nLPool)/PRE;
    %% FC1 - iki cia ok, conv teisingas
    fc1in = C1nLPool(:)';
    fc1out = repelem(fc1in,net.Layers(6).OutputSize,1).*round(PRE*net.Layers(6).Weights)/PRE;
%     fc1out = round(PRE*16*fc1out)/PRE/16; % cia taisyti apvalinima,
%     FPGA skaiciuoja x*w poromis ir prideda prie neurono, jei pora
%     uzejimu, tai nuskaito praeita 16b neurono verte ir perraso.
    fc1out = sum(fc1out,2) + round(PRE*net.Layers(6).Bias)/PRE;
    fc1out = fix(PRE*fc1out)/PRE;
    
    %% FC2
    fc2in = fc1out';
    fc2out = repelem(fc2in,net.Layers(7).OutputSize,1).*round(PRE*net.Layers(7).Weights)/PRE;
%     fc2out = round(PRE*16*fc2out)/PRE/16;
    fc2out = sum(fc2out,2) + round(PRE*net.Layers(7).Bias)/PRE;
    fc2out = fix(PRE*fc2out)/PRE;
%     y(n,:) = fc2out';
    disp(['n=' num2str(n)])
end

% YPredicted2 = y;