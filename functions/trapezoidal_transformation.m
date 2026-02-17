function [data_trans] = trapezoidal_transformation(energy, data)

% trapezoidal_transformation - Perform trapezoidal transformation
%   This function performs trapezoidal transformation for a given data to 
%   account for the energy dependence of the maximum imaging wavevector.
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
%       data_trans - Intensity after transformation [arb.u.]
%           vector
%

% Defining variables crucial for transformation
E_max = max(energy);
[NY, NX] = size(data);
x0 = (NX+1)/2;
x_new = 1:NX;
data_trans = zeros(size(data));

% Iterating through rows
for i = 1:NY

    % Determining the shift
    scale = energy(i) / E_max;

    % X coordinates, that are mapped to the new grid 
    x_old = (x_new - x0)/scale + x0;

    % Interpolation
    data_trans(i,:) = interp1(1:NX, data(i,:), x_old, 'linear', 0);
end
