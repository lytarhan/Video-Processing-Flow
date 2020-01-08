function speedVids(vidList, newDur, saveDir)
% Leyla Tarhan
% 7/2016

% Function to speed up a video by selecting a regularly-spaced subset
% of its frames and writing only those to a new video, rather than changing
% the frame rate but keeping the same # of frames. 

% inputs:
    % vidList: list of videos (with full file paths) to edit
    % newDur: desired duration of the resulting videos
    % saveDir: directory in which to save the output videos

% outputs: new video that's been sped up, saved to saveDir. If a video is
% already the desired duration (OR shorter), will print out a message to
% that effect and copy the original file, unaltered, to the saveDir. 
%--------------------------------------------------------------------------

noChangeCounter = 0; % initialize counter to keep track of vids that are 
% already the newDur length

for i = 1:length(vidList) % loop through all vids in this directory
    
    disp(sprintf('Speeding up video %d of %d ...', i, length(vidList)));
    
    % get the movie's fullfile
    vidFileName = char(vidList(i)); % convert to a string so that it's
    % possible to feed it into VideoReader()
    
    % Feed it into VideoReader() (I think this just makes it a certain class):
    vidObj = VideoReader(vidFileName);

    % Fraction of the total original frames that you want to write to the new
    % file:
    framesFrac = floor(vidObj.Duration / newDur); % 1/n of the frames (or, every n frames)
    % using floor function will
    % make the interval between frames an integer and errs on the side of
    % collecting too many frames (vs. ceiling).
    
    if framesFrac > 1 % new vid would be shorter than the old vid (accounts
        % for cases where original vid is just a little bit longer than 
        % newDur, and as a result framesFrac would = 1 (which would fail 
        % the assert catch below)
    % if (vidObj.Duration - newDur) > 0.3 % this vid starts out longer than the newDur
        % (arbitrarily set different value -- accounts for the case where 
        % original duration > newDur, but only by so little that it 
        % wouldn't make sense to enter this loop). 
        


        % get some useful names:
        vidFileSplit = strsplit(vidFileName, '\');
        currVid = char(vidFileSplit(end)); % grab just the file name (not the full path)
        
        % new name for filenaming purposes:
        vidName = strsplit(currVid, '.');
        spedFile = strcat(char(vidName(1)), '_sped');
        vid_sped = VideoWriter(spedFile, 'MPEG-4');
        
        open(vid_sped);
        
        % loop through the frames, and collect them only at the interval specified
        % above.
        counter = 1; % initialize counter to = index of 1st frame
        while hasFrame(vidObj)
            vidFrame = readFrame(vidObj); % read in the next frame
            if mod(counter, framesFrac) == 0; % this is a frame we should write
                writeVideo(vid_sped, vidFrame); % add this frame to the new vid
            end
            counter = counter + 1; % on each loop, iterate the counter
        end
        
        close(vid_sped);
        close all
        
        % defensive programming to make sure the new duration = the desired new
        % duration.
        assert((floor(vid_sped.Duration) == newDur), 'WARNING: videos new duration does not match newDur.');
        % errs on the side of being a little bit too long.
        
        % Then copy it to the saveDir
        movefile(strcat(spedFile, '.mp4'), saveDir);
    else % this vid starts out as long as newDur or very slightly longer
        disp(sprintf('%s is c. %d s long already. Moving to saveDir as it is...', vidFileName, newDur));
        % move it as it is:
        copyfile(vidFileName, saveDir);
        noChangeCounter = noChangeCounter + 1; % keep track of how many vids in this category
    end
end
disp(sprintf('Done! Sped up all vids to last %d seconds. %d vids were already this short.', newDur, noChangeCounter));
end