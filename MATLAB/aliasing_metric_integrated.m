function out = aliasing_metric_integrated(chain, context, varargin)
%ALIASING_METRIC_INTEGRATED One-number anti-aliasing metric.
%
% Liczy całkowitą energię zakłóceń, które aliasują się do badanego pasma.
%
% Wynik główny:
%   AliasRatio_dBc
%
% Interpretacja:
%   bardziej ujemna wartość = lepiej
%
% Przykład:
%   -80 dBc jest o 20 dB lepsze niż -60 dBc,
%   czyli ma 100x mniejszą moc aliasów.

p = inputParser;
addParameter(p, "FMax_Hz", 1.8e6);
addParameter(p, "N", 600000);
addParameter(p, "AliasBand_Hz", [0 10e3]);
addParameter(p, "DesiredBand_Hz", [0 10e3]);
addParameter(p, "InterfererBand_Hz", []);
parse(p, varargin{:});
cfg = p.Results;

fs_final = local_final_fs(chain);

f = linspace(0, cfg.FMax_Hz, cfg.N).';

resp = chain_response(chain, f);
gain2 = resp.magnitude.^2;

f_alias = local_signed_alias(f, fs_final);

alias_band_low = min(cfg.AliasBand_Hz);
alias_band_high = max(cfg.AliasBand_Hz);

desired_low = min(cfg.DesiredBand_Hz);
desired_high = max(cfg.DesiredBand_Hz);

if isempty(cfg.InterfererBand_Hz)
    interferer_low = desired_high;
    interferer_high = cfg.FMax_Hz;
else
    interferer_low = min(cfg.InterfererBand_Hz);
    interferer_high = max(cfg.InterfererBand_Hz);
end

% Czy dana częstotliwość po aliasowaniu trafia do badanego pasma?
if alias_band_low >= 0
    % np. [0 10e3] oznacza abs(alias) od 0 do 10 kHz
    in_alias_band = ...
        abs(f_alias) >= alias_band_low & ...
        abs(f_alias) <= alias_band_high;
else
    % np. [-10e3 10e3] oznacza podpisane pasmo aliasu
    in_alias_band = ...
        f_alias >= alias_band_low & ...
        f_alias <= alias_band_high;
end

% Sygnał użyteczny — tego NIE liczymy jako alias.
desired_mask = ...
    f >= desired_low & ...
    f <= desired_high;

% Zakłócenia spoza pasma użytecznego.
interferer_mask = ...
    f >= interferer_low & ...
    f <= interferer_high;

% To jest właściwy aliasing: zakłócenie spoza pasma,
% które po aliasowaniu wpada do pasma badanego.
alias_mask = in_alias_band & interferer_mask;

% Całkowanie po całej siatce z zerowaniem poza maską.
% To jest ważne, bo alias_mask może mieć wiele rozłącznych kawałków.
P_alias = trapz(f, gain2 .* double(alias_mask));
P_desired_ref = trapz(f, gain2 .* double(desired_mask));

AliasRatio = P_alias / max(P_desired_ref, realmin);
AliasRatio_dBc = 10 * log10(AliasRatio + realmin);

if any(alias_mask)
    WorstAlias_dB = max(resp.magnitude_dB(alias_mask));
else
    WorstAlias_dB = -Inf;
end

AliasInputBandwidth_Hz = trapz(f, double(alias_mask));
DesiredBandwidth_Hz = trapz(f, double(desired_mask));

out = struct();

out.AliasRatio_dBc = AliasRatio_dBc;
out.AliasRatio = AliasRatio;
out.P_alias = P_alias;
out.P_desired_ref = P_desired_ref;
out.WorstAlias_dB = WorstAlias_dB;
out.AliasInputBandwidth_Hz = AliasInputBandwidth_Hz;
out.DesiredBandwidth_Hz = DesiredBandwidth_Hz;

out.FMax_Hz = cfg.FMax_Hz;
out.AliasBand_Hz = cfg.AliasBand_Hz;
out.DesiredBand_Hz = cfg.DesiredBand_Hz;
out.InterfererBand_Hz = [interferer_low interferer_high];

out.table = table( ...
    f, ...
    f_alias, ...
    gain2, ...
    resp.magnitude_dB, ...
    desired_mask, ...
    interferer_mask, ...
    alias_mask, ...
    'VariableNames', { ...
        'InputFrequency_Hz', ...
        'OutputAlias_Hz', ...
        'GainSquared', ...
        'Magnitude_dB', ...
        'DesiredMask', ...
        'InterfererMask', ...
        'AliasMask' ...
    } ...
);

fprintf("\nIntegrated aliasing metric\n");
fprintf("  final fs_out:             %.3f kS/s\n", fs_final/1e3);
fprintf("  analyzed input range:     0...%.3f kHz\n", cfg.FMax_Hz/1e3);
fprintf("  desired band:             %.3f...%.3f kHz\n", desired_low/1e3, desired_high/1e3);
fprintf("  interferer band:          %.3f...%.3f kHz\n", interferer_low/1e3, interferer_high/1e3);

if alias_band_low >= 0
    fprintf("  alias band abs:           %.3f...%.3f kHz\n", alias_band_low/1e3, alias_band_high/1e3);
else
    fprintf("  alias band signed:        %.3f...%.3f kHz\n", alias_band_low/1e3, alias_band_high/1e3);
end

fprintf("  integrated alias ratio:   %.3f dBc\n", AliasRatio_dBc);
fprintf("  worst single alias point: %.3f dB\n", WorstAlias_dB);

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