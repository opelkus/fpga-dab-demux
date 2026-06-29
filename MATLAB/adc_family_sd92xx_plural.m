function family = adc_family_sd92xx_plural()
%ADC_FAMILY_SD92XX_PLURAL Variant table for Silanna Plural dual ADCs.
%
% The project uses this table as the single editable source of ADC family
% choices. The reference part requested for the default study is:
%
%   SD9231-20-A-QC9-TA
%
% Field meaning:
%   base_part_number        base device, without speed/package/order suffix
%   resolution_bits         ADC output resolution
%   speed_grade_MSps        maximum rated sample rate for that orderable grade
%   channels                number of ADC channels
%   exact_orderable_seed    true when the base/speed is seeded as an exact
%                           orderable family entry in this project
%
% If you need another orderable Silanna variant, add one line in the
% add_exact_variants() section below. The rest of the code will pick it up.

family = struct();
family.name = "Silanna Plural SD92xx/SD96xx dual ADC family";
family.reference_part_number = "SD9231-20-A-QC9-TA";
family.package_code = "QC9";
family.default_order_code = "TA";
family.order_codes = ["TA", "TB", "RD"];
family.output_interfaces = ["CMOS", "LVDS"];
family.channels = 2;
family.architecture = "pipeline";

% Platform-level choices. These are useful when you want to plan a study
% before a concrete orderable part number is added to the exact table below.
family.platform_resolutions_bits = [10 12 14 16];
family.platform_speed_grades_MSps = [20 25 40 65 80 105 125 170 210 250];

family.variants = repmat(empty_variant(), 0, 1);

%% Exact/orderable seed variants used by this project
% 10-bit dual ADCs around SD9204.
family = add_exact_variants(family, "SD9204", 10, [20 40 65 80]);

% 12-bit dual ADCs around the requested SD9231 family.
family = add_exact_variants(family, "SD9231", 12, [20 40 65 80]);

% 14-bit dual ADCs around SD9251.
family = add_exact_variants(family, "SD9251", 14, [20 40 65 80]);

% 16-bit dual ADCs around SD9268.
family = add_exact_variants(family, "SD9268", 16, [80 105 125]);

family.verified_part_numbers_TA = build_part_number_list(family, "TA");

end


function family = add_exact_variants(family, base_part_number, resolution_bits, speed_grades_MSps)

for k = 1:numel(speed_grades_MSps)
    v = empty_variant();
    v.base_part_number = string(base_part_number);
    v.resolution_bits = resolution_bits;
    v.speed_grade_MSps = speed_grades_MSps(k);
    v.channels = family.channels;
    v.package_code = family.package_code;
    v.default_order_code = family.default_order_code;
    v.architecture = family.architecture;
    v.exact_orderable_seed = true;
    v.note = "Exact base/speed seeded in adc_family_sd92xx_plural().";

    if isempty(family.variants)
        family.variants = v;
    else
        family.variants(end + 1) = v; %#ok<AGROW>
    end
end

end


function parts = build_part_number_list(family, order_code)

parts = strings(1, numel(family.variants));

for k = 1:numel(family.variants)
    v = family.variants(k);
    parts(k) = sprintf("%s-%d-A-%s-%s", ...
        v.base_part_number, ...
        v.speed_grade_MSps, ...
        v.package_code, ...
        string(order_code) ...
    );
end

end


function v = empty_variant()

v = struct( ...
    "base_part_number", string.empty, ...
    "resolution_bits", [], ...
    "speed_grade_MSps", [], ...
    "channels", [], ...
    "package_code", string.empty, ...
    "default_order_code", string.empty, ...
    "architecture", string.empty, ...
    "exact_orderable_seed", false, ...
    "note", string.empty ...
);

end
