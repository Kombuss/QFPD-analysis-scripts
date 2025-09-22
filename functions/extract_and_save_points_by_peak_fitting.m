function [] = extract_and_save_points_by_peak_fitting...
    (k, branches_energy, branches, path, file_name)

% This function finds lorentzian peaks of intensity [arb.u.] (branches) in 
% a function of energy (branches_energy) [eV] for different wavevectors (k)
% [um^-1] for different branches and saves those fits.

% Iterating through all branches

for i = 1:size(branches, 2)

    % Opening file for saving fit resuls and writing headline

    file_save_fit = string(path) + "\extracted_points\" + ...
        string(file_name(1:3)) + string(i) + "_branch_fit.txt";             % Defining file name where extracted points will be saved
    open_file = fopen(file_save_fit, 'w');                                  % Opening file for wrtiting data in it
    fprintf(open_file, ...
        '%20s\t %20s\t %20s\t %20s\t %20s\t %20s\t %20s\t %20s\t \n', ...
        'Wavevector [um^-1]', 'Energy [eV]', 'Error [eV]', ...
        'Intensity [arb.u.]', 'Error [arb.u.]', 'FWHM [eV]', ...
        'Error [eV]', 'R^2 [arb.u.]');                                      % Writing headline in opened file
    
    % Setting up data and energy for fitting

    data_to_fit = branches{i};          % Extracting one of the branches for fitting
    energy_to_fit = branches_energy{i}; % Same for energy

    % Iterating through columns of intensity for different wavevectors
    
    for j = 1:size(data_to_fit, 2)
        
        % Determining the correct prominence for finding peaks

        intensity_one_col = data_to_fit(:, j);                              % Taking single column of intensities for k(j)
        [~, ~, ~, proms] = findpeaks(intensity_one_col, energy_to_fit, ...
            'MinPeakProminence', 0);                                        % Extracting prominence for all peaks that this function finds
        
        %!!!FIX!!! (tune this 95% for optimal data extraction)

        proms_sorted = sort(proms);
        cum_sum_proms = cumsum(proms_sorted);
        threshold_idx = find(cum_sum_proms >= 0.95*sum(proms_sorted), 1);
        min_peak_prominence = proms_sorted(threshold_idx);                  % Setting up minimum peak prominence based on prominance
        if isempty(min_peak_prominence)
            min_peak_prominence = 0;
        end
        % Finding peaks in column j and chcecking number of peaks found
        % Because data is already divided into branches, there shouldn't be
        % more than 2 (due to polarization splitting)

        [intensity, E_peak, width_E_peak, ~] = findpeaks(intensity_one_col, ...
            energy_to_fit, 'MinPeakProminence', min_peak_prominence);           % Finding peaks for j column
       
        if size(E_peak) == 1                                                % Checking if peaks there found                                                
            number_of_peaks = 1;
        elseif size(E_peak) == 2                                            % Looking for TM-TE slpitting
            number_of_peaks = 2;
        else                                                                % If peaks are not found save wavevector and empty columns and continue with the loop
            fprintf(open_file, ...
                ['%20s\t %20s\t %20s\t %20s\t %20s\t %20s\t %20s\t ' ...
                '%20s\t \n'], num2str(k(j),15), num2str(''), ...
                num2str(''), num2str(''), num2str(''), num2str(''), ...
                num2str(''), num2str(''));                                  
            continue;                                                       % Skipping code below in this loop but continuing with futher iterations
        end
        
        % Setting starting points

        factor = 2/(pi*width_E_peak);                               % Factor for determining starting intensity
        start_points = [intensity/factor E_peak width_E_peak 0];    % Defining starting points for fitting

        % Fitting lotentzian peak

        [fit_result, goodness] = fit_peak(energy_to_fit, intensity_one_col, ...
            number_of_peaks, start_points, "lorentz");                          % Fitting with lorentzian peak with defined starting points

        % Extraction of standard errors

        er = confint(fit_result); % Confidence intervals for fit coefficients

        a_error = (er(2,1)-er(1,1))/2;  % Replacing confidence intervals with single standard error for all coefficients
        b_error = (er(2,2)-er(1,2))/2;
        c_error = (er(2,3)-er(1,3))/2;
        d_error = (er(2,4)-er(1,4))/2;

        % Saving fitted data

        fprintf(open_file, ['%20s\t %20s\t %20s\t %20s\t %20s\t' ...
            ' %20s\t %20s\t %20s\t \n'], num2str(k(j),15), ...
            num2str(fit_result.b,15), num2str(b_error,15), ...
            num2str(fit_result.d+(2*fit_result.a)/(pi*fit_result.c),15), ...
            num2str(sqrt((2*a_error)^2/(pi*fit_result.c)^2+ ...
            (4*fit_result.a^2*c_error^2/(pi*fit_result.c^2)^2))+ ...
            (d_error)^2,15), num2str(fit_result.c,15), ...
            num2str(c_error,15), num2str(goodness.rsquare,15));             % Writing all of the fitting parameters and their errors to previously opened file
        
    end

    fclose(open_file);  % Closing file in which fit results where saved
    
end
