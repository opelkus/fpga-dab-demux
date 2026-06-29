function analysis = analysis_alias_map(varargin)
%ANALYSIS_ALIAS_MAP Configuration for plot_chain_alias_map().

p = inputParser;
addParameter(p, "FMax_Hz", []);
addParameter(p, "N", 200000);
addParameter(p, "AliasBand_Hz", [0 10e3]);
addParameter(p, "Enabled", true);
parse(p, varargin{:});
cfg = p.Results;

analysis = struct();
analysis.kind = "alias_map";
analysis.name = "Alias map";
analysis.enabled = cfg.Enabled;
analysis.f_max_Hz = cfg.FMax_Hz;
analysis.N = cfg.N;
analysis.alias_band_Hz = cfg.AliasBand_Hz;

end
