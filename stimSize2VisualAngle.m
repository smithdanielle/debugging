function[visualAngle] = stimSize2VisualAngle(sizeInPixels, screenParams)
% STIMSIZE2VISUALANGLE Provides size in degrees of visual angle for a given number of pixels
%   [visualAngle] = STIMSIZE2VISUALANGLE(sizeInPixels) uses default screen parameters
%   [visualAngle] = STIMSIZE2VISUALANGLE(sizeInPixels, screenParams) incorporates user-defined screen parameters
%
%   Where screen parameters are defined by the user, inputs must include 
%   screenParams.Distance and screenParams.Width (measured in mm), and 
%   screenParams.Res (horizontal resolution in pixels).
%
%   See also VISUALANGLE2STIMSIZE.
%
%   11/02/2014 D Smith

if nargin < 2
    % measurements in millimeters
    screenParams.Distance = 1200;
    screenParams.Width = 396;
    
    % measurements in pixels
    screenParams.Res = 1024;
end

visualAngleRadians = 2 * atan(screenParams.Width/2/screenParams.Distance);
visualAngleDegrees = visualAngleRadians * (180/pi);

degreesPerPixel = visualAngleDegrees/screenParams.Res;

visualAngle = sizeInPixels * degreesPerPixel;
