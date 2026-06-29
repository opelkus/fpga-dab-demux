function plot_alias_map(stage, f_max_Hz, N, alias_band_Hz)
%PLOT_ALIAS_MAP Plot alias mapping after decimation.
%
% Example:
%   plot_alias_map(os, 500e3);
%   plot_alias_map(os, 500e3, 50000, [-10e3 10e3]);
%
% alias_band_Hz:
%   [f_low f_high] after decimation, for example [-10e3 10e3].
%
% The function highlights input frequencies that alias into the selected
% output band.

if nargin < 2 || isempty(f_max_Hz)
    f_max_Hz = stage.fs_in_Hz / 2;
end

if nargin < 3 || isempty(N)
    N = 20000;
end

if nargin < 4
    alias_band_Hz = [];
end

f_in = linspace(0, f_max_Hz, N).';
T = stage_alias_table(stage, f_in);

has_alias_band = ~isempty(alias_band_Hz);

if has_alias_band
    alias_low_Hz  = min(alias_band_Hz);
    alias_high_Hz = max(alias_band_Hz);

    in_alias_band = ...
        T.AliasFrequency_Hz >= alias_low_Hz & ...
        T.AliasFrequency_Hz <= alias_high_Hz;
else
    in_alias_band = false(size(f_in));
end

figure;

tiledlayout(2, 1);

%% ------------------------------------------------------------------------
% Alias frequency map
% -------------------------------------------------------------------------

nexttile;
hold on;

plot(T.InputFrequency_Hz / 1e3, ...
     T.AliasFrequency_Hz / 1e3, ...
     "LineWidth", 1.0);

if has_alias_band
    % Horizontal band: selected aliased output frequency range
    x_patch = [0 f_max_Hz f_max_Hz 0] / 1e3;
    y_patch = [alias_low_Hz alias_low_Hz alias_high_Hz alias_high_Hz] / 1e3;

    patch(x_patch, y_patch, 1, ...
        "FaceAlpha", 0.12, ...
        "EdgeColor", "none");

    % Points that alias into selected band
    plot(T.InputFrequency_Hz(in_alias_band) / 1e3, ...
         T.AliasFrequency_Hz(in_alias_band) / 1e3, ...
         ".", ...
         "MarkerSize", 7);
end

grid on;
xlabel("Input frequency before decimation [kHz]");
ylabel("Aliased frequency after decimation [kHz]");
title(stage.name + " - alias frequency map");

yline(stage.output_nyquist_Hz / 1e3, "--", "+output Nyquist");
yline(-stage.output_nyquist_Hz / 1e3, "--", "-output Nyquist");

if has_alias_band
    yline(alias_low_Hz / 1e3, "--", "alias band low");
    yline(alias_high_Hz / 1e3, "--", "alias band high");
end

hold off;

%% ------------------------------------------------------------------------
% Attenuation before aliasing
% -------------------------------------------------------------------------

nexttile;
hold on;

plot(T.InputFrequency_Hz / 1e3, ...
     T.Magnitude_dB, ...
     "LineWidth", 1.0);

if has_alias_band
    % Highlight the attenuation of all input frequencies that fall
    % into selected aliased band after decimation.
    plot(T.InputFrequency_Hz(in_alias_band) / 1e3, ...
         T.Magnitude_dB(in_alias_band), ...
         ".", ...
         "MarkerSize", 7);
end

grid on;
xlabel("Input frequency before decimation [kHz]");
ylabel("Oversampling attenuation [dB]");
title(stage.name + " - attenuation before aliasing");
ylim([-100 2]);

xline(stage.output_nyquist_Hz / 1e3, "--", "output Nyquist");
xline(stage.first_zero_Hz / 1e3, "--", "first zero");

hold off;

%% ------------------------------------------------------------------------
% Text summary
% -------------------------------------------------------------------------

fprintf("\nAlias map summary\n");
fprintf("  fs_in:          %.3f kS/s\n", stage.fs_in_Hz / 1e3);
fprintf("  fs_out:         %.3f kS/s\n", stage.fs_out_Hz / 1e3);
fprintf("  output Nyquist: %.3f kHz\n", stage.output_nyquist_Hz / 1e3);

if has_alias_band
    fprintf("\nSelected aliased output band:\n");
    fprintf("  %.3f kHz ... %.3f kHz\n", ...
        alias_low_Hz / 1e3, alias_high_Hz / 1e3);

    if any(in_alias_band)
        selected_att_dB = T.Magnitude_dB(in_alias_band);
        selected_f_in_Hz = T.InputFrequency_Hz(in_alias_band);

        fprintf("\nInput frequencies aliasing into selected band:\n");
        fprintf("  input range:      %.3f kHz ... %.3f kHz\n", ...
            min(selected_f_in_Hz) / 1e3, ...
            max(selected_f_in_Hz) / 1e3);

        fprintf("  best attenuation: %.3f dB\n", min(selected_att_dB));
        fprintf("  worst attenuation %.3f dB\n", max(selected_att_dB));

        % Find worst-case leak, meaning the largest magnitude / least negative dB.
        [worst_att_dB, idx_local] = max(selected_att_dB);
        selected_idx = find(in_alias_band);
        idx = selected_idx(idx_local);

        fprintf("\nWorst-case alias leak into selected band:\n");
        fprintf("  input frequency:  %.3f kHz\n", ...
            T.InputFrequency_Hz(idx) / 1e3);
        fprintf("  aliased to:       %.3f kHz\n", ...
            T.AliasFrequency_Hz(idx) / 1e3);
        fprintf("  attenuation:      %.3f dB\n", worst_att_dB);
    else
        fprintf("\nNo sampled input frequencies landed in selected alias band.\n");
        fprintf("Increase N if this is unexpected.\n");
    end
end

end