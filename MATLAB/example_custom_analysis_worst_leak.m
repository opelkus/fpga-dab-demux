function out = example_custom_analysis_worst_leak(chain, context, varargin)
%EXAMPLE_CUSTOM_ANALYSIS_WORST_LEAK Example analysis_custom() function.
%
% Usage inside a study file:
%   analysis_custom(@example_custom_analysis_worst_leak, ...
%       "Name", "Worst leak table", ...
%       "FMax_Hz", 1.8e6, ...
%       "N", 300000, ...
%       "AliasBand_Hz", [0 10e3])

p = inputParser;
addParameter(p, "FMax_Hz", 1.8e6);
addParameter(p, "N", 300000);
addParameter(p, "AliasBand_Hz", [0 10e3]);
parse(p, varargin{:});
cfg = p.Results;

fs_final = local_final_fs(chain);

f = linspace(0, cfg.FMax_Hz, cfg.N).';
resp = chain_response(chain, f);
f_alias = local_signed_alias(f, fs_final);

band_low = min(cfg.AliasBand_Hz);
band_high = max(cfg.AliasBand_Hz);

if band_low >= 0
    in_band = abs(f_alias) >= band_low & abs(f_alias) <= band_high;
else
    in_band = f_alias >= band_low & f_alias <= band_high;
end

T = table( ...
    f, ...
    f_alias, ...
    resp.magnitude_dB, ...
    resp.phase_deg, ...
    in_band, ...
    'VariableNames', { ...
        'InputFrequency_Hz', ...
        'OutputAlias_Hz', ...
        'Magnitude_dB', ...
        'Phase_deg', ...
        'InSelectedBand' ...
    } ...
);

selected = T(T.InSelectedBand, :);

out = struct();
out.table = T;
out.selected = selected;
out.context = context;

if isempty(selected)
    fprintf("\nCustom worst-leak analysis: no points in selected band.\n");
    out.worst = [];
    return;
end

[worst_dB, idx] = max(selected.Magnitude_dB);
out.worst = selected(idx, :);

fprintf("\nCustom worst-leak analysis\n");
fprintf("  input frequency:   %.3f kHz\n", selected.InputFrequency_Hz(idx)/1e3);
fprintf("  output alias:      %.3f kHz\n", selected.OutputAlias_Hz(idx)/1e3);
fprintf("  attenuation:       %.3f dB\n", worst_dB);

end


function fs_final = local_final_fs(chain)

for k = numel(chain):-1:1
    if isfield(chain{k}, "fs_out_Hz") && ~isnan(chain{k}.fs_out_Hz)
        fs_final = chain{k}.fs_out_Hz;
        return;
    end
end

error("No stage with fs_out_Hz found.");

end


function f_alias = local_signed_alias(f_Hz, fs_Hz)

f_alias = mod(f_Hz + fs_Hz/2, fs_Hz) - fs_Hz/2;

end
