function datapixxStereoDemo(stereoMode, usedatapixx)
% datapixxStereoDemo([stereoMode=1][, usedatapixx=0])
%
% ImagingStereoDemo.m tweaked for DataPixx with custom emitter and shutter
% glasses, although can be used without either of these pieces of equipment.
%
% Optional parameters:
%
% 'stereoMode' specifies the type of stereo display algorithm to use:
%
% 0 == Mono display - No stereo at all.
%
% 1 == Flip frame stereo (temporally interleaved) - You'll need shutter
% glasses that are supported by the operating system, e.g., the
% CrystalEyes-Shutterglasses. Psychtoolbox will automatically generate blue
% sync lines at the bottom of the display.
%
% 2 == Top/bottom image stereo with lefteye=top also for use with special
% CrystalEyes-hardware. Also used by the ViewPixx Inc. DataPixx device for
% frame-sequential stereo with shutter glasses, and with various other products.
%
% 3 == Same, but with lefteye=bottom.
%
% 4 == Free fusion (lefteye=left, righteye=right): Left-eye view displayed
% in left half of window, right-eye view displayed in right-half of window.
% Use this for dual-display setups (binocular video goggles, haploscopes,
% polarized stereo setups etc.)
%
% 5 == Cross fusion (lefteye=right ...): Like mode 4, but with views
% switched.
%
% 6-9 == Different modes of anaglyph stereo for color filter glasses:
%
% 6 == Red-Green
% 7 == Green-Red
% 8 == Red-Blue
% 9 == Blue-Red; note that settings here are optimised for Dell 1901fp
%
% If you have a different set of filter glasses, e.g., red-magenta, you can
% simply select one of above modes, then use the
% SetStereoAnglyphParameters() command to change color gain settings,
% thereby implementing other anaglyph color combinations.
%
% 10 == Like mode 4, but for use on Mac OS/X with dualhead display setups.
%
% 11 == Like mode 1 (frame-sequential) but using Screen's built-in method,
% instead of the native method supported by your graphics card.
%
% 100 == Interleaved line stereo: Left eye image is displayed in even
% scanlines, right eye image is displayed in odd scanlines.
%
% 101 == Interleaved column stereo: Left eye image is displayed in even
% columns, right eye image is displayed in odd columns. Typically used for
% auto-stereoscopic displays, e.g., lenticular sheet or parallax barrier
% displays.
%
% 102 == PsychImaging('AddTask', 'General', 'SideBySideCompressedStereo');
% Side-by-side compressed stereo, popular with HDMI stereo display devices.
%
% 'usedatapixx' If provided and set to a non-zero value, will setup a
% connected VPixx DataPixx device for stereo display.
%
% Author:
% Danielle Smith - lpxds5 at nottingham.ac.uk

Screen('Preference', 'SkipSyncTests', 1);

% We start of with non-inverted display:
inverted = 0;

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
space = KbName('space');
escape = KbName('ESCAPE');

[keyboardIndices] = GetKeyboardIndices;
keyboardIndex = max(keyboardIndices);

% Get screen numbers and draw to highest-numbered external screen
screenNumber = max(Screen('Screens'));

% Dual display dual-window stereo requested?
if stereoMode == 10
    % Yes. Do we have at least two separate displays for both views?
    if length(Screen('Screens')) < 2
        error('Sorry, for stereoMode 10 you''ll need at least 2 separate display screens in non-mirrored mode.');
    end
    
    if ~IsWin
        % Assign left-eye view (the master window) to main display:
        screenNumber = 0;
    else
        % Assign left-eye view (the master window) to main display:
        screenNumber = 1;
    end
end

% Open double-buffered onscreen window with the requested stereo mode,
% setup imaging pipeline for additional on-the-fly processing:

% Prepare pipeline for configuration. This marks the start of a list of
% requirements/tasks to be met/executed in the pipeline:
PsychImaging('PrepareConfiguration');

if usedatapixx == 1
    % Tell PTB we want to display on a DataPixx device:
    PsychImaging('AddTask', 'General', 'UseDataPixx');
    SetStereoBlueLineSyncParameters(win, windowRect(4)-0); % must be zero, DATAPixx is strict about scanline position
    Datapixx('SetVideoStereoVesaWaveform', 2); % If driving NVIDIA glasses
end

% Ask to restrict stimulus processing to some subarea (ROI) of the
% display. This will only generate the stimulus in the selected ROI and
% display the background color in all remaining areas, thereby saving
% some computation time for pixel processing: We select the center
% 512x512 pixel area of the screen:
if ~ismember(stereoMode, [100, 101, 102])
    PsychImaging('AddTask', 'AllViews', 'RestrictProcessing', CenterRect([0 0 512 512], Screen('Rect', screenNumber)));
end

% stereoMode 100 triggers scanline interleaved display:
if stereoMode == 100
    PsychImaging('AddTask', 'General', 'InterleavedLineStereo', 0);
end

% stereoMode 101 triggers column interleaved display:
if stereoMode == 101
    PsychImaging('AddTask', 'General', 'InterleavedColumnStereo', 0);
end

% stereoMode 102 triggers side-by-side compressed HDMI frame-packing display:
if stereoMode == 102
    PsychImaging('AddTask', 'General', 'SideBySideCompressedStereo');
end

% Consolidate the list of requirements (error checking etc.), open a
% suitable onscreen window and configure the imaging pipeline for that
% window according to our specs. The syntax is the same as for
% Screen('OpenWindow'):
[windowPtr, windowRect] = PsychImaging('OpenWindow', screenNumber, 0, [], [], [], stereoMode);

if stereoMode == 10
    % In dual-window, dual-display mode, we open the slave window on
    % the secondary screen. Please note that, after opening this window
    % with the same parameters as the "master-window", we won't touch
    % it anymore until the end of the experiment. PTB will take care of
    % managing this window automatically as appropriate for a stereo
    % display setup. That is why we are not even interested in the window
    % handles of this window:
    if IsWin
        slaveScreen = 2;
    else
        slaveScreen = 1;
    end
    Screen('OpenWindow', slaveScreen, BlackIndex(slaveScreen), [], [], [], stereoMode);
end

% Stimulus settings:
numDots = 1000;
vel = 1;   % pix/frames
dotSize = 8;
dots = zeros(3, numDots);

xmax = RectWidth(windowRect)/2;
ymax = RectHeight(windowRect)/2;
if stereoMode == 100
    xmax = xmax/4;
    ymax = ymax/2;
else
    xmax = min(xmax, ymax) / 2;
    ymax = xmax;
end

amp = 16;

dots(1, :) = 2*(xmax)*rand(1, numDots) - xmax;
dots(2, :) = 2*(ymax)*rand(1, numDots) - ymax;

% Set color gains. This depends on the anaglyph mode selected. The
% values set here as default need to be fine-tuned for any specific
% combination of display device, color filter glasses and (probably)
% lighting conditions and subject. The current settings do ok on a
% MacBookPro flat panel.
switch stereoMode
    case 6,
        SetAnaglyphStereoParameters('LeftGains', windowPtr,  [1.0 0.0 0.0]);
        SetAnaglyphStereoParameters('RightGains', windowPtr, [0.0 0.6 0.0]);
    case 7,
        SetAnaglyphStereoParameters('LeftGains', windowPtr,  [0.0 0.6 0.0]);
        SetAnaglyphStereoParameters('RightGains', windowPtr, [1.0 0.0 0.0]);
    case 8,
        SetAnaglyphStereoParameters('LeftGains', windowPtr, [0.4 0.0 0.0]);
        SetAnaglyphStereoParameters('RightGains', windowPtr, [0.0 0.2 0.7]);
    case 9,
        %SetAnaglyphStereoParameters('LeftGains', windowPtr, [0.0 0.2 0.7]);
        %SetAnaglyphStereoParameters('RightGains', windowPtr, [0.4 0.0 0.0]);
        rgbParamsL = [0.0 0.4 0.4]; % Optimal cyan parameters for Dell 1901fp
        rgbParamsR = [0.6 0.0 0.0]; % Optimal red parameters for Dell 1901fp
        SetAnaglyphStereoParameters('LeftGains', windowPtr, rgbParamsL);
        SetAnaglyphStereoParameters('RightGains', windowPtr, rgbParamsR);
    otherwise
        %error('Unknown stereoMode specified.');
end

% Initially fill left- and right-eye image buffer with black background
% color:
Screen('SelectStereoDrawBuffer', windowPtr, 0);
Screen('FillRect', windowPtr, BlackIndex(screenNumber));
Screen('SelectStereoDrawBuffer', windowPtr, 1);
Screen('FillRect', windowPtr, BlackIndex(screenNumber));

% Show cleared start screen:
Screen('Flip', windowPtr);

% Set up alpha-blending for smooth (anti-aliased) drawing of dots:
Screen('BlendFunction', windowPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

col1 = WhiteIndex(screenNumber);
col2 = col1;
center = [0 0];
sigma = 50;
xvel = 2*vel*rand(1,1)-vel;
yvel = 2*vel*rand(1,1)-vel;

Screen('Flip', windowPtr);

% Maximum number of animation frames to show:
nmax = 100000;

% Preallocate timing array for speed:
t = zeros(1, nmax);
count = 1;

% Perform a flip to sync us to vbl and take start-timestamp in t:
t(count) = Screen('Flip', windowPtr);
buttons = 0;

% Run until a key is pressed or nmax iterations have been done:
while (count < nmax) && ~any(buttons)
    
    % Demonstrate how mouse cursor position (or any other physical pointing
    % device location on the actual display) can be remapped to the
    % stereo framebuffer locations which correspond to those positions. We
    % query "physical" mouse cursor location, remap it to stereo
    % framebuffer locations, then draw some little marker-square at those
    % locations via Screen('DrawDots') below. At least one of the squares
    % locations should correspond to the location of the mouse cursor
    % image:
    [x,y, buttons] = GetMouse(windowPtr);
    [x,y] = RemapMouse(windowPtr, 'AllViews', x, y);
    
    % Select left-eye image buffer for drawing:
    Screen('SelectStereoDrawBuffer', windowPtr, 0);
    
    % Draw left stim:
    Screen('DrawDots', windowPtr, dots(1:2, :) + [dots(3, :)/2; zeros(1, numDots)], dotSize, col1, windowRect(3:4)/2, 1);
    Screen('FrameRect', windowPtr, [255 0 0], [], 5);
    Screen('DrawDots', windowPtr, [x ; y], 8, [255 0 0]);
    
    % Select right-eye image buffer for drawing:
    Screen('SelectStereoDrawBuffer', windowPtr, 1);
    
    % Draw right stim:
    Screen('DrawDots', windowPtr, dots(1:2, :) - [dots(3, :)/2; zeros(1, numDots)], dotSize, col2, windowRect(3:4)/2, 1);
    Screen('FrameRect', windowPtr, [0 255 0], [], 5);
    Screen('DrawDots', windowPtr, [x ; y], 8, [0 255 0]);
    
    % Tell PTB drawing is finished for this frame:
    Screen('DrawingFinished', windowPtr);
    
    % Now all non-drawing tasks:
    
    % Compute dot positions and offsets for next frame:
    center = center + [xvel yvel];
    if center(1) > xmax || center(1) < -xmax
        xvel = -xvel;
    end
    
    if center(2) > ymax || center(2) < -ymax
        yvel = -yvel;
    end
    
    dots(3, :) = -amp.*exp(-(dots(1, :) - center(1)).^2 / (2*sigma*sigma)).*exp(-(dots(2, :) - center(2)).^2 / (2*sigma*sigma));
    
    % Keyboard queries and key handling:
    [pressed dummy keycode] = KbCheck; %#ok<ASGLU>
    if pressed
        % SPACE key toggles between non-inverted and inverted display:
        if keycode(space) && ismember(stereoMode, [6 7 8 9]);
            KbReleaseWait;
            inverted = 1 - inverted;
            if inverted
                % Set inverted mode:
                SetAnaglyphStereoParameters('InvertedMode', windowPtr);
            else
                % Set standard mode:
                SetAnaglyphStereoParameters('StandardMode', windowPtr);
            end
        end
        
        % ESCape key exits the demo:
        if keycode(escape)
            break;
        end
    end
    
    % Flip stim to display and take timestamp of stimulus-onset after
    % displaying the new stimulus and record it in vector t:
    onset = Screen('Flip', windowPtr);
    
    % Log timestamp:
    count = count + 1;
    t(count) = onset;
end

% Last Flip:
Screen('Flip', windowPtr);


% Done. Close the onscreen window:
Screen('CloseAll')

% Compute and show timing statistics:
t = t(1:count);
dt = t(2:end) - t(1:end-1);
disp(sprintf('N.Dots\tMean (s)\tMax (s)\t%%>20ms\t%%>30ms\n')); %#ok<DSPS>
disp(sprintf('%d\t%5.3f\t%5.3f\t%5.2f\t%5.2f\n', numDots, mean(dt), max(dt), sum(dt > 0.020)/length(dt), sum(dt > 0.030)/length(dt))); %#ok<DSPS>

% We're done.
return;