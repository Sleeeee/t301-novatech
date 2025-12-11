# Décisions liées à l'adressage IP des machines

Voici les conventions suivies qui ont permi de réaliser l'adressage IPv4 de l'ensemble des machines des sites de Novatech. IPv6 n'est pas supporté dans cette infrastructure et est désactivé partout où cela est possible.

Nous employons la plage d'adresses 10.0.0.0/8 car elle nous offre un maximum d'adresses utilisables. Bien que nous n'ayons pas un nombre considérable de machines, cela nous permet de segmenter davantage le réseau en plages logiques, d'employer majoritairement des /24 pour simplifier l'usabilité et la compréhension des différentes sections.

## Séparation en sites

Chaque site dispose d'une réseau en /12. On peut donc adresser 16 /16 à l'intérieur, ce qui nous permet de disposer de plusieurs grosses zones distinctes dans chaque site. Pour l'instant, seuls deux sites existent, mais nous pourrions utiliser le même adressage jusqu'à la création de 16 sites pour remplir la plage 10.0.0.0/8 (si l'on souhaite employer le même adressage interne). La maison mère a naturellement récupéré la première plage en raison de son importance en tant que siège de l'entreprise.

Voici les plages actuellement attribuées : 
- Maison mère (M) : 10.0.0.0/12 (10.0.0.0 - 10.15.255.255)
- Site de production (P) : 10.16.0.0/12 (10.16.0.0 - 10.31.255.255)

## Séparation en zones

Les différents sites peuvent également être amenés à être séparés en zones. Afin d'afficher au mieux cette séparation, nous avons attribué un /16 à chacune des zones. Cela nous permet de créer jusqu'à 16 zones par site (ce qui est peu probable, mais il est toujours intéressant de laisser de la marge plutôt que de devoir tout recommencer). Chaque zone dispose d'une plage suffisamment large pour attribuer 256 /24. Dans la mesure du possible, chaque zone récupérera un sous-réseau dont le troisième byte est équivalent à celui de ses homologues sur les autres sites. Comme nos conventions le veulent, nous attribuons la dernière plage disponible aux systèmes d'interconnexion. Nous avons également mis en place un VPN client-to-site, reliant à la maison mère, permettant à une partie des employés de travailler à distance.

Voici les plages actuellement attribuées : 
- M - User Zone (U) : 10.0.0.0/16
- M - Trusted Zone (T) : 10.1.0.0/16
- M - DMZ (D) : 10.2.0.0/16
- M - VPN : 10.8.0.0/16
- M - Interconnexion (I) : 10.15.0.0/16
- P - User Zone (U) : 10.16.0.0/16
- P - Interconnexion (I) : 10.31.0.0/16

## Séparation en VLANs / sous-réseaux

Chaque zone doit bien évidemment comporter plusieurs VLANs ou sous-réseaux (selon le type de zone). Par souci de simplicité et de facilité de compréhension, une portion majoritaire des sous-réseaux sont des /24, permettant 256 hôtes, ce qui peut paraitre overkill sur le plan technique, mais justifié par l'aisance d'adressage, et permis par le /16 de la zone, autorisant jusqu'à 256 VLANs ou sous-réseaux, ce qui sera d'autant plus simple à mettre à l'échelle si nécessaire. Pour les conventions de nommage des VLANs, voir le fichier nommage.md.

### Maison mère - Interconnexion

La plage étant énorme par rapport à nos besoins en termes d'adresses, nous avons suivi une pratique constante d'employer les adresses de fin de plage pour les sous-réseaux d'interconnexion de routeurs/firewalls au sein de notre réseau. De ce fait, nous retrouvons les plages suivantes : 

- ISP vers Firewall externe : 10.15.255.252/30. Nous avons attribué un /30 car nous n'avons pas besoin de plus de deux adresses dans ce réseau, et que si cela venait à changer, la charge de travail demandée serait minime.
- Firewall externe vers Firewall interne : 10.15.254.252/30. Même raison pour le /30. Si besoin, nous aurions pu également utiliser la plage 10.15.255.248/30 pour éviter de mobiliser un /24 supplémentaire. Étant donné la faible probabilité d'atteindre les 256 sous-réseaux au sein de 10.15.0.0/16, nous estimons que le risque est minime, et que la segmentation logique est justifiée, car cela nous permet de donner des adresses constantes sur les différentes machines (par exemple, peu importe son sous-réseau, le firewall externe obtient toujours l'adresse .254).
- Firewall externe vers couche de Distribution (switches L3) : 10.15.253/24. Même justification, il sera beaucoup plus simple de maintenir une User Zone où les L3 et le firewall dispose d'une convention d'adressage uniforme.

### Maison mère - User Zone

La User Zone contient un nombre assez important de VLANs. Nous comptions initialement uniquement utiliser des multiples de 10 afin de laisser de la marge (pour des aménagements futurs). Cependant, si la plage 10.0.0.0/16 dispose des VLANs de 0 à 99, 10.1.0.0/16 dispose de 100 à 199, etc, nous n'aurions la possibilité que d'avoir 10 VLANs prévues dans la User Zone pour conserver une convention constante. De ce fait, nous avons préféré employer des multiples de 4, et donc de pouvoir attribuer initialement 25 VLANs de masque /24 sans créer d'incohérences. Pourquoi 4, nous avons préféré garder un adressage constant qui peut facilement s'aligner avec le format binaire des adresses avec une puissance de 2 (même si les ID de VLAN n'ont pas de réelle signification binaire). Les VLANs destinés aux réelles machines des employés démarrent de 4 en augmentant, tandis que les VLANs des appareils de type IOT commencent à 88 en diminuant. Nous avons également des VLANs spéciales : les invités (GUEST), la VLAN de gestion des équipements réseaux (MGM-MU), et la VLAN native que nous avons déplacé en 99. Voici l'adressage attribué à la User Zone de la maison mère : 

- ADMIN-MU - VLAN 4 : 10.0.4.0/24 (gestion des équipements réseau et services internes)
- IT-MU - VLAN 8 : 10.0.8.0/24 (service informatique ne demandant pas d'accès aux équipements réseau et services internes)
- RD-MU - VLAN 12 : 10.0.12.0/24 (recherche et développement)
- MARKET-MU - VLAN 16 : 10.0.16.0/24
- ALARME-MU - VLAN 80 : 10.0.80.0/24
- CAMERA-MU - VLAN 84 : 10.0.84.0/24
- PRINTER-MU - VLAN 88 : 10.0.88.0/24
- GUEST - VLAN 92 : 10.0.92.0/24
- MGM-MU - VLAN 96 : 10.0.96.0/24 (VLAN de gestion des équipements réseau)
- VLAN 99 natif : 10.0.99.0/24

- Les VLANs métiers (ADMIN, IT, RD, MARKET, GUEST) récupèrent toutes leurs adresses par DHCP (range entre 100 et 200).
- Les VLANs IOT (ALARME, CAMERA, PRINTER) se voient assigner des adresses IPv4 statiques.
- La LAN de management (MGM) est configurée avec des adresses IPv4 statiques.

### Maison mère - Trusted Zone

La Trusted Zone contient également plusieurs VLANs, mais un nombre moins important que pour les User Zones. La VLAN de management a été assignée avec un tag reflétant son homologue en User Zone. Voici les différents réseaux attribués :

- JMP-MT - VLAN 104 : 10.1.4.0/24 (machines rebond pour l'accès aux interfaces de gestion des équipements réseau et services internes)
- DC-MT - VLAN 108 : 10.1.8.0/24
- APP-MT - VLAN 112 : 10.1.12.0/24
- BACKUP-MT - VLAN 116 : 10.1.16.0/24
- NVR-MT - VLAN 120 : 10.1.20.0/24
- DB_ECOM-MT - VLAN 124 : 10.1.24.0/24
- DB_ERP-MT - VLAN 128 : 10.1.28.0/24
- DB_CRM-MT - VLAN 132 : 10.1.32.0/24
- RDS-MT - VLAN 136 : 10.1.36.0/24
- MGM-MT - VLAN 196 : 10.1.96.0/24 (VLAN de gestion des équipements réseau et services internes, contenant les hyperviseurs Proxmox et les services de monitoring)

Notons que la Trusted Zone contient des serveurs, et ces derniers sont parfois (souvents) redondants. De ce fait, nous avons adopté la convention de nommer les machines d'une VLAN en réservant, de manière officieuse, 16 adresses par type de service présent. Au sein d'une même VLAN, on pourra donc retrouver les machines SVU-TU-01 (.1), SVU-TU-02 (.2), SVU-TU-03 (.3), SVD-TU-03 (.16), SVT-TU-01 (.32), etc.

### Maison mère - DMZ

La DMZ se base sur les mêmes principes d'adressage que pour la Trusted Zone. Voici les VLANs actuellement attribuées : 

- REVERSE-MD - VLAN 204 : 10.2.4.0/24 (reverse proxies et WAF)
- FORWARD-MD - VLAN 208 : 10.2.8.0/24
- DNS-MD - VLAN 212 : 10.2.12.0/24 (DNS public uniquement)
- WEB-MD - VLAN 216 : 10.2.16.0/24 (serveurs web uniquement, pas d'API/DB)

### Maison mère - VPN client-to-site

Les employés travaillant à distance grâce au VPN client-to-site disposent d'accès similaires à leur VLAN habituelle, d'où le troisième byte identique :

- ADMIN-MV : 10.8.4.0/24
- IT-MV : 10.8.8.0/24
- RD-MV : 10.8.12.0/24
- MARKET-MV : 10.8.16.0/24

### Site de production - Interconnexion

Cette zone d'interconnexion a suivi les mêmes pratiques que pour la maison mère. Voici l'attribution des différents sous-réseaux : 

- ISP vers Firewall externe : 10.31.0.252/30

### Site de production - User Zone

La User Zone du second site a suivi la même convention que la maison mère, c'est-à-dire les VLANs des postes des employés commençant au début et en augmentant, et les machines "IOT" commençant à la fin de la plage en descendant. Dans la mesure du possible, les VLANs représentées sur les deux sites se voient attribués le même troisième byte. Nous avons préfixé les ID de VLAN avec le second byte correspondant à la User Zone du site de production (16xx). Voici l'adressage attribué :

- ADMIN-PU - VLAN 1604 : 10.16.4.0/24 (idem que pour la maison mère)
- IT-PU - VLAN 1608 : 10.16.8.0/24 (idem)
- RD-MU - VLAN 1612 : 10.16.12.0/24 (idem)
- PROD-PU - VLAN 1620 : 10.16.20.0/24
- LOGI-PU - VLAN 1624 : 10.16.24.0/24
- ASM-PU - VLAN 1676 : 10.16.76.0/24 (chaines d'assemblage)
- ALARME-PU - VLAN 1680 : 10.16.80.0/24
- CAMERA-PU - VLAN 1684 : 10.16.84.0/24
- PRINTER-PU - VLAN 1688 : 10.16.88.0/24
- MGM-PU - VLAN 1696 : 10.16.96.0/24
- VLAN 1699 natif : 10.16.99.0/24

- Les VLANs métiers (ADMIN, IT, RD, PROD, LOGI, GUEST) récupèrent toutes leurs adresses par DHCP (range entre 100 et 200).
- Les VLANs IOT (ASM, ALARME, CAMERA, PRINTER) se voient assigner des adresses IPv4 statiques.
- La LAN de management (MGM) est configurée avec des adresses statiques.
