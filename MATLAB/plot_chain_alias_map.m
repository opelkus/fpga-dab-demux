function T = plot_chain_alias_map(chain, f_max_Hz, N, alias_band_Hz)
%PLOT_CHAIN_ALIAS_MAP Alias map after whole filter/decimation chain.
%
% Example:
%   T = plot_chain_alias_map(chain, 3.4e6, 300000, [0 10e3]);
%
% alias_band_Hz:
%   [0 10e3] means absolute output alias frequency 0...10 kHz.
%   [-10e3 10e3] means signed output alias frequency -10...10 kHz.

if nargin < 2 || isempty(f_max_Hz)
    f_max_Hz = 3 * get_first_digital_fs(chain);
end

if nargin < 3 || isempty(N)
    N = 200000;
end

if nargin < 4 || isempty(alias_band_Hz)
    alias_band_Hz = [0 10e3];
end

fs_final = get_final_fs(chain);

f = linspace(0, f_max_Hz, N).';

resp = chain_response(chain, f);

f_alias = signed_alias(f, fs_final);

band_low = min(alias_band_Hz);
band_high = max(alias_band_Hz);

% If band is positive, treat it as absolute alias frequency band.
if band_low >= 0
    in_band = abs(f_alias) >= band_low & abs(f_alias) <= band_high;
else
    in_band = f_alias >= band_low & f_alias <= band_high;
end

T = table( ...
    f, ...
    f_alias, ...
    in_band, ...
    resp.magnitude, ...
    resp.magnitude_dB, ...
    resp.phase_deg, ...
    'VariableNames', { ...
        'InputFrequency_Hz', ...
        'OutputAlias_Hz', ...
        'InSelectedBand', ...
        'Magnitude', ...
        'Magnitude_dB', ...
        'Phase_deg' ...
    } ...
);

figure;
tiledlayout(3, 1);

%% Alias map

nexttile;
hold on;

plot(T.InputFrequency_Hz/1e3, ...
     T.OutputAlias_Hz/1e3, ...
     "LineWidth", 1.0);

plot(T.InputFrequency_Hz(T.InSelectedBand)/1e3, ...
     T.OutputAlias_Hz(T.InSelectedBand)/1e3, ...
     ".", ...
     "MarkerSize", 5);

grid on;
xlabel("Input analog frequency [kHz]");
ylabel("Final output alias [kHz]");
title("Alias map after full chain");

if band_low >= 0
    yline(band_high/1e3, "--", "+selected band");
    yline(-band_high/1e3, "--", "-selected band");
else
    yline(band_low/1e3, "--", "band low");
    yline(band_high/1e3, "--", "band high");
end

hold off;

%% Total attenuation

nexttile;
hold on;

plot(T.InputFrequency_Hz/1e3, ...
     T.Magnitude_dB, ...
     "LineWidth", 1.0);

plot(T.InputFrequency_Hz(T.InSelectedBand)/1e3, ...
     T.Magnitude_dB(T.InSelectedBand), ...
     ".", ...
     "MarkerSize", 5);

grid on;
xlabel("Input analog frequency [kHz]");
ylabel("Total attenuation [dB]");
title("Total attenuation before aliasing to final output");
ylim([-160 5]);

hold off;

%% Phase

nexttile;
hold on;

plot(T.InputFrequency_Hz/1e3, ...
     T.Phase_deg, ...
     "LineWidth", 1.0);

plot(T.InputFrequency_Hz(T.InSelectedBand)/1e3, ...
     T.Phase_deg(T.InSelectedBand), ...
     ".", ...
     "MarkerSize", 5);

grid on;
xlabel("Input analog frequency [kHz]");
ylabel("Total phase [deg]");
title("Total phase response of full chain");

hold off;

%% Summary

selected = T(T.InSelectedBand, :);

fprintf("\nFull chain alias analysis\n");
fprintf("  final fs_out:       %.3f kS/s\n", fs_final/1e3);
fprintf("  final Nyquist:      %.3f kHz\n", fs_final/2/1e3);
fprintf("  analyzed up to:     %.3f kHz\n", f_max_Hz/1e3);

if band_low >= 0
    fprintf("  selected abs band:  %.3f...%.3f kHz\n", ...
        band_low/1e3, band_high/1e3);
else
    fprintf("  selected band:      %.3f...%.3f kHz\n", ...
        band_low/1e3, band_high/1e3);
end

fprintf("\nChain stages:\n");
for k = 1:numel(chain)
    fprintf("  %d: %s\n", k, chain{k}.name);
end

if ~isempty(selected)
    [worst_dB, idx] = max(selected.Magnitude_dB);

    fprintf("\nWorst leak into selected band:\n");
    fprintf("  input frequency:   %.3f kHz\n", ...
        selected.InputFrequency_Hz(idx)/1e3);
    fprintf("  output alias:      %.3f kHz\n", ...
        selected.OutputAlias_Hz(idx)/1e3);
    fprintf("  attenuation:       %.3f dB\n", worst_dB);
    fprintf("  phase:             %.3f deg\n", ...
        selected.Phase_deg(idx));
else
    fprintf("\nNo points landed in selected band. Increase N.\n");
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

error("No stage with fs_out_Hz found.");

end


function fs_first = get_first_digital_fs(chain)

fs_first = NaN;

for k = 1:numel(chain)
    if isfield(chain{k}, "fs_in_Hz") && ~isnan(chain{k}.fs_in_Hz)
        fs_first = chain{k}.fs_in_Hz;
        return;
    end
end

error("No digital stage with fs_in_Hz found.");

end


function f_alias = signed_alias(f_Hz, fs_Hz)

f_alias = mod(f_Hz + fs_Hz/2, fs_Hz) - fs_Hz/2;

end