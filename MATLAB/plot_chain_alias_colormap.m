function T = plot_chain_alias_colormap(chain, f_max_Hz, N, varargin)
%PLOT_CHAIN_ALIAS_COLORMAP Alias map with attenuation encoded as color.
%
% X axis: input analog frequency
% Y axis: final output frequency after aliasing
% Color: total chain attenuation in dB
%
% Example:
%   T = plot_chain_alias_colormap(chain, 1.8e6, 300000);
%
% Example with highlighted output band:
%   T = plot_chain_alias_colormap(chain, 1.8e6, 300000, ...
%       "AliasBand_Hz", [0 10e3], ...
%       "CLim_dB", [-140 5], ...
%       "MarkerSize", 4);

p = inputParser;

addParameter(p, "AliasBand_Hz", []);
addParameter(p, "CLim_dB", [-140 5]);
addParameter(p, "MarkerSize", 4);
addParameter(p, "UseAbsBand", true);
addParameter(p, "ShowGrid", true);
addParameter(p, "Title", "Alias map: input frequency → final output alias");

parse(p, varargin{:});
cfg = p.Results;

if nargin < 2 || isempty(f_max_Hz)
    f_max_Hz = 3 * get_first_digital_fs(chain);
end

if nargin < 3 || isempty(N)
    N = 200000;
end

fs_final = get_final_fs(chain);

f_in = linspace(0, f_max_Hz, N).';

resp = chain_response(chain, f_in);

f_out_alias = signed_alias(f_in, fs_final);

atten_dB = resp.magnitude_dB;

%% Selected output band mask

alias_band_Hz = cfg.AliasBand_Hz;

if isempty(alias_band_Hz)
    in_band = false(size(f_in));
else
    band_low = min(alias_band_Hz);
    band_high = max(alias_band_Hz);

    if cfg.UseAbsBand && band_low >= 0
        in_band = abs(f_out_alias) >= band_low & ...
                  abs(f_out_alias) <= band_high;
    else
        in_band = f_out_alias >= band_low & ...
                  f_out_alias <= band_high;
    end
end

%% Output table

T = table( ...
    f_in, ...
    f_out_alias, ...
    atten_dB, ...
    resp.phase_deg, ...
    in_band, ...
    'VariableNames', { ...
        'InputFrequency_Hz', ...
        'OutputAliasFrequency_Hz', ...
        'Attenuation_dB', ...
        'Phase_deg', ...
        'InSelectedBand' ...
    } ...
);

%% Plot

figure;
hold on;

scatter( ...
    T.InputFrequency_Hz / 1e3, ...
    T.OutputAliasFrequency_Hz / 1e3, ...
    cfg.MarkerSize, ...
    T.Attenuation_dB, ...
    "filled" ...
);

colormap turbo;
cb = colorbar;
cb.Label.String = "Total attenuation [dB]";
clim(cfg.CLim_dB);

xlabel("Input analog frequency [kHz]");
ylabel("Final output alias frequency [kHz]");
title(cfg.Title);

if cfg.ShowGrid
    grid on;
end

ylim([-fs_final/2, fs_final/2] / 1e3);

yline(fs_final/2/1e3, "--", "+final Nyquist");
yline(-fs_final/2/1e3, "--", "-final Nyquist");
yline(0, ":", "0 Hz");

if ~isempty(alias_band_Hz)
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

hold off;

%% Summary

fprintf("\nAlias colormap\n");
fprintf("  final fs_out:       %.3f kS/s\n", fs_final / 1e3);
fprintf("  final Nyquist:      %.3f kHz\n", fs_final / 2 / 1e3);
fprintf("  analyzed up to:     %.3f kHz\n", f_max_Hz / 1e3);
fprintf("  points:             %d\n", N);

fprintf("\nChain stages:\n");
for k = 1:numel(chain)
    fprintf("  %d: %s\n", k, chain{k}.name);
end

if ~isempty(alias_band_Hz)
    selected = T(T.InSelectedBand, :);

    fprintf("\nSelected alias band:\n");

    if cfg.UseAbsBand && band_low >= 0
        fprintf("  abs output alias:   %.3f...%.3f kHz\n", ...
            band_low / 1e3, band_high / 1e3);
    else
        fprintf("  signed output alias %.3f...%.3f kHz\n", ...
            band_low / 1e3, band_high / 1e3);
    end

    if ~isempty(selected)
        [worst_dB, idx] = max(selected.Attenuation_dB);

        fprintf("\nWorst leak into selected band:\n");
        fprintf("  input frequency:    %.3f kHz\n", ...
            selected.InputFrequency_Hz(idx) / 1e3);
        fprintf("  output alias:       %.3f kHz\n", ...
            selected.OutputAliasFrequency_Hz(idx) / 1e3);
        fprintf("  attenuation:        %.3f dB\n", worst_dB);
        fprintf("  phase:              %.3f deg\n", ...
            selected.Phase_deg(idx));
    else
        fprintf("  No points landed in selected band. Increase N.\n");
    end
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

