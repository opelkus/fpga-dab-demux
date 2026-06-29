function stage = make_adc_oversampling_stage(adc)
%MAKE_ADC_OVERSAMPLING_STAGE Generic ADC moving-average oversampling stage.
%
% Model:
%   moving average / moving sum FIR before decimation
%
% Normalized response is used for frequency plots:
%   h = ones(M,1)/M
%
% Actual ADC-code gain with right_shift is still stored separately.

M = adc.oversampling.ratio;
right_shift = adc.oversampling.right_shift;

stage.name = sprintf("ADC oversampling x%d", M);
stage.type = "fir_decimator";

stage.M = M;
stage.decimation = M;

stage.fs_in_Hz = adc.raw_sample_rate_Hz;
stage.fs_out_Hz = adc.raw_sample_rate_Hz / M;

stage.right_shift = right_shift;

% Actual hardware gain in ADC codes:
stage.h_actual = ones(M, 1) / 2^right_shift;

% Normalized frequency response:
stage.h_norm = ones(M, 1) / M;

stage.dc_gain_actual = M / 2^right_shift;
stage.dc_gain_actual_dB = 20*log10(stage.dc_gain_actual);

stage.group_delay_input_samples = (M - 1) / 2;
stage.group_delay_seconds = stage.group_delay_input_samples / stage.fs_in_Hz;
stage.group_delay_output_samples = stage.group_delay_seconds * stage.fs_out_Hz;

stage.first_zero_Hz = stage.fs_out_Hz;
stage.output_nyquist_Hz = stage.fs_out_Hz / 2;

% Complex response evaluated at analog/input frequency f_Hz.
% This is periodic with fs_raw.
stage.response = @(f_Hz) adc_oversampling_response(f_Hz, stage.fs_in_Hz, stage.h_norm);

end


function H = adc_oversampling_response(f_Hz, fs_raw_Hz, h)

f_Hz = f_Hz(:);
n = 0:(numel(h)-1);

H = exp(-1j * 2*pi * (f_Hz/fs_raw_Hz) * n) * h;

end