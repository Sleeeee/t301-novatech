# Documentation des Règles Firewall pfSense - NovaTech Production

**Date de création :** 11 décembre 2025  
**Version :** 1.0  
**Environnement :** Production - Site PU (Production Unit)  
**Firewall :** pfSense

---

## Vue d'ensemble de l'infrastructure

### Objectifs de sécurité
- Segmentation réseau stricte par fonction métier
- Principe du moindre privilège (Least Privilege)
- Isolation des réseaux critiques (SCADA, Caméras, Alarmes)
- Protection contre les menaces Layer 2 (DHCP Snooping, DAI)
- Contrôle d'accès granulaire entre VLANs

### Équipements
- **Firewall :** pfSense (passerelle et routage inter-VLAN)
- **Switches L2 :** 
  - SL2-PU-01 (10.16.96.219)
  - SL2-PU-02 (10.16.96.218)

---

## Architecture réseau

```
Internet
   |
[pfSense Firewall]
   |
   +--- VLAN 1604 (ADMIN-PU)      - 10.16.4.0/24
   +--- VLAN 1608 (IT-PU)         - 10.16.8.0/24
   +--- VLAN 1612 (RD-PU)         - 10.16.12.0/24
   +--- VLAN 1620 (PROD-PU)       - 10.16.20.0/24
   +--- VLAN 1624 (LOGI-PU)       - 10.16.24.0/24
   +--- VLAN 1676 (ASM-PU)        - 10.16.76.0/24
   +--- VLAN 1680 (ALARMES-PU)    - 10.16.80.0/24
   +--- VLAN 1684 (CAMERAS-PU)    - 10.16.84.0/24
   +--- VLAN 1688 (PRINTER-PU)    - 10.16.88.0/24
   +--- VLAN 1696 (MGM-PU)        - 10.16.96.0/24
```

---

## VLANs configurés

| VLAN ID | Nom           | Réseau IP       | Passerelle   | Usage                          |
|---------|---------------|-----------------|--------------|--------------------------------|
| 1604    | ADMIN-PU      | 10.16.4.0/24    | 10.16.4.254  | Administration                 |
| 1608    | IT-PU         | 10.16.8.0/24    | 10.16.8.254  | Équipe IT                      |
| 1612    | RD-PU         | 10.16.12.0/24   | 10.16.12.254 | Recherche & Développement      |
| 1620    | PROD-PU       | 10.16.20.0/24   | 10.16.20.254 | Production (SCADA/ICS)         |
| 1624    | LOGI-PU       | 10.16.24.0/24   | 10.16.24.254 | Logistique                     |
| 1676    | ASM-PU        | 10.16.76.0/24   | 10.16.76.254 | Assemblage                     |
| 1680    | ALARMES-PU    | 10.16.80.0/24   | 10.16.80.254 | Systèmes d'alarme              |
| 1684    | CAMERAS-PU    | 10.16.84.0/24   | 10.16.84.254 | Vidéosurveillance              |
| 1688    | PRINTER-PU    | 10.16.88.0/24   | 10.16.88.254 | Imprimantes                    |
| 1696    | MGM-PU        | 10.16.96.0/24   | 10.16.96.254 | Management (switches, équip.)  |

---

## Politique de sécurité globale

### Principe de base : **DENY ALL par défaut**

Chaque VLAN dispose de :
1. **Règles explicites d'autorisation** pour les flux nécessaires
2. **Règle de blocage finale** qui log tous les rejets
3. **Pas de règle "allow any"** sauf cas exceptionnels (ADMIN, IT)

### Catégories de VLANs

#### VLANs Administratifs
- **ADMIN-PU (1604)** : Accès complet
- **IT-PU (1608)** : Accès complet

#### VLANs Métiers
- **RD-PU (1612)** : Accès IT, Imprimantes, Internet
- **LOGI-PU (1624)** : Accès Imprimantes, Assemblage, Internet
- **ASM-PU (1676)** : Accès Production, Imprimantes, Internet

#### VLANs Critiques
- **PROD-PU (1620)** : Isolation - IT uniquement
- **ALARMES-PU (1680)** : Isolation - IT uniquement
- **CAMERAS-PU (1684)** : Isolation - IT uniquement

#### VLANs Services
- **PRINTER-PU (1688)** : Mode passif
- **MGM-PU (1696)** : Management

---

## Règles firewall par VLAN

### VLAN 1604 - ADMIN-PU

#### Objets / Alias utilisés
* **RFC1918_Private** (Network) : `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`

| ID | Ordre | Action | Protocole | Source | Destination | Port | Description |
|:---|:---:|:---:|:---:|:---|:---|:---|:---|
| **1** | 1 | `PASS` | TCP/UDP | `ADMIN-PU subnets` | **! RFC1918_Private** | * (Any) | Accès Internet |
| **2** | 2 | `BLOCK` | Any | * | * | * | Règle de Clôture |

---

### VLAN 1608 - IT-PU

#### Objets / Alias utilisés
* **RFC1918_Private** (Network) : `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`

| ID | Ordre | Action | Protocole | Source | Destination | Port | Description |
|:---|:---:|:---:|:---:|:---|:---|:---|:---|
| **1** | 1 | `PASS` | TCP/UDP | `IT-PU subnets` | **! RFC1918_Private** | * (Any) | Accès Internet |
| **2** | 2 | `BLOCK` | Any | * | * | * | Règle de Clôture |

---

### VLAN 1612 - RD-PU

#### Objets / Alias utilisés
* **RFC1918_Private** (Network) : `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`

| ID | Ordre | Action | Protocole | Source | Destination | Port | Description |
|:---|:---:|:---:|:---:|:---|:---|:---|:---|
| **1** | 1 | `PASS` | TCP/UDP | `RD-PU subnets` | `IT-PU subnets` | * (Any) | Accès support IT |
| **2** | 2 | `PASS` | TCP | `RD-PU subnets` | `PRINTER-PU subnets` | 9100, 515 | Impression |
| **3** | 3 | `PASS` | TCP/UDP | `RD-PU subnets` | **! RFC1918_Private** | * (Any) | Accès Internet |
| **4** | 4 | `BLOCK` | Any | * | * | * | Règle de Clôture |

---

### VLAN 1620 - PROD-PU

| ID | Ordre | Action | Protocole | Source | Destination | Port | Description |
|:---|:---:|:---:|:---:|:---|:---|:---|:---|
| **1** | 1 | `PASS` | TCP/UDP | `PROD-PU subnets` | `IT-PU subnets` | * (Any) | Support IT uniquement |
| **2** | 2 | `BLOCK` | Any | * | * | * | Règle de Clôture - Isolation stricte |

---

### VLAN 1624 - LOGI-PU

#### Objets / Alias utilisés
* **RFC1918_Private** (Network) : `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`

| ID | Ordre | Action | Protocole | Source | Destination | Port | Description |
|:---|:---:|:---:|:---:|:---|:---|:---|:---|
| **1** | 1 | `PASS` | TCP/UDP | `LOGI-PU subnets` | `IT-PU subnets` | * (Any) | Support IT |
| **2** | 2 | `PASS` | TCP/UDP | `LOGI-PU subnets` | `ASM-PU subnets` | * (Any) | Coordination assemblage |
| **3** | 3 | `PASS` | TCP | `LOGI-PU subnets` | `PRINTER-PU subnets` | 9100, 515 | Impression |
| **4** | 4 | `PASS` | TCP/UDP | `LOGI-PU subnets` | **! RFC1918_Private** | * (Any) | Accès Internet |
| **5** | 5 | `BLOCK` | Any | * | * | * | Règle de Clôture |

---

### VLAN 1676 - ASM-PU

#### Objets / Alias utilisés
* **RFC1918_Private** (Network) : `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`

| ID | Ordre | Action | Protocole | Source | Destination | Port | Description |
|:---|:---:|:---:|:---:|:---|:---|:---|:---|
| **1** | 1 | `PASS` | TCP/UDP | `ASM-PU subnets` | `IT-PU subnets` | * (Any) | Support IT |
| **2** | 2 | `PASS` | TCP/UDP | `ASM-PU subnets` | `PROD-PU subnets` | * (Any) | Accès systèmes production |
| **3** | 3 | `PASS` | TCP | `ASM-PU subnets` | `PRINTER-PU subnets` | 9100, 515 | Impression |
| **4** | 4 | `PASS` | TCP/UDP | `ASM-PU subnets` | **! RFC1918_Private** | * (Any) | Accès Internet |
| **5** | 5 | `BLOCK` | Any | * | * | * | Règle de Clôture |

---

### VLAN 1680 - ALARMES-PU

| ID | Ordre | Action | Protocole | Source | Destination | Port | Description |
|:---|:---:|:---:|:---:|:---|:---|:---|:---|
| **1** | 1 | `PASS` | TCP/UDP | `ALARMES-PU subnets` | `IT-PU subnets` | * (Any) | Maintenance IT uniquement |
| **2** | 2 | `BLOCK` | Any | * | * | * | Règle de Clôture - Isolation stricte |

---

### VLAN 1684 - CAMERAS-PU

| ID | Ordre | Action | Protocole | Source | Destination | Port | Description |
|:---|:---:|:---:|:---:|:---|:---|:---|:---|
| **1** | 1 | `PASS` | TCP/UDP | `CAMERAS-PU subnets` | `IT-PU subnets` | * (Any) | Maintenance IT uniquement |
| **2** | 2 | `BLOCK` | Any | * | * | * | Règle de Clôture - Isolation stricte |

---

### VLAN 1688 - PRINTER-PU

| ID | Ordre | Action | Protocole | Source | Destination | Port | Description |
|:---|:---:|:---:|:---:|:---|:---|:---|:---|
| **1** | 1 | `PASS` | TCP/UDP | `PRINTER-PU subnets` | `IT-PU subnets` | * (Any) | Maintenance IT |
| **2** | 2 | `BLOCK` | Any | * | * | * | Règle de Clôture - Isolation stricte |

---

### VLAN 1696 - MGM-PU

#### Objets / Alias utilisés
* **RFC1918_Private** (Network) : `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`

| ID | Ordre | Action | Protocole | Source | Destination | Port | Description |
|:---|:---:|:---:|:---:|:---|:---|:---|:---|
| **1** | 1 | `PASS` | TCP/UDP | `MGM-PU subnets` | `IT-PU subnets` | * (Any) | Support IT |
| **2** | 2 | `PASS` | TCP/UDP | `MGM-PU subnets` | **! RFC1918_Private** | 53 (DNS) | Résolution DNS |
| **3** | 3 | `PASS` | TCP | `MGM-PU subnets` | **! RFC1918_Private** | 80, 443 | Mises à jour firmware |
| **4** | 4 | `PASS` | UDP | `MGM-PU subnets` | **! RFC1918_Private** | 123 (NTP) | Synchronisation temps |
| **5** | 5 | `BLOCK` | Any | * | * | * | Règle de Clôture |

---

## Services DHCP

### Configuration DHCP par VLAN

Chaque VLAN dispose de son propre serveur DHCP configuré sur pfSense :

| VLAN | Réseau          | Plage DHCP         | Passerelle   | DNS           |
|------|-----------------|-------------------|--------------|---------------|
| 1604 | 10.16.4.0/24    | 10.16.4.100-200   | 10.16.4.254  | 10.16.4.254   |
| 1608 | 10.16.8.0/24    | 10.16.8.100-200   | 10.16.8.254  | 10.16.8.254   |
| 1612 | 10.16.12.0/24   | 10.16.12.100-200  | 10.16.12.254 | 10.16.12.254  |
| 1620 | 10.16.20.0/24   | 10.16.20.100-200  | 10.16.20.254 | 10.16.20.254  |
| 1624 | 10.16.24.0/24   | 10.16.24.100-200  | 10.16.24.254 | 10.16.24.254  |
| 1676 | 10.16.76.0/24   | 10.16.76.100-200  | 10.16.76.254 | 10.16.76.254  |
| 1680 | 10.16.80.0/24   | 10.16.80.100-200  | 10.16.80.254 | 10.16.80.254  |
| 1684 | 10.16.84.0/24   | 10.16.84.100-200  | 10.16.84.254 | 10.16.84.254  |
| 1688 | 10.16.88.0/24   | 10.16.88.100-200  | 10.16.88.254 | 10.16.88.254  |
| 1696 | 10.16.96.0/24   | 10.16.96.100-200  | 10.16.96.254 | 10.16.96.254  |

**Durée de bail :** 86400 secondes (24 heures)

### Réservations statiques

#### VLAN 1604 (ADMIN-PU)
- **10.16.4.10** - Tap Management pfSense (MAC: 02:42:7b:d0:0f:00)

#### VLAN 1696 (MGM-PU)
- **10.16.96.218** - SL2-PU-02
- **10.16.96.219** - SL2-PU-01

---

### Flux autorisés détaillés

#### Depuis RD-PU
- → IT-PU : Complet
- → PRINTER-PU : TCP 9100, 515
- → Internet : TCP/UDP Any

#### Depuis PROD-PU
- → IT-PU : Complet

#### Depuis LOGI-PU
- → IT-PU : Complet
- → ASM-PU : Complet
- → PRINTER-PU : TCP 9100, 515
- → Internet : TCP/UDP Any

#### Depuis ASM-PU
- → IT-PU : Complet
- → PROD-PU : Complet
- → PRINTER-PU : TCP 9100, 515
- → Internet : TCP/UDP Any

#### Depuis ALARMES-PU
- → IT-PU : Complet

#### Depuis CAMERAS-PU
- → IT-PU : Complet

#### Depuis PRINTER-PU
- → IT-PU : Complet

#### Depuis MGM-PU
- → IT-PU : Complet
- → Internet : DNS, NTP, HTTPS

---

## Bonnes pratiques appliquées

### 1. Segmentation réseau
- 10 VLANs distincts par fonction métier
- Isolation des systèmes critiques
- Séparation des flux de données sensibles

### 2. Principe du moindre privilège
- Accès uniquement aux ressources nécessaires
- Règles par défaut = DENY ALL
- Autorisations explicites uniquement

### 3. Défense en profondeur
- Firewall pfSense (Layer 3/4)
- DHCP Snooping sur switches (Layer 2)
- Dynamic ARP Inspection (Layer 2)
- Port Security sur interfaces access

### 4. Isolation des systèmes critiques
- PROD-PU : Isolation SCADA
- ALARMES-PU : Isolation complète
- CAMERAS-PU : Protection des flux vidéo

### 5. Logging et traçabilité
- Règles de blocage avec logging activé
- Traçabilité des tentatives d'accès refusées
- Audit des flux réseau possible

### 6. Protection Layer 2
- DHCP Snooping
- Rate limiting : 5 pps sur interfaces access
- Dynamic ARP Inspection
- Trust ports uniquement sur uplinks firewall

### 7. Hardening switches
- CDP désactivé
- Port Security activé
- BPDU Guard sur ports access
- Root Guard sur ports access
- SSH v2 uniquement
- Authentification locale

### 8. Gestion sécurisée
- VLAN Management dédié (1696)
- Accès administration par IT/ADMIN uniquement
- Pas de VLAN 1
- Native VLAN trunk = 1699 (unused)

---

## Recommandations futures

### Court terme (0-3 mois)
1. **IDS/IPS** : Déployer Suricata sur pfSense pour détection d'intrusions
2. **Monitoring** : Mettre en place un SIEM (Security Information and Event Management)
3. **Sauvegardes** : Automatiser les backups de config pfSense et switches
4. **Documentation** : Maintenir un inventaire des équipements par VLAN

### Moyen terme (3-6 mois)
1. **802.1X** : Authentification réseau (NAC) sur ports access
2. **VPN** : Accès distant sécurisé pour IT/ADMIN
3. **Pentest** : Test d'intrusion pour validation de la sécurité
4. **Formation** : Sensibilisation sécurité pour les utilisateurs

### Long terme (6-12 mois)
1. **SOC** : Centre d'opérations de sécurité (interne ou externalisé)
2. **Redondance** : Firewall pfSense en HA (High Availability)
3. **Segmentation micro** : Micro-segmentation au niveau applicatif
4. **Zero Trust** : Évolution vers une architecture Zero Trust

---

## Annexes

### A. Ports communs

| Port  | Protocole | Service                    |
|-------|-----------|----------------------------|
| 53    | TCP/UDP   | DNS                        |
| 80    | TCP       | HTTP                       |
| 443   | TCP       | HTTPS                      |
| 123   | UDP       | NTP (synchronisation temps)|
| 515   | TCP       | LPD (impression)           |
| 9100  | TCP       | JetDirect (impression HP)  |
| 22    | TCP       | SSH                        |

### B. Commandes de vérification

#### pfSense
```bash
# Vérifier les règles firewall
pfctl -sr

# Vérifier les états de connexion
pfctl -ss

# Vérifier les tables d'alias
pfctl -t tablename -T show

# Logs firewall en temps réel
clog -f /var/log/filter.log
```

#### Switches Cisco
```cisco
! Vérifier DHCP Snooping
show ip dhcp snooping
show ip dhcp snooping binding

! Vérifier ARP Inspection
show ip arp inspection
show ip arp inspection vlan <vlan-id>

! Vérifier Port Security
show port-security
show port-security interface <interface>

! Vérifier VLANs
show vlan brief
show interface trunk
```

### C. Contacts et escalades

| Rôle                  | Contact                | Disponibilité |
|-----------------------|------------------------|---------------|
| Administrateur Réseau | admin@novatech.lab     | 24/7          |
| Équipe IT             | it-support@novatech.lab| 8h-18h        |
| Sécurité              | security@novatech.lab  | 24/7          |
| Astreinte             | +33 X XX XX XX XX      | 24/7          |

---

## Changelog

| Version | Date       | Auteur      | Modifications                           |
|---------|------------|-------------|-----------------------------------------|
| 1.0     | 2025-12-11 | Mister_DS   | Création initiale de la documentation   |

---

**Document confidentiel - Usage interne uniquement**  
**© NovaTech - Infrastructure Production 2025**
