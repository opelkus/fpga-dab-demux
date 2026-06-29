function y = apply_stage(x, stage)
%APPLY_STAGE Apply DSP stage to signal.
%
% For ADC oversampling stage:
%   input  x is sampled at stage.fs_in_Hz
%   output y is sampled at stage.fs_out_Hz

switch stage.type

    case "adc_sampler"

        % Frequency-domain ADC model is unity gain. Time-domain application
        % passes samples through unchanged; quantization can be added later
        % as a separate experiment-specific block.
        y = double(x);

    case "fir_decimator"

        h = stage.h_actual;

        % FIR moving sum / average
        y_full = filter(h, 1, double(x));

        % First valid complete sum is at sample M.
        M = stage.decimation;
        y = y_full(M:M:end);

    otherwise
        error("Unsupported stage type: %s", stage.type);

end

end