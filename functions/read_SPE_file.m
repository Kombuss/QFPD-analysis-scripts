function [x, energy, data] = read_SPE_file(file_to_analyze, bg_files, ND_filters)

% read_SPE_file - Read .spe file
%   This function reads data from .spe file. Intensity calculation takes 
%   into account exposure time, neutral density filters and subtract 
%   background from the input background file.
%
%   Syntax
%       [x, energy, data] = read_SPE_file(file_to_analyze, bg_files, ND_filters)
%       [x, energy, data] = read_SPE_file(file_to_analyze)
%
%   Input Arguments
%       file_to_analyze - Single .spe file
%           structure with fields containing file's name and folder
%
%   Name-Value Arguments
%       bg_files - All background files
%           [] (default) | structure with fields containing filename and
%           file's folder
%       ND_filters - All files with transmission for ND filters
%           [] (default) | cell array with cells containing 2 double 
%           columns: 1st with wavelength [nm] and 2nd with transmission [%]
%
%   Output Arguments
%       x - Position [px]
%           vector
%       energy - Energy [eV]
%           vector
%       data - Intensity [arb.u.]
%           vector
%

% Setting the default background and OD filter variable
 if ~exist('bg_files','var')
      bg_files = [];
      disp(['No background files provided. Analysis proceeding ' ...
          'without background files']);
 end

 if ~exist('ND_filters','var')
      ND_filters = [];
 end

% Defining physical constants
h = 4.135667*10^(-15);  % Planck constant [eV*s]
c = 299792458;          % Speed of light [m/s]

% Loading data from .spe file
fullname = fullfile([file_to_analyze.folder, '\'], file_to_analyze.name);
file = loadSPE(fullname);    

% Extracting necessary variables from the file
lambda = file.wavelength;           % Wavelength [nm]
energy = flip(h*c*10^9./lambda);    % Energy [eV]
expotime = file.expo_time;          % Exposure time [s]
data = file.int;                    % Intensity [arb.u.]

% Checking if any background files are provided
if isempty(bg_files) == 0

    % Searching for the background file with right exposure time
    background_idx = contains({bg_files.name}, ['_', num2str(expotime), ...
        's']);
    background_file = bg_files(background_idx);
    background_fullname = fullfile([background_file.folder, '\'], ...
        background_file.name);
    
    % Loading background file and reading its intensity
    background = loadSPE(background_fullname);
    background_data = background.int;
else

    % If background not found, then intensity equals zero
    background_data = 0;
    disp(['No background files with the same expurure time as ' ...
        'analyzing file provided. Analysis proceeding without ' ...
        'background file']);
end

% Checking if ND filters are provided
if isempty(ND_filters) == 0
    
    % Determining central wavelength for gray filters transmission
    central_wavelength = lambda(ceil(size(lambda, 1)/2));

    % Loading gray filter data.
    ND_filters_trans = zeros(size(ND_filters));
    for i = 1:size(ND_filters, 1)
        central_wavelength_idx = ...
            find(ND_filters{i}(:,1)==central_wavelength);
        ND_filters_trans(i) = ND_filters{i}(central_wavelength_idx, 2)/100;
    end
    
    % Checking if ND filter was used. "OD#" or "#OD" should be in the 
    % filename
    if contains(upper(file_to_analyze.name), 'OD') == 1
        file_name_split = split(file_to_analyze.name, "_");
        OD_idx = find(contains(upper(string(file_name_split)), "OD"));
        filter = file_name_split(OD_idx);
        filter = filter{:}(1:3);
    else

        % If ND filter not used, then setting default value for filter name
        filter = 'no_filter';
    end
else

    % If ND filters not found, then setting default value for filter name
    filter = 'no_filter';
    disp(['No ND filters files provided. Analysis proceeding without ' ...
        'considering ND filters']);
end

% Setting filter transmission value
switch filter                       
    case {'OD1', '1OD'}
        filter_transmission = ND_filters_trans(1);
    case {'OD2', '2OD'}
        filter_transmission = ND_filters_trans(2);
    case {'OD3', '3OD'}
        filter_transmission = ND_filters_trans(3);
    case {'OD4', '4OD'}
        filter_transmission = ND_filters_trans(4);
    case {'OD5', '5OD'}
        filter_transmission = ND_filters_trans(1) * ND_filters_trans(4);
    case {'OD6', '6OD'}
        filter_transmission = ND_filters_trans(1) * ND_filters_trans(4);
    case {'OD7', '7OD'}
        filter_transmission = ND_filters_trans(1) * ND_filters_trans(4);
    case {'OD8', '8OD'}
        filter_transmission = ND_filters_trans(1) * ND_filters_trans(4);
    otherwise
        filter_transmission = 1;
end

% Subtracting background, rotating intensity matrix and dividing it by
% exposure time
data = data - background_data;
data(data<0) = 0;
data = rot90(data);
data = data/(expotime*filter_transmission);

% Centering x-axis
x = 1:size(data,2);
x = x - size(data,2)/2;
