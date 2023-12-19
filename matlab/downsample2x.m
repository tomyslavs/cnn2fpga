function Img = downsample2x(I)
% I = double(I);
% sizeI = size(I);
% Img = zeros(round(sizeI(1)/2),round(sizeI(2)/2),sizeI(3));
% for y=1:2:sizeI(1)
%     yy=1+round((y-1)/2);
%     for x=1:2:sizeI(2)
%         xx=1+round((x-1)/2);
%         for z=1:sizeI(3)
%             Img(yy,xx,z)=round(mean([I(y,x,z) I(y+1,x,z) I(y,x+1,z) I(y+1,x+1,z)]));
%         end
%     end
% end
Img = imresize(I,0.5);


