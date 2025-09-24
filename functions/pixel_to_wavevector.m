function [k, data_cut] = pixel_to_wavevector(x, energy, data, NA, f, dpx, magK)

% pixel_to_wavevector - Convert pixel to wavevector
%   This function converts pixels to wavevectors based on parameters of the
%   setup and measurement.
%
%   Syntax
%       [k, data_cut] = pixel_to_wavevector(x, energy, data, NA, f, dpx, magK)
%
%   Input Arguments
%       x - Position [px]
%           vector
%       energy - Energy [eV]
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
%
%   Output Arguments
%       k - Wavevector [um^-1]
%           vector
%       data_cut - Intensity [arb.u.]
%           vector
%

% Physical constants
h = 4.135667*10^(-15);  % Planck constant [eV*s]
c = 299792458;          % Speed of light [m/s]

% Cutting data based on maximum pixel that was imaged
pixel_max = magK*f*NA*10^3/dpx;
if_x_within_max_pixel = x >= -pixel_max & x <= pixel_max;
x = x(if_x_within_max_pixel);
data_cut = data(:, if_x_within_max_pixel);

% Converting pixels to wavevectors
E_max = max(energy);
k_max = 2*pi*NA*E_max/(h*c)*10^-6;
k = k_max*x/pixel_max;
