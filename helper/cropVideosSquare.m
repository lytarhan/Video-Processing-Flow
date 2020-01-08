function cropVideosSquare(vidList, saveDir)

%--------------------------------------------------------------------------
% Leyla Tarhan
% 3/2016 

% Crop a list of videos to a square frame and save the new files elsewhere.

% input: 
    % List of video files (including the full file path)
    % directory to save new files in
% output:
    % new files (saved in specified directory)
%--------------------------------------------------------------------------
disp('starting square crop now...');
for i = 1:length(vidList)
    
    disp(sprintf('cropping video %d of %d to square frame ...', i, length(vidList)));
    % get the movie's fullfile 
    vidFileName = char(vidList(i)); % convert to a string so that it's 
    % possible to feed it into VideoReader()
    
    % Feed it into VideoReader() (I think this just makes it a certain class):
    vidObj = VideoReader(vidFileName);
    
       
    % crop to square and then expand:
    for x = 1:vidObj.NumberOfFrames 
        % Read in the current frame:
        vid(x).data = read(vidObj, x); % cdata is part of a frame structure  

        vidFrame = vid(x).data;
        squareFrame1 = cropToSquare(vidFrame);
        vid(x).squareFrame2 = expandToSquare(squareFrame1);
    end

    % write the video 
    
    % get some useful names:
    vidFileSplit = strsplit(vidFileName, '\');
    currVid = char(vidFileSplit(end)); % grab just the file name (not the full path)
    
    % new name for filenaming purposes:
    vidName = strsplit(currVid, '.');
    croppedFile = strcat(char(vidName(1)), '_cropped');
    vid_cropped = VideoWriter(croppedFile, 'MPEG-4');
    open(vid_cropped);
    for y = 1:vidObj.NumberOfFrames
        % imshow(vid(y).squareFrame2); % I think this is just to do a spot-check on the cropping
        writeVideo(vid_cropped, vid(y).squareFrame2);
    end

    close(vid_cropped);
    close all
    
    % Then move it to the saveDir
    movefile(strcat(croppedFile, '.mp4'), saveDir);
end

disp('done! All videos cropped to square frame.')


end