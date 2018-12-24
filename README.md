 Garage privé basé sur ESX	 Garage privé basé sur ESX
 
  
  Requirement : 	 Requirement : 
 esx_vehicleshop	 fxserver-esx_vehicleshop
 ft_libs (https://github.com/FivemTools/ft_libs)	
 
  
  Le garage prends en compte uniquement les véhicules achetés dans le concessionaire et aussi les véhicules qui sont dehors ou non.	 Le garage prends en compte uniquement les véhicules achetés dans le concessionaire et aussi les véhicules qui sont dehors ou non.
 Lors d'un reboot tous les véhicules passe en rentré.
 
  
  features:	 1) Il faut appliquer le SQL
 2) Mettre la resource dans votre server.cfg
 3) Modifier la config pour ajouter garage ou modifier
 
  
  - renaming cars	 BUG CONNU :
 - an exited vehicle can not be out again	
 - only ownled vehicles can be inside	
 - no vehicle duplication	
 - impound for police and mecano	
 - code optimisation with ft_libs	
 - ...	
 
  
  
 ```
 ALTER TABLE `owned_vehicles` ADD INDEX `vehsowned` (`owner`);	
 ALTER TABLE `owned_vehicles` ADD `fourrieremecano` BOOLEAN NOT NULL DEFAULT FALSE;	
 ALTER TABLE `owned_vehicles` ADD `vehiclename` varchar(50) NOT NULL DEFAULT 'voiture';	
 ```	
 
  
 Fonctionnement :
 Le cercle jaune pour sortir / rentrer vehicule / recuperer vehicule ( en cas de depop de celui ci )
 Pour rntrer un vehicule, le mettre dans le rond rouge puis aller dans le rond jaune et faire rentrer vehicule
  
if you want the impound of police and mecano to work, paste those lines when you take your duty:	

```	  	
exports.ft_libs:EnableArea("esx_eden_garage_area_police_mecanodeletepoint")	
exports.ft_libs:EnableArea("esx_eden_garage_area_police_mecanospawnpoint")	  	
exports.ft_libs:EnableArea("esx_eden_garage_area_Bennys_mecanodeletepoint")	
exports.ft_libs:EnableArea("esx_eden_garage_area_Bennys_mecanospawnpoint")	
```	

and offduty:	
```	
exports.ft_libs:DisableArea("esx_eden_garage_area_police_mecanodeletepoint")	
exports.ft_libs:DisableArea("esx_eden_garage_area_police_mecanospawnpoint")	  	
exports.ft_libs:DisableArea("esx_eden_garage_area_Bennys_mecanodeletepoint")	
exports.ft_libs:DisableArea("esx_eden_garage_area_Bennys_mecanospawnpoint")	
```
 
#UPDATE
if you haven't plate column:
```
ALTER TABLE owned_vehicle add plate varchar(50) NOT NULL;
```
and run this script once:
https://github.com/TanguyOrtegat/esx_jb_migrate

whith command migrate
