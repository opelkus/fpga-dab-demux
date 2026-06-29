function out = check_analog_group_delay(varargin)
%CHECK_ANALOG_GROUP_DELAY Plot and print analog LPF group delay.
%
% Supports:
%   "butterworth" / "butter"
%   "bessel"
%   "chebyshev1" / "cheby1"
%   "chebyshev2" / "cheby2"
%   "elliptic" / "ellip"

p = inputParser;
addParameter(p, "Cutoff_Hz", 900e3);
addParameter(p, "Order", 3);
addParameter(p, "Model", "butterworth");
addParameter(p, "Passband_Hz", [0 768e3]);
addParameter(p, "FMax_Hz", 3e6);
addParameter(p, "N", 50000);
addParameter(p, "MakePlots", true);

% Parametry dla filtrów Chebyshev / elliptic
addParameter(p, "PassbandRipple_dB", 0.5);
addParameter(p, "StopbandAttenuation_dB", 60);

parse(p, varargin{:});
cfg = p.Results;

fc_Hz = cfg.Cutoff_Hz;
order = cfg.Order;
model = lower(string(cfg.Model));
passband_Hz = cfg.Passband_Hz;
FMax_Hz = cfg.FMax_Hz;
N = cfg.N;

Rp_dB = cfg.PassbandRipple_dB;
Rs_dB = cfg.StopbandAttenuation_dB;

if numel(passband_Hz) ~= 2 || passband_Hz(2) <= passband_Hz(1)
    error("Passband_Hz must be [f_min f_max].");
end

if FMax_Hz <= passband_Hz(2)
    FMax_Hz = 1.2 * passband_Hz(2);
end

if order < 1
    error("Order must be >= 1.");
end

% Start lekko powyżej DC
f_Hz = linspace(1, FMax_Hz, N).';
w = 2*pi*f_Hz;

wc = 2*pi*fc_Hz;

%% ============================================================
%  PROJEKT ANALOGOWEGO FILTRU
%% ============================================================

switch model

    case {"butterworth", "butter"}
        [b, a] = butter(order, wc, "s");

    case "bessel"
        [b, a] = besself(order, wc);

        % Normalizacja DC do 1
        H0 = polyval(b, 0) / polyval(a, 0);
        b = b / H0;

    case {"chebyshev1", "cheby1"}
        [b, a] = cheby1(order, Rp_dB, wc, "s");

    case {"chebyshev2", "cheby2"}
        [b, a] = cheby2(order, Rs_dB, wc, "s");

    case {"elliptic", "ellip"}
        [b, a] = ellip(order, Rp_dB, Rs_dB, wc, "s");

    otherwise
        error("Unsupported analog filter model: %s", model);

end

%% ============================================================
%  ODPOWIEDŹ CZĘSTOTLIWOŚCIOWA
%% ============================================================

H = freqs(b, a, w);

mag_dB = 20*log10(abs(H) + eps);
phase_rad = unwrap(angle(H));
phase_deg = phase_rad * 180/pi;

% Opóźnienie grupowe:
% tau_g(f) = -1/(2*pi) * d(phi)/df
f_gd_Hz = 0.5 * (f_Hz(1:end-1) + f_Hz(2:end));
tau_g_s = -diff(phase_rad) ./ (2*pi*diff(f_Hz));

idx = (f_gd_Hz >= passband_Hz(1)) & (f_gd_Hz <= passband_Hz(2));
if ~any(idx)
    error("No group-delay points inside selected Passband_Hz.");
end

tau_min_s = min(tau_g_s(idx));
tau_max_s = max(tau_g_s(idx));
tau_pp_s = tau_max_s - tau_min_s;
tau_mean_s = mean(tau_g_s(idx));

%% ============================================================
%  WYNIKI W KONSOLI
%% ============================================================

fprintf("\n============================================================\n");
fprintf("ANALOG LPF GROUP DELAY CHECK\n");
fprintf("============================================================\n");
fprintf("  Model:             %s\n", model);
fprintf("  Order:             %d\n", order);
fprintf("  Cutoff:            %.3f kHz\n", fc_Hz/1e3);
fprintf("  Checked passband:  %.3f ... %.3f kHz\n", passband_Hz(1)/1e3, passband_Hz(2)/1e3);
fprintf("  Mean delay:        %.6f us\n", tau_mean_s*1e6);
fprintf("  Min delay:         %.6f us\n", tau_min_s*1e6);
fprintf("  Max delay:         %.6f us\n", tau_max_s*1e6);
fprintf("  Delay p-p:         %.6f us\n", tau_pp_s*1e6);

if tau_pp_s < 1e-6
    fprintf("  Assessment:        very good for DAB+\n");
elseif tau_pp_s < 5e-6
    fprintf("  Assessment:        OK for DAB+\n");
elseif tau_pp_s < 10e-6
    fprintf("  Assessment:        probably usable, but reduced margin\n");
else
    fprintf("  Assessment:        risky; consider wider analog LPF, Bessel filter, or phase compensation\n");
end

fprintf("============================================================\n");

%% ============================================================
%  WYKRESY
%% ============================================================

if cfg.MakePlots

    figure;
    plot(f_Hz/1e3, mag_dB);
    grid on;
    xlabel("Frequency [kHz]");
    ylabel("Magnitude [dB]");
    title(sprintf("Analog LPF magnitude response - %s order %d", model, order));
    xline(passband_Hz(2)/1e3, "--", "DAB band edge");

    figure;
    plot(f_Hz/1e3, phase_deg);
    grid on;
    xlabel("Frequency [kHz]");
    ylabel("Phase [deg]");
    title(sprintf("Analog LPF unwrapped phase - %s order %d", model, order));
    xline(passband_Hz(2)/1e3, "--", "DAB band edge");

    figure;
    plot(f_gd_Hz/1e3, tau_g_s*1e6);
    grid on;
    xlabel("Frequency [kHz]");
    ylabel("Group delay [us]");
    title(sprintf("Analog LPF group delay - %s order %d", model, order));
    xline(passband_Hz(2)/1e3, "--", "DAB band edge");

    figure;
    plot(f_gd_Hz(idx)/1e3, tau_g_s(idx)*1e6);
    grid on;
    xlabel("Frequency [kHz]");
    ylabel("Group delay [us]");
    title(sprintf("Analog LPF group delay in DAB band - %s order %d", model, order));

end

%% ============================================================
%  OUTPUT STRUCT
%% ============================================================

out = struct();

out.model = model;
out.order = order;
out.cutoff_Hz = fc_Hz;

out.b = b;
out.a = a;

out.f_Hz = f_Hz;
out.H = H;
out.magnitude_dB = mag_dB;
out.phase_rad = phase_rad;
out.phase_deg = phase_deg;

out.f_gd_Hz = f_gd_Hz;
out.tau_g_s = tau_g_s;

out.passband_Hz = passband_Hz;
out.tau_min_s = tau_min_s;
out.tau_max_s = tau_max_s;
out.tau_pp_s = tau_pp_s;
out.tau_mean_s = tau_mean_s;

end