clear all
close all
clc
v = VideoReader('sample_video_144.mp4');

% create tensor of dimensions m x n x nFrames
% n = video frame columns, m = video frame rows
% currently limiting nFrames to 40 to speed computation

n = v.Width;
m = v.Height;
time = v.Duration;
nFrames = min(v.NumberOfFrames, 40);

X = zeros(m, n, nFrames);

% using v.NumberOfFrames requires resetting VideoReader to read frames 
v = VideoReader('sample_video_144.mp4');
i = 1;
while hasFrame(v) && i <= nFrames
    vid = readFrame(v);
    X(:,:,i) = rgb2gray(vid);
    i = i + 1;
end

X = X/max(abs(X(:)));

% set lambda
% Zhang paper found optimal results at 1/sqrt(min(size(X,1), size(X,2)))
% for the de-noising application.  This value does not appear optimal 
% for the background separation problem. 

lambda = 0.215 / sqrt(min(size(X,1), size(X,2)));

[L, S] = tensor_rpca(X, lambda);

%% ===================== Plot Result ===========================

LS = L+S;
fh = figure;
for i = 1:size(X,3) 
    subplot(221)
    imagesc(X(:,:,i));title('Original Video');
    colormap(gray);
    
    subplot(222)
    imagesc(LS(:,:,i));title('L + S');
    colormap(gray);
    
    subplot(223)
    imagesc(L(:,:,i));title('Low Rank Component');
    colormap(gray);
      
    subplot(224)
    imagesc(S(:,:,i));title('Sparse Component')
    colormap(gray);
    
    pause(0.1);

end