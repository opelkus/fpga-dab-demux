function [adc, allowed, limits, family] = adc_config_sd92xx_plural(varargin)
%ADC_CONFIG_SD92XX_PLURAL Configurable Silanna Plural ADC family model.
%
% Default:
%   [adc, allowed, limits] = adc_config_sd92xx_plural();
%
% Select exact part:
%   adc_config_sd92xx_plural("Variant", "SD9231-20-A-QC9-TA")
%
% Select by resolution and speed grade:
%   adc_config_sd92xx_plural("ResolutionBits", 10, "SpeedGrade_MSps", 40)
%
% Use a lower operating sample rate than the selected speed grade:
%   adc_config_sd92xx_plural( ...
%       "Variant", "SD9231-20-A-QC9-TA", ...
%       "SampleRate_Hz", 5e6 ...
%   )
%
% Use a platform-level combination not yet present in the exact table:
%   adc_config_sd92xx_plural( ...
%       "ResolutionBits", 12, ...
%       "SpeedGrade_MSps", 125, ...
%       "AllowPlatformVariant", true ...
%   )

p = inputParser;

addParameter(p, "Variant", "SD9231-20-A-QC9-TA");
addParameter(p, "ResolutionBits", []);
addParameter(p, "SpeedGrade_MSps", []);
addParameter(p, "SampleRate_Hz", []);

addParameter(p, "OrderCode", "TA");
addParameter(p, "PackageCode", "QC9");
addParameter(p, "OutputInterface", "CMOS");
addParameter(p, "InputClockDivider", 1);
addParameter(p, "AllowPlatformVariant", false);

parse(p, varargin{:});
cfg = p.Results;

family = adc_family_sd92xx_plural();

allowed = struct();
allowed.resolution_bits = family.platform_resolutions_bits;
allowed.speed_grades_MSps = family.platform_speed_grades_MSps;
allowed.order_codes = family.order_codes;
allowed.package_codes = family.package_code;
allowed.output_interfaces = family.output_interfaces;
allowed.input_clock_dividers = 1:8;
allowed.verified_part_numbers_TA = family.verified_part_numbers_TA;

limits = struct();
limits.max_input_clock_Hz = 500e6;
limits.min_sample_rate_Hz = 0;

order_code = upper(string(cfg.OrderCode));
package_code = upper(string(cfg.PackageCode));
output_interface = upper(string(cfg.OutputInterface));

must_be_member(order_code, allowed.order_codes, "OrderCode");
must_be_member(package_code, allowed.package_codes, "PackageCode");
must_be_member(output_interface, allowed.output_interfaces, "OutputInterface");
must_be_member(cfg.InputClockDivider, allowed.input_clock_dividers, "InputClockDivider");

has_resolution_override = ~isempty(cfg.ResolutionBits);
has_speed_override = ~isempty(cfg.SpeedGrade_MSps);

if has_resolution_override || has_speed_override
    if ~has_resolution_override || ~has_speed_override
        error("Use both ResolutionBits and SpeedGrade_MSps, or use Variant only.");
    end

    variant = select_variant_by_resolution_speed( ...
        family, ...
        cfg.ResolutionBits, ...
        cfg.SpeedGrade_MSps, ...
        package_code, ...
        order_code, ...
        cfg.AllowPlatformVariant ...
    );
else
    variant = select_variant_by_part_number( ...
        family, ...
        string(cfg.Variant), ...
        package_code, ...
        order_code, ...
        cfg.AllowPlatformVariant ...
    );
end

% Use package/order parsed from Variant when a full part number was supplied.
package_code = variant.package_code;
order_code = variant.default_order_code;

if isempty(cfg.SampleRate_Hz)
    sample_rate_Hz = variant.speed_grade_MSps * 1e6;
else
    sample_rate_Hz = cfg.SampleRate_Hz;
end

if sample_rate_Hz <= 0
    error("SampleRate_Hz must be positive.");
end

max_sample_rate_Hz = variant.speed_grade_MSps * 1e6;
input_clock_Hz = sample_rate_Hz * cfg.InputClockDivider;

adc = struct();
adc.name = sprintf("%s %d-bit %.0f MSPS dual ADC", ...
    variant.base_part_number, ...
    variant.resolution_bits, ...
    variant.speed_grade_MSps ...
);
adc.vendor = "Silanna Semiconductor";
adc.family = family.name;
adc.reference_part_number = family.reference_part_number;
adc.part_number = build_part_number(variant, package_code, order_code);
adc.base_part_number = variant.base_part_number;
adc.resolution_bits = variant.resolution_bits;
adc.channels = variant.channels;
adc.architecture = variant.architecture;
adc.package_code = package_code;
adc.order_code = order_code;
adc.output_interface = output_interface;
adc.speed_grade_MSps = variant.speed_grade_MSps;
adc.max_sample_rate_Hz = max_sample_rate_Hz;
adc.sample_rate_Hz = sample_rate_Hz;
adc.raw_sample_rate_Hz = sample_rate_Hz;
adc.final_sample_rate_Hz = sample_rate_Hz;
adc.final_IQ_pair_rate_Hz = sample_rate_Hz;
adc.exact_orderable_seed = variant.exact_orderable_seed;

adc.clock = struct();
adc.clock.input_clock_divider = cfg.InputClockDivider;
adc.clock.input_clock_Hz = input_clock_Hz;
adc.clock.fADC_Hz = sample_rate_Hz;
adc.clock.sample_rate_Hz = sample_rate_Hz;

% Keep a neutral oversampling sub-struct so older generic stages can still
% inspect adc.oversampling.
adc.oversampling = struct();
adc.oversampling.enabled = false;
adc.oversampling.ratio = 1;
adc.oversampling.right_shift = 0;

adc.max_raw_code = 2^adc.resolution_bits - 1;
adc.max_output_code = adc.max_raw_code;
adc.midscale_output_code = 2^(adc.resolution_bits - 1);
adc.theoretical_oversampling_gain_bits = 0;

limits.selected_sample_rate_max_Hz = max_sample_rate_Hz;
limits.selected_input_clock_max_Hz = limits.max_input_clock_Hz;

adc.validation = struct();
adc.validation.sample_rate_ok = sample_rate_Hz <= max_sample_rate_Hz;
adc.validation.input_clock_ok = input_clock_Hz <= limits.max_input_clock_Hz;
adc.validation.output_fits_uint16 = adc.max_output_code <= double(intmax("uint16"));
adc.validation.orderable_part_seeded = variant.exact_orderable_seed;
adc.validation.platform_variant = ~variant.exact_orderable_seed;

if ~adc.validation.sample_rate_ok
    error("SampleRate_Hz %.3f MSPS exceeds selected speed grade %.3f MSPS.", ...
        sample_rate_Hz / 1e6, ...
        max_sample_rate_Hz / 1e6 ...
    );
end

if ~adc.validation.input_clock_ok
    error("Input clock %.3f MHz exceeds %.3f MHz limit. Reduce SampleRate_Hz or InputClockDivider.", ...
        input_clock_Hz / 1e6, ...
        limits.max_input_clock_Hz / 1e6 ...
    );
end

end


function variant = select_variant_by_part_number(family, part_number, package_code, order_code, allow_platform)

part_number = upper(string(part_number));

if strlength(part_number) == 0 || part_number == "AUTO"
    part_number = family.reference_part_number;
end

[base_part_number, speed_grade_MSps, parsed_package_code, parsed_order_code] = parse_part_number(part_number);

if strlength(parsed_package_code) > 0
    package_code = parsed_package_code;
end

if strlength(parsed_order_code) > 0
    order_code = parsed_order_code;
end

variant = find_exact_variant(family, base_part_number, speed_grade_MSps);

if ~isempty(variant)
    variant.package_code = package_code;
    variant.default_order_code = order_code;
    return;
end

if allow_platform
    error([ ...
        "Variant '%s' is not in the exact SD92xx table. " + ...
        "Use ResolutionBits + SpeedGrade_MSps with AllowPlatformVariant=true, " + ...
        "or add this exact part to adc_family_sd92xx_plural()."], part_number);
end

error([ ...
    "Unsupported ADC Variant: %s. Add it in adc_family_sd92xx_plural(), " + ...
    "or select by ResolutionBits/SpeedGrade_MSps with AllowPlatformVariant=true."], part_number);

end


function variant = select_variant_by_resolution_speed(family, resolution_bits, speed_grade_MSps, package_code, order_code, allow_platform)

must_be_member(resolution_bits, family.platform_resolutions_bits, "ResolutionBits");
must_be_member(speed_grade_MSps, family.platform_speed_grades_MSps, "SpeedGrade_MSps");

matches = [];
for k = 1:numel(family.variants)
    v = family.variants(k);
    if v.resolution_bits == resolution_bits && v.speed_grade_MSps == speed_grade_MSps
        matches(end + 1) = k; %#ok<AGROW>
    end
end

if ~isempty(matches)
    variant = family.variants(matches(1));
    variant.package_code = package_code;
    variant.default_order_code = order_code;
    return;
end

if allow_platform
    variant = make_platform_variant(resolution_bits, speed_grade_MSps, family.channels, package_code, order_code);
    return;
end

error([ ...
    "No exact ADC seed for %d-bit %.0f MSPS. " + ...
    "Either add it in adc_family_sd92xx_plural(), or set AllowPlatformVariant=true."], ...
    resolution_bits, ...
    speed_grade_MSps ...
);

end


function variant = find_exact_variant(family, base_part_number, speed_grade_MSps)

variant = [];
base_part_number = upper(string(base_part_number));

for k = 1:numel(family.variants)
    v = family.variants(k);
    if upper(string(v.base_part_number)) == base_part_number && v.speed_grade_MSps == speed_grade_MSps
        variant = v;
        return;
    end
end

end


function variant = make_platform_variant(resolution_bits, speed_grade_MSps, channels, package_code, order_code)

variant = struct();
variant.base_part_number = sprintf("PLURAL_%db", resolution_bits);
variant.resolution_bits = resolution_bits;
variant.speed_grade_MSps = speed_grade_MSps;
variant.channels = channels;
variant.package_code = package_code;
variant.default_order_code = order_code;
variant.architecture = "pipeline";
variant.exact_orderable_seed = false;
variant.note = "Platform-level option; exact orderable part not seeded in adc_family_sd92xx_plural().";

end


function part_number = build_part_number(variant, package_code, order_code)

if variant.exact_orderable_seed
    part_number = sprintf("%s-%d-A-%s-%s", ...
        string(variant.base_part_number), ...
        variant.speed_grade_MSps, ...
        string(package_code), ...
        string(order_code) ...
    );
else
    part_number = sprintf("Silanna Plural %d-bit %.0f MSPS platform option", ...
        variant.resolution_bits, ...
        variant.speed_grade_MSps ...
    );
end

end


function [base_part_number, speed_grade_MSps, package_code, order_code] = parse_part_number(part_number)

base_part_number = "";
speed_grade_MSps = [];
package_code = "";
order_code = "";

tokens = regexp(char(part_number), '^(SD\d+)-(\d+)-A-([A-Z0-9]+)-([A-Z0-9]+)$', 'tokens', 'once');

if isempty(tokens)
    error("ADC Variant must look like SD9231-20-A-QC9-TA. Got: %s", part_number);
end

base_part_number = string(tokens{1});
speed_grade_MSps = str2double(tokens{2});
package_code = string(tokens{3});
order_code = string(tokens{4});

end


function must_be_member(value, allowed_values, parameter_name)

if isnumeric(allowed_values)
    ok = any(value == allowed_values);
else
    ok = any(upper(string(value)) == upper(string(allowed_values)));
end

if ~ok
    error("Unsupported %s: %s", string(parameter_name), string(value));
end

end
