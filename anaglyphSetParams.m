function [rgbParamsL,rgbParamsR] = anaglyphSetParams(stereoMode)
% anaglyphSetParams([stereoMode=9])
%
% A small utility script that can be run to determine individualised colour
% channel gains for anaglyph stereo. In order to be able to do this
% on-the-fly, the Psychtoolbox imaging pipeline is enabled. It first 
% callibrates the left eye and then the right eye. Finally, the gains 
% for each eye are reported. Gains are set using the method specified in
% Mulligan (1988).
%
% Press the 'q', 'w' and 'e' keys to increase and the 'a', 's' and 'd' keys
% to decrease the gain settings for the red, green and blue channels 
% respectively. Once crosstalk has been minimalised between the eyes, press
% the spacebar to move on to the next callibration.
%
% When adjusting the gains for the left filter (first instance), view through
% right filter - adjust gains until you only see a horizontal contour, then
% press space. The program will move on to adjusting gains for the right
% filter (second instance) - view through the left filter and adjust gains
% until you only see a vertical contour. Again, press space when finished.
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

[keyboardIndices] = GetKeyboardIndices;
keyboardIndex = max(keyboardIndices);

% Specify screen res
res = [1024 1280];

% Define the centre
xcen = res(1)/2;
ycen = res(2)/2;

% Let's try the PsychImaging pipeline
PsychImaging('PrepareConfiguration');

% Set interval to 1
leftGainSetting=0;
rightGainSetting=0;
rgbParamsL = [0.0 0.5 0.5]; % Default cyan parameters
rgbParamsR = [1.0 0.0 0.0]; % Default red parameters

% Get the screen numbers, then draw to external screen.
screens = Screen('Screens');
screenNumber = max(screens);

% Define colors (white will be 1 and black 0). This is because
% in general luminace values are defined between 0 and 1 with 255 steps in
% between. All values in Psychtoolbox are defined between 0 and 1
white = WhiteIndex(screenNumber);
grey = white / 2;

% Open an on screen window using PsychImaging and color it grey.
[windowPtr]=PsychImaging('OpenWindow', screenNumber, grey, [], [], [], stereoMode);
HideCursor;

% Show cleared start screen:
Screen('Flip', windowPtr);
        
% Drawing rectangle (clockwise from top-left)
rectWhite = [xcen-100, ycen-100, xcen, ycen];
rectRed = [xcen, ycen-100, xcen+100, ycen];
rectGrey = [xcen, ycen, xcen + 100, ycen+100];
rectCyan = [xcen-100, ycen, xcen, ycen+100];
rectMatrix = vertcat(rectWhite,rectRed,rectGrey,rectCyan)'; % matrix of rects for 'FillRect' command
rectColors = horzcat(ones(3,2)*white,ones(3,1)*grey,ones(3,1)*white); % matrix of rect colours (white, white, grey, white clockwise from top-left)

% Timing and stimulus presentation loop
SetAnaglyphStereoParameters('LeftGains', windowPtr, rgbParamsL);
SetAnaglyphStereoParameters('RightGains', windowPtr, rgbParamsR);
keyCode=zeros(1,256);
keyIsDown=0;

while leftGainSetting == 0
    (keyIsDown (~keyCode(upr) & ~keyCode(downr) & ~keyCode(upg) & ~keyCode(downg) & ~keyCode(upb) & ~keyCode(downb)));
    [keyIsDown,~,keyCode] = KbCheck(keyboardIndex);
    KbReleaseWait(keyboardIndex);
    
    % Select left-eye image buffer for drawing:
    % Test stimulus
    Screen('SelectStereoDrawBuffer', windowPtr, 0);
    Screen(windowPtr, 'FillRect', rectColors(:,[1,3,4]), rectMatrix(:,[1,3,4])); % White rect

    % Select right-eye image buffer for drawing:
    % Test stimulus
    Screen('SelectStereoDrawBuffer', windowPtr, 1);
    Screen(windowPtr, 'FillRect', rectColors(:,[1,2,3]), rectMatrix(:,[1,2,3])); % White rect

    
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
    (keyIsDown (~keyCode(upr) & ~keyCode(downr) & ~keyCode(upg) & ~keyCode(downg) & ~keyCode(upb) & ~keyCode(downb)));
    [keyIsDown,~,keyCode] = KbCheck(keyboardIndex);
    KbReleaseWait(keyboardIndex);
    
    % Select left-eye image buffer for drawing:
    % Test stimulus
    Screen('SelectStereoDrawBuffer', windowPtr, 0);
    Screen(windowPtr, 'FillRect', rectColors(:,[1,3,4]), rectMatrix(:,[1,3,4])); % White rect

    % Select right-eye image buffer for drawing:
    % Test stimulus
    Screen('SelectStereoDrawBuffer', windowPtr, 1);
    Screen(windowPtr, 'FillRect', rectColors(:,[1,2,3]), rectMatrix(:,[1,2,3])); % White rect
    
    % Wait for response; could be any of seven keys
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

% Clear the screen.
sca;
ShowCursor;
ListenChar(1);