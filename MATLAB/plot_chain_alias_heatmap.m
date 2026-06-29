function [T, Hmap, x_edges, y_edges] = plot_chain_alias_heatmap(chain, f_max_Hz, N, varargin)
%PLOT_CHAIN_ALIAS_HEATMAP Heatmap of aliasing through the whole chain.
%
% X axis: input analog frequency
% Y axis: final output alias frequency
% Color: worst attenuation in each bin, dB
%
% Example:
%   [T, Hmap] = plot_chain_alias_heatmap(chain, 1.8e6, 600000, ...
%       "XBins", 1000, ...
%       "YBins", 400, ...
%       "CLim_dB", [-140 5]);

p = inputParser;

addParameter(p, "XBins", 1200);
addParameter(p, "YBins", 500);
addParameter(p, "CLim_dB", [-140 5]);
addParameter(p, "AliasBand_Hz", []);
addParameter(p, "UseAbsBand", true);
addParameter(p, "Title", "Alias heatmap: input frequency → final output alias");

parse(p, varargin{:});
cfg = p.Results;

if nargin < 2 || isempty(f_max_Hz)
    f_max_Hz = 3 * get_first_digital_fs(chain);
end

if nargin < 3 || isempty(N)
    N = 500000;
end

fs_final = get_final_fs(chain);

f_in = linspace(0, f_max_Hz, N).';
resp = chain_response(chain, f_in);

f_alias = signed_alias(f_in, fs_final);
atten_dB = resp.magnitude_dB;

%% Build bins

x_edges = linspace(0, f_max_Hz, cfg.XBins + 1);
y_edges = linspace(-fs_final/2, fs_final/2, cfg.YBins + 1);

x_bin = discretize(f_in, x_edges);
y_bin = discretize(f_alias, y_edges);

valid = ~isnan(x_bin) & ~isnan(y_bin);

% We want worst leak per bin, so use max dB.
Hmap_vec = accumarray( ...
    [y_bin(valid), x_bin(valid)], ...
    atten_dB(valid), ...
    [cfg.YBins, cfg.XBins], ...
    @max, ...
    NaN ...
);

Hmap = Hmap_vec;

x_centers = 0.5 * (x_edges(1:end-1) + x_edges(2:end));
y_centers = 0.5 * (y_edges(1:end-1) + y_edges(2:end));

%% Output table

T = table( ...
    f_in, ...
    f_alias, ...
    atten_dB, ...
    resp.phase_deg, ...
    'VariableNames', { ...
        'InputFrequency_Hz', ...
        'OutputAliasFrequency_Hz', ...
        'Attenuation_dB', ...
        'Phase_deg' ...
    } ...
);

%% Plot heatmap

figure;

imagesc(x_centers/1e3, y_centers/1e3, Hmap);
axis xy;
colormap turbo;
cb = colorbar;
cb.Label.String = "Worst attenuation in bin [dB]";
clim(cfg.CLim_dB);

xlabel("Input analog frequency [kHz]");
ylabel("Final output alias frequency [kHz]");
title(cfg.Title);

grid on;

yline(fs_final/2/1e3, "--", "+final Nyquist");
yline(-fs_final/2/1e3, "--", "-final Nyquist");
yline(0, ":", "0 Hz");

%% Optional selected output band lines

alias_band_Hz = cfg.AliasBand_Hz;

if ~isempty(alias_band_Hz)
    band_low = min(alias_band_Hz);
    band_high = max(alias_band_Hz);

    if cfg.UseAbsBand && band_low >= 0
        yline(band_high/1e3, "--", "+selected band");
        yline(-band_high/1e3, "--", "-selected band");

        if band_low > 0
            yline(band_low/1e3, "--", "+band low");
            yline(-band_low/1e3, "--", "-band low");
        end
    else
        yline(band_low/1e3, "--", "band low");
        yline(band_high/1e3, "--", "band high");
    end
end

%% Summary

fprintf("\nAlias heatmap\n");
fprintf("  final fs_out:       %.3f kS/s\n", fs_final / 1e3);
fprintf("  final Nyquist:      %.3f kHz\n", fs_final / 2 / 1e3);
fprintf("  analyzed up to:     %.3f kHz\n", f_max_Hz / 1e3);
fprintf("  points:             %d\n", N);
fprintf("  heatmap bins:        %d x %d\n", cfg.XBins, cfg.YBins);

fprintf("\nChain stages:\n");
for k = 1:numel(chain)
    fprintf("  %d: %s\n", k, chain{k}.name);
end

end


function fs_final = get_final_fs(chain)

fs_final = NaN;

for k = numel(chain):-1:1
    if isfield(chain{k}, "fs_out_Hz") && ~isnan(chain{k}.fs_out_Hz)
        fs_final = chain{k}.fs_out_Hz;
        return;
    end
end

error("No stage with fs_out_Hz found in chain.");

end


function fs_first = get_first_digital_fs(chain)

fs_first = NaN;

for k = 1:numel(chain)
    if isfield(chain{k}, "fs_in_Hz") && ~isnan(chain{k}.fs_in_Hz)
        fs_first = chain{k}.fs_in_Hz;
        return;
    end
end

error("No digital stage with fs_in_Hz found in chain.");

end


function f_alias = signed_alias(f_Hz, fs_Hz)

f_alias = mod(f_Hz + fs_Hz/2, fs_Hz) - fs_Hz/2;

end