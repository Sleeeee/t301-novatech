# Description et justification de l'infrastructure

## Zone d'interconnexion

### Firewalls

Nous avons placé deux firewalls sur le site principal, et un seul sur le site de production pour un total de trois. Les firewalls externes (FWS-MI-01 et FWS-PI-01) ont pour but de filtrer le trafic venant et allant vers l'extérieur. Dans le cas de la maison mère, FWS-MI-01 redirige le trafic HTTPS vers les WAF (qui redirigeront vers le Reverse Proxy), et sert également de gateway aux VLANs de la DMZ. Les firewalls externes ont, comme énoncé précédemment, le rôle de diriger le trafic Internet des utilisateurs vers l'extérieur. Pour cela, nous avons mis en place un proxy en DMZ, qui servira de relai pour les requêtes web des clients, et ainsi effectuer une rupture protocolaire dans le flux.

Le firewall interne de la maison mère (FWS-MI-02) a pour but de protéger la Trusted Zone, et possède donc des règles strictes sur les flux entrant et sortant, toujours en se basant sur un principe de Zero Trust. Il effectue également le routage inter-VLAN de la Trusted Zone, en l'absence d'un SL3.

Nous estimons raisonnable cette quantité de firewalls pour une entreprise de taille moyenne comme Novatech, sans être overkill. Chaque site nécessite au minimum un firewall externe, ce qui semble évident pour réduire un maximum la surface d'attaque avec un minimum de moyens. Le firewall interne de la maison mère pourrait être enlevé, et ses règles déplacées sur FWS-MI-01, cela réduirait les coûts matériels. Cependant, nous jugeons qu'il nous apporte une couche d'abstraction supplémentaire, en maintenant une configuration lisible et compréhensible par les administrateurs (Keep it Stupid Simple - KISS), en évitant à un seul firewall de devoir faire tout le boulot car FWS-MI-02 s'occupe lui-même des VLANs en Trusted.

### VPN site-to-site

En raison de la présence de deux sites distincts (dont un beaucoup plus important que l'autre), nous avions besoin d'établir une communication entre les deux. Par le biais de nos firewalls, nous avons mis en place un VPN site-to-site avec un chiffrement de couche 3 par IPSec. Ce tunnel nous permet donc de communiquer cross-sites par Internet en disposant de confidentialité sur l'ensemble de notre trafic, tout en conservant les adresses IP privées, permettant d'identifier fiablement l'interlocateur à travers les sites. La plupart des machines du site de production sont sensées pouvoir atteindre le site mère, notamment les services hébergés en Trusted, comme l'ERP par exemple. L'inverse n'est pas toujours vrai, seulement certaines machines privilégiées devraient pouvoir accéder du site mère au site de production.

Nous avons opté pour pratiquer le full tunnelling pour le site de production, car ce dernier ne dispose pas d'infrastructures suffisantes pour pratiquer une rupture protocolaire (proxy). Même si cela est désavantageux pour la charge de l'infrastructure, nous routons l'intégralité du trafic du site de production à travers le VPN IPSec afin d'assurer la sécurité de notre site de production.

Nous pourrious également justifier la location d'une ligne dédiée entre les deux sites, qui nullifierait l'intérêt du VPN. Au niveau qualité et performance, ce serait la meilleure option envisageable, mais dans le cadre d'une entreprise de l'envergure de Novatech, le budget serait complètement dépassé par le coût de cette ligne, ce qui explique notre préférence pour un VPN, bien que moins performant.

### VPN client-to-site

Certains types d'utilisateurs (certaines VLANs) ont besoin d'un accès distant à certains services. Pour cela, nous avons implémenté un VPN client-to-site avec OpenVPN sur le firewall externe de la maison mère. Ce VPN nous offre également la confidentialité des données échangées. Seuls les postes nécessaires disposent d'un accès OpenVPN (voir adressage.md) : ADMIN, IT, RD et MARKET.

## User Zone

### Maison mère

La User Zone du site mère comprend deux L3 et six L2. Les Layer 3 servent de gateway aux VLANs et effectuent le routage inter-VLAN. Nous aurions pu enlever ces L3 et laisser la charge de travail des VLANs au firewall externe, mais la quantité importante d'utilisateurs nous a amené vers cette topologie à deux switches L3. Nous en avons placé deux, ce qui impacte négativement le budget, mais nous avons jugé qu'un simple L3 serait un SPOF trop important pour être laissé seul, malgré le coût.

Nous retrouvons un nombre important de VLANs dans la User Zone. Nous pouvons faire la distinction entre les VLANs "métiers", qui reprennent les machines des différents employés, ainsi que des VLANs "IOT", qui reprennent les appareils tels que des caméras, alarmes, imprimantes. Le routage inter-VLAN est effectué par les L3, afin de maintenir le trafic interne indépendant du firewall, pour éviter de le surcharger.

### Site de production

Le site distant ne possède que deux SL2 en User Zone. Étant donné le peu d'employés présents sur ce site, et la quantité limitée de trafic qui doit être écoulé, un L3 serait un gros investissement qui s'avérerait être peu rentable. C'est pourquoi nous nous contentons de simples Layer 2, et le firewall a pour rôle d'effectuer le routage inter-VLAN. Sans plus de détails concernant le nombre de postes informatisés sur site, nous pensons que deux switches avec chacun 48 ports suffiront, mais cela pourra bien évidemment être amené à changer si l'on tombe à court d'interfaces.

## Datacenter

### Proxmox

L'ensemble des services présents dans le datacenter sont en réalité virtualisés dans des hyperviseurs faisant tourner l'environnement virtuel Proxmox. Comme indiqué sur la topologie physique de notre datacenter, ces hyperviseurs forment des clusters, un pour la DMZ, et un pour la Trusted (pour séparer physiquement les données sensibles des données publiques).

### Proxy

Pour effectuer une rupture protocolaire du trafic internet sortant, nous avons installé un proxy. Ce dernier se trouve dans la DMZ car l'extérieur peut lui répondre directement. Toutes les machines métiers sont autorisées à le contacter sur son port de travail. Nous estimons que ce service est indispensable, et étant donné qu'il est virtualisé, que son coût en termes de ressources est minime par rapport à son utilité. Il n'est pas envisageable de le supprimer.

### Reverse Proxy

Le Reverse Proxy a pour objectif de rediriger les connexions externes vers les applications web. Il permet également d'assurer une rupture protocolaire entre l'extérieur et les services et les serveurs, et donc de réduire la surface d'attaque. Idem que pour le Forward Proxy, il n'est pas envisageable de le supprimer.

### WAF

Avant de tomber sur le Reverse Proxy, les requêtes web sont examinées par un Web Application Firewall. Ce dernier a pour objectif de vérifier la légitimité des requêtes et de les forwarder au Reverse Proxy, ainsi que de bloquer celles qu'il estime dangereuses pour les applications web.

### Active Directory

Nos machines clientes sont orchestrées par Active Directory. Nous possédons deux Domain Controllers dans la Trusted Zone, qui servent notamment de serveur DHCP, DNS, NTP, et permettent notamment l'authentification des utilisateurs via Kerberos et la récupération des Group Policies via SMB.

### Jump servers

Afin de restreindre au maximum les accès des administrateurs réseau lorsqu'ils effectuent leurs tâches quotidiennes, nous avons mis en place des machines rebond privilégiées, sur lesquelles les administrateurs devront s'authentifier (SSH ou RDP) afin d'effectuer des manipulations nécessitant des privilèges. Ces machines seraient évidemment très dangereuses si elles venaient à être compromises, ce pourquoi nous obligeons une seconde authentification pour éviter les accès non autorisés.

### Machines virtuelles R&D

L'équipe de Recherche et Développement a besoin d'accéder à des machines virtuelles et environnement de tests sensibles. Nous avons pris la décision de virtualiser ces machines dans la Trusted Zone, et d'y restreindre un maximum les accès (R&D et JMP). Les employés de R&D peuvent se connecter aux machines en SSH. Nous avons également pensé à RDP, mais sans contexte additionnel, avons préféré éviter d'autoriser un port potentiellement non utilisé. Ils pourront ouvrir un ticket s'ils ne sont pas contents.

### NVR

Pour permettre aux caméras d'envoyer leurs données, nous avons installé un Network Video Recorder dans la Trusted Zone. Ce dernier permet de traiter les images envoyées par les caméras en temps réel grâce au protocole RSTP.
