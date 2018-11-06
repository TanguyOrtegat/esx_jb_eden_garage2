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

if you want the impound of police and mecano to work, paste those lines when you take your duty:

```	  
exports.ft_libs:EnableArea("esx_eden_garage_area_police_mecanodeletepoint")
	  exports.ft_libs:EnableArea("esx_eden_garage_area_police_mecanospawnpoint")	  
	  exports.ft_libs:EnableArea("esx_eden_garage_area_Bennys_mecanodeletepoint")
	  exports.ft_libs:EnableArea("esx_eden_garage_area_Bennys_mecanospawnpoint")
```
