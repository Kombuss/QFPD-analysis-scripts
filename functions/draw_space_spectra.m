function [fig] = draw_space_spectra(x, energy, data, space, fig_visibility, x_axis_limits, y_axis_limits)

% draw_space_spectra - Plot polariton spectra
%   This function draws spectra in k-space or r-space
%
%   Syntax
%       draw_space_spectra(x, energy, data, space, fig_visibility)
%       draw_space_spectra(x, energy, data, space)
%
%   Input Arguments
%       x - Position [px]
%           vector
%       energy - Energy [eV]
%           vector
%       data - Intensity [arb.u.]
%           vector
%       space - Space of the data
%           "kspace" | "rspace"
%
%   Name-Value Arguments
%       fig_visibility - State of figures visibility
%           "off" (default) | "on"
%       x_axis_limits - Limits for x-axis
%           [min(energy) max(energy)] (default) | double array
%       y_axis_limits - Limits for y-axis
%           [min(x) max(x)] (default) | double array
%
%   Output Arguments
%       fig - Figure with plotted data
%           figure
%

% Setting default value for figure visibility and axes limits
 if ~exist('fig_visibility','var')
      fig_visibility = "off";
 end
 if ~exist('x_axis_limits','var')
      x_axis_limits = [min(x) max(x)];
 end
 if ~exist('y_axis_limits','var')
      y_axis_limits = [min(energy) max(energy)];
 end
 
% Creating figure and plotting all the data
fig = figure("Visible", fig_visibility);
fig.Theme = "light";
p1 = pcolor(x, energy, data);

% Allowing for further changes on the same plot
hold on;

% Making transparent edges
set(p1, 'EdgeColor', 'none');

% Changing colormap
colormap(flip(cmocean('ice')));

% Creating colorbar
cb = colorbar(gca, 'eastoutside', 'AxisLocation','out');
set(cb, 'TickLength', 0.025);

% Setting x-axis labels based on which space is being plotted
if space == "kspace"
    xlabel('Wavevector k_{||} (\mum^-^1)');
elseif space == "rspace"
    xlabel('Position (\mum)');
end

% Setting up y-axis label
ylabel('Energy (eV)');

% Setting up x-axis and y-axis limits
xlim(x_axis_limits);
ylim(y_axis_limits);

% Moving axis markers to the surface
set(gca,'layer','top');

% Finishing further changes on the same plot
hold off;