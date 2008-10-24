function handles = LoadSingleImage(handles)

% Help for the Load Single Image module:
% Category: File Processing
%
% SHORT DESCRIPTION:
% Loads a single image, which will be used for all image cycles.
% *************************************************************************
% Note: for most purposes, you will probably want to use the Load Images
% module, not this one.
%
% Tells CellProfiler where to retrieve a single image and gives the image a
% meaningful name for the other modules to access.  The module only
% functions the first time through the pipeline, and thereafter the image
% is accessible to all subsequent cycles being processed. This is
% particularly useful for loading an image like an Illumination correction
% image to be used by the CorrectIllumination_Apply module. Note: Actually,
% you can load four 'single' images using this module.
%
% Relative pathnames can be used. For example, on the Mac platform you
% could leave the folder where images are to be loaded as '.' to choose the
% default image folder, and then enter ../Imagetobeloaded.tif as the name
% of the file you would like to load in order to load the image from the
% directory one above the default image directory. Or, you could type
% .../AnotherSubfolder (note the three periods: the first is interpreted as
% a standin for the default image folder) as the folder from which images
% are to be loaded and enter the filename as Imagetobeloaded.tif to load an
% image from a different subfolder of the parent of the default image
% folder.  The above also applies for '&' with regards to the default
% output folder.
%
% If more than four single images must be loaded, more than one Load Single
% Image module can be run sequentially. Running more than one o f these
% modules also allows images to be retrieved from different folders.
%
% LoadImages can now open and read .ZVI files.  .ZVI files are Zeiss files
% that are generated by the microscope imaging software, Axiovision.  These
% images are stored with 12-bit precision.  Currently, this will not work
% with stacked or color images.
%
% See also LoadImages.

% CellProfiler is distributed under the GNU General Public License.
% See the accompanying file LICENSE for details.
%
% Developed by the Whitehead Institute for Biomedical Research.
% Copyright 2003,2004,2005.
%
% Please see the AUTHORS file for credits.
%
% Website: http://www.cellprofiler.org
%
% $Revision$

%%%%%%%%%%%%%%%%%
%%% VARIABLES %%%
%%%%%%%%%%%%%%%%%
drawnow

[CurrentModule, CurrentModuleNum, ModuleName] = CPwhichmodule(handles);

%textVAR01 = This module loads one image for *all* cycles that will be processed. Typically, however, a different module (LoadImages) is used to load new sets of images during each cycle of processing.

%pathnametextVAR02 = Enter the path name to the folder where the images to be loaded are located.  Type period (.) for the default image folder, or type ampersand (&) for the default output folder.
Pathname = char(handles.Settings.VariableValues{CurrentModuleNum,2});

%filenametextVAR03 = What image file do you want to load? Include the extension, like .tif
TextToFind{1} = char(handles.Settings.VariableValues{CurrentModuleNum,3});

%textVAR04 = What do you want to call that image?
%defaultVAR04 = OrigBlue
%infotypeVAR04 = imagegroup indep
ImageName{1} = char(handles.Settings.VariableValues{CurrentModuleNum,4});

%filenametextVAR05 = What image file do you want to load? Include the extension, like .tif
TextToFind{2} = char(handles.Settings.VariableValues{CurrentModuleNum,5});

%textVAR06 = What do you want to call that image?
%defaultVAR06 = Do not use
%infotypeVAR06 = imagegroup indep
ImageName{2} = char(handles.Settings.VariableValues{CurrentModuleNum,6});

%filenametextVAR07 = What image file do you want to load? Include the extension, like .tif
TextToFind{3} = char(handles.Settings.VariableValues{CurrentModuleNum,7});

%textVAR08 = What do you want to call that image?
%defaultVAR08 = Do not use
%infotypeVAR08 = imagegroup indep
ImageName{3} = char(handles.Settings.VariableValues{CurrentModuleNum,8});

%filenametextVAR09 = What image file do you want to load? Include the extension, like .tif
TextToFind{4} = char(handles.Settings.VariableValues{CurrentModuleNum,9});

%textVAR10 = What do you want to call that image?
%defaultVAR10 = Do not use
%infotypeVAR10 = imagegroup indep
ImageName{4} = char(handles.Settings.VariableValues{CurrentModuleNum,10});

%%%VariableRevisionNumber = 4

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PRELIMINARY CALCULATIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
drawnow
if handles.Current.SetBeingAnalyzed == 1
    %%% Determines which cycle is being analyzed.
    SetBeingAnalyzed = handles.Current.SetBeingAnalyzed;

    %%% Remove slashes '/' from the input
    tmp1 = {};
    tmp2 = {};
    for n = 1:4
        if ~strcmp(TextToFind{n}, 'Do not use') && ~strcmp(ImageName{n}, 'Do not use')
            tmp1{end+1} = TextToFind{n};
            tmp2{end+1} = ImageName{n};
        end
    end
    TextToFind = tmp1;
    ImageName = tmp2;

    %%% Get the pathname and check that it exists
    if strncmp(Pathname,'.',1)
        if length(Pathname) == 1
            Pathname = handles.Current.DefaultImageDirectory;
        else
            Pathname = fullfile(handles.Current.DefaultImageDirectory,Pathname(2:end));
        end
    elseif strncmp(Pathname, '&', 1)
        if length(Pathname) == 1
            Pathname = handles.Current.DefaultOutputDirectory;
        else
            Pathname = fullfile(handles.Current.DefaultOutputDirectory,Pathname(2:end));
        end
    end

    SpecifiedPathname = Pathname;
    if ~exist(SpecifiedPathname,'dir')
        error(['Image processing was canceled in the ', ModuleName, ' module because the directory "',SpecifiedPathname,'" does not exist. Be sure that no spaces or unusual characters exist in your typed entry and that the pathname of the directory begins with / (for Mac/Unix) or \ (for PC).'])
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% FIRST CYCLE FILE HANDLING %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    drawnow

    if isempty(ImageName)
        error(['Image processing was canceled in the ', ModuleName, ' module because you have not chosen any images to load.'])
    end

    for n = 1:length(ImageName)
        %%% This try/catch will catch any problems in the load images module.
        try
            CurrentFileName = TextToFind{n};
            %%% The following runs every time through this module (i.e. for
            %%% every cycle).
            %%% Saves the original image file name to the handles
            %%% structure.  The field is named appropriately based on
            %%% the user's input, in the Pipeline substructure so that
            %%% this field will be deleted at the end of the analysis
            %%% batch.
            fieldname = ['Filename', ImageName{n}];
            handles.Pipeline.(fieldname) = CurrentFileName;
            fieldname = ['Pathname', ImageName{n}];
            handles.Pipeline.(fieldname) =  Pathname;

            FileAndPathname = fullfile(Pathname, CurrentFileName);
            LoadedImage = CPimread(FileAndPathname);
            %%% Saves the image to the handles structure.
            handles.Pipeline.(ImageName{n}) = LoadedImage;

        catch
            CPerrorImread(ModuleName, n);
        end % Goes with: catch

        % Create a cell array with the filenames
        FileNames(n) = {CurrentFileName};
    end



    %%%%%%%%%%%%%%%%%%%%%%%
    %%% DISPLAY RESULTS %%%
    %%%%%%%%%%%%%%%%%%%%%%%
    drawnow

    ThisModuleFigureNumber = handles.Current.(['FigureNumberForModule',CurrentModule]);
    if any(findobj == ThisModuleFigureNumber)
        if handles.Current.SetBeingAnalyzed == handles.Current.StartingImageSet
            CPresizefigure('','NarrowText',ThisModuleFigureNumber)
        end
        for n = 1:length(ImageName)
            drawnow
            %%% Activates the appropriate figure window.
            currentfig=CPfigure(handles,'Text',ThisModuleFigureNumber);
            if iscell(ImageName)
                TextString = [ImageName{n},': ',FileNames{n}];
            else
                TextString = [ImageName,': ',FileNames];
            end
            uicontrol(currentfig,'style','text','units','normalized','fontsize',handles.Preferences.FontSize,'HorizontalAlignment','left','string',TextString,'position',[.05 .85-(n-1)*.15 .95 .1],'BackgroundColor',[.7 .7 .9])
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% SAVE DATA TO HANDLES %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for n = 1:length(ImageName)*handles.Current.NumberOfImageSets,
        handles = CPaddmeasurements(handles, 'Image', ['FileName_', ImageName{n}], TextToFind{n});
        handles = CPaddmeasurements(handles, 'Image', ['PathName_', ImageName{n}], Pathname);
    end
end
