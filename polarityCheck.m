function [correctPolarity] = polarityCheck(stereoMode, usedatapixx)
% polarityCheck([stereoMode=1][, usedatapixx=0])
%
% Debugging script that aims to determine if polarity is set correctly by 
% the system. If everything is working, the left eye should see a a vertical
% contour that is equiluminant throughought, and the right eye should see a
% horizontal contour. This script can also be used to check for crosstalk, 
% by measuring the luminance of a part of the screen that can only be seen
% through the opposite eye's view. Viewing is set up similar to Mulligan (1988).
%
% When viewing the stimulus, switch the viewing eye until you are sure that
% polarity is correct
%
% If polarity is correct, the observer is instructed to press the 'y' key and
% at the end of the script the `correctPolarity` variable reports 'TRUE'.
% If polarity is abnormal, the observer presses 'n' and `correctPolarity` is 
% set to 'FALSE'.
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
% 'usedatapixx' If provided and set to a non-zero value, will setup a
% connected VPixx DataPixx device for stereo display.
%
% Author:
% Danielle Smith - lpxds5 at nottingham.ac.uk

% Default to stereoMode 1 -- Flip-frame (temporally interleaved) stereo:
if nargin < 1
    stereoMode = 1;
end

if nargin < 2
    usedatapixx = 0;
end

AssertOpenGL;
ListenChar(2);

% Define response key mappings, unify the names of keys across operating
% systems:
KbName('UnifyKeyNames');
yesKey = KbName('y');
noKey = KbName('n');
escape = KbName('ESCAPE');

[keyboardIndices] = GetKeyboardIndices;
keyboardIndex = max(keyboardIndices);

% Specify screen res
res = [1024 768];

% Define the centre
xcen = res(1)/2;
ycen = res(2)/2;

% Let's try the PsychImaging pipeline
PsychImaging('PrepareConfiguration');

if usedatapixx == 1
    % Tell PTB we want to display on a DataPixx device:
    PsychImaging('AddTask', 'General', 'UseDataPixx');
end

% Get the screen numbers, then draw to external screen.
screens = Screen('Screens');
screenNumber = max(screens);

% Define colors (white will be 1 and black 0). This is because
% in general luminace values are defined between 0 and 1 with 255 steps in
% between. All values in Psychtoolbox are defined between 0 and 1
white = WhiteIndex(screenNumber);
grey = white / 2;

% Open an on screen window using PsychImaging and color it grey.
[windowPtr]=PsychImaging('OpenWindow', screenNumber, [grey 0 0], [], [], [], stereoMode);

if usedatapixx == 1
    % Set up Datapixx shutter glasses:
    SetStereoBlueLineSyncParameters(windowPtr, res(2)-0); % must be zero, DATAPixx is strict about scanline position
    Datapixx('SetVideoStereoVesaWaveform', 2); % If driving NVIDIA glasses
end

% Adjust left and right eye gains if using anaglyph stereo
if stereoMode == 9
    rgbParamsL = [0.0 0.4 0.4]; % Optimal cyan parameters for Dell 1901fp
    rgbParamsR = [0.6 0.0 0.0]; % Optimal red parameters for Dell 1901fp
    SetAnaglyphStereoParameters('LeftGains', windowPtr, rgbParamsL);
    SetAnaglyphStereoParameters('RightGains', windowPtr, rgbParamsR);
end
HideCursor;

% Show cleared start screen:
Screen('Flip', windowPtr);

% Drawing rectangle (clockwise from top-left)
rectWhite = [xcen-100, ycen-100, xcen, ycen];
rectRight = [xcen, ycen-100, xcen+100, ycen];
rectGrey = [xcen, ycen, xcen + 100, ycen+100];
rectLeft = [xcen-100, ycen, xcen, ycen+100];
rectMatrix = vertcat(rectWhite,rectRight,rectGrey,rectLeft)'; % matrix of rects for 'FillRect' command
if usedatapixx
    rectColors = [white white grey white; 0 0 0 0; 0 0 0 0]; %matrix of rect colors using RED GUN ONLY (white, white, grey, white clockwise from top-left)
else
    rectColors = horzcat(ones(3,2)*white,ones(3,1)*grey,ones(3,1)*white); % matrix of rect colours (white, white, grey, white clockwise from top-left)
end
%%%%%%%%%% Timing and stimulus presentation loop %%%%%%%%%%%%%%%%%%%%%%%%%%
keyCode=zeros(1,256);
keyIsDown=0;

% Run until a key is pressed
while ~any(keyIsDown)
    % Select left-eye image buffer for drawing - observer should see a vertical line:
    Screen('SelectStereoDrawBuffer', windowPtr, 0);
    Screen(windowPtr, 'FillRect', rectColors(:,[1,3,4]), rectMatrix(:,[1,3,4])); % White rect
    Screen('TextFont', windowPtr, 'Arial');
    Screen('TextSize', windowPtr, 20);
    DrawFormattedText(windowPtr, 'Does the left eye see a vertical contour\n\n AND\n\n right eye a horizontal contour?\n\n\n Press [Y] for yes and [N] for no.', 'center', xcen+30, white);
    
    % Select right-eye image buffer for drawing - observer should see a horizontal line:
    Screen('SelectStereoDrawBuffer', windowPtr, 1);
    Screen(windowPtr, 'FillRect', rectColors(:,[1,2,3]), rectMatrix(:,[1,2,3])); % White rect
    Screen('TextFont', windowPtr, 'Arial');
    Screen('TextSize', windowPtr, 20);
    DrawFormattedText(windowPtr, 'Does the left eye see a vertical contour\n\n AND\n\n right eye a horizontal contour?\n\n\n Press [Y] for yes and [N] for no.', 'center', xcen+30, white);
    
    % Now show it
    Screen('Flip', windowPtr);
    
    % Keyboard queries and key handling 
    (keyIsDown (~keyCode(yesKey) & ~keyCode(noKey) & ~keyCode(escape)));
    [keyIsDown,~,keyCode] = KbCheck(keyboardIndex);
    
    if keyIsDown
        if keyCode(yesKey)
            KbReleaseWait(keyboardIndex);
            correctPolarity = 'TRUE';
        elseif keyCode(noKey)
            KbReleaseWait(keyboardIndex);
            correctPolarity = 'FALSE';
        elseif keyCode(escape)
            break;
        end
    end
end

% Final flip
Screen('Flip', windowPtr);

% Clear the screen.
sca;
ShowCursor;
ListenChar(1);

% We're done.
%return;



    
