function [Fingerprint, frameNum] = getVidFingerprint( vidDir , frm_step)
% calculate the fingerprint of the video file
    sigma = 2;                                  % local std of extracted noise
    %%%  Parameters used in denoising filter
    L = 4;                                      %  number of decomposition levels
    qmf = MakeONFilter('Daubechies',8);
    for i = 1:length(vidDir)
        %SeeProgress(i);
        vid = VideoReader(vidDir(i).name);
        t = 0;
        while hasFrame(vid) 
            vid_frame = readFrame(vid);
            X = double255(vid_frame);
            if t==0
                [M,N,three]=size(X);
                if three==1 
                    continue;                           % only color images will be processed    
                end
                %%%  Initialize sums 
                for j=1:3
                    RPsum{j}=zeros(M,N,'single');   
                    NN{j}=zeros(M,N,'single');        	% number of additions to each pixel for RPsum
                end
            else
                s = size(X);
                if length(size(X))~=3, 
                    fprintf('Not a color image - skipped.\n');
                    continue;                           % only color images will be used 
                end
                if any([M,N,three]~=size(X))
                    fprintf('\n Skipping image %s of size %d x %d x %d \n', vidDir1(i).name,s(1),s(2),s(3));
                    continue;                           % only same size images will be used 
                end
            end
            % The image will be the t-th image used for the reference pattern RP
            t=t+1;                                      % counter of used images

            for j=1:3
                ImNoise = single(NoiseExtract(X(:,:,j),qmf,sigma,L)); 
                Inten = single(IntenScale(X(:,:,j))).*Saturation(X(:,:,j));    % zeros for saturated pixels
                RPsum{j} = RPsum{j}+ImNoise.*Inten;   	% weighted average of ImNoise (weighted by Inten)
                NN{j} = NN{j} + Inten.^2;
            end
        end
    end
    clear ImNoise Inten X
    if t==0, error('None of the images was color image in landscape orientation.'), end
    RP = cat(3,RPsum{1}./(NN{1}+1),RPsum{2}./(NN{2}+1),RPsum{3}./(NN{3}+1));
    % Remove linear pattern and keep its parameters
    [RP,LP] = ZeroMeanTotal(RP);
    RP = single(RP);     

    RP = rgb2gray1(RP);
        sigmaRP = std2(RP);
    Fingerprint = WienerInDFT(RP,sigmaRP);
    frameNum = t;
end

    
