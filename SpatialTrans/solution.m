v = VideoReader('sample_video.mp4');
w = v.Width;
h = v.Height;
time = v.Duration;

n = h*w*3;
dof = 6;

init = 0;

frames = 250;
p = 25;
d = zeros(n*frames, 1);
i = 1;
K = ones(1,dof);
T = ones(dof,1);
I = eye(dof);

j = 0;
while j < init
    vid = readFrame(v);
    j = j + 1;
end

while i < frames;
    vid = readFrame(v);
    x = reshape(vid, [n,1]);
    d((i*n)+1:(i+1)*n) = x;
    i = i+1;
end
frames = 40;
d = d/255;

j = 25;

it = 0;
maxIt = 5;
lambda = 1e4;
mu = 1e4;

d_old = d((j*n)+1:frames*n);
d_new = d(1:frames*n-n*j);
while it < maxIt
    T = ((d_new*K)'*(d_new*K) + lambda*eye(dof))\((d_new*K)'*d_old);
    K = T'*(T*(d_new'*d_old)-sign(K)'*mu)*T'/(T*T');
    K = K/((T'*T)*(d_new'*d_new));
    it = it + 1;
end

i = 1;
frames = 2;
imstack = zeros(h,w,3,frames);
while i < frames;
    y = d((i*n)+1:(i+1)*n);
    x = d(((i+j)*n)+1:((i+j)+1)*n);
    
    L = 255*x*K*T;
    S = 255-abs(y-L);
    O = y*255;
    errS = sum(abs(S));
    O_im = reshape(O, [h, w, 3]);
    L_im = reshape(L, [h, w, 3]);
    S_im = reshape(S, [h, w, 3]);
    S_frame = mean(S_im,3);

    figure;
    imshow(uint8(mean(O_im,3)));
    figure;
    imshow(uint8(L_im));
    figure;
    imshow(uint8(S_frame));
    
    imstack(:,:,:,i) = uint8(S_im);
    i = i+1;
end
