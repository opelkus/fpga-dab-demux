function stage = make_analog_lpf_stage(fc_Hz, order, model)
%MAKE_ANALOG_LPF_STAGE Analog low-pass filter stage.
%
% Supported models:
%   "butterworth" / "butter"
%   "bessel"
%   "chebyshev1" / "cheby1"
%   "chebyshev2" / "cheby2"
%   "elliptic" / "ellip"
%
% Example:
%   analog = make_analog_lpf_stage(900e3, 3, "butterworth");
%   analog = make_analog_lpf_stage(900e3, 3, "bessel");
%   analog = make_analog_lpf_stage(900e3, 3, "chebyshev1");

if nargin < 3
    model = "butterworth";
end

model = lower(string(model));

stage.name = sprintf("Analog LPF %s, order %d, fc %.1f kHz", ...
    model, order, fc_Hz/1e3);

stage.type = "analog_filter";

stage.fc_Hz = fc_Hz;
stage.order = order;
stage.model = model;

% Analog stage does not define sample rate.
stage.fs_in_Hz = NaN;
stage.fs_out_Hz = NaN;

% Design analog transfer function H(s) = B(s)/A(s)
[b, a] = design_analog_lpf(fc_Hz, order, model);

stage.b = b;
stage.a = a;

% Complex frequency response H(jw)
stage.response = @(f_Hz) analog_lpf_response(f_Hz, b, a);

end


%% ============================================================
%  LOCAL FUNCTIONS
%% ============================================================

function [b, a] = design_analog_lpf(fc_Hz, order, model)

wc = 2*pi*fc_Hz;

% Parameters for filters that need ripple/attenuation.
% Możesz je później zmienić, jeżeli chcesz ostrzejszy filtr.
Rp_dB = 0.5;    % passband ripple for Chebyshev I / elliptic
Rs_dB = 60;     % stopband attenuation for Chebyshev II / elliptic

switch model

    case {"butterworth", "butter"}
        % Butterworth:
        % - płaska amplituda w paśmie
        % - faza nieliniowa
        % - dla fc jest około -3 dB
        [b, a] = butter(order, wc, "s");

    case "bessel"
        % Bessel:
        % - najlepsze zachowanie fazowe / opóźnienia grupowego
        % - łagodniejsze zbocze amplitudowe
        % - dobry wybór, jeśli zależy Ci na fazie
        [b, a] = besself(order, wc);

        % Normalizacja DC do 1
        H0 = polyval(b, 0) / polyval(a, 0);
        b = b / H0;

    case {"chebyshev1", "cheby1"}
        % Chebyshev I:
        % - szybsze zbocze niż Butterworth
        % - ripple w paśmie przepustowym
        % - gorsza faza
        [b, a] = cheby1(order, Rp_dB, wc, "s");

    case {"chebyshev2", "cheby2"}
        % Chebyshev II:
        % - płaskie pasmo przepustowe
        % - ripple w paśmie zaporowym
        % - wc jest częstotliwością zaporową, nie klasycznym -3 dB cutoff
        [b, a] = cheby2(order, Rs_dB, wc, "s");

    case {"elliptic", "ellip"}
        % Elliptic / Cauer:
        % - najostrzejsze zbocze dla danego rzędu
        % - ripple w paśmie przepustowym i zaporowym
        % - zwykle najgorsza faza
        [b, a] = ellip(order, Rp_dB, Rs_dB, wc, "s");

    otherwise
        error("Unsupported analog filter model: %s", model);

end

b = b(:).';
a = a(:).';

end


function H = analog_lpf_response(f_Hz, b, a)

f_Hz = f_Hz(:);
w = 2*pi*f_Hz;

% freqs() liczy odpowiedź analogowego filtru H(jw)
H = freqs(b, a, w);

end