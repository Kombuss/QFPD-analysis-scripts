function [fig] = extract_and_plot_distribution(file, fig_visibility)

% extract_and_plot_energy_distribution - Reads extracted points, plots 
% energy distribution on the graph and saves it
%   This function reads previously extracted points using
%   extract_and_save_points function, then extracts and saves energy 
%   distribution in a .txt file and plots and saves graph of this 
%   distribution.
%
%   Syntax
%       extract_and_plot_energy_distribution(file)
%
%   Input Arguments
%       file - Single .spe file (not file with extracted points)
%           structure with fields containing file's name and folder
%
%   Name-Value Arguments
%       fig_visibility - State of figures visibility
%           "off" (default) | "on"
%
%   Output Arguments
%       fig - Figure with plotted data
%           figure
%

% Setting default value for figure visibility and axes limits
 if ~exist('fig_visibility','var')
      fig_visibility = "off";
 end

% Setting path and picking .txt files
path = string(file.folder) + "\extracted_points";
files_with_points = dir(fullfile(path, '*.txt'));

% Opening file for saving fit results and writing headline
file_save = string(file.folder) + "\energy_distribution_points\" + ...
    string(file.name(1:3)) + "energy_distribution.txt";
open_file = fopen(file_save, 'w');
fprintf(open_file, '%20s\t %20s\t \n', 'Energy [meV]', ...
    'Intensity [arb.u.]');

% Checking which files are valid, that is which have matching file number
% in their name and are points of lower branch
valid_files = zeros(size(files_with_points));
for i = 1:length(files_with_points)
    filename = files_with_points(i).name;
    if str2double(filename(1:2)) == str2double(file.name(1:2)) && ...
            str2double(filename(4)) == 1
        valid_files(i) = i;
    end
end
files_with_points(valid_files == 0) = [];

if isempty(files_with_points)
    disp([file.name(1:2), '_ file with extracted points not found. ' ...
        'Distribution not extracted.']);
    return;
end

% Reading points from existing file
for i = 1:length(files_with_points)
    fid = fopen(string(path) + "\"+ files_with_points(i).name, 'r');
    header = fgetl(fid);
    data = textscan(fid, repmat('%f', 1, 8));
    energy = data{2};
    energy_k0 = energy(ceil(size(energy,1)/2));
    if isnan(energy_k0)
        energy_k0 = 0;
        disp('Energy for k=0 not found (assumed E0 = 0).')
    end
    int = data{4};
end

% Creating matrices
energy_avg = NaN(ceil(size(energy,1)/2),1);
int_avg = NaN(ceil(size(energy,1)/2),1);

% Averaging energies and intensities for opposites wavevectors
for i = 1:ceil(size(energy,1)/2)
    if isnan(energy(i))
        energy_avg(i) = energy(end+1-i);
        int_avg(i) = int(end+1-i);
    elseif isnan(energy(end+1-i))
        energy_avg(i) = energy(i);
        int_avg(i) = int(i);
    else
    energy_avg(i) = (energy(i)+energy(end+1-i))/2;
    int_avg(i) = (int(i)+int(end+1-i))/2;
    end
end

% Sorting energies and intensities
[energy_sorted, energy_order] = sort(energy_avg);
int_sorted = int_avg(energy_order);
energy_diff = energy_sorted - energy_k0;
energy_diff = energy_diff*10^3;

% Creating figure and plotting all the data
fig = figure("Visible", fig_visibility);
fig.Theme = "light";
plot(energy_diff, int_sorted, "LineWidth", 2);

% Allowing for further changes on the same plot
hold on;

% Setting x and y-axis labels
xlabel('E - E_{0} (meV)');
ylabel('N(E) (cts/s)')

% Setting up x-axis limits
xlim([min(energy_diff), max(energy_diff)])

% Finishing further changes on the same plot
hold off;

% Saving energy distribution points
for i = 1:size(energy_diff,1)
    if ~isnan(energy_diff(i))
        fprintf(open_file, '%20s\t %20s\t \n', num2str(energy_diff(i)), ...
            num2str(int_sorted(i)));
    end
end

% Searching for all saved files and deleting not energy distributions
files_to_merge = dir(fullfile(string(file.folder) + ...
    '\energy_distribution_points', '*.txt'));

files_to_delete = [];

for i = 1:size(files_to_merge, 1)
    if contains(files_to_merge(i).name, 'energy_distribution') == 0
        files_to_delete = [files_to_delete, i];
    end
end

files_to_merge(files_to_delete) = [];

% Opening file to write all energy distributions into and reading all files
% with energy distributions
merged_file = fopen(string(string(file.folder) + ...
    "\energy_distribution_points\") + "all_distributions.txt", 'w');

for i = 1:size(files_to_merge, 1)
    file_open = fopen(string(string(file.folder) + ...
    '\energy_distribution_points') + "\" + ...
        string(files_to_merge(i).name), 'r');
    file_content{i} = cell2mat(textscan(file_open, '%f %f', ...
        'HeaderLines', 1));
end

% Filling matrices to same size
max_size = 0;

for i = 1:size(file_content, 2)
    if size(file_content{i},1) > max_size
        max_size = size(file_content{i},1);
    end
end

for i = 1:size(file_content, 2)
    content_to_fill = file_content{i};
    for j = 1:(max_size-size(file_content{i},1)) 
        content_to_fill = [content_to_fill; [NaN,NaN]];
    end
    file_content(i) = {content_to_fill};
end

% Merging content of all files into one
merged_data = cat(2, file_content{:});

fprintf(merged_file, [repmat('%.15f ', 1, size(merged_data, 2)), '\n'], flip(rot90(merged_data)));

fclose('all');