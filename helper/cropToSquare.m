function im_crop = cropToSquare(im)

% get the size
imRows = size(im,1);
imCols = size(im,2);

% find the center
centerR = round(imRows/2);
centerC =  round(imCols/2);


% if it's already square:
if imRows==imCols
    im_crop = im;
    
% else if it's wider than a square    
elseif imRows<imCols 
    rad = floor(imRows/2) - 1; % just to be safe, minus 1
    im_crop = im((centerR-rad):(centerR+rad),(centerC-rad):(centerC+rad),:);
    
% else if it's taller than a square
else
    rad = floor(imCols/2) - 1; % just to be safe, minus 1
    im_crop = im((centerR-rad):(centerR+rad),(centerC-rad):(centerC+rad),:);
    
end