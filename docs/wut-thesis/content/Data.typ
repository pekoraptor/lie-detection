#import "../utils.typ": todo, silentheading, flex-caption

= Przygotowanie danych i inżynieria cech <data-preparation-and-feature-engineering>
Jakość i sposób przygotowania danych są w projektach uczenia maszynowego równie ważne jak architektura wykorzystanych modeli. Nawet najbardziej rozbudowany model niczego się nie nauczy, jeśli do treningu dostanie zaszumione i niereprezentatywne dane. W detekcji kłamstwa, gdzie o etykiecie próbki danych świadczą bardzo subtelne sygnały (takie jak mikroekspresje), adekwatne przygotowanie danych jest kluczowe. W tym rozdziale przedstawiono szczegółowy opis wykorzystanych w pracy zbiorów danych, obejmujący metody ich pozyskania oraz techniki wykorzystane w celu uzyskania jak najlepszej reprezentatywności. Następnie, przedstawiony zostanie kompletny potok przetwarzania danych, poczynając od surowych nagrań wideo, a kończąc na tensorach cech zrozumiałych dla sieci neuronowych. Opisana zostanie także strategia podziału danych na zbiory treningowe, walidacyjne i testowe oraz ich normalizacja. 

== Charakterystyka zbiorów danych <dataset-description>
W pracy wykorzystano dwa zbiory danych, aby sprawdzić zdolność wybranego rozwiązania do nauki na danych przygotowanych w kontrolowanych warunkach laboratoryjnych, jak i jego generalizację w warunkach rzeczywistych (nagranie zbliżone jakością do tych, które będą zamieszczane przez użytkownika końcowego).

=== Silesian Deception Dataset <silesian-deception-dataset>
Zbiór @silesian został użyty jako zbiór podstawowy, z którego model uczy się wskaźników kłamstwa. Został on opracowany przez naukowców z Politechniki Śląskiej @radlak_bozek_2015. Zawiera nagrania 101 uczestników (studentów), co zapewnia wystarczająco dużą różnorodność biometryczną twarzy. Próbki danych zostały zebrane w kontrolowanych warunkach, a w szczególności:
- kontrolowane statyczne oświetlenie,
- jednolite tło,
- kamera ustawiona na wprost.
Taki sposób pozyskania nagrań w pełni eliminuje szum tła, pozwalając modelowi na skupienie się wyłącznie na twarzach uczestników. W procesie tworzenia tego zbioru danych została wykorzystana profesjonalna kamera rejestrująca obraz w rozdzielczości 640x480 pikseli z szybkością 100 klatek na sekundę.

Twórcy @silesian trafnie zauważyli, że w celu pozyskania nagrań zawierających naturalne wskaźniki nieszczerości trzeba stworzyć środowisko, w którym kłamstwo uczestników będzie znaczące, a nie tylko z góry narzucone. W tym celu, nagrania zostały przeprowadzone jako badanie rzekomych zdolności telepatycznych pewnej osoby. Przed uczestnikiem stał laptop, na którego ekranie wyświetlała się figura geometryczna oraz polecenie "skłam" lub "powiedz prawdę". Usadzony na przeciwko niego był rzekomy telepata, który miał czytając im w myślach zadecydować czy na ekranie faktycznie jest dana figura geometryczna czy nie. Obecność kamer została uzasadniona wykluczeniem możliwości niewerbalnego podpowiadania telepacie, a jedna z nich była skierowana właśnie na niego w celu zwiększenia immersji tej narracji. Dzięki tym zabiegom, udało się uchwycić zachowania zbliżone do tych, które występują podczas prawdziwego kłamania - spontaniczne, niekontrolowane reakcje mimiczne, mikroekspresje i napięcie emocjonalne.

Nagranie każdego uczestnika zawiera w sobie dziesięć próbek danych. Proces opisany wcześniej był ustrukturyzowany w taki sposób, że uczestnik wypowiadał się dziesięć razy, gdzie pierwsza, druga i ostatnia wypowiedź miała być szczera, a pozostałe - kłamstwami. Z tego powodu zbiór jest silnie niezbalansowany - 70% przykładów to kłamstwa. Taka struktura nagrań wymaga ręcznej ich segmentacji, w czym pomagają załączone pliki o formacie `.eaf`, zawierające m.in. informację o tym w jakich przedziałach czasowych zamyka się pojedyncza wypowiedź. W plikach tych zaznaczone są także odstępstwa od scenariusza - momenty, w których zaszła pomyłka i w miejscu kłamstwa pojawiła się prawda, itp. Takie przykłady musiały zostać odrzucone. Po usunięciu wadliwych próbek, zbiór składa się z #todo[ile?] przykładów.

=== Real-Life Deception Dataset <real-life-deception-dataset>
W przeciwieństwie do nagrań ze zbioru @silesian przygotowanych w warunkach laboratoryjnych, @real_life_ddd @perez-rosas_abouelenien_mihalcea_burzo_2015 składa się z klipów pochodzących z prawdziwych procesów sądowych (głównie z USA) - fragmenty zeznań świadków oraz wyjaśnień oskarżonych. Zbiór zawiera zaledwie 121 nagrań, lecz ze względu na liczebność klas jest niemal idealnie zbalansowany - 61 kłamstw i 60 wypowiedzi szczerych.

Ze względu na okoliczności powstania nagrań (środowisko sali sądowej bez reżysera ani naukowców), są one niezwykle reprezentatywne. Kłamstwa zawarte w filmach są rzeczywistymi i naturalnymi kłamstwami wysokiej wagi (ang. _High-Stakes Lies_). Przedstawieni w nich ludzie kłamią walcząc o swoją przyszłość, reputację, a nawet życie. Takie wypowiedzi wiążą się z ogromnym obciążeniem poznawczym (ang. _cognitive load_) i silnym stresem, co stwarza idealne warunki do wystąpienia silnych i trudnych do ukrycia mikroekspresji oraz mimowolnych ruchów mięśni twarzy, których nie da się zreplikować w kontrolowanych warunkach eksperymentu laboratoryjnego. Dzięki temu zbiór ten pozwala zweryfikować użyteczność modelu w systemach bezpieczeństwa, gdzie celem jest wykrywanie realnych zagrożeń, a nie akademickiego kłamstwa.

W przeciwieństwie do statycznej kamery i oświetlenia w @silesian, w tym zbiorze z powodu rozproszonego sposobu pozyskania nagrań (różne sale sądowe), cechują się one:
- różnymi kątami kamery (niekoniecznie na wprost),
- zmiennym oświetleniem,
- ruchami kamery,
- przysłonięciami twarzy (np. ręką lub mikrofonem).
To właśnie te ograniczenia sprawiają, że zbiór ten jest idealnym zasobem testowym dla odporności modelu na szum i jego zdolności generalizacji.

Etykiety przykładów z tego zbioru zostały przypisane na podstawie ostatecznych werdyktów sądowych oraz zweryfikowanych przez policję faktów. Choć system sądowniczy nie jest perfekcyjnie wiarygodny i nieomylny, jest to najlepsze przybliżenie prawdy dostępne dla danych rzeczywistych.

== Strategia podziału danych i walidacji <data-split-strategy>

== Potok przetwarzania obrazu <image-processing-pipeline>

== Inżynieria cech <feature-engineering>

== Normalizacja i przygotowanie sekwencji <normalization-and-sequence-preparation>
