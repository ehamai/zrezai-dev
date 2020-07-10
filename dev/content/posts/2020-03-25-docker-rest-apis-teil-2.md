---
title: 'Docker – Teil 2: Eigene REST API'
author: Zadjad Rezai
type: post
date: 2020-03-25T20:16:43+00:00
excerpt: Um die Simplizität von Docker zu erläutern, möchte ich eine kleine Python-Anwendung erstellen, welche wir über Docker veröffentlichen und nutzen können. Der Code sollte ab Python 3.6 funktionieren und ist auf meinem Github-Repo einsehbar.
url: /container/docker-rest-apis-teil-2/
featured_image: https://i.giphy.com/media/RiHcR76mXBUT6/giphy.webp
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
  - Flask
  - REST API

---

Um die Simplizität von Docker zu erläutern, möchte ich eine kleine Python-Anwendung erstellen, welche wir über Docker veröffentlichen und nutzen können. Der Code sollte ab Python 3.6 funktionieren und ist auf <a href="https://github.com/Xcalizorz/docker-example-restapi/tree/part-2" target="_blank" rel="noreferrer noopener" aria-label=" (öffnet in neuem Tab)">meinem Github-Repo</a> einsehbar. Für eine Einführung in 

`Flask`, schaut euch <a href="https://flask.palletsprojects.com/en/1.1.x/tutorial/#tutorial" target="_blank" rel="noreferrer noopener" aria-label=" (öffnet in neuem Tab)">das offizielle Tutorial</a> an. 

Im ersten Schritt soll nur eine simple `API` geschrieben werden, welche beim Aufrufen von `/response/<string>` den angegeben String als Antwort zurücksenden.

Bevor wir beginnen sollten folgende Pakete installiert werden: `pytest, flask`

Gerne auch über `python -m pip install -r app/requirements.txt`

## Tests

Nach [TDD][1]-manier, beginnen wir erstmal mit einem Test &#8211; ich nutze gerne `pytest` für meine Tests, weil das ein enorm gutes Framework ist, um schnell, einfach und professionel Tests zu schreiben.

Zuerst erstellen wir die `./setup.cfg` für `pytest`.

```cfg
[tool:pytest]
log_auto_indent = True
testpaths = app/tests
```

Dann können wir mit dem Schreiben erster Tests (`./app/tests/test_responses.py`) beginnen:

```python
import pytest

from app.app import app


@pytest.fixture
def client():
    app.config['TESTING'] = True

    with app.test_client() as client:
        yield client


class TestResponse:
    @pytest.mark.parametrize("test_string", [
        "hi", "bye", "xxx", "123!", "-12312",
    ])
    def test_simple_response__simple_message(self, client, test_string):
        response = client.get(f"/respond/{test_string}")

        assert response.status_code == 200
        assert response.json == {'response': test_string}

    @pytest.mark.parametrize("test_string", [
        "../", "\\//..", "cd ..//",
    ])
    def test_simple_response__wrong_url(self, client, test_string):
        response = client.get(f"/respond/{test_string}")

        assert response.status_code == 404
```

In Zeile 6 bis 11 erstellen wir einen `Flask`-Testclient und nutzen diesen, um unsere `API` zu testen.

Über die `TestResponse` Klasse überprüfen wir zwei simple Szenarien

  1. Nutzer übergibt eine akzeptierte Nachricht ein `test_simple_response__simple_message`
  2. Nutzer gibt etwas nicht akzeptables ein `test_simple_response__wrong_url`

In Szenario 1 wird als Rückmeldung eine `JSON`-Antwort erwartet, welche so aussieht: `{'response': test_string}`  
Im zweiten Szenario wird ein `404-Fehler` erwartet.

## REST API

Da wir die Tests nun haben, können wir uns an die `REST API` setzen und unsere Tests mit `./app/app.py` zum laufen bringen.

```python
from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/respond/<string>", methods=['GET'])
def simple_response(string: str):
    return jsonify(
        response=string
    )


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

In `Flask` kann man natürlich auch klassenbasiert arbeiten, aber so wie es jetzt ist, ist es erstmal in Ordnung.  
Unsere `API` erlaubt eine `GET` Anfrage an `/respond/<string>` und kreiert eine `JSON`-Antwort mit dem Inhalt `{response: string}`

Nun können wir unsere App via Python starten: `python app/app.py`

<div style="text-align:center;">
  <figure class="aligncenter size-large"><img src="/img/docker-2/local_1.webp" alt=""/><figcaption>Abbildung 1: GET Anfrage auf localhost</figcaption></figure>
</div>

Die Tests können wir mit dem Befehl `pytest` ausführen.

```terminal
(venv) C:\..\docker-example-restapi> pytest
===================================== test session starts =====================================
platform win32 -- Python 3.7.4, pytest-5.4.1, py-1.8.1, pluggy-0.13.1
rootdir: C:\..\docker-example-restapi, inifile: setup.cfg, testpaths: app/tests
collected 8 items

app\tests\test_responses.py ........                                                     [100%]

===================================== 8 passed in 0.40s =======================================
```

Da alle Tests problemlos durchgelaufen sind, wissen wir, dass unsere `API` funktioniert wie wir wollen.

## Docker

Docker nutzt u. a. `Dockerfiles`, um die einzelnen Schritte der Instanziierung zu beschreiben.

```dockerfile
FROM python:3.7.7-alpine
COPY app /app
WORKDIR /app
RUN pip3 install --upgrade pip
RUN pip3 install -r requirements.txt
EXPOSE 5000
ENTRYPOINT ["python3"]
CMD ["app.py"]</pre>
```

Gehen wir hier einmal Zeilenweise durch

  1. `FROM` beschreibt wo wir beginnen wollen &#8211; wir wollen bei einer Dockerumgebung beginnen, die durch [python:3.7.7-alpine][2] definiert ist
      * Dadurch wird Python 3.7.7 installiert, ggf. heruntergeladen, falls nicht lokal vorhanden
  2. `COPY` funktioniert wie der Linux-`cp`-Befehl. `cp source destination` &#8211; Damit wird der lokale Ordner `app` in den Docker-Ordner `app/` kopiert
  3. `WORKDIR` definiert den aktuellen Arbeitsordner
  4. `RUN` beschreibt was genau innerhalb der Docker-Instanz (bei mir eine Linux-Instanz) aufgerufen werden soll
      * Im ersten Schritt upgrade ich pip
      * Im zweiten Schritt werden alle nötigen Abhängigkeiten installiert (genau wie bei einer lokalen Installation)
  5. `EXPOSE` sagt aus unter welchen Ports unsere Docker-Instanz von außen erreichbar sein soll &#8211; hier 5000
  6. `ENTRYPOINT` erlaubt höhere Kontrolle der Eingangsargumente beim Starten des Containers &#8211; alle Argumente von `docker run` sind damit Argumente des `ENTRYPOINT`&#8217;s
  7. `CMD` irgendeine Anweisung an unseren Container
      * Da unser `ENTRYPOINT` `python3` ist, wäre der gesamte Befehl `python3 app.py`

<p>
  <mark>.dockerignore</mark>
</p>

Eine `.dockerignore`-Datei funktioniert wie eine `.gitignore`-Datei &#8211; alles darin angegebene wird nicht Teil des Dockerbuilds. Mehr Details in der [Docker Dokumentation][3].

```gitignore
**/%appdata%
**/venv</pre>
```

<p>
  <mark>docker build</mark>
</p>

Jetzt können wir endlich anfangen zu bauen. Insgesamt wurden nur zwei Dateien mit zusammen 10 Zeilen Code hinzugefügt.  
Nun geht es endlich in eine Shell-Umgebung (tty, powershell, etc.)

```terminal
[node1] (local) root ~
$ ls
    docker-example-restapi

[node1] (local) root ~
$ cd docker-example-restapi/

[node1] (local) root ~/docker-example-restapi
$ ls
    Dockerfile  LICENSE     README.md   app         setup.cfg

[node1] (local) root ~/docker-example-restapi
$ docker image build --tag xcalizorz/docker-example-restapi:1.0 .
    Sending build context to Docker daemon  123.4kB
    Step 1/8 : FROM python:3.7.7-alpine
    3.7.7-alpine: Pulling from library/python
    aad63a933944: Pull complete
    f229563217f5: Pull complete
    71ded8122394: Pull complete
    807d0888ee2e: Pull complete
    95206a02ba21: Pull completeDigest: sha256:4a704ebee45695fa91125301e43eee08a85fc984d05cc75650cc66fad7826c56
    Status: Downloaded newer image for python:3.7.7-alpine
     ---> 7fbc871584eb
    Step 2/8 : COPY app /app
     ---> 7988d031143d
    Step 3/8 : WORKDIR /app
     ---> Running in d71f7ff48d85
    Removing intermediate container d71f7ff48d85
     ---> 3f69a63db409
    Step 4/8 : RUN pip3 install --upgrade pip
     ---> Running in 305280adbbc9
    Requirement already up-to-date: pip in /usr/local/lib/python3.7/site-packages (20.0.2)
    Removing intermediate container 305280adbbc9
     ---> 6c9da2129f02
    Step 5/8 : RUN pip3 install -r requirements.txt
     ---> Running in fa85c4c1c56b
    Collecting flask
      Downloading Flask-1.1.1-py2.py3-none-any.whl (94 kB)
    Collecting pytest
      Downloading pytest-5.4.1-py3-none-any.whl (246 kB)
    Collecting Jinja2>=2.10.1
      Downloading Jinja2-2.11.1-py2.py3-none-any.whl (126 kB)
    Collecting itsdangerous>=0.24
      Downloading itsdangerous-1.1.0-py2.py3-none-any.whl (16 kB)
    Collecting Werkzeug>=0.15
      Downloading Werkzeug-1.0.0-py2.py3-none-any.whl (298 kB)
    Collecting click>=5.1
      Downloading click-7.1.1-py2.py3-none-any.whl (82 kB)
    Collecting importlib-metadata>=0.12; python_version &lt; "3.8"
      Downloading importlib_metadata-1.5.1-py2.py3-none-any.whl (30 kB)
    Collecting attrs>=17.4.0
      Downloading attrs-19.3.0-py2.py3-none-any.whl (39 kB)
    Collecting packaging
      Downloading packaging-20.3-py2.py3-none-any.whl (37 kB)
    Collecting more-itertools>=4.0.0
      Downloading more_itertools-8.2.0-py3-none-any.whl (43 kB)
    Collecting pluggy&lt;1.0,>=0.12
      Downloading pluggy-0.13.1-py2.py3-none-any.whl (18 kB)
    Collecting wcwidth
      Downloading wcwidth-0.1.9-py2.py3-none-any.whl (19 kB)
    Collecting py>=1.5.0
      Downloading py-1.8.1-py2.py3-none-any.whl (83 kB)
    Collecting MarkupSafe>=0.23
      Downloading MarkupSafe-1.1.1.tar.gz (19 kB)
    Collecting zipp>=0.5
      Downloading zipp-3.1.0-py3-none-any.whl (4.9 kB)
    Collecting six
      Downloading six-1.14.0-py2.py3-none-any.whl (10 kB)
    Collecting pyparsing>=2.0.2
      Downloading pyparsing-2.4.6-py2.py3-none-any.whl (67 kB)
    Building wheels for collected packages: MarkupSafe
      Building wheel for MarkupSafe (setup.py): started
      Building wheel for MarkupSafe (setup.py): finished with status 'done'
      Created wheel for MarkupSafe: filename=MarkupSafe-1.1.1-py3-none-any.whl size=12629 sha256=235a27d61d695fffaab5a991ce459a0ba4a9eae57113c9b6bf5a9a5c89e45088
      Stored in directory: /root/.cache/pip/wheels/b9/d9/ae/63bf9056b0a22b13ade9f6b9e08187c1bb71c47ef21a8c9924
    Successfully built MarkupSafe
    Installing collected packages: MarkupSafe, Jinja2, itsdangerous, Werkzeug, click, flask, zipp, importlib-metadata, attrs, six, pyparsing, packaging, more-itertools, pluggy, wcwidth, py, pytest
    Successfully installed Jinja2-2.11.1 MarkupSafe-1.1.1 Werkzeug-1.0.0 attrs-19.3.0 click-7.1.1 flask-1.1.1 importlib-metadata-1.5.1 itsdangerous-1.1.0 more-itertools-8.2.0 packaging-20.3 pluggy-0.13.1 py-1.8.1 pyparsing-2.4.6 pytest-5.4.1 six-1.14.0 wcwidth-0.1.9 zipp-3.1.0
    Removing intermediate container fa85c4c1c56b
     ---> d640ba0e6471
    Step 6/8 : EXPOSE 5000
     ---> Running in abf93887096d
    Removing intermediate container abf93887096d
     ---> 9792a24ce22b
    Step 7/8 : ENTRYPOINT ["python3"]
     ---> Running in 5559040fecef
    Removing intermediate container 5559040fecef
     ---> fb509e1def0d
    Step 8/8 : CMD ["app.py"]
     ---> Running in 52f84a3385e2
    Removing intermediate container 52f84a3385e2
     ---> c4256a07215a
    Successfully built c4256a07215a
    Successfully tagged xcalizorz/docker-example-restapi:1.0
```

Wir navigieren einfach in den Arbeitsordner `docker-example-restapi` und geben folgenden Befehl ein:

`docker image build --tag xcalizorz/docker-example-restapi:1.0 .`

  * `docker image build` erstellt das Docker Image
  * `--tag` erlaubt es uns einen benutzerdefinierten Namen zu vergeben
  * `.` ist der relative Pfad zum Ordner mit dem `Dockerfile`
  * `xcalizorz` ist meine Dockerhub ID

Nun haben wir ein Docker Image, jedoch läuft es noch nicht. Wenn man eine VM installiert und vorbereitet hat, ist diese z. B. in Virtualbox sichtbar &#8211; sie wurde schon _gebaut_, jedoch ist die VM noch aus.

Mit folgendem Befehl starten wir unser Image:

```terminal
[node1] (local) root ~/docker-example-restapi
$ docker container run --detach --publish 8080:5000 --name responder xcalizorz/docker-example-restapi:1.0
    7679e475e1517d2850c14fd6ffc7cc5947bc43ae506dbb9cc6cc22e2fa9a74e7</pre>
```

  * `docker container run` startet einen neuen Container mittels unseres Images
  * `--detach` startet den Container im Hintergrund
  * `--publish 8080:5000` veröffentlicht unseren Container auf Port 5000 des Docker Containers und 8080 des Host-Computers
      * `--publish host_port:container_port` &#8211; wenn nun Anfragen auf Port 8080 meines Host-Computers treffen, werden diese direkt an Port 5000 des Containers weitergegeben
  * `--name` vergibt einen Namen an unseren Container
  * Zuletzt noch den Namen unseres Images

Schon ist unser Container gestartet. Mit `docker container ls`, können wir die aktuell laufenden Container sehen

```terminal
[node1] (local) root ~/docker-example-restapi
$ docker container ls
CONTAINER ID        IMAGE                                  COMMAND             CREATED             STATUS              PORTS                    NAMES
7679e475e151        xcalizorz/docker-example-restapi:1.0   "python3 app.py"    18 minutes ago      Up 18 minutes       0.0.0.0:8080->5000/tcp   responder</pre>
```

Damit haben wir einen Container, der über `Port 8080` unseres Host-Computers erreichbar ist.

<div style="text-align:center;">
  <figure class="aligncenter size-large"><img src="/img/docker-2/in_docker_1.webp" alt=""/><figcaption>Abbildung 2: GET Anfrage an Docker</figcaption></figure>
</div>

<div style="text-align:center;">
  <figure class="aligncenter size-large"><img src="/img/docker-2/Sequenzdiagramm.webp" alt=""/><figcaption>Abbildung 3: Vereinfachtes Sequenzdiagramm unserer Anwendung</figcaption></figure>
</div>

Später wird die Anwendung erweitert und wir tauchen tiefer in die Materie der Container-Welt ein.

 [1]: https://zrezai-dev.de/methodik/warum-tdd/
 [2]: https://hub.docker.com/_/python
 [3]: https://docs.docker.com/engine/reference/builder/#dockerignore-file