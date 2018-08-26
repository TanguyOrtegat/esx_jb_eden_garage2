# esx_eden_garage
Garage privé basé sur ESX

Requirement : 
fxserver-esx_vehicleshop

Le garage prends en compte uniquement les véhicules achetés dans le concessionaire et aussi les véhicules qui sont dehors ou non.
Lors d'un reboot tous les véhicules passe en rentré.

1) Il faut appliquer le SQL
2) Mettre la resource dans votre server.cfg
3) Modifier la config pour ajouter garage ou modifier

BUG CONNU :

- Certains véhicules sont impossible à rentrer
- En cherchant bien il est possible de dupliquer les véhicules

Nous travaillons dessus. 

Fonctionnement :
Le cercle jaune pour sortir / rentrer vehicule / recuperer vehicule ( en cas de depop de celui ci )
Pour rntrer un vehicule, le mettre dans le rond rouge puis aller dans le rond jaune et faire rentrer vehicule

