function block = block_custom_stage(factory, varargin)
%BLOCK_CUSTOM_STAGE Custom stage block.
%
% factory must be a function handle. It is called as:
%   stage = factory(fs_in_Hz, varargin{:})
%
% The generated stage must expose at least:
%   stage.name
%   stage.fs_in_Hz
%   stage.fs_out_Hz
%   stage.response = @(f_Hz) ...
%
% Example:
%   block_custom_stage(@make_my_stage, "FsInSource", "previous", "Param", 1)

if ~isa(factory, 'function_handle')
    error("factory must be a function handle, for example @make_my_stage.");
end

[fs_source, args] = pull_name_value(varargin, "FsInSource", "previous");
[enabled, args] = pull_name_value(args, "Enabled", true);
[name, args] = pull_name_value(args, "Name", "Custom stage");

block = struct();
block.kind = "custom_stage";
block.name = string(name);
block.enabled = enabled;
block.fs_in_source = string(fs_source);
block.factory = factory;
block.params = args;

end
