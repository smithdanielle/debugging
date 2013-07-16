% anaglyphSetParams.m
% Setup to run in PTB3 in A13 with 3DPixx goggles
%
% Determines which sign of polarity the glasses are currently displaying in
% Created by DS on 1/13

Screen('Preference', 'SkipSyncTests', 1);

% Specify screen res
res = [1024 1280];

% Let's try the PsychImaging pipeline
PsychImaging('PrepareConfiguration');

% Which stereomode to use
stereoMode=9;   % Red-cyan anaglyph glasses
AssertOpenGL;

% Specify colours
grey = [190 190 190];
white = [255 255 255];
black = [0 0 0];

% Define the centre
xcen = res(1)/2;
ycen = res(2)/2;

% Set keys
upr = KbName('q');
downr = KbName('a');
upg = KbName('w');
downg = KbName('s');
upb = KbName('e');
downb = KbName('d');
space = KbName('space');
escapeKey = KbName('ESCAPE');

% Set interval to 1
interval=1;
leftGainSetting=0;
rightGainSetting=0;
rgbParamsL = [1.0 0.0 0.0];
rgbParamsR = [0.0 0.5 0.5];
WindowValue = 0;
 
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
% rect1 = [xcen-200, ycen-100, xcen-100, ycen+100];
% rect2 = [xcen+100, ycen-100, xcen+200, ycen+100];
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