function [fig] = draw_polariton_spectra(x, energy, data, space)

% draw_polariton_spectra - Plot polariton spectra
%   This function draws polariton spectra in k-space or r-space
%
%   Syntax
%       draw_polariton_spectra(x, energy, data, space)
%
%   Input Arguments
%       x - Position [px]
%           vector
%       energy - Energy [eV]
%           vector
%       data - Intensity [arb.u.]
%           vector
%       space - space of the data ("kspace" or "rspace")
%           string
%
%   Output Arguments
%       fig - figure with plotted data
%           figure
%

% Creating figure and plotting all the data
fig = figure("Visible","off");
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

% Moving axis markers to the surface
set(gca,'layer','top');

% Finishing further changes on the same plot
hold off;