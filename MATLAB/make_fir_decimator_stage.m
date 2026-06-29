function stage = make_fir_decimator_stage(fs_in_Hz, varargin)
%MAKE_FIR_DECIMATOR_STAGE FIR decimator stage for chain analysis.
%
% Features:
%   - arbitrary decimation factor
%   - low-pass FIR
%   - optional +dB boost in upper passband
%   - configurable tap count, ripple, stopband attenuation
%   - compatible with chain_response() and plot_chain_alias_map()
%   - optional forced Type-I linear phase by symmetric coefficients
%
% Example:
%   fir3 = make_fir_decimator_stage(425e3, ...
%       "Decimation", 3, ...
%       "NumTaps", 95, ...
%       "Cutoff_Hz", 10e3, ...
%       "BoostStart_Hz", 5e3, ...
%       "BoostGain_dB", 3, ...
%       "PassbandRipple_dB", 0.1, ...
%       "StopbandAttenuation_dB", 80);

p = inputParser;

addParameter(p, "Name", "FIR decimator");

addParameter(p, "Decimation", 3);
addParameter(p, "NumTaps", 95);

addParameter(p, "Cutoff_Hz", 10e3);

% Stopband can be specified directly or by transition width.
addParameter(p, "StopbandStart_Hz", []);
addParameter(p, "TransitionWidth_Hz", []);

% Passband boost
addParameter(p, "BoostEnabled", true);
addParameter(p, "BoostStart_Hz", 5e3);
addParameter(p, "BoostGain_dB", 3);
addParameter(p, "BoostTransitionWidth_Hz", 1e3);

% Design weights/specs
addParameter(p, "PassbandRipple_dB", 0.1);
addParameter(p, "StopbandAttenuation_dB", 80);

% "firls" is robust for shaped passbands.
% "firpm" gives equiripple-like behavior.
addParameter(p, "Method", "firls");

% Force exact linear phase by making coefficients symmetric after design.
% For low-pass decimators this gives a Type-I FIR when NumTaps is odd.
addParameter(p, "LinearPhase", true);

parse(p, varargin{:});
cfg = p.Results;

R = cfg.Decimation;
num_taps = cfg.NumTaps;
cutoff_Hz = cfg.Cutoff_Hz;

fs_out_Hz = fs_in_Hz / R;
nyq_in_Hz = fs_in_Hz / 2;
nyq_out_Hz = fs_out_Hz / 2;

%% ------------------------------------------------------------------------
% Validation
% -------------------------------------------------------------------------

if R < 1 || round(R) ~= R
    error("Decimation must be a positive integer.");
end

if cutoff_Hz >= nyq_out_Hz
    error([ ...
        "Cutoff %.3f kHz is impossible for decimation x%d. " + ...
        "Output Nyquist is only %.3f kHz. " + ...
        "Use lower cutoff, lower decimation, or higher fs_in."], ...
        cutoff_Hz/1e3, R, nyq_out_Hz/1e3);
end

% For alias protection into 0...cutoff, stopband should start no later than:
% fs_out - cutoff.
max_stop_start_Hz = fs_out_Hz - cutoff_Hz;

if isempty(cfg.StopbandStart_Hz)
    if isempty(cfg.TransitionWidth_Hz)
        max_transition_Hz = max_stop_start_Hz - cutoff_Hz;

        if max_transition_Hz <= 0
            error([ ...
                "No transition band is possible. " + ...
                "Need fs_out > 2*cutoff. Current fs_out %.3f kHz, cutoff %.3f kHz."], ...
                fs_out_Hz/1e3, cutoff_Hz/1e3);
        end

        transition_Hz = min(5e3, 0.5 * max_transition_Hz);
    else
        transition_Hz = cfg.TransitionWidth_Hz;
    end

    stopband_start_Hz = cutoff_Hz + transition_Hz;
else
    stopband_start_Hz = cfg.StopbandStart_Hz;
    transition_Hz = stopband_start_Hz - cutoff_Hz;
end

if stopband_start_Hz <= cutoff_Hz
    error("StopbandStart_Hz must be higher than Cutoff_Hz.");
end

if stopband_start_Hz > max_stop_start_Hz
    error([ ...
        "Stopband starts too late for alias protection. " + ...
        "For decimation x%d and cutoff %.3f kHz, stopband should start <= %.3f kHz. " + ...
        "Current stopband start is %.3f kHz."], ...
        R, cutoff_Hz/1e3, max_stop_start_Hz/1e3, stopband_start_Hz/1e3);
end

if stopband_start_Hz >= nyq_in_Hz
    error("StopbandStart_Hz must be below input Nyquist.");
end

% Prefer odd number of taps for Type-I linear phase FIR.
if mod(num_taps, 2) == 0
    num_taps = num_taps + 1;
    warning("NumTaps changed to %d to get odd tap count / Type-I linear phase.", num_taps);
end

order = num_taps - 1;

%% ------------------------------------------------------------------------
% Weight calculation from ripple specs
% -------------------------------------------------------------------------

rp_dB = cfg.PassbandRipple_dB;
as_dB = cfg.StopbandAttenuation_dB;

delta_p = (10^(rp_dB/20) - 1) / (10^(rp_dB/20) + 1);
delta_s = 10^(-as_dB/20);

delta_p = max(delta_p, 1e-6);
delta_s = max(delta_s, 1e-12);

w_pass = 1 / delta_p;
w_stop = 1 / delta_s;

%% ------------------------------------------------------------------------
% Build FIR bands
% -------------------------------------------------------------------------

boost_enabled = cfg.BoostEnabled && abs(cfg.BoostGain_dB) > 1e-9;
boost_gain = 10^(cfg.BoostGain_dB / 20);

freq_edges_Hz = [];
amp_edges = [];
weights = [];

passbands = [];

if boost_enabled
    boost_start_Hz = cfg.BoostStart_Hz;
    boost_transition_Hz = cfg.BoostTransitionWidth_Hz;

    low_end_Hz = boost_start_Hz - boost_transition_Hz/2;
    boost_begin_Hz = boost_start_Hz + boost_transition_Hz/2;

    if low_end_Hz <= 0
        error("BoostStart_Hz is too low for the selected BoostTransitionWidth_Hz.");
    end

    if boost_begin_Hz >= cutoff_Hz
        error("Boost band begins above or too close to Cutoff_Hz.");
    end

    % Band 1: flat lower passband, gain 1.
    freq_edges_Hz = [freq_edges_Hz, 0, low_end_Hz];
    amp_edges     = [amp_edges,     1, 1];
    weights       = [weights,       w_pass];

    passbands = [passbands; 0, low_end_Hz, 1];

    % Gap low_end...boost_begin is boost transition.

    % Band 2: boosted passband.
    freq_edges_Hz = [freq_edges_Hz, boost_begin_Hz, cutoff_Hz];
    amp_edges     = [amp_edges,     boost_gain, boost_gain];

    % Use relative ripple weighting for boosted band.
    weights       = [weights,       1 / (delta_p * boost_gain)];

    passbands = [passbands; boost_begin_Hz, cutoff_Hz, boost_gain];

else
    % Single flat passband.
    freq_edges_Hz = [freq_edges_Hz, 0, cutoff_Hz];
    amp_edges     = [amp_edges,     1, 1];
    weights       = [weights,       w_pass];

    passbands = [passbands; 0, cutoff_Hz, 1];
end

% Stopband.
freq_edges_Hz = [freq_edges_Hz, stopband_start_Hz, nyq_in_Hz];
amp_edges     = [amp_edges,     0, 0];
weights       = [weights,       w_stop];

% Normalize weights to avoid silly large numbers.
weights = weights / min(weights);

freq_edges_norm = freq_edges_Hz / nyq_in_Hz;

%% ------------------------------------------------------------------------
% FIR design
% -------------------------------------------------------------------------

method = string(cfg.Method);

switch method
    case "firls"
        if exist("firls", "file") ~= 2
            error("firls() not found. Signal Processing Toolbox is required.");
        end

        h = firls(order, freq_edges_norm, amp_edges, weights);

    case "firpm"
        if exist("firpm", "file") ~= 2
            error("firpm() not found. Signal Processing Toolbox is required.");
        end

        h = firpm(order, freq_edges_norm, amp_edges, weights);

    otherwise
        error("Unsupported FIR design method: %s", method);
end

h = h(:);

%% ------------------------------------------------------------------------
% Enforce linear phase
% -------------------------------------------------------------------------

linear_phase_enabled = logical(cfg.LinearPhase);

if linear_phase_enabled
    % A real FIR has exactly linear phase when its impulse response is
    % symmetric or antisymmetric. This decimator is a low-pass filter, so use
    % even symmetry h[n] = h[N-1-n]. With odd NumTaps this is Type-I FIR.
    h = 0.5 * (h + flipud(h));

    % Normalize DC gain after symmetrization. This preserves the intended
    % low-frequency gain and avoids tiny numerical drift.
    dc_gain = sum(h);
    if abs(dc_gain) > eps
        h = h / dc_gain;
    end
end

linear_phase_symmetry_error = max(abs(h - flipud(h)));

%% ------------------------------------------------------------------------
% Build stage struct
% -------------------------------------------------------------------------

stage.name = sprintf("%s x%d, %d taps", cfg.Name, R, num_taps);
stage.type = "fir_decimator";

stage.fs_in_Hz = fs_in_Hz;
stage.fs_out_Hz = fs_out_Hz;
stage.decimation = R;

stage.num_taps = num_taps;
stage.order = order;

stage.h_norm = h;
stage.h_actual = h;

stage.cutoff_Hz = cutoff_Hz;
stage.stopband_start_Hz = stopband_start_Hz;
stage.transition_width_Hz = transition_Hz;

stage.output_nyquist_Hz = nyq_out_Hz;

stage.group_delay_input_samples = (num_taps - 1) / 2;
stage.group_delay_seconds = stage.group_delay_input_samples / fs_in_Hz;
stage.group_delay_output_samples = stage.group_delay_seconds * fs_out_Hz;

stage.design.method = method;
stage.design.linear_phase = linear_phase_enabled;
stage.design.linear_phase_type = "Type-I even-symmetric";
stage.design.symmetry_error = linear_phase_symmetry_error;
stage.design.freq_edges_Hz = freq_edges_Hz;
stage.design.amp_edges = amp_edges;
stage.design.weights = weights;
stage.design.passbands = passbands;
stage.design.stopband = [stopband_start_Hz, nyq_in_Hz];

stage.design.passband_ripple_dB_requested = rp_dB;
stage.design.stopband_attenuation_dB_requested = as_dB;

stage.boost.enabled = boost_enabled;
stage.boost.start_Hz = cfg.BoostStart_Hz;
stage.boost.gain_dB = cfg.BoostGain_dB;
stage.boost.gain_linear = boost_gain;

% Q31 coefficients for later STM32 use.
q31 = round(h * double(2^31));
q31(q31 > double(intmax("int32"))) = double(intmax("int32"));
q31(q31 < double(intmin("int32"))) = double(intmin("int32"));

stage.q31.coeffs = int32(q31);
stage.q31.scale = "Q31";

% Estimate peak gain for headroom.
f_probe = linspace(0, nyq_in_Hz, 20000).';
H_probe = fir_response_horner(f_probe, fs_in_Hz, h);
stage.peak_gain = max(abs(H_probe));
stage.peak_gain_dB = 20*log10(stage.peak_gain + eps);
stage.recommended_headroom_bits = ceil(log2(stage.peak_gain + eps));

% Complex response function for chain compatibility.
fs_local = fs_in_Hz;
h_local = h;
stage.response = @(f_Hz) fir_response_horner(f_Hz, fs_local, h_local);

end


function H = fir_response_horner(f_Hz, fs_Hz, h)
%FIR_RESPONSE_HORNER Efficient complex FIR response at arbitrary frequencies.
%
% Evaluates:
%   H(f) = sum h[n] exp(-j 2 pi f/fs n)
%
% This works for f beyond Nyquist because the response is periodic.

f_Hz = f_Hz(:);
z = exp(-1j * 2*pi * f_Hz / fs_Hz);

H = h(end) * ones(size(f_Hz));

for k = numel(h)-1:-1:1
    H = H .* z + h(k);
end

end