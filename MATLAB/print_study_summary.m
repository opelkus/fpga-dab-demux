function print_study_summary(result)
%PRINT_STUDY_SUMMARY Print configured ADC and chain rates.

study = result.study;
chain = result.chain;
context = result.context;

fprintf("\nStudy: %s\n", string(study.name));

if isfield(study, "description") && strlength(string(study.description)) > 0
    fprintf("  %s\n", string(study.description));
end

if ~isempty(context.adc)
    adc = context.adc;
    fprintf("\nADC configuration:\n");

    if isfield(adc, "vendor")
        fprintf("  vendor:             %s\n", string(adc.vendor));
    end

    if isfield(adc, "part_number")
        fprintf("  part:               %s\n", string(adc.part_number));
    end

    fprintf("  resolution:         %d bit\n", adc.resolution_bits);

    if isfield(adc, "channels")
        fprintf("  channels:           %d\n", adc.channels);
    end

    if isfield(adc, "speed_grade_MSps")
        fprintf("  speed grade:        %.3f MSPS\n", adc.speed_grade_MSps);
    end

    if isfield(adc, "sample_rate_Hz")
        fprintf("  sample rate:        %.3f MSPS\n", adc.sample_rate_Hz / 1e6);
    elseif isfield(adc.clock, "fADC_Hz")
        fprintf("  fADC:               %.3f MHz\n", adc.clock.fADC_Hz / 1e6);
    end

    if isfield(adc, "output_interface")
        fprintf("  output interface:   %s\n", string(adc.output_interface));
    end

    if isfield(adc, "oversampling") && adc.oversampling.enabled
        fprintf("  ADC OS ratio:       x%d\n", adc.oversampling.ratio);
        fprintf("  ADC output fs:      %.3f kS/s\n", adc.final_sample_rate_Hz / 1e3);
    end

    if isfield(adc, "validation")
        if isfield(adc.validation, "sample_rate_ok")
            fprintf("  sample rate OK:     %d\n", adc.validation.sample_rate_ok);
        end
        if isfield(adc.validation, "input_clock_ok")
            fprintf("  input clock OK:     %d\n", adc.validation.input_clock_ok);
        end
        if isfield(adc.validation, "output_fits_uint16")
            fprintf("  uint16 output fit:  %d\n", adc.validation.output_fits_uint16);
        end
        if isfield(adc.validation, "orderable_part_seeded")
            fprintf("  seeded exact part:  %d\n", adc.validation.orderable_part_seeded);
        end
    end
end

fprintf("\nConfigured chain:\n");

for k = 1:numel(chain)
    stage = chain{k};

    fprintf("  %d: %s", k, string(stage.name));

    has_fs_in = isfield(stage, "fs_in_Hz") && ~isnan(stage.fs_in_Hz);
    has_fs_out = isfield(stage, "fs_out_Hz") && ~isnan(stage.fs_out_Hz);

    if has_fs_in && has_fs_out
        fprintf(" | %.3f -> %.3f kS/s", ...
            stage.fs_in_Hz / 1e3, ...
            stage.fs_out_Hz / 1e3 ...
        );
    end

    fprintf("\n");
end

final_fs = get_final_fs_from_chain(chain);

if ~isnan(final_fs)
    fprintf("\nFinal output:\n");
    fprintf("  fs:                 %.3f kS/s\n", final_fs / 1e3);
    fprintf("  Nyquist:            %.3f kHz\n", final_fs / 2 / 1e3);
end

end


function fs_final = get_final_fs_from_chain(chain)

fs_final = NaN;

for k = numel(chain):-1:1
    if isfield(chain{k}, "fs_out_Hz") && ~isnan(chain{k}.fs_out_Hz)
        fs_final = chain{k}.fs_out_Hz;
        return;
    end
end

end
