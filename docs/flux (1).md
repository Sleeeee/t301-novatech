# Diagramme de flux
# MAISON MÈRE (M)
## METIER
- source : VLAN METIER , destination : Proxy, Port (protocole) : 8888/TCP (HTTPS) , chiffré : oui µ
- source : Vlan METIER , destination : Proxy, Port (protocole) : 8888/TCP (HTTPS) , chiffré : oui 
- source : Vlan METIER , destination : Serveur Active Directory, Port (protocole) : 53/UDP (DNS), 88 TCP/UDP(Kerberos), 389/TCP (LDAP),636/TCP (LDAPS),135/TCP (RPC) ,445/TCP (SMB), 123/UDP (NTP), 68/UDP (DHCP)  chiffré : Kerberos, LDAPS, SMB Description : comprends tous les services AD
- source : Vlan METIER , destination : Printer , Port (protocole) : 9100/TCP (RAW) , chiffré : non , description : Accès Printer
- source : Vlan METIER, destination : CRM , Port (protocole) : 443/TCP (HTTPS) , chiffré : oui , description : Accès CRM
- source : Vlan METIER destination : ERP , Port (protocole) : 443/TCP (HTTPS) , chiffré : oui , description : Accès ERP
- source : Vlan METIER destination : Server WEB DMZ , Port (protocole) : 443/TCP (HTTPS) , chiffré : oui , description : Accès au serveur WEB vitrine et E-commerce
## USER ZONE (MU)
- source : VLAN MANAGEMENT-MU , destination : / , Port (protocole) : , chiffré : / , -----> RIEN
- ---
- source : VLAN ALARME-MU , destination : / , Port (protocole) : , chiffré : / , -----> RIEN
- ---
- source : VLAN PRINTER-MU , destination : / , Port (protocole) : , chiffré : / , -----> RIEN
- ---
- source : VLAN GUEST-MU , destination : Proxy, Port (protocole) : 8888/TCP (HTTPS) , chiffré : oui 
- ---
- source : VLAN CAMERA-MU , destination : SERVEUR NVR, Port (protocole) : 554/TCP/UDP (RSTP) , chiffré : oui 
- ---
- source : Vlan ADMIN-MU , destination : Jump Server , Port (protocole) : 22/TCP (SSH) , chiffré : oui , description : accès à aux jump server pour admin
- source : Vlan ADMIN-MU , destination : Serveur Monitoring , Port (protocole) : 443/TCP (HTTPS) , chiffré : oui, description accès à l'interface web d'un zabbix 
 -----
 - source : Vlan IT-MU , destination : Jump Server , Port (protocole) : 22/TCP (SSH) , chiffré : oui 
 ------
 - source : Vlan R&D-MU , destination : Server R&D , Port (protocole) : 22/TCP (SSH) , chiffré : oui 
----
## DMZ (MD)
- source : VLAN DNS-MD, destination : / , Port (protocole) : , chiffré : / , Description :  les DNS n'initient pas de communication 
- source : VLAN SWT-MD, destination : / , Port (protocole) : , chiffré : / , Description :  VLAN de management du switch dédié à la DMZ donc n'initie pas de communication
- source : FORWARD-MD, destination : Internet , Port (protocole) : 443 TCP (HTTPS) , chiffré : oui , Description :  autorise tout le trafic web à partir du proxy
- source : WFE-MD-01 , destination : RPS-MD01 , Port (protocole) : 443 TCP (HTTPS) , chiffré : oui , Description :  Transfert d'une requête extérieur du WAF du site E commerce vers le proxy
- source : WFV-MD-01 , destination : RPS-MD01 , Port (protocole) : 443 TCP (HTTPS) , chiffré : oui , Description :  Transfert d'une requête extérieur du WAF du site vitrine vers le proxy
- source : RPS-MD-01 , destination : Server WEB DMZ , Port (protocole) : 443 TCP (HTTPS) , chiffré : oui , Description :  Transfert d'une requête extérieur du proxy vers le site web vitrine ou E commerce
- source : WBE-MD-01 , destination : API-MT-01 , Port (protocole) : 443 TCP (HTTPS) , chiffré : oui , Description :  Demande du server web E commerce vers son serveur API
##THRUSTED
- source : Tous les servers de la Thrusted , destination : VLAN DC-MT , Port (protocole) : 123 UDP (NTP) , chiffré : non , Description :  Tous les serveurs se synchronisent à au serveur NTP du DC
- source : VLAN JMP-MT , destination : interfaces de gestion , Port (protocole) : 22 TCP (SSH) , chiffré : oui , Description :  Demande du server web E commerce vers son serveur 
- source : Vlan JMP-MT , destination : Serveur Monitoring , Port (protocole) : 443/TCP (HTTPS) , chiffré : oui, description accès à l'interface web d'un zabbix 
- source : Vlan JMP-MT , destination : VLAN-Métier , Port (protocole) : 3389/TCP (RDP) , chiffré : Support utilisateur depuis le jump serveur en remote.
- source : Vlan JMP-MT , destination : VLAN IOT , Port (protocole) : 8000/TCP (HTTP) , chiffré : configuration IOT
- source : Vlan JMP-MT , destination : Proxmox , Port (protocole) : 8006/TCP (HTTP) , chiffré : Configuration des proxmox






