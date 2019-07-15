USE `essentialmode`;

ALTER TABLE `owned_vehicles`
	ADD `state` BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Etat de la voiture' AFTER `owner`,
	ADD `fourrieremecano` BOOLEAN NOT NULL DEFAULT FALSE,
	ADD `vehiclename` varchar(50) NOT NULL DEFAULT 'voiture',
	ADD INDEX `index_owned_vehicles_owner` (`owner`)
;