function I2 = MaxPool(C1ReLU)
    s = size(C1ReLU);
    I2 = zeros(s(1)/2,s(2)/2,s(3));
    for ch=1:s(3) % loop over channels
        for yy=1:2:s(1) % loop over row
            for xx=1:2:s(2) % loop over col
                if     (C1ReLU(yy,xx,ch)>=C1ReLU(yy,xx+1,ch) && C1ReLU(yy,xx,ch)>=C1ReLU(yy+1,xx,ch) && C1ReLU(yy,xx,ch)>=C1ReLU(yy+1,xx+1,ch))
                    I2(1+(yy-1)/2,1+(xx-1)/2,ch)=C1ReLU(yy,xx,ch);
                elseif (C1ReLU(yy,xx+1,ch)>=C1ReLU(yy,xx,ch) && C1ReLU(yy,xx+1,ch)>=C1ReLU(yy+1,xx,ch) && C1ReLU(yy,xx+1,ch)>=C1ReLU(yy+1,xx+1,ch))
                    I2(1+(yy-1)/2,1+(xx-1)/2,ch)=C1ReLU(yy,xx+1,ch);
                elseif (C1ReLU(yy+1,xx,ch)>=C1ReLU(yy,xx,ch) && C1ReLU(yy+1,xx,ch)>=C1ReLU(yy,xx+1,ch) && C1ReLU(yy+1,xx,ch)>=C1ReLU(yy+1,xx+1,ch))
                    I2(1+(yy-1)/2,1+(xx-1)/2,ch)=C1ReLU(yy+1,xx,ch);
                elseif (C1ReLU(yy+1,xx+1,ch)>=C1ReLU(yy,xx,ch) && C1ReLU(yy+1,xx+1,ch)>=C1ReLU(yy,xx+1,ch) && C1ReLU(yy+1,xx+1,ch)>=C1ReLU(yy+1,xx,ch))
                    I2(1+(yy-1)/2,1+(xx-1)/2,ch)=C1ReLU(yy+1,xx+1,ch);
                end
            end
        end
    end
end