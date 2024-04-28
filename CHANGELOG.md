# Change Log
All notable changes to this project will be documented in this file.
 
The format is based on [Keep a Changelog](http://keepachangelog.com/).
 
## [0.9.2] - 2024-04-28 

### Security

- Die VPN-Interfaces wurden teilweise nciht korrekt in das Firewall-Regelwerk der UDM-Pro integriert. Das 
  konnte dazu führen, dass VPN-Clients ungefiltert auf das interne Netzwerk zugreifen konnten.  


## [0.9.1] - 2024-04-28 

### Breaking Changes

- Die Wireguard-Konfigurations-Dateien wurden in einen Unterordner verschoben. Bei einem Update sollten
  daher bereits bestehende Konfigurationsdateien in das Verzeichnis conf verschoben werden. Alternativ kann 
  der Konfigurationsparameter $conf_dir in der Datei udm-wireguard.conf angepasst werden. 

### Added

-  n/a

### Changes

-  n/a

### Fixed
 
- Wenn es sich bei einem Config-File um die udm-wireguard.conf, so wird diese nicht mehr an wg-quick übergeben
  um Fehlermeldungen zu vermeiden.

## [0.9.0] - 2024-01-19
 
### Added

- Initiale Version mit grundelgender Funktionalität
