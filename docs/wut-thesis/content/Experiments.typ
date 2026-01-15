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

Jak przedstawiono na powyższej krzywej uczenia, model bardzo szybko zredukował stratę do wartości bliskich zeru. Wszystkie próbki zostały bezbłednie sklasyfikowane, o czym świadczy accuracy równe `1.0`. Dzięki temu, potwierdzono, że dane poprawnie płyną przez wszystkie warstwy sieci, a gradienty są precyzyjnie obliczane i aktualizują wagi w przewidywany sposób. Oznacza to także, że architektura ma wystarczającą pojemność informacyjną, żeby nauczyć się zależności między cechami a etykietami. Pozytywny wynik testu pozwolił na rozpoczęcie właściwego procesu uczenia na pełnym zbiorze treningowym.