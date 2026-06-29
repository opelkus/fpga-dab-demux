function stage = make_adc_sampler_stage(adc)
%MAKE_ADC_SAMPLER_STAGE Frequency-domain ADC sampler stage.
%
% The sampler is modelled as a unity-gain stage in the analog-response
% chain. Aliasing is accounted for by later analyses through fs_out_Hz.

stage = struct();
stage.name = sprintf("%s sampler @ %.3f MSPS", adc.part_number, adc.sample_rate_Hz / 1e6);
stage.type = "adc_sampler";

stage.fs_in_Hz = adc.sample_rate_Hz;
stage.fs_out_Hz = adc.sample_rate_Hz;
stage.decimation = 1;

stage.resolution_bits = adc.resolution_bits;
stage.channels = adc.channels;
stage.max_code = adc.max_output_code;
stage.midscale_code = adc.midscale_output_code;
stage.output_interface = adc.output_interface;

stage.h_actual = 1;
stage.h_norm = 1;
stage.dc_gain_actual = 1;
stage.dc_gain_actual_dB = 0;
stage.group_delay_input_samples = 0;
stage.group_delay_seconds = 0;
stage.group_delay_output_samples = 0;
stage.output_nyquist_Hz = stage.fs_out_Hz / 2;

stage.response = @(f_Hz) ones(numel(f_Hz(:)), 1);

end
