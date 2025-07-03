
OriginalSample = imread("SampleSolution3.jpg");
imshow (OriginalSample);

%% RGB Layers of Image

I_Red =  OriginalSample (:,:,1);
I_Green = OriginalSample (:,:,2);
I_Blue = OriginalSample (:,:,3);

subplot(2,2,1), imshow(I_Red);
title('Red Plane');
subplot(2,2,2), imshow(I_Green);
title('Green Plane');
subplot(2,2,3), imshow(I_Blue);
title('Blue Plane');
subplot(2,2,4), imshow(OriginalSample);
title('Original');

imwrite(I_Green,'GreenImage1.jpg');

%% Record Color Values
clc 
clear

Sample = imread("GreenImage.jpg");
imshow  (Sample);


%% Look at Pixel Values

imtool(Sample);

%% Split image into RGB

g_channel = Sample(:,:,1);

%% Use colors to differentiate things in image

bin = g_channel<=90 ;
imshow(bin);

%% Removing From Image

solid_sample = bwareaopen(bin, 100);
imshow(solid_sample);

%% Fixing Holes

solid_sample_filled = imfill(solid_sample,"holes");
imshow(solid_sample_filled);

%% Add Green OVerlay with No Holes

rockCover = solid_sample_filled;
green_overlay = imoverlay(Sample, rockCover,[0,1,0]);

imshow(green_overlay);

imwrite(green_overlay, 'GreenOverlay.jpeg');

%% Adding Bounding Box

Bounding_Boxes = regionprops(solid_sample,'BoundingBox');

figure, imshow(Sample),title('Bounding Box Around Solid Sample');

hold on
    for k =1:length(Bounding_Boxes)
    SampleBB = Bounding_Boxes(k).BoundingBox;
    rectangle('Position',[SampleBB(1),SampleBB(2),SampleBB(3),SampleBB(4)] ,'EdgeColor','r','LineWidth',2)
    end
hold off

%% Determining Distances

if length(Bounding_Boxes) >= 2
    SampleBB = Bounding_Boxes(2).BoundingBox;
    BallTop = SampleBB(2);
    BallHeight = SampleBB(4);

    BottomBall = BallTop + BallHeight;

    SampleBB = Bounding_Boxes(1).BoundingBox;
    TopBox = SampleBB(2);

    DistancePixels = TopBox - BottomBall;

    DistanceCm = DistancePixels * (0.019685); %% number is pixel:distance ratio found in Model 1
    Distance = round(DistanceCm, 1);
    fprintf('%.2f centimeters above the solid \n', DistanceCm);

    figure, imshow(Sample), title(Distance,'centimeters away','C');

    if Distance <= 1.1
        disp("STOP");
    end
else
    disp("There are not enough bounding boxes detected.");
end
