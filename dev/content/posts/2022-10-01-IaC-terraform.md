---
title: 'Projekt 2: Infrastructure as Code - Terraform'
author: Zadjad Rezai
type: post
date: 2022-10-11T10:00:00+00:00
draft: true
excerpt: 'IaC - ein häufig genutzter Begriff mit Beispielen erläutert. Am Beispiel von Terraform als IaC tool.'
url: /projekt/2/infra-as-code/terraform
featured_image: /img/infra-as-code/terraform.webp  # TODO add image
categories:
  - Projekt
  - Methodik
tags:
  - projekt
  - cloud

---

<!-- TODO <a href="http://example.com/" target="_blank">Hello, world!</a> -->

# Projekt 2: Infrastructure as Code - Terraform

Ein sehr häufig gelesener Begriff, der einige Realitäten in sich vereint.

Dank der globalen Bewegung in Richtung `DevOps`, Cloud & Verlässigkeit (`Realiability`) von Software Entwicklung und Software Teams, ist `X` als Code besonders wichtig geworden.

Mit Code kann man eine Situation objektiv & idempotent darstellen, sodass jeder neue Aufruf des Codes immer zum selben Ergebnis führt, egal wann oder wie oft man diesen Aufruf tätigt.

Der große Vorteil ist klar: Alles als Code bedeutet, alles ist versionierbar zum Beispiel via `git`. Änderungen sind nachvollziehbar, reviewbar, aufhaltbar, revertierbar, etc.
Also eine hervoragende Lösung für praktisch alle Bereiche.

Vor allem aber in der IT ist `X as Code` besonders gut angekommen - da existiert `Code` sowieso schon in allen Ecken & ein Software Team hat normalerweise keine Angst vor Code.

In diesem Post möchte ich erstmal ausschließlich über `Terraform` und `Ansible` sprechen. Zwei standard tools im Repertoire des DevOps Engineers[^1].

Als Beispiel erstellen möchte ich zwei `EC2` Maschinen in einer neuen `AWS`-Umgebung bauen, darin `apache` installieren und eine simple `index.php` anzeigen.

## Terraform

`Terraform` ist ein Cloud-Anbieter-übergreifendes Tool, welches erlaubt mit Code Infrastruktur anzulegen.

Man definiert seine Infrastruktur innerhalb von `.tf` Dateien in der `HCL` Sprache. Terraform hat eine sehr gute [Dokumentation](https://www.terraform.io/), [viele Beispiele und Tutorials](https://learn.hashicorp.com/).

`Terraform` ruft die `API` der jeweiligen `provider` auf, um die definierten Resourcen aufzurufen.

### AWS Umgebung

Zuerst brauchen wir AWS & einen Nutzer mit CLI Zugangsdaten, siehe [hier](https://docs.aws.amazon.com/cli/latest/userguide/cli-services-iam-create-creds.html).

Nun eure Variablen exportieren:

```bash
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

### Terraform Umgebung

Obligatorisch:

```bash
> terraform version       

Terraform v1.3.0
on linux_amd64
```

#### Ordner Struktur

So sieht die Struktur des Terraform Codes aus:

```bash
.
├── environment
│   └── production
│       ├── files
│       │   └── mykey.pub
│       ├── main.tf
│       ├── output.tf
│       ├── templates
│       │   └── hosts.tftpl
│       ├── terraform.tfstate          # -> Current state in the Cloud // ignore
│       └── terraform.tfstate.backup   # -> Current state in the Cloud // ignore
└── modules
    └── aws
        └── simple
            ├── ec2.tf
            ├── output.tf
            └── variables.tf
```

#### `environment` Ordner

```bash
.
└── environment
    └── production
        ├── files
        │   └── mykey.pub
        ├── main.tf
        ├── output.tf
        └── templates
            └── hosts.tftpl
```

Der erste Ordner `environments` erlaubt es uns mehrere Umgebungen wie `production`, `test`, `delivery`, etc. aufzubauen.
In diesem einfachen Beispiel existiert nur `production`, aber es ist beliebig ausbaubar.

Darin sind einige Unterordner die spezifisch für die `productions` Umgebung sind. Generell ist dieser Bereich relativ leer, da die echte Arbeit später erst in den Modulen passiert.

Module erlauben es uns `modularen` Code zu schreiben. So können wir in jeder Umgebung auf die selben Infrastruktur Resourcen zugreifen & ausschließlich einzelne Parameter anpassen - [`DRY`](https://de.wikipedia.org/wiki/Don%E2%80%99t_repeat_yourself).

Im `files` Ordner befinden sich statische Dateien; hier mein `public key`, um später über SSH auf die Maschinen zuzugreifen.

`templates` beinhaltet dynamische Dateien, welche sich über Variablen anpassen lassen. Hier ist nur `hosts.tftpl` enthalten - daraus entspäter später die `Ansible` hosts Datei mit den jeweiligen öffentlichen IP-Adressen der erzeugten `EC2` Maschien.

```bash
# environment/production/templates/hosts.tftpl

[all]
%{ for addr in web_ip_addrs ~}
${addr}
%{ endfor ~}

[webservers]
%{ for addr in web_ip_addrs ~}
${addr}
%{ endfor ~}
```

`tftpl` erinnert start an typische templates Sprachen wie `jinja2` oder `go` templating. `web_ip_addrs` kommt aus der `main.tf`

```bash
# environment/production/main.tf

# Do not hardcode credentials here
# Use environment variables or AWS CLI profile
provider "aws" {
  region = "eu-central-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.32"
    }
  }
}

module "simple" {
  source = "../../modules/aws/simple"

  environment             = "production"
  aws_nodes_instance_type = "t2.micro" # free tier
  key_pair = {
    key_name   = "mykey"
    public_key = file("${path.module}/files/mykey.pub")
  }
}

resource "local_file" "ansible_hosts" {
    content = templatefile(
               "${path.module}/templates/hosts.tftpl",
               {
                 web_ip_addrs = module.simple.instance_ip_addr_public
               }
              )
    filename = "${path.module}/../../../inventories/production/hosts"
}
```

Zu Beginn wird `terraform` mitgeteilt auf welchem Provider wir arbeiten wollen - hier `aws`, danach wird die spezifische Version angegeben.

Dann wird ein Modul genutzt - hier `simple`, welches wir später definieren. Es verlangt nach einigen Variablen (und gibt auch einige als `Output` zurück). Der Output wird später bei `local_file.ansible_hosts` genutzt, um die `ansible` `hosts` Datei zu schreiben.

Terraform erlaubt es uns Information anzuzeigen/weiterzugeben - diese kann man im `output.tf` definieren.

```bash
# environment/production/output.tf

output "instance_ip_addr" {
    value = module.simple.instance_ip_addr
}

output "instance_ip_addr_public" {
    value = module.simple.instance_ip_addr_public
}
```

Hier definieren wir den output des modules `simple` als output vom `environment/production`.

#### `modules`

Man kann so viele Module haben wie man möchte & diese auch aufteilen wie es am besten zum Projekt passt.

Für dieses simple Beispiel habe ich mich dazu entschieden einen `aws`-Ordner zu haben, der alle `aws`-Kompatiblen Module enthält. Darin ist aktuell nur das `simple` module, welches zwei `EC2` Maschinen startet und einige `SecurityGroups` sowie meinen `PublicKey` anlegt.

```bash
.
└── modules
    └── aws
        └── simple
            ├── ec2.tf
            ├── output.tf
            └── variables.tf
```

Das `simple` module wird im `main.tf` genutzt, wie oben schon gesehen:

```bash
...
module "simple" {
  source = "../../modules/aws/simple"

  # variables, defined in ../../modules/aws/simple/variables.tf
  environment             = "production"
  aws_nodes_instance_type = "t2.micro" # free tier
  key_pair = {
    key_name   = "mykey"
    public_key = file("${path.module}/files/mykey.pub")
  }
  ...
  ...
```

Die genutzten Variablen werden in `variables.tf` genutzt:

```bash
# modules/aws/simple/variables.tf

variable "aws_nodes_instance_type" {
    default = "t2.micro"
    type = string
}

variable "environment" {
    type = string
}

variable "key_pair" {
    type = object({
        key_name = string
        public_key = string
    })
}
```

##### ec2.tf

In `ec2.tf` passiert die gesammte Magie - es wird ein `AWS Launch Template angelegt`. Darin kann man eine generell gültige Instanzen Beschreibung schreiben & diese an verschiedene `aws_instance` (AWS Maschienen) resourcen übergeben.

Spezifische Parameter kann man direkt in der `aws_instance` überschreiben, wenn nötig. Hier habe ich die `ami` pro Instanz definiert, jedoch z.B. den `key_name` einmal im `aws_launch_template`. So hat jede Instanz immer meinen `public key`, während sich das grundlegende Maschinen Image unterscheiden darf.

`ec2.tf` können wir verbessern, indem wir z. B. [Autosclaing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) hinzufügen, aber das vielleicht für einen anderen Post.

```bash
resource "aws_launch_template" "default_webserver" {
  name = "default_webserver"
  instance_type = var.aws_nodes_instance_type
  network_interfaces {
    associate_public_ip_address = true
    security_groups = [
        aws_security_group.ssh_access.id,
        aws_security_group.allow_outgoing.id,
        aws_security_group.webserver_sg.id
    ]
  }
  key_name = aws_key_pair.web_keypair.id

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
  tag_specifications {
    resource_type = "instance"

    tags = {
      Environment = var.environment
    }
  } 
}

resource "aws_instance" "web" {
    launch_template {
        id = aws_launch_template.default_webserver.id
    }
    ami = "ami-05ff5eaef6149df49" # amazon/amzn2-ami-kernel-5.10-hvm-2.0.20220912.1-x86_64-gp2
    tags = {
        Name = "webserver"
    }
    count = 2
}

resource "aws_security_group" "webserver_sg" {
    name = "webserver_sg"
    description = "Allow everything our webserver needs"
}

resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.webserver_sg.id
}

resource "aws_security_group_rule" "allow_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.webserver_sg.id
}

resource "aws_security_group" "ssh_access" {
    name = "ssh_access"
    description = "Allow SSH"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "allow_outgoing" {
    name = "allow_outgoing"
    description = "Allow all outgoing"

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_key_pair" "web_keypair" {
    key_name = var.key_pair["key_name"]
    public_key = var.key_pair["public_key"]
}
```

#### Terraform Apply

```bash
> cd environment/production
> terraform apply -auto-appro

---- [REDACTED] ----

local_file.ansible_hosts: Creating...
local_file.ansible_hosts: Creation complete after 0s [id=2f66f99365e1b4c8999d9a1c17c93f0ca64cb893]

Apply complete! Resources: 9 added, 0 changed, 0 destroyed.

Outputs:

instance_ip_addr = [
  "172.31.16.242",
  "172.31.18.82",
]
instance_ip_addr_public = [
  "3.70.99.43",
  "3.71.179.254",
]
```

`environment/production/output.tf` zeigt und die privaten und öffentlichen IP-Adressen der erzeugten Maschinen.

```bash
local_file.ansible_hosts: Creating...
local_file.ansible_hosts: Creation complete after 0s [id=2f66f99365e1b4c8999d9a1c17c93f0ca64cb893]
```

Diese zwei Zeilen sagen aus, dass unsere `local_file.ansible_hosts` erzeugt wurde, damit muss jetzt eine `hosts` Datei in `inventories/production/hosts` existieren:

```bash
# ../../../inventories/production/hosts
[all]
3.70.99.43
3.71.179.254

[webservers]
3.70.99.43
3.71.179.254
```

Sieht gut aus.

`Terraform` erzeugt physische Resourcen, die wir jetzt in `Ansible` nutzen können, um konkrete Einstellungen zu tätigen.

Jetzt weiter zum [nächsten Post](/projekt/2/infra-as-code/ansible), um `httpd` und `php` zu installieren und eine simple Webseite zu erzeugen.


[^1]: DevOps ist meiner Meinung nach eine Kultur, kein Job-Titel. Mit DevOps Engineer meine ich alle Positionen die aus der DevOps Kultur entspringen - dazu zählen auch z.B. Site Realiability Engineers, Systems Automation Engineers, etc.