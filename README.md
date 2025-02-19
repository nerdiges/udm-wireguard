# udm-wireguard
Manuelle Wiregurad Konfiguration auf der UDM Pro.

In der GUI der UDM Pro können mittlerweile wireguard VPNs eingerichtet weden. Allerdings sind hier eher nur Standardkonfigurationen möglich. Komplexere Site2Site-Setups mit speziellen Parametern können über die GUI nicht angepasst werden. Mit udm-wireguard können dieWireguard-Verbindgungen direkt und ohne GUI eingerichtet werden.

## Voraussetzungen

> [!IMPORTANT]
> <strong>UnifiOS 4.1.x</strong> und aktivierten <strong>$\color{Bittersweet}{Zone\ Based\ Firewall}$</strong> Regelwerk. Erfolgreich getestet mit UnifiOS 4.1.13 und Network App 9.0.114.

## Funktionsweise
Das Script `udm-wireguard.sh` wird bei jedem Systemstart und anschließend alle 2 Minuten per systemd ausgeführt. 

Ab Version 0.9.4 setzt das Script ein Zone Based Firewall Regelwerk vorraus. Die  Wireguard-Interfaces werden wie VPN-Verbindungen behandelt und in die VPN-Zone integriert. Die Integration der VPN-Interfaces wird bei Änderungen an der Netzwerkkonfiguration in der GUI regelmäßig wieder überschrieben. Damit die VPN-Verbindungen dauerhaft integriert werden, wird regelmäßig überprüft, ob die Firewall-Regeln noch passen. Neben dem systemd-Service wird daher auch ein systemd-Timer eingerichtet der das Script alle 2 Minuten neu startet und so die Regeln bei Bedarf wiederherstellt.

Da die VPN-Interfaces der VPN-Zone zugeordnet werden, müssen in der GUI z.B. unter Security > Traffic & Firewall Rules entsprechende Regeln eingerichtet werden.

## Features
- Verbindungen /data/custom/wireguard/*.conf aufbauen
- Wireguard Interfaces im Firewall-Regelwerk der UDM-Pro der VPN-Zone zuordnen 

## Disclaimer
Änderungen die dieses Script an der Konfiguration der UDM-Pro vornimmt, werden von Ubiquiti nicht offiziell unterstützt und können zu Fehlfunktionen oder Garantieverlust führen. Alle BAÄnderungenkup werden auf eigene Gefahr durchgeführt. Daher vor der Installation: Backup nicht vergessen!!!


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
conf_dir="/data/custom/wireguard/conf/"

#
# No further changes should be necessary beyond this line.
#
######################################################################################
```

Dieser Parameter muss in der Regel nicht angepasst weden. Soll der Pfad zu den Wireguard-Configs angepasst werden, so sollte der Wert in der Datei udm-wireguard.conf gespeichert werden, die bei einem Update nicht überschrieben wird.

**3. Einrichten der systemd-Services**

```
# Install udm-wireguard.service und timer definition file in /etc/systemd/system via:
ln -s /data/custom/wireguard/udm-wireguard.service /etc/systemd/system/udm-wireguard.service
ln -s /data/custom/wireguard/udm-wireguard.timer /etc/systemd/system/udm-wireguard.timer

# Reload systemd, enable and start the systemd timer:
systemctl daemon-reload
systemctl enable --now udm-wireguard.timer

# check status of service and timer
systemctl status udm-wireguard.timer 
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