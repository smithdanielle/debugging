function [rgbParamsL,rgbParamsR] = anaglyphSetParams(stereoMode)
% anaglyphSetParams([stereoMode=9])
%
% A small utility script that can be run to determine individualised colour
% channel gains for anaglyph stereo. In order to be able to do this
% on-the-fly, the Psychtoolbox imaging pipeline is enabled. It first 
% callibrates the left eye and then the right eye. A stereoscopic rectangle
% is then shown after gains have been set for both eyes. Finally, the gains 
% for each eye are reported.
%
% Press the 'q', 'w' and 'e' keys to increase and the 'a', 's' and 'd' keys
% to decrease the gain settings for the red, green and blue channels 
% respectively. Once crosstalk has been minimalised between the eyes, press
% the spacebar to move on to the next callibration.
%
% Optional parameters:
% 'stereoMode' specifies the type of stereo display algorithm to use:
%
% 0 == Mono display - No stereo at all.
%
% 6-9 == Different modes of anaglyph stereo for color filter glasses:
%
% 6 == Red-Green
% 7 == Green-Red
% 8 == Red-Blue
% 9 == Blue-Red
%
% Author:
% Danielle Smith - lpxds5 at nottingham.ac.uk

Screen('Preference', 'SkipSyncTests', 1);

% Default to stereoMode 9 -- Blue-Red stereo:
if nargin < 1
    stereoMode = 9;
end

AssertOpenGL;
ListenChar(2);

% Define response key mappings, unify the names of keys across operating
% systems:
KbName('UnifyKeyNames');
upr = KbName('q');
downr = KbName('a');
upg = KbName('w');
downg = KbName('s');
upb = KbName('e');
downb = KbName('d');
space = KbName('space');
escapeKey = KbName('ESCAPE');


% Specify screen res
res = [1024 1280];

% Let's try the PsychImaging pipeline
PsychImaging('PrepareConfiguration');

% Specify colours
grey = [190 190 190];
white = [255 255 255];
black = [0 0 0];

% Define the centre
xcen = res(1)/2;
ycen = res(2)/2;

% Set interval to 1
leftGainSetting=0;
rightGainSetting=0;
rgbParamsL = [1.0 0.0 0.0]; % Default red parameters
rgbParamsR = [0.0 0.5 0.5]; % Default cyan parameters
 
% How many screens? Check for use of stereomode
screens=Screen('Screens');
screenNumber=max(screens);

% Open my screen: (open, window, color, size, color-bits, buffer, stereomode,
% multisample-mode)
% Open double-buffered onscreen window with the requested stereo mode:
[windowPtr, windowRect]=PsychImaging('OpenWindow', screenNumber, grey, [], [], [], stereoMode);
HideCursor;

% Show cleared start screen:
Screen('Flip', windowPtr);
        
% Drawing rectangle
rect1 = [xcen-50, ycen-100, xcen+25, ycen+100];
rect2 = [xcen-25, ycen-100, xcen+50, ycen+100];

% Timing and stimulus presentation loop
SetAnaglyphStereoParameters('LeftGains', windowPtr, rgbParamsL);
SetAnaglyphStereoParameters('RightGains', windowPtr, rgbParamsR);
[keyIsDown,secs,keyCode] = KbCheck;
keyCode=zeros(1,256);
keyIsDown=0;

% Show the test stimulus until finish key is pressed
while leftGainSetting == 0
    (keyIsDown || (~keyCode(upr) & ~keyCode(downr) & ~keyCode(upg) & ~keyCode(downg) & ~keyCode(upb) & ~keyCode(downb)));
    [keyIsDown,secs,keyCode] = KbCheck;
    KbReleaseWait;
    
    % Select left-eye image buffer for drawing:
    % Test stimulus
    Screen('SelectStereoDrawBuffer', windowPtr, 0);
    Screen(windowPtr, 'FillRect', white, rect1); % White rect

    % Select right-eye image buffer for drawing:
    % Test stimulus
    Screen('SelectStereoDrawBuffer', windowPtr, 1);
    
    % Wait for response; could be any of seven keys
    if keyIsDown
        if keyCode(upr)
            rgbParamsL(1) = rgbParamsL(1)+0.1;
        elseif keyCode(downr)
            rgbParamsL(1) = rgbParamsL(1)-0.1;
        elseif keyCode(upg)
            rgbParamsL(2) = rgbParamsL(2)+0.1;
        elseif keyCode(downg)
            rgbParamsL(2) = rgbParamsL(2)-0.1;
        elseif keyCode(upb)
            rgbParamsL(3) = rgbParamsL(3)+0.1;
        elseif keyCode(downb)
            rgbParamsL(3) = rgbParamsL(3)-0.1; 
        elseif keyCode(space)
            leftGainSetting = 1;
        end
    end
   SetAnaglyphStereoParameters('LeftGains', windowPtr, rgbParamsL);
   
   % Now show it
   Screen(windowPtr,'Flip');
end  % End of run

keyIsDown = 0;

% Show the test and ref stimulus for stim_time secs
while rightGainSetting == 0
    (keyIsDown || (~keyCode(upr) & ~keyCode(downr) & ~keyCode(upg) & ~keyCode(downg) & ~keyCode(upb) & ~keyCode(downb)));
    [keyIsDown,secs,keyCode] = KbCheck;
    KbReleaseWait;
    
    % Select left-eye image buffer for drawing:
    % Test stimulus 
    Screen('SelectStereoDrawBuffer', windowPtr, 0);

    % Select right-eye image buffer for drawing:
    % Test stimulus
    Screen('SelectStereoDrawBuffer', windowPtr, 1);
    Screen(windowPtr, 'FillRect', white, rect2); % White rect
    if keyIsDown
        if keyCode(upr)
            rgbParamsR(1) = rgbParamsR(1)+0.1;
        elseif keyCode(downr)
            rgbParamsR(1) = rgbParamsR(1)-0.1;
        elseif keyCode(upg)
            rgbParamsR(2) = rgbParamsR(2)+0.1;
        elseif keyCode(downg)
            rgbParamsR(2) = rgbParamsR(2)-0.1;
        elseif keyCode(upb)
            rgbParamsR(3) = rgbParamsR(3)+0.1;
        elseif keyCode(downb)
            rgbParamsR(3) = rgbParamsR(3)-0.1; 
        elseif keyCode(space)
            rightGainSetting = 1;
        end
    end
   SetAnaglyphStereoParameters('RightGains', windowPtr, rgbParamsR);
   
   % Now show it
   Screen(windowPtr,'Flip');
end  % End of timed run

keyIsDown = 0;

% Show the test and ref stimulus for 5 secs
tic
while toc<5
    % Select left-eye image buffer for drawing:
    % Test stimulus
    Screen('SelectStereoDrawBuffer', windowPtr, 0);
    Screen(windowPtr, 'FillRect', white, rect1); % White rect

    % Select right-eye image buffer for drawing:
    % Test stimulus
    Screen('SelectStereoDrawBuffer', windowPtr, 1);
    Screen(windowPtr, 'FillRect', white, rect2); % White rect

    % Now show it
    Screen(windowPtr,'Flip');
end  % End of timed run

% Now turn all the expt screens off
Screen('CloseAll');
ShowCursor;
ListenChar(1);

% We're done.
return;