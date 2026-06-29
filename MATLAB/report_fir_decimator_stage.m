function report = report_fir_decimator_stage(stage, N)
%REPORT_FIR_DECIMATOR_STAGE Measure actual FIR stage ripple/attenuation.
%
% Example:
%   report = report_fir_decimator_stage(fir3);

if nargin < 2 || isempty(N)
    N = 200000;
end

f = linspace(0, stage.fs_in_Hz/2, N).';
H = stage.response(f);

mag = abs(H);
mag_dB = 20*log10(mag + eps);

passbands = stage.design.passbands;
stopband = stage.design.stopband;

fprintf("\nFIR decimator report: %s\n", stage.name);
fprintf("  fs_in:       %.3f kS/s\n", stage.fs_in_Hz / 1e3);
fprintf("  fs_out:      %.3f kS/s\n", stage.fs_out_Hz / 1e3);
fprintf("  decimation:  x%d\n", stage.decimation);
fprintf("  taps:        %d\n", stage.num_taps);
fprintf("  cutoff:      %.3f kHz\n", stage.cutoff_Hz / 1e3);
fprintf("  stopband:    %.3f kHz ... %.3f kHz\n", ...
    stopband(1)/1e3, stopband(2)/1e3);
fprintf("  peak gain:   %.3f dB\n", stage.peak_gain_dB);
fprintf("  group delay: %.3f samples input / %.3f us\n", ...
    stage.group_delay_input_samples, ...
    stage.group_delay_seconds * 1e6);

if isfield(stage, "design") && isfield(stage.design, "linear_phase")
    fprintf("  linear phase: %d (%s)\n", ...
        stage.design.linear_phase, stage.design.linear_phase_type);
    fprintf("  symmetry err: %.3e\n", stage.design.symmetry_error);
end

report = struct();
report.passbands = [];

for k = 1:size(passbands, 1)
    f1 = passbands(k, 1);
    f2 = passbands(k, 2);
    target_gain = passbands(k, 3);
    target_dB = 20*log10(target_gain);

    mask = f >= f1 & f <= f2;

    err_dB = mag_dB(mask) - target_dB;

    pb.min_error_dB = min(err_dB);
    pb.max_error_dB = max(err_dB);
    pb.ripple_pp_dB = max(err_dB) - min(err_dB);
    pb.max_abs_error_dB = max(abs(err_dB));

    report.passbands = [report.passbands; pb];

    fprintf("\n  Passband %d: %.3f...%.3f kHz, target %.3f dB\n", ...
        k, f1/1e3, f2/1e3, target_dB);
    fprintf("    ripple p-p:       %.4f dB\n", pb.ripple_pp_dB);
    fprintf("    max abs error:    %.4f dB\n", pb.max_abs_error_dB);
    fprintf("    min/max error:    %.4f / %.4f dB\n", ...
        pb.min_error_dB, pb.max_error_dB);
end

stop_mask = f >= stopband(1) & f <= stopband(2);
stop_max_dB = max(mag_dB(stop_mask));

report.stopband_max_dB = stop_max_dB;
report.stopband_attenuation_dB = -stop_max_dB;

fprintf("\n  Stopband:\n");
fprintf("    max level:        %.3f dB\n", stop_max_dB);
fprintf("    attenuation:      %.3f dB\n", -stop_max_dB);

end