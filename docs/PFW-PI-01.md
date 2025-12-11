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

## Alias Firewall

### Alias IP (Réseaux)

| Nom | Type | Valeurs | Description |
|:----|:----:|:--------|:------------|
| **APPMT** | Network(s) | `10.1.12.0/24` | Accès app Mère |
| **ASM_PU** | Network(s) | `10.16.76.0/24` | Chaîne assemblage |
| **DCMT** | Network(s) | `10.1.8.0/24` | Domain Controller |
| **DNS_MD** | Network(s) | `10.2.12.0/24` | DNS Public DMZ |
| **ERP_CRM_MT** | Network(s) | `10.1.12.0/24`, `10.1.12` | Serveur ERP et CRM |
| **JMPMT** | Network(s) | `10.1.4.0/24` | Jump Serveur Mère |
| **NVR_MT** | Network(s) | `10.1.20.0/24` | Video Recorder |
| **PROXY_MT** | Network(s) | `10.2.8.0/24` | Proxy Mère |
| **RDS_MT** | Network(s) | `10.1.36.0/24` | Serveur RDS sensible |
| **RFC1918_Private** | Network(s) | `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16` | Accès internet |
| **VLANS_Metier_Prod** | Network(s) | `10.16.4.0/24`, `10.16.8.0/24`, `10.16.12.0/24`, `10.16.20.0/24`, `10.16.24.0/24` | VLANs métier site de production |
| **WEB_MD** | Network(s) | `10.2.16.0/24` | Serveur Web DMZ |

### Alias Ports

| Nom | Type | Valeurs | Description |
|:----|:----:|:--------|:------------|
| **AD_Auth_Port** | Port(s) | `88`, `389`, `445`, `636` | Port Pour l'AD |
| **HTTP_Proxy** | Port(s) | `8888` | Port http Proxy |
| **Impression** | Port(s) | `9100`, `515`, `631`, `445`, `139` | Port d'impression |
| **Logs** | Port(s) | `514`, `162` | Pour les logs |
| **SSH_RDP** | Port(s) | `22`, `3389` | Pour le SSH et RDP |
| **RSTP** | Port(s) | `554` | Streaming video |

---

## Règles firewall par VLAN

### VLAN 1604 - ADMIN-PU

#### Objets / Alias utilisés
* **JMPMT** : Serveur Jump (probablement au HQ)
* **SSH_RDP** : Ports SSH/RDP
* **PROXY_MT** : Serveur Proxy
* **HTTP_Proxy** : Port proxy HTTP
* **DCMT** : Domain Controller (HQ)
* **DNS_MD** : Serveur DNS secondaire
* **ERP_CRM_MT** : Serveur ERP/CRM
* **WEB_MD** : Serveur Web
* **AD_Auth_Port** : Ports d'authentification Active Directory

| ID | Ordre | Action | Protocole | Source | Destination | Port | Description |
|:---|:---:|:---:|:---:|:---|:---|:---|:---|
| **1** | 1 | `PASS` | * | * | `ADMINPU Address` | 443, 80 | Anti-Lockout Rule |
| **2** | 2 | `PASS` | TCP | `ADMINPU subnets` | `JMPMT` | SSH_RDP | SSH/RDP to JMP-MT |
| **3** | 3 | `PASS` | TCP | `ADMINPU subnets` | `PROXY_MT` | HTTP_Proxy | Http vers Proxy |
| **4** | 4 | `PASS` | TCP | `ADMINPU subnets` | `DCMT` | 53 (DNS) | DNS vers DC-MT |
| **5** | 5 | `PASS` | TCP | `ADMINPU subnets` | `DNS_MD` | 53 (DNS) | DNS vers DNS-MD |
| **6** | 6 | `PASS` | TCP | `ADMINPU subnets` | `ERP_CRM_MT` | 443 (HTTPS) | HTTPS vers ERP |
| **7** | 7 | `PASS` | TCP | `ADMINPU subnets` | `WEB_MD` | 443 (HTTPS) | HTTPS vers Web-MD |
| **8** | 8 | `PASS` | TCP/UDP | `ADMINPU subnets` | `DCMT` | AD_Auth_Port | AD Service vers DC-MT |
| **9** | 9 | `PASS` | TCP | `JMPMT` | `ADMINPU subnets` | 3389 (MS RDP) | RDP du Jump vers Admin |
| **10** | 10 | `BLOCK` | IPv4 * | `ADMINPU subnets` | * | * | Blocque tout le trafic d'admin |
| **11** | 11 | `BLOCK` | IPv6 * | * | * | * | Rejet IPv6 |

---

### VLAN 1624 - LOGI-PU

#### Objets / Alias utilisés
* **PROXY_MT** : Serveur Proxy (HQ)
* **HTTP_Proxy** : Port proxy HTTP
* **DCMT** : Domain Controller (HQ)
* **DNS_MD** : Serveur DNS secondaire
* **ERP_CRM_MT** : Serveur ERP/CRM
* **WEB_MD** : Serveur Web
* **JMPMT** : Serveur Jump (HQ)
* **AD_Auth_Port** : Ports d'authentification Active Directory

| ID | Ordre | Action | Protocole | Source | Destination | Port | Description |
|:---|:---:|:---:|:---:|:---|:---|:---|:---|
| **1** | 1 | `PASS` | TCP | `LOGIPU address` | `LOGIPU address` | 443 (HTTPS) | Anti-Lockout Rule |
| **2** | 2 | `PASS` | TCP | `LOGIPU subnets` | `PROXY_MT` | HTTP_Proxy | Http vers Proxy |
| **3** | 3 | `PASS` | TCP/UDP | `LOGIPU subnets` | `DCMT` | 53 (DNS) | DNS to DC-MT |
| **4** | 4 | `PASS` | TCP/UDP | `LOGIPU subnets` | `DNS_MD` | 53 (DNS) | DNS vers DNS-MD |
| **5** | 5 | `PASS` | TCP | `LOGIPU subnets` | `ERP_CRM_MT` | 443 (HTTPS) | HTTPS vers ERP |
| **6** | 6 | `PASS` | TCP | `LOGIPU subnets` | `WEB_MD` | 443 (HTTPS) | HTTPS vers Web-MD |
| **7** | 7 | `PASS` | TCP | `JMPMT` | `LOGIPU subnets` | 3389 (MS RDP) | RDP du Jump vers LOGIPU |
| **8** | 8 | `PASS` | TCP/UDP | `LOGIPU subnets` | `DCMT` | AD_Auth_Port | AD Service vers DC-MT |
| **9** | 9 | `BLOCK` | IPv4 * | `LOGIPU subnets` | * | * | Blocque tout le trafic de logi |
| **10** | 10 | `BLOCK` | IPv6 * | * | * | * | Rejet IPv6 |

---

### VLAN 1612 - RD-PU

#### Objets / Alias utilisés
* **RDS_MT** : Serveur RDS (HQ)
* **SSH_RDP** : Ports SSH/RDP
* **PROXY_MT** : Serveur Proxy (HQ)
* **HTTP_Proxy** : Port proxy HTTP
* **DCMT** : Domain Controller (HQ)
* **DNS_MD** : Serveur DNS secondaire
* **ERP_CRM_MT** : Serveur ERP/CRM
* **WEB_MD** : Serveur Web
* **AD_Auth_Port** : Ports d'authentification Active Directory
* **JMPMT** : Serveur Jump (HQ)

| ID | Ordre | Action | Protocole | Source | Destination | Port | Description |
|:---|:---:|:---:|:---:|:---|:---|:---|:---|
| **1** | 1 | `PASS` | TCP | `RDPU address` | `RDPU address` | 443 (HTTPS) | Anti-Lockout Rule |
| **2** | 2 | `PASS` | TCP | `RDPU subnets` | `RDS_MT` | SSH_RDP | SSH/RDP vers zone sensible |
| **3** | 3 | `PASS` | TCP | `RDPU subnets` | `PROXY_MT` | HTTP_Proxy | Http vers Proxy |
| **4** | 4 | `PASS` | TCP/UDP | `RDPU subnets` | `DCMT` | 53 (DNS) | DNS to DC-MT |
| **5** | 5 | `PASS` | TCP/UDP | `RDPU subnets` | `DNS_MD` | 53 (DNS) | DNS vers DNS-MD |
| **6** | 6 | `PASS` | TCP | `RDPU subnets` | `ERP_CRM_MT` | 443 (HTTPS) | HTTPS vers ERP |
| **7** | 7 | `PASS` | TCP | `RDPU subnets` | `WEB_MD` | 443 (HTTPS) | HTTPS vers Web-MD |
| **8** | 8 | `PASS` | TCP/UDP | `RDPU subnets` | `DCMT` | AD_Auth_Port | AD Service vers DC-MT |
| **9** | 9 | `PASS` | TCP | `JMPMT` | `RDPU subnets` | SSH_RDP | RDP du Jump vers RDPU |
| **10** | 10 | `BLOCK` | IPv4 * | `RDPU subnets` | * | * | Blocque tout le trafic de RD |
| **11** | 11 | `BLOCK` | IPv6 * | * | * | * | Rejet IPv6 |

---

### VLAN 1620 - PROD-PU

#### Objets / Alias utilisés
* **ASM_PU** : Chaîne assemblage (10.16.76.0/24)
* **PROXY_MT** : Serveur Proxy Mère (10.2.8.0/24)
* **HTTP_Proxy** : Port 8888
* **DCMT** : Domain Controller (10.1.8.0/24)
* **DNS_MD** : DNS Public DMZ (10.2.12.0/24)
* **ERP_CRM_MT** : Serveur ERP/CRM (10.1.12.0/24)
* **WEB_MD** : Serveur Web DMZ (10.2.16.0/24)
* **AD_Auth_Port** : Ports 88, 389, 445, 636

| ID | Ordre | Action | Protocole | Source | Destination | Port | Description |
|:---|:---:|:---:|:---:|:---|:---|:---|:---|
| **1** | 1 | `PASS` | TCP | `PRODPU address` | `PRODPU address` | 443 (HTTPS) | Anti-Lockout Rule |
| **2** | 2 | `PASS` | TCP | `PRODPU subnets` | `ASM_PU` | 80 (HTTP) | HTTP vers ASM |
| **3** | 3 | `PASS` | TCP | `PRODPU subnets` | `PROXY_MT` | HTTP_Proxy | Http vers Proxy |
| **4** | 4 | `PASS` | TCP/UDP | `PRODPU subnets` | `DCMT` | 53 (DNS) | DNS to DC-MT |
| **5** | 5 | `PASS` | TCP/UDP | `PRODPU subnets` | `DNS_MD` | 53 (DNS) | DNS vers DNS-MD |
| **6** | 6 | `PASS` | TCP | `PRODPU subnets` | `ERP_CRM_MT` | 443 (HTTPS) | HTTPS vers ERP |
| **7** | 7 | `PASS` | TCP | `PRODPU subnets` | `WEB_MD` | 443 (HTTPS) | HTTPS vers Web-MD |
| **8** | 8 | `PASS` | TCP/UDP | `PRODPU subnets` | `DCMT` | AD_Auth_Port | AD Service vers DC-MT |
| **9** | 9 | `BLOCK` | IPv4 * | `PRODPU subnets` | * | * | Blocque tout le trafic de prod |
| **10** | 10 | `BLOCK` | IPv6 * | * | * | * | Rejet IPv6 |

---

### VLAN 1676 - ASM-PU

#### Objets / Alias utilisés
* **JMPMT** : Jump Serveur Mère (10.1.4.0/24)
* **PRODPU** : VLAN Production (10.16.20.0/24)

| ID | Ordre | Action | Protocole | Source | Destination | Port | Description |
|:---|:---:|:---:|:---:|:---|:---|:---|:---|
| **1** | 1 | `PASS` | TCP | `ASMPU address` | `ASMPU address` | 443 (HTTPS) | Anti-Lockout Rule |
| **2** | 2 | `PASS` | TCP | `JMPMT` | `ASMPU subnets` | 80 (HTTP) | http vers jump vers asm |
| **3** | 3 | `PASS` | TCP | `PRODPU subnets` | `ASMPU subnets` | 80 (HTTP) | http de PROD-PU vers ASM |
| **4** | 4 | `BLOCK` | IPv4 * | `ASMPU subnets` | * | * | Blocque tout le trafic d'asm |
| **5** | 5 | `BLOCK` | IPv6 * | * | * | * | Rejet IPv6 |

---

### VLAN 1684 - CAMERAS-PU

#### Objets / Alias utilisés
* **JMPMT** : Jump Serveur Mère (10.1.4.0/24)
* **NVR_MT** : Video Recorder (10.1.20.0/24)

| ID | Ordre | Action | Protocole | Source | Destination | Port | Description |
|:---|:---:|:---:|:---:|:---|:---|:---|:---|
| **1** | 1 | `PASS` | TCP | `CAMERASPU address` | `CAMERASPU address` | 443 (HTTPS) | Anti-Lockout Rule |
| **2** | 2 | `PASS` | TCP | `JMPMT` | `CAMERASPU subnets` | 80 (HTTP) | http vers jump vers camera |
| **3** | 3 | `PASS` | TCP/UDP | `CAMERASPU subnets` | `NVR_MT` | * | Camera vers NVR_MT |
| **4** | 4 | `BLOCK` | IPv4 * | `CAMERASPU subnets` | * | * | Blocque tout le trafic de cameras |
| **5** | 5 | `BLOCK` | IPv6 * | * | * | * | Rejet IPv6 |

---

### VLAN 1608 - IT-PU

#### Objets / Alias utilisés
* **DCMT** : Domain Controller (10.1.8.0/24)
* **HTTP_Proxy** : Port 8888
* **DNS_MD** : DNS Public DMZ (10.2.12.0/24)
* **ERP_CRM_MT** : Serveur ERP/CRM (10.1.12.0/24)
* **WEB_MD** : Serveur Web DMZ (10.2.16.0/24)
* **AD_Auth_Port** : Ports 88, 389, 445, 636

| ID | Ordre | Action | Protocole | Source | Destination | Port | Description |
|:---|:---:|:---:|:---:|:---|:---|:---|:---|
| **1** | 1 | `PASS` | TCP | `ITPU address` | `ITPU address` | 443 (HTTPS) | Anti-Lockout Rule |
| **2** | 2 | `PASS` | TCP | `ITPU subnets` | `DCMT` | HTTP_Proxy | Http vers Proxy |
| **3** | 3 | `PASS` | TCP/UDP | `ITPU subnets` | `DCMT` | 53 (DNS) | DNS to DC-MT |
| **4** | 4 | `PASS` | TCP/UDP | `ITPU subnets` | `DNS_MD` | 53 (DNS) | DNS vers DNS-MD |
| **5** | 5 | `PASS` | TCP | `ITPU subnets` | `ERP_CRM_MT` | 443 (HTTPS) | HTTPS vers ERP |
| **6** | 6 | `PASS` | TCP | `ITPU subnets` | `WEB_MD` | 443 (HTTPS) | HTTPS vers Web-MD |
| **7** | 7 | `PASS` | TCP/UDP | `ITPU subnets` | `DCMT` | AD_Auth_Port | AD Service vers DC-MT |
| **8** | 8 | `BLOCK` | IPv4 * | `ITPU subnets` | * | * | Blocque tout le trafic d'it |
| **9** | 9 | `BLOCK` | IPv6 * | * | * | * | Rejet IPv6 |

---

### VLAN 1688 - PRINTER-PU

#### Objets / Alias utilisés
* **VLANS_Metier_Prod** : VLANs métier site de production (10.16.4.0/24, 10.16.8.0/24, 10.16.12.0/24, 10.16.20.0/24, 10.16.24.0/24)
* **Impression** : Ports 9100, 515, 631, 445, 139

| ID | Ordre | Action | Protocole | Source | Destination | Port | Description |
|:---|:---:|:---:|:---:|:---|:---|:---|:---|
| **1** | 1 | `PASS` | TCP | `PRINTERPU address` | `PRINTERPU address` | 443 (HTTPS) | Anti-Lockout Rule |
| **2** | 2 | `PASS` | TCP | `VLANS_Metier_Prod` | `PRINTERPU subnets` | Impression | accès printer du métiers |
| **3** | 3 | `BLOCK` | IPv4 * | `PRINTERPU subnets` | * | * | Blocque tout le trafic de printer |
| **4** | 4 | `BLOCK` | IPv6 * | * | * | * | Rejet IPv6 |

---

### VLAN 1680 - ALARMES-PU

#### Objets / Alias utilisés
* **JMPMT** : Jump Serveur Mère (10.1.4.0/24)

| ID | Ordre | Action | Protocole | Source | Destination | Port | Description |
|:---|:---:|:---:|:---:|:---|:---|:---|:---|
| **1** | 1 | `PASS` | TCP | `ALARMESPU address` | `ALARMESPU address` | 443 (HTTPS) | Anti-Lockout Rule |
| **2** | 2 | `PASS` | TCP | `JMPMT` | `ALARMESPU subnets` | 80 (HTTP) | http vers jump vers alarmes |
| **3** | 3 | `BLOCK` | IPv4 * | `ALARMESPU subnets` | * | * | Blocque tout le trafic d'alarme |
| **4** | 4 | `BLOCK` | IPv6 * | * | * | * | Rejet IPv6 |

---


