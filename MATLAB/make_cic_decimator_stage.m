function stage = make_cic_decimator_stage(fs_in_Hz, R, N)
%MAKE_CIC_DECIMATOR_STAGE CIC decimator stage for DSP chain analysis.
%
% This models a classic CIC decimator:
%
%   N integrators -> decimate by R -> N combs
%
% For frequency-response analysis it uses the equivalent FIR response:
%
%   H(z) = [1/R * (1 - z^-R)/(1 - z^-1)]^N
%
% Example:
%   cic = make_cic_decimator_stage(425e3, 4, 4);

stage.name = sprintf("CIC%d decimator R=%d", N, R);
stage.type = "cic_decimator";

stage.fs_in_Hz = fs_in_Hz;
stage.R = R;
stage.N = N;
stage.decimation = R;
stage.fs_out_Hz = fs_in_Hz / R;

% One moving-average section, normalized to 0 dB at DC.
h = ones(R, 1) / R;

% Equivalent FIR response of CIC.
h_total = 1;
for k = 1:N
    h_total = conv(h_total, h);
end

stage.h_norm = h_total(:);
stage.h_actual = stage.h_norm;

stage.gain_unscaled = R^N;
stage.gain_unscaled_bits = log2(stage.gain_unscaled);

stage.group_delay_input_samples = (numel(stage.h_norm) - 1) / 2;
stage.group_delay_seconds = stage.group_delay_input_samples / fs_in_Hz;
stage.group_delay_output_samples = ...
    stage.group_delay_seconds * stage.fs_out_Hz;

stage.output_nyquist_Hz = stage.fs_out_Hz / 2;
stage.first_zero_Hz = stage.fs_out_Hz;

stage.response = @(f_Hz) fir_response(f_Hz, fs_in_Hz, stage.h_norm);

end


function H = fir_response(f_Hz, fs_Hz, h)

f_Hz = f_Hz(:);
n = 0:(numel(h)-1);

H = exp(-1j * 2*pi * (f_Hz/fs_Hz) * n) * h;

end