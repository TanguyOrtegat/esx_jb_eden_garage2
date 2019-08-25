-- phpMyAdmin SQL Dump
-- version 4.8.4
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Gegenereerd op: 17 aug 2019 om 12:12
-- Serverversie: 5.7.24
-- PHP-versie: 7.2.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `essentialmode`
--

-- --------------------------------------------------------

--
-- Tabelstructuur voor tabel `owned_vehicles`
--

DROP TABLE IF EXISTS `owned_vehicles`;
CREATE TABLE IF NOT EXISTS `owned_vehicles` (
  `vehicle` longtext NOT NULL,
  `owner` varchar(60) NOT NULL,
  `state` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Etat de la voiture',
  `garage_name` varchar(50) NOT NULL DEFAULT 'Garage_Centre',
  `fourrieremecano` tinyint(1) NOT NULL DEFAULT '0',
  `vehiclename` varchar(50) NOT NULL DEFAULT 'voiture',
  `plate` varchar(50) NOT NULL,
  `vehicle_type` varchar(10) NOT NULL DEFAULT 'car',
  PRIMARY KEY (`plate`),
  KEY `vehsowned` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
