# Choix technologiques

Ici se trouve une liste des décisions technologiques prises pour chaque service, ainsi qu'une justification lorsque c'est nécessaire. Une contrainte notable, l'infrastructure de Novatech est intégralement localisée on-premise, principalement pour des fins pédagogiques.

Dans plusieurs cas, nous avons exploré différentes alternatives. Notre objectif ici n'est pas de donner un avis biaisé, mais plutôt d'énoncer les avantages et inconvénients de telles solutions.

Les prix ont été recensés en date du 07/12/2025 aux URLs fournies. Il est possible qu'ils ait subi des changements entre temps. Le budget étant approximatif, c'est un risque négligeable pour notre analyse.

## Équipements réseaux

### Firewalls

Pour des raisons budgétaires (et officieusement, éducatives), nous avons choisi de faire tourner PfSense sur tous nos firewalls. C'est un software robuste, qui permet également à l'entreprise de limiter ses coûts sans en faire souffrir la sécurité de ses atouts. 

Une option matérielle abordable est le [Netgate 6100 Base](https://shop.netgate.com/products/6100-base-pfsense), achetable au prix de 729€. Ce firewall physique comporte suffisamment d'interfaces (6) pour nos besoins dans la topologie actuelle (5 au plus). Il est également notable qu'il est manufacturé par Netgate, la société derrière PfSense, ce qui nous fournit une compatibilité assurée avec le software.

Alternatives :
- Nous avons pensé à multiplier les vendeurs de firewalls, pour se protéger contre l'impact de 0-days futures affectant PfSense. Par exemple, les firewalls Fortinet ont été une option que nous avons exploré. Bien que plus robuste, le budget aurait souffert énormément, par l'achat d'un device beaucoup plus cher, comme par exemple le [FortiGate 100F Firewall](https://www.firewallshop.nl/p/fortinet-fortigate-100f-firewall-met-fortinet-24x7-utp-bundle-3-jaar-91726), qui coute proche des 4000€ avec un an de license comprise.
- Nous pouvons également virtualiser les firewalls, et anéantir les coûts liés au hardware. Cette pratique vient cependant avec des risques, tels qu'un manque d'isolation physique (une faille liée à notre hyperviseur est capable de faire tomber nos firewalls).

### L2 Switches

Dans le cadre de cette PoC, nous avons virtualisé des switches Cisco. En regardant sur le marché, nous avons trouvé des [Cisco Catalyst 1000](https://www.tonitrus.com/C1000-48T-4X-L_8) comportant 48 ports, pour le prix de 922.5€ (reconditionné) ou 1325.5€ (neuf). Bien que peu abordable, le matériel Cisco ainsi que son IOS nous offre une solution uniforme et robuste pour l'ensemble de nos réseaux.

Alternatives : 
- Un équivalent provenant d'Ubiquiti est le [UniFi Switch 48 PoE](https://wifimedia.eu/fr/products/unifi-switch-48-poe), au prix de 564.9€. D'autres alternatives sont disponibles à prix réduits, impactant positivement le budget de manière non négligeable. Il est cependant important de noter que nous perdons certaines features avancées de Cisco, ainsi qu'une scalabilité assurée. Pour une entreprise de petite taille (~200 employés), ces solutions restent évidemment une option solide.

### L3 Switches

Les commutateurs de couche 3 peuvent souvent atteindre des prix exorbitants. Ici, nous nous concentrons sur des modèles relativement bon marché, d'une part car nous nous occupons d'une PME, et d'autre part car la User Zone ne constitue pas notre source d'atouts la plus précieuse. Nous avons donc estimé qu'il est envisageable de limiter les coûts de ce côté. Un appareil qui a attiré notre attention est le [Cisco SG500X](https://it-market.com/en/switches/other-switches/cisco/sg500x-24mpp-k9-na/1265278-E2-898990), que nous avons trouvé disponible au prix de 505.75€ (reconditionné), ou à 2201.5€ (neuf).

Alternatives :
- Nous nous sommes intéressés au haut-de-gamme de Cisco, notamment au modèle Cisco Catalyst C9500, que nous avons trouvé au prix de 7918.39€ ([reconditionné](https://intelligentservers.co.uk/cisco-catalyst-9500-48y4c-e-c9500-48y4c-e-switch)), ou 21724.52€ ([neuf](https://www.routershop.nl/p/cisco-catalyst-9500-48-port-x-1-10-25g-4-port-40-100g-advantage-75083)). Si nous avons l'ambition de passer à l'échelle de manière significative, ces appareils peuvent nous fournir une robustesse et qualité supérieures. Le prix sera cependant l'argument clé, car il faudrait multiplier par 10 notre budget L3.
- Une autre option serait de changer de vendeur, par exemple le [QSFPTEK S5300](https://www.qsfptek.com/product/100492.html), trouvé à 1010.6€ (neuf). Cette alternative nous permet de réduire modérément les coûts du budget L3, mais nous perdons l'uniformité que nous offre Cisco, ce qui est très important à considérer avant de prendre une telle décision.

## Proxies

### Forward Proxy

### Reverse Proxy

## Web

### Bases de données
La solution que nous avons choisi pour nos bases de données dans cette PoC est PostgreSQL, qui offre un environnement robuste gratuit et adapté pour notre site d'e-commerce. Le port correspondant est le 5432, important à noter pour nos règles de firewall.

### Backend
Notre backend sera hosté avec Django. Bien que l'objectif n'est pas de comparer les technologies web, nous gardons en tête qu'il opère sur le port 8000.

### Serveur web
Nous emploierons Nginx pour servir les fichiers de nos deux sites web, le site vitrine et le site d'e-commerce. Nous bloquerons le port 80 afin de réduire la surface d'attaque, et de forcer HTTPS de manière dure. Notons également que Nginx ne joue pas le rôle de reverse proxy, mais bien de serveur web. Nous utilisons un reverse proxy dédié pour augmenter la robustesse de notre système.

### WAF
