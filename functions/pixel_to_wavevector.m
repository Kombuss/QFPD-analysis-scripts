function [k, data_cut] = pixel_to_wavevector(x, energy, data, NA, f, dpx, magK)

% This function converts pixels to wavevectors based od pixel position (x)
% [arb.u.], energy [eV], intensity (data) [arb.u.], numerical apeture (NA)
% [arb.u.], focal length of the lens (f) [mm], pixel size (dpx) [um],
% k-space magnification (magK) [arb.u.]. It returns wavevector (k) [um^-1]
% and imaged intensity (data_cut) [arb.u.].

% Physical constants

h = 4.135667*10^(-15);  % Planck constant [eV*s]
c = 299792458;          % Speed of light [m/s]

% Cutting data based on maximum pixel that was imaged

pixel_max = magK*f*NA*10^3/dpx;                             % Determining the maximum imaged pixel
if_x_within_max_pixel = x >= -pixel_max & x <= pixel_max;   % Determining which pixels are imaged
x = x(if_x_within_max_pixel);                               % Cutting unimaged pixels
data_cut = data(:, if_x_within_max_pixel);                  % Cutting unimaged data

% Converting pixel to wavevector

E_max = max(energy);                % Determining maximum energy
k_max = 2*pi*NA*E_max/(h*c)*10^-6;  % Calculating maximum imaged wavevector based on maximum energy
k = k_max*x/pixel_max;              % Calculated wavevectors [um^-1]
