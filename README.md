# esx_jb_eden_garage
 Garage privé basé sur ESX	



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

 #UPDATE	

 if you haven't plate column:	
```	
ALTER TABLE owned_vehicle add plate varchar(50) NOT NULL;	
ALTER TABLE `owned_vehicles` ADD INDEX `vehsowned` (`owner`);
ALTER TABLE `owned_vehicles` ADD `fourrieremecano` BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE `owned_vehicles` ADD `vehiclename` varchar(50) NOT NULL DEFAULT 'voiture';
```	
and run this script once:	
https://github.com/TanguyOrtegat/esx_jb_migrate	

 whith command migrate
