#import "../utils.typ": todo, silentheading, flex-caption

= Implementacja systemu w postaci aplikacji webowej <web-application>
Nawet najbardziej skuteczne modele uczenia maszynowego są bezużyteczne w zastosowaniach komercyjnych, jeśli są dostępne wyłącznie jako skrypt uruchamiany z wiersza poleceń lub komórka w Jupyter Notebooku. Celem niniejszego rozdziału jest prezentacja interfejsu graficznego przygotowanego dla opracowanych modeli umożliwiającego ich użycie przez użytkownika końcowego, nieposiadającego wiedzy programistycznej. Stworzone rozwiązanie ma charakter Proof of Concept (PoC). Jest to prototyp mający na celu demonstrację możliwości utworzonego systemu automatycznej analizy prawdomówności, a nie gotowy produkt komercyjny.

Treść tego rozdziału rozpocznie się od definicji wymagań funkcjonalnych i niefunkcjonalnych. Następnie, omówiony zostanie stos technologiczny wraz z argumentacją za jego wyborem, opis architektury. Na końcu, zaprezentowane będzie działanie stworzonego prototypu. 

== Analiza wymagań systemowych <system-requirements-analysis>
Zgodnie z zasadami inżynierii oprogramowania, proces budowy aplikacji poprzedzono definicją wymagań. Ze względu na badawczy charakter projektu (_Proof of Concept_), skupiono się na kluczowych funkcjonalnościach niezbędnych do walidacji modeli w środowisku produkcyjnym. Wymagania podzielono na dwie kategorie: funkcjonalne (określające zachowanie systemu) oraz niefunkcjonalne (określające atrybuty jakościowe).

=== Wymagania funkcjonalne <functional-requirements>
System musi realizować następujące funkcje:
- *WF1. Obsługa danych wejściowych:* Możliwość wczytania pliku wideo w powszechnych formatach (m.in. `.mp4`, `.avi`) poprzez interfejs graficzny.
- *WF2. Konfiguracja inferencji:* Możliwość dynamicznego wyboru architektury modelu (Random Forest, BiGRU) oraz zbioru danych, na którym został wytrenowany (Silesian/Real-Life).
- *WF3. Automatyczne przetwarzanie nagrań:* System musi automatycznie wykonywać potok przetwarzania wideo w dane zrozumiałe dla modeli bez ingerencji użytkownika.
- *WF4. Prezentacja wyników:* Aplikacja musi wyświetlać wynik predykcji w przejrzysty i zrozumiały sposób - binarnie i probabilistycznie. 
- *WF5. Wyjaśnialność (XAI):* Dla modeli głębokich system musi wyświetlać wykres wag atencji w funkcji czasu.
- *WF6. Responsywność:* System musi na bieżąco informować o postępie analizy i wystąpieniach błędów.

=== Wymagania niefunkcjonalne <non-functional-requirements>
System musi spełniać następujące kryteria jakościowe:
- *WN1. Użyteczność:* Interfejs użytkownika nie może wymagać wiedzy programistycznej ani technicznej i powinien być zrozumiały dla laika.
- *WN2. Wydajność:* Czas przetwarzania powinien być zminimalizowany z użyciem downsamplingu.
- *WN3. Zarządzanie zasobami:* Wagi modeli powinny być ładowane do pamięci operacyjnej tylko raz, aby przełączanie między nagraniami było płynne.
- *WN4. Odporność na błędy użytkownika:* Aplikacja musi bezpiecznie obsłużyć wyjątki, takie jak brak twarzy w nagraniu, wyświetlając odpowiedni komunikat zamiast przerywać działanie.
- *WN5. Przenośność:* System powinien być niezależny od systemu operacyjnego oraz podzespołów komputera, działając zarówno na CPU jak i GPU.

== Założenia projektowe i wybór technologii <design-and-technology>
Projektując interfejs użytkownika postawiono na jego prostotę i czytelność. Aplikacja ta powinna działać na zasadzie "drag and drop", minimalizując wymaganą liczbę kliknięć potrzebnych do otrzymania predykcji dla własnego nagrania. Ze względu na uzyskane wyniki opisane #link(<experiments-and-analysis>)[w poprzednim rozdziale] (bardzo odmienne skuteczności modelu autorskiego BiGRU+Attention wytrenowanego na zbiorze @silesian, dotrenowanego na @real_life_ddd, a także obu klasyfikatorów Random Forest) zdecydowano się na podejście wielomodelowe. System musi pozwalać na dynamiczne przełączanie się między różnymi klasyfikatorami bez konieczności restartowania aplikacji. Dodatkowym założeniem była także optymalizacja procesu inferencji w celu jak najszybszego czasu analizy, co uzyskano poprzez m.in. inteligentne pomijanie klatek (_downsampling_) oraz akcelerację obliczeń na karcie graficznej (w przypadku jej dostępności).

Poniżej przedstawiono wykorzystany stos technologiczny:
- Język programowania: *Python*. Jest to standard współczesnego uczenia maszynowego. Użycie tego języka pozwoliło na bezpośrednią integrację kodu napisanego w fazie badań i modelowania oraz wczytanie wag najlepszych modeli zapisanych w trakcie treningu.
- Framework UI: *Streamlit*. Został wybrany zamiast klasycznego podejścia dwuwarstwowego z oddzielnym backendem i frontendem, ponieważ pozwala na błyskawiczne tworzenie aplikacji opartych na danych w czystym Pythonie.
- Silnik uczenia maszynowego: *PyTorch i Scikit-learn*.
  - PyTorch został użyty do inferencji z wykorzystaniem modelu głębokiego (BiGRU+Attention).
  - Scikit-learn został wykorzystany do obsługi modeli Random Forest.
- Przetwarzanie danych: *OpenCV, MediaPipe, FacialEmotionRecognition, Ultralytics*. Wykorzystano odtworzony potok opisany szczegółowo w #link(<data-preparation-and-feature-engineering>)[rozdziale trzecim tej pracy]. Dostosowano go, jednak, do przetwarzania pojedynczych nagrań w przeciwieństwie do pierwotnego zastosowania na całych zbiorach danych.

Taki dobór technologii jest obecnie standardem w szybkim prototypowaniu rozwiązań AI w środowiskach R&D (ang. _research and development_).

== Architektura aplikacji <architecture>
W procesie projektowania systemu skupiono się na modularności i separacji odpowiedzialności, co ma na celu zachowanie czytelności kodu oraz łatwość rozszerzania go w przyszłości o dodatkowe funkcjonalności. Logika aplikacji została podzielona na trzy warstwy, separując logikę interfejsu graficznego, przetwarzania danych i inferencji.

Sercem systemu jest moduł predykcji. Aby obsłużyć dwa zupełnie różne typy modeli (sieci neuronowe i Random Forest) w jednolity sposób, zdefiniowano abstrakcyjną klasę bazową `BaseLieDetector` oraz fabrykę `LieDetector`, która na podstawie rozszerzenia wybranego przez użytkownika pliku wag dynamicznie instancjonuje odpowiedni obiekt klasyfikatora. Dzięki zastosowaniu polimorfizmu, warstwa interfejsu nie uwzględnia szczegółów implementacyjnych modelu, a jedynie wywołuje ustandaryzowaną metodę `predict`.

Za wstępne przetworzenie nagrań i konwersję do formy akceptowanej przez modele odpowiadają moduły pomocnicze. Klasa `VideoProcessor` dokładnie odtwarza logikę potoku przetwarzania obrazu wykonywanego przed trenowaniem modeli. Funkcje zdefiniowane w pliku `features.py` wyciągają inteligentne (ang. feature-engineered) wskaźniki, obliczając znormalizowane dystanse między punktami charakterystycznymi twarzy, konstruując cechy pochodne (prędkościowe), aplikując filtry wygładzające (średnia krocząca) i odpowiednio skalując dane.

Logika samego interfejsu graficznego zaimplementowana została w pliku `app.py`. Moduł ten pełni rolę orkiestratora systemu - definiuje układ komponentów wizualnych, obsługuje interakcję z użytkownikiem, wywołuje odpowiednie funkcje pomocnicze i predykcje modeli, a także odpowiada za wizualizację wyników. Ważnym aspektem architektury jest optymalizacja wydajności. Wykorzystano mechanizm cache'owania, aby zapobiec wielokrotnemu wczytywaniu wag modeli do pamięci operacyjnej. Ładowanie to jest wykonywane tylko raz (przy uruchomieniu strony) oraz po każdej zmianie wybranego modelu.

#figure(
  image("../images/diagrams/architecture_uml.drawio.pdf", width: 90%),
  caption: [Diagram klas UML prezentujący architekturę aplikacji. Widoczny podział na warstwę interfejsu (`StreamlitApp`), przetwarzania wideo (`VideoProcessor`) oraz hierarchię klas modułu predykcyjnego realizującą polimorfizm.]
)

== Weryfikacja działania i testowanie oprogramowania <tests>
Zapewnienie niezawodności systemu łączącego przetwarzanie wideo, modele sztucznej inteligencji oraz interfejs użytkownika wymagało wprowadzenia procedury testowej. W procesie jej implementacji wykorzystano framework `pytest`, który jest standardem w inżynierii oprogramowania z użyciem języka Python. Kluczowym elementem strategii testowania było wykorzystanie techniki atrap obiektów (ang. _mocking_) z biblioteki `unittest.mock`, co pozwoliło na oddzielenie logiki biznesowej od ciężkich zasobów (w tym wag modeli, operacji wejścia i wyjścia). 

=== Testy jednostkowe <unit-tests>
W celu weryfikacji poprawności działania pojedynczych, izolowanych komponentów utworzono testy jednostkowe:
- *Weryfikacja inżynierii cech:* Przetestowano kompletny potok przetwarzania danych dla obu typów modeli. Dla modelu głębokiego sprawdzono czy funkcja `preprocess_video_data()` generuje odpowiednie sekwencyjne tensory. Dla modelu Random Forest zweryfikowano funkcję `preprocess_video_data_rf()` pod kątem poprawnej transformacji sekwencji czasowej w "spłaszczony" wektor o stałym wymiarze 92 cech. Dodatkowo, przetestowano funkcję `calculate_distances()`.
- *Walidacja architektury sieci:* Sprawdzono poprawność implementacji klasy `BiGRUAttention`, weryfikując zgodność wymiarów tensorów wejściowych i wyjściowych oraz poprawność działania mechanizmu atencji (suma wag powinna równać się `1.0` po operacji Softmax).

=== Testy integracyjne <integration-tests>
Celem testów integracyjnych było sprawdzenie poprawności współpracy między modułami w ramach potoku predykcyjnego, odzwierciedlającego ten proces w aplikacji. Zweryfikowano klasy `DeepLieDetector` oraz `RFLieDetector` pod kątem zgodności interfejsów. Symulując wczytywanie wag z dysku, sprawdzono, czy metoda `predict` poprawnie przetwarza surowy tensor wejściowy i zwraca ustandaryzowany obiekt wynikowy zawierający prawdopodobieństwo, binarny werdykt oraz wektor wag atencji (w przypadku Random Forest, zwracane jest `None` jako wartość tego pola). Dzięki temu, potwierdzono, że warstwa interfejsu otrzymuje dane w oczekiwanym formacie niezależnie od wybranego modelu.

== Prezentacja funkcjonalności i interfejsu użytkownika <functionality-and-ui-overview>
=== Konfiguracja i panel sterowania <configuration-and-side-panel>
Interfejs został podzielony na dwa panele, co jest widoczne na #link(<ui-uploaded-video>)[poniższym zrzucie ekranu]. Z lewej strony znajduje się wysuwany panel konfiguracyjny, zawierający dynamiczny selektor modelu. Główny ekran służy do interakcji z danymi. Na jego górze znajduje się komponent do przesyłania plików. Kiedy użytkownik załaduje swoje nagranie, pojawia się jego nazwa pliku wraz z rozmiarem. Poniżej widnieje podgląd nagrania, dzięki któremu użytkownik może w łatwy sposób je obejrzeć w celu zweryfikowania czy analizuje właściwy materiał.

#figure(
  image("../images/ui/loaded_recording.png", width: 100%),
  caption: [Widok główny aplikacji w fazie konfiguracji. W panelu bocznym widoczny wybór modelu, w części centralnej podgląd analizowanego nagrania.]
) <ui-uploaded-video>

=== Przebieg procesu inferencji <inference-process>
Wstępne przetworzenie wideo oraz wywołanie inferencji modelu jest dosyć długim procesem i w zależności od rozmiaru i długości nagrania może trwać nawet kilkadziesiąt sekund. Z tego powodu, zadbano żeby po kliknięciu przycisku "Analyze Video", interfejs nie zamarzał, lecz na bieżąco informował o aktualnie wykonywanych działaniach. W tym celu wykorzystano pasek postępu i komunikaty statusu, aby użytkownik nie zastanawiał się czy aplikacja się zawiesiła. Dodatkowo, w przypadku napotkania błędu (takiego jak np. niepomyślna detekcja twarzy na nagraniu) wyświetlany jest komunikat ostrzegawczy.

=== Prezentacja wyników <results-display>
Na #link(<ui-inference-results>)[poniższym zrzucie ekranu] przedstawiony został interfejs użytkownika wyświetlany po pomyślnie zakończonej inferencji. Wynik jest prezentowany w sposób binarny i probabilistyczny, co pozwala na natychmiastową interpretację wyniku przez użytkownika. Wyświetlony jest pasek pokazujący prawdopodobieństwo wystąpienia kłamstwa w stosunku do użytego progu decyzyjnego, w celu uzyskania maksymalnej transparentności. Na samym dole jako realizacja koncepcji wyjaśnialności sztucznej inteligencji (ang. _XAI_ - _Explainable AI_) umieszczony został rozwijany panel wizualizujący wektor atencji. Wykres ten pozwala zidentyfikować krytyczne momenty w nagraniu, które najmocniej wpłynęły na podjętą przez model decyzję. Ze względu na naturę alternatywnych modeli wykorzystujących algorytm Random Forest, ten panel widoczny jest tylko po inferencji z użyciem modelu BiGRU+Attention.

#figure(
  image("../images/ui/results.png", width: 80%),
  caption: [Panel wyników analizy. Widoczna ocena prawdopodobieństwa kłamstwa, wizualizacja progu decyzyjnego oraz wykres wag atencji wskazujący na podejrzane fragmenty nagrania.]
) <ui-inference-results>