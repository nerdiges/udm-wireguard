# udm-wireguard
Manuelle Wiregurad Konfiguration auf der UDM Pro.

In der GUI der UDM Pro können mittlerweile wireguard VPNs eingerichtet weden. Allerdings sind hier eher nur Standardkonfigurationen möglich. Komplexere Site2Site-Setups mit speziellen Paramtern konnte ich über die GUI nicht einrichten. Stattdessen können mit udm-wireguard die entsprechenden Interfaces direkt und ohne GUI eingerichtet werden.

## Voraussetzungen
Unifi Dream Machine Pro mit UnifiOS Version 3.x. Erfolgreich getestet mit UnifiOS 3.2.7 und Network App 8.0.26.

## Funktionsweise
Das Script `udm-wireguard.sh` wird bei jedem Systemstart und anschließend alle 2 Minuten per systemd ausgeführt. 

Die eingerichteten Wireguard-Interfaces werden wie LAN-Interfaces behandelt und im Firewall-Regelwerk integriert. Die dabei erstellten Regeln werden bei Änderungen an der Netzwerkkonfiguration in der GUI regelmäßig wieder überschrieben. Damit die VPN-Verbindungen dauerhaft integriert werden, wird regelmäßig überprüft, ob die Firewall-Regeln noch passen. Neben dem systemd-Service wird daher auch ein systemd-Timer eingerichtet der das Script alle 2 Minuten neu startet und so die Regeln bei Bedarf wiederherstellt.

## Features
- Verbindungen /data/custom/wireguard/*.conf aufbauen
- Wireguard Interfaces im Firewall-Regelwerk wie LAN Interfaces einbinden 

## Disclaimer
Änderungen die dieses Script an der Konfiguration der UDM-Pro vornimmt, werden von Ubiquiti nicht offiziell unterstützt und können zu Fehlfunktionen oder Garantieverlust führen. Alle BAÄnderungenkup werden auf eigene Gefahr durchgeführt. Daher vor der Installation: Backup, Backup, Backup!!!

## Hinweis
**ACHTUNG:** Die Wireguard Interfaces werden vom Script wie normale LAN-Interfaces behandelt! In der Standardkonfiguration können mit dem VPN verbundene Geräte auf alle Systeme und Dienste uneingeschränkt zugreifen. Für eine angemessene Netzwerktrennung müssen daher in der GUI entsprechende Regeln eingefügt werden. Alternativ kann auch [udm-firewall](https://github.com/nerdiges/udm-firewall) für die NEtzwerktrennung genutzt werden.

## Installation
Nachdem eine Verbindung per SSH zur UDM/UDM Pro hergestellt wurde wird udm-wireguard folgendermaßen installiert:

**1. Download der Dateien**

```
mkdir -p /data/custom
dpkg -l git || apt install git
git clone https://github.com/nerdiges/udm-wireguard.git /data/custom/wireguard
chmod +x /data/custom/wireguard/udm-wireguard.sh
```

**2. Parameter im Script anpassen (optional)**

Im Script kann über eine Variablen das Verzeichnis hinterlegt werden, in dem die wireguard Config-Files abgelegt werden:

```
##############################################################################################
#
# Configuration
#

# directory with wireguard config files. All *.conf files in
# the directory will be considered as valid wireguard configs
conf_dir="/data/custom/wireguard/"

#
# No further changes should be necessary beyond this line.
#
######################################################################################
```

Dieser Parameter muss in der Regel nicht angepasst weden.

Die Konfiguration kann auch in der Datei udm-wireguard.conf gespeichert werden, die bei einem Update nicht überschrieben wird.

**3. Einrichten der systemd-Services**

Ist auf der UDM-Pro auch das Script [udm-firewall](https://github.com/nerdiges/udm-firewall) installiert, kann dieser Schritt übersprungen werden, da das Script automatisch von [udm-firewall](https://github.com/nerdiges/udm-firewall) mit ausgeführt wird. Damit das funktioniert müssen sowohl das [udm-firewall](https://github.com/nerdiges/udm-firewall) als auch udm-wireguard, wie in den jeweiligen README.md beschrieben installiert wurden. 

```
# Install udm-wireguard.service und timer definition file in /etc/systemd/system via:
ln -s /data/custom/wireguard/udm-wireguard.service /etc/systemd/system/udm-wireguard.service
ln -s /data/custom/wireguard/udm-wireguard.timer /etc/systemd/system/udm-wireguard.timer

# Reload systemd, enable and start the service and timer:
systemctl daemon-reload
systemctl enable udm-wireguard.service
systemctl start udm-wireguard.service
systemctl enable udm-wireguard.timer
systemctl start udm-wireguard.timer

# check status of service and timer
systemctl status udm-wireguard.timer udm-wireguard.service
```

**4. Wireguard Config-Files**

Damit wireguard Interfaces angelegt werden, müssen die entsprechenden wireguard Config-Files erstellt und im Verzeichnis `$conf_dir` (siehe oben Punkt 2) abgelegt werden.

Der Dateiname der Konfigurationsdateien ist dabei entscheidend für den Interface-Namen. Alles vor dem Suffix `.conf` wird als Interfacename genutzt. Die Datei `wg0.conf` erzeugt somit beispielsweise das Interface `wg0`.

## Update

Das Script kann mit folgenden Befehlen aktualisiert werden:
```
cd /data/custom/wireguard
git pull origin
```

## Known Issues
1. Der DNS-Parameter in wireguard Config-Files führt zu einer Fehlermeldung, da das Paket openresolv im UnifiOS per Default nicht installiert ist. 