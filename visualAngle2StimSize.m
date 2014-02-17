function[sizeInPixels] = visualAngle2StimSize(visualAngle, screenParams)
% VISUALANGLE2STIMSIZE Provides size in pixels for a given number of degrees of visual angle
%   [sizeInPixels] = VISUALANGLE2STIMSIZE(visualAngle) uses default screen parameters
%   [sizeInPixels] = VISUALANGLE2STIMSIZE(visualAngle, screenParams) incorporates user-defined screen parameters
%
%   Where screen parameters are defined by the user, inputs must include 
%   screenParams.Distance and screenParams.Width (measured in mm), and 
%   screenParams.Res (horizontal resolution in pixels).
%
%   See also STIMSIZE2VISUALANGLE.
%
%   11/02/2014 D Smith

if nargin < 2
    % measurements in millimeters
    screenParams.Distance = 1200;
    screenParams.Width = 396;
    
    % measurements in pixels
    screenParams.Res = [1024 1280];
end

if visualAngle < stimSize2VisualAngle(1)
    error('This value is too small for the current display settings - lower value limit is %6.4f', stimSize2VisualAngle(1))
end

visualAngleRadians = 2 * atan(screenParams.Width/2/screenParams.Distance);
visualAngleDegrees = visualAngleRadians * (180/pi);

pixelsPerDegree = screenParams.Res(end)/visualAngleDegrees;

sizeInPixels = round(visualAngle * pixelsPerDegree);

end
