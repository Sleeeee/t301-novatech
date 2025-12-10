# Flux Site Production (PU) → Maison Mère (M/T)

Ce document recense exclusivement les flux réseaux autorisés partant des VLANs du site de Production vers les services hébergés à la Maison Mère.

## 1. Administrateurs & IT (ADMIN-PU / IT-PU)
**Sources :** `ADMIN-PU` (10.16.4.0/24) / `IT-PU` (10.16.8.0/24)

Les équipes techniques sur le site de production doivent accéder aux outils de gestion centralisés.

| Destination (Maison Mère) | Zone / VLAN | IP Cible | Protocole / Port | Description |
| :--- | :--- | :--- | :--- | :--- |
| **Jump Server** | Trusted (MT) | `10.1.4.0/24` | TCP/22 (SSH)<br>TCP/3389 (RDP) | Point d'entrée unique pour l'administration des serveurs et équipements. |
| **Contrôleurs de Domaine** | Trusted (MT) | `10.1.8.0/24` | UDP+TCP/53 (DNS)<br>TCP/88 (Kerberos)<br>TCP/389 (LDAP)<br>TCP/445 (SMB) | Authentification des sessions, GPO et résolution DNS interne. |
| **NVR (Caméras)** | Trusted (MT) | `10.1.20.0/24` | TCP/443 (HTTPS) | Accès à l'interface de visualisation des caméras. |
| **Serveurs App (Monitoring)** | Trusted (MT) | `10.1.12.0/24` | TCP/443 (HTTPS) | Accès aux consoles web de supervision si hébergées sur APP. |

---

## 2. Production & Logistique (PROD-PU / LOGI-PU)
**Sources :** `PROD-PU` (10.16.20.0/24) / `LOGI-PU` (10.16.24.0/24)

Les machines de production et les postes logistiques ont besoin d'accéder à l'ERP central.

| Destination (Maison Mère) | Zone / VLAN | IP Cible | Protocole / Port | Description |
| :--- | :--- | :--- | :--- | :--- |
| **Serveurs Applicatifs** | Trusted (MT) | `10.1.12.0/24` | TCP/443 (HTTPS) | Accès à l'ERP et aux applications métier. |

> **Note :** Aucun accès direct à la Base de Données (`10.1.28.0/24`) n'est autorisé depuis ces VLANs. Tout passe par le serveur applicatif.

---

## 3. R&D (RD-PU)
**Source :** `RD-PU` (10.16.12.0/24)

| Destination (Maison Mère) | Zone / VLAN | IP Cible | Protocole / Port | Description |
| :--- | :--- | :--- | :--- | :--- |
| **Serveurs Applicatifs** | Trusted (MT) | `10.1.12.0/24` | TCP/443 (HTTPS)<br>TCP/22 (SSH/Git) | Accès aux dépôts de code ou environnements de recette. |
| **Contrôleurs de Domaine** | Trusted (MT) | `10.1.8.0/24` | Standards AD | Authentification (si postes intégrés au domaine). |

---

## 4. Caméras (CAMERA-PU)
**Source :** `CAMERA-PU` (10.16.84.0/24)

Les caméras du site de production envoient leurs flux vers l'enregistreur central.

| Destination (Maison Mère) | Zone / VLAN | IP Cible | Protocole / Port | Description |
| :--- | :--- | :--- | :--- | :--- |
| **NVR Central** | Trusted (MT) | `10.1.20.0/24` | TCP+UDP/554 (RTSP)<br>TCP/80 (ONVIF) | Enregistrement du flux vidéo en continu. |

---

## 5. Alarmes (ALARME-PU)
**Source :** `ALARME-PU` (10.16.80.0/24)

| Destination (Maison Mère) | Zone / VLAN | IP Cible | Protocole / Port | Description |
| :--- | :--- | :--- | :--- | :--- |
| **Serveur Supervision** | Management (MT) | `10.1.96.0/24` | Propriétaire ou TCP/443 | Remontée des alertes intrusions/incendies vers la console centrale. |

---

## 6. Management Équipements (MGM-PU)
**Source :** `MGM-PU` (10.16.96.0/24)

Les équipements réseaux (switchs, onduleurs) du site de production envoient leurs logs.

| Destination (Maison Mère) | Zone / VLAN | IP Cible | Protocole / Port | Description |
| :--- | :--- | :--- | :--- | :--- |
| **Serveur Supervision** | Management (MT) | `10.1.96.0/24` | UDP/514 (Syslog)<br>UDP/162 (SNMP Trap) | Centralisation des logs et alertes techniques. |
