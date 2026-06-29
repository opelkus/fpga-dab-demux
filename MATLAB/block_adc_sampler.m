function block = block_adc_sampler(varargin)
%BLOCK_ADC_SAMPLER ADC sampling stage with unity frequency response.
%
% This block inserts the selected ADC sample rate into the chain. It does
% not apply an anti-alias filter; put block_analog_lpf() before it when the
% analog front-end needs to be modelled.

p = inputParser;
addParameter(p, "Enabled", true);
parse(p, varargin{:});
cfg = p.Results;

block = struct();
block.kind = "adc_sampler";
block.name = "ADC sampler";
block.enabled = cfg.Enabled;

end
