function [k, branches_energy, branches] = ...
    divide_data_into_branches(k, energy, data)

% This function divides data [arb.u.] matrix and energies [eV] into
% different branches and returns new matrisis and energies as cells of 
% double arrays.

% Determining the correct prominence for finding peaks

intensity_middle_col = data(:,ceil(size(k,2)/2));               % Extracting middle column of data
[~, ~, ~, proms] = findpeaks(intensity_middle_col, energy, ...
    'MinPeakProminence', 0);                                    % Extracting prominence for all praks that this function finds
min_prak_prominence = std(proms);                               % Defining minimum peak prominence as standard deviation of all prominences

% Finding peaks in the middle of dispersion curve for k = 0

[~, E_branches, width_branches, ~] = findpeaks(intensity_middle_col, energy, ...    
    'MinPeakProminence', min_prak_prominence);                                      % Finding peaks in middle column to know how many branches there are

% Designating branch bounderies based on peaks found

branch_bounderies = E_branches - 1.2*width_branches;    % Creating bounderies of branches based on energy and width of the peak fit aproximetly to whole peaks not only slopes
branch_bounderies = [branch_bounderies; energy(end)];   % Adding highes energy at the end for upper boundery of last branch            

% Dividing data matrix and energies into different branches

branches = {size(branch_bounderies)};           % Setting the size of branches to the size of their bounderies
branches_energy = {size(branch_bounderies)};    % and doing the same for energies' size

for i = 1:(size(branch_bounderies, 1)-1)                                                            % Loop for saving different parts of data matrix to different branches
    branch_energy_log = energy(:) >= branch_bounderies(i) & energy(:) <= branch_bounderies(i+1);    % Creating matrix of logical values of 1 for energies in a given bounderies
    branches_energy{i} = energy(branch_energy_log);                                                 % Saving those energies
    branches{i} = data(branch_energy_log, 1:end);                                                   % Saving data slice based on given bounderies
end
