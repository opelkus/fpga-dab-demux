| Wymaganie | Tor                  |     Alias | Spadek pasma | DSP folded | Wniosek                       |
| --------- | -------------------- | --------: | -----------: | ---------: | ----------------------------- |
| 50 dB     | bez CIC: HB 7/7/27   | ~50.25 dB |    ~0.047 dB |          3 | bardzo płaski, ale więcej DSP |
| 50 dB     | CIC N=4 + HB 7/27    | ~52.45 dB |    ~0.478 dB |          2 | **najlepszy zasobowo**        |
| 75 dB     | bez CIC: HB 11/15/47 |  ~80.9 dB |     <0.01 dB |          5 | bardzo czysty, ale droższy    |
| 75 dB     | CIC N=5 + HB 11/43   |  ~75.7 dB |    ~0.547 dB |          3 | minimalny                     |
| 75 dB     | CIC N=5 + HB 15/47   |  ~80.0 dB |    ~0.538 dB |          3 | **najlepszy praktycznie**     |


| Parametr                               | A: ≥50 dB, bez CIC |       A: ≥50 dB, z CIC | B: ≥75 dB, bez CIC |        B: ≥75 dB, z CIC |
| -------------------------------------- | -----------------: | ---------------------: | -----------------: | ----------------------: |
| Tor decymacji                          |  HB7 → HB11 → HB31 | CIC×2 N=4 → HB7 → HB31 | HB11 → HB15 → HB51 | CIC×2 N=5 → HB15 → HB47 |
| Decymacja                              |           ×2 ×2 ×2 |               ×2 ×2 ×2 |           ×2 ×2 ×2 |                ×2 ×2 ×2 |
| Faza liniowa                           |                tak |                    tak |                tak |                     tak |
| Najgorszy aliasing                     |       **51.83 dB** |           **50.01 dB** |       **80.82 dB** |            **76.00 dB** |
| Margines względem wymagań              |           +1.83 dB |               +0.01 dB |           +5.82 dB |                +1.00 dB |
| Spadek w paśmie 0–800 kHz              |          0.0066 dB |               0.431 dB |          0.0011 dB |                0.538 dB |
| Ripple / nierówność pasma              |       0.032 dB p-p |           0.451 dB p-p |      0.0016 dB p-p |            0.538 dB p-p |
| Opóźnienie grupowe                     |          4.5625 µs |                4.25 µs |          7.4375 µs |              6.78125 µs |
| Opóźnienie w próbkach @2 MHz           |              9.125 |                    8.5 |             14.875 |                 13.5625 |
| Zmienne mnożenia FIR na próbkę końcową |                 22 |                     12 |                 33 |                      20 |
| DSP 18×18, folded MAC                  |              **3** |                  **2** |              **5** |                   **3** |
| Użycie DSP                             |              6.25% |                  4.17% |             10.42% |                   6.25% |
| CIC add/sub                            |                  0 |                      4 |                  0 |                       5 |
| CIC wewnętrzna szerokość               |                  — |            12 → 16 bit |                  — |             12 → 17 bit |
| Maks. akumulator FIR                   |            ~37 bit |                ~37 bit |            ~37 bit |                 ~38 bit |
| BRAM                                   |                  0 |                      0 |                  0 |                       0 |
| Szacowane LUT4 po syntezie             |           ~550–900 |               ~430–760 |          ~800–1300 |               ~700–1200 |
| Szacowane użycie LUT4                  |          ~2.7–4.3% |              ~2.1–3.7% |          ~3.9–6.3% |               ~3.4–5.8% |
| Szacowane FF po syntezie               |          ~650–1100 |              ~620–1050 |         ~1000–1600 |               ~950–1550 |
| Szacowane użycie FF                    |          ~4.2–7.1% |              ~4.0–6.8% |         ~6.4–10.3% |              ~6.1–10.0% |
