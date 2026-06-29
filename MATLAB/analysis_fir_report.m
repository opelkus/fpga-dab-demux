function analysis = analysis_fir_report(varargin)
%ANALYSIS_FIR_REPORT Configuration for report_fir_decimator_stage().
%
% Stage can be:
%   "last"       - last stage in chain
%   "first_fir"  - first FIR-decimator stage
%   numeric index - exact chain index

p = inputParser;
addParameter(p, "Stage", "last");
addParameter(p, "N", 200000);
addParameter(p, "Enabled", true);
parse(p, varargin{:});
cfg = p.Results;

analysis = struct();
analysis.kind = "fir_report";
analysis.name = "FIR report";
analysis.enabled = cfg.Enabled;
analysis.stage = cfg.Stage;
analysis.N = cfg.N;

end
