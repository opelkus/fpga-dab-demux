function plot_fir_decimator_stage(stage, f_max_Hz, N)
%PLOT_FIR_DECIMATOR_STAGE Plot amplitude and phase of FIR decimator.
%
% Example:
%   plot_fir_decimator_stage(fir3);

if nargin < 2 || isempty(f_max_Hz)
    f_max_Hz = stage.fs_in_Hz / 2;
end

if nargin < 3 || isempty(N)
    N = 100000;
end

f = linspace(0, f_max_Hz, N).';
H = stage.response(f);

mag_dB = 20*log10(abs(H) + eps);
phase_deg = rad2deg(unwrap(angle(H)));

figure;
tiledlayout(2, 1);

nexttile;
plot(f/1e3, mag_dB, "LineWidth", 1.1);
grid on;
xlabel("Frequency [kHz]");
ylabel("Magnitude [dB]");
title(stage.name + " - amplitude response");
ylim([-140 8]);

xline(stage.cutoff_Hz/1e3, "--", "cutoff");
xline(stage.stopband_start_Hz/1e3, "--", "stopband start");
xline(stage.fs_out_Hz/2/1e3, "--", "output Nyquist");

nexttile;
plot(f/1e3, phase_deg, "LineWidth", 1.1);
grid on;
xlabel("Frequency [kHz]");
ylabel("Phase [deg]");
title(stage.name + " - phase response");

end