function [k, branches_energy, branches] = divide_data_into_branches(k, energy, data)

% divide_data_into_branches - Divides intensity matrix into branches
%   This function divides intensity matrix into different branches, so that
%   in each branch there is only one curve
%
%   Syntax
%       [k, branches_energy, branches] = divide_data_into_branches(k, energy, data)
%
%   Input Arguments
%       k - Wavevector [um^-1]
%           vector
%       energy - Energy [eV]
%           vector
%       data - Intensity [arb.u.]
%           vector
%
%   Output Arguments
%       k - Wavevector [um^-1]
%           vector
%       branches_energy - Energy [eV] divided into branches
%           cell
%       branches - Intensity [arb.u.] divided into branches
%           cell
%

% Determining the correct prominence for finding peaks in middle column
% !!!IDEA!!! (find minimums instead of maximums)
% !!!NOTE!!! (change min_peak_prominance so that it's a little more 
% sensitive. Maybe min_peak_prominance = mean(data('all'))-min(data('all'))
% or something like that)
intensity_middle_col = data(:,ceil(size(k, 2)/2));
[~, ~, ~, proms] = findpeaks(intensity_middle_col, energy, ...
    'MinPeakProminence', 0);
min_peak_prominence = std(proms);

% Finding peaks in the middle of dispersion curve for k = 0 to know how
% many branches there are
[~, E_branches, width_branches, ~] = findpeaks(intensity_middle_col, ...
    energy, 'MinPeakProminence', min_peak_prominence);

% Designating branch boundaries based on peaks found
branch_bounderies = zeros(size(E_branches, 1) + 1, 1);
branch_bounderies(1) = E_branches(1) - 1.699*width_branches(1);
branch_bounderies(end) = energy(end);
if size(E_branches, 1) > 1
    branch_bounderies(2:end-1) = E_branches(2:end) - ...
        width_branches(2:end).*(E_branches(2:end) - ...
        E_branches(1:end-1))./(width_branches(1:end-1) + ...
        width_branches(2:end));
end         

% Dividing data and energies into different branches
branches = {size(branch_bounderies)};
branches_energy = {size(branch_bounderies)};
for i = 1:(size(branch_bounderies, 1)-1)
    branch_energy_log = energy(:) >= branch_bounderies(i) & energy(:) <= branch_bounderies(i+1);
    branches_energy{i} = energy(branch_energy_log);
    branches{i} = data(branch_energy_log, 1:end);
end
