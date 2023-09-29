---
title: 'Projekt 2: Infrastructure as Code - Ansible'
author: Zadjad Rezai
type: post
date: 2022-10-11T10:00:00+00:00
draft: true
excerpt: 'IaC - ein häufig genutzter Begriff mit Beispielen erläutert. Am Beispiel von Ansible als configurations management tool.'
url: /projekt/2/infra-as-code/ansible
featured_image: /img/infra-as-code/ansible.webp  # TODO add image
cover:
  image: /img/infra-as-code/ansible.webp  # TODO add image
categories:
  - Projekt
  - Methodik
tags:
  - projekt
  - cloud

---

<!-- TODO <a href="http://example.com/" target="_blank">Hello, world!</a> -->

# Projekt 2: Infrastructure as Code - Ansible

## Ansible

[Ansible](https://www.ansible.com/) ist ein beliebtes Konfigurationsmanagement Tool, welches Redhat gehört - daher sollte es auch die nächsten Jahre relativ gut unterstützt und geupdated werden.

Es gibt sicherlich guter alternativen z.B. [`SaltStack`](https://saltproject.io/), welches wir uns wann anders anschauen können.

Ansible ruft Code über SSH auf den Maschinen auf, die wir in der `hosts`-Datei definieren.

Der Post soll kein `Ansible` Tutorial darstellen, sondern einen Überblick darüber geben wie ich persönlich ein **simples** Projekt aufsetzen würde. Die Dokumentation ist hervorragend geschrieben, schaut sie auch gerne an: [`docs`](https://docs.ansible.com/ansible/latest/getting_started/index.html)


### Ansible Umgebung

Obligatorisch:

```bash
> ansible --version

ansible [core 2.13.4]
  python version = 3.8.10 (default, Jun 22 2022, 20:18:18) [GCC 9.4.0]
  jinja version = 3.1.2
```

```bash
.
├── ansible.cfg
├── inventories
│   └── production
│       ├── group_vars
│       │   └── all.yml
│       └── hosts                    # Im vorherigen Schritt vom Terraform erstellt
├── playbooks
│   ├── all.yml
│   └── install_webservers.yml
└── roles
    └── webservers
        ├── handlers
        │   └── main.yml
        ├── tasks
        │   ├── copy_code.yml
        │   ├── install_httpd.yml
        │   └── main.yml
        └── templates
            ├── httpd.conf.j2
            ├── index.php.j2
            └── webserver.conf.j2
```

#### `ansible.cfg`

In `ansible.cfg` kann man viele Einstellungen treffen, um einen auskommentierten `default` zu erstellen, kann man diesen Befehl ausführen:

```bash
ansible-config init --disabled > ansible.cfg
```

Interessant für mich war eigentlich nur die Eingabe meines private keys.
Der public key wurde über `terraform` auf die angelegten Maschinen ausgerollt & mit dem private key, ist es nun möglich eine passwortlose `SSH`-Verbindung aufzubauen.

```cfg
# (path) Option for connections using a certificate or key file to authenticate, rather than an agent or passwords, you can set the default value here to avoid re-specifying --private-key with every invocation.
private_key_file=~/.ssh/mykey
```

Wenn man möchte, kann man hier z.B. den Pfad zum Inventory (default: `/etc/ansible/hosts`) anpassen:

```cfg
# (pathlist) Comma separated list of Ansible inventory sources
inventory=./inventories/production
```

#### `inventories` Ordner

In `inventories` befinden sich zum einen Umgebungsabhängige Variablen und zum anderen die `hosts` Datei.

In der Hosts Datei sind die IP-Adressen der erzeugten Instanzen:

```ini
# inventories/production/hosts

[all]
3.70.99.43
3.71.179.254

[webservers]
3.70.99.43
3.71.179.254
```

Unter `group_vars` kann man Variablen definieren, die für die jeweiligen Maschinengruppen, hier `webservers` und `all` gelten. In diesem Beispiel existiert nur `all.yml` und ist für alle Maschinen gültig.

```bash
# inventories/production/group_vars/all.yml
# Variables listed here are applicable to all host groups

https_port: 443
http_port: 80

user: ec2-user
```

#### `playbooks` Ordner

Playbooks werden genutzt, um strukturell zusammenpassende Aktionen zu bündeln. Ein `playbook` ist simple aufgebaut und ruft praktisch nur die jeweils passenden `roles` aus.

In den `roles` ist der tatsächliche Code versteckt, welcher ausgeführt wird. So sorgen wir dafür, dass auch unser Ansible code möglichst `DRY` bleibt und auch in anderen Projekten Verwendung finden kann.

```bash
.
├── playbooks
│   ├── all.yml
│   └── install_webservers.yml
```

```bash
# playbooks/all.yml

- import_playbook: install_webservers.yml
# - import_playbook: install_databases.yml
# - import_playbook: ....
```

`all.yml` zu definieren erlaubt uns später **alle** playbooks gemeinsam aufzurufen. So kann man z.B. Webserver, Datenbanken und andere mit nur einem Befehl installieren. Hier ist es natürlich noch simple, da wir ausschließlich ein anderes `playbook` importieren.

```bash
- name: Configure webservers and deploy application code
  hosts: webservers
  remote_user: "{{ user }}"
  roles:
    - webservers
```

In `install_webservers.yml` rufen wir die Rolle `webservers` auf, welche als Ordner in `roles/webservers` definiert ist.

Mehr dazu in den [`ansible docs`](https://docs.ansible.com/ansible/latest/user_guide/playbooks.html#working-with-playbook)

Da `aws` spezielle `user` für den SSH definiert, ist der user dynamisch über `group_vars/all.yml` oder [`--extra-vars`](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#defining-variables-at-runtime) änderbar, indem man `user` überschreibt.

Ich persönlich mag es nicht innerhalb des `playbooks` `become: true` zu setzen - auch wenn es später vielleicht oft gebraucht wird - weil ich ungerne als `root` eine SSH Verbindung aufbauen möchte. Lieber als normaler user rein & dann über `sudo` Befehele ausführen, wenn `sudo` nötig ist.

#### `roles` Ordner

```bash
.
└── roles
    └── webservers
        ├── handlers
        │   └── main.yml
        ├── tasks
        │   ├── copy_code.yml
        │   ├── install_httpd.yml
        │   └── main.yml
        └── templates
            ├── httpd.conf.j2
            ├── index.php.j2
            └── webserver.conf.j2
```

Im `roles` Ordner passiert das eigentliche `Configurationmanagement`. Darin können noch viele andere Ordner angelegt werden, die alle ihre Aufgaben erfüllen, mehr dazu aber lieber direkt in den [`ansible docs`](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html) nachlesen.

Alle Ordner haben `main.yml` als Einstiegspunkt & `main.yml` kann andere Dateien aufrufen bzw. importieren.

##### `tasks`

In den `tasks` definieren wir alle tatsächlichen Aufgaben.

```yaml
# roles/webservers/tasks/main.yml

- include_tasks: install_httpd.yml
- include_tasks: copy_code.yml
```

Es wird ausschließlich auf andere Dateien verwiesen, die sich im selben Ordner befinden:


```yaml
# roles/webservers/tasks/copy_code.yml

- name: Insert simple index.php
  become: true
  template:
    src: index.php.j2
    dest: /var/www/html/index.php
  notify: restart httpd
```

In `copy_code.yml` wird die `jinja2` Datei `templates/index.php.j2` ausgewertet und nach `/var/www/html/index.php` kopiert. Danach wird der `handler` mit dem Namen `restart httpd` ausgeführt.


```yaml
- name: Install http and php, etc.
  become: true
  yum:
    name: "{{ item }}"
    state: present
  with_items:
    - httpd
    - php
    - php-mysql
    - libsemanage-python
    - libselinux-python

- name: Insert httpd config
  become: true
  block:
  - name: Insert httpd.conf
    template:
      src: httpd.conf.j2
      dest: /etc/httpd/conf/httpd.conf
  - name: Insert webserver virtualhost config
    vars:
      port: "{{ item }}"
    with_items:
      - "{{ https_port }}"
      - "{{ http_port }}"
    template:
      src: webserver.conf.j2
      dest: "/etc/httpd/conf.d/webserver_{{ item }}.conf"

- name: http service state
  become: true
  service:
    name: httpd
    state: started
    enabled: yes
```

##### `handlers`

Handlers erlauben uns z.B. services sauber neuzustarten, indem wir Aufgaben aus den Tasks an sie übergeben. Normalerweise werden handlers genutzt, um eine Sache auszuführen, sobald der dazugehörige Task erfolgreich ausgeführt wurde.



```bash
> ansible-playbook playbooks/all.yml -i inventories/production

PLAY [Configure webservers and deploy application code] **************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************
[WARNING]: Platform linux on host 3.70.99.43 is using the discovered Python interpreter at /usr/bin/python3.7, but future installation of another Python
interpreter could change the meaning of that path. See https://docs.ansible.com/ansible-core/2.13/reference_appendices/interpreter_discovery.html for
more information.
ok: [3.70.99.43]
[WARNING]: Platform linux on host 3.71.179.254 is using the discovered Python interpreter at /usr/bin/python3.7, but future installation of another
Python interpreter could change the meaning of that path. See https://docs.ansible.com/ansible-core/2.13/reference_appendices/interpreter_discovery.html
for more information.
ok: [3.71.179.254]

TASK [webservers : include_tasks] ************************************************************************************************************************
included: /mnt/c/Users/zadjad.rezai/Documents/repos/01_privat/infrastructure/ansible/roles/webservers/tasks/install_httpd.yml for 3.70.99.43, 3.71.179.254

TASK [webservers : Install http and php, etc.] ***********************************************************************************************************
ok: [3.71.179.254] => (item=httpd)
ok: [3.70.99.43] => (item=httpd)
ok: [3.71.179.254] => (item=php)
ok: [3.70.99.43] => (item=php)
ok: [3.71.179.254] => (item=php-mysql)
ok: [3.70.99.43] => (item=php-mysql)
ok: [3.71.179.254] => (item=libsemanage-python)
ok: [3.70.99.43] => (item=libsemanage-python)
ok: [3.71.179.254] => (item=libselinux-python)
ok: [3.70.99.43] => (item=libselinux-python)

TASK [webservers : Insert httpd.conf] ********************************************************************************************************************
ok: [3.71.179.254]
ok: [3.70.99.43]

TASK [webservers : Insert webserver virtualhost config] **************************************************************************************************
ok: [3.70.99.43] => (item=443)
ok: [3.71.179.254] => (item=443)
ok: [3.70.99.43] => (item=80)
ok: [3.71.179.254] => (item=80)

TASK [webservers : http service state] *******************************************************************************************************************
ok: [3.70.99.43]
ok: [3.71.179.254]

TASK [webservers : include_tasks] ************************************************************************************************************************
included: /mnt/c/Users/zadjad.rezai/Documents/repos/01_privat/infrastructure/ansible/roles/webservers/tasks/copy_code.yml for 3.70.99.43, 3.71.179.254
TASK [webservers : Insert simple index.php] **************************************************************************************************************
changed: [3.70.99.43]
changed: [3.71.179.254]

RUNNING HANDLER [webservers : restart httpd] *************************************************************************************************************
changed: [3.70.99.43]
changed: [3.71.179.254]

PLAY RECAP ***********************************************************************************************************************************************
3.70.99.43                 : ok=9    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
3.71.179.254               : ok=9    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```


[^1]: DevOps ist meiner Meinung nach eine Kultur, kein Job-Titel. Mit DevOps Engineer meine ich alle Positionen die aus der DevOps Kultur entspringen - dazu zählen auch z.B. Site Realiability Engineers, Systems Automation Engineers, etc.
