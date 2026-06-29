clear; clc; close all;

%% ============================================================
%  MAIN - DAB+ aliasing study
%
%  Tor:
%    analog LPF
%      -> ADC sampler, Fs_ADC = n * 2.048 MHz
%      -> CIC /2
%      -> FIR1 /2
%      -> FIR2 /2
%
%  Dodatkowo:
%    - wybór typu analogowego filtru LPF
%    - analogowy filtr 3. rzędu
%    - sprawdzenie opóźnienia grupowego analogowego LPF
%    - FIR-y wymuszone jako liniowofazowe
%% ============================================================


%% ============================================================
%  GŁÓWNE PARAMETRY
%% ============================================================

BW_Hz  = 2.048e6;     % bazowy raster Fs DAB+
BW_DAB = 768e3;       % pasmo I lub Q badanego sygnału DAB+

n = 8;                % Fs_ADC = n * 2.048 MHz
Fs_ADC_Hz = n * BW_Hz;

D_CIC  = 2;
D_FIR1 = 2;
D_FIR2 = 2;

CIC_ORDER = 5;

D_TOTAL = D_CIC * D_FIR1 * D_FIR2;

Fs_after_CIC_Hz  = Fs_ADC_Hz / D_CIC;
Fs_after_FIR1_Hz = Fs_after_CIC_Hz / D_FIR1;
Fs_OUT_Hz        = Fs_after_FIR1_Hz / D_FIR2;

FMAX_ANALYSIS_Hz = 30e6;

ADC_VARIANT = "SD9231-20-A-QC9-TA";
ADC_MAX_SAMPLE_RATE_Hz = 20e6;


%% ============================================================
%  ANALOGOWY FILTR LPF
%
%  Dostępne modele po podmianie make_analog_lpf_stage.m:
%
%    "butterworth"
%    "bessel"
%    "chebyshev1"
%    "chebyshev2"
%    "elliptic"
%
%  Dla DAB+:
%    - "bessel"      najlepszy fazowo, ale łagodniejsze tłumienie
%    - "butterworth" kompromis
%    - "elliptic"    ostre tłumienie, ale zwykle najgorsza faza
%% ============================================================

ANALOG_LPF_CUTOFF_Hz = 1e6;
ANALOG_LPF_ORDER     = 3;
ANALOG_LPF_MODEL     = "Butterworth";

% Przykłady:
% ANALOG_LPF_MODEL = "bessel";
% ANALOG_LPF_MODEL = "chebyshev1";
% ANALOG_LPF_MODEL = "chebyshev2";
% ANALOG_LPF_MODEL = "elliptic";


%% ============================================================
%  PRZEŁĄCZNIKI ANALIZ
%% ============================================================

RUN_FIR_REPORT         = true;
RUN_ANALOG_ALIAS_DEBUG = true;
RUN_STAGE_ALIAS_DEBUG  = true;
RUN_ALIAS_MAP          = true;
RUN_ALIAS_HEATMAP      = false;
RUN_ALIAS_METRIC       = true;
RUN_ANALOG_GROUP_DELAY = false;


%% ============================================================
%  PARAMETRY FILTRÓW FIR
%% ============================================================

FIR1_FsIn_Hz  = Fs_after_CIC_Hz;
FIR1_FsOut_Hz = Fs_after_FIR1_Hz;

FIR2_FsIn_Hz  = Fs_after_FIR1_Hz;
FIR2_FsOut_Hz = Fs_OUT_Hz;

FIR1_StopbandStart_Hz = FIR1_FsOut_Hz - BW_DAB;
FIR2_StopbandStart_Hz = FIR2_FsOut_Hz - BW_DAB;

FIR1_TransitionWidth_Hz = FIR1_StopbandStart_Hz - BW_DAB;
FIR2_TransitionWidth_Hz = FIR2_StopbandStart_Hz - BW_DAB;

FIR1_NUM_TAPS = 15;
FIR2_NUM_TAPS = 37;

FIR1_STOPBAND_ATTENUATION_dB = 55;
FIR2_STOPBAND_ATTENUATION_dB = 90;

FIR1_PASSBAND_RIPPLE_dB = 0.2;
FIR2_PASSBAND_RIPPLE_dB = 0.1;

% Wymuszenie liniowej fazy FIR:
% h[n] = h[N-1-n]
FIR_LINEAR_PHASE = true;


%% ============================================================
%  WALIDACJA PLANU PRÓBKOWANIA
%% ============================================================

fprintf("\n============================================================\n");
fprintf("SAMPLING PLAN\n");
fprintf("============================================================\n");
fprintf("  BW base:         %.6f MHz\n", BW_Hz / 1e6);
fprintf("  BW DAB:          %.6f MHz\n", BW_DAB / 1e6);
fprintf("  n:               %d\n", n);
fprintf("  Fs ADC:          %.6f MHz\n", Fs_ADC_Hz / 1e6);
fprintf("  CIC decimation:  %d\n", D_CIC);
fprintf("  FIR1 decimation: %d\n", D_FIR1);
fprintf("  FIR2 decimation: %d\n", D_FIR2);
fprintf("  Total decim:     %d\n", D_TOTAL);
fprintf("  Fs after CIC:    %.6f MHz\n", Fs_after_CIC_Hz / 1e6);
fprintf("  Fs after FIR1:   %.6f MHz\n", Fs_after_FIR1_Hz / 1e6);
fprintf("  Fs OUT:          %.6f MHz\n", Fs_OUT_Hz / 1e6);
fprintf("  Nyquist OUT:     %.6f MHz\n", Fs_OUT_Hz / 2 / 1e6);
fprintf("  Analysis Fmax:   %.6f MHz\n", FMAX_ANALYSIS_Hz / 1e6);

fprintf("\nANALOG LPF PLAN\n");
fprintf("  Model:           %s\n", ANALOG_LPF_MODEL);
fprintf("  Order:           %d\n", ANALOG_LPF_ORDER);
fprintf("  Cutoff:          %.6f MHz\n", ANALOG_LPF_CUTOFF_Hz / 1e6);

if Fs_OUT_Hz <= 2 * BW_DAB
    error("Fs_OUT_Hz is too low. Need Fs_OUT_Hz > 2*BW_DAB to leave transition margin.");
end

if Fs_ADC_Hz > ADC_MAX_SAMPLE_RATE_Hz
    error("Fs_ADC_Hz = %.3f MSPS exceeds selected ADC limit %.3f MSPS for %s.", ...
        Fs_ADC_Hz / 1e6, ADC_MAX_SAMPLE_RATE_Hz / 1e6, ADC_VARIANT);
end

if FIR1_TransitionWidth_Hz <= 0
    error("FIR1 has no transition band. Increase n or reduce FIR1 decimation.");
end

if FIR2_TransitionWidth_Hz <= 0
    error("FIR2 has no transition band. Increase n or reduce FIR2 decimation.");
end

if FIR1_StopbandStart_Hz >= FIR1_FsIn_Hz / 2
    error("FIR1 stopband starts above input Nyquist.");
end

if FIR2_StopbandStart_Hz >= FIR2_FsIn_Hz / 2
    error("FIR2 stopband starts above input Nyquist.");
end

fprintf("\nFIR PLAN\n");
fprintf("  FIR1 Fs in:       %.6f MHz\n", FIR1_FsIn_Hz / 1e6);
fprintf("  FIR1 Fs out:      %.6f MHz\n", FIR1_FsOut_Hz / 1e6);
fprintf("  FIR1 cutoff:      %.6f MHz\n", BW_DAB / 1e6);
fprintf("  FIR1 stopband:    %.6f MHz\n", FIR1_StopbandStart_Hz / 1e6);
fprintf("  FIR1 transition:  %.6f MHz\n", FIR1_TransitionWidth_Hz / 1e6);
fprintf("  FIR1 taps:        %d\n", FIR1_NUM_TAPS);

fprintf("  FIR2 Fs in:       %.6f MHz\n", FIR2_FsIn_Hz / 1e6);
fprintf("  FIR2 Fs out:      %.6f MHz\n", FIR2_FsOut_Hz / 1e6);
fprintf("  FIR2 cutoff:      %.6f MHz\n", BW_DAB / 1e6);
fprintf("  FIR2 stopband:    %.6f MHz\n", FIR2_StopbandStart_Hz / 1e6);
fprintf("  FIR2 transition:  %.6f MHz\n", FIR2_TransitionWidth_Hz / 1e6);
fprintf("  FIR2 taps:        %d\n", FIR2_NUM_TAPS);


%% ============================================================
%  DEFINICJA BADANIA
%% ============================================================

study = struct();

study.name = "ADC aliasing - DAB+ BW_DAB study";
study.description = "Analog LPF -> ADC sampler -> CIC /2 -> FIR1 /2 -> FIR2 /2";


%% ============================================================
%  ADC
%% ============================================================

study.adc = block_adc_sd92xx( ...
    "Variant", ADC_VARIANT, ...
    "SampleRate_Hz", Fs_ADC_Hz, ...
    "OutputInterface", "CMOS" ...
);


%% ============================================================
%  TOR SYGNAŁOWY / CHAIN
%% ============================================================

study.stages = { ...

    block_analog_lpf( ...
        "Cutoff_Hz", ANALOG_LPF_CUTOFF_Hz, ...
        "Order", ANALOG_LPF_ORDER, ...
        "Model", ANALOG_LPF_MODEL ...
    ), ...

    block_adc_sampler(), ...

    block_cic_decimator( ...
        "Decimation", D_CIC, ...
        "Order", CIC_ORDER ...
    ), ...

    block_fir_decimator( ...
        "Name", "FIR1 wide transition decimator", ...
        "Decimation", D_FIR1, ...
        "NumTaps", FIR1_NUM_TAPS, ...
        "Cutoff_Hz", BW_DAB, ...
        "StopbandStart_Hz", FIR1_StopbandStart_Hz, ...
        "BoostEnabled", false, ...
        "BoostStart_Hz", 0.8 * BW_DAB, ...
        "BoostGain_dB", 0, ...
        "BoostTransitionWidth_Hz", 0.1e6, ...
        "PassbandRipple_dB", FIR1_PASSBAND_RIPPLE_dB, ...
        "StopbandAttenuation_dB", FIR1_STOPBAND_ATTENUATION_dB, ...
        "Method", "firls", ...
        "LinearPhase", FIR_LINEAR_PHASE ...
    ), ...

    block_fir_decimator( ...
        "Name", "FIR2 final anti-alias decimator", ...
        "Decimation", D_FIR2, ...
        "NumTaps", FIR2_NUM_TAPS, ...
        "Cutoff_Hz", BW_DAB, ...
        "StopbandStart_Hz", FIR2_StopbandStart_Hz, ...
        "BoostEnabled", false, ...
        "BoostStart_Hz", 0.8 * BW_DAB, ...
        "BoostGain_dB", 0, ...
        "BoostTransitionWidth_Hz", 0.1e6, ...
        "PassbandRipple_dB", FIR2_PASSBAND_RIPPLE_dB, ...
        "StopbandAttenuation_dB", FIR2_STOPBAND_ATTENUATION_dB, ...
        "Method", "firls", ...
        "LinearPhase", FIR_LINEAR_PHASE ...
    ) ...

};


%% ============================================================
%  ANALIZY / WYKRESY
%% ============================================================

study.analyses = {};

if RUN_FIR_REPORT
    study.analyses{end + 1} = analysis_fir_report( ...
        "Stage", "last_fir", ...
        "N", 200000 ...
    );
end

if RUN_ANALOG_ALIAS_DEBUG
    study.analyses{end + 1} = analysis_custom(@analog_alias_debug, ...
        "Name", "Analog frontend alias debug", ...
        "FMax_Hz", FMAX_ANALYSIS_Hz, ...
        "N", 200000, ...
        "Fs_ADC_Hz", Fs_ADC_Hz, ...
        "AliasBand_Hz", [0 BW_DAB], ...
        "DesiredBand_Hz", [0 BW_DAB], ...
        "YLim_dB", [-140 5] ...
    );
end

if RUN_STAGE_ALIAS_DEBUG
    study.analyses{end + 1} = analysis_custom(@stage_alias_debug, ...
        "Name", "Stage-by-stage alias debug", ...
        "N", 80000, ...
        "AliasBand_Hz", [0 BW_DAB], ...
        "DesiredBand_Hz", [0 BW_DAB], ...
        "YLim_dB", [-140 5] ...
    );
end

if RUN_ALIAS_MAP
    study.analyses{end + 1} = analysis_alias_map( ...
        "FMax_Hz", FMAX_ANALYSIS_Hz, ...
        "N", 300000, ...
        "AliasBand_Hz", [0 BW_DAB] ...
    );
end

if RUN_ALIAS_HEATMAP
    study.analyses{end + 1} = analysis_alias_heatmap( ...
        "FMax_Hz", FMAX_ANALYSIS_Hz, ...
        "N", 600000, ...
        "XBins", 1200, ...
        "YBins", 500, ...
        "AliasBand_Hz", [0 BW_DAB], ...
        "CLim_dB", [-140 5] ...
    );
end

if RUN_ALIAS_METRIC
    study.analyses{end + 1} = analysis_custom(@aliasing_metric_integrated, ...
        "Name", "Integrated aliasing metric", ...
        "FMax_Hz", FMAX_ANALYSIS_Hz, ...
        "N", 600000, ...
        "AliasBand_Hz", [0 BW_DAB], ...
        "DesiredBand_Hz", [0 BW_DAB] ...
    );
end


%% ============================================================
%  SPRAWDZENIE OPÓŹNIENIA GRUPOWEGO FILTRU ANALOGOWEGO
%% ============================================================

if RUN_ANALOG_GROUP_DELAY
    analog_gd = check_analog_group_delay( ...
        "Cutoff_Hz", ANALOG_LPF_CUTOFF_Hz, ...
        "Order", ANALOG_LPF_ORDER, ...
        "Model", ANALOG_LPF_MODEL, ...
        "Passband_Hz", [0 BW_DAB], ...
        "FMax_Hz", 3e6, ...
        "N", 50000, ...
        "MakePlots", true ...
    );
end


%% ============================================================
%  START SYMULACJI
%% ============================================================

result = run_study(study);


%% ============================================================
%  PODSUMOWANIE NA KOŃCU
%% ============================================================

fprintf("\n\n============================================================\n");
fprintf("FINAL RESULTS\n");
fprintf("============================================================\n");

fprintf("  BW base:         %.6f MHz\n", BW_Hz / 1e6);
fprintf("  BW DAB:          %.6f MHz\n", BW_DAB / 1e6);
fprintf("  n:               %d\n", n);
fprintf("  Fs ADC:          %.6f MHz\n", Fs_ADC_Hz / 1e6);
fprintf("  Fs OUT:          %.6f MHz\n", Fs_OUT_Hz / 1e6);
fprintf("  Nyquist OUT:     %.6f MHz\n", Fs_OUT_Hz / 2 / 1e6);
fprintf("  Total decim:     %d\n", D_TOTAL);
fprintf("  Analysis Fmax:   %.6f MHz\n", FMAX_ANALYSIS_Hz / 1e6);

fprintf("\nANALOG LPF\n");
fprintf("  Model:           %s\n", ANALOG_LPF_MODEL);
fprintf("  Order:           %d\n", ANALOG_LPF_ORDER);
fprintf("  Cutoff:          %.6f MHz\n", ANALOG_LPF_CUTOFF_Hz / 1e6);

if exist("analog_gd", "var")
    fprintf("\nANALOG LPF GROUP DELAY IN DAB BAND\n");
    fprintf("  Mean delay:      %.6f us\n", analog_gd.tau_mean_s * 1e6);
    fprintf("  Min delay:       %.6f us\n", analog_gd.tau_min_s * 1e6);
    fprintf("  Max delay:       %.6f us\n", analog_gd.tau_max_s * 1e6);
    fprintf("  Delay p-p:       %.6f us\n", analog_gd.tau_pp_s * 1e6);
end

fprintf("\nFILTER COST\n");
fprintf("  FIR1 taps:        %d\n", FIR1_NUM_TAPS);
fprintf("  FIR2 taps:        %d\n", FIR2_NUM_TAPS);
fprintf("  Total FIR taps:   %d\n", FIR1_NUM_TAPS + FIR2_NUM_TAPS);

for k = 1:numel(result.analysis_outputs)

    item = result.analysis_outputs{k};

    if isfield(item, "value") && isstruct(item.value)

        v = item.value;

        if isfield(v, "AliasRatio_dBc")
            fprintf("\n%s\n", string(item.name));
            fprintf("  Integrated alias ratio:   %.3f dBc\n", v.AliasRatio_dBc);
            fprintf("  Worst single alias point: %.3f dB\n", v.WorstAlias_dB);
            fprintf("  Alias input bandwidth:    %.3f MHz\n", v.AliasInputBandwidth_Hz / 1e6);
            fprintf("  Desired bandwidth:        %.3f MHz\n", v.DesiredBandwidth_Hz / 1e6);
            fprintf("  Interferer band:          %.3f...%.3f MHz\n", ...
                v.InterfererBand_Hz(1) / 1e6, ...
                v.InterfererBand_Hz(2) / 1e6);
        end

        if isfield(v, "table") && istable(v.table)
            if any(strcmp(v.table.Properties.VariableNames, "WorstAliasAttenuation_dB"))
                fprintf("\n%s\n", string(item.name));
                disp(v.table);
            end
        end

    end
end

fprintf("\n============================================================\n");