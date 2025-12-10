# Documentation Firewall

## ADMIN-PU

### Objets / Alias utilisés
* **DCMT** (Network) : `10.1.8.0/24` (Contrôleurs de Domaine Maison Mère)
* **JMPMT** (Network) : `10.1.4.0/24` (Serveur de Rebond)
* **RFC1918_Private** (Network) : `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16` (Ensemble des réseaux privés)
* **SSH_RDP** (Ports) : `22`, `3389` (Administration distante)

### Synthèse des flux autorisés

| ID | Ordre | Action | Protocole | Source | Destination | Port | Description & Justification |
| :--- | :---: | :---: | :---: | :--- | :--- | :--- | :--- |
| **1** | 1 | `PASS` | TCP/UDP | `ADMINPU subnets` | **! RFC1918_Private** | * (Any) | **Accès Internet** : Autorise l'accès vers le WAN uniquement. L'inversion (`!`) sur l'alias privé garantit qu'aucun trafic ne peut fuiter vers d'autres réseaux internes via cette règle. |
| **2** | 2 | `PASS` | TCP | `ADMINPU subnets` | **JMPMT** | **SSH_RDP** | **Administration Centralisée** : Accès au Jump Server en SSH ou RDP pour l'administration des serveurs. |
| **3** | 3 | `PASS` | TCP/UDP | `ADMINPU subnets` | **DCMT** | 53 (DNS) | **Infra DNS** : Résolution de noms via les contrôleurs de domaine de la Maison Mère. |
| **4** | 4 | `BLOCK` | Any | * | * | * | **Règle de Clôture** : Bloque explicitement tout autre trafic pour assurer la segmentation stricte. |

## ALARMES-PU

### Politique de Sécurité
Ce réseau héberge les centrales d'intrusion et de détection incendie.
Il est configuré avec une politique d'**isolation stricte**. Aucune remontée d'alerte directe vers le serveur de supervision n'est autorisée. Les flux sont limités exclusivement à l'envoi de logs vers le serveur d'administration (Jump Server).

### Objets / Alias utilisés
* **JMPMT** (Network) : `10.1.4.0/24` (Serveur de Rebond / Bastion)

### Synthèse des flux autorisés

| ID | Ordre | Action | Protocole | Source | Destination | Port | Description & Justification |
| :--- | :---: | :---: | :---: | :--- | :--- | :--- | :--- |
| **1** | 1 | `PASS` | TCP | `ALARMESPU subnets` | **JMPMT** | 22 (SSH) | **Envoi de logs** : Seule communication sortante autorisée. Permet aux équipements d'envoyer leurs journaux ou fichiers de maintenance vers le Jump Server. |
| **2** | 2 | `BLOCK` | Any | * | * | * | **Isolement Total** : Bloque tout autre trafic (Internet, Supervision, accès latéral). Empêche les équipements d'alarme de communiquer avec l'extérieur ou le reste du réseau. |

### Note
L'administration des alarmes reste possible à l'initiative du **Jump Server** (flux entrant), grâce au mécanisme de suivi d'état (*Stateful Inspection*) du pare-feu.

## ASM-PU, CAMERAS-PU, PRINTER-PU

### Politique de Sécurité
Ces réseaux sont considérés comme des zones **passives et isolées**. Ils ne doivent initier qu'un seul flux : l'envoi de logs vers le serveur d'administration central (Jump Server). Tout autre trafic (y compris Internet) est strictement interdit.

### Objets / Alias utilisés
* **JMPMT** (Network) : `10.1.4.0/24` (Serveur de Rebond / Bastion)

---

### Synthèse des flux autorisés (Identique pour les 3 VLANs)


| ID | Ordre | Action | Protocole | Source | Destination | Port | Description & Justification |
| :--- | :---: | :---: | :---: | :--- | :--- | :--- | :--- |
| **1** | 1 | `PASS` | TCP | `VLAN subnets` | **JMPMT** | 22 (SSH) | **Envoi de Logs** : Autorise la communication sortante vers le Jump Server pour l'envoi de journaux de sécurité et de maintenance. |
| **2** | 2 | `BLOCK` | Any | * | * | * | **Règle de Clôture** : Bloque tout autre trafic (Internet, accès latéral, Supervision). |



## RD-PU

### Objets / Alias utilisés
* **DCMT** (Network) : `10.1.8.0/24` (Contrôleurs de Domaine)
* **APPMT** (Network) : `10.1.12.0/24` (Serveurs Applicatifs / Recette)
* **RFC1918_Private** (Network) : Ensemble des réseaux privés (10.x.x.x, 172.16.x.x, 192.168.x.x)
* **AD_Auth_Ports** (Ports) : `88`, `389`, `445` (Kerberos, LDAP, SMB)

### Synthèse des flux autorisés

| ID | Ordre | Action | Protocole | Source | Destination | Port | Description & Justification |
| :--- | :---: | :---: | :---: | :--- | :--- | :--- | :--- |
| **1** | 1 | `PASS` | TCP/UDP | `RDPU subnets` | **DCMT** | 53 (DNS) | **Résolution DNS** : Indispensable pour la navigation et la résolution des noms de serveurs. |
| **2** | 2 | `PASS` | TCP | `RDPU subnets` | **DCMT** | **AD_Auth_Ports** | **Authentification** : Permet l'ouverture de session sur le domaine (Active Directory). |
| **3** | 3 | `PASS` | TCP | `RDPU subnets` | **APPMT** | 443 (HTTPS) | **Accès Applicatif** : Accès aux interfaces web des environnements de recette et des applications métier. (Le port 22 (SSH/Git) est volontairement retiré). |
| **4** | 4 | `PASS` | TCP/UDP | `RDPU subnets` | **! RFC1918_Private** | * (Any) | **Accès Internet** : Autorise l'accès WAN pour la documentation et les ressources externes. L'inversion (`!`) garantit l'interdiction d'accès aux autres réseaux internes. |
| **5** | 5 | `BLOCK` | Any | * | * | * | **Règle de Clôture** : Bloque tout autre trafic. |


## PROD-PU

### Objets / Alias utilisés
* **DCMT** (Network) : `10.1.8.0/24` (Contrôleurs de Domaine)
* **APPMT** (Network) : `10.1.12.0/24` (Serveurs Applicatifs)
* **AD_Auth_Port** (Ports) : `88`, `389`, `445` (Kerberos, LDAP, SMB)

### Synthèse des flux autorisés

| ID | Ordre | Action | Protocole | Source | Destination | Port | Description & Justification |
| :--- | :---: | :---: | :---: | :--- | :--- | :--- | :--- |
| **1** | 1 | `PASS` | TCP/UDP | `PRODPU subnets` | **DCMT** | 53 (DNS) | **Résolution DNS** : Indispensable pour la résolution de noms interne (ERP). |
| **2** | 2 | `PASS` | TCP | `PRODPU subnets` | **DCMT** | **AD_Auth_Port** | **Authentification** : Permet l'ouverture de session et l'authentification au domaine. |
| **3** | 3 | `PASS` | TCP | `PRODPU subnets` | **APPMT** | 443 (HTTPS) | **Accès ERP/Métier** : Accès à l'application métier centrale. La règle assure l'interdiction d'accès direct à la base de données. |
| **4** | 4 | `BLOCK` | Any | * | * | * | **Règle de Clôture** : Bloque tout autre trafic (Internet, Jump Server, autres VLANs, BDD) pour maintenir l'isolation de cette zone critique. |

## IT-PU

### Objets / Alias utilisés
* **DCMT** (Network) : `10.1.8.0/24` (Contrôleurs de Domaine)
* **JMPMT** (Network) : `10.1.4.0/24` (Serveur de Rebond)
* **APPMT** (Network) : `10.1.12.0/24` (Serveurs Applicatifs)
* **RFC1918_Private** (Network) : Ensemble des réseaux privés
* **AD_Auth_Port** (Ports) : `88`, `389`, `445` (Authentification AD)
* **SSH_RDP** (Ports) : `22`, `3389` (Administration distante)

### Synthèse des flux autorisés

| ID | Ordre | Action | Protocole | Source | Destination | Port | Description & Justification |
| :--- | :---: | :---: | :---: | :--- | :--- | :--- | :--- |
| **1** | 1 | `PASS` | TCP/UDP | `ITPU subnets` | **DCMT** | 53 (DNS) | **Résolution DNS** : Indispensable pour la navigation et la résolution des ressources internes. |
| **2** | 2 | `PASS` | TCP | `ITPU subnets` | **DCMT** | **AD_Auth_Port** | **Authentification** : Permet l'ouverture de session sur le domaine (Active Directory). |
| **3** | 3 | `PASS` | TCP | `ITPU subnets` | **JMPMT** | **SSH_RDP** | **Administration/Support** : Accès au Jump Server pour la maintenance des serveurs. |
| **4** | 4 | `PASS` | TCP | `ITPU subnets` | **APPMT** | 443 (HTTPS) | **Accès Applicatif** : Accès aux consoles web de supervision ou aux applications métier pour le support. |
| **5** | 5 | `PASS` | TCP/UDP | `ITPU subnets` | **! RFC1918_Private** | * (Any) | **Accès Internet** : Autorise l'accès WAN pour la recherche de documentation, drivers et outils. |
| **6** | 6 | `BLOCK** | Any | * | * | * | **Règle de Clôture** : Bloque tout autre trafic (y compris MGM-PU, BDD et autres VLANs de Production) pour respecter le principe de moindre privilège. |
