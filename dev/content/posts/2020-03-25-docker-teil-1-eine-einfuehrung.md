---
title: 'Docker – Teil 1: Eine Einführung.'
author: Zadjad Rezai
type: post
date: 2020-03-25T20:16:33+00:00
excerpt: 'Docker ist eine interessante technische Entwicklung, welche uns zeigt, dass wir uns aktuell in jeder Ebene in die selbe Richtung bewegen - immer weiter in die Abstraktion von Komplexität.'
url: /container/docker-teil-1-eine-einfuehrung/
featured_image: /img/31518965950_1b75084023_o-scaled.webp
cover:
  image: /img/31518965950_1b75084023_o-scaled.webp
eael_transient_elements:
  - 'a:0:{}'
site-sidebar-layout:
  - default
site-content-layout:
  - default
theme-transparent-header-meta:
  - default
categories:
  - Container
tags:
  - Docker

---
<div>
  <figcaption>Foto von <a href="https://www.flickr.com/photos/134416355@N07/">Kyohei Ito</a></figcaption></figure>
</div>

In diesem ersten Post, möchte ich Docker grob vorstellen und im nächsten Teil eine Beispielanwendung veröffentlichen.

Docker ist eine interessante technische Entwicklung, welche uns zeigt, dass wir uns aktuell in jeder Ebene in die selbe Richtung bewegen &#8211; immer weiter in die Abstraktion von Komplexität.

<p>
  <mark>Bevor ich auf Docker selbst eingehe, möchte ich einige Gedanken zur Grundlegenden Überlegung los werden.</mark>
</p>

Seit Jahren sieht die Bewegung auf dem technischen Markt gleich aus: Abstraktion.

Damit möchte man Komplexität nehmen, System und Anwendungen weniger Abhängig voneinander machen und damit Verbesserung, Bereitstellung und zukünftige Bewegung der Software vereinfachen.

Beim Schreiben der ersten Anwendungen, stellen viele fest, dass es enorm aufwendig ist wichtige Teile der Anwendung zu verbessern, anzupassen oder gar auszutauschen. Dadurch kommt es zu einem fundamentalen Konflikt ****und man muss sich entscheiden, ob man

  1. das Projekt aufgibt (traurig 😔)
  2. die Änderung macht (aufwenig)
  3. das Projekt so ändert, dass zukünftige Änderungen leichter sind (sehr aufwenig)

Im Grunde möchte gute Software <a href="https://martinfowler.com/ieeeSoftware/coupling.pdf" target="_blank" rel="noreferrer noopener" aria-label=" (öffnet in neuem Tab)">Kopplungen niedrig halten</a> und <a href="https://stackoverflow.com/questions/10830135/what-is-high-cohesion-and-how-to-use-it-make-it" target="_blank" rel="noreferrer noopener" aria-label=" (öffnet in neuem Tab)">Kohäsion stärken</a>.

Dieses Konzept, bekannt in der Softwareentwicklung, lässt sich natürlich u. a. auf das Konzept von virtuellen Maschinen (VMs) übertragen. So merkt man, dass die Welt auch hier wieder ganz ähnlich aussieht.

Früher hat man eine VM gehabt, welche für eine bestimmte Software verantwortlich war &#8211; beispielsweise hat man eine VM, welche eine Datenbank betreibt. Braucht mehr mehr Datenbanken, muss man eine neue VM erstellen &#8211; und das dauert vergleichsweise lange.

Eine VM jedoch hat viele Abhängigkeiten, die für die Datenbank eigentlich nicht von Bedeutung sind &#8211; jedes mal muss beispielsweise mit der VM ein Betriebssystem installiert werden. Damit ist die Kopplung ziemlich hoch und die logische Aufgabe der VM ist nicht **nur** die Datenbank, weshalb sie keine einzige definierte Verantwortung hat (niedrige Kohäsion).

Eine VM ist damit sehr ineffizient und sollte heutzutage nur genutzt werden, wenn man Container nicht nutzen kann.

<div style="text-align:center;">
  <figure class="aligncenter size-large"><img src="/img/docker-1/vm_1-1.webp" alt="" srcset="/img/docker-1/vm_1-1.webp 406w, /img/docker-1/vm_1-1.webp 300w" sizes="(max-width: 406px) 100vw, 406px" /><figcaption>Abbildung 1: Nutzung von VMs</figcaption></figure>
</div>

In Abbildung 1 erkennt man einen ungefähren Aufbau einer VM-Architektur. Die Hardware wurde durch die Virtualisierung weg abstrahiert, weshalb eine VM seinen Kernel (Guest OS), die jeweiligen Abhängigkeiten und natürlich den Code oder die Software benötigt, die man darauf laufen lassen möchte.

Wenn man das Prinzip von [DRY][1] auf dieses Bild anwendet, erkennt man, dass der **Kernel** eine Sache ist, die sich wiederholt, aber eigentlich nicht wirklich etwas mit der Dienstleistung zu tun hat, die man liefern möchte. Man sollte diese also separieren können, um nicht unnötig Resourcen zu verschwenden.

<p>
  <mark>Container kommen zur Rettung</mark>
</p>

Nun sollte es eindeutig geworden sein, dass eine VM-Architektur ein fundamentales Problem aufweist. Docker bietet dafür die Möglichkeit diesen Teil zu abstrahieren.

<div style="text-align:center;">
  <figure class="aligncenter size-large"><img src="/img/docker-1/docker_1-1.webp" alt="" class="wp-image-1001" srcset="/img/docker-1/docker_1-1.webp 406w, /img/docker-1/docker_1-1.webp 300w" sizes="(max-width: 406px) 100vw, 406px" /><figcaption>Abbildung 2: VMs werden zu Containern</figcaption></figure>
</div>

Durch die Abstraktion des Kernels/des Betriebssystems, tritt man in eine Welt ein, die schnellere Bereitstellungen, einfache Weitergabe und höhere Skalierbarkeit erlaubt.

Bevor wir zu tief in die Details gehen, können wir es <a href="https://zops.top/container/docker-rest-apis-teil-2" target="_blank" rel="noreferrer noopener" aria-label=" (öffnet in neuem Tab)">einfach ausprobieren</a>.

 [1]: https://martinfowler.com/ieeeSoftware/repetition.pdf
