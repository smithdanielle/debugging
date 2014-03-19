% photodiodeTest.m
% Checks the refresh rate of both CRT screens and stereogoggles
% Created by Danielle Smith on 2/14

close all; clear all
sca;

% Specify screen parameters, including resolution, distance and width
% Measurements in millimeters
screenParams.Distance = 1200;
screenParams.Width = 300;
% Measurements in pixels
screenParams.Res = [1024 1280];

% Are we using the Datapixx?
usedatapixx=0;

% Specify stereomode
% Which stereomode to use
stereoMode=0;      % Default, no stereo at all.
%stereoMode=1;     % Stereogoggles alternate frames
%stereoMode=5;      % Set up for left-right viewing, L on R x-fusion
%stereoMode=9;       % Blue-red anaglyph
%stereoMode=10;    % Set up for 2 screen/stereoscope stereomode

AssertOpenGL;
HideCursor;
ListenChar(2);

% Kludge to force to work despite dodgy refresh
Screen('Preference', 'SkipSyncTests', 1);

% How many screens? Check for use of stereomode
screens=Screen('Screens');
screenNumber = max(screens);

% Specify colours
white = WhiteIndex(screenNumber);
grey = GrayIndex(screenNumber);
black = BlackIndex(screenNumber);

% Let's try the PsychImaging pipeline
PsychImaging('PrepareConfiguration');

if usedatapixx == 1
    % Tell PTB we want to display on a DataPixx device:
    PsychImaging('AddTask', 'General', 'UseDataPixx');
    SetStereoBlueLineSyncParameters(win, windowRect(4)-0); % must be zero, DATAPixx is strict about scanline position
    Datapixx('SetVideoStereoVesaWaveform', 2); % If driving NVIDIA glasses
    
   if stereoMode == 1
       % Set the LUT for the Datapixx to only use the red gun
       %%% HOW DO I DO THIS %%%?
   end
end

% Open an on screen window using PsychImaging and color it grey.
[windowPtr]=PsychImaging('OpenWindow', screenNumber, grey, [], [], [], stereoMode);
HideCursor;

% Measure the vertical refresh rate of the monitor
ifi = Screen('GetFlipInterval', windowPtr);

% Length of time and number of frames we will use for each drawing test
numSecs = 1;
numFrames = round(numSecs / ifi);
testFrames = 120; % change this value to test if your refresh rate is correct

% Number of frames to wait when specifying good timing
waitframes = 1;

% Show cleared start screen:
vbl = Screen('Flip', windowPtr);

% Draw test square
square = [100 100 200 200];

% Run until a key is pressed
keyCode=zeros(1,256);
keyIsDown=0;

while ~any(keyIsDown)

    for frame = 1:testFrame-1 % show a black square for refresh rate-1 frames
        % Select left-eye image buffer for drawing:
        Screen('SelectStereoDrawBuffer', windowPtr, 0);
        Screen(windowPtr, 'FillRect', black, square); % Black square

        % Select right-eye image buffer for drawing:
        Screen('SelectStereoDrawBuffer', windowPtr, 1);
        Screen(windowPtr, 'FillRect', black, square); % Black square

        % Now show it
        vbl = Screen('Flip', windowPtr, vbl + (waitframes - 0.5) * ifi);
    end

    for frame = 1 % show a white square for a single frame
        % Select left-eye image buffer for drawing:
        Screen('SelectStereoDrawBuffer', windowPtr, 0);
        Screen(windowPtr, 'FillRect', white, square); % Black square

        % Select right-eye image buffer for drawing:
        Screen('SelectStereoDrawBuffer', windowPtr, 1);
        Screen(windowPtr, 'FillRect', white, square); % Black square

        % Now show it
        vbl = Screen('Flip', windowPtr, vbl + (waitframes - 0.5) * ifi);
    end
    
    % Keyboatd queries and key handling
    [keyIsDown,~,keyCode] = KbCheck();
    
end

% Final flip
Screen('Flip', windowPtr);

% Clear the screen.
sca;
ShowCursor;
ListenChar(1);