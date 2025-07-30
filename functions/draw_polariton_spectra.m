function [fig] = draw_polariton_spectra(x, energy, data, space)

% This function draws polariton spectra in k-space or r-space based on 
% wavevector or position on x axis (x) [um^-1], energy [eV], intensity 
% (data) [arb.u.], numerical aperature (NA) [arb.u.] and type of space. 
% Function returns figure, on which everything is plotted.

% Creating figure and drawing graph (X: wavevactor or position, Y: energy, C: intensity)

fig = figure("Visible","off");  % Creating figure without displaying it
fig.Theme = "light";            % Setting the figure theme to light
p1 = pcolor(x, energy, data);   % Ploting pcolor graph on the figure

hold on;                        % Allowing for futher changes on the same plot

set(p1, 'EdgeColor', 'none');   % Making transparent edges

colormap(flip(cmocean('ice'))); % Changing colormap

cb = colorbar(gca, 'eastoutside', 'AxisLocation','out');    % Creating colorbar
set(cb, 'TickLength', 0.025);                               % Changing thicknes of the colorbar

% Setting axes labels

if space == "kspace"                        % Checking which space is plotted and setting up x axis label accordingly
    xlabel('Wavevector k_{||} (\mum^-^1)');
elseif space == "rspace"
    xlabel('Position (\mum)');
end

ylabel('Energy (eV)');  % Setting up y axis label

set(gca,'layer','top'); % MOcing axis markers to the surface

hold off;               % Finishing futher changes on the same plot