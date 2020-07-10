---
title: Pair Programming als Qualitätssicherungsmaßnahme
author: Zadjad Rezai
type: post
date: 2019-11-06T18:10:09+00:00
excerpt: Qualität sichern, indem zwei kluge Köpfe gemeinsam an einem Problem arbeiten.
url: /methodik/qualitatives-pair-programming/
featured_image: /img/hacker.webp
eael_transient_elements:
  - 'a:0:{}'
site-sidebar-layout:
  - default
site-content-layout:
  - default
theme-transparent-header-meta:
  - default
eael_uid:
  - cbfg8301573829439
categories:
  - Methodik
tags:
  - agil

---

<p>
<mark>
  Wer so wie die Person auf dem Bild arbeitet, sollte sich diesen Beitrag dringend durchlesen.
</mark></p>

<a rel="noreferrer noopener" href="https://en.wikipedia.org/wiki/Pair_programming" target="_blank"><em>Pair Programming</em></a> _wird in vielen Ebenen der Enterprise-Software-Entwicklung genutzt, gelebt, geliebt und manchmal auch gehasst._ 

Ein schönes Werkzeuge der agilen Software-Entwicklung bildet das Pair Programming, mit seinem intelligenten Ansatz das &#8222;Vier-Augen-Prinzip&#8220; auf eine geistig anstrengende Aufgabe anzuwenden.

Meiner Erfahrung nach wird man in traditionellen, deutschen Unternehmen nicht besonders häufig auf Projekte, in denen Pair Programming gelebt wird, treffen. Ich bin der Auffassung das kommt vom Drang vieler Unternehmen hier in Deutschland die Dinge bei dem zu belassen, was aktuell funktioniert. Gleichzeitig Streuben sich viele verschiedene Funktionsträger gegen die Ausübung des Pair Programmings, weil es kontraintuitiv scheint &#8211; man behauptet nämlich, dass die Effizienz steigt, obwohl nun zwei Personen an einer Aufgabe arbeiten. Durch diese und ähnliche falsche Annahmen fallen wir leider in vielen Bereichen zurück &#8211; siehe Industrie 4.0, Digitalisierung auf politischer Ebene und natürlich auch in vielen Bereichen der Automobilbranche.

Eine interessante wissenschaftliche Arbeit liefert folgendes Ergebnis: <a href="https://pdfs.semanticscholar.org/3918/81acebcf21072364316b812617c06140f67f.pdf" target="_blank" rel="noreferrer noopener" aria-label="Pair Programming steigert die Effizienz und Qualität (öffnet in neuem Tab)">Pair Programming steigert die Effizienz und Qualität</a>. Es sei jedoch erwähnt, dass es kaum empirische Daten zu diesem Problem gibt, weshalb die These auch ungenau sein kann. Viele Unternehmensberater, u. a. <a rel="noreferrer noopener" aria-label="ThoughtWorks (öffnet in neuem Tab)" href="https://www.thoughtworks.com/insights/blog/effective-navigation-in-pair-programming" target="_blank">ThoughtWorks</a>, sind für das Pair Programming und konnten dessen Wirken in vielen verschiedenen Projekten und Unternehmen miterleben.

Dieser Blog-Post soll auf gar keinen Fall ein Affront gegen die deutsche Industrie sein &#8211; sie hat unglaublich viel geleistet und &#8222;Made in Germany&#8220; erst zu einem Ausdruck von Qualität und Sicherheit gemacht &#8211; jedoch muss sie sich den neuen Gegebenheiten stellen und Dinge auch anders angehen.

Viele traditionelle deutsche Unternehmen haben eigene Bereiche, die sich mit neuen Technologien befassen. Als Beispiel erster Schritte sehe ich die <a href="https://www.draeger.com/en_corp/About-Draeger/Innovation/Innovation-Stories" target="_blank" rel="noreferrer noopener" aria-label=" (öffnet in neuem Tab)">Garage des Drägerwerks in Lübeck</a>. 

Zurück zum Thema: Pair Programming ist eine schon recht &#8222;alte&#8220; Herangehensweise an Probleme. Diese Herangehensweise unterstützt agile Teams dabei wahres Continuous Delivery zu erbringen, indem man Dinge wie festen Code Ownership, unklare Veränderungen und lange, oft technisch unattraktive Pull Requests verhindet.


>Pair programmers: Keep each other on task. Brainstorm refinements to the system. Clarify ideas. Take initiative when their partner is stuck, thus lowering frustration. Hold each other accountable to the team&#8217;s practices.<br><br>
>‒ **Kent Beck**, Extreme Programming Explained: Embrace Change


### Pair Programming {#0-pair-programming}

Es ist oft enorm schwierig sein Team davon zu überzeugen, dass Pair Programming angewendet werden sollte &#8211; warum? Die Projekt Manager wollen schnelle Ergebnisse sehen und die gibt es doch scheinbar nur, wenn sich die Programmierenden an ihren Platz setzen, mit niemandem plaudern und ausschließlich ihrer Aufgabe nachgehen. Wir möchten produktive Programmierende haben, die ohne große Diskussionen und Ablenkung arbeiten können &#8211; Effektivität ist unglaublich wichtig!

Die Programmierenden sollen konstant an ihrer Aufgabe arbeiten, vordefiniert durch eine Story mit Story Points. Sobald die Aufgabe erledigt ist, soll diese vorgestellt, ggf. überarbeitet und dann abgegeben werden. Die Abgabe erfolgt über einen Pull-Request, dessen Code andere kluge Köpfe kommentieren und Verbesserungen anfordern, bis sie nicht nur mit der Funktionsweise, sondern auch mit dem Code zufrieden sind.

Das ist was man sich eigentlich wünscht. Die Realität sieht oft anders aus. Im Normalfall wird die Story erledigt und ein Pull-Request wird gestellt &#8211; bis hier hin in einem gut funktionierenden Team alles gleich. Dann passiert jedoch oft folgendes: Der Code ist unsauber, Design Patterns wurden nicht korrekt umgesetzt oder missachtet, es ist nicht wirklich nach SOLID gearbeitet worden oder andere weniger gravierende Probleme treten auf. Aber eine Verbesserung davon zu erhalten dauert enorm lange und zieht die Abgabe der Story nach hinten, macht den Sprint kaputt, stört die Product Owner und vieles mehr. Die Entscheidung vieler Reviewer &#8211; weil es grundsätzlich bloß menschlich ist &#8211; ist dem statt zu geben, da es momentan funktioniert. Man verspricht sich eine neue Story, ein neues ToDo oder ähnliches zu schreiben, damit diese Sache später behoben wird. Da sie aber unwichtig scheint, weil das Programm funktioniert, wird das natürlich weit nach hinten geschoben &#8211; falls das überhaupt eine Erwähnung im Board findet. Leider missachtet man in dem Moment, dass diese eine Sache spätere Änderungen enorm verzögern kann. **Der erste Schritt in Richtung technische Schulden.**

Dafür ist das Pair Programming da. Wenn zwei kluge Köpfe gemeinsam an einem Problem sitzen und das Pair Programming korrekt ausführen, werden solche Probleme im Normalfall vermieden. Man hat nur zwei Personen, die sich ggf. regelmäßig in den Aufgaben abwechseln. Person A befindet sich im Modus des Schreibers und Person B im Modus des _Strategen_. Beide verfolgen das selbe Ziel, arbeiten aber an zwei Fronten. So können sie sich gegenseitig unterstützen, voneinander lernen und kennen beide die Änderungen und Verbesserung im Code.

Der _Schreiber_ konzentriert sich auf das aktuelle Problem und lokale Verbesserungen, während sich der _Stratege_ auf Probleme konzentriert, die durch die Änderungen hervorgerufen werden können. Während beide gemeinsam versuchen auf korrektes Design und intelligente Umsetzung zu achten.

Somit gibt es keine strikten Code-Ownership-Barrieren mehr, welche viele positive Änderungen verlangsamt.

Gleichzeitig muss man als Pairer erklären und manchmal sogar verteidigen warum man eine Sache auf eine bestimmte Art umsetzt &#8211; wird man vom Partner mit einem besseren Argument belehrt, hat man (a) dazugelernt und (b) besseren Code. In Kombination mit dem Vorteil des Kollektiven-Code-Ownerships erzeugt das echtes Continuous Integration.

Bedeutet; der Code wird schon während des Schreibens überprüft, ausdiskutiert, verbessert und durchgesprochen. So muss kein Reviewer mehr einen Pull-Request mit schlechtem Gewissen akzeptieren.