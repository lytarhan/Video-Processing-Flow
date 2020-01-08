function editMovieDur(vidList, newDur, frameRate, saveDir, reDoDir)
%--------------------------------------------------------------------------
% Leyla Tarhan
% 6/2016

% Crop videos with high accuracy to a specified duration (generally used
% after preliminary editing with QuickTime Pro or comparable program). 

% input: vidList (list of videos to edit, with the full file paths), newDur 
% (desired duration in seconds), frameRate (desired frame rate -- this 
% might not change depending upon the original value), saveDir 
% (where you want to save the newly edited videos), reDoDir (in case a 
% video is too short and needs to be
% re-edited using something like QuickTime).

% output: re-cropped movie (saved to separate directory)
%--------------------------------------------------------------------------

% For each video in vidList, change the duration to newDur and save the new
% videos in the saveDir:

for i = 1:length(vidList) 
    % get the movie's fullfile 
    vidFileName = char(vidList(i)); % convert to a string so that it's 
    % possible to feed it into VideoReader()
    disp(sprintf('cutting video %d of %d ...', i, length(vidList)));
    
    % Feed it into VideoReader() (I think this just makes it a certain class):
    vidObj = VideoReader(vidFileName);
    
    
    % get the current duration and # of frames, and from this calculate how
    % many frames you want to keep to get it down to the desired duration:

    newFrames = ceil(newDur * frameRate); % if anything, will make a 
    % little too long (by very little) -- fMRI code should account for this.
    
    if newFrames < vidObj.NumberOfFrames % most common case - need to cut some frames
        % write the file, but only include as many frames as will fit into
        % the desired duration:
        
        % get some useful names:
        vidFileSplit = strsplit(vidFileName, '\');
        currVid = char(vidFileSplit(end)); % grab just the file name (not the full path)
        
        % new name for filenaming purposes:
        vidName = strsplit(currVid, '.');
        vidNameAlone = strsplit(char(vidName(1)), '/');
        vidNameAlone = vidNameAlone(end);
        editedFile = char(fullfile(saveDir, strcat(vidNameAlone, '_edited'))); 
        vid_edited = VideoWriter(editedFile, 'MPEG-4');
        
        % specify the frame rate (right now, set to same as original vid --
        % otherwise defaults to 30 fps)
        vid_edited.FrameRate = frameRate; % ensures that new frame rate 
        % will match the value you fed in to the function (most likely 30,
        % but this is more flexible).
       
        
        open(vid_edited);
        for y = 1:newFrames
            vid(y).data = read(vidObj, y);
            % imshow(vid(y).data); % I think this is just to do a spot-check on the cropping
            writeVideo(vid_edited, vid(y).data); 
        end
        
        close(vid_edited);
        close all
        
        % defensive programming to make sure the new dur = newDur, within
        % some very small margin.
        assert((abs(vid_edited.Duration - newDur) < 0.10), 'WARNING: videos new duration does not match newDur');
        
       
    elseif newFrames > vidObj.NumberOfFrames % we have fewer frames that necessary -- need to re-edit
        % so move (rather than copy) file to a "re-edit in QT" folder:
        movefile(vidFileName, reDoDir);
        
    else % don't need to make any changes (already have the right # of frames) -- just copy file to saveDir
        copyfile(vidFileName, saveDir);
        
    end
   
end

disp(sprintf('done! All movies cut to exactly %d seconds', newDur)); 

% check for any movies that were too short:
reDo = dir(reDoDir);
reDo = {reDo.name}';
reDo(strncmp('.', reDo, 1)) = []; % remove entries that start with a '.' (otherwise might give false message below)

if length(reDo) > 0 % there are videos that are too short to begin with
    disp(sprintf('%d movie(s) were shorter than the desired duration and should be re-edited with QuickTime', (length(reDo)))); % [] not sure about this...
end

end