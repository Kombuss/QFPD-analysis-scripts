function [x, data_cut] = pixel_to_position(x, data, NA, f, dpx, magK, magR)

% pixel_to_position - Convert pixel to position
%   This function converts pixels to position based on parameters of the
%   setup and measurement.
%
%   Syntax
%       [x, data_cut] = pixel_to_position(x, data, NA, f, dpx, magK, magR)
%
%   Input Arguments
%       x - Position [px]
%           vector
%       data - Intensity [arb.u.]
%           vector
%       NA - Numerical aperture [arb.u.]
%           double
%       f - Focal length of objective [mm]
%           double
%       dpx - Pixel size [um]
%           double
%       magK - K-space magnification [arb.u.]
%           double
%       magR - R-space magnification [arb.u.]
%           double
%
%   Output Arguments
%       x - Position [um]
%           vector
%       data_cut - Intensity [arb.u.]
%           vector
%

% Cutting data based on maximum pixel that was imaged
pixel_max = magK*f*NA*10^3/dpx;
if_x_within_max_pixel = x >= -pixel_max & x <= pixel_max;
x = x(if_x_within_max_pixel);
data_cut = data(:, if_x_within_max_pixel);

% Converting pixels to positions
x = x*dpx/magR/magK;