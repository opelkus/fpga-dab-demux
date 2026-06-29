function block = block_fir_decimator(varargin)
%BLOCK_FIR_DECIMATOR FIR decimator block configuration.
%
% The parameter names mirror make_fir_decimator_stage(). FsInSource is a
% block-framework parameter and is not passed to the FIR designer.

p = inputParser;

addParameter(p, "Name", "FIR decimator");
addParameter(p, "Decimation", 3);
addParameter(p, "NumTaps", 95);
addParameter(p, "Cutoff_Hz", 10e3);
addParameter(p, "StopbandStart_Hz", []);
addParameter(p, "TransitionWidth_Hz", []);
addParameter(p, "BoostEnabled", true);
addParameter(p, "BoostStart_Hz", 5e3);
addParameter(p, "BoostGain_dB", 3);
addParameter(p, "BoostTransitionWidth_Hz", 1e3);
addParameter(p, "PassbandRipple_dB", 0.1);
addParameter(p, "StopbandAttenuation_dB", 80);
addParameter(p, "Method", "firls");
addParameter(p, "LinearPhase", true);

addParameter(p, "FsInSource", "previous");
addParameter(p, "Enabled", true);

parse(p, varargin{:});
cfg = p.Results;

block = struct();
block.kind = "fir_decimator";
block.name = sprintf("%s x%d", char(string(cfg.Name)), cfg.Decimation);
block.enabled = cfg.Enabled;
block.fs_in_source = string(cfg.FsInSource);

block.params = { ...
    "Name", cfg.Name, ...
    "Decimation", cfg.Decimation, ...
    "NumTaps", cfg.NumTaps, ...
    "Cutoff_Hz", cfg.Cutoff_Hz, ...
    "StopbandStart_Hz", cfg.StopbandStart_Hz, ...
    "TransitionWidth_Hz", cfg.TransitionWidth_Hz, ...
    "BoostEnabled", cfg.BoostEnabled, ...
    "BoostStart_Hz", cfg.BoostStart_Hz, ...
    "BoostGain_dB", cfg.BoostGain_dB, ...
    "BoostTransitionWidth_Hz", cfg.BoostTransitionWidth_Hz, ...
    "PassbandRipple_dB", cfg.PassbandRipple_dB, ...
    "StopbandAttenuation_dB", cfg.StopbandAttenuation_dB, ...
    "Method", cfg.Method, ...
    "LinearPhase", cfg.LinearPhase ...
};

end
