# Diagramme de flux
# MAISON MÈRE (M)
## USER ZONE (MU)
- source : VLAN MANAGEMENT , destination : / , Port (protocole) : , chiffré : / , -----> RIEN
- source : Vlan Admin , destination : Jump Server , Port (protocole) : 22/TCP (SSH) , chiffré : oui 
- source : Vlan Admin , destination : Proxy, Port (protocole) : 8888/TCP (HTTPS) , chiffré : oui 
- source : Vlan Admin , destination : Serveur Monitoring , Port (protocole) : 443/TCP (HTTPS) , chiffré : oui, description accès à l'interface web d'un zabbix 


