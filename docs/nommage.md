# Conventions de nommages et index

## Nommage

### Machines

Tous les serveurs et équipements réseaux possèdent un nom suivant le format SSS-LZ-NN, où :
- SSS est un acronyme correspondant au service fourni par la machine, de taille fixe de 3 lettres
- L est la localisation du site, de taille fixe d'une lettre
- Z est la zone logique dans laquelle se trouve la machine, de taille fixe d'une lettre
- NN est un nombre correspondant à l'identifiant de série de la machine, de taille fixe de 2 nombres

Nous pourrons par exemple retrouver RPS-MD-01, correspondant à un Reverse Proxy Service, localisé dans la maison Mère, dans la zone Démilitarisée, premier de ce type.

### VLANs

Les VLANs sont toutes nommées UUU-LZ, où :
- UUU est la dénomination de l'utilisation de la VLAN (ou bien le type d'utilisateurs qui y auront accès dans le cadre de la User Zone), de taille variable
- L est la localisation du site, de taille fixe d'une lettre
- Z est la zone logique dans laquelle est située la VLAN, de taille fixe d'une lettre

## Index

### Localisations

- M : maison Mère
- P : site de Production

### Zones

- D : zone Démilitarisée, ou DMZ
- I : zone d'Interconnexion avec l'extérieur
- T : zone Trusted
- U : zone User

### Services
- API : APIs/backends du site d'ecommerce
- BKP : machine de BacKuP
- DCS : Domain Controller Server
- DNS : Domain Name Server
- ERP : Enterprise Resource Planning
- FPS : Forward Proxy Server
- FWS : FireWall Server
- HYP : HYPerviseur (Proxmox)
- ISP : Internet Service Provider
- JMP : serveur JuMP (ou rebond)
- MON : serveur de MONitoring
- RPS : Reverse Proxy Server
- SL2 : Switch Layer 2
- SL3 : Switch Layer 3
- WBE : service WeB du site d'E-commerce
- WBV : service WeB du site Vitrine
- WFE : Web application Firewall (WAF) du site d'E-commerce
- WFV : Web application Firewall (WAF) du site Vitrine
