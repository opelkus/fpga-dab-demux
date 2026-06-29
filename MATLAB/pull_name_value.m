function [value, args_out, found] = pull_name_value(args_in, name, default_value)
%PULL_NAME_VALUE Remove one name-value pair from a cell array.
%
% This utility keeps block_custom_stage() simple while staying compatible
% with ordinary MATLAB name-value cell arrays.

args_out = args_in;
value = default_value;
found = false;

name = string(name);

if isempty(args_in)
    return;
end

if mod(numel(args_in), 2) ~= 0
    error("Name-value arguments must have an even number of elements.");
end

remove_idx = [];

for k = 1:2:numel(args_in)
    key = string(args_in{k});

    if key == name
        value = args_in{k + 1};
        found = true;
        remove_idx = [k, k + 1]; %#ok<AGROW>
        break;
    end
end

if found
    args_out(remove_idx) = [];
end

end
