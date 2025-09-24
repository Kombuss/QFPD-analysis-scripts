function [] = extract_and_save_points(k, branches_energy, branches, path, file_name)

% extract_and_save_points_by_peak_fitting - Extract and saving points
%   This function finds lorentzian peaks of intensity for different 
%   wavevectors for different branches and saves those fits.
%
%   Syntax
%       extract_and_save_points(k, branches_energy, branches, path, file_name)
%
%   Input Arguments
%       k - Wavevector [um^-1]
%           vector
%       branches_energy - Energy [eV] divided into branches
%           cell
%       branches - Intensity [arb.u.] divided into branches
%           cell
%       path - path for a folder in which a folder with fit results will be
%       created
%           char
%       file_name - name of a file from which points are extracted
%           char
%

% Iterating through all branches
for i = 1:size(branches, 2)

    % Opening file for saving fit results and writing headline
    file_save_fit = string(path) + "\extracted_points\" + ...
        string(file_name(1:3)) + string(i) + "_branch_fit.txt";
    open_file = fopen(file_save_fit, 'w');
    fprintf(open_file, ...
        '%20s\t %20s\t %20s\t %20s\t %20s\t %20s\t %20s\t %20s\t \n', ...
        'Wavevector [um^-1]', 'Energy [eV]', 'Error [eV]', ...
        'Intensity [arb.u.]', 'Error [arb.u.]', 'FWHM [eV]', ...
        'Error [eV]', 'R^2 [arb.u.]');
    
    % Setting up data and energy for fitting
    data_to_fit = branches{i};
    energy_to_fit = branches_energy{i};

    % Iterating through columns of intensity for different wavevectors  
    for j = 1:size(data_to_fit, 2)
        
        % Determining the correct prominence for finding peaks
        %!!!NOTE!!! (tune this 95% for optimal data extraction)
        intensity_one_col = data_to_fit(:, j);
        [~, ~, ~, proms] = findpeaks(intensity_one_col, energy_to_fit, ...
            'MinPeakProminence', 0);
        proms_sorted = sort(proms);
        cum_sum_proms = cumsum(proms_sorted);
        threshold_idx = find(cum_sum_proms >= 0.95*sum(proms_sorted), 1);
        min_peak_prominence = proms_sorted(threshold_idx);
        if isempty(min_peak_prominence)
            min_peak_prominence = 0;
        end

        % Finding peaks in column j and checking number of peaks found.
        % Because data is already divided into branches, there shouldn't be
        % more than 2 (due to polarization splitting).
        [intensity, E_peak, width_E_peak, ~] = ...
        findpeaks(intensity_one_col, energy_to_fit, ...
        'MinPeakProminence', min_peak_prominence);
        if size(E_peak) == 1                                            
            number_of_peaks = 1;
        elseif size(E_peak) == 2
            number_of_peaks = 2;
        else
            fprintf(open_file, ...
                ['%20s\t %20s\t %20s\t %20s\t %20s\t %20s\t %20s\t ' ...
                '%20s\t \n'], num2str(k(j),15), num2str(''), ...
                num2str(''), num2str(''), num2str(''), num2str(''), ...
                num2str(''), num2str(''));                                  
            continue;
        end
        
        % Setting fit starting points
        factor = 2/(pi*width_E_peak);
        start_points = [intensity/factor E_peak width_E_peak 0];

        % Fitting lotentzian peak
        [fit_result, goodness] = fit_peak(energy_to_fit, ...
            intensity_one_col, number_of_peaks, start_points, "lorentz");

        % Extraction of standard errors
        er = confint(fit_result);
        a_error = (er(2,1)-er(1,1))/2;
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
            num2str(c_error,15), num2str(goodness.rsquare,15));
        
    end

    % Closing file in which fit results where saved
    fclose(open_file);    
end
