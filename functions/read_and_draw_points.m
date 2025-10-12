function [] = read_and_draw_points(file)

% read_and_draw_points - Reads extracted points and plots them on the graph
%   This function reads previously extracted points using
%   extract_and_save_points function and plots them on currently active
%   figure.
%
%   Syntax
%       read_and_draw_points(file)
%
%   Input Arguments
%       file - Single .spe file (not file with extracted points)
%           structure with fields containing file's name and folder
%

% Setting path and picking .txt files
path = string(file.folder) + "\extracted_points";
files_with_points = dir(fullfile(path, '*.txt'));

% Checking which files are valid, that is which have matching file number
% in their name
valid_files = zeros(size(files_with_points));
for i = 1:length(files_with_points)
    filename = files_with_points(i).name;
    if str2double(filename(1:2)) == str2double(file.name(1:2))
        valid_files(i) = i;
    end
end
files_with_points(valid_files == 0) = [];

if isempty(files_with_points)
    disp([file.name(1:2), '_ file with extracted points not found. ' ...
        'Points not drawn.']);
    return;
end

% Preparing for plotting on existing graph
hold on;

% Reading and plotting points from existing file
for i = 1:length(files_with_points)
    fid = fopen(string(path) + "\"+ files_with_points(i).name, 'r');
    header = fgetl(fid);
    data = textscan(fid, repmat('%f', 1, 8));
    k = data{1};
    energy = data{2};
    plot(k, energy, Color=[1,0.7,0], LineWidth=2);
end

% Finishing plotting on existing graph
hold off;