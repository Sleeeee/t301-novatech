# Documentation des Tests de Sécurité Réseau - NovaTech

**Date des tests :** 11 décembre 2025  

**Testeur :** Groupe N°9 dans le cadre du projet Novatech 

**Équipements testés :** SL2-PU-01, SL2-PU-02

---

## 1. Topologie de Test

<img width="862" height="776" alt="image" src="https://github.com/user-attachments/assets/bd76d863-dcf3-4df3-bb55-824270eec2f2" />


**Machine attaquante :** RED-1 (10.16.8.100 - MAC: 0242.e2a5.7400) - VLAN 1608 (IT-PU)  
**Machine cible :** IT-PU (10.16.8.20 - MAC: 0242.ebc3.4100) - VLAN 1608 (IT-PU)

---

## 2. Sécurités Implémentées sur les Switches

### Configuration de sécurité par port access

| Sécurité | Commande | Protection contre |
|----------|----------|-------------------|
| Port Security | `switchport port-security` | MAC Flooding |
| BPDU Guard | `spanning-tree bpduguard enable` | STP Exploit |
| Root Guard | `spanning-tree guard root` | STP Root Takeover |
| PortFast | `spanning-tree portfast edge` | Délai STP |
| DTP désactivé | `switchport nonegotiate` | VLAN Hopping |
| Mode Access | `switchport mode access` | DTP Exploit |
| DHCP Rate Limit | `ip dhcp snooping limit rate 5` | DHCP Flooding |

### Configuration globale

| Sécurité | Commande | Protection contre |
|----------|----------|-------------------|
| DHCP Snooping | `ip dhcp snooping vlan X` | Rogue DHCP, DHCP Starvation |
| DAI | `ip arp inspection vlan X` | ARP Poisoning |
| CDP désactivé | `no cdp run` | CDP Flooding, Information Disclosure |
| Native VLAN | `switchport trunk native vlan 1699` | VLAN Hopping |

### Configuration du port de test (Gi2/0 sur SL2-PU-01)

```cisco
interface GigabitEthernet2/0
 description RED-TEST
 switchport access vlan 1608
 switchport mode access
 switchport nonegotiate
 switchport port-security
 spanning-tree portfast edge
 spanning-tree bpduguard enable
 spanning-tree guard root
 ip dhcp snooping limit rate 5
```

---

## 3. Tests d'Attaques et Résultats

### Test 1 : ARP Cache Poisoning (arpspoof)

**Objectif :** Vérifier que DAI bloque les tentatives d'empoisonnement de cache ARP

**Outil utilisé :** arpspoof 

**Commande d'attaque :**
```bash
arpspoof -i eth0 -t 10.16.8.20 10.16.8.254
```

**Preuve de l'attaque (RED-1) :**
```
root@RED-1:~# arpspoof -i eth0 -t 10.16.8.20 10.16.8.254
2:42:e2:a5:74:0 2:42:eb:c3:41:0 0806 42: arp reply 10.16.8.254 is-at 2:42:e2:a5:74:0
2:42:e2:a5:74:0 2:42:eb:c3:41:0 0806 42: arp reply 10.16.8.254 is-at 2:42:e2:a5:74:0
2:42:e2:a5:74:0 2:42:eb:c3:41:0 0806 42: arp reply 10.16.8.254 is-at 2:42:e2:a5:74:0
2:42:e2:a5:74:0 2:42:eb:c3:41:0 0806 42: arp reply 10.16.8.254 is-at 2:42:e2:a5:74:0
2:42:e2:a5:74:0 2:42:eb:c3:41:0 0806 42: arp reply 10.16.8.254 is-at 2:42:e2:a5:74:0
2:42:e2:a5:74:0 2:42:eb:c3:41:0 0806 42: arp reply 10.16.8.254 is-at 2:42:e2:a5:74:0
2:42:e2:a5:74:0 2:42:eb:c3:41:0 0806 42: arp reply 10.16.8.254 is-at 2:42:e2:a5:74:0
2:42:e2:a5:74:0 2:42:eb:c3:41:0 0806 42: arp reply 10.16.8.254 is-at 2:42:e2:a5:74:0
^CCleaning up and re-arping targets...
```

**Statistiques AVANT l'attaque (SL2-PU-01) :**
```
SL2-PU-01#show ip arp inspection statistics vlan 1608
 Vlan      Forwarded        Dropped     DHCP Drops      ACL Drops
 ----      ---------        -------     ----------      ---------
 1608             85             16             16              0
```

**Statistiques APRÈS l'attaque (SL2-PU-01) :**
```
SL2-PU-01#show ip arp inspection statistics vlan 1608
 Vlan      Forwarded        Dropped     DHCP Drops      ACL Drops
 ----      ---------        -------     ----------      ---------
 1608            151             33             33              0
```

**Résultat :** **BLOQUÉ par DAI**  
- Paquets ARP malveillants droppés : **+17**
- L'attaque ARP Poisoning a été détectée et bloquée par DAI
- Les paquets forgés (usurpant 10.16.8.254) ne correspondaient pas aux entrées autorisées
- **Le port n'a PAS été mis en err-disabled** car la vraie MAC de RED-1 était utilisée

---

### Test 2 : MAC Address Flooding (macof)

**Objectif :** Vérifier que Port Security bloque l'inondation d'adresses MAC

**Outil utilisé :** macof

**Commande d'attaque :**
```bash
macof -i eth0
```

**Preuve de l'attaque (RED-1) :**
```
root@RED-1:~# macof -i eth0
55:75:a5:35:c1:d3 3d:4c:7d:65:e9:8b 0.0.0.0.65364 > 0.0.0.0.45905: S 329959872:329959872(0) win 512
ce:54:40:2c:cd:f5 35:e:32:6:d0:21 0.0.0.0.26723 > 0.0.0.0.2070: S 122980179:122980179(0) win 512
8e:61:de:7c:ee:da 8f:7e:be:42:ff:67 0.0.0.0.48306 > 0.0.0.0.47865: S 328473803:328473803(0) win 512
10:75:ef:1c:59:db ee:fd:bd:43:b9:c3 0.0.0.0.14805 > 0.0.0.0.59032: S 157766848:157766848(0) win 512
52:80:87:7:36:df 98:84:76:8:40:9c 0.0.0.0.9303 > 0.0.0.0.59753: S 606304753:606304753(0) win 512
[...]
^C
```

**État AVANT l'attaque (SL2-PU-01) :**
```
SL2-PU-01#show port-security interface Gi2/0
Port Security              : Enabled
Port Status                : Secure-up
Violation Mode             : Shutdown
Aging Time                 : 0 mins
Aging Type                 : Absolute
SecureStatic Address Aging : Disabled
Maximum MAC Addresses      : 1
Total MAC Addresses        : 1
Configured MAC Addresses   : 0
Sticky MAC Addresses       : 0
Last Source Address:Vlan   : 0242.e2a5.7400:1608
Security Violation Count   : 0

SL2-PU-01#show port-security
Secure Port  MaxSecureAddr  CurrentAddr  SecurityViolation  Security Action
                (Count)       (Count)          (Count)
---------------------------------------------------------------------------
      Gi2/0              1            1                  0         Shutdown
```

**État APRÈS l'attaque (SL2-PU-01) :**
```
SL2-PU-01#show port-security interface Gi2/0
Port Security              : Enabled
Port Status                : Secure-shutdown
Violation Mode             : Shutdown
Aging Time                 : 0 mins
Aging Type                 : Absolute
SecureStatic Address Aging : Disabled
Maximum MAC Addresses      : 1
Total MAC Addresses        : 0
Configured MAC Addresses   : 0
Sticky MAC Addresses       : 0
Last Source Address:Vlan   : 3110.2e27.6d20:1608
Security Violation Count   : 1

SL2-PU-01#show port-security                
Secure Port  MaxSecureAddr  CurrentAddr  SecurityViolation  Security Action
                (Count)       (Count)          (Count)
---------------------------------------------------------------------------
      Gi2/0              1            0                  1         Shutdown
```

**Résultat :**  **BLOQUÉ par Port Security**  
- Port Status : **Secure-shutdown**
- Security Violation Count : **1**
- Last Source Address : **3110.2e27.6d20** (MAC aléatoire de macof)
- **Le port a été mis en err-disabled par le Port Security**

---

### Test 3 : DHCP Starvation (yersinia)

**Objectif :** Vérifier que DHCP Snooping bloque l'épuisement du pool DHCP

**Outil utilisé :** yersinia

**Commande d'attaque :**
```bash
yersinia dhcp -attack 1 -interface eth0
```

**Preuve de l'attaque (RED-1) :**
```
root@RED-1:~# yersinia dhcp -attack 1 -interface eth0
<*> Starting DOS attack sending DISCOVER packet...
<*> Press any key to stop the attack <*>
MOTD: Having lotto fun with my Denon AVC-A11XVA... :)
```

**État AVANT l'attaque (SL2-PU-01) :**
```
SL2-PU-01#show ip dhcp snooping statistics
 Packets Forwarded                                     = 0
 Packets Dropped                                       = 0
 Packets Dropped From untrusted ports                  = 0

SL2-PU-01#show port-security interface Gi2/0
Port Security              : Enabled
Port Status                : Secure-up
Violation Mode             : Shutdown
Maximum MAC Addresses      : 1
Security Violation Count   : 2
```

**État APRÈS l'attaque (SL2-PU-01) :**
```
SL2-PU-01#show ip dhcp snooping statistics
 Packets Forwarded                                     = 4
 Packets Dropped                                       = 72
 Packets Dropped From untrusted ports                  = 0

SL2-PU-01#show port-security interface Gi2/0
Port Security              : Enabled
Port Status                : Secure-shutdown
Violation Mode             : Shutdown
Maximum MAC Addresses      : 1
Security Violation Count   : 3
Last Source Address:Vlan   : 40c7.5302.20f5:1608

SL2-PU-01#show interfaces Gi2/0 status
Port      Name               Status       Vlan       Duplex  Speed Type 
Gi2/0     RED-TEST           err-disabled 1608         auto   auto RJ45
```

**Résultat :**  **BLOQUÉ par DHCP Snooping + Port Security**  
- DHCP Snooping : **72 paquets droppés**
- Port Security : Violation détectée (MAC aléatoire **40c7.5302.20f5**)
- **Le port a été mis en err-disabled par Port Security**

---

### Test 4 : STP Attack (yersinia)

**Objectif :** Vérifier que BPDU Guard bloque les tentatives de manipulation STP

**Outil utilisé :** yersinia

**Commande d'attaque :**
```bash
yersinia stp -attack 4 -interface eth0
```

**Preuve de l'attaque (RED-1) :**
```
root@RED-1:~# yersinia stp -attack 4 -interface eth0
<*> Starting NONDOS attack Claiming Root Role...
<*> Press any key to stop the attack <*>
MOTD: Yersiiiiiiiiiiiniaaaa, you're breaking my heart!! - S&G (c) -
```

**État AVANT l'attaque (SL2-PU-01) :**
```
SL2-PU-01#show spanning-tree vlan 1608
VLAN1608
  Spanning tree enabled protocol ieee
  Root ID    Priority    34376
             Address     0cfa.b4a8.0000
             Cost        4
             Port        16 (GigabitEthernet3/3)
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec

  Bridge ID  Priority    34376  (priority 32768 sys-id-ext 1608)
             Address     0cfe.791b.0000

Interface           Role Sts Cost      Prio.Nbr Type
------------------- ---- --- --------- -------- --------------------------------
Gi0/0               Desg FWD 4         128.1    P2p 
Gi2/0               Desg FWD 4         128.9    P2p Edge 
Gi3/3               Root FWD 4         128.16   P2p 
```

**État APRÈS l'attaque (SL2-PU-01) :**
```
SL2-PU-01#show spanning-tree vlan 1608
VLAN1608
  Spanning tree enabled protocol ieee
  Root ID    Priority    34376
             Address     0cfa.b4a8.0000      <<< ROOT BRIDGE INCHANGÉ
             Cost        4
             Port        16 (GigabitEthernet3/3)

Interface           Role Sts Cost      Prio.Nbr Type
------------------- ---- --- --------- -------- --------------------------------
Gi0/0               Desg FWD 4         128.1    P2p 
Gi3/3               Root FWD 4         128.16   P2p 

SL2-PU-01#show interfaces Gi2/0 status
Port      Name               Status       Vlan       Duplex  Speed Type 
Gi2/0     RED-TEST           err-disabled 1608         auto   auto RJ45

SL2-PU-01#show logging | include Gi2/0
*Dec 11 11:33:19.673: %SPANTREE-2-BLOCK_BPDUGUARD: Received BPDU on port Gi2/0 with BPDU Guard enabled. Disabling port.
*Dec 11 11:33:19.673: %PM-4-ERR_DISABLE: bpduguard error detected on Gi2/0, putting Gi2/0 in err-disable state
```

**Résultat :**  **BLOQUÉ par BPDU Guard**  
- Root Bridge : **Identique** (toujours 0cfa.b4a8.0000)
- Log : `SPANTREE-2-BLOCK_BPDUGUARD: Received BPDU on port Gi2/0 with BPDU Guard enabled`
- **Le port a été mis en err-disabled par BPDU Guard** 

---

### Test 5 : DTP (yersinia)

**Objectif :** Vérifier que `switchport nonegotiate` bloque les tentatives de négociation trunk

**Outil utilisé :** yersinia

**Commande d'attaque :**
```bash
yersinia dtp -attack 1 -interface eth0
```

**Preuve de l'attaque (RED-1) :**
```
root@RED-1:~# yersinia dtp -attack 1 -interface eth0
<*> Starting NONDOS attack enabling trunking...
<*> Press any key to stop the attack <*>
MOTD: I would like to see romanian wild boars, could you invite me? :)
```

**État AVANT l'attaque (SL2-PU-01) :**
```
SL2-PU-01#show interfaces Gi2/0 switchport
Name: Gi2/0
Switchport: Enabled
Administrative Mode: static access
Operational Mode: static access
Administrative Trunking Encapsulation: negotiate
Operational Trunking Encapsulation: native
Negotiation of Trunking: Off
Access Mode VLAN: 1608 (IT-PU)
Trunking Native Mode VLAN: 1 (default)
```

**État APRÈS l'attaque (SL2-PU-01) :**
```
SL2-PU-01#show interfaces Gi2/0 switchport
Name: Gi2/0
Switchport: Enabled
Administrative Mode: static access
Operational Mode: down
Negotiation of Trunking: Off           <<< TOUJOURS OFF
Access Mode VLAN: 1608 (IT-PU)

SL2-PU-01#show interfaces Gi2/0 status
Port      Name               Status       Vlan       Duplex  Speed Type 
Gi2/0     RED-TEST           err-disabled 1608         auto   auto RJ45

SL2-PU-01#show logging | include Gi2/0
*Dec 11 11:36:12.540: %PM-4-ERR_DISABLE: psecure-violation error detected on Gi2/0, putting Gi2/0 in err-disable state
```

**Résultat :**  **BLOQUÉ par `nonegotiate` + Port Security**  
- `Negotiation of Trunking: Off` - Le port reste en mode **static access**
- L'attaquant n'a **PAS réussi** à passer le port en mode trunk
- **Le port a été mis en err-disabled par Port Security**

---

### Test 6 : CDP Flooding (yersinia)

**Objectif :** Vérifier que `no cdp run` empêche les attaques CDP

**Outil utilisé :** yersinia

**Commande d'attaque :**
```bash
yersinia cdp -attack 1 -interface eth0
```

**Preuve de l'attaque (RED-1) :**
```
root@RED-1:~# yersinia cdp -attack 1 -interface eth0
<*> Starting DOS attack flooding CDP table...
<*> Press any key to stop the attack <*>
MOTD: Don't do it!! Don't do it!! Don't do it!!
	(Please DO IT)
```

**État AVANT l'attaque (SL2-PU-01) :**
```
SL2-PU-01#show cdp
% CDP is not enabled

SL2-PU-01#show cdp neighbors
% CDP is not enabled
```

**État APRÈS l'attaque (SL2-PU-01) :**
```
SL2-PU-01#show cdp
% CDP is not enabled

SL2-PU-01#show cdp neighbors
% CDP is not enabled

SL2-PU-01#show interfaces Gi2/0 status
Port      Name               Status       Vlan       Duplex  Speed Type 
Gi2/0     RED-TEST           err-disabled 1608         auto   auto RJ45
```

**Résultat :**  **BLOQUÉ par `no cdp run` + Port Security**  
- CDP : **Complètement désactivé** - Tous les paquets CDP sont ignorés
- Aucun voisin CDP ne peut être appris ou forgé
- **Le port a été mis en err-disabled par Port Security** 

---

### Analyse des causes de err-disabled

Dans la majorité des tests, c'est **Port Security** qui met le port en err-disabled car les outils d'attaque (yersinia, macof) utilisent des adresses MAC aléatoires/forgées.

Seul le **Test 4 (STP Attack)** a été bloqué directement par **BPDU Guard** car yersinia envoie des BPDU, ce qui déclenche immédiatement la protection STP.

---

## 4. Conclusion

Toutes les protections de sécurité Layer 2 implémentées sur les switches SL2-PU-01 et SL2-PU-02 sont **fonctionnelles et efficaces**. Les 6 types d'attaques testées ont été bloquées avec succès :

- **DAI** protège contre l'ARP Poisoning
- **Port Security** protège contre le MAC Flooding et agit comme protection supplémentaire
- **DHCP Snooping** protège contre le DHCP Starvation et les Rogue DHCP
- **BPDU Guard** protège contre les attaques STP
- **`switchport nonegotiate`** protège contre le VLAN Hopping via DTP
- **`no cdp run`** élimine les risques liés au protocole CDP

La configuration actuelle respecte les bonnes pratiques de sécurité réseau et offre une défense en profondeur contre les attaques Layer 2.

---
