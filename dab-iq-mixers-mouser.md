# Tanie mieszacze / demodulatory IQ do odbiornika DAB+

Aktualizacja: **2026-06-26**. Ceny i stany magazynowe pochodzą ze stron Mouser Polska i mogą się szybko zmieniać.

Założenie projektowe: odbiornik **DAB+ Band III 174–240 MHz**, mieszanie wybranego bloku do zera przez IQ, potem analogowy LPF antyaliasingowy, ADC i filtracja cyfrowa.

## Krótka lista — od najlepszego do najgorszego

| # | Układ | Cena 1 szt. | Stan Mouser | Krótki opis pod DAB+ |
|---:|---|---:|---:|---|
| 1 | [LT5546EUF#PBF](#lt5546eufpbf) — [Mouser](https://www.mouser.pl/ProductDetail/Analog-Devices/LT5546EUFPBF?qs=hVkxg5c3xu%252BvQM9NSK1D9Q%3D%3D) | 40,66 zł | 209 | Najlepszy wybór: demodulator IQ 40–500 MHz z VGA, tani, niski pobór prądu, idealny zakres dla DAB+. |
| 2 | [LT5506EUF#PBF](#lt5506eufpbf) — [Mouser](https://www.mouser.pl/ProductDetail/Analog-Devices/LT5506EUFPBF?qs=hVkxg5c3xu%252BnSaKH%252BJTOFQ%3D%3D) | 44,14 zł | 77 | Bardzo dobra alternatywa: demodulator IQ 40–500 MHz, tani i prosty. |
| 3 | [AD8348ARUZ-REEL7](#ad8348aruz-reel7) — [Mouser](https://www.mouser.pl/ProductDetail/Analog-Devices/AD8348ARUZ-REEL7?qs=%2FtpEQrCGXCx%2FRvZyU1EheA%3D%3D) | 61,91 zł | 63 | Dobry demodulator IQ 50 MHz–1 GHz; wygodny zakres, trochę droższy. |
| 4 | [AD8348ARUZ](#ad8348aruz) — [Mouser](https://www.mouser.pl/ProductDetail/Analog-Devices/AD8348ARUZ?qs=%2FtpEQrCGXCy3u%2Fm%2FZroFwg%3D%3D) | 61,91 zł | 18 | Ten sam sens co REEL7, ale mniej sztuk na stanie; opakowanie tube. |
| 5 | [LT5517EUF#PBF](#lt5517eufpbf) — [Mouser](https://www.mouser.pl/ProductDetail/Analog-Devices/LT5517EUFPBF?qs=hVkxg5c3xu%252B5rTNIicAYTQ%3D%3D) | 89,46 zł | 104 | Dobry technicznie demodulator 40–900 MHz, ale droższy i bardziej prądożerny. |
| 6 | [ADL5387ACPZ-R7](#adl5387acpz-r7) — [Mouser](https://www.mouser.pl/ProductDetail/Analog-Devices/ADL5387ACPZ-R7?qs=BpaRKvA4VqGQ7woK15iRbg%3D%3D) | 59,43 zł | 81 | Szerokopasmowy demodulator 30 MHz–2 GHz; działa, ale jest overkill do DAB+ i bierze dużo prądu. |
| 7 | [LT5502EGN#PBF](#lt5502egnpbf) — [Mouser](https://www.mouser.pl/ProductDetail/Analog-Devices/LT5502EGNPBF?qs=hVkxg5c3xu8uqHpbqjgq9A%3D%3D) | 60,23 zł | 4 | Zakres 70–400 MHz pasuje do DAB+, ale stan jest bardzo niski. |
| 8 | [ADRF6850BCPZ](#adrf6850bcpz) — [Mouser](https://www.mouser.pl/ProductDetail/Analog-Devices/ADRF6850BCPZ?qs=WIvQP4zGanhitN%252B3d2%252BYqw%3D%3D) | 110,84 zł | 620 | Zintegrowany szerokopasmowy układ odbiorczy/demodulator; ciekawy, ale drogi, złożony i prądożerny. |
| 9 | [AD8333ACPZ-WP](#ad8333acpz-wp) — [Mouser](https://www.mouser.pl/ProductDetail/Analog-Devices/AD8333ACPZ-WP?qs=%2FtpEQrCGXCwhOxX%252B643MWg%3D%3D) | 93,70 zł | 145 | Nie nadaje się bezpośrednio na 174–240 MHz; max 50 MHz, więc wymaga pierwszego mieszania na niższe IF. |
| 10 | [ADL5385ACPZ-R7](#adl5385acpz-r7) — [Mouser](https://www.mouser.pl/ProductDetail/Analog-Devices/ADL5385ACPZ-R7?qs=BpaRKvA4VqG4OwtCMETyCw%3D%3D) | 57,12 zł | 367 | To modulator, nie demodulator odbiorczy; zły kierunek sygnału dla naszego RX. |
| 11 | [TRF370417IRGET](#trf370417irget) — [Mouser](https://www.mouser.pl/ProductDetail/Texas-Instruments/TRF370417IRGET?qs=%252BneE8T2%2Fs3ROM8TeFBefqw%3D%3D) | 96,81 zł | 314 | Też modulator, nie demodulator; dobry do TX, nie do odbiornika DAB+. |

Duplikaty z listy wejściowej zostały scalone: **LT5517EUF#PBF** i **AD8333ACPZ-WP** pojawiły się dwa razy.

---

<a id="lt5546eufpbf"></a>
## 1. LT5546EUF#PBF

**Typ:** demodulator IQ / VGA + I/Q demodulator  
**Zakres wg Mousera:** 40–500 MHz  
**Zasilanie / prąd wg Mousera:** 1,8–5,25 V, ok. 24 mA  
**Cena / stan:** 40,66 zł, 209 szt.

To jest mój pierwszy wybór do naszego odbiornika DAB+. Pasmo DAB+ 174–240 MHz leży dobrze wewnątrz zakresu układu, a opis Mousera wskazuje na połączenie VGA i demodulatora I/Q. To jest bardzo przydatne, bo w odbiorniku DAB+ problemem bywa duża różnica poziomów między lokalnym multipleksem a słabymi sygnałami.

**Zalety:**

- najlepsza relacja cena/funkcja z tej listy;
- zakres 40–500 MHz dobrze obejmuje DAB Band III;
- niski pobór prądu;
- VGA może pomóc w ustawieniu poziomu przed ADC;
- QFN-16 jest mały, ale jeszcze do opanowania na sensownej płytce RF.

**Wady:**

- wymaga porządnego layoutu RF, symetrii torów I/Q i dobrej masy;
- QFN jest mniej przyjazny ręcznemu montażowi niż TSSOP/SSOP;
- nadal potrzebujesz zewnętrznego LO oraz analogowych LPF dla I/Q.

**Wniosek:** najlepszy kandydat do pierwszego prototypu DAB+.

---

<a id="lt5506eufpbf"></a>
## 2. LT5506EUF#PBF

**Typ:** demodulator kwadraturowy IQ  
**Zakres wg Mousera:** 40–500 MHz  
**Zasilanie / prąd wg Mousera:** 1,8–5,25 V, ok. 26,5 mA  
**Cena / stan:** 44,14 zł, 77 szt.

Bardzo dobry, prosty kandydat do bezpośredniego mieszania DAB+ do pasma bazowego. Zakres częstotliwości pasuje praktycznie idealnie: obejmuje całe Band III, a nie jest przesadnie szeroki.

**Zalety:**

- tani;
- niskoprądowy;
- zakres 40–500 MHz jest dobrze dobrany pod DAB+;
- prostszy wybór niż szerokopasmowe układy 2 GHz+;
- dobra alternatywa, gdy LT5546 nie jest dostępny.

**Wady:**

- mniejsza funkcjonalność niż LT5546;
- również QFN-16, więc layout i montaż wymagają uwagi;
- bez cyfrowego sterowania — regulację poziomów trzeba rozwiązać osobno w torze RF/IF/ADC.

**Wniosek:** bardzo rozsądny wybór, jeżeli chcesz prosty i tani demodulator IQ.

---

<a id="ad8348aruz-reel7"></a>
## 3. AD8348ARUZ-REEL7

**Typ:** demodulator kwadraturowy IQ  
**Zakres wg Mousera:** 50 MHz–1 GHz  
**Zasilanie / prąd wg Mousera:** 2,7–5,5 V, ok. 48 mA  
**Cena / stan:** 61,91 zł, 63 szt.  
**Opakowanie:** reel / cut tape / MouseReel

AD8348 jest dobrym klasycznym demodulatorem IQ. DAB+ leży daleko od granic jego zakresu, więc częstotliwościowo pasuje bez problemu. Jest droższy od LT5546 i LT5506, ale nadal sensowny.

**Zalety:**

- duży zapas częstotliwości: 50 MHz–1 GHz;
- umiarkowany pobór prądu;
- TSSOP-28 jest przyjemniejszy prototypowo niż małe LFCSP/QFN;
- dobry kandydat, jeśli zależy nam na łatwiejszym montażu i dostępności dokumentacji.

**Wady:**

- droższy niż LT5546/LT5506;
- większa obudowa;
- nie daje tak atrakcyjnej relacji cena/funkcja jak LT5546;
- nadal wymaga dobrego LO, filtrów I/Q i pilnowania balansu ścieżek.

**Wniosek:** dobry wybór, jeśli priorytetem jest wygodniejszy montaż i klasyczna, przewidywalna topologia.

---

<a id="ad8348aruz"></a>
## 4. AD8348ARUZ

**Typ:** demodulator kwadraturowy IQ  
**Zakres wg Mousera:** 50 MHz–1 GHz  
**Zasilanie / prąd wg Mousera:** 2,7–5,5 V, ok. 48 mA  
**Cena / stan:** 61,91 zł, 18 szt.  
**Opakowanie:** tube

To zasadniczo ten sam wybór techniczny co AD8348ARUZ-REEL7, ale w innym pakowaniu i z mniejszą liczbą sztuk na stanie.

**Zalety:**

- dobre dopasowanie do DAB+;
- TSSOP-28 ułatwia prototypowanie;
- sensowny pobór prądu;
- opakowanie tube może być wygodne przy ręcznym montażu kilku sztuk.

**Wady:**

- niski stan magazynowy względem wersji REEL7;
- cena wyższa niż LT5546/LT5506;
- brak przewagi funkcjonalnej nad wersją REEL7.

**Wniosek:** brać tylko wtedy, gdy konkretnie pasuje pakowanie tube albo REEL7 jest niedostępny.

---

<a id="lt5517eufpbf"></a>
## 5. LT5517EUF#PBF

**Typ:** demodulator kwadraturowy IQ  
**Zakres wg Mousera:** 40–900 MHz  
**Zasilanie / prąd wg Mousera:** 4,5–5,25 V, ok. 90 mA  
**Cena / stan:** 89,46 zł, 104 szt.

LT5517 jest technicznie pasujący do DAB+ i ma większy zapas częstotliwości niż LT5546/LT5506. Problemem jest cena i pobór prądu. Do prostego odbiornika DAB+ nie daje wystarczająco dużej przewagi, żeby był pierwszym wyborem.

**Zalety:**

- zakres 40–900 MHz komfortowo obejmuje DAB+;
- dobry zapas na inne pasma VHF/UHF;
- sensowny wybór, jeśli chcesz zostać przy rodzinie układów LT/Analog Devices;
- dostępność jest lepsza niż przy LT5502.

**Wady:**

- wyraźnie droższy;
- pobór prądu ok. 90 mA jest kilka razy większy niż LT5546/LT5506;
- nadal QFN-16;
- do samego DAB+ jest trochę przesadzony.

**Wniosek:** dobry, ale nieoptymalny cenowo. Warto rozważyć, jeśli LT5546/LT5506 odpadają.

---

<a id="adl5387acpz-r7"></a>
## 6. ADL5387ACPZ-R7

**Typ:** demodulator kwadraturowy IQ  
**Zakres wg Mousera:** 30 MHz–2 GHz  
**Zasilanie / prąd wg Mousera:** 4,75–5,25 V, ok. 180 mA  
**Cena / stan:** 59,43 zł, 81 szt.

ADL5387 częstotliwościowo bez problemu obejmuje DAB+. Jest też dość atrakcyjny cenowo jak na układ szerokopasmowy. Problem: pobór prądu i obudowa LFCSP-24. Do DAB+ nie potrzebujemy 2 GHz, więc płacimy złożonością i prądem za zakres, którego nie wykorzystamy.

**Zalety:**

- bardzo szeroki zakres częstotliwości;
- DAB+ leży daleko od granic zakresu;
- cena 1 szt. nie jest zła;
- dobry wybór, jeśli jeden projekt ma później obsłużyć też wyższe pasma.

**Wady:**

- duży pobór prądu: ok. 180 mA;
- LFCSP-24 wymaga starannego PCB i montażu;
- overkill do odbiornika tylko DAB+;
- większe wymagania dla zasilania, odsprzęgania i layoutu RF.

**Wniosek:** działa, ale nie jest najładniejszym wyborem do taniego, prostego DAB+.

---

<a id="lt5502egnpbf"></a>
## 7. LT5502EGN#PBF

**Typ:** demodulator kwadraturowy IF z RSSI  
**Zakres wg Mousera:** 70–400 MHz  
**Zasilanie / prąd wg Mousera:** 1,8–5,25 V, ok. 25 mA  
**Cena / stan:** 60,23 zł, 4 szt.

Technicznie zakres obejmuje DAB+ Band III, więc układ może działać w naszej aplikacji. Ma też niski pobór prądu i RSSI, co jest przydatne. Główny problem to bardzo niski stan magazynowy.

**Zalety:**

- zakres 70–400 MHz obejmuje DAB+;
- niski pobór prądu;
- RSSI może być przydatne do AGC lub diagnostyki poziomu sygnału;
- SSOP-24 jest wygodniejszy niż QFN/LFCSP.

**Wady:**

- tylko 4 sztuki na stanie w momencie sprawdzania;
- cena wyższa niż LT5546/LT5506;
- mniejszy zapas częstotliwości niż AD8348/LT5517;
- ryzyko projektowe związane z dostępnością.

**Wniosek:** ciekawy technicznie, ale zbyt słaba dostępność jak na główny wybór do repo/BOM.

---

<a id="adrf6850bcpz"></a>
## 8. ADRF6850BCPZ

**Typ:** zintegrowany szerokopasmowy demodulator / układ odbiorczy  
**Opis Mousera:** 100 MHz–1 GHz integrated wideband  
**Tabela Mousera:** max frequency 22,5 MHz, interfejs I2C/SPI  
**Zasilanie / prąd wg Mousera:** 3,15–3,45 V, ok. 350 mA  
**Cena / stan:** 110,84 zł, 620 szt.

To nie jest prosty tani mieszacz IQ, tylko bardziej zintegrowany układ odbiorczy. Może być ciekawy, bo obejmuje DAB+ i ma sterowanie cyfrowe, ale dla prostego własnego toru IQ jest za ciężki: drogi, prądożerny i wymaga konfiguracji przez I2C/SPI.

**Zalety:**

- bardzo dobra dostępność;
- obejmuje interesujący nas zakres RF według opisu produktu;
- integracja może uprościć część toru RF, jeśli zaakceptujemy bardziej złożony układ;
- sterowanie cyfrowe może być zaletą w bardziej ambitnym odbiorniku.

**Wady:**

- najdroższy z sensownych układów odbiorczych na liście;
- bardzo duży pobór prądu: ok. 350 mA;
- LFCSP-56 jest trudny w prototypowaniu;
- wymaga konfiguracji cyfrowej i bardziej rozbudowanego firmware;
- nie jest prostym zamiennikiem klasycznego pasywnego/aktywnego demodulatora IQ.

**Wniosek:** dobry do bardziej zintegrowanego odbiornika, słaby wybór do taniego prostego front-endu DAB+.

---

<a id="ad8333acpz-wp"></a>
## 9. AD8333ACPZ-WP

**Typ:** podwójny demodulator IQ  
**Zakres wg Mousera:** 0–50 MHz  
**Zasilanie / prąd wg Mousera:** 5 V, ok. 44 mA  
**Cena / stan:** 93,70 zł, 145 szt.

AD8333 nie nadaje się do bezpośredniego mieszania DAB+ z 174–240 MHz do zera, bo jego zakres kończy się na 50 MHz. Może mieć sens tylko w architekturze superheterodynowej, gdzie najpierw zewnętrznym mieszaczem przesuwamy DAB+ na IF poniżej 50 MHz, a AD8333 robi dopiero drugą demodulację IQ.

**Zalety:**

- podwójny demodulator IQ;
- dobra dostępność;
- może być użyteczny przy architekturze z niskim IF;
- sensowny, jeśli projekt już ma pierwszy mieszacz RF → IF.

**Wady:**

- nie obejmuje DAB+ RF bezpośrednio;
- wymaga dodatkowego mieszacza i dodatkowego LO;
- robi projekt bardziej skomplikowany niż potrzeba;
- cena jest wysoka jak na układ, który nie rozwiązuje głównego problemu.

**Wniosek:** nie do prostego bezpośredniego DAB+ IQ. Tylko do wariantu z dodatkową przemianą częstotliwości.

---

<a id="adl5385acpz-r7"></a>
## 10. ADL5385ACPZ-R7

**Typ:** modulator kwadraturowy  
**Zakres wg Mousera:** 30 MHz–2,2 GHz  
**Zasilanie / prąd wg Mousera:** 4,75–5,5 V, ok. 215 mA  
**Cena / stan:** 57,12 zł, 367 szt.

ADL5385 jest modulatorem, czyli działa w przeciwnym kierunku niż potrzebujemy w odbiorniku. Bierze I/Q baseband i tworzy RF. Do naszego toru `antena → RF → IQ → ADC` nie pasuje jako główny układ mieszający.

**Zalety:**

- dobry zakres częstotliwości dla DAB+ po stronie RF;
- dobra cena jak na szerokopasmowy modulator;
- wysoka dostępność;
- mógłby być przydatny w torze nadawczym/testowym.

**Wady:**

- zły kierunek sygnału dla odbiornika;
- wysoki pobór prądu;
- LFCSP-24;
- nie zastępuje demodulatora IQ.

**Wniosek:** nie wybierać do odbiornika DAB+. Ewentualnie zostawić do generatora/testowego TX IQ.

---

<a id="trf370417irget"></a>
## 11. TRF370417IRGET

**Typ:** modulator kwadraturowy  
**Zakres wg Mousera:** 50 MHz–6 GHz  
**Zasilanie / prąd wg Mousera:** 4,5–5,5 V, ok. 205 mA  
**Cena / stan:** 96,81 zł, 314 szt.

TRF370417IRGET to również modulator, nie demodulator. Częstotliwościowo obejmuje DAB+, ale funkcjonalnie jest przeznaczony do generowania RF z sygnałów I/Q, nie do odbierania RF i wyciągania I/Q.

**Zalety:**

- bardzo szeroki zakres częstotliwości;
- dobra dostępność;
- może być przydatny w torze nadawczym, generatorze testowym albo eksperymentach z modulacją IQ.

**Wady:**

- zły kierunek dla odbiornika;
- drogi;
- duży pobór prądu;
- VQFN-24;
- nie rozwiązuje problemu odbioru DAB+.

**Wniosek:** nie do naszego RX DAB+. Dobry kandydat tylko do osobnego toru TX/testowego.

---

## Rekomendacja końcowa

Do pierwszej wersji hardware wybrałbym:

1. **LT5546EUF#PBF** jako główny wariant.
2. **LT5506EUF#PBF** jako tańszy/prostszy fallback.
3. **AD8348ARUZ-REEL7** jako wariant wygodniejszy montażowo.

Unikałbym w głównym odbiorniku:

- **ADL5385ACPZ-R7** i **TRF370417IRGET**, bo to modulatory;
- **AD8333ACPZ-WP**, bo nie obejmuje DAB+ RF bezpośrednio;
- **ADRF6850BCPZ**, chyba że świadomie przechodzimy na bardziej zintegrowany i programowo sterowany front-end.

Praktyczny tor dla rekomendowanych układów:

```text
antena VHF
→ filtr pasmowy DAB Band III
→ opcjonalny tłumik / LNA
→ demodulator IQ, LO = środek bloku DAB+
→ analogowe LPF I/Q około 2,3 MHz przy Fs = 6,144 MS/s
→ ADC I/Q
→ cyfrowy FIR kanałowy ±768 kHz
→ dekoder DAB+
```
