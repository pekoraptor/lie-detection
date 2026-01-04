#import "../utils.typ": todo, silentheading, flex-caption

= Wstęp <intro>
Żyjemy w społeczeństwie opartym na informacji i zaufaniu. Wiedza w dużej mierze przekazywana jest werbalnie, a prawdomówność rozmówców stanowi fundament efektywnej komunikacji międzyludzkiej. Niestety, kłamstwo jest nieodłącznym elementem ludzkiej natury i może prowadzić do poważnych konsekwencji poczynając od utraty zaufania wśród bliskich osób, uszczerbku emocjonalnego, aż po poważne utraty finansowe w przypadku oszustw czy korupcji, a nawet zagrożenia dla bezpieczeństwa (np. w kontekście terroryzmu).

Kłamstwo towarzyszy nam każdego dnia - zarówno w relacjach prywatnych, biznesowych, na lotniskach i w sądach. Ludzie kłamią z różnych powodów, takich jak unikanie kary, osiąganie korzyści materialnych czy ochrona własnego wizerunku.
W związku z licznymi negatywnymi skutkami nieszczerości, rozwój metod umożliwiających nieinwazyjną i obiektywną weryfikację prawdomówności ma istotne znaczenie w wielu dziedzinach, takich jak wymiar sprawiedliwości, bezpieczeństwo narodowe czy psychologia sądowa.

== Tło problemu <background>
Mimo wszechobecności zjawiska kłamstwa, ludzie wykazują zaskakująco niską skuteczność w jego rozpoznawaniu. Badania psychologiczne wskazują, że przeciętny człowiek potrafi poprawnie odróżnić prawdę od kłamstwa zaledwie w około 54% przypadków @bond_depaulo_2006. Wynik ten jest zbliżony do losowego rzutu monetą, co podkreśla trudność tego zadania nawet dla doświadczonych obserwatorów. Niska skuteczność wynika z wielu czynników, takich jak umiejętność kontrolowania mimiki twarzy i mowy ciała przez osoby kłamiące, a także zjawiska tzw. _truth bias_ (tendencji do zakładania, że rozmówca mówi prawdę). Często także, niewerbalne sygnały kłamstwa są subtelne i trudne do wychwycenia gołym okiem. Ograniczenia te stwarzają potrzebę opracowania zautomatyzowanych, obiektywnych narzędzi wspierających proces decyzyjny w ocenie prawdomówności.

Podstawą teoretyczną dla budowy takich systemów jest hipoteza _przecieku informacji_ (ang. _leakage hypothesis_), spopularyzowana m.in. przez Paula Ekmana @ekman_leakage_1969. Zakłada ona, że proces kłamania wiąże się ze zwiększonym obciążeniem poznawczym (ang. _cognitive load_). Mózg osoby kłamiącej musi jednocześnie konstruować fałszywą narrację, hamować prawdziwe informacje oraz kontrolować mimikę i mowę ciała, co prowadzi do nieświadomego "wycieku" prawdziwych emocji w formie mimowolnych, trwających ułamki sekund mikroekspresji twarzy, które są trudne do świadomego ukrycia @ekman_telling_lies, ale i praktycznie niemożliwe do wychwycenia bez specjalistycznego treningu lub wsparcia technologicznego.

== Przewaga wizji komputerowej nad metodami tradycyjnymi <computer-vision-for-lie-detection>
Tradycyjne metody instrumentalnej detekcji kłamstwa, takie jak poligraf (wariograf), opierają się na pomiarze fizjologicznych reakcji organizmu: tętna, potliwości skóry, ciśnienia krwi czy częstotliwości oddechu. Choć skuteczne, metody te są inwazyjne - wymagają podłączenia aparatury do ciała badanej osoby oraz obecności wykwalifikowanego operatora, co ogranicza ich zastosowanie w praktyce.

W przeciwieństwie do metod tradycyjnych, metody oparte na _wizji komputerowej_ (ang. _computer vision_) oferują podejście bezkontaktowe. Wykorzystanie kamer oraz algorytmów uczenia maszynowego pozwala na analizę nagrań wideo osób bez konieczności ingerencji fizycznej. Badaniu podlegają: subtelne zmiany w mimice twarzy, ruchy oczu, gesty rąk czy postawa ciała, które mogą dostarczać wskazówek dotyczących prawdomówności. Takie podejście jest mniej stresujące dla badanych, bardziej dyskretne i może być stosowane w szerszym zakresie sytuacji, np. podczas rozmów kwalifikacyjnych, przesłuchań czy monitoringu bezpieczeństwa.

Gwałtowny rozwój technik głębokiego uczenia (ang. _deep learning_) w ostatniej dekadzie, a w szczególności postępy w dziedzinie detekcji obiektów (np. modele YOLO @yolo_2016 użyte w ramach tej pracy) oraz analizy sekwencji czasowych (sieci rekurencyjne LSTM @lstm_1997, GRU), otworzył nowe możliwości w zakresie analizy zachowań niewerbalnych. Współczesne algorytmy potrafią wykrywać i interpretować subtelne wzorce w ogromnych zbiorach danych wideo, wyłapując sygnały zupełnie niedostępne dla ludzkiej percepcji. Niniejsza praca wpisuje się w ten nurt badawczy, eksplorując potencjalne zastosowania wizji komputerowej do automatycznej oceny wiarygodności wypowiedzi na podstawie cech wizualnych.

== Cel pracy <goal>
Głównym celem niniejszej pracy inżynierskiej jest zaimplementowanie kompletnego systemu informatycznego, wykorzystującego metody wizji komputerowej i algorytmy sztucznej inteligencji do wspierania człowieka w ocenie wiarygodności wypowiedzi na podstawie analizy nagrań wideo. Cel ten został zrealizonany w aspekcie badawczym oraz aplikacyjnym.

Celem badawczym było zbadanie, czy cechy wizualne (mimika, ruchy głowy i reszty ciała, itd.) są wystarczająco informatywne, aby umożliwić skuteczną klasyfikację z dokładnością przewyższającą ludzką percepcję. W tym celu przeprowadzono eksperymenty porównujące różne podejścia modelowe oraz metody ekstrakcji cech z filmów. Dodatkowo, zbadano wpływ technik takich jak transfer learning czy inżynieria cech na zdolność generalizacji modeli.

Celem inżynierskim było zaprojektowanie i utworzenie aplikacji webowej, umożliwiającej użytkownikowi bez technicznego wykształcenia wgranie nagrania wideo i otrzymanie predykcji modelu dotyczącej prawdomówności wypowiedzi.

== Zakres pracy <scope>
Realizacja zamierzonego celu wymagała przeprowadzenia szeregu prac badawczych i programistycznych. Zakres pracy obejmował:
+ analizę literatury dotyczącej psychologii kłamstwa, metod wizji komputerowej oraz algorytmów uczenia maszynowego stosowanych w detekcji kłamstwa.
+ pozyskanie zbiorów danych wideo zawierających nagrania osób mówiących prawdę i kłamiących: @silesian @radlak_bozek_2015 oraz @real_life_ddd @perez-rosas_abouelenien_mihalcea_burzo_2015.
+ utworzenie potoku przetwarzania danych (_pipeline_) przekształcającego surowe nagrania wideo na wektory cech wizualnych przystosowanych do trenowania modeli sztucznej inteligencji i zastosowanie go na wyżej wymienionych danych.
+ budowę i trening modeli, m.in.:
  - implementacja wybranych architektur modeli
  - zaprojektowanie efektywnego procesu uczenia, poprzez dobór odpowiednich funkcji straty, optymalizatorów i strategii treningowych.
+ przeprowadzenie eksperymentów badawczych, obejmujących:
  - strojenie hiperparametrów
  - analizę ważności cech
  - inzynierię cech
  - weryfikację skuteczności techniki _transfer learningu_
  - porównanie skuteczności różnych rozwiązań
+ stworzenie interfejsu dla użytkownika końcowego z wykorzystaniem frameworku Streamlit, umożliwiającego praktyczne zastosowanie finalnie wybranego rozwiązania.

== Układ pracy <structure>
Niniejsza praca została podzielona na *siedem rozdziałów*, których treść układa się w logiczny ciąg wprowadzający czytelnika w tematykę, poczynając od podstaw wymaganych do zrozumienia dalej opisanych zagadnień, a kończąc na szczegółowym omówieniu przeprowadzonych badań i uzyskanych wyników.
- *Rozdział drugi* zawiera podstawy teoretyczne dotyczące psychologii kłamstwa, metod wizji komputerowej, zagadnień związanych z uczeniem maszynowym, a także przegląd istniejących rozwiązań w dziedzinie automatycznej detekcji kłamstwa (_state of the art_).
- *Rozdział trzeci* skupia się na danych wykorzystywanych w pracy, opisując zbiory danych, techniki ekstrakcji cech wizualnych oraz proces przystosowania danych do trenowania modeli, poczynając od segmentacji wideo na próbki treningowe, poprzez cały potok przetwarzania, aż po ich normalizację.
- W *rozdziale czwartym* przedstawione są architektury i szczegóły implementacyjne modeli wykorzystanych do klasyfikacji binarnej nagrań, opisany jest proces ich trenowania oraz zastosowane techniki poprawiające zdolność generalizacji modeli.
- *Rozdział piąty* składa się z opisu przeprowadzonych eksperymentów badawczych, analizy uzyskanych wyników, w tym: metryk skuteczności, analizy ważności cech, wpływu inżynierii cech i transfer learningu na efektywność modeli.
- *Rozdział szósty* poświęcony jest praktycznemu zastosowaniu opracowanego rozwiązania, opisując implementację i funkcjonalności aplikacji webowej, utworzonej w celu przedstawienia możliwości systemu użytkownikowi nieposiadającemu wiedzy technicznej.
- W *rozdziale siódmym* zawarte są wnioski końcowe z realizacji projektu, ocena osiągniętych rezultatów oraz propozycje dla dalszego rozwoju i badań w tym obszarze.