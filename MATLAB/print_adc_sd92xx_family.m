function T = print_adc_sd92xx_family()
%PRINT_ADC_SD92XX_FAMILY Print seeded Silanna Plural ADC variants.
%
% T = print_adc_sd92xx_family();

family = adc_family_sd92xx_plural();
variants = family.variants;

part = strings(numel(variants), 1);
resolution_bits = zeros(numel(variants), 1);
speed_grade_MSps = zeros(numel(variants), 1);
channels = zeros(numel(variants), 1);

for k = 1:numel(variants)
    v = variants(k);
    part(k) = sprintf("%s-%d-A-%s-%s", ...
        v.base_part_number, ...
        v.speed_grade_MSps, ...
        v.package_code, ...
        v.default_order_code ...
    );
    resolution_bits(k) = v.resolution_bits;
    speed_grade_MSps(k) = v.speed_grade_MSps;
    channels(k) = v.channels;
end

T = table(part, resolution_bits, speed_grade_MSps, channels, ...
    'VariableNames', { ...
        'PartNumber_TA', ...
        'Resolution_bits', ...
        'SpeedGrade_MSps', ...
        'Channels' ...
    } ...
);

disp(T);

fprintf("\nPlatform-level resolutions: %s bit\n", num2str(family.platform_resolutions_bits));
fprintf("Platform-level speed grades: %s MSPS\n", num2str(family.platform_speed_grades_MSps));

end
