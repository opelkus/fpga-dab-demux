function idx = resolve_chain_stage(chain, selector)
%RESOLVE_CHAIN_STAGE Convert a stage selector to a chain index.
%
% selector options:
%   "last", "first", "first_fir", "last_fir", "first_cic", "last_cic"
%   numeric index
%   exact or partial stage name text

if isempty(chain)
    error("Chain is empty.");
end

if isnumeric(selector)
    idx = selector;
    validate_index(idx, chain);
    return;
end

selector = string(selector);

switch selector
    case "first"
        idx = 1;
        return;

    case "last"
        idx = numel(chain);
        return;

    case "first_fir"
        idx = find_stage_by_type(chain, "fir_decimator", "first");
        return;

    case "last_fir"
        idx = find_stage_by_type(chain, "fir_decimator", "last");
        return;

    case "first_cic"
        idx = find_stage_by_type(chain, "cic_decimator", "first");
        return;

    case "last_cic"
        idx = find_stage_by_type(chain, "cic_decimator", "last");
        return;

    case "first_adc_oversampling"
        idx = find_stage_by_type(chain, "adc_oversampling", "first");
        return;

    case "last_adc_oversampling"
        idx = find_stage_by_type(chain, "adc_oversampling", "last");
        return;

    case "first_adc_sampler"
        idx = find_stage_by_type(chain, "adc_sampler", "first");
        return;

    case "last_adc_sampler"
        idx = find_stage_by_type(chain, "adc_sampler", "last");
        return;
end

% Fallback: exact or partial name match.
for k = 1:numel(chain)
    stage_name = string(chain{k}.name);
    if stage_name == selector || contains(stage_name, selector)
        idx = k;
        return;
    end
end

error("Could not resolve stage selector: %s", selector);

end


function idx = find_stage_by_type(chain, type_name, direction)

matches = [];
use_block_kind = false;

for k = 1:numel(chain)
    if isfield(chain{k}, "block_kind")
        use_block_kind = true;
        break;
    end
end

for k = 1:numel(chain)
    if use_block_kind
        if isfield(chain{k}, "block_kind") && string(chain{k}.block_kind) == string(type_name)
            matches(end + 1) = k; %#ok<AGROW>
        end
    else
        if isfield(chain{k}, "type") && string(chain{k}.type) == string(type_name)
            matches(end + 1) = k; %#ok<AGROW>
        end
    end
end

if isempty(matches)
    error("No stage of type '%s' found.", string(type_name));
end

switch string(direction)
    case "first"
        idx = matches(1);
    case "last"
        idx = matches(end);
    otherwise
        error("Unsupported direction: %s", string(direction));
end

end


function idx = find_stage_by_name(chain, name_text, direction)

matches = [];
needle = string(name_text);

for k = 1:numel(chain)
    if isfield(chain{k}, "name") && contains(string(chain{k}.name), needle)
        matches(end + 1) = k; %#ok<AGROW>
    end
end

if isempty(matches)
    error("No stage containing name '%s' found.", needle);
end

switch string(direction)
    case "first"
        idx = matches(1);
    case "last"
        idx = matches(end);
    otherwise
        error("Unsupported direction: %s", string(direction));
end

end


function validate_index(idx, chain)

if numel(idx) ~= 1 || idx < 1 || idx > numel(chain) || round(idx) ~= idx
    error("Stage index must be an integer from 1 to %d.", numel(chain));
end

end
