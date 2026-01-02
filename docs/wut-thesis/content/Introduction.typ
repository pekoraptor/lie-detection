#import "../utils.typ": todo, silentheading, flex-caption

= Wstęp <intro>
Żyjemy w społeczeństwie opartym na informacji i zaufaniu. Wiedza w dużej mierze przekazywana jest werbalnie, a prawdomówność rozmówców stanowi fundament efektywnej komunikacji międzyludzkiej. Niestety, kłamstwo jest nieodłącznym elementem ludzkiej natury i może prowadzić do poważnych konsekwencji poczynając od utraty zaufania wśród bliskich osób, uszczerbku emocjonalnego, aż po poważne utraty finansowe w przypadku oszustw czy korupcji, a nawet zagrożenia dla bezpieczeństwa (np. w kontekście terroryzmu).

Kłamstwo towarzyszy nam każdego dnia - zarówno w relacjach prywatnych, biznesowych, na lotniskach i w sądach. Ludzie kłamią z różnych powodów, takich jak unikanie kary, osiąganie korzyści materialnych czy ochrona własnego wizerunku.
W związku z licznymi negatywnymi skutkami nieszczerości, rozwój metod umożliwiających nieinwazyjną i obiektywną weryfikację prawdomówności ma istotne znaczenie w wielu dziedzinach, takich jak wymiar sprawiedliwości, bezpieczeństwo narodowe czy psychologia sądowa.

== Tło problemu <background>
Mimo powszechności zjawiska kłamstwa, ludzie wykazują zaskakująco niską skuteczność w jego rozpoznawaniu. Badania psychologiczne wskazują, że przeciętny człowiek potrafi poprawnie odróżnić prawdę od kłamstwa zaledwie w około 54% przypadków @bond_depaulo_2006. Wynik ten jest zbliżony do losowego rzutu monetą, co podkreśla trudność tego zadania nawet dla doświadczonych obserwatorów. Niska skuteczność wynika z wielu czynników, takich jak umiejętność kontrolowania mimiki twarzy i mowy ciała przez osoby kłamiące, a także zjawiska tzw. _truth bias_ (tendencji do zakładania, że rozmówca mówi prawdę). Często także, niewerbalne sygnały kłamstwa są subtelne i trudne do wychwycenia gołym okiem. Ograniczenia te stwarzają potrzebę opracowania zautomatyzowanych, obiektywnych narzędzi wspierających proces decyzyjny w ocenie prawdomówności.

Podstawą teoretyczną dla budowy takich systemów jest hipoteza _przecieku informacji_ (ang. _leakage hypothesis_), spopularyzowana m.in. przez Paula Ekmana @ekman_leakage_1969. Zakłada ona, że proces kłamania wiąże się ze zwiększonym obciążeniem poznawczym (ang. _cognitive load_). Mózg osoby kłamiącej musi jednocześnie konstruować fałszywą narrację, hamować prawdziwe informacje oraz kontrolować mimikę i mowę ciała, co prowadzi do nieświadomego "wycieku" prawdziwych emocji w formie mimowolnych, trwających ułamki sekund mikroekspresji twarzy, które są trudne do świadomego ukrycia @ekman_telling_lies, ale i praktycznie niemożliwe do wychwycenia bez specjalistycznego treningu lub wsparcia technologicznego.

== Przewaga wizji komputerowej nad metodami tradycyjnymi <computer-vision-for-lie-detection>
Tradycyjne metody instrumentalnej detekcji kłamstwa, takie jak poligraf (wariograf), opierają się na pomiarze fizjologicznych reakcji organizmu: tętna, potliwości skóry, ciśnienia krwi czy częstotliwości oddechu. Choć skuteczne, metody te są inwazyjne - wymagają podłączenia aparatury do ciała badanej osoby oraz obecności wykwalifikowanego operatora, co ogranicza ich zastosowanie w praktyce.

W przeciwieństwie do metod tradycyjnych, metody oparte na _wizji komputerowej_ (ang. _computer vision_) oferują podejście bezkontaktowe. Wykorzystanie kamer oraz algorytmów uczenia maszynowego pozwala na analizę nagrań wideo osób bez konieczności ingerencji fizycznej. Badaniu podlegają: subtelne zmiany w mimice twarzy, ruchy oczu, gesty rąk czy postawa ciała, które mogą dostarczać wskazówek dotyczących prawdomówności. Takie podejście jest mniej stresujące dla badanych, bardziej dyskretne i może być stosowane w szerszym zakresie sytuacji, np. podczas rozmów kwalifikacyjnych, przesłuchań czy monitoringu bezpieczeństwa.

Gwałtowny rozwój technik głębokiego uczenia (ang. _deep learning_) w ostatniej dekadzie, a w szczególności postępy w dziedzinie detekcji obiektów (np. modele YOLO @yolo_2016 użyte w ramach tej pracy) oraz analizy sekwencji czasowych (sieci rekurencyjne LSTM @lstm_1997, GRU), otworzył nowe możliwości w zakresie analizy zachowań niewerbalnych. Współczesne algorytmy potrafią wykrywać i interpretować subtelne wzorce w ogromnych zbiorach danych wideo, wyłapując sygnały zupełnie niedostępne dla ludzkiej percepcji. Niniejsza praca wpisuje się w ten nurt badawczy, eksplorując potencjalne zastosowania wizji komputerowej do automatycznej oceny wiarygodności wypowiedzi na podstawie cech wizualnych.


== Cel pracy <goal>

== Zakres pracy <scope>

== Układ pracy <structure>
