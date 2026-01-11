#import "../utils.typ": todo, silentheading, flex-caption

= Przygotowanie danych i inżynieria cech <data-preparation-and-feature-engineering>
Jakość i sposób przygotowania danych są w projektach uczenia maszynowego równie ważne jak architektura wykorzystanych modeli. Nawet najbardziej rozbudowany model niczego się nie nauczy, jeśli do treningu dostanie zaszumione i niereprezentatywne dane. W detekcji kłamstwa, gdzie o etykiecie próbki danych świadczą bardzo subtelne sygnały (takie jak mikroekspresje), adekwatne przygotowanie danych jest kluczowe. W tym rozdziale przedstawiono szczegółowy opis wykorzystanych w pracy zbiorów danych, obejmujący metody ich pozyskania oraz techniki wykorzystane w celu uzyskania jak najlepszej reprezentatywności. Następnie, przedstawiony zostanie kompletny potok przetwarzania danych, poczynając od surowych nagrań wideo, a kończąc na tensorach cech zrozumiałych dla sieci neuronowych. Opisana zostanie także strategia podziału danych na zbiory treningowe, walidacyjne i testowe oraz ich normalizacja. 

== Charakterystyka zbiorów danych <dataset-description>
W pracy wykorzystano dwa zbiory danych, aby sprawdzić zdolność wybranego rozwiązania do nauki na danych przygotowanych w kontrolowanych warunkach laboratoryjnych, jak i jego generalizację w warunkach rzeczywistych (nagranie zbliżone jakością do tych, które będą zamieszczane przez użytkownika końcowego).

=== Silesian Deception Dataset
Zbiór @silesian został użyty jako zbiór podstawowy, z którego model uczy się wskaźników kłamstwa. Został on opracowany przez naukowców z Politechniki Śląskiej @radlak_bozek_2015. Zawiera nagrania 101 uczestników (studentów), co zapewnia wystarczająco dużą różnorodność biometryczną twarzy. Próbki danych zostały zebrane w kontrolowanych warunkach, a w szczególności:
- kontrolowane statyczne oświetlenie,
- jednolite tło,
- kamera ustawiona na wprost.
Taki sposób pozyskania nagrań w pełni eliminuje szum tła, pozwalając modelowi na skupienie się wyłącznie na twarzach uczestników. W procesie tworzenia tego zbioru danych została wykorzystana profesjonalna kamera rejestrująca obraz w rozdzielczości 640x480 pikseli z szybkością 100 klatek na sekundę.

Twórcy @silesian trafnie zauważyli, że w celu pozyskania nagrań zawierających naturalne wskaźniki nieszczerości trzeba stworzyć środowisko, w którym kłamstwo uczestników będzie znaczące, a nie tylko z góry narzucone. W tym celu, nagrania zostały przeprowadzone jako badanie rzekomych zdolności telepatycznych pewnej osoby. Przed uczestnikiem stał laptop, na którego ekranie wyświetlała się figura geometryczna oraz polecenie "skłam" lub "powiedz prawdę". Usadzony na przeciwko niego był rzekomy telepata, który miał czytając im w myślach zadecydować czy na ekranie faktycznie jest dana figura geometryczna czy nie. Obecność kamer została uzasadniona wykluczeniem możliwości niewerbalnego podpowiadania telepacie, a jedna z nich była skierowana właśnie na niego w celu zwiększenia immersji tej narracji. Dzięki tym zabiegom, udało się uchwycić zachowania zbliżone do tych, które występują podczas prawdziwego kłamania - spontaniczne, niekontrolowane reakcje mimiczne, mikroekspresje i napięcie emocjonalne.

== Strategia podziału danych i walidacji <data-split-strategy>

== Potok przetwarzania obrazu <image-processing-pipeline>

== Inżynieria cech <feature-engineering>

== Normalizacja i przygotowanie sekwencji <normalization-and-sequence-preparation>
