function resp = stage_freq_response(stage, N, use_actual_gain)
%STAGE_FREQ_RESPONSE Frequency response of DSP stage.
%
% resp = stage_freq_response(stage)
% resp = stage_freq_response(stage, N)
% resp = stage_freq_response(stage, N, use_actual_gain)
%
% use_actual_gain = false -> normalized response, 0 dB at DC
% use_actual_gain = true  -> actual ADC-code gain

if nargin < 2 || isempty(N)
    N = 16384;
end

if nargin < 3
    use_actual_gain = false;
end

if use_actual_gain
    h = stage.h_actual;
else
    h = stage.h_norm;
end

fs = stage.fs_in_Hz;

f = linspace(0, fs/2, N).';
n = 0:(numel(h)-1);

H = exp(-1j * 2*pi * (f/fs) * n) * h;

resp.frequency_Hz = f;
resp.H = H;
resp.magnitude = abs(H);
resp.magnitude_dB = 20 * log10(abs(H) + eps);
resp.phase_rad = unwrap(angle(H));
resp.phase_deg = rad2deg(resp.phase_rad);

resp.fs_in_Hz = stage.fs_in_Hz;
resp.fs_out_Hz = stage.fs_out_Hz;
resp.group_delay_input_samples = stage.group_delay_input_samples;
resp.group_delay_seconds = stage.group_delay_seconds;
resp.group_delay_output_samples = stage.group_delay_output_samples;

end