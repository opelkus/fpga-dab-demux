# Modułowa wersja badań aliasingu — Silanna SD92xx / SD9231

Projekt jest ustawiony tak, żeby `main.m` tylko uruchamiał wybrane badanie:

```matlab
study = study_aliasing_default();
result = run_study(study);
```

Najważniejszy plik do edycji to:

```text
study_aliasing_default.m
```

Są w nim dwie listy:

1. `study.stages` – klocki toru sygnałowego połączone w kolejności.
2. `study.analyses` – badania/wykresy wykonywane po zbudowaniu toru.

Domyślny tor:

```text
Analog LPF -> SD92xx/SD9231 ADC sampler -> CIC x4 -> FIR x3
```

Domyślne badania:

```text
raport FIR
alias map
alias heatmap
```

## ADC: nowa rodzina SD92xx / SD9231

```matlab
study.adc = block_adc_sd92xx( ...
    "Variant", "SD9231-20-A-QC9-TA", ...
    "SampleRate_Hz", 20e6, ...
    "OutputInterface", "CMOS" ...
);
```

`Variant` wybiera konkretny wariant szybkościowy, a `SampleRate_Hz` ustawia rzeczywistą częstotliwość próbkowania w badaniu. `SampleRate_Hz` nie może być większe niż wybrany speed grade.

Przykłady:

```matlab
% 12 bit / 20 MSPS — domyślny, wskazany wariant
study.adc = block_adc_sd92xx("Variant", "SD9231-20-A-QC9-TA");

% 12 bit / 80 MSPS
study.adc = block_adc_sd92xx("Variant", "SD9231-80-A-QC9-TA");

% 10 bit / 40 MSPS
study.adc = block_adc_sd92xx("ResolutionBits", 10, "SpeedGrade_MSps", 40);

% 14 bit / 65 MSPS
study.adc = block_adc_sd92xx("ResolutionBits", 14, "SpeedGrade_MSps", 65);

% 16 bit / 125 MSPS
study.adc = block_adc_sd92xx("Variant", "SD9268-125-A-QC9-TA");

% Wariant 20 MSPS, ale badanie pracuje z 5 MSPS
study.adc = block_adc_sd92xx( ...
    "Variant", "SD9231-20-A-QC9-TA", ...
    "SampleRate_Hz", 5e6 ...
);
```

Tabela wariantów jest w jednym pliku:

```text
adc_family_sd92xx_plural.m
```

Żeby wypisać aktualnie zasiane warianty:

```matlab
T = print_adc_sd92xx_family();
```

Jeżeli potrzebujesz dopisać kolejny konkretny orderable part, dodajesz jedną linię w `adc_family_sd92xx_plural.m`, np. w sekcji:

```matlab
family = add_exact_variants(family, "SD9231", 12, [20 40 65 80]);
```

## Dostępne klocki toru

### Analogowy LPF

```matlab
block_analog_lpf( ...
    "Cutoff_Hz", 10e3, ...
    "Order", 2, ...
    "Model", "butterworth" ...
)
```

### ADC sampler

```matlab
block_adc_sampler()
```

Ten klocek wstawia do toru częstotliwość próbkowania wybranego ADC. W dziedzinie częstotliwości ma odpowiedź równą 1, więc filtr antyaliasingowy trzeba modelować osobno jako `block_analog_lpf()`.

### CIC decimator

```matlab
block_cic_decimator( ...
    "Decimation", 4, ...
    "Order", 8 ...
)
```

### FIR decimator

```matlab
block_fir_decimator( ...
    "Name", "FIR x3 LPF", ...
    "Decimation", 3, ...
    "NumTaps", 67, ...
    "Cutoff_Hz", 10e3, ...
    "TransitionWidth_Hz", 10e3, ...
    "Method", "firls" ...
)
```

### Własny klocek

```matlab
block_custom_stage(@make_my_stage, ...
    "FsInSource", "previous", ...
    "MyParam", 123 ...
)
```

Funkcja `make_my_stage` powinna przyjmować `fs_in_Hz` jako pierwszy argument i zwracać strukturę `stage` z polami:

```matlab
stage.name
stage.fs_in_Hz
stage.fs_out_Hz
stage.response = @(f_Hz) ...
```

## Łączenie klocków

Domyślnie bloki cyfrowe mają:

```matlab
"FsInSource", "previous"
```

czyli ich częstotliwość wejściowa jest brana z poprzedniego cyfrowego bloku. Można też użyć:

```matlab
"FsInSource", "adc_raw"
"FsInSource", "adc_final"
"FsInSource", 425e3
```

## Dostępne badania

### Raport FIR

```matlab
analysis_fir_report("Stage", "last_fir", "N", 200000)
```

### Charakterystyka całego toru

```matlab
analysis_chain_response("FMax_Hz", 1.8e6, "N", 300000)
```

### Charakterystyka pojedynczego bloku

```matlab
analysis_stage_response("Stage", "last", "N", 16384)
```

### Wykres FIR

```matlab
analysis_fir_plot("Stage", "last")
```

### Alias map

```matlab
analysis_alias_map( ...
    "FMax_Hz", 1.8e6, ...
    "N", 300000, ...
    "AliasBand_Hz", [0 10e3] ...
)
```

### Alias colormap

```matlab
analysis_alias_colormap( ...
    "FMax_Hz", 1.8e6, ...
    "N", 300000, ...
    "AliasBand_Hz", [0 10e3], ...
    "CLim_dB", [-140 5] ...
)
```

### Alias heatmap

```matlab
analysis_alias_heatmap( ...
    "FMax_Hz", 1.8e6, ...
    "N", 600000, ...
    "XBins", 1200, ...
    "YBins", 500, ...
    "AliasBand_Hz", [0 10e3], ...
    "CLim_dB", [-140 5] ...
)
```

### Własne badanie

```matlab
analysis_custom(@my_analysis, "Name", "Moje badanie", "Param", 1)
```

Funkcja `my_analysis` powinna mieć postać:

```matlab
function out = my_analysis(chain, context, varargin)
    % chain   - zbudowany tor
    % context - ADC, limity, konfiguracja badania, poprzednie wyniki
    out = struct();
end
```

## Jak zrobić nowe badanie

1. Skopiuj `study_aliasing_default.m` jako np. `study_noise_test.m`.
2. Zmień `study.name`, `study.description`, `study.adc`, `study.stages` i `study.analyses`.
3. W `main.m` zmień jedną linię:

```matlab
study = study_noise_test();
```

4. Uruchom `main.m`.

## Przydatne selektory etapów

W analizach można wskazywać etap przez:

```matlab
"first"
"last"
"first_fir"
"last_fir"
"first_cic"
"last_cic"
"first_adc_sampler"
"last_adc_sampler"
```

Można też podać numer etapu, np.:

```matlab
analysis_stage_response("Stage", 3)
```

albo fragment nazwy etapu.
