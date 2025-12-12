# Répartition des Tâches & Contributions

Ce document détaille les responsabilités individuelles et les contributions techniques de chaque membre du groupe pour le projet de sécurité.

## Justin
* **Architecture Réseau :** Conception majeure du schéma logique et contribution au schéma physique.
* **Firewalling :** Configuration et sécurisation du **Pare-feu Externe**.
* **Virtualisation :** Création et déploiement des images Docker pour les services réseaux.
* **Documentation :** Rédaction principale de la documentation écrite et des procédures du projet.

## Simon
* **Sécurité Offensive (Audit) :** Exécution des tests d'attaques et rédaction du rapport de sécurité/vulnérabilité.
* **Environnement de Production :**
    * Configuration complète du **pfSense (Prod)**.
    * Documentation détaillée des règles de filtrage appliquées.
* **Commutation (L2) :** Configuration de la sécurité de couche 2 dans la partie Production et supervision des normes de sécurité L2 globales.

## Nathan
* **Gestion de Version & Intégration :** Regroupement de toutes les versions du projet et gestion des conflits (fusion des configurations).
* **Firewalling :** Configuration et sécurisation du **Pare-feu Interne**, assurant le filtrage au cœur de l'infrastructure.
* **Routage (L3) :** Configuration du routage inter-VLAN et de l'interconnexion réseau.

## Arnaud
* **Architecture & Modélisation :**
    * Réalisation des **topologies logique et physique**.
    * Réalisation du **diagramme de flux** de données.
* **Commutation (L2) :** Mise en place de la sécurité **L2** spécifique pour la **User Zone** (Partie Mère).

## Tiago
* **Implémentation GNS3 :** Mise en place de la topologie globale sur GNS3.
* **Interconnexion (VPN) :** Configuration de la terminaison IPsec et des règles associées côté **Main** (Réseau Mère).
* **Commutation (L2) :** Configuration et sécurisation des switches de la partie **Main**.

## Mathéo
* **Implémentation GNS3 :** Mise en place de la topologie globale sur GNS3.
* **Interconnexion (VPN) :** Configuration de la terminaison IPsec et des règles associées côté **Prod** (Réseau Production).
* **Commutation (L2) :** Configuration et sécurisation des switches de la partie **Prod**.

---
*Note globale : La sécurité de couche 2 (Port Security, DHCP Snooping, mitigation VLAN Hopping) a été appliquée systématiquement sur l'ensemble des commutateurs du projet.*
