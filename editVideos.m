% Leyla Tarhan & Evan Fields
% https://github.com/lytarhan
% 6/2016
% MATLAB R2015b

% This script goes through several steps to edit a set of videos. 
% This code assumes that you have already collected and saved these and
% edited them to roughly the chunk of the video you wish to use as a
% stimulus. It also expects that these videos are saved in .mp4 format, but
% that's easy to change below. 

% The editing steps are:
    % 1. Edit each video down to exactly your desired duration (default: 2
    % seconds). This is useful because programs like QuickTime aren't
    % sufficiently accurate to the level of milliseconds. However, it is
    % still necessary to do a first (coarse) pass outside of MATLAB to make
    % sure you're capturing the correct segment of the video. 
    
    % 2. Crop the video's frame to a square.
    
    % 3. If necessary, re-crop the video frame in a more manual step to
    % isolate the video's "usable area" (e.g., excluding a section of the
    % frame or centering the main actor). 
    
    % 4. Detect faces using the Viola-Jones method, and save that
    % information.
    

%% Clean up
clear all
close all
clc

%% Path Management

% add path to helper functions:
addpath('helper');

% save your videos in the "Videos" directory (see README file for file
% structure instructions). 
topDir = 'Videos';

% Video files that have been edited to a little above the desired duration, 
% and are inside the topDir:
movieDir =  fullfile(topDir, '0-editedToSegment');

% Save directories for each step:
% (1a) edited to exact duration 
saveDir_edit = fullfile(topDir, '1a-trimmed'); 
if ~exist(saveDir_edit, 'dir'); mkdir(saveDir_edit); end

% (1b) if necessary to re-edit duration outside of MATLAB
saveDir_reEdit = fullfile(topDir, '1b-re-edit_QT'); 
if ~exist(saveDir_reEdit, 'dir'); mkdir(saveDir_reEdit); end

% (2) cropped - automatic square
saveDir_crop = fullfile(topDir, '2-cropped'); 
if ~exist(saveDir_crop, 'dir'); mkdir(saveDir_crop); end

% (3a) if the cropping didn't work, specify specify the usable area by
% hand. For these videos, move the pre-cropped, trimmed files to this
% directory. 
recropDir = fullfile(topDir, '3a-specify usable area'); 
if ~exist(recropDir, 'dir'); mkdir(recropDir); end

% (3b) got usable area -- need to re-crop to square frame
usableAreaDir = fullfile(topDir, '3b-got usable area'); 
if ~exist(usableAreaDir, 'dir'); mkdir(usableAreaDir); end

% (3c) usable area discards
discardDir = fullfile(topDir, 'z-discard'); 
if ~exist(discardDir, 'dir'); mkdir(discardDir); end

% (4a) Directory with vids that might have faces:
faceDir = fullfile(topDir, '4a-getFaceData');
if ~exist(faceDir, 'dir'); mkdir(faceDir); end

% (4b) Data from face detection and motion models:
faceMotDir = fullfile(topDir, '4b-Motion and Face Data'); 
if ~exist(faceMotDir, 'dir'); mkdir(faceMotDir); end


%% Get the list of videos to edit

% get vid list, make sure it's what you expect:
movieList = dir(fullfile(movieDir, '*.*'));
movieList = {movieList.name};
movieList(strncmp('.', movieList, 1)) = []; % remove entries that start with a '.'

moviesSample = movieList(:);
moviesSample


%% (1) edit for exact duration

% (a) get vid list:
vidList_1 = fullfile(movieDir, moviesSample(:)); 

% input: video list, desired duration, saveDir for this step, discard dir
% for videos that are too short and need to be re-edited for time in
% QuickTime, etc.

% output: new videos saved to saveDir

% (b) call the function to edit them:
newDur = 2; % in seconds
fps = 30; % make it all 30 fps
editMovieDur(vidList_1, newDur, fps, saveDir_edit, saveDir_reEdit);

%% (2) crop video frames automatically

clc % clear the terminal

% input: video list from step 1's saveDir, saveDir for cropped videos
% output: new videos saved to step 2's saveDir

% (a) get vid list:
vidFiles_2 = dir(fullfile(saveDir_edit, '*.*')); 
vidFiles_2 = {vidFiles_2.name}';
vidFiles_2(strncmp('.', vidFiles_2, 1)) = []; % remove entries that start with a '.'

vidList_2 = vidFiles_2(:);
vidList_2 = fullfile(saveDir_edit, vidList_2);

% (b) call the function to crop them:
cropVideosSquare(vidList_2, saveDir_crop);

%% (3) go through the results of step 2 (in saveDir_crop)
% if any should be re-done manually, *copy* the pre-cropped versions 
% (in 1a-trimmed) to a folder called 
% 'specifyUsableArea' so can specify their usable area manually and then 
% re-crop them manually (section 4).

% Also, be sure to *delete* the version of any of these from the
% saveDir_cropped folder (won't over-write with same filename)

%% (4) IF NECESSARY: manually specify usable area, re-crop automatically

% If we need to manually specify usable area for any videos, call 2 
% functions -- manual specification function, then square cropping
% function.
    
% input: video list from folder called 'specifyUsableArea' (same as in
% section 3).

% output: videos saved in new saveDir (check these over and then move to
% general saveDir from section2).
usableAreaFiles = dir(fullfile(recropDir));
usableAreaFiles = {usableAreaFiles.name}';
usableAreaFiles(strncmp('.', usableAreaFiles, 1)) = []; % remove entries that start with a '.'

if ~isempty(usableAreaFiles) % there are files for which we need to specify 
    % the usable area
    
    % (a) get vid list:
    vidFiles_4a = dir(fullfile(recropDir, '*.*')); % naming matches the step #
    vidFiles_4a = {vidFiles_4a.name}';
    vidFiles_4a(strncmp('.', vidFiles_4a, 1)) = []; % remove entries that start with a '.'
    
    vidList_4a = vidFiles_4a(:);
    vidList_4a = fullfile(recropDir, vidList_4a);
    
    % (b) call the function to specify the usable areas:
    for i = 1:length(vidList_4a)
        vidFile = vidList_4a(i);
        cropAndSaveMovie(vidFile, usableAreaDir, discardDir);
    end
    
    disp('all usable areas specified!');
    
    % (c) call the function to crop to square:
    
    % get vid list:
    vidFiles_4c = dir(fullfile(usableAreaDir, '*.*')); % naming matches the step #
    vidFiles_4c = {vidFiles_4c.name}';
    vidFiles_4c(strncmp('.', vidFiles_4c, 1)) = []; % remove entries that start with a '.'
    
    vidList_4c = vidFiles_4c(:);
    vidList_4c = fullfile(usableAreaDir, vidList_4c);
    
    % crop to square:
    cropVideosSquare(vidList_4c, saveDir_crop);
else
    disp('No files need to be manually cropped.');
end

%% (5a-b) Face Detection 

% input: video list (everything in saveDir from step 2)
% output: "F" struct with faces per frame for each video, condition, etc.

% Put vidoes where you care about face data into faceDir
% (otherwise, if do this for all vids, this will take *forever*)

% (a) get vid list:
vidFiles_5 = dir(fullfile(faceDir, '*.*')); % naming matches the step #
vidFiles_5 = {vidFiles_5.name}';
vidFiles_5(strncmp('.', vidFiles_5, 1)) = []; % remove entries that start with a '.'

vidList_5 = vidFiles_5(:);
% vidList_5 = fullfile(saveDir_crop, vidList_5);
vidList_5 = fullfile(faceDir, vidList_5);

% (b) call the function to detect faces:
findFaces(vidList_5, faceMotDir);

% NB: this step takes awhile, so just be patient. 


