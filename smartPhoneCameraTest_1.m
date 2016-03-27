% % Camera identification example
clear;
addpath('/home/lhj/my_documents/openh264-openh264v1.5/test_videos/samsang/rsdl_clips/', ...
        '/home/lhj/my_documents/openh264-openh264v1.5/test_videos/utubes/travel/',...
        '/home/lhj/my_documents/codes_144/CameraFingerprint/',...
        '/home/lhj/my_documents/codes_144/CameraFingerprint/Functions/',...
        '/home/lhj/my_documents/codes_144/CameraFingerprint/Filter/');
vidDir1 = dir('/home/lhj/my_documents/openh264-openh264v1.5/test_videos/samsang/rsdl_clips/*.avi');

[Fingerprint, t1] = getVidFingerprint(vidDir1, 1);
save 'samsang_gtRsdl_minus128.mat' Fingerprint;
%load 'meilan_gtOrg_qp0.mat';
% clear RPsum NN;
vidDir2 = dir('/home/lhj/my_documents/openh264-openh264v1.5/test_videos/samsang/rsdl_clips/*.aviTestone');

[Fingerprint_test, t2] = getVidFingerprint(vidDir2, 1);
% The optimal detector (see publication "Large Scale Test of Sensor Fingerprint Camera Identification")

save 'samsang_testRsdl_minus128.mat' Fingerprint_test;
C = crosscorr(Fingerprint,Fingerprint_test);
detection = PCE(C)

