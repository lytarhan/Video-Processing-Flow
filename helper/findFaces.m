function F = findFaces(movies, dataDir)

% Leyla Tarhan
% 6/2016

% detectFaces: Face detection model using the viola-Jones face-detection 
% algorithm, which detects frontal faces in an
% image (but not profile, etc.). Loops through each frame of a movie and
% each movie in a directory.

% input: 
    % movies (videos with and without faces)
    % dataDir (directory in which to save the F struct)

% output: "F" struct, containing the video name and the total # of faces
% detected / # of frames in the video

% reference:
% http://www.mathworks.com/help/vision/ref/vision.cascadeobjectdetector-class.html

%% Loop through "movies", and for each vid loop through frames

for v = 1:length(movies)
    
    % Create a "detector" object:
    faceDetector = vision.CascadeObjectDetector;
    
    % Load a video:
    vidFile = movies(v);
    vidFileName = char(vidFile); % convert to a string so that it's
    % possible to feed it into VideoReader()
    
    % Feed it into VideoReader() (just makes it a certain class):
    vidObj = VideoReader(vidFileName);
    
    totalFaces = 0; % initialize total faces for this movie to 0, then add as they're detected
    
    % loop through the frames, each time save how many faces were detected:
    for f = 1:vidObj.NumberOfFrames
        frame = read(vidObj, f); % read in the current frame
        % Add boxes around the faces
        bboxes = step(faceDetector, frame); % empty matrix if no faces present;
        % 4-by-# of faces matrix if faces present (4 bc 4 corners of a bounding
        % box)
               
        % How many faces did it detect in this frame?
        numFaces = size(bboxes, 1);
        totalFaces = totalFaces + numFaces;
        
        close all;
    end
    
    % Save the average faces per frame into the "F" struct (chose this instead
    % of total frames with faces to control for possible difference between #
    % of frames in movies:
    
    % get a useful name that's not too long:
    vidNameSplit = strsplit(vidFileName, '\');
    vidNameAlone = char(vidNameSplit(end));
    
    F.vidName{v} = vidNameAlone;
    F.facesPerFrame(v) = round(totalFaces/vidObj.NumberOfFrames, 2);
    disp(sprintf('Model detected %d faces in %s, or %d face(s) per frame', totalFaces, F.vidName{v}, F.facesPerFrame(v)));
    
end

%% Save F struct 
save(fullfile(dataDir, 'F.mat'), 'F');
disp(['F struct saved to ', dataDir]);
end