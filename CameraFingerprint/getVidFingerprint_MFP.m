function [Fingerprint, step] = getVidFingerprint(vidDir, frm_step)
% calculate the fingerprint of the video file
sigma = 2;                                  % local std of extracted noise
%%%  Parameters used in denoising filter
L = 4;                                      %  number of decomposition levels
qmf = MakeONFilter('Daubechies',8);
t = 0;
l = 1;
for i = 1:length(vidDir)
    vidDir(i).name
    vid = VideoReader(vidDir(i).name);
    if t==0
        % the first frame of the first video we initialize two cells
        sz_X1 = [vid.height,vid.width, 3];
        for j=1:3
            RPsum{j}=zeros(vid.height,vid.width,'single');   
            NN{j}=zeros(vid.height,vid.width,'single');        	% number of additions to each pixel for RPsum
        end
    end
    while hasFrame(vid) 
        X = double255(readFrame(vid))-128;
        if length(size(X))~=3 || any(size(X)~=sz_X1)
            fprintf('Not a color image - skipped.\n or size is not right\n');
            continue;                           % only color images will be used 
        end
        for j=1:3
            ImNoise = single(NoiseExtract(X(:,:,j),qmf,sigma,L)); 
            Inten = single(IntenScale(X(:,:,j))).*Saturation(X(:,:,j));    % zeros for saturated pixels
            RPsum{j} = RPsum{j}+ImNoise.*Inten;   	% weighted average of ImNoise (weighted by Inten)
            NN{j} = NN{j} + Inten.^2;
        end
        t=t+1;                                      % counter of used images
        if t > 500
            % output every 5000 frames
            RP = cat(3,RPsum{1}./(NN{1}+1),RPsum{2}./(NN{2}+1),RPsum{3}./(NN{3}+1)); % integrate the three channels
            % Remove linear pattern and keep its parameters
            [RP,LP] = ZeroMeanTotal(RP);
            RP = single(RP);     

            RP = rgb2gray1(RP);
            sigmaRP = std2(RP);
            Fingerprint(:,:,l) = WienerInDFT(RP,sigmaRP);
            l = l+1;
            t = 1;
        end
    end
end
clear ImNoise Inten X;
if t==0 
    error('None of the images was color image in landscape orientation.');
    exit(1);
end
step = l;
end
