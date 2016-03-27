function [Fingerprint, frameNum] = getVidFingerprint(vidDir, frm_step)
% calculate the fingerprint of the video file
sigma = 2;                                  % local std of extracted noise
%%%  Parameters used in denoising filter
L = 4;                                      %  number of decomposition levels
qmf = MakeONFilter('Daubechies',8);
vid = VideoReader(vidDir(1).name);
v_h = vid.height;
v_w = vid.width;
ImNoise = zeros(v_h, v_w, 'single');
Inten   = zeros(v_h, v_w, 'single');
sz_X1 = [v_h,v_w, 3];
t=1;
n=100;
for j=1:3
    RPsum{j}=zeros(v_h,v_w,'single');   
    NN{j}   =zeros(v_h,v_w,'single');        	% number of additions to each pixel for RPsum
end
for i = 1:length(vidDir)
    vidDir(i).name
    vid = VideoReader(vidDir(i).name);
    while hasFrame(vid) 
        X = double255(readFrame(vid));
        if length(size(X))~=3 || any(size(X)~=sz_X1)
            fprintf('Not a color image - skipped.\n or size is not right\n');
            continue;                           % only color images will be used 
        end
        for j=1:3
            ImNoise = ImNoise + single(NoiseExtract(X(:,:,j),qmf,sigma,L)); 
            Inten   = Inten   + single(IntenScale(X(:,:,j))).*Saturation(X(:,:,j));    % zeros for saturated pixels
            if mod(t, n) == 0                   % end of a segment of frames
                avg_ImNoise = ImNoise/n;
                avg_Inten   = Inten/n;
                RPsum{j}    = RPsum{j}+avg_ImNoise.*avg_Inten;   	% weighted average of ImNoise (weighted by Inten)
                NN{j}       = NN{j} + avg_Inten.^2;
                ImNoise     = zeros(v_h, v_w, 'single');
                Inten       = zeros(v_h, v_w, 'single');
            end
        end
        t=t+1;
    end
end
clear ImNoise Inten X avg_ImNoise avg_Inten
if t==0 
    error('None of the images was color image in landscape orientation.');
end
RP = cat(3,RPsum{1}./(NN{1}+1),RPsum{2}./(NN{2}+1),RPsum{3}./(NN{3}+1));
% Remove linear pattern and keep its parameters
[RP,LP] = ZeroMeanTotal(RP);
RP = single(RP);     

RP = rgb2gray1(RP);
sigmaRP = std2(RP);
Fingerprint = WienerInDFT(RP,sigmaRP);
frameNum = t;
end
