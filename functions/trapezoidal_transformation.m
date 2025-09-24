function [data_trans] = trapezoidal_transformation(energy, data)

% trapezoidal_transformation - Perform trapezoidal transformation
%   This function performs trapezoidal transformation of data.
%
%   Syntax
%       [data_trans] = trapezoidal_transformation(energy, data)
%
%   Input Arguments
%       energy - Energy [eV]
%           vector
%       data - Intensity [arb.u.]
%           vector
%
%   Output Arguments
%       data_trans - Intensity [arb.u.]
%           vector
%

% Determining the shift
E_max = max(energy);
E_min = min(energy);
factor_trap = E_min/E_max;
NY = size(data,1);
NX = size(data,2);
shift = 0.5*(NX-ceil(NX*factor_trap));

% Setting moving and fixed points for transformation
moving_points = [1 1; NX 1; 1 NY; NX NY];
fixed_points = [1+shift 1; NX-shift 1; 1 NY; NX NY];

% Performing trapezoidal transformation
tform = fitgeotform2d(moving_points, fixed_points, 'pwl');
RA = imref2d([NY NX], [1 NX], [1 NY]);
[data_trans,~] = imwarp(data, tform, 'OutputView', RA);