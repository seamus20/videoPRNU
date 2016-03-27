% % Camera identification example
clear;
addpath(genpath('/home/lhj/my_documents/openh264-openh264v1.5/test_videos/'));
addpath(genpath('/home/lhj/my_documents/codes_144/CameraFingerprint/'));

vidDir1 = dir('/home/lhj/my_documents/openh264-openh264v1.5/test_videos/meilan/rsdl_clips/*.avi');
[Fingerprint, step] = getVidFingerprint(vidDir1, 2);
save 'meilan_gtRsdl_segment.mat' Fingerprint;
%load  'mat/MineNexus7_gtRsdl_crf0.mat';      
% clear RPsum NN;

vidDir2 = dir('/home/lhj/my_documents/openh264-openh264v1.5/test_videos/meilan/rsdl_clips/*.aviTestone');
[Fingerprint_test, t2] = getVidFingerprint(vidDir2, 2);
% The optimal detector (see publication "Large Scale Test of Sensor Fingerprint Camera Identification")

save 'meilan_testRsdl_segment.mat' Fingerprint_test;
% for mfp (have not get satisfied result)
%for i = 1:step 
%    C = crosscorr(Fingerprint(:,:,i),Fingerprint_test);
%    detection(i) = PCE(C)
%end

C = crosscorr(Fingerprint, Fingerprint_test);
detection = PCE(C)

