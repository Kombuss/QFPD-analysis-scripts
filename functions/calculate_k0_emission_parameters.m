function [k0_int, emission_energy, emission_energy_err, fwhm, fwhm_err] = ...
    calculate_k0_emission_parameters(data, energy, k0_width)

% calculate_k0_emission_parameters - Calculate emission parameters around
% zero wavevector
%   This function reads and calculates emission parameters i.e. intensity,
%   emission energy and FWHM of a single mode around zero wavevector. It 
%   also subtracts linear background from measured data.
%
%   Syntax
%       [k0_int, emission_energy, emission_energy_err, fwhm, fwhm_err] = ...
%       calculate_k0_emission_parameters(data, energy, k0_width);
%       [k0_int, emission_energy, ~, fwhm, ~] = calculate_k0_emission_parameters(data, energy, 9);
%
%   Input Arguments
%       data - Intensity [arb.u.]
%           vector
%       energy - Energy [eV]
%           vector
%       k0_width - Width of a single mode around zero wavevector [px]
%           double
%
%   Output Arguments
%       k0_int - Intensity of a single mode around zero wavevector [arb.u.]
%           double
%       emission_energy - Emission energy of a single mode around zero
%       wavevector [eV]
%           double
%       emission_energy_err - Error in the determination of emission energy
%       [eV]
%           double
%       fwhm - FWHM of a single mode around zero wavevector [eV]
%           double
%       fwhm_err - Error in the determination of FWHM [eV]
%           double
%

% Determining data of a single mode around zero wavevector
k0_data = data(:, (size(data,2)+1)/2-floor(k0_width/2): ...
    (size(data,2)+1)/2+floor(k0_width/2));

% Selecting data for fitting in case you don't want to fit whole data.
% In that case change ranges accordingly. Example: multiple branches 
% visible
energy_to_fit = energy;
idx_to_fit = size(energy_to_fit);
idx_to_fit = idx_to_fit(1);
k0_to_fit = k0_data(1:idx_to_fit,:);

% Summing k0_width colums
k0_sum = sum(k0_to_fit,2);

% Subtracting linear background from intensities
[~,Sl,~] = ischange(k0_sum,'linear');                               % Detect Changes, Calculates Slopes (& Intercepts)
[Cts,~,Bin] = histcounts(Sl, 50);                                   % Histogram Of Slopes
[~,Binmax] = max(Cts);                                              % Find Largest Bin
LinearRegion = (Bin==Binmax);                                       % Logical Vector Of Values Corresponding To Largest Number Of Slopes
B = polyfit(energy_to_fit(LinearRegion), k0_sum(LinearRegion), 1);  % Linear Fit
L = polyval(B, energy_to_fit);                                      % Evaluate
k0_sum_no_bg = k0_sum - L;                                          % Detrend
k0_sum_no_bg(k0_sum_no_bg<0) = 0;

% In case you don't want to subtract background uncomment the line below
% k0_sum_no_bg = k0_sum;

% Calculating numerical integral to get whole emission intensity
k0_int = trapz(k0_sum_no_bg);

% Creating arrays for emission characteristics and preallocating sizes
energies = zeros(size(k0_width));
intensities = zeros(size(k0_width));
widths = zeros(size(k0_width));
energies_err = zeros(size(k0_width));
widths_err = zeros(size(k0_width));


% Iterating through k0_width wavevectors
for i = 1:k0_width
    
    % Finding peaks for fitting
    [prominence, E_peak, width_E_peak, ~] = findpeaks(k0_to_fit(:,i), ...
            energy_to_fit, 'MinPeakProminence', max(k0_to_fit(:,i)/2));
    
    % Checking if any peaks were found
    if  isempty(E_peak)
        continue;
    end
    
    % Setting fit starting points
    factor = 2/(pi*width_E_peak(1));

    % Fitting lotentzian peak
    [fit_result, goodness] = fit_peak(energy_to_fit, k0_to_fit(:,i), 1, ...
        [prominence(1)/factor E_peak(1) width_E_peak(1) 0], 'lorentz');

    % Saving fitted results
    energies(i) = fit_result.b;
    intensities(i) = fit_result.a;
    widths(i) = fit_result.c;

    % Extraction of standard errors
    er = confint(fit_result);
    b_error = (er(2,2)-er(1,2))/2;
    c_error = (er(2,3)-er(1,3))/2;
    energies_err(i) = b_error;
    widths_err(i) = c_error;
end

% Deleting not used array elements
energies(energies==0) = [];
intensities(intensities==0) = [];
widths(widths==0) = [];
energies_err(energies_err==0) = [];
widths_err(widths_err==0) = [];

% Calculating emission energy and width
emission_energy = mean(energies,Weights = intensities);
emission_energy_err = sqrt(sum((intensities.*(energies-emission_energy)).^2))/(length(energies)*(length(energies)-1));
fwhm = mean(widths,Weights = intensities);
fwhm_err = sqrt(sum((intensities.*(widths-fwhm)).^2))/(length(widths)*(length(widths)-1));

% Alternatively energy and width of a single middle column can be taken
% emission_energy = energies(ceil((k0_width+1)/2));
% emission_energy_err = energies_err(ceil((k0_width+1)/2));
% fwhm = widths(ceil((k0_width+1)/2));
% fwhm_err = widths_err(ceil((k0_width+1)/2));