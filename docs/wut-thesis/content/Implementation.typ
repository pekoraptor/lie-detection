#import "../utils.typ": todo, silentheading, flex-caption

= Implementacja i architektura modeli klasyfikacyjnych <classifiers-implementation-and-architecture>
W poprzednim rozdziale szczegółowo opisano dane używane w projekcie oraz sposób ich przetwarzania, poprzez ekstrakcję cech z nagrań wideo, inżynierię cech w celu zwiększenia ich informatywności, kończąc na finalnych tensorach. Celem tego rozdziału jest przedstawienie szczegółów implementacyjnych algorytmów sztucznej inteligencji, które na wejście dostają właśnie te przygotowane dane. Najpierw scharakteryzowane zostanie środowisko programistyczne oraz biblioteki i narzędzia użyte w ramach realizacji projektu. W dalszej kolejności omówiony zostanie model bazowy Random Forest, służący jako punkt odniesienia dla bardziej zaawansowanego rozwiązania. Główna część rozdziału będzie poświęcona szczegółowemu opisowi proponowanej architektury głębokiej sieci neuronowej, opartej na dwukierunkowych jednostkach rekurencyjnych (BiGRU), wzbogaconych o mechanizm atencji. Rozdział zostanie zakończony analizą procedury treningowej, doboru hiperparametrów oraz technik użytych w celu poprawy zdolności generalizacji modelu.

== Środowisko programistyczne i wykorzystane biblioteki <environment-and-libraries>
Całość projektu została zrealizowana w języku programowania Python w wersji 3.10.14. Jest to język dominujący dziedziny Data Science oraz Machine Learning i z tego właśnie powodu zdecydowano się na jego wybór. Specyficzna wersja została dobrana w sposób maksymalizujący liczbę kompatybilnych bibliotek. Jako środowisko pracy wykorzystano Visual Studio Code, a badania były przeprowadzane z użyciem Jupyter Notebooków, pozwalających na interaktywną analizę danych, szybkie i wygodne restartowanie fragmentów kodu oraz wizualizację wyników między komórkami (ang. _inline_).
Framework głębokiego uczenia maszynowego PyTorch stanowił główny silnik projektu i został użyty do:
- konstrukcji sieci neuronowych - warstw GRU, Linear, modułu Attention (`torch.nn`),
- obsługi datasetów i data loaderów (`torch.utils.data`),
- akcelerowanych sprzętowo obliczeń na tensorach (na GPU) przy użyciu technologii NVIDIA CUDA w wersji 12.1, co znacznie przyspieszyło proces treningu sieci.

Biblioteka `scikit-learn` posłużyła do:
- preprocessingu danych - skalowania opisanego szczegółowo w #link(<data-normalization>)[poprzednim rozdziale],
- podziału danych na zbiory treningowe, walidacyjne i testowe (funkcja `train_test_split`),
- implementacji modelu bazowego - algorytmu Random Forest,
- obliczania skuteczności modeli, korzystając z dostępnych funkcji (`accuracy_score`, `f1_score`, `roc_auc_score`, `confusion matrix`, itp.).

W celu wizualizacji wyników użyto bibliotek `matplotlib.pyplot` oraz `seaborn` do generowania wykresów strat (ang. _loss curves_), macierzy pomyłek (ang. _confusion matrix_) oraz rozkładu danych.

Do narzędzi pomocniczych zaliczają się:
- `pandas` - do przechowywania i manipulacji danych tabelarycznych (danych wychodzących z potoku przetwarzania),
- `numpy` do operacji na macierzach,
- `joblib` - do serializacji obiektów skalerów, co pozwala na użycie ich w aplikacji webowej opisanej w #link(<web-application>)[rozdziale szóstym].

Dla przypomnienia, do budowy potoku przetwarzania obrazu posłużyły biblioteki:
- `ultralytics` - do detekcji twarzy i kadrowania z użyciem YOLOv8,
- `mediapipe` - do ekstrakcji punktów charakterystycznych twarzy,
- `opencv-python` - do operacji na obrazach, w tym: wczytywanie wideo, skalowanie, obliczanie Optical Flow algorytmem Farnebacka,
- `facial_emotion_recognition` - do ekstrakcji wektora emocji,
- `pympi` - do parsowania plików adnotacji (.eaf) ze zbioru @silesian,
- `tqdm` - do wizualizacji paska postępu podczas długotrwałego procesu przetwarzania danych.

== Model bazowy - Random Forest <baseline-random-forest>
Jako model bazowy (_baseline_) zastosowano algorytm Random Forest, którego podstawy teoretyczne zostały dokładnie omówione w #link(<classical-machine-learning-algorithms>)[rozdziale drugim]. Z uwagi na prostotę tego klasyfikatora oraz powszechną dostępność jego implementacji, wykorzystano klasę `RandomForestClassifier` z biblioteki `scikit-learn`.

=== Przygotowanie danych i wektor wejściowy <rf-data-preparation-and-input-vector>
W przeciwieństwie do sieci rekurencyjnych, Random Forest nie obsługuje danych sekwencyjnych o zmiennej długości. Ze względu na ten wymóg, sekwencyjne wektory cech musiały zostać spłaszczone do wektorów o stałym rozmiarze, reprezentujących całe nagranie. W tym celu, dla każdej z 23 cech wyznaczono cztery statystyki opisowe: średnia arytmetyczna, odchylenie standardowe, minimum i maksimum. Operacja ta pozwoliła na transformację zmiennej liczby klatek w stały wektor o rozmiarze 92 ($23 "cechy" times 4 "statystyki"$), który był następnie podawany na wejście klasyfikatora.

=== Konfiguracja modelu <rf-model-configuration>
Klasa `RandomForestClassifier` jest bardzo konfigurowalna - pozwala na znaczne dostosowanie algorytmu pod swoje własne potrzeby. Hiperparametry zostały dobrane eksperymentalnie, a oto ich wartości:
- Liczba estymatorów (`n_estimators`) = 100: liczba drzew w lesie,
- Maksymalna głębokość drzewa (`max_depth`) = 10: złoty środek między zbyt prostą architekturą (skutkującą niedouczeniem modelu), a zbyt skomplikowaną (mającą ryzyko przeuczenia),
- Ziarno losowości (`random_state`) = 42 (według konwencji): w celu zapewnienia reprodukowalności wyników,
- Waga klas (`class_weight`) = `balanced`: uwzględnienie niezbalansowanej liczebności etykiet, wymuszając wagi w funkcji straty odwrotnie proporcjonalne do częstości występowania klas.

== Proponowana architektura głęboka <bigru-attention-architecture>
W tym podrozdziale przedstawione zostaną szczegóły techniczne autorskiego modelu głębokiej sieci rekurencyjnej BiGRU wzbogaconej mechanizmem atencji.

#figure(
  image("../images/bigru_attention.drawio.pdf", width: 100%),
  caption: [
    Schemat architektury modelu BiGRU z mechanizmem atencji. 
    Wymiary tensorów podano w nawiasach kwadratowych nad strzałkami przepływu danych.
  ],
) <fig:architecture>

=== Konfiguracja warstwy rekurencyjnej BiGRU <bigru-layer>
Warstwa wejściowa przyjmuje wektory 23-elementowe (kształt wejścia: `[Batch, Length, 23]`), zgodnie z przedstawionym wcześniej potokiem przetwarzania danych i inżynierią cech. Rozmiar stanu ukrytego został zdefiniowany na 16 jako kompromis między pojemnością informacyjną sieci, a ryzykiem jej przeuczania na małym zbiorze danych (takim jak @silesian, a tym bardziej @real_life_ddd).
Stan ukryty w każdym kroku czasowym jest konkatenacją wektorów z obu kierunków przetwarzania, co opisuje zależność: $h_t = [arrow(h_t);arrow.l(h_t)]$.

Zastosowano dwie warstwy Gru, co zwiększa zdolność modelu do zauważania bardziej złożonych zależności między cechami. Dodatkowo, między warstwami została użyta warstwa `Dropout`. Jej zadaniem jest zapobieganie przeuczeniu. Podczas treningu, w każdym kroku część neuronów (w tym przypadku 40%) jest zerowana. Dzięki temu sieć nie polega na pojedynczych spostrzeżeniach (np. tylko na mruganiu), lecz uczy się bardziej uniwersalnych i odpornych wzorców kłamstwa. 

Z powodu nierównej długości próbek został wykorzystany mechanizm paddingu (opisany wcześniej w #link(<sequence-preparation>)[ostatniej sekcji poprzedniego rozdziału]) w postaci funkcji `pack_padded_sequence` i `pad_packed_sequence` z biblioteki `torch.nn.utils`. Pozwala to sieci na przetwarzanie tylko istotnych fragmentów sekwencji, efektywnie pomijając dopełnione wartości, co oszczędza zasoby obliczeniowe i poprawia jakość gradientów w procesie wstecznej propagacji (ang. _backpropagation_).

Wagi rekurencyjne modelu są inicjalizowane stosując inicjalizację ortogonalną. Jest to technika, która matematycznie zapewnia, że wartości własne macierzy wag są bliskie 1. Wpływa to pozytywnie na stabilność uczenia sieci.

=== Mechanizm atencji <attention-mechanism>
Zaimplementowano wariant atencji Global Soft Attention. Warstwa liniowa `torch.nn.Linear` dostaje na wejście skonkatenowany stan ukryty z obu kierunków (ze względu na dwukierunkowość zastosowanej sieci rekurencyjnej BiGRU) i przypisuje mu skalar (score). Następnie na wynikowy wektor (skonkatenowane skalary dla każdej klatki z sekwencji) nakładana jest maska przypisująca klatkom z paddingu wartość `-1e4`. Dzięki użyciu maski po przejściu przez warstwę aktywacji `torch.softmax` ich waga (wartość w finalnym wektorze kontekstu) wynosi dokładnie `0.0`, co sprawia że puste klatki są całkowicie ignorowane. Wagi pozostałych kroków czasowych są równe prawdopodobieństwu wystąpienia w nich istotnej informacji.

Cały ten proces można opisać formalnie w następujących krokach. Niech $h_t$ oznacza wartość stanu ukrytego dla kroku czasowego $t$. Score obliczany jest ze wzoru:
$ e_t = W^T h_t + b $ 
gdzie $W$ i $b$ to trenowalne parametry warstwy liniowej (odpowiednio wagi i bias). Następnie, wagi atencji oznaczone jako $alpha_t$ obliczane są poprzez normalizację funkcją Softmax:
$ alpha_t = (exp(e_t))/(sum_(k=1)^T exp(e_k)) $
Finalny wektor kontekstu $c$ stanowi sumę ważoną stanów ukrytych wszystkich kroków czasowych z sekwencji:
$ c = sum_(t=1)^T alpha_t h_t $
Tak uzyskany wektor $c$ jest reprezentacją całej sekwencji i trafia do klasyfikatora.

=== Moduł klasyfikacyjny i wyjście modelu <classification-module>
Wektor kontekstu uzyskany z modułu atencji trafia do perceptrona wielowarstwowego, który składa się z następujących warstw:
- `Linear(32, 16)`, 
- `ReLU`,
- `Dropout(0.4)`,
- `Linear(16, 1)`.
Wąskie gardło (rozmiar 16) przed ostateczną predykcją wymusza na sieci ekstrakcję najważniejszych cech. Model zwraca surowe logity (kształt wyjścia: `[Batch, 1]`), gdyż wykorzystana podczas treningu funkcja straty `BCEWithLogitsLoss` ma wbudowaną sigmoidę.

== Procedura treningowa i optymalizacja <training-procedure-and-optimization>

=== Funkcja straty i optymalizator <loss-function-and-optimizer>
W procesie treningu sieci BiGRU + Attention skorzystano z najbardziej powszechnej funkcji straty używanej do klasyfikacji binarnej, którą jest `BCEWithLogitsLoss`. Funkcja ta łączy w sobie warstwę `Sigmoid` oraz binarną entropię krzyżową (ang. _binary cross entropy_) w jedną operację matematyczną. W przeciwieństwie do ręcznego nakładania funkcji aktywacji na wyjście modelu i korzystania z funkcji straty `BCELoss`, wykorzystana funkcja zapewnia większą stabilność numeryczną, unikając problemów z niedokładnością obliczania gradientów dla skrajnych wartości prawdopodobieństwa.

Zdecydowano się na użycie optymalizatora `AdamW`, który jest poprawioną implementacją klasycznego optymalizatora `Adam`. Wprowadza on bardziej efektywne zanikanie wag (ang. _weight decay_), rozdzielając go od aktualizacji gradientu. Dzięki temu regularyzacja modelu jest silniejsza bez pogarszania zbieżności treningu, co jest kluczowe przy małych zbiorach danych.

=== Polityka Learning Rate (OneCycle) <learning-rate-policy>
Zamiast statycznego rozmiaru kroku lub jego redukcji na płaskim fragmencie wykresu funkcji straty (z użyciem schedulera `ReduceLROnPlateau`), zastosowano politykę *One Cycle Learning Rate*. Trening rozpoczyna się od niższej wartości LR, która rośnie liniowo przez pierwsze 30% epok (tzw. faza warm up), osiągając maksimum na poziomie `1e-3`. W kolejnych iteracjach LR jest sukcesywnie zmniejszane (tzw. faza annealing). Dzięki zastosowaniu schedulera `OneCycleLR`, trening jest szybszy (zjawisko super-zbieżności). Wyższe LR w środkowej fazie działa jak regularyzator, powstrzymując model przed utykaniem w minimach lokalnych.

=== Inicjalizacja biasu <bias-initialization>
Dane, na których trenowany jest model są niezbalansowane klasowo. Z tego powodu, przed rozpoczęciem treningu, bias ostatniej warstwy klasyfikatora został zainicjowany wartością $log("num_pos_videos" / "num_neg_videos")$. Dzięki temu, model od początku przewiduje prawdopodobieństwo zgodne z rozkładem klas w zbiorze treningowym (w którym jest znaczna przewaga próbek zawierających kłamstwo). W ten sposób, początkowa faza treningu skupiona jest już na nauce cech, a nie proporcji klas (jak byłoby w przypadku bez ręcznej inicjalizacji).

=== Walidacja i wybór metryki <validation-and-metric-choice>
Po zakończeniu każdej epoki treningowej następuje walidacja modelu, podczas której działanie modelu jest ewaluowane na zbiorze walidacyjnym. W tym kroku wagi modelu zostają zamrożone jak przy inferencji, a model traktowany jest jakby był już wytrenowany. Obliczana jest wartość funkcji straty oraz metryki jakościowe, które są akumulowane w celu wygenerowania krzywych uczenia (ang. _learning curves_). Dzięki temu procesowi, możliwe jest badanie jak zmienia się skuteczność modelu oraz wykrywanie zjawiska przeuczenia w czasie rzeczywistym.

Przy niezbalansowanym zbiorze danych, model zgadujący zawsze klasę większościową osiąga wysoką skuteczność (accuracy), ale nie odzwierciedla ona rzeczywistej skuteczności klasyfikacji. Z tego powodu, w procesie treningu jako główną metrykę służącą do ewaluacji skuteczności modelu na zbiorze walidacyjnym wybrano pole pod krzywą ROC (AUC ROC, ang. _Area Under the Receiver Operating Characteristic Curve_). Metryka ta mierzy zdolność modelu do rozróżniania klas niezależnie od przyjętego progu klasyfikacyjnego. Wysoka wartość AUC gwarantuje, że model przypisuje wyższe prawdopodobieństwa kłamstwa próbkom fałszywym niż próbkom prawdziwym.

Warto zaznaczyć, że w zadaniach klasyfikacji binarnej, próg rozdzielający klasy o wartości `0.5` nie jest zawsze optymalny. Dlatego, w procesie walidacji stosowana jest technika poszukiwania optymalnego progu (ang. _threshold tuning_), co pozwala na zmaksymalizowanie czułości (ang. _recall_ zdefiniowane jako $"true positives"/"all positives"$) przy zachowaniu akceptowalnego poziomu specyficzności (ang. _specificity_ zdefiniowane jako $"true negatives"/"all negatives"$).

=== Kontrola pętli treningowej <training-loop-control>
Proces uczenia realizowany był w trybie wsadowym (ang. _batch training_) z rozmiarem wsadu (ang. _batch size_) równym 16 próbek. Ze względu na rekurencyjny charakter proponowanej sieci neuronowej, zastosowano technikę przycinania gradientu (ang. _gradient clipping_) w celu eliminacji problemu wybuchających gradientów. Podczas propagacji wstecznej, norma wektora gradientów była skalowana, żeby nie przekraczała wartości `1.0`.

Maksymalna liczba epok została ustawiona na 60. Dodatkowo, wykorzystano mechanizm wczesnego zakończenia (ang. _early stopping_) względem metryki AUC z cierpliwością (ang. _patience_) równą 20 epok. Jest to stosunkowo duża cierpliwość, lecz jej wysoka wartość jest kluczowa przy użyciu wcześniej opisanego schedulera `OneCycleLR`. Używając go, strata (jak i inne metryki) może naprzemiennie rosnąć i maleć w fazie wysokiego LR. Z tego powodu, wymagana jest zwiększona tolerancja na brak poprawy, aby dać modelowi szansę na znalezienie lepszego optimum.

Najlepszy model uzyskany podczas trenowania (na podstawie metryki AUC) wczytywany jest na koniec, a jego wagi zapisywane są do pliku w celu możliwości późniejszego go odtworzenia bez konieczności ponawiania treningu.

=== Podsumowanie hiperparametrów <hyperparameters-summary>
Finalna konfiguracja hiperparametrów, która pozwoliła na uzyskanie najlepszych wyników (prezentowanych w kolejnym rozdziale), została przedstawiona w #link(<hyperparameters>)[poniższej tabeli].

#figure( 
    table( columns: (1fr, 1fr), 
    inset: 10pt, 
    align: horizon,
    fill: (_, row) => if row == 0 { luma(240) },
    [*Hiperparametr*], [*Wartość*],
    [Architektura sieci], [BiGRU + Global Soft Attention], 
    [Liczba warstw rekurencyjnych], [2], 
    [Wymiar stanu ukrytego], [16], 
    [Dropout], [0.4], 
    [Optymalizator], [`AdamW`], 
    [Funkcja Straty], [`BCEWithLogitsLoss`],
    [Startowe Learning Rate], [`1e-4`],
    [Maksymalne Learning Rate], [`1e-3` (OneCycle Policy)], 
    [Rozmiar wsadu (Batch Size)], [16], 
    [Liczba epok], [60], 
    [Regularyzacja L2 (Weight Decay)], [0.05], 
    [Gradient Clipping Norm], [1.0]), 
    caption: [
        Zestawienie finalnych hiperparametrów modelu oraz procedury treningowej.
    ] 
) <hyperparameters>