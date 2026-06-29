# FFT 2048 complex – planowane zużycie zasobów i architektura

## Cel

Rdzeń realizuje **zespolone FFT 2048 punktów** dla wejścia:

- `I`: signed 16 bit
- `Q`: signed 16 bit
- tryb pracy: ramkowy
- okres ramki: około **1 ms**
- wymagany czas przetwarzania jednej ramki: **≤ 500 µs**
- docelowe FPGA: **Sipeed Tang Nano 20K / Gowin GW2AR-18**

Założona częstotliwość zegara rdzenia: **50 MHz**.

## Architektura

Zastosowana architektura to **blokowe, iteracyjne FFT radix-2 DIT** z prostym potokowaniem ramkowym:

```text
capture buffer A  ← zbiera ramkę n+1
FFT engine        ← liczy ramkę n z bufora B
po zakończeniu    ← zamiana buforów A/B
```

Nie jest to pełne streaming FFT typu SDF/MDC. Jest to lżejsza architektura ramkowa, dobrana pod małe zużycie zasobów.

## Główne bloki

| Blok | Funkcja |
|---|---|
| Podwójny bufor wejściowy | Zbieranie nowej ramki podczas liczenia poprzedniej |
| FFT RAM ping-pong | Pamięć robocza dla kolejnych etapów FFT |
| Jeden silnik butterfly | Jeden radix-2 butterfly na takt w fazie obliczeń |
| Twiddle ROM | Tablica współczynników `W_N^k` dla FFT 2048 |
| Complex multiplier | 4 mnożniki 18×18 dla mnożenia zespolonego |
| Sterownik etapów | Licznik stage/group/pair dla 11 etapów radix-2 |
| Output sequencer | Wypisywanie 2048 wyników po zakończeniu FFT |

## Przepływ danych

```text
16-bit I/Q input
  ↓
double frame buffer: 2 × 2048 × 32 bit
  ↓
FFT working RAM / ping-pong
  ↓
radix-2 butterfly engine
  ↓
twiddle multiply, Q1.17
  ↓
scaling /2 per stage
  ↓
16-bit I/Q output
```

Wynik jest skalowany przez wszystkie 11 etapów:

```text
output ≈ FFT(input) / 2048
```

Skalowanie `/2` po każdym etapie ogranicza ryzyko overflow i pozwala utrzymać 16-bitowy format wyjściowy.

## Czas wykonania

Dla zegara **50 MHz**:

| Parametr | Wartość |
|---|---:|
| Cykle na 1 ms | 50 000 |
| Załadowanie 2048 próbek do FFT RAM | ~2048 cykli |
| Obliczenie FFT | ~11 297 cykli |
| Wypisanie 2048 wyników | ~2049 cykli |
| Razem przetwarzanie ramki | ~15 400 cykli |
| Czas przetwarzania ramki | ~308 µs |
| Zapas względem 1 ms | ~692 µs |
| Zapas względem limitu 500 µs | ~192 µs |

Wniosek: rdzeń powinien spełnić wymaganie **FFT 2048 w czasie ≤ 500 µs** przy zegarze 50 MHz.

## Planowane zużycie zasobów

Szacunek dla Tang Nano 20K / GW2AR-18. Wartości LUT/FF są orientacyjne, ponieważ dokładny wynik zależy od syntezy Gowin EDA, inferencji BSRAM, pipeline’u i floorplanu.

| Zasób | Szacunek | Procent układu |
|---|---:|---:|
| DSP 18×18 | **4 / 48** | **~8.3%** |
| BSRAM | **~26 / 46** | **~56.5%** |
| LUT4 | **~2700–5000 / 20736** | **~13–24%** |
| FF | **~2000–3600 / 15552** | **~13–23%** |

## Rozbicie pamięci

| Pamięć | Rozmiar logiczny | Szacowane BSRAM |
|---|---:|---:|
| FFT RAM, replikowana dla dwóch odczytów/zapisów | 4 × 2048 × 36 bit | ~16 BSRAM |
| Twiddle ROM | 1024 × 36 bit | ~2 BSRAM |
| Podwójny bufor wejściowy | 2 × 2048 × 32 bit | ~8 BSRAM |
| Razem | ~463 kbit | **~26 BSRAM** |

## Rozbicie arytmetyki

| Blok | Zasoby |
|---|---:|
| Complex multiply | 4 DSP 18×18 |
| Butterfly add/sub | logika LUT/carry-chain |
| Skalowanie etapowe | przesunięcia arytmetyczne |
| Saturacja/rounding | logika LUT |
| Sterowanie FSM/liczniki | LUT + FF |

## Dlaczego nie pełne FFT potokowe

Pełne FFT streamingowe, np. SDF/MDC, pozwala przyjmować próbkę praktycznie co takt, ale zużywa znacznie więcej DSP, rejestrów i pamięci opóźniających. Dla ramek przychodzących co **1 ms** nie jest to potrzebne.

Lepszy kompromis dla Tang Nano 20K:

```text
ramkowy ping-pong buffer + pojedynczy silnik butterfly
```

Daje to małe użycie DSP, przewidywalny czas wykonania i wystarczający zapas czasowy.

## Najważniejsze ryzyka implementacyjne

1. **Inferencja BSRAM**  
   Trzeba sprawdzić w raporcie Gowin EDA, czy pamięci RAM/ROM zostały umieszczone w BSRAM, a nie w LUT.

2. **Timing complex multiplier**  
   Przy 50 MHz powinno być łatwo, ale warto zostawić rejestry pipeline wokół mnożników DSP.

3. **Format wyniku**  
   Wynik jest skalowany jako `FFT/2048`. Jeżeli potrzebne jest nieskalowane FFT, szerokość danych musi wzrosnąć o około 11 bitów.

4. **Kolejność binów**  
   Iteracyjne radix-2 DIT może wymagać uwzględnienia kolejności bit-reversal na wejściu albo wyjściu, zależnie od dokładnej wersji sterownika.

## Wniosek

Planowany rdzeń FFT 2048 complex powinien zmieścić się na Sipeed Tang Nano 20K z dużym zapasem logiki i DSP, ale z istotnym użyciem pamięci BSRAM.

Najważniejsze liczby:

```text
czas ramki @50 MHz:  ~308 µs
DSP:                 4 / 48
BSRAM:               ~26 / 46
LUT4:                ~2700–5000
FF:                  ~2000–3600
```
