function [Precision,Recall,IoU_avg] = test_ARC(net,XTest,YTest,N,sizeI,Gridx,Gridy,Anchors,ILx,ILy,stepx,stepy,Nout,ds,Anchors_gt,YT_gt)  
%     YPredicted = predict(net,XTest);
gt_limited_by_anchors = 0; % number of gt bbox'es limited by number of anchors ?    lim=1: Precision 0.70638 Recall 0.69002 
iou_level = 0.5 % 0.25 % 0.5
iou_sum = 0;
TP = 0; % true positives                                                            lim=0: Precision 0.70638 Recall 0.68798
AllDet = 0; % all detections
AllGT = 0; % all ground truths
for n=1:N % 200 or 600 for n=1:100:N %
    if mod(n,200) == 0 % plot kas 100 figure
        disp_on = 1;
    else
        disp_on = 0;
    end
    bbox_gt = [0 0 0 0]; bbox_pred = [0 0 0 0];
    Img = XTest(:,:,:,n);
    YPredicted0 = predict(net,Img); % YPredicted0 = YPredicted(n,:)';
    if gt_limited_by_anchors == 1
        YTest0 = YTest(n,:)';
    else
        YTest0_gt = YT_gt(n,:)';
    end
    if disp_on == 1
        figure(n); imshow(Img); hold on;
    end
    for y=1:Gridy
        for x=1:Gridx
            if gt_limited_by_anchors == 0 % Ground Truth (all original detections)
                for k=1:Anchors_gt
                    p_i = Gridx*Anchors_gt*5*(y-1)+Anchors_gt*5*(x-1)+5*(k-1)+1; % probability index
                    x_i = (stepx)*(YTest0_gt(p_i+1)+x-1-YTest0_gt(p_i+3)/2);	if x_i < 0, x_i = 0; end
                    y_i = (stepy)*(YTest0_gt(p_i+2)+y-1-YTest0_gt(p_i+4)/2);	if y_i < 0, y_i = 0; end
                    w_i = (stepx)*YTest0_gt(p_i+3);                             if w_i < 0, w_i = 0.001; end
                    h_i = (stepy)*YTest0_gt(p_i+4);                         	if h_i < 0, h_i = 0.001; end
                    bbox = [x_i y_i w_i h_i];
                    if (YTest0_gt(p_i)>0.99 && bbox(3)>0 && bbox(4)>0) % probability > 0.5
                        if disp_on == 1
                            rectangle('Position',[x_i,y_i,w_i,h_i],'EdgeColor',[0 1 0],'LineWidth',1);
                        end
                        bbox_gt = cat(1,bbox_gt,bbox);
                    end
                end
            end
            for k=1:Anchors
                p_i = Gridx*Anchors*5*(y-1)+Anchors*5*(x-1)+5*(k-1)+1; % probability index
                if gt_limited_by_anchors == 1 % Ground Truth (limited by anchors)
                    x_i = (stepx)*(YTest0(p_i+1)+x-1-YTest0(p_i+3)/2);  if x_i < 0, x_i = 0; end
                    y_i = (stepy)*(YTest0(p_i+2)+y-1-YTest0(p_i+4)/2);  if y_i < 0, y_i = 0; end
                    w_i = (stepx)*YTest0(p_i+3);                        if w_i < 0, w_i = 0.001; end
                    h_i = (stepy)*YTest0(p_i+4);                        if h_i < 0, h_i = 0.001; end
                    bbox = [x_i y_i w_i h_i];
                    if (YTest0(p_i)>0.99 && bbox(3)>0 && bbox(4)>0) % probability > 0.5
                        if disp_on == 1
                            rectangle('Position',[x_i,y_i,w_i,h_i],'EdgeColor',[0 1 0],'LineWidth',1);
                        end
                        bbox_gt = cat(1,bbox_gt,bbox);
                    end
                end
                %% Predicted
                x_i = (stepx)*(YPredicted0(p_i+1)+x-1-YPredicted0(p_i+3)/2);    if x_i < 0, x_i = 0; end
                y_i = (stepy)*(YPredicted0(p_i+2)+y-1-YPredicted0(p_i+4)/2);    if y_i < 0, y_i = 0; end
                w_i = (stepx)*YPredicted0(p_i+3);                               if w_i < 0, w_i = 0.001; end
                h_i = (stepy)*YPredicted0(p_i+4);                               if h_i < 0, h_i = 0.001; end
                bbox = [x_i y_i w_i h_i];
                if (YPredicted0(p_i)>0.5 && bbox(3)>0 && bbox(4)>0) % probability > 0.5
                    if disp_on == 1
                        rectangle('Position',[x_i,y_i,w_i,h_i],'EdgeColor',[1 1 0],'LineWidth',1);
                    end
                    bbox_pred = cat(1,bbox_pred,bbox);
%                     disp(['p ' num2str(YPredicted0(p_i))]);
%                     disp([num2str(YPredicted0(p_i)) ' ' num2str(x_i) ' ' num2str(y_i) ' ' num2str(w_i) ' ' num2str(h_i)]);
%                     disp([' ']);
                end
            end
        end
    end
    %% Plot grid
    if disp_on == 1
        for y=1:Gridy-1
            line([1 ILx],[stepy*y stepy*y],'color','r')
        end
        for x=1:Gridx-1
            line([stepx*x stepx*x],[1 ILy],'color','r')
        end
        hold off;
    end
    %% calc IOU
    bbox_gt = bbox_gt(2:end,:);         len_gt = size(bbox_gt);         len_gt = len_gt(1);
    bbox_pred = bbox_pred(2:end,:);     len_pred = size(bbox_pred);     len_pred = len_pred(1);
%     disp(['bbox_pred ' bbox_pred]);
%     disp(['kiek pred ' num2str(len_pred) ' kiek gt ' num2str(len_gt)]);
    for i=1:len_pred % scan over all detection boxes in image
        bboxA = bbox_pred(i,:); % pred box
        for j=1:len_gt % scan over all ground truth boxes in image
%             j
            bboxB = bbox_gt(j,:); % gt box
            iou = bboxOverlapRatio(bboxA,bboxB);
            if iou > 0
                iou_sum = iou_sum + iou;
            end
            if iou > iou_level
                TP = TP + 1;
                break;
            end
        end
    end
    AllGT = AllGT + len_gt;     AllDet = AllDet + len_pred;
    Precision = TP / AllDet;
    Recall = TP / AllGT;
    IoU_avg = iou_sum / AllDet;
%     disp(['TP ' num2str(TP) ' AllDet ' num2str(AllDet) ' AllGT ' num2str(AllGT)]);
    disp(['Precision ' num2str(Precision) ' Recall ' num2str(Recall) ' IoU_avg ' num2str(IoU_avg)]);
end
% Precision = TP / AllDet;
% Recall = TP / AllGT;
% disp(['TP ' num2str(TP) ' AllDet ' num2str(AllDet) ' AllGT ' num2str(AllGT)]);
% disp(['Precision ' num2str(Precision) ' Recall ' num2str(Recall)]);
% disp([' ']);
end