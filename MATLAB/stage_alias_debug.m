function out = stage_alias_debug(chain, context, varargin)
%STAGE_ALIAS_DEBUG Plot attenuation of every digital stage separately.
%
% Shows ADC/CIC/FIR stage responses in their own local frequency domains.
% For decimating stages it also marks input-frequency regions which alias
% into the selected output band, e.g. 0...BW_DAB.
%
% Intended use from main.m:
%
%   analysis_custom(@stage_alias_debug, ...
%       "Name", "Stage-by-stage alias debug", ...
%       "AliasBand_Hz", [0 BW_DAB], ...
%       "DesiredBand_Hz", [0 BW_DAB]);

p = inputParser;
addParameter(p, "N", 80000);
addParameter(p, "AliasBand_Hz", [0 768e3]);
addParameter(p, "DesiredBand_Hz", [0 768e3]);
addParameter(p, "YLim_dB", [-140 5]);
addParameter(p, "ShowADC", true);
addParameter(p, "SeparateFigures", true);
parse(p, varargin{:});
cfg = p.Results;

alias_low  = min(cfg.AliasBand_Hz);
alias_high = max(cfg.AliasBand_Hz);

desired_low  = min(cfg.DesiredBand_Hz);
desired_high = max(cfg.DesiredBand_Hz);

plot_indices = [];

for k = 1:numel(chain)

    st = chain{k};

    % Analog stages have fs_in_Hz/fs_out_Hz as NaN. Digital stages have
    % finite sample rates. This is the key difference from analog_alias_debug.
    if ~isfield(st, "fs_in_Hz") || ~isfield(st, "fs_out_Hz")
        continue;
    end

    if isnan(st.fs_in_Hz) || isnan(st.fs_out_Hz)
        continue;
    end

    if ~isfield(st, "response")
        continue;
    end

    if ~cfg.ShowADC
        if isfield(st, "type") && contains(lower(string(st.type)), "adc")
            continue;
        end
    end

    plot_indices(end + 1) = k; %#ok<AGROW>
end

if isempty(plot_indices)
    warning("stage_alias_debug(): no digital stages found. Check fs_in_Hz/fs_out_Hz fields in chain.");
    out = struct();
    out.table = table();
    return;
end

summary_stage_index = [];
summary_stage_name = strings(0, 1);
summary_stage_type = strings(0, 1);
summary_fs_in_Hz = [];
summary_fs_out_Hz = [];
summary_decimation = [];
summary_alias_min_Hz = [];
summary_alias_max_Hz = [];
summary_worst_alias_attenuation_dB = [];
summary_integrated_alias_power_dB = [];

fprintf("\nStage-by-stage alias debug\n");
fprintf("  desired band:           %.6f...%.6f MHz\n", desired_low/1e6, desired_high/1e6);

if alias_low >= 0
    fprintf("  alias band abs:         %.6f...%.6f MHz\n", alias_low/1e6, alias_high/1e6);
else
    fprintf("  alias band signed:      %.6f...%.6f MHz\n", alias_low/1e6, alias_high/1e6);
end

if ~cfg.SeparateFigures
    figure("Name", "Stage-by-stage alias debug");
    tiledlayout(numel(plot_indices), 1, "TileSpacing", "compact");
end

for ii = 1:numel(plot_indices)

    k = plot_indices(ii);
    st = chain{k};

    fs_in = st.fs_in_Hz;
    fs_out = st.fs_out_Hz;

    if isfield(st, "decimation")
        decim = st.decimation;
    else
        decim = fs_in / fs_out;
    end

    f = linspace(0, fs_in/2, cfg.N).';

    H = st.response(f);
    H = H(:);
    mag = abs(H);
    mag_dB = 20 * log10(mag + eps);

    f_alias = local_signed_alias(f, fs_out);

    if alias_low >= 0
        in_alias_band = ...
            abs(f_alias) >= alias_low & ...
            abs(f_alias) <= alias_high;
    else
        in_alias_band = ...
            f_alias >= alias_low & ...
            f_alias <= alias_high;
    end

    desired_mask = ...
        f >= desired_low & ...
        f <= desired_high;

    % Out-of-band input frequencies of this stage which fold into AliasBand_Hz.
    alias_mask = in_alias_band & ~desired_mask & f > desired_high;

    if any(alias_mask)
        alias_min_Hz = min(f(alias_mask));
        alias_max_Hz = max(f(alias_mask));
        worst_alias_attenuation_dB = max(mag_dB(alias_mask));
        integrated_alias_power_dB = 10 * log10(trapz(f, mag.^2 .* double(alias_mask)) + realmin);
    else
        alias_min_Hz = NaN;
        alias_max_Hz = NaN;
        worst_alias_attenuation_dB = -Inf;
        integrated_alias_power_dB = -Inf;
    end

    if cfg.SeparateFigures
        figure(100 + ii);
        clf;
        
        set(gcf, ...
            "Name", sprintf("%02d - Stage alias debug - %s", ii, st.name), ...
            "NumberTitle", "off" ...
        );
        
        hold on;
    else
        nexttile;
    end

    hold on;
    plot(f/1e6, mag_dB, "LineWidth", 1.2);

    if any(alias_mask)
        plot(f(alias_mask)/1e6, mag_dB(alias_mask), ".", "MarkerSize", 5);
    end

    xline(desired_high/1e6, "--", "BW_DAB");

    if isfield(st, "stopband_start_Hz")
        xline(st.stopband_start_Hz/1e6, "--", "stopband");
    end

    if isfield(st, "output_nyquist_Hz")
        xline(st.output_nyquist_Hz/1e6, ":", "out Nyq");
    else
        xline(fs_out/2/1e6, ":", "out Nyq");
    end

    grid on;
    xlim([0 fs_in/2/1e6]);
    ylim(cfg.YLim_dB);

    xlabel("Input frequency to this stage [MHz]");
    ylabel("Stage attenuation |H| [dB]");
    title(sprintf("%d: %s", k, char(string(st.name))), "Interpreter", "none");

    if any(alias_mask)
        legend("stage response", "aliases to selected band", "Location", "southwest");
    else
        legend("stage response", "Location", "southwest");
    end

    hold off;

    fprintf("\n  %d: %s\n", k, string(st.name));
    fprintf("     type:       %s\n", string(st.type));
    fprintf("     fs_in:      %.6f MHz\n", fs_in/1e6);
    fprintf("     fs_out:     %.6f MHz\n", fs_out/1e6);
    fprintf("     decimation: %.3f\n", decim);

    if isfield(st, "cutoff_Hz")
        fprintf("     cutoff:     %.6f MHz\n", st.cutoff_Hz/1e6);
    end

    if isfield(st, "stopband_start_Hz")
        fprintf("     stopband:   %.6f MHz\n", st.stopband_start_Hz/1e6);
    end

    if any(alias_mask)
        fprintf("     alias input region: %.6f...%.6f MHz\n", alias_min_Hz/1e6, alias_max_Hz/1e6);
        fprintf("     worst stage attenuation in alias region: %.3f dB\n", worst_alias_attenuation_dB);
    else
        fprintf("     no out-of-band points alias into selected band in plotted range\n");
    end

    summary_stage_index(end + 1, 1) = k; %#ok<AGROW>
    summary_stage_name(end + 1, 1) = string(st.name); %#ok<AGROW>
    summary_stage_type(end + 1, 1) = string(st.type); %#ok<AGROW>
    summary_fs_in_Hz(end + 1, 1) = fs_in; %#ok<AGROW>
    summary_fs_out_Hz(end + 1, 1) = fs_out; %#ok<AGROW>
    summary_decimation(end + 1, 1) = decim; %#ok<AGROW>
    summary_alias_min_Hz(end + 1, 1) = alias_min_Hz; %#ok<AGROW>
    summary_alias_max_Hz(end + 1, 1) = alias_max_Hz; %#ok<AGROW>
    summary_worst_alias_attenuation_dB(end + 1, 1) = worst_alias_attenuation_dB; %#ok<AGROW>
    summary_integrated_alias_power_dB(end + 1, 1) = integrated_alias_power_dB; %#ok<AGROW>

end

out = struct();

out.table = table( ...
    summary_stage_index, ...
    summary_stage_name, ...
    summary_stage_type, ...
    summary_fs_in_Hz, ...
    summary_fs_out_Hz, ...
    summary_decimation, ...
    summary_alias_min_Hz, ...
    summary_alias_max_Hz, ...
    summary_worst_alias_attenuation_dB, ...
    summary_integrated_alias_power_dB, ...
    'VariableNames', { ...
        'StageIndex', ...
        'StageName', ...
        'StageType', ...
        'FsIn_Hz', ...
        'FsOut_Hz', ...
        'Decimation', ...
        'AliasInputMin_Hz', ...
        'AliasInputMax_Hz', ...
        'WorstAliasAttenuation_dB', ...
        'IntegratedAliasPower_dB' ...
    } ...
);

end


function f_alias = local_signed_alias(f_Hz, fs_Hz)

f_alias = mod(f_Hz + fs_Hz/2, fs_Hz) - fs_Hz/2;

end
