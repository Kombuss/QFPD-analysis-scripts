function [k, branches_energy, branches] = ...
    divide_data_into_branches(k, energy, data)

% This function divides data [arb.u.] matrix and energies [eV] into
% different branches and returns new matrisis and energies as cells of 
% double arrays.

% Determining the correct prominence for finding peaks
% !!!IDEA!!! (find minimums instead of maximums)

intensity_middle_col = data(:,ceil(size(k,2)/2));               % Extracting middle column of data
[~, ~, ~, proms] = findpeaks(intensity_middle_col, energy, ...
    'MinPeakProminence', 0);                                    % Extracting prominence for all preks that this function finds

%!!!FIX!!! (change min_peak_prominance so that it's more sensitive)

min_peak_prominence = std(proms);                               % Defining minimum peak prominence as standard deviation of all prominences

% Finding peaks in the middle of dispersion curve for k = 0

[~, E_branches, width_branches, ~] = findpeaks(intensity_middle_col, energy, ...    
    'MinPeakProminence', min_peak_prominence);                                      % Finding peaks in middle column to know how many branches there are

% Designating branch bounderies based on peaks found

branch_bounderies = zeros(size(E_branches, 1) + 1, 1);          % Alocating array for branch's bounderies
branch_bounderies(1) = E_branches(1) - 1.699*width_branches(1); % Setting first ...
branch_bounderies(end) = energy(end);                           % ... and last energy values as outer bounderies

if size(E_branches, 1) > 1
    branch_bounderies(2:end-1) = E_branches(2:end) - ...
        width_branches(2:end).*(E_branches(2:end) - ...
        E_branches(1:end-1))./(width_branches(1:end-1) + ...
        width_branches(2:end));                                 % Creating bounderies of branches based on energy and width of the peaks
end         

% Dividing data matrix and energies into different branches

branches = {size(branch_bounderies)};           % Setting the size of branches to the size of their bounderies
branches_energy = {size(branch_bounderies)};    % and doing the same for energies' size

for i = 1:(size(branch_bounderies, 1)-1)                                                            % Loop for saving different parts of data matrix to different branches
    branch_energy_log = energy(:) >= branch_bounderies(i) & energy(:) <= branch_bounderies(i+1);    % Creating matrix of logical values of 1 for energies in a given bounderies
    branches_energy{i} = energy(branch_energy_log);                                                 % Saving those energies
    branches{i} = data(branch_energy_log, 1:end);                                                   % Saving data slice based on given bounderies
end
