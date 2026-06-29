function plot_stage_response(stage, N)
%PLOT_STAGE_RESPONSE Plot amplitude and phase response of DSP stage.

if nargin < 2 || isempty(N)
    N = 16384;
end

resp = stage_freq_response(stage, N, false);

figure;

tiledlayout(2, 1);

nexttile;
plot(resp.frequency_Hz / 1e3, resp.magnitude_dB, "LineWidth", 1.2);
grid on;
xlabel("Frequency [kHz]");
ylabel("Magnitude [dB]");
title(stage.name + " - amplitude response");
ylim([-100 2]);

xline(stage.output_nyquist_Hz / 1e3, "--", "output Nyquist");
xline(stage.first_zero_Hz / 1e3, "--", "first zero");

nexttile;
plot(resp.frequency_Hz / 1e3, resp.phase_deg, "LineWidth", 1.2);
grid on;
xlabel("Frequency [kHz]");
ylabel("Phase [deg]");
title(stage.name + " - phase response");

xline(stage.output_nyquist_Hz / 1e3, "--", "output Nyquist");
xline(stage.first_zero_Hz / 1e3, "--", "first zero");

fprintf("\n%s\n", stage.name);
fprintf("  fs_in:                  %.3f kS/s\n", stage.fs_in_Hz / 1e3);
fprintf("  fs_out:                 %.3f kS/s\n", stage.fs_out_Hz / 1e3);
fprintf("  output Nyquist:         %.3f kHz\n", stage.output_nyquist_Hz / 1e3);
fprintf("  first zero:             %.3f kHz\n", stage.first_zero_Hz / 1e3);
fprintf("  actual DC gain:         %.3f / %.3f dB\n", ...
    stage.dc_gain_actual, stage.dc_gain_actual_dB);
fprintf("  group delay:            %.3f input samples\n", ...
    stage.group_delay_input_samples);
fprintf("  group delay:            %.3f us\n", ...
    stage.group_delay_seconds * 1e6);
fprintf("  group delay:            %.3f output samples\n", ...
    stage.group_delay_output_samples);

end