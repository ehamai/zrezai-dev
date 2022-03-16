---
title: 'Docker – Teil 3: Eintauchen in komplexere Bereiche'
author: Zadjad Rezai
type: post
date: 2020-03-31T08:29:42+00:00
excerpt: In Teil-1 bin ich teilweise auf die Ziele von Docker eingegangen, jedoch habe ich außen vor gelassen wie das ganze überhaupt funktioniert. Wie kann es sein, dass man isolierte VM-ähnliche Gebilde hat, während man keinen eigenen Kernel braucht?
url: /container/docker-teil-3/
featured_image: /img/docker-3/humpback-whale-whale-marine.webp
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
Wie in <a rel="noreferrer noopener" aria-label="Teil-2 (öffnet in neuem Tab)" href="https://zrezai-dev.de/container/docker-rest-apis-teil-2/" target="_blank">Teil-2</a> versprochen, tauchen wir diesmal etwas tiefer in Docker ein, verbessern und erweitern unsere App.

Das <a rel="noreferrer noopener" aria-label="Repository (öffnet in neuem Tab)" href="https://github.com/Xcalizorz/docker-example-restapi" target="_blank">Repository</a> basiert jetzt auf verschiedenen Branches, die jeweils mit einem Blogpost zusammen hängen. Aktuell gibt es die Branch _<a rel="noreferrer noopener" aria-label="step-2 (öffnet in neuem Tab)" href="https://github.com/Xcalizorz/docker-example-restapi/tree/part-2" target="_blank">step-2</a>_, und _<a rel="noreferrer noopener" aria-label="step-3 (öffnet in neuem Tab)" href="https://github.com/Xcalizorz/docker-example-restapi/tree/part-3" target="_blank">step-3</a>_ welcher mit Teil 2 bzw. Teil 3 der Docker-Serie zusammenhängen.

## Docker Funktionsweise

In <a rel="noreferrer noopener" aria-label="Teil-1 (öffnet in neuem Tab)" href="https://zrezai-dev.de/container/docker-teil-1-eine-einfuehrung/" target="_blank">Teil-1</a> bin ich teilweise auf die Ziele von Docker eingegangen, jedoch habe ich außen vor gelassen wie das ganze überhaupt funktioniert. Wie kann es sein, dass man isolierte VM-ähnliche Gebilde hat, während man keinen eigenen Kernel braucht?

<p>
  <mark>Das Problem ist, dass das gar nicht stimmt.</mark>
</p>

Docker ist zwar recht isoliert, jedoch nicht auf dem Level einer VM! In den aller meisten Fällen wird das auch unwichtig sein, aber es ist wichtig zu wissen, dass Docker **Linux**-Namespaces nutzt, um einen isolierten Prozess zu simulieren.

Grundsätzlich sieht der Docker-Alltag so aus, dass ein Docker-Daemon gestartet wird und dieser u. a. für die Erstellung jener isolierten Prozesse zuständig ist. Auf Windows wird dieser Daemon ironischerweise in einer VM gestartet, da ein Linux-Kernel gebraucht wird, um Linux-Namespaces zu nutzen.

<div style="text-align:center;">
  <figure class="aligncenter size-large"><img src="/img/docker-3/docker-intern-1.webp" alt="" class="wp-image-1063" /><figcaption>Abbildung 1: Docker Daemon erstellt Container</figcaption></figure>
</div>

Zur Isolierung werden unter anderem folgende System-interne Möglichkeiten ausgenutzt:

  >* PID namespace — Process identifiers and capabilities
  >* UTS namespace — Host and domain name
  >* MNT namespace — Filesystem access and structure
  >* IPC namespace — Process communication over shared memory
  >* NET namespace — Network access and structure
  >* USR namespace — User names and identifiers
  >* chroot syscall — Controls the location of the filesystem root
  >* cgroups — Resource protection
  >* CAP drop — Operating system feature restrictions
  >* Security modules — Mandatory access controls
  > <br>‒ Docker in Action, Jeff Nickeloff & Stephan Kuenzli, Manning Publications 2019_

Da Docker-Container keinen eigenen Kernel haben, nutzen sie immer den Host-Kernel, um Befehle an die Hardware zu leiten. Dadurch ist Docker nicht ganz so flexibel wie eine VM. Sollte beispielsweise eines der containerisierten Anwendungen eine ganz bestimmte Kernelversion brauchen, wird diese auch nur bei ganz bestimmten Anwendern funktionieren &#8211; da wäre wahrscheinlich die Nutzung einer VM anzuraten.

## Erweitern der Flask API

Im ersten Schritt, haben wir eine sehr simple Anwendung erstellt. Damit die REST API einfacher erweitert & dokumentiert werden kann, sollten wir <a rel="noreferrer noopener" aria-label="Swagger (öffnet in neuem Tab)" href="https://swagger.io/" target="_blank">Swagger</a> zur Dokumentation nutzen und eine bessere Möglichkeit zur Erstellung von REST APIs nutzen.

Nach einem ersten Aufteilen, befindet sich der Code jetzt in `learn_docker_app/`. Um `app.py` starten zu können, muss unser `PYTHONPATH` angepasst werden:

```shell
export PYTHONPATH="{PYTHONPATH}:/path/to/docker-example-restapi"
```

Wir nutzen `flask_restx`, um unsere `REST API` zu dokumentieren & diese in verschiedene Namespaces aufzuteilen.
`learn_docker_app/api/__init__.py`

```python
"""
A collection of all API namespaces provided by the app.
If you want to add more namespaces, you need to provide them inside this sub-module
and add the namespace to the `Api`. Here is an example:
After creating a new file called `new_api.py` with the following simple content:

  from flask_restx import Namespace
  new_api_namespace = Namespace('New API', description='Any description.')

We have to add the new namespace to our `Api` via inserting the following lines into `apis/__init__.py`:

  from .new_api import new_api_namespace
  api.add_namespace(new_api_namespace, path='/new/')

Now, the `New API` can be contacted via `baseurl/new/`
"""
from flask_restx import Api
from .respond import respond_namespace

api = Api(
    version='1.0',
    title='Learning Docker API',
    description='A simple API created by Zadjad Rezai',
)

api.add_namespace(respond_namespace, path='/respond/')
```

Ein neues Feature soll dazu kommen - `learn_docker_app/tests/test_responses.py`. Sobald ein Nutzer über eine `GET`-Anfrage `/respond/hostname` aufruft, sollen möglichst der Hostname & das Betriebssystem des Clients sowie des Servers ausgegeben werden. Natürlich, wie immer &#8211; zuerst die Tests. 💉

```python
from dataclasses import dataclass
from types import SimpleNamespace

import pytest

from learn_docker_app.app import create_app


@pytest.fixture
def client():
    app = create_app()
    app.config['TESTING'] = True

    with app.test_client() as client:
        yield client


class TestResponse:
    @staticmethod
    def copy_cat_response(test_string: str):
        return f"/respond/{test_string}"

    @pytest.mark.parametrize("test_string", [
        "hi", "bye", "xxx", "123!", "-12312",
    ])
    def test_simple_response__simple_message(self, client, test_string):
        response = client.get(self.copy_cat_response(test_string))

        assert response.status_code == 200
        assert response.json == {'response': test_string}

    @pytest.mark.parametrize("test_string", [
        "../", "\\//..", "cd ..//",
    ])
    def test_simple_response__wrong_url(self, client, test_string):
        response = client.get(self.copy_cat_response(test_string))

        assert response.status_code == 404

    def test_hostname(self, client, monkeypatch):
        monkeypatch.setattr('learn_docker_app.api.respond.platform', MockPlatform)
        monkeypatch.setattr('learn_docker_app.api.respond.request', MockRequest)

        response = client.get(f"/respond/hostname")

        assert response.status_code == 200
        assert response.json == {
            'host': {
                'hostname_or_ip': 'TEST-HOSTNAME',
                'system': 'TEST-SYSTEM',
            },
            'client': {
                'hostname_or_ip': 'TEST-HOSTNAME-CLIENT',
                'system': 'TEST-SYSTEM-CLIENT',
            },
        }


class MockPlatform:
    """Will override the builtin platform module"""

    @staticmethod
    def node():
        return 'TEST-HOSTNAME'

    @staticmethod
    def system():
        return 'TEST-SYSTEM'


@dataclass
class MockRequest:
    """Will override the flask.request object"""
    user_agent = SimpleNamespace(platform='TEST-SYSTEM-CLIENT')
    remote_addr = 'TEST-HOSTNAME-CLIENT'
```

Neu hinzugekommen sind `test_hostname()` sowie zwei Mock-Klassen, die innerhalb der Tests bestimmte Funktionen bzw. Klassen anpassen sollen. `MockPlatform` ist ein Mock des internen Moduls `platform`, welches uns Informationen über den Server liefern kann. `MockRequest` soll`flask.request` überschreiben, welches uns Daten über den Client liefern kann.

Jedes `API` Namespace wird in einer eigenen `.py`-Datei definiert und implementiert - z. B. `learn_docker_app/api/respond.py`.

```python
import platform

from flask import request
from flask_restx import fields, Namespace, Resource

respond_namespace = Namespace(
    'respond',
    description='Provides operations that generate a simple response.'
)

copy_cat_model = respond_namespace.model('Respond', {
    'response': fields.String(description='The string provided.')
})


@respond_namespace.route('/<string>')
class Copycat(Resource):
    @respond_namespace.marshal_with(copy_cat_model)
    def get(self, string: str):
        return {
            'response': string,
        }


platform_model = respond_namespace.model('Host', {
    'hostname_or_ip': fields.String(
        description='The computer’s network name (may not be fully qualified!) or its ip address.' \
                    'An empty string is returned if the value cannot be determined.'
    ),
    'system': fields.String(
        description='Returns the system/OS name, such as "Linux", "Darwin", ' \
                    '"Java", "Windows". An empty string is returned if the' \
                    'value cannot be determined.'
    )
})
hostname_model = respond_namespace.model('Hostname', {
    'host': fields.Nested(platform_model, description='Data concerning the API server.'),
    'client': fields.Nested(platform_model, description='Data concerning the requesting client.'),
})


@respond_namespace.route('/hostname')
class Hostname(Resource):
    @respond_namespace.marshal_with(hostname_model)
    def get(self):
        return {
            'host': {
                'hostname_or_ip': platform.node(),
                'system': platform.system(),
            },
            'client': {
                'hostname_or_ip': request.remote_addr,
                'system': request.user_agent.platform,
            },
        }
```

Die `Copycat`-Klasse übernimmt die Aufgabe der alten `simple_response()`-Funktion.

Die `Hostname`-Klasse erlaubt es uns Information über den Server und den anfragenden Client weiterzugeben. Hier also einmal den Hostnamen oder die IP-Adresse sowie das erkannte Betriebssystem. Dadurch können wir uns anschauen welchen Hostnamen unser Docker-Container hat.

Da das UTS namespace (Host and domain name) von Docker genutzt wird, um möglichst tiefgreifende Isolierung zu erzielen, sollte jeder Container einen eigene Hostnamen zugewiesen bekommen.

![](/img/docker-3/local_2.webp)

![](/img/docker-3/local_2_hostname.webp)

Auf unserem Host-PC funktioniert die API einwandfrei. Unser Flask-Server nutzt wieder Port `5000`.

Die Ausgabe von `/respond/hostname` ist:

```json
{
  "host": {
    "hostname_or_ip": "REDACTED",
    "system": "windows"
  },
  "client": {
    "hostname_or_ip": "127.0.0.1",
    "system": "windows"
  }
}
```

## Docker

Wir erweitern unsere `.dockerignore`-Datei, um weitere unnötige Dateien auszugrenzen:

```
**/%appdata%
**/venv
**/__pycache__

.idea
.github
.devcontainer
.vscode
.gitignore
LICENSE
*.md
img
```

Danach passen wir unser `Dockerfile` an, damit diese mit der neuen Projekt-Struktur zurechtkommt:

```dockerfile
FROM python:3.7.7-alpine
WORKDIR /home/learn_docker_app
ENV PYTHONPATH "${PYTHONPATH}:/home"
COPY learn_docker_app ./

RUN pip3 install --upgrade pip \
    && pip3 --disable-pip-version-check --no-cache-dir install -r requirements.txt \
    && pip3 --disable-pip-version-check --no-cache-dir install -r requirements-test.txt \
    && rm -rf *.txt \
    && pytest

EXPOSE 5000
ENTRYPOINT ["python3", "app.py"]
```

Neu hier ist, dass wir unseren `RUN`-Befehl in einen Befehl gefasst haben, um möglichst wenig Image-Layer in unserem Build zu haben. So wird die Buildgröße kleingehalten.

Außerdem ist der `ENV`-Befehl neu. Dieser definiert Umgebungsvariablen &#8211; hier setzen wir unseren `PYTHONPATH` genau wie vorher auch.

Docker erstellt aus Optimierungsgründen für jeden Befehl eine eigene Schicht (Layer) &#8211; ein isolierter Container, der nur diesen einen Schritt ausführt. Diese einzelnen Container sieht man auch im Buildprozess, siehe unten.

<p>
  <mark>Nun starten wir den Buildprozess</mark>
</p>

`docker image build --tag xcalizorz/docker-example-restapi:1.1 .`

```terminal
Sending build context to Docker daemon  286.7kB
Step 1/7 : FROM python:3.7.7-alpine
3.7.7-alpine: Pulling from library/python
aad63a933944: Pull complete
f229563217f5: Pull complete
71ded8122394: Pull complete
807d0888ee2e: Pull complete
95206a02ba21: Pull complete
Digest: sha256:4a704ebee45695fa91125301e43eee08a85fc984d05cc75650cc66fad7826c56
Status: Downloaded newer image for python:3.7.7-alpine
 ---> 7fbc871584eb
Step 2/7 : WORKDIR /home/learn_docker_app
 ---> Running in ab4310580790
Removing intermediate container ab4310580790
 ---> 6bef8525d882
Step 3/7 : ENV PYTHONPATH "${PYTHONPATH}:/home"
 ---> Running in 2141d223dcdd
Removing intermediate container 2141d223dcdd
 ---> c1b348453453
Step 4/7 : COPY learn_docker_app ./
 ---> 8ad2bc2439b8
..
...
....
============================= test session starts ==============================
platform linux -- Python 3.7.7, pytest-5.4.1, py-1.8.1, pluggy-0.13.1
rootdir: /home/learn_docker_app
collected 9 items

tests/test_responses.py .........                                        [100%]

============================== 9 passed in 0.20s ===============================
Removing intermediate container 4cab6203ca5b
 ---> e681ce2ee7b9
Step 6/7 : EXPOSE 5000
 ---> Running in 6c16c40836ac
Removing intermediate container 6c16c40836ac
 ---> 3683acd0cad5
Step 7/7 : ENTRYPOINT ["python3", "app.py"]
 ---> Running in c17aed8c3cf9
Removing intermediate container c17aed8c3cf9
 ---> 1ac04a07a974
Successfully built 1ac04a07a974
Successfully tagged xcalizorz/docker-example-restapi:1.1
```

Um Platz zu sparen habe ich `Step 4` und `5` ausgelassen.

Die Layer erkennt man z. B. hier:

```
Step 6/7 : EXPOSE 5000
 ---> Running in 6c16c40836ac
Removing intermediate container 6c16c40836ac
```

`6c16c40836ac` ist der Container für den Layer, welcher in `Step 6` genutzt wird.

Da wir nun auch `pytest` aufrufen, wird der Buildprozess fehlschlagen, sobald nicht alle Tests fehlerfrei ausgeführt werden konnten. Vielleicht integrieren wir das ganze in Zukunft mit <a href="https://jenkins.io/" target="_blank" rel="noreferrer noopener" aria-label="Jenkins (öffnet in neuem Tab)">Jenkins</a> o. ä.?

<p>
  <mark>Jetzt können wir unseren Container starten</mark>
</p>

`docker container run --detach --publish 8080:5000 --name webserver xcalizorz/docker-example-restapi:1.1`

Das ist equivalent zu:

`docker run -d -p 8080:5000 --name webserver xcalizorz/docker-example-restapi:1.1`

Auf geht&#8217;s zu <a rel="noreferrer noopener" aria-label=" (öffnet in neuem Tab)" href="http://localhost:8080/" target="_blank">http://localhost:8080/</a>

![](/img/docker-3/in_docker_2.webp)

![](/img/docker-3/in_docker_2_hostname.webp)

Die Ausgabe von `/respond/hostname` ist jetzt:

```json
{
  "host": {
    "hostname_or_ip": "82c1788f0d51",
    "system": "Linux"
  },
  "client": {
    "hostname_or_ip": "172.17.0.1",
    "system": "windows"
  }
}
```

Damit haben wir den Beweis &#8211; unser Docker-Container ist in seiner eigenen, isolierten Umgebung.

`172.17.0.1` ist das sogenannte <a rel="noreferrer noopener" aria-label="default-bridge-network (öffnet in neuem Tab)" href="https://docs.docker.com/network/network-tutorial-standalone/#use-the-default-bridge-network" target="_blank">default-bridge-network</a> von Docker.