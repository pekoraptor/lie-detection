#import "../utils.typ": todo, silentheading, flex-caption

= Implementacja systemu w postaci aplikacji webowej <web-application>
Nawet najbardziej skuteczne modele uczenia maszynowego są bezużyteczne w zastosowaniach komercyjnych, jeśli są dostępne wyłącznie jako skrypt uruchamiany z wiersza poleceń lub komórka w Jupyter Notebooku. Celem niniejszego rozdziału jest prezentacja interfejsu graficznego przygotowanego dla opracowanych modeli umożliwiającego ich użycie przez użytkownika końcowego, nieposiadającego wiedzy programistycznej. Stworzone rozwiązanie ma charakter Proof of Concept (PoC). Jest to prototyp mający na celu demonstrację możliwości utworzonego systemu automatycznej analizy prawdomówności, a nie gotowy produkt komercyjny.

Treść tego rozdziału rozpocznie się od definicji wymagań funkcjonalnych. Następnie, omówiony zostanie stos technologiczny wraz z argumentacją za jego wyborem, opis architektury. Na końcu, zaprezentowane będzie działanie stworzonego prototypu. 

== Założenia projektowe i wybór technologii <design-and-technology>
Projektując interfejs użytkownika postawiono na jego prostotę i czytelność. Aplikacja ta powinna działać na zasadzie "drag and drop", minimalizując wymaganą liczbę kliknięć potrzebnych do otrzymania predykcji dla własnego nagrania. Ze względu na uzyskane wyniki opisane #link(<experiments-and-analysis>)[w poprzednim rozdziale] (bardzo odmienne skuteczności modelu autorskiego BiGRU+Attention wytrenowanego na zbiorze @silesian, dotrenowanego na @real_life_ddd, a także obu klasyfikatorów Random Forest) zdecydowano się na podejście wielomodelowe. System musi pozwalać na dynamiczne przełączanie się między różnymi klasyfikatorami bez konieczności restartowania aplikacji. Dodatkowym założeniem, była także optymalizacja procesu inferencji w celu jak najszybszego czasu analizy, co uzyskano poprzez m.in. inteligentne pomijanie klatek (_downsampling_) oraz akcelerację obliczeń na karcie graficznej (w przypadku jej dostępności).

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

Sercem systemu jest moduł predykcji. Aby obsłużyć dwa zupełnie różne typy modeli (sieci neuronowe i lasy losowe) w jednolity sposób, zdefiniowano abstrakcyjną klasę bazową `BaseLieDetector` oraz fabrykę `LieDetector`, która na podstawie rozszerzenia wybranego przez użytkownika pliku wag dynamicznie instancjonuje odpowiedni obiekt klasyfikatora. Dzięki zastosowaniu polimorfizmu, warstwa interfejsu nie uwzględnia szczegółów implementacyjnych modelu, a jedynie wywołuje ustandaryzowaną metodę `predict`.

Za wstępne przetworzenie nagrań i konwersję do formy akceptowanej przez modele odpowiadają moduły pomocnicze. Klasa `VideoProcessor` dokładnie odtwarza logikę potoku przetwarzania obrazu wykonywanego przed trenowaniem modeli. Funkcje zdefiniowane w pliku `features.py` wyciągają inteligentne (ang. feature-engineered) wskaźniki, obliczając znormalizowane dystanse między punktami charakterystycznymi twarzy, konstruując cechy pochodne (prędkościowe), aplikując filtry wygładzające (średnia krocząca) i odpowiednio skalując dane.

Logika samego interfejsu graficznego zaimplementowana została w pliku `app.py`. Moduł ten pełni rolę orkiestratora systemu - definiuje układ komponentów wizualnych, obsługuje interakcję z użytkownikiem, wywołuje odpowiednie funkcje pomocnicze i predykcje modeli, a także odpowiada za wizualizację wyników. Ważnym aspektem architektury jest optymalizacja wydajności. Wykorzystano mechanizm cache'owania, aby zapobiec wielokrotnemu wczytywaniu wag modeli do pamięci operacyjnej. Ładowanie to jest wykonywane tylko raz (przy uruchomieniu strony) oraz po każdej zmianie wybranego modelu.

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
Na #link(<ui-inference-results>)[poniższym zrzucie ekranu] przedstawiony został interfejs użytkownika wyświetlany po pomyślnie zakończonej inferencji. Wynik jest prezentowany w sposób binarny i probabilistyczny, co pozwala na natychmiastową interpretację wyniku przez użytkownika. Wyświetlony jest pasek pokazujący prawdopodobieństwo wystąpienia kłamstwa w stosunku do użytego progu decyzyjnego, w celu uzyskania maksymalnej transparentności. Na samym dole jako realizacja koncepcji wyjaśnialności sztucznej inteligencji (ang. _XAI_ - _Explainable AI_) umieszczony został rozwijany panel wizualizujący wektor atencji. Wykres ten pozwala zidentyfikować krytyczne momenty w nagraniu, które najmocniej wpłynęły na podjętą przez model decyzję. Ze względu na naturę alternatywnych modeli wykorzystujących algorytm lasu losowego, ten panel widoczny jest tylko po inferencji z użyciem modelu BiGRU+Attention.

#figure(
  image("../images/ui/results.png", width: 80%),
  caption: [Panel wyników analizy. Widoczna ocena prawdopodobieństwa kłamstwa, wizualizacja progu decyzyjnego oraz wykres wag atencji wskazujący na podejrzane fragmenty nagrania.]
) <ui-inference-results>