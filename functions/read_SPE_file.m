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
%           [] (default) | cell array with two cells 1st containing OD 
%           values of a filter and 2nd two double columns: 1st with 
%           wavelength [nm] and 2nd with transmission [%]
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

    % Setting possible string in filename format
    possible_expotime_string = ...
        [strrep([string(['_' ,num2str(expotime), 's']), ...
        string(['_' ,num2str(expotime*1000), 'ms']), ...
        string(['_' ,num2str(expotime*1000*1000), 'us'])], '.', ','), ...
        strrep([string(['_' ,num2str(expotime), 's']), ...
        string(['_' ,num2str(expotime*1000), 'ms']), ...
        string(['_' ,num2str(expotime*1000*1000), 'us'])],'.','p'), ...
        strrep([string(['-' ,num2str(expotime), 's']), ...
        string(['-' ,num2str(expotime*1000), 'ms']), ...
        string(['-' ,num2str(expotime*1000*1000), 'us'])], '.', ','), ...
        strrep([string(['-' ,num2str(expotime), 's']), ...
        string(['-' ,num2str(expotime*1000), 'ms']), ...
        string(['-' ,num2str(expotime*1000*1000), 'us'])],'.','p')];

    % Searching for the background file with right exposure time
    background_idx = contains(lower({bg_files.name}), ...
        possible_expotime_string);
    background_file = bg_files(background_idx);
    background_fullname = fullfile([background_file.folder, '\'], ...
        background_file.name);

    % Checking if background file with proper exposure time was found
    if isempty(background_file)

        % If background not found, then intensity equals zero
        background_data = 0;
        disp(['No ',num2str(expotime) , 's background file was found. ' ...
            'Analysis will proceed without background file']);
    else

        % Loading background file and reading its intensity
        background = loadSPE(background_fullname);
        background_data = background.int;
    end
else

    % If background not found, then intensity equals zero
    background_data = 0;
    disp(['No ',num2str(expotime) , 's background file was found. ' ...
        'Analysis will proceed without background file']);
end

% Checking if ND filters are provided
if isempty(ND_filters) == 0

    % Determining central wavelength for gray filters transmission
    central_wavelength = ceil(lambda(ceil(size(lambda, 1)/2)));

    % Loading gray filter data.
    ND_filters_trans = zeros(size(ND_filters));
    for i = 1:size(ND_filters, 1)
        central_wavelength_idx = ...
            find(ND_filters{i,2}(:,1) == central_wavelength);
        ND_filters_trans(i,2) = ...
        ND_filters{i,2}(central_wavelength_idx, 2)/100;
        ND_filters_trans(i,1) = ND_filters{i,1};
    end

    % Checking if ND filter was used. "OD#" | "#OD" | "ND#" | "#ND" | 
    % should be in the filename
    if contains(upper(file_to_analyze.name), 'OD') == 1
        file_name_split = split(file_to_analyze.name, "_");
        OD_idx = find(contains(upper(string(file_name_split)), "OD"));
        filter = upper(file_name_split(OD_idx));
        if contains(filter, '.SPE')
            filter = upper(filter{:}(1:end-4));
        end

        % Unifying fraction format
        filter = strrep(filter, ',', '.');
        filter = strrep(filter, 'P', '.');
        
        % Extracting just the OD value
        filter = str2double(regexprep(filter, 'OD', ''));

    elseif contains(upper(file_to_analyze.name), 'ND') == 1
        file_name_split = split(file_to_analyze.name, "_");
        OD_idx = find(contains(upper(string(file_name_split)), "ND"));
        filter = upper(file_name_split(OD_idx));
        if contains(filter, '.SPE')
            filter = upper(filter{:}(1:end-4));
        end

        % Unifying fraction format
        filter = strrep(filter, ',', '.');
        filter = strrep(filter, 'P', '.');

        % Extracting just the OD value
        filter = str2double(regexprep(filter, 'ND', ''));
    else

        % If ND filter not used, then setting default value for filter name
        filter = 0;
    end
else

    % If ND filters not found, then setting default value for filter name
    filter = 0;
    disp(['No ND filters files provided. Analysis proceeding without ' ...
        'considering ND filters']);
end

% Setting filter transmission value
filter_idx = find([ND_filters_trans(:,1)] == filter);
if isempty(filter_idx) == 0
    filter_transmission = ND_filters_trans(filter_idx,2);

% If OD is grater than the maximum value of OD in folder with ND filters, 
% then assumption is made, that maxND was used and some additional filter
elseif fix(filter/max([ND_filters_trans(:,1)])) ~= 0 && ~isnan(filter)
    filter_idx = find([ND_filters_trans(:,1)] == ...
        max([ND_filters_trans(:,1)]));
    filter_transmission = ND_filters_trans(filter_idx,2);
    filter_idx = find([ND_filters_trans(:,1)] == ...
        mod(filter,max([ND_filters_trans(:,1)])));
    filter_transmission = ...
    filter_transmission*ND_filters_trans(filter_idx,2);
elseif filter ~= 0
    filter_transmission = 1;
    disp(['No ND', num2str(filter), ' filter file found'])
else
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
