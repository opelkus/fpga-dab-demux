function analysis = analysis_alias_heatmap(varargin)
%ANALYSIS_ALIAS_HEATMAP Configuration for plot_chain_alias_heatmap().

p = inputParser;
addParameter(p, "FMax_Hz", []);
addParameter(p, "N", 500000);
addParameter(p, "XBins", 1200);
addParameter(p, "YBins", 500);
addParameter(p, "AliasBand_Hz", []);
addParameter(p, "UseAbsBand", true);
addParameter(p, "CLim_dB", [-140 5]);
addParameter(p, "Title", "Alias heatmap: input frequency → final output alias");
addParameter(p, "Enabled", true);
parse(p, varargin{:});
cfg = p.Results;

analysis = struct();
analysis.kind = "alias_heatmap";
analysis.name = "Alias heatmap";
analysis.enabled = cfg.Enabled;
analysis.f_max_Hz = cfg.FMax_Hz;
analysis.N = cfg.N;
analysis.options = { ...
    "XBins", cfg.XBins, ...
    "YBins", cfg.YBins, ...
    "AliasBand_Hz", cfg.AliasBand_Hz, ...
    "UseAbsBand", cfg.UseAbsBand, ...
    "CLim_dB", cfg.CLim_dB, ...
    "Title", cfg.Title ...
};

end
