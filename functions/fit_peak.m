function [fit_result, goodness] = fit_peak(x, y, number_of_peaks, ...
    start_points, type, upper_bounds, lower_bounds)

% This function fits number of gaussian or lorentzian peaks
% (number_of_peaks and type) to x and y data based on strating points of a
% fit (start_points). Optionaly you can define upper and lower bonds for 
% fitting parameters. It returns results of fitting (fit_result) and 
% goodness of the fit.

 if ~exist('upper_bounds','var')    % Setting default value for upper bonds
      upper_bounds = [];
 end

  if ~exist('lower_bounds','var')   % Setting default value for lower bonds
      lower_bounds = [0 0 0 -inf];
 end

% Defining gauss and lorentz functions for fitting
% !!!FIX!!! (fittype defined for arbitrary number of peaks by changing strings and lists below in some for loop) 

if type == "gauss"

    fit_type_1 = fittype('(a/(c*sqrt(pi/2)))*exp(-2*((x-b)/c)^2)+d', ...
    'coefficients', {'a', 'b', 'c', 'd'});

    fit_type_2 = fittype(['(a/(c*sqrt(pi/2)))*exp(-2*((x-b)/c)^2)+' ...
        '(a2/(c2*sqrt(pi/2)))*exp(-2*((x-b2)/c2)^2)+d'], ...
        'coefficients', {'a', 'b', 'c', 'a2', 'b2', 'c2','d'});
    
    fit_type_3 = fittype(['(a/(c*sqrt(pi/2)))*exp(-2*((x-b)/c)^2)+' ...
        '(a2/(c2*sqrt(pi/2)))*exp(-2*((x-b2)/c2)^2)+' ...
        '(a3/(c3*sqrt(pi/2)))*exp(-2*((x-b3)/c3)^2)+d'], ...
        'coefficients', {'a', 'b', 'c', 'a2', 'b2', 'c2', ...
        'a3', 'b3', 'c3','d'});
    
    fit_type_4 = fittype(['(a/(c*sqrt(pi/2)))*exp(-2*((x-b)/c)^2)+' ...
        '(a2/(c2*sqrt(pi/2)))*exp(-2*((x-b2)/c2)^2)+' ...
        '(a3/(c3*sqrt(pi/2)))*exp(-2*((x-b3)/c3)^2)+' ...
        '(a4/(c4*sqrt(pi/2)))*exp(-2*((x-b4)/c4)^2)+d'], ...
        'coefficients', {'a', 'b', 'c', 'a2', 'b2', 'c2', ...
        'a3', 'b3', 'c3', 'a4', 'b4', 'c4','d'});
    
    fit_type_5 = fittype(['(a/(c*sqrt(pi/2)))*exp(-2*((x-b)/c)^2)+' ...
        '(a2/(c2*sqrt(pi/2)))*exp(-2*((x-b2)/c2)^2)+' ...
        '(a3/(c3*sqrt(pi/2)))*exp(-2*((x-b3)/c3)^2)+' ...
        '(a4/(c4*sqrt(pi/2)))*exp(-2*((x-b4)/c4)^2)+' ...
        '(a5/(c5*sqrt(pi/2)))*exp(-2*((x-b5)/c5)^2)+d'], ...
        'coefficients', {'a', 'b', 'c', 'a2', 'b2', 'c2', ...
        'a3', 'b3', 'c3', 'a4', 'b4', 'c4', 'a5', 'b5', 'c5','d'});

else

    fit_type_1 = fittype(['(a/pi)*(0.5*c)/((x-b)^2+(0.5*c)^2)+d'], ...
        'coefficients', {'a', 'b', 'c', 'd'});

    fit_type_2 = fittype(['(a/pi)*(0.5*c)/((x-b)^2+(0.5*c)^2)+' ...
        '(a2/pi)*(0.5*c2)/((x-b2)^2+(0.5*c2)^2)+d'], ...
        'coefficients', {'a', 'b', 'c', 'a2', 'b2', 'c2',  'd'});  

end

% Determining how many peaks to fit and picking fit_type

if number_of_peaks == 1
    fit_type = fit_type_1;
elseif number_of_peaks == 2
    fit_type = fit_type_2;
elseif number_of_peaks == 3
    fit_type = fit_type_3;
elseif number_of_peaks == 4
    fit_type = fit_type_4;
else
    fit_type = fit_type_5;
end

% Setting fitting options

fit_options = fitoptions('Method', 'NonlinearLeastSquares', ...
            'Algorithm', 'Trust-Region', 'StartPoint', start_points, ...
            'Upper', upper_bounds, 'Lower', lower_bounds);

% Fitting data

[fit_result, goodness] = fit(x, y, fit_type, fit_options);