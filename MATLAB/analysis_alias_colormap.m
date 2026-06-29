function analysis = analysis_alias_colormap(varargin)
%ANALYSIS_ALIAS_COLORMAP Configuration for plot_chain_alias_colormap().

p = inputParser;
addParameter(p, "FMax_Hz", []);
addParameter(p, "N", 200000);
addParameter(p, "AliasBand_Hz", []);
addParameter(p, "CLim_dB", [-140 5]);
addParameter(p, "MarkerSize", 4);
addParameter(p, "UseAbsBand", true);
addParameter(p, "ShowGrid", true);
addParameter(p, "Title", "Alias map: input frequency → final output alias");
addParameter(p, "Enabled", true);
parse(p, varargin{:});
cfg = p.Results;

analysis = struct();
analysis.kind = "alias_colormap";
analysis.name = "Alias colormap";
analysis.enabled = cfg.Enabled;
analysis.f_max_Hz = cfg.FMax_Hz;
analysis.N = cfg.N;
analysis.options = { ...
    "AliasBand_Hz", cfg.AliasBand_Hz, ...
    "CLim_dB", cfg.CLim_dB, ...
    "MarkerSize", cfg.MarkerSize, ...
    "UseAbsBand", cfg.UseAbsBand, ...
    "ShowGrid", cfg.ShowGrid, ...
    "Title", cfg.Title ...
};

end
