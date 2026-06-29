function analysis = analysis_chain_response(varargin)
%ANALYSIS_CHAIN_RESPONSE Configuration for plot_chain_response().

p = inputParser;
addParameter(p, "FMax_Hz", []);
addParameter(p, "N", 100000);
addParameter(p, "Enabled", true);
parse(p, varargin{:});
cfg = p.Results;

analysis = struct();
analysis.kind = "chain_response";
analysis.name = "Chain response";
analysis.enabled = cfg.Enabled;
analysis.f_max_Hz = cfg.FMax_Hz;
analysis.N = cfg.N;

end
