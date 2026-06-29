function out = analog_alias_debug(chain, context, varargin)
%ANALOG_ALIAS_DEBUG Plot analog frontend response and ADC aliasing regions.
%
% Pokazuje:
%   - charakterystykę analogowego toru przed ADC,
%   - częstotliwości wejściowe, które po próbkowaniu ADC aliasują się
%     do badanego pasma, np. 0...BW_DAB.
%
% To jest potrzebne osobno, bo analogowy filtr działa przed próbkowaniem
% i ma sens analizować go powyżej Nyquista ADC, np. do 30 MHz.

p = inputParser;
addParameter(p, "FMax_Hz", 30e6);
addParameter(p, "N", 200000);
addParameter(p, "Fs_ADC_Hz", []);
addParameter(p, "AliasBand_Hz", [0 768e3]);
addParameter(p, "DesiredBand_Hz", [0 768e3]);
addParameter(p, "YLim_dB", [-140 5]);
parse(p, varargin{:});
cfg = p.Results;

if isempty(cfg.Fs_ADC_Hz)
    cfg.Fs_ADC_Hz = local_find_adc_fs(chain);
end

fs_adc = cfg.Fs_ADC_Hz;

alias_low  = min(cfg.AliasBand_Hz);
alias_high = max(cfg.AliasBand_Hz);

desired_low  = min(cfg.DesiredBand_Hz);
desired_high = max(cfg.DesiredBand_Hz);

f = linspace(0, cfg.FMax_Hz, cfg.N).';

H_analog = ones(size(f));

analog_stage_names = strings(0, 1);

for k = 1:numel(chain)

    st = chain{k};

    is_analog = false;

    if isfield(st, "type")
        t = lower(string(st.type));
        if contains(t, "analog")
            is_analog = true;
        end
    end

    if isfield(st, "name")
        nm = lower(string(st.name));
        if contains(nm, "analog")
            is_analog = true;
        end
    end

    if is_analog && isfield(st, "response")
        H_analog = H_analog .* st.response(f);
        analog_stage_names(end + 1, 1) = string(st.name); %#ok<AGROW>
    end

end

mag_dB = 20 * log10(abs(H_analog) + eps);

f_alias_adc = local_signed_alias(f, fs_adc);

if alias_low >= 0
    in_alias_band = ...
        abs(f_alias_adc) >= alias_low & ...
        abs(f_alias_adc) <= alias_high;
else
    in_alias_band = ...
        f_alias_adc >= alias_low & ...
        f_alias_adc <= alias_high;
end

desired_mask = ...
    f >= desired_low & ...
    f <= desired_high;

alias_mask = in_alias_band & ~desired_mask & f > desired_high;

figure;
hold on;

plot(f/1e6, mag_dB, "LineWidth", 1.2);

if any(alias_mask)
    plot(f(alias_mask)/1e6, mag_dB(alias_mask), ".", "MarkerSize", 5);
end

xline(desired_high/1e6, "--", "BW_DAB");
xline(fs_adc/2/1e6, ":", "ADC Nyquist");

for m = 1:floor(cfg.FMax_Hz / fs_adc)
    xline(m * fs_adc / 1e6, ":", sprintf("%d*FsADC", m));
end

grid on;
ylim(cfg.YLim_dB);
xlabel("Analog input frequency [MHz]");
ylabel("|H analog| [dB]");
title("Analog frontend response and ADC aliasing to selected band");

if any(alias_mask)
    legend("analog response", "aliases to selected band", "Location", "southwest");
else
    legend("analog response", "Location", "southwest");
end

hold off;

if any(alias_mask)
    worst_alias_dB = max(mag_dB(alias_mask));
    integrated_alias_power_dB = 10 * log10(trapz(f, abs(H_analog).^2 .* double(alias_mask)) + realmin);
    alias_min_Hz = min(f(alias_mask));
    alias_max_Hz = max(f(alias_mask));
else
    worst_alias_dB = -Inf;
    integrated_alias_power_dB = -Inf;
    alias_min_Hz = NaN;
    alias_max_Hz = NaN;
end

fprintf("\nAnalog frontend alias debug\n");
fprintf("  Fs ADC:                 %.6f MHz\n", fs_adc/1e6);
fprintf("  ADC Nyquist:            %.6f MHz\n", fs_adc/2/1e6);
fprintf("  plot range:             0...%.6f MHz\n", cfg.FMax_Hz/1e6);
fprintf("  desired band:           %.6f...%.6f MHz\n", desired_low/1e6, desired_high/1e6);

if alias_low >= 0
    fprintf("  alias band abs:         %.6f...%.6f MHz\n", alias_low/1e6, alias_high/1e6);
else
    fprintf("  alias band signed:      %.6f...%.6f MHz\n", alias_low/1e6, alias_high/1e6);
end

if ~isempty(analog_stage_names)
    fprintf("  analog stages:\n");
    for i = 1:numel(analog_stage_names)
        fprintf("    - %s\n", analog_stage_names(i));
    end
else
    fprintf("  analog stages:          none detected\n");
end

if any(alias_mask)
    fprintf("  alias input region:     %.6f...%.6f MHz\n", alias_min_Hz/1e6, alias_max_Hz/1e6);
    fprintf("  worst analog attenuation in alias region: %.3f dB\n", worst_alias_dB);
else
    fprintf("  no out-of-band points alias into selected band in plotted range\n");
end

out = struct();

out.Fs_ADC_Hz = fs_adc;
out.FMax_Hz = cfg.FMax_Hz;
out.AliasBand_Hz = cfg.AliasBand_Hz;
out.DesiredBand_Hz = cfg.DesiredBand_Hz;
out.AliasInputMin_Hz = alias_min_Hz;
out.AliasInputMax_Hz = alias_max_Hz;
out.WorstAliasAttenuation_dB = worst_alias_dB;
out.IntegratedAliasPower_dB = integrated_alias_power_dB;

out.table = table( ...
    f, ...
    f_alias_adc, ...
    mag_dB, ...
    desired_mask, ...
    alias_mask, ...
    'VariableNames', { ...
        'AnalogInputFrequency_Hz', ...
        'AliasAfterADC_Hz', ...
        'AnalogMagnitude_dB', ...
        'DesiredMask', ...
        'AliasMask' ...
    } ...
);

end


function fs_adc = local_find_adc_fs(chain)

for k = 1:numel(chain)
    st = chain{k};

    if isfield(st, "type")
        if contains(lower(string(st.type)), "adc")
            if isfield(st, "fs_out_Hz") && ~isnan(st.fs_out_Hz)
                fs_adc = st.fs_out_Hz;
                return;
            end
        end
    end

    if isfield(st, "name")
        if contains(lower(string(st.name)), "adc")
            if isfield(st, "fs_out_Hz") && ~isnan(st.fs_out_Hz)
                fs_adc = st.fs_out_Hz;
                return;
            end
        end
    end
end

error("Could not find ADC sampling frequency in chain.");

end


function f_alias = local_signed_alias(f_Hz, fs_Hz)

f_alias = mod(f_Hz + fs_Hz/2, fs_Hz) - fs_Hz/2;

end