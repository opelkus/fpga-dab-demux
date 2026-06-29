function result = run_study(study)
%RUN_STUDY Build a configured DSP chain and execute selected analyses.
%
% Example:
%   study = study_aliasing_default();
%   result = run_study(study);

[chain, context] = build_chain_from_blocks(study);

result = struct();
result.study = study;
result.chain = chain;
result.context = context;
result.analysis_outputs = {};

print_study_summary(result);

if ~isfield(study, "analyses") || isempty(study.analyses)
    fprintf("\nNo analyses configured. Chain was built only.\n");
    return;
end

fprintf("\nRunning analyses:\n");

for k = 1:numel(study.analyses)
    analysis = study.analyses{k};

    if isfield(analysis, "enabled") && ~analysis.enabled
        fprintf("  %d: %s [disabled]\n", k, string(analysis.name));
        continue;
    end

    fprintf("  %d: %s\n", k, string(analysis.name));

    out = run_one_analysis(analysis, chain, context, result);
    result.analysis_outputs{end + 1} = out; %#ok<AGROW>
    context.previous_outputs = result.analysis_outputs;
    result.context = context;
end

end


function out = run_one_analysis(analysis, chain, context, result)

out = struct();
out.kind = analysis.kind;
out.name = analysis.name;

switch string(analysis.kind)
    case "fir_report"
        idx = resolve_chain_stage(chain, analysis.stage);
        out.stage_index = idx;
        out.report = report_fir_decimator_stage(chain{idx}, analysis.N);

    case "fir_plot"
        idx = resolve_chain_stage(chain, analysis.stage);
        out.stage_index = idx;
        plot_fir_decimator_stage(chain{idx}, analysis.f_max_Hz, analysis.N);

    case "stage_response"
        idx = resolve_chain_stage(chain, analysis.stage);
        out.stage_index = idx;
        plot_stage_response(chain{idx}, analysis.N);

    case "chain_response"
        plot_chain_response(chain, analysis.f_max_Hz, analysis.N);

    case "alias_map"
        out.table = plot_chain_alias_map( ...
            chain, ...
            analysis.f_max_Hz, ...
            analysis.N, ...
            analysis.alias_band_Hz ...
        );

    case "alias_colormap"
        out.table = plot_chain_alias_colormap( ...
            chain, ...
            analysis.f_max_Hz, ...
            analysis.N, ...
            analysis.options{:} ...
        );

    case "alias_heatmap"
        [T, Hmap, x_edges, y_edges] = plot_chain_alias_heatmap( ...
            chain, ...
            analysis.f_max_Hz, ...
            analysis.N, ...
            analysis.options{:} ...
        );
        out.table = T;
        out.Hmap = Hmap;
        out.x_edges = x_edges;
        out.y_edges = y_edges;

    case "custom"
        context.result_so_far = result;
        out.value = analysis.func(chain, context, analysis.params{:});

    otherwise
        error("Unsupported analysis kind: %s", string(analysis.kind));
end

end
