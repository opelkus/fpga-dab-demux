function analysis = analysis_stage_response(varargin)
%ANALYSIS_STAGE_RESPONSE Configuration for plot_stage_response().

p = inputParser;
addParameter(p, "Stage", "last");
addParameter(p, "N", 16384);
addParameter(p, "Enabled", true);
parse(p, varargin{:});
cfg = p.Results;

analysis = struct();
analysis.kind = "stage_response";
analysis.name = "Stage response";
analysis.enabled = cfg.Enabled;
analysis.stage = cfg.Stage;
analysis.N = cfg.N;

end
