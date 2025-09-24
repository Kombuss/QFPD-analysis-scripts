function [x, energy, data] = read_SPE_file(file_to_analyze, bg_files)

% read_SPE_file - Read .spe file
%   This function reads data from .spe file structure with fields 
%   containing file's name and folder. Intensity calculation takes into 
%   account exposure time, OD filters and subtract background from the 
%   input background file.
%
%   Syntax
%       [x, energy, data] = read_SPE_file(file_to_analyze, bg_files)
%       [x, energy, data] = read_SPE_file(file_to_analyze)
%
%   Input Arguments
%       file_to_analyze - Single .spe file
%           structure with fields containing file's name and folder
%
%   Name-Value Arguments
%       bg_files - All background files
%           [] (default) | structure with fields containing files' name and
%           folder
%
%   Output Arguments
%       x - Position [px]
%           vector
%       energy - Energy [eV]
%           vector
%       data - Intensity [arb.u.]
%           vector
%

% Setting the default background variable
 if ~exist('bg_files','var')
      bg_files = [];
      disp(['No background files provided. Analysis proceeding ' ...
          'without background files']);
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

% Loading grey filter data. For now only for one wavelength (809 nm)
% !!!FIX!!! (Transmission extracted from excel file for each filer based on
% center wavelength of a measurment)
OD05 = 0.41088752;
OD1 = 0.1631333;
OD2 = 0.0574673;
OD3 = 0.01297389;
OD4 = 0.00328358;

% Creating and setting default value for filter name
filter = 'no_filter';

% Checking if OD filter was used. "OD#" should be in file name
if contains(file_to_analyze.name, 'OD') == 1
    file_name_split = split(file_to_analyze.name, "_");
    OD_idx = find(contains(string(file_name_split), "OD"));
    filter = file_name_split(OD_idx);
    filter = filter{:}(1:3);
end

% Setting filter transmission value
switch filter                       
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
data = data - background_data;
data(data<0) = 0;
data = rot90(data);
data = data/(expotime*filter_transmission);

% Centering x-axis
x = 1:size(data,2);
x = x - size(data,2)/2;
