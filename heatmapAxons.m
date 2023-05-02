% get the directory to quantification results
basepath = uigetdir('select animal folder'); 
respath = [basepath, filesep, '_heatplot results'];
if ~exist(respath, 'dir')
    mkdir(respath);
end

%get gaussian filter for all images
    prompt = {'Enter sigma for gaussian filter'};
    dlgtitle = 'Input';
    dims = [1 35];
    definput = {'5.0'};
    userInputSigma = inputdlg(prompt,dlgtitle,dims,definput); 
    [xG, yG] = meshgrid(-5:5);
    sigma = str2num(string(userInputSigma));
    g = exp(-xG.^2./(2.*sigma.^2)-yG.^2./(2.*sigma.^2));
    g = g./sum(g(:));
    
% load all tif files from directory
imgfiles = dir(fullfile(basepath, 'Thresholded Images', '*.tif')); 
nfiles = length(imgfiles); %number of files found

for ii = 1:nfiles
    currentfilename = imgfiles(ii).name;
    data = importdata(string(currentfilename));

    resizedimg = imresize(data.cdata, 0.2);

    % smooth data and create heat map
    density = conv2(resizedimg, g, 'same');
    rescaleddens = rescale(density);
    fig = imagesc(rescaleddens);  
    colorbar;

    % Save Figure as Tiff File (Not Compressed)
    heatMapName = [currentfilename '' '_' 'heatmap'];
    saveas(fig,[respath filesep heatMapName],'tiffn');

end