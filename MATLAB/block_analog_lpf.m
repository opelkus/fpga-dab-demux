function block = block_analog_lpf(varargin)
%BLOCK_ANALOG_LPF Analog low-pass filter block configuration.
%
% Example:
%   block_analog_lpf("Cutoff_Hz", 10e3, "Order", 2, "Model", "butterworth")

p = inputParser;
addParameter(p, "Cutoff_Hz", 10e3);
addParameter(p, "Order", 2);
addParameter(p, "Model", "butterworth");
addParameter(p, "Enabled", true);
parse(p, varargin{:});
cfg = p.Results;

block = struct();
block.kind = "analog_lpf";
block.name = sprintf("Analog LPF %.3f kHz", cfg.Cutoff_Hz/1e3);
block.enabled = cfg.Enabled;
block.cutoff_Hz = cfg.Cutoff_Hz;
block.order = cfg.Order;
block.model = string(cfg.Model);

end
