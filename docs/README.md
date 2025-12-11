# Documentation Technique
Ce dossier regroupe l'ensemble des ressources techniques nécessaires à la compréhension, au déploiement et à la sécurisation de l'infrastructure Novatech.

## Architecture & Réseau:

### infrastructure.md : 
Présente la topologie globale du réseau, expliquant la répartition entre la Maison Mère et le site de Production. Il détaille la segmentation en zones de sécurité (User, Trusted, DMZ), l'usage des Firewalls et VPNs, ainsi que l'infrastructure de virtualisation.

### adressage.md : 
Définit le plan d'adressage IPv4 (CIDR 10.0.0.0/8) appliqué à l'ensemble du parc. Il liste de manière exhaustive les plages IP allouées par site et par zone, ainsi que les VLANs spécifiques pour les métiers, l'IoT et l'administration.

## Normes & Choix Techniques:

### nommage.md : 
Etablit les conventions de nommage standardisées pour garantir la cohérence des identifiants machines et VLANs. Il inclut également un glossaire des acronymes utilisés pour les services et localisations.

### technologies.md : 
Justifie les décisions prises concernant le matériel et les logiciels. Il offre une analyse comparative des alternatives et aborde les contraintes budgétaires du projet.

## Sécurité & Flux:

### flux.md : 
Cartographie les matrices de communication autorisées au sein du réseau. Il précise les règles de filtrage inter-VLANs, les protocoles validés et les ports ouverts nécessaires au fonctionnement des services.

### attaques.md : 
Documente les résultats des tests d'intrusion effectués sur la couche 2 (Layer 2). Il démontre l'efficacité des mitigations mises en place (DAI, Port Security, BPDU Guard) face aux attaques courantes.

# Ordre de lecture recommandé

1. Vue d'ensemble

2. Vocabulaire et conventions

3. Structure logique IP

4. Outils utilisés

5. Règles de communication

6. Validation de la sécurité
