#import "../utils.typ": todo, silentheading, flex-caption

= Przeprowadzone eksperymenty i analiza ich wyników <experiments-and-analysis>
Głównym celem niniejszego rozdziału jest empiryczna weryfikacja skuteczności zaproponowanego rozwiązania BiGRU z mechanizmem atencji i porównanie jego osiągów do modelu bazowego Random Forest. W trosce o maksymalną reprodukowalność eksperymentów ziarna losowości (ang. _random seeds_) bibliotek `torch`, `numpy` i `random` zostały ustalone na stałą wartość, co w połączeniu z udokumentowaną konfiguracją środowiska (wersjami bibliotek) pozwoli innym badaczom na replikację poniżej przedstawionych wyników.

== Spis przeprowadzonych eksperymentów <experiments-list>
Oto proces badawczy utworzony z przeprowadzonych eksperymentów:
+ *Ustawienie punktu odniesienia dla proponowanej architektury sieci głębokiej*: Oddzielny trening klasyfikatora Random Forest na zbiorach @silesian oraz @real_life_ddd. Głównym celem było wyznaczenie dolnej granicy skuteczności oraz punktu odniesienia dla sieci BiGRU + Attention. Celem pobocznym było wykorzystanie wbudowanej w drzewa decyzyjne analizy ważności cech (ang. _feature importance_), aby zrozumieć, które sygnały są najbardziej informatywne.
+ *Weryfikacja techniczna (_Overfit Check_)*: Przed uruchomieniem pełnego treningu, został przeprowadzony test przeuczenia. Sieć została wytrenowana na pojedynczej paczce danych (16 próbkach) w celu potwierdzenia poprawności architektury modelu oraz zbieżności funkcji straty.
+ *Ewaluacja modelu autorskiego*: Pełny trening proponowanej sieci na zbiorze @silesian. W ramach tego eksperymentu przeprowadzono także analizę krzywych uczenia (ang. _learning curves_), histogramu prawdopodobieństwa oraz macierzy pomyłek wygenerowanych na podstawie inferencji na zbiorze testowym.
+ *Badanie zdolności generalizacji*: Dotrenowanie modelu na zbiorze danych @real_life_ddd z wykorzystaniem techniki transferu wiedzy (ang. _transfer learning_), a w tym także porównanie skuteczności przed (zero-shot) i po dotrenowaniu oraz analiza katastroficznego zapominania (ang. _catastrophic forgetting_) na zbiorze oryginalnym.

== Analiza skuteczności modelu bazowego i ważności cech <baseline-analysis>
Wyniki przedstawione w #link(<rf-results-comparison>)[poniższej tabeli] zostały uzyskane z modelu Random Forest wytrenowanego na zagregowanych sekwencjach (średnia arytmetyczna, odchylenie standardowe, maksimum i zakres wartości) ze zbiorów @silesian i @real_life_ddd.

#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    inset: 10pt,
    align: horizon,
    fill: (_, row) => if row == 0 { luma(240) },
    table.header(
      [*Metryka*], [*@silesian*], [*@real_life_ddd*]
    ),
    table.hline(),
    [Accuracy], [0.7184], [0.7851],
    [F1 Score], [0.8343], [0.7451],
    [AUC Score], [0.6393], [0.9063],
    table.hline(),
  ),
  caption: [Porównanie skuteczności modelu na zbiorach Silesian i Real Life],
) <rf-results-comparison>

Wyniki uzyskane na zbiorze @silesian są idealnym przykładem modelu Random Forest wytrenowanego na niezbalansowanym zbiorze danych. Stosunkowo wysokie accuracy oraz F1 Score wskazują na dobrze wytrenowany model. Jednak niskie AUC sugeruje, że las losowy ma trudność z rozróżnianiem klas. Model prawdopodobnie nauczył się większości próbek dawać etykietę pozytywną, bo taki jest rozkład danych. Poza problem niezbalansowanych klas, nagrania z tego zbioru pochodzą z laboratorium, co wpływa na zawarte w nich kłamstwa. Niska stawka i brak realnych konsekwencji sprawiają, że sygnały (takie jak m.in. mikroekspresje i wycieki emocjonalne) są słabe i trudne do zauważenia przez algorytm mimo idealnej jakości nagrań.

Dla kontrastu, Random Forest poradził sobie znakomicie na zbiorze rzeczywistych nagrań z sal sądowych @real_life_ddd, pomimo gorszej ich jakości technicznej. Bardzo wysokie AUC oznacza, że model świetnie separuje prawdę od kłamstwa. Wskazuje to, że w warunkach sali sądowej, gdzie ludzie często kłamiąc walczą o swoją przyszłość, mimowolne reakcje mimiczne i inne zachowania powiązane z kłamstwem są na tyle silne, że przebijają się przez szum słabszej jakości nagrania. Ponieważ zbiór ten jest idealnie zbalansowany, accuracy na poziomie 78,5% jest bardzo dobrym wynikiem dla tak prostego modelu.

Eksperyment sugeruje, że kłamstwo naturalne wiąże się z zupełnie innym zachowaniem niż kłamstwo wymuszone. Random Forest o wiele lepiej radzi sobie z klasyfikacją nagrań zawierających kłamstwa high-stakes, chociaż imbalans klas w zbiorze @silesian mógł mocno wpłynąć na działanie modelu wytrenowanego na jego nagraniach.

=== Analiza ważności cech <feature-importance-analysis>
Drugim celem eksperymentu z modelem bazowym była analiza ważności cech, która pozwoliła zidentyfikować najbardziej kluczowe behawioralne wyznaczniki kłamstwa. Jak przedstawiono na poniższych wykresach, rankingi najważniejszych cech dla obu zbiorów drastycznie się różnią, co potwierdza fundamentalne różnice w naturze kłamstwa wymuszonego i rzeczywistego.

W przypadku zbioru @real_life_ddd, proces podejmowania predykcji został zdominowany przez cechy związane z ruchami głowy (grupa cech `head_pose`), co zostało ukazane na wykresie oznaczonym jako @rl-feature-importance. Aż 6 z 10 najważniejszych cech dotyczy rotacji głowy (`head_yaw` opisujące ruch przeczący "nie" oraz `head_roll`). Istotne okazały się miary zmienności (odchylenie standardowe i zakres wartości). Na podstawie tego można stwierdzić, że w rzeczywistych sytuacjach kłamstwa _high-stakes_, nieszczerości towarzyszą silne, dynamiczne ruchy głowy. Kłamcy prawdopodobnie nieświadomie swoimi ruchami głowy zaprzeczają wypowiadanym słowom.

#figure(
  image("../images/feature_importance/real_life.png", 
  width: 100%
  ), 
  caption: [Ważność cech: Zbiór @real_life_ddd.], 
) <rl-feature-importance>

Ważność cech dla zbioru @silesian jest zupełnie odmienna. Tutaj ważności cech z różnych kategorii są mocno przemieszane. W 10 najważniejszych sygnałach znalazły się:
- parametry geometryczne ramki twarzy (`Box_Center_Y`, `Box_Width`) oraz cechy obrazujące ogólny ruch między klatkami, co w przypadku nagrań ze statycznej kamery i z jednolitym tłem wskazuje na zmianę postury ciała - wiercenie się na krześle, pochylanie w przód-tył i ogólnie wysoką ruchowość ciała,
- cechy związane z mimiką (`Mouth`, `Eye` i `Brow`), być może wskazujące mikroekspresje.
Sugeruje to, że w warunkach laboratoryjnych, kłamstwa _low-stakes_ nie objawiają się gwałtownymi reakcjami, lecz raczej subtelnymi zmianami pozycji ciała i mikroekspresjami, które są trudniejsze dla prostego modelu do jednoznacznej klasyfikacji, o czym świadczą również #link(<rf-results-comparison>)[wyżej przedstawione metryki].

#figure( 
  image("../images/feature_importance/silesian.png", 
  width: 100%
  ), 
  caption: [Ważność cech: Zbiór @silesian.], 
) <sddd-feature-importance>

== Weryfikacja techiczna modelu autorskiego (_Overfit Check_) <overfit-check>
Implementacja złożonych sieci neuronowych jest podatna na błędy, które nie uniemożliwiają uruchomienie kodu, ale uniemożliwiają skuteczny trening modelu. Do takich niedopatrzeń zaliczają się m.in.: złe wymiary warstw, nieprawidłowe połączenia między nimi oraz problemy z paddowaniem. Najłatwiejszym sposobem na ich wykrycie jest testowy trening na małym podzbiorze danych. Takie podejście trwa zaledwie kilka sekund i od razu można stwierdzić, czy implementacja modelu jest poprawna.

W tym celu, wytrenowano autorski model BiGRU z mechanizmem atencji z użyciem pojedynczej paczki danych (_batch_) ze zbioru treningowego, składającej się z 16 próbek. Taki trening powinien doprowadzić do całkowitego przeuczenia. Prawidłowo zaimplementowana architektura posiadająca tysiące trenowalnych parametrów powinna bez żadnego problemu zapamiętać tak małą ilość danych osiągając idealną skuteczność na paczce użytej do treningu.

#figure( 
  image("../images/training/overfit_check.png", 
  width: 100%
  ), 
  caption: [Krzywe uczenia uzyskane w procesie _Overfit Check_], 
) <overfit-check-learning-curve>

Jak przedstawiono na #link(<overfit-check-learning-curve>)[powyższej krzywej uczenia], model bardzo szybko zredukował stratę do wartości bliskich zeru (w 100 epok). Wszystkie próbki zostały bezbłednie sklasyfikowane, o czym świadczy accuracy równe `1.0`. Dzięki temu, potwierdzono, że dane poprawnie płyną przez wszystkie warstwy sieci, a gradienty są precyzyjnie obliczane i aktualizują wagi w przewidywany sposób. Oznacza to także, że architektura ma wystarczającą pojemność informacyjną, żeby nauczyć się zależności między cechami a etykietami. Pozytywny wynik testu pozwolił na rozpoczęcie właściwego procesu uczenia na pełnym zbiorze treningowym.

== Analiza procesu uczenia i skuteczności modelu autorskiego <training-analysis>
Przedstawione w tym podrozdziale wyniki zostały uzyskane podczas treningu autorskiego modelu BiGRU z mechanizmem atencji na zbiorze @silesian z użyciem hiperparametrów przedstawionych w #link(<hyperparameters-summary>)[sekcji zamykającej rozdział 4].

Celem analizy przebiegu procesu uczenia jest weryfikacja poprawności doboru hiperparametrów, skuteczności polityki treningowej `OneCycleLR` oraz ocena zdolności modelu do generalizacji wiedzy. Po każdej epoce monitorowane były metryki jakościowe, co pozwoliło na ocenę stabilności zbieżności algorytmu optymalizacyjnego. Poniższa sekcja prezentuje analizę wartości tych metryk w czasie treningu oraz finalną ocenę skuteczności modelu na zbiorze testowym.

=== Dynamika procesu uczenia (_Learning Curves_) <learning-curves>
#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 1mm,
    image("../images/training/loss_curve.png", width: 100%),
    image("../images/training/metrics_curve.png", width: 100%),
  ),
  caption: [
    Krzywe uczenia dla modelu BiGRU na zbiorze @silesian.
    Po lewej: przebieg funkcji straty (`BCEWithLogitsLoss`).
    Po prawej: przebieg metryki AUC ROC oraz F1 Score.
  ],
) <learning-curves-plots>

Na wykresie funkcji straty widoczny jest wpływ polityki `OneCycleLR`. Na początku, niskie startowe LR powoduje wolny spadek wartości funkcji straty, po czym następuje przyśpieszenie (faza _warm-up_). Pod koniec treningu widoczne jest ponowne spowolnienie, ponieważ w fazie _annealing_ długość kroku jest redukowana. Podczas całego procesu uczenia, wartość funkcji straty nie spadła blisko zera, co oznacza, że maksymalna wartość hiperparametru _learning rate_ została dobrana prawidłowo i nie wystąpiło zjawisko znacznego przeuczenia. Wahania widoczne na krzywej prawdopodobnie są spowodowane stosunkowo niskim rozmiarem paczki danych, ale nie powinno to negatywnie wpłynąć na skuteczność modelu.

Wysoka początkowa wartość F1 Score na zbiorze walidacyjnym (ok. `0.81`) spowodowana została przez imbalans klas i inicjalizację wag biasu klasyfikatora. Niemniej jednak, wartość tej metryki powoli wzrasta (głównie w środkowej fazie treningu za sprawą użytej polityki treningowej), osiągając maksimum bliskie wartości `0.85`. Pole pod krzywą ROC na początku treningu oscylowało w okolicach losowości - `0.5`. Oznacza to, że model w początkowej fazie nauki nie rozróżniał jeszcze klas. Jednak, po ok. 15 epokach, ta wartość zaczęła stosunkowo stabilnie rosnąć, dochodząc aż do prawie `0.72`. Tak wysoka wartość sugeruje, że wytrenowany już model faktycznie nauczył się separować kłamstwa od szczerych wypowiedzi.

#figure(
  image("../images/training/threshold_curve.png", width: 70%),
  caption: [Przebieg optymalnego progu decyzyjnego.]
) <threshold-curve>

Z analizy zmienności optymalnego progu decyzyjnego przedstawionej na #link(<threshold-curve>)[powyższym wykresie] można także wyciągnąć interesujące wnioski.Przez pierwsze 15 epok wykres zmian progu decyzyjnego jest płaski i trzyma się minimalnej dopuszczonej wartości `0.1`. Idealnie pokrywa się to z wykresem AUC, który w tym czasie wskazywał na losowe zgadywanie. Model w tej fazie dopiero "się rozgrzewał", ucząc się czym są poszczególne cechy, ale jeszcze nie zauważając zależności między nimi. 

Gdy AUC zaczęło rosnąć (model zaczyna dostrzegać różnice między klasami), optymalny próg decyzyjny skakał między wartościami `0.1` i `0.6`. Jest to efekt wysokiego LR w tej fazie treningu. Od epoki 45, wahania zaczęły się wygaszać, a próg ustabilizował się na poziomie ok. `0.27`. Model w tym momencie zakończył już naukę cech i tylko delikatnie się dostrajał. Finalny próg jest znacznie niższy od domyślnego `0.5` dowodząc niezbędności zastosowania techniki _threshold tuning_. Ze względu na niezbalansowanie zbioru i specyfikę funkcji straty, model jest "nieśmiały" w swoich predykcjach. Sztywne przyjęcie domyślnego progu skutkowałoby nieoptymalnymi finalnymi wartościami metryk F1 Score i Accuracy.

=== Wyniki na zbiorze testowym i porównanie z modelem bazowym <bigru-test-results-and-baseline-comparison>
W tabeli poniżej przedstawiono wyniki opisujące dokładność predykcji najlepszego uzyskanego modelu (na podstawie metryki AUC) z epoki 51 na zbiorze testowym. Dla porównania w tabeli umieszczono także wyniki osiągnięte przez model bazowy Random Forest.

#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    inset: 10pt,
    align: center + horizon,
    fill: (_, row) => if row == 0 { luma(240) },
    table.header(
      [*Metryka*], [*Random Forest (Baseline)*], [*BiGRU + Attention*]
    ),
    table.hline(),
    [Accuracy], [0.7184], [0.6146],
    [F1 Score], [0.8343], [0.7448],
    [AUC ROC], [0.6393], [0.5234],
    table.hline(),
  ),
  caption: [Zestawienie wyników końcowych modelu autorskiego z modelem bazowym na zbiorze testowym Silesian.],
) <results-comparison-silesian>

Mimo obiecujących wyników na etapie walidacji (AUC równe ok. `0.72`), finalny model poradził sobie z inferencją na zbiorze testowym znacznie gorzej, a także niestety gorzej niż model bazowy. W kontraście do wyników walidacyjnych, na zbiorze testowym AUC spadło do poziomu zaledwie `0.52` - wynik zbliżony do losowego zgadywania. Oznacza to, że model dopasował się do specyfiki osób ze zbioru walidacyjnego, ale nie nauczył się w pełni rozpoznawać uniwersalnych wskaźników kłamstwa. Wskazuje to na trudność w generalizacji wyuczonych wzorców na nowe osoby, mimo zastosowania technik regularyzacji w postaci warstw `Dropout` oraz mechanizmu zanikania wag (_weight decay_).

=== Analiza macierzy pomyłek (_Confusion Matrix_) i histogramu prawdopodobieństwa <silesian-confusion-matrix-and-probability-histogram-analysis>
W celu zbadania nietypowego zjawiska wysokiego F1 Score przy tak niskim AUC wygenerowano macierz pomyłek widoczną #link(<silesian-confusion-matrix>)[poniżej]. Aż 80.6% kłamców zostało sklasyfikowana poprawnie, ale 82% osób mówiących prawdę także zostało oskarżone o nieszczerość. Model wykazuje silną tendencję do klasyfikowania próbek jako kłamstwo w przypadku niepewności (tzw. bias w stronę klasy większościowej). Nie znajdując silnych sygnałów w danych, przyjmuje on bezpieczną strategię obstawiania klasy większościowej (kłamstwa). 

#figure(
  image("../images/training/confusion_matrix_test.png", width: 50%),
  caption: [Macierz pomyłek wytrenowanego modelu BiGRU+Attention na podzbiorze testowym zbioru @silesian.]
) <silesian-confusion-matrix>

Potwierdza to także histogram, na którym rozkłady prawdopodobieństw dla prawdy i kłamstwa w dużym stopniu na siebie nachodzą, uniemożliwiając wyznaczenie skutecznej granicy decyzyjnej.

#figure(
  image("../images/training/prob_histogram.png", width: 70%),
  caption: [Histogram prawdopodobieństw predykcji modelu BiGRU+Attention na podzbiorze testowym zbioru @silesian.]
) <silesian-probability-histogram>

Wnioskiem z eksperymentu jest to, że proste modele działające na zagregowanych statystykach cech (Random Forest) radzą sobie lepiej niż złożone modele sekwencyjne. Prawdopodobnie, zostało to spowodowane niską liczebnością zbioru @silesian, która okazała się niewystarczająca do wytrenowania tysięcy parametrów tak rozbudowanego modelu głębokiego.

== Transfer wiedzy (ang. _transfer learning_) <transfer-learning>
Celem tego podrozdziału jest głębsze zbadania zdolności generalizacji modelu i weryfikacja hipotezy o negatywnym wpływie laboratoryjnych wymuszonych kłamstw low-stakes na skuteczność predykcji. Przeprowadzono transfer wiedzy modelu wytrenowanego na zbiorze @silesian, dotrenowując go na @real_life_ddd.

=== Ewaluacja zero-shot <zero-shot-analysis>
Na początku, wykonano tzw. ewaluację zero-shot - sprawdzenie skuteczności wytrenowanego już modelu na odmiennym zbiorze testowym (pochodzącym z @real_life_ddd). Wyniki zostały zamieszczone w #link(<rl-zero-shot>)[poniższej tabeli oraz macierzy pomyłek].

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 5mm,
    image("../images/transfer_learning/confusion_matrix_real_life_test_zero_shot.png", width: 100%),
    table(
      columns: (1fr, 1fr),
      inset: 12pt,
      align: horizon,
      fill: (_, row) => if row == 0 { luma(240) },
      table.header(
        [*Metryka*], [*Wartość*]
      ),
      table.hline(),
      [Accuracy], [0.4876],
      [F1 Score], [0.6517],
      [AUC Score], [0.5276],
      [Precision], [0.4957],
      [Recall], [0.9508],
      table.hline(),
    ),
  ),
  caption: [
    Statystyki uzyskane z ewaluacji zero-shot na zbiorze @real_life_ddd.
    Po lewej: macierz pomyłek.
    Po prawej: metryki jakościowe.
    ],
) <rl-zero-shot>

Jak można było się spodziewać, model nie osiągnął zadowalających wyników. Podobnie jak w przypadku ewaluacji na zbiorze testowym z @silesian, przewidywał on kłamstwo dla większości próbek. Wartość AUC jest porównywalna z tą uzyskanym na podzbiorze testowym zbioru oryginalnego, a niższe accuracy w tym przypadku można wytłumaczyć równomiernym rozkładem etykiet. Ewaluacja zero-shot wskazuje na to, że model wytrenowany na danych laboratoryjnych nie jest dobrym klasyfikatorem dla danych rzeczywistych bez ówczesnego dotrenowania.

=== Procedura transferu wiedzy i analiza jego wyników <transfer-learning-analysis>
Zamiast uczyć model od zera, zastosowano technikę transfer learningu. Zamrożono warstwy BiGRU oraz atencji, aby zachować wytrenowaną już ektrakcję cech. Zdecydowano się na użycie nowej "wyzerowanej" głowy klasyfikacyjnej, której bias został zainicjowany w taki sam sposób jak przy oryginalnym treningu (logarytm stosunku klas). Ponownie, użyto schedulera `OneCycleLR`. Miało to na celu ułatwienie i przyspieszenie treningu. #link(<transfer-learning-curves>)[Poniżej przedstawione zostały krzywe uczenia].

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    row-gutter: 1em,
    image("../images/transfer_learning/loss_curve.png", width: 100%),
    image("../images/transfer_learning/metrics_curve.png", width: 100%),
    grid.cell(
      colspan: 2,
      align: center,
      image("../images/transfer_learning/threshold_curve.png", width: 60%) 
    )
  ),
  caption: [
    Dynamika procesu transfer learningu modelu autorskiego na zbiorze @real_life_ddd. 
    W górnym rzędzie: przebieg funkcji straty (po lewej) oraz metryk walidacyjnych AUC i F1 (po prawej).
    U dołu: ewolucja optymalnego progu decyzyjnego w czasie trwania treningu.
  ],
) <transfer-learning-curves>

Wartość funkcji straty stabilnie spada (pomijając mocne wahania w ostatniej fazie treningu - prawdopodobnie za wysokie LR na trening wyłącznie warstw klasyfikacyjnych), a AUC bardzo szybko rośnie do poziomu ok. `0.7`. Oznacza to, że cechy wyekstrahowane przez BiGRU na zbiorze @silesian są użyteczne. Wagi sieci rekurencyjnej są poprawnie wytrenowane, dzięki czemu model rozumie ruchy twarzy, a sam klasyfikator musiał tylko nauczyć się podejmować decyzję na ich podstawie. 

Wyniki finalnej ewaluacji dotrenowanego modelu na zbiorze testowym z @real_life_ddd zostały przedstawione #link(<rl-finetuned>)[poniżej].

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 5mm,
    image("../images/transfer_learning/confusion_matrix_real_life_test_finetuned.png", width: 100%),
    table(
      columns: (1fr, 1fr),
      inset: 12pt,
      align: horizon,
      fill: (_, row) => if row == 0 { luma(240) },
      table.header(
        [*Metryka*], [*Wartość*]
      ),
      table.hline(),
      [Accuracy], [0.5372],
      [F1 Score], [0.6818],
      [AUC Score], [0.7639],
      [Precision], [0.5217],
      [Recall], [0.9836],
      table.hline(),
    ),
  ),
  caption: [
    Statystyki uzyskane z ewaluacji dotrenowanego modelu na zbiorze testowym z @real_life_ddd.
    Po lewej: macierz pomyłek.
    Po prawej: metryki jakościowe.
    ],
) <rl-finetuned>

Osiągnięte AUC przewyższyło to uzyskane na oryginalnym zbiorze danych (@silesian), ale jest niższe niż to uzyskane przez Random Forest. Dowodzi to, że wskaźniki kłamstwa są znacznie wyraźniejsze w sytuacjach _high-stakes_ (sala sądowa) niż w _low-stakes_ (laboratorium). Zamrożony ekstraktor cech (BiGRU) skutecznie wykrywa te sygnały, a nowa głowa klasyfikacyjna nauczyła się je intepretować. Warto jednak, zwrócić uwagę na niską wartość Accuracy przy bardzo wysokim Recall. Prawdopodobnie wynika to z faktu, że w warunkach sądowych stres, jak i obciążenie poznawcze towarzyszy zarówno kłamcom, jak i osobom prawdomównym. Model wykrywając silne napięcie, klasyfikuje większość osób jako podejrzane, z czego wynika także niski próg decyzyjny (`0.13`). Mimo to, wysokie AUC dowodzi, że model poprawnie nadaje wyższe prawdopodobieństwo kłamstwa rzeczywistym kłamcom, co jest widoczne także na #link(<rl-finetuned-prob-histogram>)[poniższym histogramie], gdzie rozkłady prawdopodobieństw klas są od siebie lepiej odseparowane niż w przypadku wyników na oryginalnym zbiorze.

#figure(
  image("../images/transfer_learning/prob_histogram.png", width: 70%),
  caption: [Histogram prawdopodobieństw predykcji dotrenowanego modelu BiGRU+Attention na podzbiorze testowym zbioru @real_life_ddd.]
) <rl-finetuned-prob-histogram>

=== Analiza katastroficznego zapominania <catastrophic-forgetting>
Jako finalny eksperyment związany z techniką transferu wiedzy, postanowiono sprawdzić czy skuteczność modelu dotrenowany na nagraniach sądowych poprawiła się względem oryginalnie wytrenowanego modelu. Oryginalny klasyfikator na zbiorze testowym @silesian miał AUC równe 0.5279, a po dotrenowaniu wartość tej metryki spadła do 0.4731. Pomimo wysokiej wartości tego wskaźnika na zbiorze testowym @real_life_ddd, wynik spadł tutaj poniżej losowości. Model nie tylko zapomniał, ale zaczął wręcz mylić sygnały ze starego zbioru. 

W @silesian nie ma silnego stresu. Nowa głowa klasyfikacyjna szuka w nagraniach silnych reakcji na stres, ale nie udaje się jej ich znaleźć, przez co produkuje chaotyczne predykcje. Stara głowa natomiast, potrafiła lepiej skupić się na subtelniejszych sygnałach i wykonywać nieco bardziej precyzyjne predykcje. Eksperyment dowodzi, że nie da się skonstruować jednego modelu do klasyfikacji zarówno kłamstw _low-stakes_ i _high-stakes_, gdyż różnica między tymi domenami (ang. _domain gap_) jest zbyt duża.