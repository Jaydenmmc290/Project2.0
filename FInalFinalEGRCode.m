close all
clear
clc

% Take photo with camera
m = mobiledev;
cam = camera(m, "back");
cam.Resolution = '1280x720';
cam.Autofocus = 'on';
img = snapshot(cam, 'immediate');

% Save the image
imwrite(img, 'SampleSolution3.jpg');

% Load the image
OriginalSample = imread("SampleSolution3.jpg");

% Show the image
imshow(OriginalSample);

%% RGB Layers of Image

I_Red = OriginalSample(:,:,1);
I_Green = OriginalSample(:,:,2);
I_Blue = OriginalSample(:,:,3);

figure;
subplot(2,2,1), imshow(I_Red);
title('Red Plane');
subplot(2,2,2), imshow(I_Green);
title('Green Plane');
subplot(2,2,3), imshow(I_Blue);
title('Blue Plane');
subplot(2,2,4), imshow(OriginalSample);
title('Original');

imwrite(I_Green, 'GreenImage1.jpg');

%% Record Color Values

Sample = imread("GreenImage1.jpg");

%% Look at Pixel Values

imtool(Sample);

%% Split image into RGB

g_channel = Sample(:,:,1); % Green channel

%% Use colors to differentiate things in image

bin = g_channel <= 90; % Thresholding

%% Removing Noise From Image

solid_sample = bwareaopen(bin, 100); % Remove small noisy regions
solid_sample_filled = imfill(solid_sample, "holes"); % Fill holes in regions

%% Add Green Overlay with No Holes

green_overlay = imoverlay(Sample, solid_sample_filled, [0,1,0]);

imshow(green_overlay);

imwrite(green_overlay, 'GreenOverlay.jpeg');

%% Adding Bounding Box

Bounding_Boxes = regionprops(solid_sample, 'BoundingBox');

figure;
imshow(Sample);
title('Bounding Box Around Solid Sample');
hold on;

for k = 1:length(Bounding_Boxes)
    SampleBB = Bounding_Boxes(k).BoundingBox;
    rectangle('Position', [SampleBB(1), SampleBB(2), SampleBB(3), SampleBB(4)], 'EdgeColor', 'r', 'LineWidth', 2);
end

hold off;

%% Determining Distances

if length(Bounding_Boxes) >= 2
    Ball_BoundingBox = Bounding_Boxes(2).BoundingBox;
    BallTop = Ball_BoundingBox(2);
    BallHeight = Ball_BoundingBox(4);

    BottomBall = BallTop + BallHeight;

    Box_BoundingBox = Bounding_Boxes(1).BoundingBox;
    TopBox = Box_BoundingBox(2);

    DistancePixels = TopBox - BottomBall;

    DistanceCm = DistancePixels * 0.019685; % Pixel:Distance ratio
    fprintf('%.2f centimeters above the solid\n', DistanceCm);

    Distance = round(DistanceCm, 1);
    figure;
    imshow(Sample);
    title(sprintf('%.2f centimeters away', Distance));

    if Distance <= 1.1
        disp("STOP");
    end
else
    disp("There are not enough bounding boxes detected.");
end