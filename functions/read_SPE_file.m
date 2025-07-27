function [x, energy, data] = read_SPE_file(file_to_analyze)

% This function reads data from .spe file structure with fields containing
% file's name and folder and returns position x [px], energy [eV] and 
% intensity data [arb.u.]. Intensity takes into account expousere time, OD
% filters and subtract background from the same folder

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

% Loading background from .spe file "bg_##s"

file_bg = ['bg_',num2str(expotime),'s'];
fullname_bg = fullfile([file_to_analyze.folder, '\'], file_bg);
data_bg = loadSPE(fullname_bg);
bg = data_bg.int;                       % Intensity [arb.u.]

% Loading grey filter data

OD05 = 0.41088752;
OD1 = 0.1631333;
OD2 = 0.0574673;                % Transmission of filters for 809 nm
OD3 = 0.01297389;
OD4 = 0.00328358;

filter = 'no_filter';

if contains(file_to_analyze.name, 'OD') == 1
    file_name_split = split(file_to_analyze.name, "_");
    OD_idx = find(contains(string(file_name_split), "OD"));
    filter = file_name_split(OD_idx);
    filter = filter{:}(1:3);
end

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

data = data - bg;
data(data<0) = 0;                           % Intensity can't be lower than 0
data = rot90(data);
data = data/(expotime*filter_transmission); % Intensity [arb.u.]

% Centering data

x = 1:size(data,2);
x = x - size(data,2)/2; % X axes [px]
