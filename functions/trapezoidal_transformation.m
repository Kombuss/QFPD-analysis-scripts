function [data_trans] = trapezoidal_transformation(energy, data)

% This function performs trapezoidal transformation of data based on energy
% [eV] and intensity matrix (data) [arb.u.]. It returns transformed
% intensity matrix [arb.u.]

% Determining the shift

E_max = max(energy);                    % Determining maximum energy
E_min = min(energy);                    % Determining minimum energy
factor_trap = E_min/E_max;              % Factor for trapezoidal transformation
NY = size(data,1);                      % Number of rows
NX = size(data,2);                      % Number of columns
shift = 0.5*(NX-ceil(NX*factor_trap));  % How much point for lower power will be shifted

% Setting moving and fixed points for transformation

moving_points = [1 1; NX 1; 1 NY; NX NY];               % Points to be moved during transformation
fixed_points = [1+shift 1; NX-shift 1; 1 NY; NX NY];    % Points not to be moved during tranformation

% Trapezoidal transformation

tform = fitgeotform2d(moving_points, fixed_points, 'pwl');  % Geometrix transformation
RA = imref2d([NY NX], [1 NX], [1 NY]);                      % Special referencing information
[data_trans,~] = imwarp(data, tform, 'OutputView', RA);     % Transforming data