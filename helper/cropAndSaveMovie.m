function cropAndSaveMovie(fullpathtomovie, saveDir, delDir)
% Allows you to specify a usable area of a movie by clicking on 2 diagonal
% corners of the area devoid of borders, logos, etc. Once you've clicked
% these two points, shows you the resulting box and asks whether that was a
% good cropping (1 for yes, 0 for no). If yes, crops all frames of the
% movie to that specified area and saves the cropped movie in the specified
% directory. 

%==========================================================================
% read in movie
vidFileName = char(fullpathtomovie); % convert to a string so that it's 
% possible to feed it into VideoReader()

% Feed it into VideoReader() (I think this just makes it a certain class):
vidObj = VideoReader(vidFileName);


% get first frame
frame1 = read(vidObj, 1); 

% get click and draw box, repeat till good

% initialize 3 variables representing user's input to whether the crop was
% good to 0. These will change sequentially to 1 when the user says that
% the box was drawn correctly, they see the crop and assert that they do
% want to make it, and they see the cropped *full movie* and assert that
% they want to save the cropped movie:
done = 0; 
done1 = 0;
done2 = 0;
while ~(done & done1 & done2) % haven't completed approved the box yet
    % show the image
    imshow(frame1);
    disp('Click to specify 2 diagonal corners of your cropping area');
    
    [x y] = ginput(2); % waits for 2 clicks on the image then records the 
    % coordinates of those 2 points

    hold on % pauses until box drawn

    % Draw the box:
    plot([x(1), x(1), x(2) x(2), x(1)], [y(1), y(2), y(2), y(1), y(1)], 'r-', 'LineWidth', 2);

    % waits for user input -- if good, type a "1" and will break out of the
    % while loop:
    done = input('Is this a good crop? 1 = yes, 0 = no');
    
    if ~done % if you didn't approve the box you drew, goes back to the beginning of the while-loop
        disp('Try drawing a new box');
        continue;
    end
    
    % Otherwise (you approved the box), go on to the next step:
    close all 
    
    % Now that you have a good usable area, loop through the video's frames 
    % to crop the video to just this area:

    % Get extrema in more usable format (because that way don't have to
    % regulate which point you click first, etc.):
    xmin = round(min(x));
    ymin = round(min(y));

    xmax = round(max(x));
    ymax = round(max(y));

    % Loop through the frames and crop them as specified:
    for z = 1:vidObj.NumberOfFrames 
        % Read in the current frame:
        vid(z).data = read(vidObj, z);   

        vid(z).cropped = vid(z).data(ymin:ymax, xmin:xmax, :);
    end




    % Show the resulting crop:
    imshow(vid(1).cropped);
    
    % ask for input: is this good? If not, will go back to the beginning
    % and you have to draw a new box
    done1 = input('Write the cropped movie with this first frame? 1 = yes, 0 = no');

    if ~ done1 % you didn't like the cropping after all -- go back to the beginning
        disp('Try drawing the box again.');
        continue;
    end
    
    % otherwise (you liked the cropping), go on to the next step
    
    % Write the new, cropped video:
    disp('crop approved. Now watch a preview of the cropped video and decide whether you still want this cropping.');
    % write the cropped movie
    % get some useful names:
    vidFileSplit = strsplit(vidFileName, '\');
    currVid = char(vidFileSplit(end)); % grab just the file name (not the full path)
    
    % new name for filenaming purposes:
    vidName = strsplit(currVid, '.');
    croppedFile = strcat(char(vidName(1)), '_usableArea');
    vid_cropped = VideoWriter(croppedFile, 'MPEG-4');
    
    % write it and play at the same time:
    open(vid_cropped);
    for y = 1:vidObj.NumberOfFrames
        imshow(vid(y).cropped); % I think this is just to do a spot-check on the cropping
        writeVideo(vid_cropped, vid(y).cropped);
    end
    close(vid_cropped); % if you don't close here, program can't write a 
    % new video in the case where you don't like the final cropping and
    % want to go back to redo it.
    
    % Get final user input --> now that you've seen it, should you save it?
    done2 = input('Save this cropped video? 1 = yes, 0 = no');
    
    if ~ done2 % you didn't like the cropping after all
        disp('Try drawing the box again');
        % Move the file to the "delete" directory
        movefile(strcat(croppedFile, '.mp4'), delDir);
        continue;
    end
    
    % Otherwise (you liked the crop and want to save the video), go on to
    % the next step:
    close all
    % Then move it to the saveDir
    movefile(strcat(croppedFile, '.mp4'), saveDir);
end






