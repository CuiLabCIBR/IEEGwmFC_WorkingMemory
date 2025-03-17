%% select subnetwork of yeo 7 atlas
clc;clear;close all;
addpath Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\function\cifti-matlab;
addpath Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\function\fieldtrip-20231220\external\gifti;
% read yeo7atlas
folder = 'Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\fig1\gmelectrode_wbview';
yeo7dlabel = cifti_read(fullfile(folder, 'Yeo2011_7Networks_N1000.dlabel.nii'));
newyeo7dlabel = yeo7dlabel;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Cont network
cdata = yeo7dlabel.cdata;
% edit the dlabel file
ROInet = 'Cont'; ROIindex = 6;
cdata(cdata~=ROIindex) = 0;
newyeo7dlabel.cdata = cdata;
newdlabelFile  = fullfile(fullfile(folder, ['Yeo2011_7Networks_N1000_', ROInet,'.dlabel.nii']));
delete(newdlabelFile);
cifti_write(newyeo7dlabel, newdlabelFile);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Default mode network
cdata = yeo7dlabel.cdata;
% edit the dlabel file
ROInet = 'Default'; ROIindex = 7;
cdata(cdata~=ROIindex) = 0;
newyeo7dlabel.cdata = cdata;
newdlabelFile  = fullfile(fullfile(folder, ['Yeo2011_7Networks_N1000_', ROInet,'.dlabel.nii']));
delete(newdlabelFile);
cifti_write(newyeo7dlabel, newdlabelFile);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SalVentAttn network
cdata = yeo7dlabel.cdata;
ROInet = 'SalVentAttn'; ROIindex = 4;
cdata(cdata~=ROIindex) = 0;
newyeo7dlabel.cdata = cdata;
newdlabelFile  = fullfile(fullfile(folder, ['Yeo2011_7Networks_N1000_', ROInet,'.dlabel.nii']));
delete(newdlabelFile);
cifti_write(newyeo7dlabel, newdlabelFile);

