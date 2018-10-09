clc; clear; close all; warning off all;

image_folder = strcat(pwd, '\img_testing');
filenames = dir(fullfile(image_folder, '*.jpg'));
total_images = numel(filenames);
Xt = zeros(total_images, 6);
Yt = zeros(total_images, 1);

for n = 1:total_images
    full_name= fullfile(image_folder, filenames(n).name);
    
    [filepath,name,ext] = fileparts(full_name);
    isMature = name(4:6);
    
    if strcmp(isMature, 'mtr')
        Yt(n,:) = 1;
    else
        Yt(n,:) = 0;
    end
    
    Img = imread(full_name);
    
    % Color-Based Segmentation Using K-Means Clustering
    cform = makecform('srgb2lab');
    lab = applycform(Img,cform);
    
    ab = double(lab(:,:,2:3));
    nrows = size(ab,1);
    ncols = size(ab,2);
    ab = reshape(ab,nrows*ncols,2);
    
    nColors = 2;
    [cluster_idx, ~] = kmeans(ab,nColors,'distance','sqEuclidean', ...
        'Replicates',3);
    
    pixel_labels = reshape(cluster_idx,nrows,ncols);
    
    segmented_images = cell(1,3);
    rgb_label = repmat(pixel_labels,[1 1 3]);
    
    for k = 1:nColors
        color = Img;
        color(rgb_label ~= k) = 0;
        segmented_images{k} = color;
    end
    
    area_cluster1 = sum(find(pixel_labels==1));
    area_cluster2 = sum(find(pixel_labels==2));
    
    [~,cluster_min] = min([area_cluster1,area_cluster2]);
    
    Img_bw = (pixel_labels==cluster_min);
    Img_bw = imfill(Img_bw,'holes');
    Img_bw = bwareaopen(Img_bw,50);
    
    stats = regionprops(Img_bw,'Area','Perimeter','Eccentricity');
    area = stats.Area;
    perimeter = stats.Perimeter;
    metric = 4*pi*area/(perimeter^2);
    eccentricity = stats.Eccentricity;
    
    Img_gray = rgb2gray(Img);
    Img_gray(~Img_bw) = 0;
    
    pixel_dist = 1;
    GLCM = graycomatrix(Img_gray,'Offset',[0 pixel_dist; -pixel_dist pixel_dist; -pixel_dist 0; -pixel_dist -pixel_dist]);
    stats = graycoprops(GLCM,{'contrast','correlation','energy','homogeneity'});
    Contrast = mean(stats.Contrast);
    Correlation = mean(stats.Correlation);
    Energy = mean(stats.Energy);
    Homogeneity = mean(stats.Homogeneity);
    
    Xt(n,:) = [metric,eccentricity,Contrast,Correlation,Energy,Homogeneity];
end

save('db_testing', 'Xt');
save('db_testing', 'Yt', '-append');
