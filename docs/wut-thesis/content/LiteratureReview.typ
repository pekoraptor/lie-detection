#import "../utils.typ": todo, silentheading, flex-caption

= Teoria i przegląd literatury <literature-review>
Niniejszy rozdział ma na celu zdefiniowanie podstaw teoretycznych, które zostały bezpośrednio wykorzystane w dalszych rozdziałach pracy i ma służyć jako wprowadzenie do zagadnień związanych z tematyką kłamstwa i jego automatycznej detekcji z użyciem wizji komputerowej oraz uczenia maszynowego. Ten projekt naturalnie łączy wiedzę z różnych dziedzin naukowych, w tym psychologii behawioralnej, inżynierii oprogramowania i sztucznej inteligencji. Dlatego, aby zapewnić czytelnikowi pełne zrozumienie kontekstu i podstaw teoretycznych, rozdział ten obejmuje zagadnienia ze wszystkich tych obszarów. 

Na początku omówione zostanie w jaki sposób kłamstwo formułowane jest w ludzkim umyśle i po czym można rozpoznać jego zaistnienie w zachowaniu niewerbalnym. Następnie, wytłumaczone zostaną podstawowe metody wizji komputerowej wykorzystywane do analizy cech, takich jak mimika twarzy czy ruchy ciała. Kolejna sekcja przedstawi działanie wybranych algorytmów uczenia maszynowego, które zostały zastosowane w pracy jako modele klasyfikacyjne. Na koniec zaprezentowany zostanie przegląd istniejących już rozwiązań w dziedzinie automatycznej analizy wiarygodności wypowiedzi (_state of the art_), co stanowi punkt odniesienia dla podejścia zaproponowanego w tej pracy.

== Psychologiczne aspekty kłamstwa <psychological-aspects-of-lie-detection>
=== Formalna definicja kłamstwa <definition-of-lie>
Według Alderta Vrija kłamstwo definiuje się jako "świadomą próbę wywołania u innej osoby przekonania, które sam mówiący uważa za nieprawdziwe"  @vrij_detecting_lies_2008. Oznacza to, że akt skłamania wiąże się z intencją - zwykła pomyłka nie jest kłamstwem w sensie psychologicznym, pomimo iż wypowiadane słowa są fałszywe. Podobnie, aktor grający pewną rolę także mówi nieprawdę, ale nie uznaje się tego za kłamstwo, gdyż widzowie na wstępie zakładają, że sztuka niekoniecznie jest faktem. Psychologicznie takie sytuacje są zupełnie odmienne dla mózgu człowieka wypowiadającego się, co przejawia się w jego zachowaniu. Różnice te mogą być wychwycone i sklasyfikowane przez system wizyjny nieznający kontekstu wypowiedzi ani obiektywnej prawdy.

=== Teoria obciążenia poznawczego (ang. _Cognitive Load Theory_) <cognitive-load-theory>
Miron Zuckerman zaproponował teorię obciążenia poznawczego zakładającą, że kłamstwo jest znacznie bardziej wymagające mentalnie niż mówienie prawdy @zuckerman_verbal_nonverbal_1981. Kłamca musi jednocześnie tworzyć spójną i wiarygodną fałszywą narrację, zapamiętując jej szczegóły, tym samym hamując prawdę. Dodatkowo, stara się kontrolować swoją mowę ciała, żeby zminimalizować ryzyko ujawnienia nieszczerości, obserwując w tym samym czasie reakcję rozmówcy. 

Próba równoczesnego skupienia się na tylu zadaniach prowadzi do przeciążenia mózgu, który w efekcie ogranicza zasoby przeznaczone na nieświadomą kontrolę ciała. Skutkuje to widocznymi zmianami mowy ciała, m.in. w częstotliwości mrugania, które staje się rzadsze w czasie wypowiadania kłamstwa (efekt skupienia), a chwilę po skończeniu wypowiedzi następuje znaczne jego przyspieszenie (efekt kompensacji). Ponadto, ciało oraz głowa kłamiącego wykazują się nienaturalną sztywnością - zastygają one w bezruchu na rzecz podświadomej próby uniknięcia wykonania gestu, który mógłby zasugerować rozmówcy, iż jest on okłamywany.

=== Hipoteza przecieku prawdziwych emocji (ang. _Leakage Hypothesis_) <leakage-hypothesis>
Kłamstwo naturalnie wiąże się z intensywnymi emocjami, takimi jak stres czy strach (przed ujawnieniem nieszczerości), ale także ekscytacja i satysfakcja (z udanego wprowadzenia rozmówcy w błąd, tzw. _duping delight_ @ekman_telling_lies). Hipoteza przecieku sformułowana przez Paula Ekmana i Wallace'a Friesena mówi, że prawdziwe emocje "wyciekają" nawet przy próbie świadomego ich ukrycia @ekman_leakage_1969. Wypowiadane słowa są łatwo kontrolowane, jednak mimika twarzy, ton głosu i ruchy ciała mogą odzwierciedlać stan emocjonalny bez wiedzy ani kontroli człowieka. 

Ruchy twarzy mają dwoistą naturę. Z jednej strony, mięśnie są sterowane świadomie, dzięki czemu możemy się uśmiechnąć do zdjęcia lub zaśmiać się na zawołanie. Z drugiej strony mięśnie te mogą być też sterowane podświadomie, czego przykładem jest prawdziwy uśmiech angażujący mięśnie z okolic oczu. Kłamstwo powoduje konflikt między tymi systemami, co skutkuje wystąpieniem zjawiska bardzo szybkich nieświadomych ruchów mięśni twarzy, zwanych *mikroekspresjami*. Prawdziwa emocja pojawia się na ułamek sekundy (od 1/25 do 1/5 sekundy), zanim człowiek zdąży przybrać "maskę", za którą ją schowa. W badaniach łączących nieszczerość z ekspresjami niewerbalnymi twarzy, aż 98,3% uczestników wykazało "przeciek", próbując ukryć intensywną emocję @porter_brinke_wallace_2011. Ponadto, dowiedziono, że mechanizm ten jest uniwersalny kulturowo @ekman_friesen_1971 i biologicznie @ekman_1992_argument (co wykazano m.in. w eksperymentach z udziałem odizolowanych społeczności w Papui-Nowej Gwinei), przez co może być zaobserwowany u ludzi z różnych krajów i kultur.

Z powodu niezwykle krótkiego okresu trwania tego zjawiska jest ono często niewykrywalne dla ludzkiego oka. Natomiast kamera nagrywająca chociażby w 30 klatkach na sekundę wyłapie ten jeden moment, co pozwala na analizę poklatkową - zatrzymanie czasu i zauważenie tego, co dla oka jest zaledwie mignięciem.

== Metody wizji komputerowej w analizie twarzy <computer-vision-in-face-analysis>
=== Detekcja obiektów i twarzy <object-and-face-detection>
Na początek, ważne jest sprecyzowanie różnicy między klasyfikacją a detekcją obiektów. Klasyfikacja odpowiada na pytanie: "Czy dany obiekt (twarz) znajduje się na obrazie?". Detekcja natomiast nie tylko klasyfikuje zbiór pikseli jako dany obiekt, ale i tworzy ramkę ograniczającą go o współrzędnych `[x, y, w, h]`, gdzie `x` i `y` to współrzędne lewego górnego wierzchołka ramki, a `w` i `h` to odpowiednio jej szerokość i wysokość. Informacje uzyskane z użycia detekcji obiektów mogą zostać użyte do redukcji rozmiaru klatki z nagrania do minimalnego regionu zawierającego twarz - obszar zainteresowania (ang. _region of interest_), dzięki czemu znaczna ilość szumu (tło) zostaje pominięta.

Klasyczne metody detekcji twarzy na obrazie, takie jak kaskady Haara były rewolucyjne 20 lat temu - w momencie ich utworzenia przez Paula Violę i Michaela J Jonesa @viola_jones_2004. Są one szybkie, lecz mało dokładne w przypadku obrotów głowy i słabego oświetlenia obiektu. Współczesną alternatywą są metody oparte na konwolucyjnych sieciach neuronowych. Są one odporne na obroty, niekorzystne oświetlenie, a nawet przesłonięcia obiektu.

Najbardziej obiecującym rozwiązaniem jest architektura YOLO (_"You Only Look Once"_) @yolo_2016, którego zaletą jest zaskakująca szybkość wykrywania obiektów. Modele te "patrzą" na obraz tylko jeden raz, co wprowadza ich przewagę nad starszymi modelami (np. R-CNN), które działały dwuetapowo. Najpierw znajdowały one na obrazie regiony, w których mógł występować wykrywany obiekt, a następnie sprawdzały każdy z tych regionów. Niosło to za sobą niemały narzut wydajnościowy. YOLO łączy te dwa etapy w jeden, przetwarzający cały obraz naraz. Jak przedstawiono na schemacie @yolo_grid, sieć dzieli obraz na siatkę `S x S` komórek, z których każda jest odpowiedzialna za wykrycie obiektu, jeśli jego środek znajduje się w jej wnętrzu.

#figure(
  image("../images/yolo.png", width: 90%),
  caption: [Schemat architektury sieci YOLO. Źródło: @coll-josifov_phdthesis_2022],
) <yolo_grid>

Dzięki temu, YOLO jest ekstremalnie szybkie i znajduje zastosowanie nawet w przetwarzaniu wideo w czasie rzeczywistym.

W pracy wykorzystano model YOLO w wersji ósmej implementacji Ultralytics @yolov8_ultralytics, które jest obecnie standardem przemysłowym. Wprowadza ono wiele usprawnień nad wersją przedstawioną w oryginalnych publikacjach, m.in. uproszczoną architekturę i poprawioną zdolność generalizacji na obiekty o nietypowych kształtach (jak twarze). Model ten służy do precyzyjnego zlokalizowania twarzy na klatce, co pozwala na jej wykadrowanie przed przekazaniem do kolejnych etapów potoku przetwarzania.

=== Ekstrakcja punktów charakterystycznych twarzy <facial-landmark-extraction>
Sam obraz twarzy to tylko zbiór pikseli. Komputer interpretuje mimikę twarzy jako zmianę jasności składowych koloru pikseli, a nie kształty. Biorąc pod uwagę fakt, że pojedyncza klatka nagrania o przeciętnej rozdzielczości to ponad milion pikseli, analiza surowych danych jest nieefektywna.

Ekstrakcja punktów charakterystycznych twarzy (ang. _landmark extraction_) pozwala na znaczną redukcję wymiarowości bez znaczącej utraty informacji. Z pojedynczej klatki wyciągane są współrzędne 478 kluczowych punktów morfologicznych (np. kąciki oczu, obrys ust, czubek nosa i łuki brwiowe).

W tym celu, w pracy została zastosowana biblioteka MediaPipe utworzona przez Google @lugaresi_mediapipe_2019. Jest to wieloplatformowy framework do budowania potoków przetwarzania multimediów. 
Mechanizm jego działania oparty jest na dwuetapowym procesie:
+ Na pierwszej klatce z użyciem lekkiego modelu (BlazeFace) wykrywana jest twarz i wycinany jest prostokąt ograniczający ją.
+ Na kolejnych klatkach model landmarków działa już na wyciętym prostokącie i ponawia detekcję tylko, jeśli twarz zostanie zgubiona, np. przy gwałtownym ruchu głowy.
Dzięki takiemu podejściu, rozwiązanie to jest wysoce optymalne obliczeniowo i działa w czasie rzeczywistym.

Model Face Mesh @kartynnik_realtime_2019 zbudowany w oparciu o architekturę ResNet tworzy siatkę 3D, składającą się nie tylko ze współrzędnych `x` i `y` punktów charakterystycznych, ale także głębokości względem środka głowy `z`. To pozwala na oszacowanie czy twarz jest przechylona względem kamery. Siatka składa się z 478 precyzyjnie zlokalizowanych punktów. Jej gęstość wyróżnia ją na tle alternatywnych rozwiązań, które generują znacznie mniej punktów (68 w przypadku OpenFace), co pozwala na dokładniejszą analizę, kluczową dla wykrywania mikroekspresji i "przecieku" emocji zgodnie z teorią Ekmana. Dodatkowo wykorzystany jest mechanizm atencji @grishchenko_attention_2020, który pozwala modelowi na skupienie się na kluczowych, "trudnych" obszarach (oczy i usta), co zapewnia wysoką precyzję.

Na podstawie siatki punktów wygenerowanej przez MediaPipe wyliczane są geometryczne cechy pochodne w celu:
- wykrywania mrugnięć (wskaźnik EAR - _Eye Aspect Ratio_), co umożliwia zastosowanie wskaźników opartych na teorii obciążenia poznawczego
- wykrywania otwarć ust (wskaźnik MAR - _Mouth Aspect Ratio_), pozwalając stwierdzić kiedy wypowiadane są słowa
- wyliczania kątów Eulera (_Head Pose Estimation_), opisujących rotację głowy w trzech osiach.

#figure(
  image("../images/face_mesh.png", width: 90%),
  caption: [Siatka punktów wygenerowana przez MediaPipe. Źródło: opracowanie własne korzystając z nagrania z @silesian],
) <face_mesh>

=== Analiza przepływu optycznego (_Optical Flow_) <optical-flow-analysis>
Choć wielce informatywne, położenie punktów charakterystycznych twarzy nie jest wystarczające do wartościowej analizy. Charakteryzują one kształt i ułożenie kluczowych elementów mimicznych, ale zupełnie pomijają teksturę i dynamikę ruchu.

*Przepływ optyczny* definiowany jest jako wzorzec pozornego ruchu obiektów, powierzchni i krawędzi w scenie wizualnej, wynikający z relatywnego ruchu między obserwatorem (kamerą) a sceną @horn_schunck_1981.
W kontekście wizji komputerowej, obraz traktowany jest jako dwuwymiarowe pole wektorowe, gdzie każdemu pikselowi ($x$, $y$) przypisywany jest wektor prędkości ($u$, $v$) opisujący jego przemieszczenie $Delta x$, $Delta y$ w czasie. Pozwala to na określenie w jakim kierunku i z jaką szybkością porusza się dany punkt.

Algorytmy obliczające przepływ optyczny opierają się na założeniu o stałej jasności - piksel przemieszczający się z punktu A do punktu B zachowuje swój kolor i jasność. 

Wzór opisujący tę zależność przyjmuje postać:
$
  I(x, y, t) approx I(x + Delta x, y + Delta y, t + Delta t)
$

W rzeczywistych nagraniach powszechnie występuje zmienne oświetlenie, co oczywiście wpływa na intensywność pikseli. Z tego powodu, przed obliczeniem przepływu optycznego stosuje się konwersję klatek do skali szarości.

Metody obliczania tego wskaźnika dzieli się na dwie kategorie:
- *Metody rzadkie* (_sparse_), które śledzą tylko wybrane, obiecujące punkty (krawędzie, narożniki). Są one szybkie, ale z powodu pominięcia "płaskich obszarów", gubią informacje o subtelnych ruchach na gładkich powierzchniach (jakimi są np. policzki lub czoło). Wystąpienie mikroekspresji może zostać pominięte, co eliminuje sens użycia ich w detekcji kłamstwa.
- *Metody gęste* (_dense_), obliczające wektor prędkości dla każdego piksela obrazu. Takie podejście jest zdecydowanie bardziej wymagające obliczeniowo, ale pozwala wykryć ruch nawet tam, gdzie nie występują wyraźne punkty charakterystyczne, dzięki czemu ma potencjał na wykrycie wystąpienia mikroekspresji.

Ze względu na wyżej wymienione ograniczenia metod rzadkich, w niniejszej pracy zdecydowano się na użycie implementacji algorytmu Gunnara Farnebacka dostępnej w bibliotece OpenCV @farneback_2003. Jest to metoda gęsta pozwalająca na wyłapanie każdego niuansu. Algorytm ten aproksymuje sąsiedztwo każdego piksela korzystając z wielomianów kwadratowych i analizuje ich ruchy w kolejnych klatkach.

Analiza przepływu optycznego jest niezwykle przydatna w detekcji kłamstwa i pozwala na dostrzeżenie tego, do czego nie sprawdza się analiza punktów charakterystycznych. Niska jego wartość może wskazywać na "zastyganie" opisane wcześniej w #link(<cognitive-load-theory>)[sekcji dotyczącej teorii obciążenia poznawczego]. Nagły skok w jego magnitudzie natomiast, może sugerować mikroekspresję @liong_optical_flow_2014, które są zbyt subtelne do wykrycia przez FaceMesh.

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    image("../images/optical_flow_og.png", width: 100%),
    image("../images/optical_flow_vis.png", width: 100%),
  ),
  caption: [
    Wizualizacja gęstego przepływu optycznego. 
    Po lewej: oryginalna klatka wideo (wykadrowana twarz).
    Po prawej: wizualizacja wektorów ruchu. Czarne tło oznacza brak istotnego ruchu (efekt zastosowanego progowania), natomiast barwne plamy wskazują na dynamikę w rejonie oczu, nosa i ust. 
    Źródło: opracowanie własne z użyciem nagrania z @silesian.
  ],
) <optical_flow_vis>

== Algorytmy uczenia maszynowego stosowane w rozpoznawaniu kłamstwa <machine-learning-algorithms-for-lie-detection>
=== Klasyczne metody uczenia maszynowego - Random Forest <classical-machine-learning-algorithms>
Do zrozumienia działania algorytmu Random Forest (Las Losowy), kluczowe jest poznanie idei drzew decyzyjnych @hastie_elements_2009. Jest to hierarchiczna struktura danych, służąca do podejmowania decyzji poprzez zadawanie sekwencji pytań o wartość cech (np. "Czy wartość wskaźnika EAR jest większa od 0,2?"). Powszechnie wizualizowane jest jako odwrócone drzewo, z korzeniem na górze, a liśćmi na dole, gdzie węzłami są kolejne pytania tworzące podział, a liście to finalne predykcje. 

Algorytm ten dzieli przestrzeń cech za pomocą prostych reguł decyzyjnych. Podział następuje w sposób rekurencyjny - w każdym węźle wybierany jest podział maksymalnie separujący klasy, maksymalizując zysk informacyjny (ang. _information gain_) lub minimalizując entropię, opierając się np. na indeksie Gini.

Mechanizm działania drzewa decyzyjnego jest bardzo intuicyjny i łatwy do interpretacji. Jednak pojedyncze drzewa decyzyjne mają tendencję do przeuczenia (_overfitting_) - tworzą skomplikowane struktury, idealnie dopasowując się do danych treningowych, przez co słabo radzą sobie z nowymi danymi.

Choć Random Forest używany jest jako pojedynczy klasyfikator, w istocie stanowi on przykład uczenia zespołowego (_ensemble learning_). Nie jest on modelem monolitycznym, a zbiorem wielu drzew decyzyjnych @breiman_random_forest_2001. Jak wspomniano wcześniej, pojedyncze drzewo obarczone jest ryzykiem występowania błędów. Z tego powodu, tworzy się lasy dające uśredniony wynik dziesiątek lub nawet setek estymatorów, zapewniając większą stabilność i dokładność predykcji @hastie_elements_2009. W problemach klasyfikacji, jakim jest właśnie zadanie rozpoznawania kłamstwa, ostateczna decyzja podejmowana jest na podstawie tego, którą klasę wybrała większość drzew.

Kluczowym elementem algorytmu jest metoda *Bootstrap Aggregating* (zwana _Baggingiem_). Każde z drzew w lesie uczy się na nieco odmiennym podzbiorze zbioru treningowego @breiman_random_forest_2001, a podział ten dokonywany jest na podstawie losowania ze zwracaniem. Dodatkowo, przy tworzeniu podziału w każdym węźle drzewa, algorytm analizuje tylko losowy podzbiór cech, a nie wszystkie dostępne atrybuty. Mechanizmy te zabezpieczają przed przeuczeniem występującym w rozwiązaniach korzystających z jednego drzewa, a także wspierają zdolność do generalizacji na nowych danych.

Random Forest wymaga na wejściu wektora cech o długości niezmiennej wśród wszystkich próbek, co stawia wyzwanie dla analizy nagrań, gdyż znacznie różnią się one długością, w zależności od długości wypowiedzi, tempa mowy i wielu innych czynników. Z tego powodu, przed podaniem próbki danych do modelu wymagane jest ujednolicenie ich długości. Jednym z rozwiązań tego problemu jest wykorzystanie *statystyk opisowych z całego nagrania*. Dla każdej cechy obliczana jest jej średnia, odchylenie standardowe, maksimum i minimum, co skutkuje utratą informacji o sekwencyjności zdarzeń. Model ten nie rozumie pojęcia czasu ani kolejności klatek, jednak zachowuje ogólną charakterystykę zachowania. Uczy się on zależności między wystąpieniem zjawiska kłamstwa i np. liczbą mrugnięć, a nie rozpoznaje zjawisk opisanych #link(<cognitive-load-theory>)[wcześniej], takich jak zmiana częstotliwości mrugnięć w trakcie wypowiadania kłamstwa.

W przeciwieństwie do sieci neuronowych (często określanych jako "czarne skrzynki", ang. _black box_) opisanych w #link(<recurrent-neural-networks>)[kolejnych podrozdziałach], Random Forest charakteryzuje się wysoką interpretowalnością. Dzięki analizie ważności cech (_Feature Importance_), z łatwością można precyzyjnie określić, które cechy były najbardziej znaczące przy podejmowaniu decyzji. Pozwala to na empiryczną weryfikację hipotez psychologicznych, dotyczących fizjologicznych wskaźników nieszczerości.

W niniejszej pracy, algorytm ten został użyty jako model bazowy (ang. _baseline_) w celu oszacowania dolnej granicy skuteczności i był traktowany jako punkt odniesienia dla bardziej złożonego, finalnie wybranego modelu.

=== Rekurencyjne sieci neuronowe (_RNN - Recurrent Neural Networks_) <recurrent-neural-networks>
Kłamstwo to proces dynamiczny naturalnie umiejscowiony w czasie. Ze względu na to, do dokładnego wykrywania go wymagany jest model rozumiejący zależności czasowe i sekwencyjność kolejnych klatek nagrań wideo. Takim modelem jest rekurencyjna sieć neuronowa, przetwarzająca dane jako sekwencje kroków czasowych, gdzie stan w chwili bieżącej jest zależny od stanu go poprzedzającego. 

Takie działanie osiągane jest za sprawą zastosowanej pętli sprzężenia zwrotnego, w której wyjście neuronu $y_t$ wraca do niego jako wejście w kolejnym kroku czasowym. Stan ukryty (ang. _hidden state_) $h_t$ służy jako "pamięć" sieci. W każdym kroku czasowym $t$ obliczany jest on korzystając z aktualnego wejścia $x_t$ (cechy z bieżącej klatki) i stanu ukrytego z poprzedniego kroku $h_(t-1)$. W przeciwieństwie do tradycyjnych sieci neuronowych, gdzie każda warstwa ma oddzielne wagi, w RNN te same wagi używane są w każdym kroku czasowym, co pozwala na przetwarzanie sekwencji o dowolnej długości. 

#figure(
  image("../images/rnn.drawio.pdf", width: 85%),
  caption: [
    Schemat sieci rekurencyjnej (RNN). 
    Po lewej: reprezentacja zwinięta z pętlą sprzężenia zwrotnego. 
    Po prawej: reprezentacja rozwinięta w czasie, ukazująca przepływ informacji (stanu ukrytego) przez kolejne kroki sekwencji. 
    Źródło: opracowanie własne na podstawie @goodfellow_deep_learning_2016.
  ],
) <rnn_unrolled>

Trening takiej sieci bazuje na "rozwinięciu" jej w czasie, tworząc bardzo głęboką sieć, gdzie każda warstwa to jeden krok czasowy. Aby umożliwić naukę sieci, po przepuszczeniu przez nią sekwencji obliczany jest błąd, według którego aktualizowane są wagi, cofając się do początku sekwencji. Jest to algorytm BPTT (_Back Propagation Through Time_). Ponieważ wagi sieci neuronowej często są małymi liczbami (mniejszymi niż 1), mnożenie ich przez siebie setki razy (w przypadku długich sekwencji) w trakcie propagacji wstecznej powoduje wykładnicze malenie gradientu. Nazywane jest to problemem zanikającego gradientu @bengio_vanishing_1994, który skutkuje tym, że wagi na początku sekwencji przestają się aktualizować, a w konsekwencji na wynik predykcji długiej sekwencji najmocniej wpływają kroki czasowe z jej końca, a informacja z jej początku "zanika".

Jak wcześniej zauważono, klasyczne sieci RNN mają krótką pamięć. Problem ten rozwiązują architektury bramkowe, takie jak LSTM (_Long Short Term Memory_) zaprojektowany przez Hochreitera i Schmidhubera w celu usunięcia zanikających gradientów @hochreiter_lstm_1997. Wprowadza on dodatkowy przepływ informacji między kolejnymi krokami czasowymi w postaci stanu komórki (ang. _cell state_) $C_t$, pozwalający pamiętać informację na długich odcinkach sekwencji. Dzięki mechanizmowi bramkowania (ang. _gating_), LSTM potrafi decydować co zapomnieć, a co zapamiętać za pomocą struktur zwanych bramkami. Występują trzy ich rodzaje:
- *Bramka Zapominania* (_Forget Gate_): na podstawie wejścia $x_t$ oraz stanu ukrytego z poprzedniego kroku $h_(t-1)$ decyduje, co wyrzucić ze stanu komórki.
- *Bramka Wejściowa* (_Input Gate_): Decyduje, jakie nowe informacje zapisać w stanie komórki.
- *Bramka Wyjściowa* (_Output Gate_): Decyduje, co z obecnego stanu komórki zapisać do stanu ukrytego, przekazując do kolejnego kroku jako $h_t$.

Bramki wprowadzają znaczne usprawnienie działania rekurencyjnych sieci neuronowych, ale tym samym LSTM ma niezwykle dużo trenowalnych parametrów, przez co proces jego uczenia jest utrudniony i wymaga większej ilości danych treningowych. Architektura GRU (_Gated Recurrent Unit_) została opracowana przez Kyunghyuna Cho w celu optymalizacji i uproszczenia LSTM @cho_gru_2014. Łączy ona stan ukryty i stan komórki w jedno, ale korzysta z bramek w celu ochrony przed zanikającymi gradientami. W przeciwieństwie do LSTM, gdzie są trzy bramki, w GRU są tylko dwie:
- *Bramka Aktualizacji* (_Update Gate_) $z_t$: Jednocześnie pełni rolę bramki zapominania i wejściowej z LSTM. Decyduje, w jakim stosunku brać pod uwagę poprzedni stan ukryty i aktualne wejście.
- *Bramka Resetu* (_Reset Gate_) $r_t$: Pozwala sieci całkowicie porzucić poprzedni stan ukryty, resetując pamięć krótkotrwałą, jeśli uzna go za nieistotny dla aktualnego stanu.

Standardowe sieci rekurencyjne przetwarzają sekwencje chronologicznie, przez co decyzja sieci w danym momencie zależy tylko od kroków czasowych go poprzedzających. Z uwagi na fakt, że w pracy tej analizowane pod kątem prawdomówności są istniejące już nagrania, a celem nie jest utworzenie systemu czasu rzeczywistego, postawnowiono wzbogacić architekturę GRU o działanie dwukierunkowe, tworząc architekturę Bi-GRU @schuster_bidirectional_1997. Składa się ona z dwóch oddzielnych warstw, z których jedna przetwarza nagranie w przód, a druga w tył. W takim podejściu, finalna reprezentacja pojedynczej klatki jest wynikiem konkatenacji wektorów wyjściowych obu warstw. Dzięki temu, model uczy się pełnego kontekstu zachowania i uzyskuje zdolność odróżnienia akcji, które z pozoru w danym momencie są identyczne, ale biorąc pod uwagę kontekst przyszłości posiadają zupełnie odmienne podłoża psychologiczne.

Według teorii Ekmana opisanej wcześniej w #link(<psychological-aspects-of-lie-detection>)[przeglądzie literatury psychologicznej], kłamstwo często zostaje zdradzone w ułamku sekundy. Analizowane nagrania jednak, często mają długość osiągającą nawet minutę, zawierając długie nieinformatywne momenty ciszy i bezruchu. Tworzy to utrudnienie w procesie generowania predykcji, gdyż informacje o wystąpieniu mikroekspresji (często ze środka nagrania), ulegają zatarciu w finalnym wektorze stanu ukrytego (problem wąskiego gardła, ang. _information bottleneck_). Rozwiązaniem tego problemu jest mechanizm atencji, pozwalający sieci podejmować decyzję na podstawie wszystkich klatek jednocześnie @bahdanau_attention_2014. Sieć uczy się przypisywać każdej z nich wagę (z zakresu $[0, 1]$), gdzie wysoka wartość świadczy o ważności tego momentu, a niska często jest przypisywana właśnie do chwil, w których nie dzieje się zbyt dużo. Za sprawą normalizacji Softmax, wagi sumują się do 1, co pozwala interpretować je jako prawdopodobieństwo wystąpienia istotnej informacji w danym kroku czasowym.

Liczne zalety tej architektury, w których zawiera się mniejsza liczba parametrów, szybszy trening i mniejsze ryzyko przeuczenia na mniejszych zbiorach (takich jak @silesian) przy zachowaniu skuteczności porównywalnej z LSTM, zadecydowały o oparciu finalnego rozwiązania w tej pracy na architekturze GRU rozszerzonej o dwukierunkowość i mechanizm atencji.

#figure(
  image("../images/gru.drawio.pdf", width: 90%),
  caption: [
    Schemat komórki GRU (_Gated Recurrent Unit_). 
    Widoczny przepływ sygnałów przez bramkę resetu ($r_t$) oraz bramkę aktualizacji ($z_t$). 
    Symbol $sigma$ oznacza funkcję aktywacji sigmoidalną, a $tanh$ tangens hiperboliczny.
    Źródło: opracowanie własne na podstawie @cho_gru_2014.
  ],
) <gru_cell>

=== Alternatywne podejście: trójwymiarowe konwolucyjne sieci neuronowe (3D-CNN) <3D-CNN>
Jako alternatywa do RNN, rozważono użycie trójwymiarowych konwolucyjnych sieci neuronowych (3D-CNN) @tran_c3d_2015. Klasyczne sieci konwolucyjne CNN (używane np. w YOLO) operują bezpośrednio na obrazach. Ich trójwymiarowy odpowiednik rozszerza operację splotu (konwolucji) o trzeci wymiar - czas. Takie podejście eliminuje potrzebę skomplikowanego przetwarzania wstępnego, ponieważ sieć bezpośrednio z nagrań uczy się jednocześnie wyglądu obiektów i ich ruchu. Nie jest to jednak rozwiązanie bez wad. Tak skomplikowany model jest bardzo ciężki obliczeniowo, a efektywne wytrenowanie go wymaga tysięcy, a nawet milionów nagrań. Dziedzina detekcji kłamstwa cierpi na deficyt danych, a publicznie dostępne zbiory liczą zaledwie setki próbek. Z tego powodu, zdecydowano się na porzucenie prób modelowania opartych na tej architekturze.

== Przegląd istniejących rozwiązań w detekcji kłamstwa <state-of-the-art-in-lie-detection>
Początkowe próby zastosowania algorytmów uczenia maszynowego do automatycznej detekcji kłamstwa opierały się na klasycznych metodach wizji komputerowej. Dane zostawały poddane ręcznej ekstrakcji cech geometrycznych i tekstur, a nastepnie były używane do trenowania klasyfikatorów - maszyn wektorów nośnych (SVM) lub drzew decyzyjnych. Przykładem takiego podejścia jest praca @pfister_2011, w której wykorzystano deskryptor LBP-TOP (_Local Binary Patterns from Three Orthogonal Planes_) do analizy czasoprzestrzennych zmian tekstury twarzy, używając klasyfikatora SVM. Rozwiązania te, choć przełomowe na tamten okres (ok. 2010-2015), były bardzo podatne na błędy wynikające z nieoptymalnych warunków oświetlenia i przemieszczeń kamery.

Przełom nastąpił wraz z popularyzacją głębokiego uczenia (ang. _deep learning_). Kluczową pracą z tego okresu jest jest publikacja Pérez-Rosas et al. @perez_rosas_real_life_2015, w ramach której utworzono zbiór Real-life Trial Dataset, zawierający nagrania z prawdziwych rozpraw sądowych. W swoich eksperymentach, autorzy wykorzystali drzewa decyzyjne oraz lasy losowe do klasyfikacji próbek składających się z cech językowych (wyekstrahowanych z transkrypcji) oraz wizualnych: m.in. trajektorie ruchów głowy i dłoni oraz detekcja uśmiechów. Badania te wykazały, że automatyczne systemy oparte na ekstrakcji cech wizualnych są w stanie osiągnąć skuteczność nawet 75%, znacząco przewyższając ludzką percepcję (wcześniej wspomniane 54%).

Współczesne podejścia ewoluowały w stronę analizy multimodalnej, jednocześnie biorąc pod uwagę nie tylko obraz z kamery, ale także dźwięk (między innymi ton głosu) oraz treść wypowiedzi (korzystając z technik przetwarzania języka naturalnego, ang. _NLP_ - _Natural Language Processing_). Prace takie jak Gogate @gogate_deep_learning_2017 wykorzystały potężne architektury łączące sieci konwolucyjne CNN z mechanizmami atencji, pobijając wcześniejsze próby zautomatyzowania procesu oceny prawdomówności wypowiedzi, osiągając skuteczność rzędu 80%.

Równocześnie istniejący nurt badawczy wskazuje jednak, że to właśnie kanał wizualny dostarcza najwięcej unikalnych i trudnych do sfałszowania sygnałów (w postaci "przecieków emocjonalnych"), na co wskazuje literatura poświęcona detekcji mikroekspresji @wu_micro_expression_2017. Uzasadnia to skupienie się w niniejszej pracy na analizie wideo z wykorzystaniem metod wizji komputerowej w postaci m. in. Optical Flow oraz sekwencyjności rekurencyjnych sieci neuronowych.