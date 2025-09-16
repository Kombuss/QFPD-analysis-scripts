function [x, energy, data] = read_SPE_file(file_to_analyze, background_files)

% This function reads data from .spe file structure with fields containing
% file's name and folder and returns position x [px], energy [eV] and 
% intensity data [arb.u.]. Intensity takes into account expousere time, OD
% filters and subtract background from the input background file.

% Checking if file with background is provided

 if ~exist('background_files','var')
      background_files = [];                                                 % Default background_file value
      disp(['No background files provided. Analysis proceeding without ' ...
          'background files']);                                              % Dispaying message
 end

% Defining physical constants

h = 4.135667*10^(-15);  % Planck constant [eV*s]
c = 299792458;          % Speed of light [m/s]

% Loading data from .spe file

fullname = fullfile([file_to_analyze.folder, '\'], file_to_analyze.name);   % Path and name of the file in a single variable

file = loadSPE(fullname);           % Loading data from file being read
lambda = file.wavelength;           % Wavelength [nm]
energy = flip(h*c*10^9./lambda);    % Energy [eV]
expotime = file.expo_time;          % Exposure time [s]
data = file.int;                    % Intensity [arb.u.]

% Loading background from .spe file

if isempty(background_files) == 0

    background_idx = contains({background_files.name}, ['_', num2str(expotime), 's']);  % Searching for file with right expusure time
    background_file = background_files(background_idx);                                 % Saving background file with right exposure time

    background_fullname = fullfile([background_file.folder, '\'], background_file.name);    % Path and name of the file in a single variable

    background = loadSPE(background_fullname);  % Loading background data
    background_data = background.int;           % Intensity [arb.u.]
else
    background_data = 0;                        % If background not found intensity equals zero
end

% Loading grey filter data. For now only for one wavelength

OD05 = 0.41088752;
OD1 = 0.1631333;
OD2 = 0.0574673;                % Transmission of filters for 809 nm
OD3 = 0.01297389;
OD4 = 0.00328358;

filter = 'no_filter';   % Default value for filter varable

if contains(file_to_analyze.name, 'OD') == 1                % Checking if there is OD value in file's name
    file_name_split = split(file_to_analyze.name, "_");     % Dividing file name to list with "_" as separator
    OD_idx = find(contains(string(file_name_split), "OD")); % Searching for element with "OD"
    filter = file_name_split(OD_idx);                       % Saving OD value
    filter = filter{:}(1:3);                                % Cutting filter string to only 3 characters: "OD#"
end

switch filter                       % Setting filter_transmission value 
    case 'OD0'
        filter_transmission = OD05;
    case 'OD1'
        filter_transmission = OD1;
    case 'OD2'
        filter_transmission = OD2;
    case 'OD3'
        filter_transmission = OD3;
    case 'OD4'
        filter_transmission = OD4;
    case 'OD5'
        filter_transmission = OD1 * OD4;
    case 'OD6'
        filter_transmission = OD2 * OD4;
    case 'OD7'
        filter_transmission = OD3 * OD4;
    case 'OD8'
        filter_transmission = OD4 * OD4;
    otherwise
        filter_transmission = 1;
end

% Subtracting background, rotating intensity matrix and dividing it by
% exposure time

data = data - background_data;              % Subtracting background intensity
data(data<0) = 0;                           % Intensity can't be lower than 0
data = rot90(data);                         % Rotating data matrix
data = data/(expotime*filter_transmission); % Intensity [arb.u.] divided by exposure time and filter transmission

% Centering data

x = 1:size(data,2);     % X axes [px]
x = x - size(data,2)/2; % X axes [px] centered at 0
