function analysis = analysis_custom(func, varargin)
%ANALYSIS_CUSTOM Custom analysis hook.
%
% func must be a function handle. It is called as:
%   out = func(chain, context, varargin{:})
%
% context contains adc, allowed, limits, study, and any previous analysis
% outputs available at that moment.

if ~isa(func, 'function_handle')
    error("func must be a function handle, for example @my_analysis.");
end

[enabled, args] = pull_name_value(varargin, "Enabled", true);
[name, args] = pull_name_value(args, "Name", "Custom analysis");

analysis = struct();
analysis.kind = "custom";
analysis.name = string(name);
analysis.enabled = enabled;
analysis.func = func;
analysis.params = args;

end
