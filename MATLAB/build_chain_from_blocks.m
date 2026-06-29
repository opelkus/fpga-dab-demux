function [chain, context] = build_chain_from_blocks(study)
%BUILD_CHAIN_FROM_BLOCKS Instantiate configured stage blocks.
%
% Input:
%   study.adc    - optional ADC config block
%   study.stages - cell array of block_* structs
%
% Output:
%   chain        - cell array of instantiated stage structs
%   context      - ADC/config metadata used by analyses

context = struct();
context.study = study;
context.adc = [];
context.allowed = [];
context.limits = [];
context.family = [];

%% ADC configuration

if isfield(study, "adc") && ~isempty(study.adc)
    adc_block = study.adc;

    switch string(adc_block.kind)
        case "adc_sd92xx_plural"
            [adc, allowed, limits, family] = adc_config_sd92xx_plural(adc_block.params{:});
            context.adc = adc;
            context.allowed = allowed;
            context.limits = limits;
            context.family = family;

        otherwise
            error("Unsupported ADC config block kind: %s", string(adc_block.kind));
    end
end

%% Signal chain

if ~isfield(study, "stages") || isempty(study.stages)
    error("study.stages is empty. Add at least one block_* stage.");
end

chain = {};
source_blocks = {};

for k = 1:numel(study.stages)
    block = study.stages{k};

    if isfield(block, "enabled") && ~block.enabled
        continue;
    end

    kind = string(block.kind);

    switch kind
        case "analog_lpf"
            stage = make_analog_lpf_stage( ...
                block.cutoff_Hz, ...
                block.order, ...
                block.model ...
            );

        case "adc_oversampling"
            if isempty(context.adc)
                error("block_adc_oversampling() requires study.adc to be configured.");
            end
            stage = make_adc_oversampling_stage(context.adc);

        case "adc_sampler"
            if isempty(context.adc)
                error("block_adc_sampler() requires study.adc to be configured.");
            end
            stage = make_adc_sampler_stage(context.adc);

        case "cic_decimator"
            fs_in_Hz = resolve_fs_in(block.fs_in_source, chain, context);
            stage = make_cic_decimator_stage( ...
                fs_in_Hz, ...
                block.decimation, ...
                block.order ...
            );

        case "fir_decimator"
            fs_in_Hz = resolve_fs_in(block.fs_in_source, chain, context);
            stage = make_fir_decimator_stage(fs_in_Hz, block.params{:});

        case "custom_stage"
            fs_in_Hz = resolve_fs_in(block.fs_in_source, chain, context);
            stage = block.factory(fs_in_Hz, block.params{:});

        otherwise
            error("Unsupported stage block kind: %s", kind);
    end

    stage.block_kind = kind;
    stage.block_index = k;

    chain{end + 1} = stage; %#ok<AGROW>
    source_blocks{end + 1} = block; %#ok<AGROW>
end

context.source_blocks = source_blocks;

end


function fs_in_Hz = resolve_fs_in(source, chain, context)
%RESOLVE_FS_IN Resolve input sampling rate for a digital stage.

if isnumeric(source)
    fs_in_Hz = source;
    return;
end

source = string(source);

switch source
    case "previous"
        for k = numel(chain):-1:1
            if isfield(chain{k}, "fs_out_Hz") && ~isnan(chain{k}.fs_out_Hz)
                fs_in_Hz = chain{k}.fs_out_Hz;
                return;
            end
        end
        error("FsInSource='previous' requested, but no previous digital stage has fs_out_Hz.");

    case "adc_raw"
        require_adc(context, source);
        fs_in_Hz = context.adc.raw_sample_rate_Hz;

    case "adc_final"
        require_adc(context, source);
        fs_in_Hz = context.adc.final_sample_rate_Hz;

    case "adc_oversampled"
        require_adc(context, source);
        fs_in_Hz = context.adc.final_sample_rate_Hz;

    otherwise
        error([ ...
            "Unsupported FsInSource: %s. Use 'previous', 'adc_raw', " + ...
            "'adc_final', or a numeric sampling rate in Hz."], source);
end

end


function require_adc(context, source)

if isempty(context.adc)
    error("FsInSource='%s' requires study.adc to be configured.", string(source));
end

end
