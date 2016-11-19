
%% Start capture 
 vid = videoinput('macvideo', 1); set(vid,'FramesPerTrigger',inf); set(vid, 'ReturnedColorSpace', 'RGB');
 
 vid.FrameGrabInterval = 1;  
 try
     

    %% 

    temp = imread('temp.jpg');
    shot = getsnapshot(vid);
    %shot = imread('camtemp3.jpg');
    
    %% Contrast Stretch
    strshot = imadjust(shot,stretchlim(shot));
    % figure
    % imshow(strshot)
    
    %% Thresholding
    red = strshot(:,:,1); green = strshot(:,:,2); blue = strshot(:,:,3);
    thresh = 60
    out = red<thresh & green<thresh & blue<thresh;
    out1 = bwmorph(out, 'dilate', 1);
    out2 = imcomplement(out1);
    
    %% Convert to Single
    a = single(rgb2gray(temp));
    imshow(a);
    
    b = single(out2);
    imshow(b);
    
    %% Detect SiFt Features
    
    [F1 D1] = vl_sift(a); %temp
    [F2 D2] = vl_sift(b); %shot
    
    [matches score] = vl_ubcmatch(D1,D2,1.5);
    
    x = F2(1,matches(2,:));
    y = F2(2,matches(2,:));
    
    
    %% Bound Points
    xmin = min(x)+50;
    xmax = max(x)-50;
    ymin = min(y);
    ymax = max(y);
    xint = (xmax-xmin)/5;
    x1 = xmin + xint;
    x2 = xmin + 2*xint;
    x3 = xmin + 3*xint;
    x4 = xmin + 4*xint;
    
    %% Track Marker
    
    imshow(b);
    hold on;
    plot(F2(1,matches(2,:)),F2(2,matches(2,:)),'r*');
    k = convhull(x,y);
    plot(x(k),y(k),'r-');
    
    start(vid);  delay(2);
    
    while(vid.FramesAcquired<=500)
        data = getsnapshot(vid);
        imshow(uint8(data));
        
        hold on;
        plot(F2(1,matches(2,:)),F2(2,matches(2,:)),'r*');
        %k = convhull(x,y);
        plot(x(k),y(k),'r-');
        
        diff_im = imsubtract(data(:,:,1),rgb2gray(data));
        diff_im = medfilt2(diff_im, [3, 3]);
        diff_im = im2bw(diff_im, 0.12);
        diff_im = bwareaopen(diff_im, 300);
        bw = bwlabel(diff_im, 8);
        
        stats = regionprops(bw, 'BoundingBox', 'Centroid');
        
        hold on;
        for object = 1 : length(stats)
            bb = stats(object).BoundingBox;
            bc = stats(object).Centroid;
            rectangle('Position',bb,'EdgeColor','r','LineWidth', 2);
            plot(bc(1),bc(2),'-m+');
            
            
            if (inpolygon(bc(1),bc(2),x(k),y(k)))
                if bc(1) < x1
                    %
                    plot([x1, x1],[ymin, ymax],'b');
                    rectangle('Position',[xmin,ymin,xint,yd],'Curvature',[1,1],'FaceColor','r');
                    [l,f,m] = wavread('1.wav');
                    sound(l,f,m);
                elseif bc(1) < x2
                    %
                    plot([x1, x1],[ymin, ymax],'b');
                    plot([x2, x2],[ymin, ymax],'b');
                    rectangle('Position',[x1,ymin,xint,yd],'Curvature',[1,1],'FaceColor','r');
                    [l,f,m] = wavread('2.wav');
                    sound(l,f,m);
                elseif bc(1) < x3
                    %
                    plot([x2, x2],[ymin, ymax],'b');
                    plot([x3, x3],[ymin, ymax],'b');
                    rectangle('Position',[x2,ymin,xint,yd],'Curvature',[1,1],'FaceColor','r');
                    [l,f,m] = wavread('3.wav');
                    sound(l,f,m);
                elseif bc(1) < x4
                    %
                    plot([x3, x3],[ymin, ymax],'b');
                    plot([x4, x4],[ymin, ymax],'b');
                    rectangle('Position',[x3,ymin,xint,yd],'Curvature',[1,1],'FaceColor','r');
                    [l,f,m] = wavread('4.wav');
                    sound(l,f,m);
                else
                    %
                    plot([x4, x4],[ymin, ymax],'b');
                    rectangle('Position',[x4,ymin,xint,yd],'Curvature',[1,1],'FaceColor','r');
                    [l,f,m] = wavread('5.wav');
                    sound(l,f,m);
                end
            end
        end
        hold off;
        
    end
    
    stop(vid);
    flushdata(vid);
    clear all;
    
 catch
    stop(vid);
    imaqreset;
    disp('Cleaned up');
    %rethrow(err);
end

