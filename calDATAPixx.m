
function calMat = dsCalDATAPixx()

%original code by ZH to read and control PhotoResearch PR 655 
%modified by D Smith 2014 annotated by H Allen April 2014
%HA: Needs: three readings and mode for each luminance value
%HA why not add gamma fit??

clear all;
timeout=30;
stimpix = 256;
rgbBackground = [190 190 190];
rgbIndex = [0,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100,105,110,115,120,125,135,145,155,165,175,185,195,205,215,225,235,245,255];
% rgbIndex = [0, 100, 250];
randOrder = randperm(length(rgbIndex));
calMat = zeros(length(rgbIndex), 2);
N=zeros(1,1);
Lum=N;

oldEnableFlag = Screen('Preference', 'SuppressAllWarnings', 1);
screenNumber = max(Screen('Screens'));
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible')
PsychImaging('AddTask', 'General', 'UseDataPixx');
%PsychImaging('AddTask', 'General', 'EnableDataPixxL48Output');

possible.loadLUT = {'y','n'};
loadLUT = [];
WaitSecs(0.5); % wait a moment...

while ~strcmp(loadLUT, possible.loadLUT)
    loadLUT = input('Do you want to load a custom LUT [y] or [n]:', 's');
end

% PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');

fprintf('\n(calibration)$ please set the display to the desired spatial and temporal resolution\n')
fprintf('(calibration)$ hit any key to continue...\n');
WaitSecs(0.1);
while(KbCheck==0)
end;

fprintf('\n(calibration)$ turn on the photometer...\n');
fprintf('(calibration)$ hit any key to continue...\n');
WaitSecs(0.5);
while(KbCheck==0)
end;
fprintf('initializing photometer..c.\n');

retval = PR655init('/dev/ttyACM0');  % initialize the photometer

% Opens a window.
	screens=Screen('Screens');
	white=WhiteIndex(screenNumber);
	black=BlackIndex(screenNumber);
    gray=round((white+black)/2);
	if gray==white
		gray=black;
    end
    
% Open a double buffered fullscreen window and draw a gray background 
% % to front and back buffers:
% WaitSecs(1);
[window screenRect] = PsychImaging('OpenWindow', screenNumber, 127);

% Setting up the LUT
if strcmp(loadLUT, 'y')
%    filename = uigetfile;
    customLUT = load('customLUT_p225f_280115.mat');
elseif strcmp(loadLUT, 'n')
    L=[0:1/255:1]';
    LUTCalibPTB3=[L,L,L];
    [LUTT]=LUTCalibPTB3;
end

Screen('FillRect',window, rgbBackground);
Screen('Flip', window);
 
% Load the LUT
% if strcmp(loadLUT, 'y')
%     PsychColorCorrection('SetLookupTable', window, customLUT.Lut);
% elseif strcmp(loadLUT, 'n')
%     PsychColorCorrection('SetLookupTable', window, LUTT);
% end


% Load the LUT
if strcmp(loadLUT, 'y')
     Screen('LoadNormalizedGammaTable', window, customLUT.Lut);
elseif strcmp(loadLUT, 'n')
    Screen('LoadNormalizedGammaTable', window, LUTT);
 end

% get & record screen properties
hz=Screen('NominalFrameRate', screenNumber);
fprintf('>>> display frame rate (Hz) = %g\n',hz);
pixelSize=Screen('PixelSize', screenNumber);
fprintf('>>> pixel size = %g\n',pixelSize);

[widthPixels, heightPixels]=Screen('WindowSize', screenNumber);
fprintf('>>> display size (pixels)[width, height] = [%g,%g]\n',widthPixels,heightPixels);
%[widthcm,heightcm] = pbGetScreenDimensions(whichScreen);


center = [screenRect(3) screenRect(4)]/2;	% coordinates of screen center (pixels)
fps=Screen('FrameRate',window);      % frames per second
% if(fps==0)
%         fps=67;
%         fprintf('WARNING: using default frame rate of %i Hz\n',fps);
%     end;
% ifi=Screen('GetFlipInterval', w);

% ---------- Image Setup ----------
stimrect=SetRect(0,0,stimpix,stimpix);
destRect=CenterRect(stimrect,screenRect);
Screen('FillRect',window,rgbBackground,destRect);
Screen('FillOval',window,[0 0 0],destRect);			
Screen('DrawText',window,'Center photometer on stimulus area and hit a key to continue..', 300, 200);
vbl=Screen('Flip', window,1);
meas1=PR655rawxyz(30);

fprintf('\n\n>>> center photometer on stimulus area and hit a key to continue...\n');

while(KbCheck==0)
end;
% Screen('CloseAll');
Screen('Preference','SuppressAllWarnings',oldEnableFlag);


for curRGB=1:length(rgbIndex)
      Screen('FillRect',window,rgbBackground,destRect);
      vbl=Screen('Flip', window,0);
      WaitSecs(1.5);
      ktmp=randOrder(curRGB);
      %ktmp=curRGB;
      curRGBnumber=rgbIndex(ktmp);
      V = rgbIndex(ktmp);
      rgb = [V V V];
      Priority(MaxPriority(window));
      Screen('FillRect',window,rgbBackground);
      Screen('FillOval',window,rgb,destRect);
      vbl=Screen('Flip', window,0);
      WaitSecs(0.2);
      meas = PR655rawxyz(timeout);
%        WaitSecs(30);
        rr = str2num(meas);
        L = rr(3);
%         
        calMat(curRGB,1)= V;
        calMat(curRGB,2)= L;
        N(ktmp)=curRGBnumber;
        Lum(ktmp)=L;
 		fprintf('RGB = [%3i,%3i,%3i]; luminance = %6.2f; rgbIndex = %g\n',rgb(1),rgb(2),rgb(3),L,curRGBnumber);
        WaitSecs(0.1);

         if KbCheck
            abortFlag=1;
            break;
        end;

	end;
    
    PR655close;
    
    Screen('CloseAll');
    Screen('Preference','SuppressAllWarnings',oldEnableFlag);   
	% Restores the mouse cursor.
	ShowCursor;
    Datapixx('Close')
    
    save calMat calMat;
    csvwrite('calMat.csv',calMat);
    
    sca

end


    
