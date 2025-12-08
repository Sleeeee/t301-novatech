# Description et justification de l'infrastructure

## Site web vitrine

Un site vitrine n'a typiquement pas besoin de communiquer avec un backend. Nous avons donc simplement placé le serveur web `WBV-MD-01` dans la DMZ, qui répondra uniquement aux demandes du reverse proxy.

## Site web e-commerce

Comme une application web standard, nous avons placé le serveur web derrière le reverse proxy.

Nous avons évoqué la possibilité de dupliquer nos serveurs web et d'ajouter des mécanismes favorisant le scaling, comme un load balancer ou une message queue par exemple. Bien que cela reste une option pour le futur, étant donné le trafic limité que les serveurs devraient écouler, nous avons éviter de surcompliquer l'architecture pour le plaisir.
