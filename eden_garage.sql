ALTER TABLE `owned_vehicles` ADD `state` BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Etat de la voiture' AFTER `owner`;
ALTER TABLE `owned_vehicles` ADD INDEX `vehsowned` (`owner`);
ALTER TABLE `owned_vehicles` ADD `fourrieremecano` BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE `owned_vehicles` ADD `vehiclename` varchar(50) NOT NULL DEFAULT 'voiture';
