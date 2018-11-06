# esx_eden_garage
Garage privé basé sur ESX

Requirement : 
esx_vehicleshop
ft_libs (https://github.com/FivemTools/ft_libs)

Le garage prends en compte uniquement les véhicules achetés dans le concessionaire et aussi les véhicules qui sont dehors ou non.

features:

- renaming cars
- an exited vehicle can not be out again
- only ownled vehicles can be inside
- no vehicle duplication
- impound for police and mecano
- code optimisation with ft_libs
- ...

do not forget to update your sql:

```
ALTER TABLE `owned_vehicles` ADD INDEX `vehsowned` (`owner`);
ALTER TABLE `owned_vehicles` ADD `fourrieremecano` BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE `owned_vehicles` ADD `vehiclename` varchar(50) NOT NULL DEFAULT 'voiture';
```


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
