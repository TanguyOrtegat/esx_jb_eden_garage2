# esx_jb_eden_garage
 Private garage system based on ESX


 Requirement :
 esx_vehicleshop		or fxserver-esx_vehicleshop / ft_libs (https://github.com/FivemTools/ft_libs)

  features:


 - renaming cars
 - an exited vehicle can not be out again
 - only ownled vehicles can be inside
 - no vehicle duplication
 - impound for police and mecano
 - code optimisation with ft_libs
 - fix glitch with cheat engine
 - ...


 ```sql
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

 #UPDATE

becasue people are not devs and they don't know how sql work ... insert these lines seperatly. look at what column you already have and which not, insert the colums you haven't:
```sql
ALTER TABLE owned_vehicle add plate varchar(50) NOT NULL;
ALTER TABLE `owned_vehicles` ADD INDEX `vehsowned` (`owner`);
ALTER TABLE `owned_vehicles` ADD `fourrieremecano` BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE `owned_vehicles` ADD `vehiclename` varchar(50) NOT NULL DEFAULT 'voiture';
```
and run this script once if you haven't plate column:
https://github.com/TanguyOrtegat/esx_jb_migrate

 with command migrate

 #UPDATE 25/08
 ```sql
alter table owned_vehicles add vehicle_type varchar(10) not null default 'car'
alter table owned_vehicles add garage_name varchar(50) not null default 'Garage_Centre'
```
pay attention that you will need to edit your airplane dealer and boatdealer to put it in that table owned_vehicles and in where clause in SQL: where vehicle_type='boat' (for example)