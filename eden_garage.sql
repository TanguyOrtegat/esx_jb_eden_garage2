ALTER TABLE `owned_vehicles` ADD `state` BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Etat de la voiture' AFTER `owner`;
ALTER TABLE `owned_vehicles` ADD `fourrieremecano` BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Voiture chez mecano' AFTER `state`;
