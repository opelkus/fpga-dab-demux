function analysis = analysis_fir_plot(varargin)
%ANALYSIS_FIR_PLOT Configuration for plot_fir_decimator_stage().

p = inputParser;
addParameter(p, "Stage", "last");
addParameter(p, "FMax_Hz", []);
addParameter(p, "N", 100000);
addParameter(p, "Enabled", true);
parse(p, varargin{:});
cfg = p.Results;

analysis = struct();
analysis.kind = "fir_plot";
analysis.name = "FIR plot";
analysis.enabled = cfg.Enabled;
analysis.stage = cfg.Stage;
analysis.f_max_Hz = cfg.FMax_Hz;
analysis.N = cfg.N;

end
