function T = stage_alias_table(stage, f_in_Hz)
%STAGE_ALIAS_TABLE Analyze aliasing after decimation stage.
%
% Input:
%   f_in_Hz - vector of input frequencies before decimation
%
% Output table columns:
%   InputFrequency_Hz
%   AliasFrequency_Hz
%   AliasZone
%   Magnitude
%   Magnitude_dB
%   Phase_deg

f_in_Hz = f_in_Hz(:);

fs_in = stage.fs_in_Hz;
fs_out = stage.fs_out_Hz;

% Alias frequency after decimation, signed range:
%   -fs_out/2 ... +fs_out/2
f_alias_Hz = mod(f_in_Hz + fs_out/2, fs_out) - fs_out/2;

% Alias zone number
alias_zone = round((f_in_Hz - f_alias_Hz) / fs_out);

% Frequency response at original input frequencies.
H = response_at_frequencies(stage, f_in_Hz, false);

mag = abs(H);
mag_dB = 20 * log10(mag + eps);
phase_deg = rad2deg(angle(H));

T = table( ...
    f_in_Hz, ...
    f_alias_Hz, ...
    alias_zone, ...
    mag, ...
    mag_dB, ...
    phase_deg, ...
    'VariableNames', { ...
        'InputFrequency_Hz', ...
        'AliasFrequency_Hz', ...
        'AliasZone', ...
        'Magnitude', ...
        'Magnitude_dB', ...
        'Phase_deg' ...
    } ...
);

end


function H = response_at_frequencies(stage, f_Hz, use_actual_gain)

if use_actual_gain
    h = stage.h_actual;
else
    h = stage.h_norm;
end

fs = stage.fs_in_Hz;
n = 0:(numel(h)-1);

f_Hz = f_Hz(:);

H = exp(-1j * 2*pi * (f_Hz/fs) * n) * h;

end