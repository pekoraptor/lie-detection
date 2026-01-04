#import "../utils.typ": todo, silentheading, flex-caption

= Teoria i przegląd literatury <literature-review>
Niniejszy rozdział ma na celu zdefiniowanie podstaw teoretycznych, które zostały bezpośrednio wykorzystane w dalszych rozdziałach pracy i ma służyć jako wprowadzenie do zagadnień związanych z tematyką kłamstwa i jego automatycznej detekcji z użyciem wizji komputerowej oraz uczenia maszynowego. Ten projekt naturalnie łączy wiedzę z różnych dziedzin naukowych, w tym psychologii behawioralnej, inżynierii oprogramowania i sztucznej inteligencji. Dlatego, aby zapewnić czytelnikowi pełne zrozumienie kontekstu i podstaw teoretycznych, rozdział ten obejmuje zagadnienia ze wszystkich tych obszarów. 

Na początku omówione zostanie w jaki sposób kłamstwo formułowane jest w ludzkim umyśle i po czym można rozpoznać jego zaistnienie w zachowaniu niewerbalnym. Następnie, wytłumaczone zostaną podstawowe metody wizji komputerowej wykorzystywane do analizy cech, takich jak mimika twarzy czy ruchy ciała. Kolejna sekcja przedstawi działanie wybranych algorytmów uczenia maszynowego, które zostały zastosowane w pracy jako modele klasyfikacyjne. Na koniec zaprezentowany zostanie przegląd istniejących już rozwiązań w dziedzinie automatycznej analizy wiarygodności wypowiedzi (_state of the art_), co stanowi punkt odniesienia dla podejścia zaproponowanego w tej pracy.

== Psychologiczne aspekty kłamstwa <psychological-aspects-of-lie-detection>
=== Formalna definicja kłamstwa <definition-of-lie>
Według Alderta Vrija kłamstwo definiuje się jako "świadomą próbę wywołania u innej osoby przekonania, które sam mówiący uważa za nieprawdziwe"  @vrij_detecting_lies_2008. Oznacza to, że akt skłamania wiąże się z intencją - zwykła pomyłka nie jest kłamstwem w sensie psychologicznym, pomimo iż wypowiadane słowa są fałszywe. Podobnie, aktor grający pewną rolę także mówi nieprawdę, ale nie uznaje się tego za kłamstwo, gdyż widzowie na wstępie zakładają, że sztuka niekoniecznie jest faktem. Psychologicznie takie sytuacje są zupełnie odmienne dla mózgu człowieka wypowiadającego się, co przejawia się w jego zachowaniu. Różnice te mogą być wychwycone i sklasyfikowane przez system wizyjny nieznający kontekstu wypowiedzi ani obiektywnej prawdy.

=== Teoria obciążenia poznawczego (ang. _Cognitive Load Theory_)
Miron Zuckerman zaproponował teorię obciążenia poznawczego zakładającą, że kłamstwo jest znacznie bardziej wymagające mentalnie niż mówienie prawdy @zuckerman_verbal_nonverbal_1981. Kłamca musi jednocześnie tworzyć spójną i wiarygodną fałszywą narrację, zapamiętując jej szczegóły, tym samym hamując prawdę. Dodatkowo, stara się kontrolować swoją mowę ciała, żeby zminimalizować ryzyko ujawnienia nieszczerości, obserwując w tym samym czasie reakcję rozmówcy. 

Próba równoczesnego skupienia się na tylu zadaniach prowadzi do przeciążenia mózgu, który w efekcie ogranicza zasoby przeznaczone na nieświadomą kontrolę ciała. Skutkuje to widocznymi zmianami mowy ciała, m.in. w częstotliwości mrugania, które staje się rzadsze w czasie wypowiadania kłamstwa (efekt skupienia), a chwilę po skończeniu wypowiedzi następuje znaczne jego przyspieszenie (efekt kompensacji). Ponadto, ciało oraz głowa kłamiącego wykazują się nienaturalną sztywnością - zastygają one w bezruchu na rzecz podświadomej próby uniknięcia wykonania gestu, który mógłby zasugerować rozmówcy, iż jest on okłamywany.

=== Hipoteza przecieku prawdziwych emocji (ang. _Leakage Hypothesis_)


== Metody wizji komputerowej w analizie twarzy <computer-vision-in-face-analysis>

== Algorytmy uczenia maszynowego stosowane w rozpoznawaniu kłamstwa <machine-learning-algorithms-for-lie-detection>

== Przegląd istniejących rozwiązań w detekcji kłamstwa <state-of-the-art-in-lie-detection>