function block = block_adc_oversampling(varargin)
%BLOCK_ADC_OVERSAMPLING Generic ADC oversampling/averaging block configuration.
%
% This block uses study.adc as its ADC source.

p = inputParser;
addParameter(p, "Enabled", true);
parse(p, varargin{:});
cfg = p.Results;

block = struct();
block.kind = "adc_oversampling";
block.name = "ADC oversampling";
block.enabled = cfg.Enabled;

end
