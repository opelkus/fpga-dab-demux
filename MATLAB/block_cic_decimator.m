function block = block_cic_decimator(varargin)
%BLOCK_CIC_DECIMATOR CIC decimator block configuration.
%
% Example:
%   block_cic_decimator("Decimation", 4, "Order", 8)

p = inputParser;
addParameter(p, "Decimation", 4);
addParameter(p, "Order", 4);
addParameter(p, "FsInSource", "previous");
addParameter(p, "Enabled", true);
parse(p, varargin{:});
cfg = p.Results;

block = struct();
block.kind = "cic_decimator";
block.name = sprintf("CIC order %d, R=%d", cfg.Order, cfg.Decimation);
block.enabled = cfg.Enabled;
block.decimation = cfg.Decimation;
block.order = cfg.Order;
block.fs_in_source = string(cfg.FsInSource);

end
