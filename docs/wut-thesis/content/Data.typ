#import "../utils.typ": todo, silentheading, flex-caption

= Przygotowanie danych i inżynieria cech <data-preparation-and-feature-engineering>
Jakość i sposób przygotowania danych są w projektach uczenia maszynowego równie ważne jak architektura wykorzystanych modeli. Nawet najbardziej rozbudowany model niczego się nie nauczy, jeśli do treningu dostanie zaszumione i niereprezentatywne dane. W detekcji kłamstwa, gdzie o etykiecie próbki danych świadczą bardzo subtelne sygnały (takie jak mikroekspresje), adekwatne przygotowanie danych jest kluczowe. W tym rozdziale przedstawiono szczegółowy opis wykorzystanych w pracy zbiorów danych, obejmujący metody ich pozyskania oraz techniki wykorzystane w celu uzyskania jak najlepszej reprezentatywności. Następnie, przedstawiony zostanie kompletny potok przetwarzania danych, poczynając od surowych nagrań wideo, a kończąc na tensorach cech zrozumiałych dla sieci neuronowych. Opisana zostanie także strategia podziału danych na zbiory treningowe, walidacyjne i testowe oraz ich normalizacja. 

== Charakterystyka zbiorów danych <dataset-description>
W pracy wykorzystano dwa zbiory danych, aby sprawdzić zdolność wybranego rozwiązania do nauki na danych przygotowanych w kontrolowanych warunkach laboratoryjnych, jak i jego generalizację w warunkach rzeczywistych (nagranie zbliżone jakością do tych, które będą zamieszczane przez użytkownika końcowego).

=== Silesian Deception Detection Dataset (SDDD) <silesian-deception-detection-dataset>
Zbiór @silesian został użyty jako zbiór podstawowy, z którego model uczy się wskaźników kłamstwa. Został on opracowany przez naukowców z Politechniki Śląskiej @radlak_bozek_2015. Zawiera nagrania 101 uczestników (studentów), co zapewnia wystarczająco dużą różnorodność biometryczną twarzy. Próbki danych zostały zebrane w kontrolowanych warunkach, a w szczególności:
- kontrolowane statyczne oświetlenie,
- jednolite tło,
- kamera ustawiona na wprost.
Taki sposób pozyskania nagrań w pełni eliminuje szum tła, pozwalając modelowi na skupienie się wyłącznie na twarzach uczestników. W procesie tworzenia tego zbioru danych została wykorzystana profesjonalna kamera rejestrująca obraz w rozdzielczości 640x480 pikseli z szybkością 100 klatek na sekundę.

Twórcy @silesian trafnie zauważyli, że w celu pozyskania nagrań zawierających naturalne wskaźniki nieszczerości trzeba stworzyć środowisko, w którym kłamstwo uczestników będzie znaczące, a nie tylko z góry narzucone. W tym celu, nagrania zostały przeprowadzone jako badanie rzekomych zdolności telepatycznych pewnej osoby. Przed uczestnikiem stał laptop, na którego ekranie wyświetlała się figura geometryczna oraz polecenie "skłam" lub "powiedz prawdę". Usadzony na przeciwko niego był rzekomy telepata, który miał czytając im w myślach zadecydować czy na ekranie faktycznie jest dana figura geometryczna czy nie. Obecność kamer została uzasadniona wykluczeniem możliwości niewerbalnego podpowiadania telepacie, a jedna z nich była skierowana właśnie na niego w celu zwiększenia immersji tej narracji. Dzięki tym zabiegom, udało się uchwycić zachowania zbliżone do tych, które występują podczas prawdziwego kłamania - spontaniczne, niekontrolowane reakcje mimiczne, mikroekspresje i napięcie emocjonalne.

Nagranie każdego uczestnika zawiera w sobie dziesięć próbek danych. Proces opisany wcześniej był ustrukturyzowany w taki sposób, że uczestnik wypowiadał się dziesięć razy, gdzie pierwsza, druga i ostatnia wypowiedź miała być szczera, a pozostałe - kłamstwami. Z tego powodu zbiór jest silnie niezbalansowany - 70% przykładów to kłamstwa. Taka struktura nagrań wymaga ręcznej ich segmentacji, w czym pomagają załączone pliki o formacie `.eaf`, zawierające m.in. informację o tym w jakich przedziałach czasowych zamyka się pojedyncza wypowiedź. W plikach tych zaznaczone są także odstępstwa od scenariusza - momenty, w których zaszła pomyłka i w miejscu kłamstwa pojawiła się prawda, itp. Takie przykłady musiały zostać odrzucone. Po usunięciu wadliwych próbek, zbiór składa się z 924 przykładów.

=== Real-Life Deception Detection Dataset <real-life-deception-dataset>
W przeciwieństwie do nagrań ze zbioru @silesian przygotowanych w warunkach laboratoryjnych, @real_life_ddd @perez-rosas_abouelenien_mihalcea_burzo_2015 składa się z klipów pochodzących z prawdziwych procesów sądowych (głównie z USA) - fragmenty zeznań świadków oraz wyjaśnień oskarżonych. Zbiór zawiera zaledwie 121 nagrań, lecz ze względu na liczebność klas jest niemal idealnie zbalansowany - 61 kłamstw i 60 wypowiedzi szczerych.

Ze względu na okoliczności powstania nagrań (środowisko sali sądowej bez reżysera ani naukowców), są one niezwykle reprezentatywne. Kłamstwa zawarte w filmach są rzeczywistymi i naturalnymi kłamstwami wysokiej wagi (ang. _High-Stakes Lies_). Przedstawieni w nich ludzie kłamią walcząc o swoją przyszłość, reputację, a nawet życie. Takie wypowiedzi wiążą się z ogromnym obciążeniem poznawczym (ang. _cognitive load_) i silnym stresem, co stwarza idealne warunki do wystąpienia silnych i trudnych do ukrycia mikroekspresji oraz mimowolnych ruchów mięśni twarzy, których nie da się zreplikować w kontrolowanych warunkach eksperymentu laboratoryjnego. Dzięki temu zbiór ten pozwala zweryfikować użyteczność modelu w systemach bezpieczeństwa, gdzie celem jest wykrywanie realnych zagrożeń, a nie akademickiego kłamstwa.

W przeciwieństwie do statycznej kamery i oświetlenia w @silesian, w tym zbiorze z powodu rozproszonego sposobu pozyskania nagrań (różne sale sądowe), cechują się one:
- różnymi kątami kamery (niekoniecznie na wprost),
- zmiennym oświetleniem,
- ruchami kamery,
- przysłonięciami twarzy (np. ręką lub mikrofonem).
To właśnie te ograniczenia sprawiają, że zbiór ten jest idealnym zasobem testowym dla odporności modelu na szum i jego zdolności generalizacji.

Etykiety przykładów z tego zbioru zostały przypisane na podstawie ostatecznych werdyktów sądowych oraz zweryfikowanych przez policję faktów. Choć system sądowniczy nie jest perfekcyjnie wiarygodny i nieomylny, jest to najlepsze przybliżenie prawdy dostępne dla danych rzeczywistych.

Porównanie przykładowych klatek z obu zbiorów zostało przedstawione na #link(<datasets-comparison>)[obrazku poniżej].

#figure(
  grid(
    columns: (1fr, 1.335fr),
    gutter: 3mm,
    image("../images/example_frames/silesian.png", width: 100%),
    image("../images/example_frames/real_life.png", width: 100%),
  ),
  caption: [
    Porównanie jakości próbek w wykorzystanych zbiorach danych. 
    Po lewej: przykładowa klatka ze zbioru @silesian - widoczne idealne oświetlenie, jednolite tło i statyczna pozycja. 
    Po prawej: przykładowa klatka ze zbioru @real_life_ddd - niska rozdzielczość, małe zbliżenie i niejednolite tło.
  ],
) <datasets-comparison>

== Potok przetwarzania obrazu <image-processing-pipeline>
=== Cel potoku i zastosowanie downsamplingu <pipeline-purpose>
Celem przedstawionego potoku jest transformacja surowego nagrania wideo w ustrukturyzowany zbiór wyekstrahowanych cech numerycznych w postaci wektorów, które mogą być podane do sieci neuronowej. Proces odbywa się klatka po klatce, ale z zastosowaniem downsamplingu. Sieci rekurencyjne nie radzą sobie z bardzo długimi sekwencjami. Z tego powodu zdecydowano się na analizę co n-tej klatki w celu redukcji wymiarowości finalnych wektorów. Pozwoliło to także na ujednolicenie szybkości nagrań pochodzących z obu zbiorów. W przypadku @silesian zawierającego nagrania w stu klatkach na sekundę, brano co dziesiątą klatkę, a w przypadku @real_life_ddd, gdzie nagrania mają 30 fps (_frames per second_) - co trzecią klatkę. Dzięki temu finalne wektory pochodzące z obu zbiorów mają jednolitą liczbę wartości cech na sekundę (10), a zatem percepcja czasu sieci rekurencyjnej będzie zachowana. W przypadku niezastosowania takiego ujednolicenia, ruchy i zdarzenia z obu zbiorów znacznie różniłyby się szybkością, co mogłoby być nieoptymalne dla skuteczności modelu.

=== Segmentacja nagrań wideo <video-segmentation>
W przypadku zbioru @silesian kluczowe było odpowiednie podzielenie nagrań na próbki, gdyż oryginalne wideo zawierają dziesięć wypowiedzi, co jest jednoznaczne z dziesięcioma próbkami danych. W tym celu utworzono parser plików `.eaf`, w których zawarte były znaczniki czasowe (ang. _timestamps_) pojedynczych wypowiedzi. 
Nagrania ze zbioru @real_life_ddd natomiast, zostały potraktowane jako pojedyncze segmenty.

=== Lokalizacja i izolacja twarzy <face-localization-and-isolation>
Wykorzystano model YOLOv8-nano do detekcji twarzy i wycięcia obszaru zainteresowania (region twarzy) z całej klatki. Dzięki temu zabiegowi, tło tworzące nieistotny szum zostaje usunięte. Wykadrowany ROI (_Region of Interest_) zostaje przeskalowany do rozdzielczości 224x224 pikseli, która jest standardem dla większości architektur sieci neuronowych (w tym MediaPipe FaceMesh oraz model używany do detekcji emocji).

=== Ekstrakcja punktów charakterystycznych i normalizacja geometryczna twarzy <landmark-extraction-and-geometric-normalization>
Mediapipe FaceMesh został zastosowany w celu ekstrakcji współrzędnych punktów charakterystycznych twarzy. Na ich podstawie dokonywana jest normalizacja geometrii twarzy - wyznaczane są środki oczu oraz kąt nachylenia głowy i względem ich wykrywana jest rotacja obrazu uzyskująca poziomą linię oczu. Jest to krok wymagany przed podaniem do modelu wykrywającego emocje, który został wytrenowany na zdjęciach frontalnych i wymaga wyrównanej twarzy do poprawnej detekcji.

=== Detekcja emocji <emotion-detection>
Znormalizowany geometrycznie obraz trafia do modułu rozpoznawania emocji. Do tego zadania została wykorzystana konwolucyjna sieć neuronowa (model Facial Emotion Recognition @facial_emotion_recognition_lib wytrenowana na zbiorze @goodfellow2013challenges), która klasyfikuje wyraz twarzy do jednej z siedmiu podstawowych kategorii: złość, obrzydzenie, strach, radość, smutek, zaskoczenie oraz wyraz neutralny. Model zwraca wektor prawdopodobieństw (z dystrybucji Softmax) określający pewność modelu co do wystąpienia każdej z wyżej wymienionych emocji.

=== Wynik potoku przetwarzania <final-feature-vector>
Z każdej analizowanej klatki uzyskiwany jest wektor cech, w którego skład wchodzą:
- *Globalna pozycja głowy* - współrzędne środka ramki ograniczającej twarz (_bounding box_) oraz jej szerokość. Pozwala to modelowi klasyfikacyjnemu na śledzenie ruchów ciała (np. wiercenie się na krześle lub "zastyganie" wynikające ze stresu związanego z kłamstwem) oraz zmiany dystansu od kamery, które zostałyby utracone w procesie kadrowania samej twarzy. 
- *Morfologia twarzy* - współrzędne 478 punktów charakterystycznych z siatki MediaPipe.
- *Pozycja głowy* - estymowane kąty Eulera (Pitch, Yaw, Roll) opisujące rotację głowy w trójwymiarowej przestrzeni.
- *Emocje* - prawdopodobieństwa wystąpienia siedmiu podstawowych emocji.
- *Optical Flow* - średnia i odchylenie standardowe gęstego przepływu optycznego w osiach X i Y obliczone z użyciem algorytmu Farnebacka względem poprzedniej przetworzonej klatki.

Diagram potoku przetwarzania obrazu został przedstawiony na #link(<pipeline>)[obrazku poniżej].

#figure(
  image("../images/diagrams/pipeline.drawio.pdf", width: 85%),
  caption: [
    Schemat blokowy potoku przetwarzania obrazu.
  ],
)<pipeline>


== Inżynieria cech <feature-engineering>
Potok przetwarzania obrazu przedstawiony w poprzedniej sekcji wyciągał informacje z nagrań i przekształcał je na wektory cech. W tym podrozdziale, natomiast, przedstawiony będzie proces transformacji ich w inteligentne wskaźniki, które ułatwią modelom nauczenie się rozpoznawania kłamstwa.

=== Wygładzenie sygnału (Noise reduction and smoothing) <noise-reduction-and-smoothing>
Surowe dane pochodzące z potoku przetwarzania bywają zaszumione. Klatka po klatce, wartości cech mogą drgać (tzw. _jitter_), a wynika to z ograniczonej dokładności użytych detektorów i algorytmów. Zastosowanie średniej kroczącej (ang. _rolling window average_) o oknie długości 5 klatek na cechach, takich jak pozycja głowy (Pitch, Yaw, Roll) oraz parametry ramki ograniczającej twarz (współrzędne jej środka i jej szerokość) pozwala na usunięcie szumu pomiarowego przy jednoczesnym zachowaniu rzeczywistych ruchów ciała i głowy.

=== Redukcja wymiarowości <dimensionality-reduction>
Wektory cech uzyskane z potoku przetwarzania składają się z aż 973 elementów na jedną klatkę z nagrania. Bezpośrednie podanie sekwencji zawierających aż tyle cech, przy tak małej ilości próbek (poniżej 1000) wiąże się z ogromnym ryzykiem przeuczenia - model zapamiętałby dokładnie każdą z próbek ze zbioru treningowego ale zupełnie poległby na nowych danych. Z tego powodu, postanowiono zredukować wymiarowość wektorów. Znaczna większość cech (956) to współrzędne landmarków, więc są one idealną podgrupą cech do zredukowania. Na podstawie współrzędnych punktów charakterystycznych wyliczane są odległości między kluczowymi parami:
- *Oczy* (wskaźnik *EAR* - _Eye Aspect Ratio_): odległość między powiekami,
- *Usta* (*MAR* - _Mouth Aspect Ratio_): ich szerokość i wysokość,
- *Brwi*: odległość brwi od oka.

Decyzja o wyborze tych konkretnych obszarów anatomicznych została podyktowana przesłankami psychologicznymi, wynikającymi z omówionych wcześniej teorii Paula Ekmana oraz Mirona Zuckermana. Okolice oczu i brwi są kluczowe dla wykrywania mikroekspresji, a także pozwalają na analizę częstotliwości mrugania, która zmienia się wraz ze wzrostem obciążenia poznawczego. Z kolei analiza okolic ust pozwala na identyfikację subtelnych sygnałów stresu, takich jak zaciskanie warg czy wymuszone uśmiechy, a także umożliwia odróżnienie momentów mówienia od ekspresji mimicznej. Skupienie się na tych rejonach pozwala na odrzucenie szumu informacyjnego pochodzącego z mniej istotnych części twarzy (np. policzków czy brody), które w mniejszym stopniu powiązane są z ekspresją emocjonalną wynikającą z nieszczerości.

W ten sposób, zachowując istotną część informacji, udało się zredukować długość wektorów do zaledwie 23 elementów, co stanowi znaczną poprawę względem początkowych 973.

Problemem tego podejścia jest fakt, że te dystanse (w pikselach) zależne są od jakości utworzonej przez YOLO ramki ograniczającej oraz biometrii twarzy danej osoby. Z tego powodu, wszystkie wyliczone dystanse geometryczne dzielone są przez wysokość twarzy zdefiniowaną jako odległość między górnym krańcem czoła a dolnym zwieńczeniem podbródka w danej klatce. Dodatkowo, od każdego wyliczonego dystansu odejmowana jest jego średnia wartość z całego nagrania (_zero-centering_). Dzięki tym zabiegom, model nie będzie uczył się zależności między fizjologią osób a ich szczerością, lecz będzie analizował zmiany tych cech względem stanu spoczynkowego danej osoby, a zatem efektywnie wykrywał mikroekspresje.

=== Analiza dynamiki i prędkości cech (_Velocity Features_) <velocity-features>
Surowe koordynaty obszaru twarzy same w sobie nie są zbytnio informatywne. Fakt, że twarz znajduje się na lewej połowie klatki nie niesie za sobą znaczącej informacji o szczerości wypowiedzi. Obliczenie pierwszej pochodnej (a de facto prędkości zmiany położenia twarzy) pozwala na wykrycie nerwowości ruchów oraz gwałtowności reakcji.

=== Augmentacja danych <data-augmentation>
Do finalnego wektora uzyskanego z użyciem wyżej opisanych technik dodawany jest losowy szum gaussowski o odchyleniu standardowym 0,05. Zapobiega to przeuczeniu się sieci na specyficznych, dokładnych wartościach liczbowych i zmusza ją do nauki ogólnych wzorców, co zwiększa odporność na błędy detekcji w warunkach rzeczywistych, a zarazem wspiera regularyzację modelu.

== Strategia podziału danych i walidacji <data-split-strategy>
Dane dzielone są na trzy podzbiory: 
- Zbiór treningowy (80% próbek) - jest używany bezpośrednio w trakcie nauki modelu jako jego wejście, służąc do optymalizacji wag modelu,
- Zbiór walidacyjny (10% próbek) - służy do ewaluacji skuteczności modelu w trakcie treningu,
- Zbiór testowy (10% próbek) - używany jest do finalnego sprawdzenia skuteczności wytrenowanego już modelu. 

Podział losowy wszystkich próbek skutkowałby prawdopodobnym wystąpieniem nagrań jednej osoby w ponad jednym zbiorze. Takie zjawisko, zwane wyciekiem tożsamości/danych (ang. _identity/data leakage_), może mieć katastrofalne konsekwencje - model nauczyłby się mimiki konkretnych osób zamiast uczyć się uniwersalnych wskaźników kłamstwa, co zwiększyłoby jego skuteczność, ale nie w sposób pożadany - dokładność na nowych danych byłaby wciąż niska. Aby temu zapobiec, dane zostały podzielone z wykorzystaniem podejścia _Subject Independent_, gdzie każdej osobie przydzielony został identyfikator, a następnie nagrania zostały podzielone w rozłączne grupy względem nich.

W przypadku zbioru @silesian, ze względu na ustrukturyzowany przebieg pozyskiwania nagrań (każdy uczestnik nagrywał 3 wypowiedzi szczere i 7 kłamstw), taki podział naturalnie zachowywał globalną dystrybucję etykiet w każdym z podzbiorów. Natomiast dla zbioru @real_life_ddd, gdzie każde nagranie przedstawia inną osobę, wymagana była jawna stratyfikacja podziału, aby wymusić równomierny rozkład etykiet w zbiorze treningowym, walidacyjnym i testowym.

== Normalizacja i przygotowanie sekwencji <normalization-and-sequence-preparation>

=== Normalizacja danych (_MinMaxScaling_) <data-normalization>
Różne grupy cech mają bardzo odmienne zakresy wartości. Emocje są prawdopodobieństwami z zakresu $[0,1]$, a kąty głowy (Pitch, Yaw, Roll) są w stopniach $[-90, 90]$. Podanie takich danych do sieci neuronowej bez skalowania spowodowałoby, że cechy o większych wartościach zdominowałyby proces uczenia, a subtelne sygnały nie byłyby w ogóle brane pod uwagę. W celu wyrównania zakresów wartości cech zastosowano skalowanie liniowe do przedziału $[-1,1]$ z użyciem `MinMaxScaler` z bibliotek `scikit-learn`. Funkcje aktywacji powszechnie używane w sieciach rekurencyjnych (takie jak tangens hiperboliczny `tanh`) operują właśnie na takim zakresie. Dopasowanie danych treningowych do tego zakresu przyspiesza trening. 

W projekcie zostały użyte 4 niezależne instancje skalerów w celu oddzielnego przeskalowania różnych grup cech, odpowiednio kolumny dotyczące:
- Optical Flow,
- emocji,
- rotacji głowy,
- pozycji prostokąta ograniczającego twarz.
Skalowanie dystansów między punktami charakterystycznymi nie było konieczne, ze względu na opisane wcześniej techniki - wartości już są w odpowiednim zakresie.

Skalery zostały dopasowane (`fit`) wyłącznie na zbiorze treningowym, a następnie przy użyciu wyliczonych już parametrów nastąpiło przekształcenie (`transform`) zbioru testowego i walidacyjnego. Taka strategia zapobiega wyciekowi danych. Gdyby skaler został dopasowany na wszystkich danych, model w trakcie treningu poznałby globalną dystrybucję wartości cech, co sztucznie zawyżyłoby wyniki.

=== Przygotowanie sekwencji <sequence-preparation>
Nagrania wideo naturalnie mają różne czasy trwania. Sieci neuronowe trenowane paczkami danych (_batch_) wymagają jednak tensorów o regularnych kształtach (prostokątnych macierzy). W celu ujednolicenia długości sekwencji wykorzystano technikę paddingu, w której wszystkie próbki w ramach jednego batcha zostają wydłużone do wyrównania z najdłuższym nagraniem z paczki. Brakujące klatki zostają wypełnione stałą wartością $-10$, która została specjalnie wybrana spoza zakresu wartości cech w celu odróżnienia jej od nich. Wartość ta jest traktowana jako pusta informacja. Aby model nie uczył się na sztucznym dopełnieniu, generowany jest dodatkowy wektor (maska) informujący o rzeczywistej długości każdej z sekwencji. Dzięki temu sieć rekurencyjna GRU wie, w którym momencie zatrzymać aktualizację stanu ukrytego dla danej próbki.

Finalnie wektory cech (trzymane wcześniej w numpy arrays) konwertowane są do tensorów PyTorch, które są natywną strukturą danych dla operacji na karcie graficznej GPU, gdzie wykonywany jest trening sieci neuronowych.
