function block = block_adc_sd92xx(varargin)
%BLOCK_ADC_SD92XX Configuration block for Silanna Plural SD92xx ADCs.
%
% Examples:
%   study.adc = block_adc_sd92xx("Variant", "SD9231-20-A-QC9-TA");
%
%   study.adc = block_adc_sd92xx( ...
%       "ResolutionBits", 10, ...
%       "SpeedGrade_MSps", 40 ...
%   );
%
%   study.adc = block_adc_sd92xx( ...
%       "Variant", "SD9231-20-A-QC9-TA", ...
%       "SampleRate_Hz", 5e6 ...
%   );

block = struct();
block.kind = "adc_sd92xx_plural";
block.name = "Silanna Plural SD92xx ADC configuration";
block.params = varargin;

end
