-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: localhost    Database: pet_shelter_2
-- ------------------------------------------------------
-- Server version	9.2.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `admin`
--

DROP TABLE IF EXISTS `admin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin` (
  `AdminID` int NOT NULL AUTO_INCREMENT,
  `FirstName` varchar(50) NOT NULL,
  `LastName` varchar(50) NOT NULL,
  `Email` varchar(100) NOT NULL,
  `PasswordHash` varchar(255) NOT NULL,
  `ShelterID` int NOT NULL,
  PRIMARY KEY (`AdminID`),
  UNIQUE KEY `Email` (`Email`),
  KEY `ShelterID` (`ShelterID`),
  CONSTRAINT `admin_ibfk_1` FOREIGN KEY (`ShelterID`) REFERENCES `shelter` (`ShelterID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin`
--

LOCK TABLES `admin` WRITE;
/*!40000 ALTER TABLE `admin` DISABLE KEYS */;
INSERT INTO `admin` VALUES (1,'Admin','User','admin@petshelter.com','hashed_password_here',1),(2,'John','Doe','john.doe@shelter.com','hashed_password_1',1),(3,'Jane','Smith','jane.smith@shelter.com','hashed_password_2',1);
/*!40000 ALTER TABLE `admin` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `adopter`
--

DROP TABLE IF EXISTS `adopter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `adopter` (
  `AdopterID` int NOT NULL AUTO_INCREMENT,
  `EncryptedSSN` varbinary(255) NOT NULL,
  `FirstName` varchar(50) NOT NULL,
  `LastName` varchar(50) NOT NULL,
  `Email` varchar(100) NOT NULL,
  `Phone` varchar(15) NOT NULL,
  `Address` varchar(200) NOT NULL,
  `RegistrationDate` date DEFAULT (curdate()),
  `EncryptionKeyVersion` int DEFAULT '1',
  `IV` varbinary(16) DEFAULT NULL,
  `PasswordHash` varchar(255) NOT NULL,
  PRIMARY KEY (`AdopterID`),
  UNIQUE KEY `Email` (`Email`),
  KEY `idx_encrypted_ssn` (`EncryptedSSN`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `adopter`
--

LOCK TABLES `adopter` WRITE;
/*!40000 ALTER TABLE `adopter` DISABLE KEYS */;
/*!40000 ALTER TABLE `adopter` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `prevent_duplicate_adopter_email` BEFORE INSERT ON `adopter` FOR EACH ROW BEGIN
    IF EmailExists(NEW.Email) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Email already exists in system';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Temporary view structure for view `adopterhistory`
--

DROP TABLE IF EXISTS `adopterhistory`;
/*!50001 DROP VIEW IF EXISTS `adopterhistory`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `adopterhistory` AS SELECT 
 1 AS `AdopterID`,
 1 AS `PetID`,
 1 AS `Pet_name`,
 1 AS `App_Status`,
 1 AS `meetUp_Status`,
 1 AS `Meet_DateTime`,
 1 AS `AdoptionStatus`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `application`
--

DROP TABLE IF EXISTS `application`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `application` (
  `ApplicationID` int NOT NULL AUTO_INCREMENT,
  `AdopterID` int NOT NULL,
  `PetID` int NOT NULL,
  `EmailID` varchar(100) DEFAULT NULL,
  `ApplicationDate` datetime DEFAULT CURRENT_TIMESTAMP,
  `DOB` date NOT NULL,
  `ResidenceType` enum('Apartment','House','Condo','Other') NOT NULL,
  `OtherPets` tinyint(1) NOT NULL,
  `AdoptionReason` text NOT NULL,
  `PreviouslyAdopted` tinyint(1) NOT NULL,
  `PrimaryCaregiver` varchar(100) NOT NULL,
  `EmergencyContact` varchar(15) NOT NULL,
  `MeetupPreference` text,
  `AnnualIncome` decimal(10,2) NOT NULL,
  `App_Status` enum('Pending','Approved','Rejected','Withdrawn') DEFAULT 'Pending',
  `StaffNotes` text,
  `ProcessedByAdminID` int DEFAULT NULL,
  `ApprovalDate` datetime DEFAULT NULL,
  `RejectionReason` text,
  `Age` int DEFAULT NULL,
  PRIMARY KEY (`ApplicationID`),
  KEY `AdopterID` (`AdopterID`),
  KEY `PetID` (`PetID`),
  KEY `ProcessedByAdminID` (`ProcessedByAdminID`),
  CONSTRAINT `application_ibfk_1` FOREIGN KEY (`AdopterID`) REFERENCES `adopter` (`AdopterID`),
  CONSTRAINT `application_ibfk_2` FOREIGN KEY (`PetID`) REFERENCES `pet` (`PetID`),
  CONSTRAINT `application_ibfk_3` FOREIGN KEY (`ProcessedByAdminID`) REFERENCES `admin` (`AdminID`),
  CONSTRAINT `application_chk_1` CHECK ((((`App_Status` = _utf8mb4'Approved') and (`ApprovalDate` is not null)) or ((`App_Status` <> _utf8mb4'Approved') and (`ApprovalDate` is null))))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `application`
--

LOCK TABLES `application` WRITE;
/*!40000 ALTER TABLE `application` DISABLE KEYS */;
/*!40000 ALTER TABLE `application` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_application_status_change` AFTER UPDATE ON `application` FOR EACH ROW BEGIN
    IF OLD.App_Status != NEW.App_Status THEN
        INSERT INTO ApplicationHistory (
            ApplicationID,
            App_Status,
            ChangedByStaffID,
            Notes
        ) VALUES (
            NEW.ApplicationID,
            NEW.App_Status,
            NEW.ProcessedByAdminID,
            NEW.StaffNotes
        );
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_application_approval` AFTER UPDATE ON `application` FOR EACH ROW BEGIN
    IF NEW.App_Status = 'Approved' AND OLD.App_Status != 'Approved' THEN
        UPDATE Pet
        SET AdoptionStatus = 'Pending'
        WHERE PetID = NEW.PetID;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `applicationhistory`
--

DROP TABLE IF EXISTS `applicationhistory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `applicationhistory` (
  `HistoryID` int NOT NULL AUTO_INCREMENT,
  `ApplicationID` int NOT NULL,
  `App_Status` enum('Pending','Approved','Rejected','Withdrawn') NOT NULL,
  `ChangeDate` datetime DEFAULT CURRENT_TIMESTAMP,
  `Notes` text,
  PRIMARY KEY (`HistoryID`),
  KEY `ApplicationID` (`ApplicationID`),
  CONSTRAINT `applicationhistory_ibfk_1` FOREIGN KEY (`ApplicationID`) REFERENCES `application` (`ApplicationID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `applicationhistory`
--

LOCK TABLES `applicationhistory` WRITE;
/*!40000 ALTER TABLE `applicationhistory` DISABLE KEYS */;
/*!40000 ALTER TABLE `applicationhistory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `blog`
--

DROP TABLE IF EXISTS `blog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `blog` (
  `BlogID` int NOT NULL AUTO_INCREMENT,
  `Title` varchar(255) NOT NULL,
  `Content` text NOT NULL,
  `AdminID` int NOT NULL,
  `PublishDate` datetime DEFAULT CURRENT_TIMESTAMP,
  `IsPublished` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`BlogID`),
  KEY `AdminID` (`AdminID`),
  CONSTRAINT `blog_ibfk_1` FOREIGN KEY (`AdminID`) REFERENCES `admin` (`AdminID`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blog`
--

LOCK TABLES `blog` WRITE;
/*!40000 ALTER TABLE `blog` DISABLE KEYS */;
INSERT INTO `blog` VALUES (1,'Adoption Success Stories','Read our heartwarming adoption stories...',1,'2025-04-18 02:40:06',1),(2,'Pet Care Tips','Essential tips for new pet owners...',1,'2025-04-18 02:40:06',0);
/*!40000 ALTER TABLE `blog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `encryptionkeys`
--

DROP TABLE IF EXISTS `encryptionkeys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `encryptionkeys` (
  `KeyID` int NOT NULL AUTO_INCREMENT,
  `KeyVersion` int NOT NULL,
  `KeyValue` varbinary(255) NOT NULL,
  `CreatedAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `IsActive` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`KeyID`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `encryptionkeys`
--

LOCK TABLES `encryptionkeys` WRITE;
/*!40000 ALTER TABLE `encryptionkeys` DISABLE KEYS */;
INSERT INTO `encryptionkeys` VALUES (1,1,_binary '4P\×Ar\Õk\Zg{o²+»á¶¸\\¢–ó\àE£\"\Ù\È\È56k\ÊW—bM}2¦\èù\ä\ÆuTn\\T¾Dó9C4','2025-04-18 02:40:03',1);
/*!40000 ALTER TABLE `encryptionkeys` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `healthrecord`
--

DROP TABLE IF EXISTS `healthrecord`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `healthrecord` (
  `RecordID` int NOT NULL AUTO_INCREMENT,
  `PetID` int NOT NULL,
  `Vaccinations` json DEFAULT NULL,
  `MedicalHistory` text,
  `LastCheckup` date DEFAULT NULL,
  PRIMARY KEY (`RecordID`),
  UNIQUE KEY `PetID` (`PetID`),
  CONSTRAINT `healthrecord_ibfk_1` FOREIGN KEY (`PetID`) REFERENCES `pet` (`PetID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `healthrecord`
--

LOCK TABLES `healthrecord` WRITE;
/*!40000 ALTER TABLE `healthrecord` DISABLE KEYS */;
INSERT INTO `healthrecord` VALUES (1,1,'[\"Rabies\", \"Distemper\"]','Healthy weight, no issues','2024-03-15'),(2,2,'[\"FVRCP\"]','Mild seasonal allergies','2024-03-10'),(3,3,'[\"Bordetella\"]','Previous knee surgery','2024-03-05');
/*!40000 ALTER TABLE `healthrecord` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `healthrecordhistory`
--

DROP TABLE IF EXISTS `healthrecordhistory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `healthrecordhistory` (
  `HistoryID` int NOT NULL AUTO_INCREMENT,
  `RecordID` int NOT NULL,
  `PetID` int NOT NULL,
  `Vaccinations` json DEFAULT NULL,
  `MedicalHistory` text,
  `LastCheckup` date DEFAULT NULL,
  `VetID` int NOT NULL,
  `ArchiveDate` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`HistoryID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `healthrecordhistory`
--

LOCK TABLES `healthrecordhistory` WRITE;
/*!40000 ALTER TABLE `healthrecordhistory` DISABLE KEYS */;
/*!40000 ALTER TABLE `healthrecordhistory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `location`
--

DROP TABLE IF EXISTS `location`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `location` (
  `LocationID` int NOT NULL AUTO_INCREMENT,
  `Location_Name` varchar(100) NOT NULL,
  `Address` varchar(200) NOT NULL,
  `Location_Type` enum('Shelter','Park','Partner_Store') NOT NULL,
  `IsIndoor` tinyint(1) NOT NULL,
  `ShelterID` int DEFAULT NULL,
  PRIMARY KEY (`LocationID`),
  KEY `ShelterID` (`ShelterID`),
  CONSTRAINT `location_ibfk_1` FOREIGN KEY (`ShelterID`) REFERENCES `shelter` (`ShelterID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `location`
--

LOCK TABLES `location` WRITE;
/*!40000 ALTER TABLE `location` DISABLE KEYS */;
INSERT INTO `location` VALUES (1,'Main Shelter Lobby','123 Main St','Shelter',1,1),(2,'Central Park Spot','456 Park Ave','Park',0,1),(3,'Main Shelter HQ','123 Main St','Shelter',1,1),(4,'Greenwood Park','45 Park Ave','Park',0,NULL),(5,'PetZone Partner Store','89 Retail St','Partner_Store',1,NULL);
/*!40000 ALTER TABLE `location` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `meetup`
--

DROP TABLE IF EXISTS `meetup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `meetup` (
  `MeetupID` int NOT NULL AUTO_INCREMENT,
  `ApplicationID` int NOT NULL,
  `LocationID` int NOT NULL,
  `Meet_DateTime` datetime NOT NULL,
  `meetUp_Status` enum('Scheduled','Completed','Cancelled') DEFAULT 'Scheduled',
  `AdminID` int NOT NULL,
  PRIMARY KEY (`MeetupID`),
  KEY `ApplicationID` (`ApplicationID`),
  KEY `LocationID` (`LocationID`),
  KEY `AdminID` (`AdminID`),
  CONSTRAINT `meetup_ibfk_1` FOREIGN KEY (`ApplicationID`) REFERENCES `application` (`ApplicationID`),
  CONSTRAINT `meetup_ibfk_2` FOREIGN KEY (`LocationID`) REFERENCES `location` (`LocationID`),
  CONSTRAINT `meetup_ibfk_3` FOREIGN KEY (`AdminID`) REFERENCES `admin` (`AdminID`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meetup`
--

LOCK TABLES `meetup` WRITE;
/*!40000 ALTER TABLE `meetup` DISABLE KEYS */;
/*!40000 ALTER TABLE `meetup` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_pet_adoption` AFTER UPDATE ON `meetup` FOR EACH ROW BEGIN
    IF NEW.meetUp_Status = 'Completed' AND OLD.meetUp_Status != 'Completed' THEN
        -- Archive pet data
        INSERT INTO PetAdoptionHistory
        SELECT NULL, p.PetID, a.AdopterID, CURDATE(), m.GeneralStaffID, m.MeetupID
        FROM Pet p
        JOIN Application a ON p.PetID = a.PetID
        JOIN Meetup m ON a.ApplicationID = m.ApplicationID
        WHERE m.MeetupID = NEW.MeetupID;

        -- Archive health records
        INSERT INTO HealthRecordHistory
        SELECT NULL, hr.RecordID, hr.PetID, hr.Vaccinations, 
               hr.MedicalHistory, hr.LastCheckup, hr.VetID
        FROM HealthRecord hr
        WHERE hr.PetID = (SELECT PetID FROM Application WHERE ApplicationID = NEW.ApplicationID);

        -- Remove live records
        DELETE FROM Pet WHERE PetID = (SELECT PetID FROM Application WHERE ApplicationID = NEW.ApplicationID);
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `pet`
--

DROP TABLE IF EXISTS `pet`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pet` (
  `PetID` int NOT NULL AUTO_INCREMENT,
  `Pet_name` varchar(50) NOT NULL,
  `CategoryID` int NOT NULL,
  `Age` varchar(50) DEFAULT NULL,
  `Gender` enum('Male','Female','Unknown') NOT NULL,
  `ArrivalDate` date NOT NULL,
  `ShelterID` int NOT NULL,
  `Color` varchar(50) DEFAULT NULL,
  `Weight` decimal(5,2) DEFAULT NULL COMMENT 'Weight in kg',
  `SpecialNeeds` text,
  `AdoptionStatus` enum('Available','Pending','Adopted','Medical Hold') DEFAULT 'Available',
  PRIMARY KEY (`PetID`),
  KEY `ShelterID` (`ShelterID`),
  KEY `CategoryID` (`CategoryID`),
  CONSTRAINT `pet_ibfk_1` FOREIGN KEY (`ShelterID`) REFERENCES `shelter` (`ShelterID`),
  CONSTRAINT `pet_ibfk_2` FOREIGN KEY (`CategoryID`) REFERENCES `petcategory` (`CategoryID`),
  CONSTRAINT `pet_chk_1` CHECK ((`Weight` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pet`
--

LOCK TABLES `pet` WRITE;
/*!40000 ALTER TABLE `pet` DISABLE KEYS */;
INSERT INTO `pet` VALUES (1,'Max',1,'3 years','Male','2024-01-15',1,'Golden',28.50,'None','Available'),(2,'Luna',2,'2 years','Female','2024-02-01',1,'Tabby',4.20,'Allergy medication','Available'),(3,'Buddy',3,'5 years','Male','2024-03-01',1,'Black/Tan',8.70,'Joint supplements','Pending');
/*!40000 ALTER TABLE `pet` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `before_pet_insert` BEFORE INSERT ON `pet` FOR EACH ROW BEGIN
    DECLARE current_pets INT;
    DECLARE shelter_capacity INT;

    SELECT COUNT(*) INTO current_pets 
    FROM Pet 
    WHERE ShelterID = NEW.ShelterID;

    SELECT Capacity INTO shelter_capacity 
    FROM Shelter 
    WHERE ShelterID = NEW.ShelterID;

    IF current_pets >= shelter_capacity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Shelter at capacity. Cannot add more pets.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `petadoptionhistory`
--

DROP TABLE IF EXISTS `petadoptionhistory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `petadoptionhistory` (
  `HistoryID` int NOT NULL AUTO_INCREMENT,
  `PetID` int DEFAULT NULL,
  `AdopterID` int NOT NULL,
  `AdoptionDate` date NOT NULL,
  `MeetupID` int NOT NULL,
  PRIMARY KEY (`HistoryID`),
  KEY `PetID` (`PetID`),
  KEY `AdopterID` (`AdopterID`),
  KEY `MeetupID` (`MeetupID`),
  CONSTRAINT `petadoptionhistory_ibfk_1` FOREIGN KEY (`PetID`) REFERENCES `pet` (`PetID`) ON DELETE SET NULL,
  CONSTRAINT `petadoptionhistory_ibfk_2` FOREIGN KEY (`AdopterID`) REFERENCES `adopter` (`AdopterID`),
  CONSTRAINT `petadoptionhistory_ibfk_4` FOREIGN KEY (`MeetupID`) REFERENCES `meetup` (`MeetupID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `petadoptionhistory`
--

LOCK TABLES `petadoptionhistory` WRITE;
/*!40000 ALTER TABLE `petadoptionhistory` DISABLE KEYS */;
/*!40000 ALTER TABLE `petadoptionhistory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `petcategory`
--

DROP TABLE IF EXISTS `petcategory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `petcategory` (
  `CategoryID` int NOT NULL AUTO_INCREMENT,
  `Species` varchar(50) NOT NULL,
  `Breed` varchar(50) NOT NULL,
  `SizeCategory` enum('Small','Medium','Large','Giant') NOT NULL,
  `Temperament` varchar(100) DEFAULT NULL,
  `LifeExpectancyMin` int DEFAULT NULL,
  `LifeExpectancyMax` int DEFAULT NULL,
  `GroomingNeeds` enum('Low','Medium','High') DEFAULT NULL,
  `ActivityLevel` enum('Low','Moderate','High','Very High') DEFAULT NULL,
  `GoodWithChildren` tinyint(1) DEFAULT NULL,
  `GoodWithOtherPets` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`CategoryID`),
  UNIQUE KEY `Species` (`Species`,`Breed`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `petcategory`
--

LOCK TABLES `petcategory` WRITE;
/*!40000 ALTER TABLE `petcategory` DISABLE KEYS */;
INSERT INTO `petcategory` VALUES (1,'Dog','Golden Retriever','Large','Friendly',10,12,'Medium','High',1,1),(2,'Cat','Domestic Shorthair','Medium','Independent',12,15,'Low','Moderate',1,0),(3,'Dog','Dachshund','Small','Playful',12,16,'Low','High',1,1);
/*!40000 ALTER TABLE `petcategory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `petdetailsview`
--

DROP TABLE IF EXISTS `petdetailsview`;
/*!50001 DROP VIEW IF EXISTS `petdetailsview`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `petdetailsview` AS SELECT 
 1 AS `PetID`,
 1 AS `Pet_name`,
 1 AS `Age`,
 1 AS `Gender`,
 1 AS `ArrivalDate`,
 1 AS `Color`,
 1 AS `Weight`,
 1 AS `SpecialNeeds`,
 1 AS `ShelterID`,
 1 AS `Shelter_name`,
 1 AS `CategoryID`,
 1 AS `Species`,
 1 AS `Breed`,
 1 AS `SizeCategory`,
 1 AS `Temperament`,
 1 AS `LifeExpectancyMin`,
 1 AS `LifeExpectancyMax`,
 1 AS `GroomingNeeds`,
 1 AS `ActivityLevel`,
 1 AS `GoodWithChildren`,
 1 AS `GoodWithOtherPets`,
 1 AS `PhotoURLs`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `petphoto`
--

DROP TABLE IF EXISTS `petphoto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `petphoto` (
  `PhotoID` int NOT NULL AUTO_INCREMENT,
  `PetID` int NOT NULL,
  `PhotoURL` varchar(255) NOT NULL,
  `UploadDate` datetime DEFAULT CURRENT_TIMESTAMP,
  `IsPrimary` tinyint(1) DEFAULT '0',
  `Description` text,
  `UploadedByAdminID` int NOT NULL,
  PRIMARY KEY (`PhotoID`),
  UNIQUE KEY `OnlyOnePrimaryPhoto` (`PetID`,`IsPrimary`),
  KEY `UploadedByAdminID` (`UploadedByAdminID`),
  CONSTRAINT `petphoto_ibfk_1` FOREIGN KEY (`PetID`) REFERENCES `pet` (`PetID`) ON DELETE CASCADE,
  CONSTRAINT `petphoto_ibfk_2` FOREIGN KEY (`UploadedByAdminID`) REFERENCES `admin` (`AdminID`),
  CONSTRAINT `petphoto_chk_1` CHECK ((`IsPrimary` in (0,1)))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `petphoto`
--

LOCK TABLES `petphoto` WRITE;
/*!40000 ALTER TABLE `petphoto` DISABLE KEYS */;
INSERT INTO `petphoto` VALUES (1,1,'https://images.pexels.com/photos/1108099/pexels-photo-1108099.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2','2025-04-18 02:40:06',1,NULL,1),(2,2,'https://images.pexels.com/photos/1805164/pexels-photo-1805164.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2','2025-04-18 02:40:06',1,NULL,1),(3,3,'https://images.pexels.com/photos/45201/kitty-cat-kitten-pet-45201.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2','2025-04-18 02:40:06',1,NULL,1);
/*!40000 ALTER TABLE `petphoto` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `before_petphoto_insert` BEFORE INSERT ON `petphoto` FOR EACH ROW BEGIN
    DECLARE is_admin INT;
    
    SELECT COUNT(*) INTO is_admin 
    FROM Admin 
    WHERE AdminID = NEW.UploadedByAdminID;
    
    IF is_admin = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Only admins can add pet photos';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `before_petphoto_update` BEFORE UPDATE ON `petphoto` FOR EACH ROW BEGIN
    DECLARE is_admin INT;
    
    SELECT COUNT(*) INTO is_admin 
    FROM Admin 
    WHERE AdminID = NEW.UploadedByAdminID;
    
    IF is_admin = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Only admins can update pet photos';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `before_petphoto_delete` BEFORE DELETE ON `petphoto` FOR EACH ROW BEGIN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Use DeletePetPhoto procedure to delete photos';
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reviews` (
  `ReviewID` int NOT NULL AUTO_INCREMENT,
  `ShelterID` int NOT NULL,
  `AdopterID` int NOT NULL,
  `Rating` int NOT NULL,
  `Comments` text,
  `Reply` text,
  `ReviewDate` date DEFAULT (curdate()),
  `IsAnonymous` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`ReviewID`),
  KEY `ShelterID` (`ShelterID`),
  KEY `AdopterID` (`AdopterID`),
  CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`ShelterID`) REFERENCES `shelter` (`ShelterID`),
  CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`AdopterID`) REFERENCES `adopter` (`AdopterID`),
  CONSTRAINT `reviews_chk_1` CHECK ((`Rating` between 1 and 5))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reviews`
--

LOCK TABLES `reviews` WRITE;
/*!40000 ALTER TABLE `reviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shelter`
--

DROP TABLE IF EXISTS `shelter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shelter` (
  `ShelterID` int NOT NULL AUTO_INCREMENT,
  `Shelter_name` varchar(100) NOT NULL,
  `LicenseNumber` varchar(50) NOT NULL,
  `Address` varchar(200) NOT NULL,
  `Phone` varchar(15) NOT NULL,
  `Email` varchar(100) NOT NULL,
  `Capacity` int NOT NULL DEFAULT '20',
  PRIMARY KEY (`ShelterID`),
  UNIQUE KEY `LicenseNumber` (`LicenseNumber`),
  UNIQUE KEY `Email` (`Email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shelter`
--

LOCK TABLES `shelter` WRITE;
/*!40000 ALTER TABLE `shelter` DISABLE KEYS */;
INSERT INTO `shelter` VALUES (1,'Main Shelter','LIC-001','123 Main St','555-1234','main@shelter.com',20);
/*!40000 ALTER TABLE `shelter` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vet`
--

DROP TABLE IF EXISTS `vet`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vet` (
  `VetID` int NOT NULL AUTO_INCREMENT,
  `FirstName` varchar(50) NOT NULL,
  `LastName` varchar(50) NOT NULL,
  `Specialization` varchar(100) DEFAULT NULL,
  `Phone` varchar(15) NOT NULL,
  `Email` varchar(100) NOT NULL,
  `ShelterID` int NOT NULL,
  PRIMARY KEY (`VetID`),
  UNIQUE KEY `Email` (`Email`),
  KEY `ShelterID` (`ShelterID`),
  CONSTRAINT `vet_ibfk_1` FOREIGN KEY (`ShelterID`) REFERENCES `shelter` (`ShelterID`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vet`
--

LOCK TABLES `vet` WRITE;
/*!40000 ALTER TABLE `vet` DISABLE KEYS */;
INSERT INTO `vet` VALUES (1,'Sarah','Wilson','Canine Medicine','555-1001','sarah.vet@shelter.com',1),(2,'Michael','Brown','Feline Medicine','555-1002','michael.vet@shelter.com',1);
/*!40000 ALTER TABLE `vet` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vetschedule`
--

DROP TABLE IF EXISTS `vetschedule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vetschedule` (
  `ScheduleID` int NOT NULL AUTO_INCREMENT,
  `VetID` int NOT NULL,
  `ShelterID` int NOT NULL,
  `ScheduleDate` date NOT NULL,
  `IsAvailable` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`ScheduleID`),
  UNIQUE KEY `VetID` (`VetID`,`ScheduleDate`),
  KEY `ShelterID` (`ShelterID`),
  CONSTRAINT `vetschedule_ibfk_1` FOREIGN KEY (`VetID`) REFERENCES `vet` (`VetID`),
  CONSTRAINT `vetschedule_ibfk_2` FOREIGN KEY (`ShelterID`) REFERENCES `shelter` (`ShelterID`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vetschedule`
--

LOCK TABLES `vetschedule` WRITE;
/*!40000 ALTER TABLE `vetschedule` DISABLE KEYS */;
INSERT INTO `vetschedule` VALUES (1,1,1,'2025-04-19',1),(2,2,1,'2025-04-20',0);
/*!40000 ALTER TABLE `vetschedule` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'pet_shelter_2'
--

--
-- Dumping routines for database 'pet_shelter_2'
--
/*!50003 DROP FUNCTION IF EXISTS `EmailExists` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `EmailExists`(p_Email VARCHAR(100)) RETURNS tinyint(1)
    READS SQL DATA
BEGIN
    DECLARE email_count INT;
    
    SELECT COUNT(*) INTO email_count 
    FROM Adopter 
    WHERE Email = p_Email;
    
    IF email_count > 0 THEN 
        RETURN TRUE; 
    END IF;
    
    SELECT COUNT(*) INTO email_count 
    FROM Admin 
    WHERE Email = p_Email;
    
    RETURN email_count > 0;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `GetShelterAverageRating` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `GetShelterAverageRating`(p_ShelterID INT) RETURNS decimal(3,2)
    DETERMINISTIC
BEGIN
    DECLARE avg_rating DECIMAL(3,2);
    
    SELECT AVG(Rating) INTO avg_rating
    FROM Reviews
    WHERE ShelterID = p_ShelterID;
    
    RETURN IFNULL(avg_rating, 0);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddLocation` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddLocation`(
    IN p_Location_Name VARCHAR(100),
    IN p_Address VARCHAR(200),
    IN p_Location_Type ENUM('Shelter', 'Park', 'Partner_Store'),
    IN p_IsIndoor BOOLEAN,
    IN p_ShelterID INT)
BEGIN
    INSERT INTO Location (
        Location_Name, Address, Location_Type, IsIndoor, ShelterID
    ) VALUES (
        p_Location_Name, p_Address, p_Location_Type, p_IsIndoor, p_ShelterID
    );
    
    SELECT LAST_INSERT_ID() AS NewLocationID;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddPet` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddPet`(
    IN p_Pet_name VARCHAR(50),
    IN p_CategoryID INT,
    IN p_Age INT,
    IN p_Gender ENUM('Male', 'Female', 'Unknown'),
    IN p_ArrivalDate DATE,
    IN p_ShelterID INT,
    IN p_Color VARCHAR(50),
    IN p_Weight DECIMAL(5,2),
    IN p_SpecialNeeds TEXT)
BEGIN
    INSERT INTO Pet (
        Pet_name, CategoryID, Age, Gender, ArrivalDate, 
        ShelterID, Color, Weight, SpecialNeeds
    ) VALUES (
        p_Pet_name, p_CategoryID, p_Age, p_Gender, p_ArrivalDate,
        p_ShelterID, p_Color, p_Weight, p_SpecialNeeds
    );
    
    SELECT LAST_INSERT_ID() AS NewPetID;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddPetCategory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddPetCategory`(
    IN p_Species VARCHAR(50),
    IN p_Breed VARCHAR(50),
    IN p_SizeCategory ENUM('Small', 'Medium', 'Large', 'Giant'),
    IN p_Temperament VARCHAR(100),
    IN p_LifeExpectancyMin INT,
    IN p_LifeExpectancyMax INT,
    IN p_GroomingNeeds ENUM('Low', 'Medium', 'High'),
    IN p_ActivityLevel ENUM('Low', 'Moderate', 'High', 'Very High'),
    IN p_GoodWithChildren BOOLEAN,
    IN p_GoodWithOtherPets BOOLEAN)
BEGIN
    INSERT INTO PetCategory (
        Species, Breed, SizeCategory, Temperament, 
        LifeExpectancyMin, LifeExpectancyMax, GroomingNeeds, 
        ActivityLevel, GoodWithChildren, GoodWithOtherPets
    ) VALUES (
        p_Species, p_Breed, p_SizeCategory, p_Temperament,
        p_LifeExpectancyMin, p_LifeExpectancyMax, p_GroomingNeeds,
        p_ActivityLevel, p_GoodWithChildren, p_GoodWithOtherPets
    );
    
    SELECT LAST_INSERT_ID() AS NewCategoryID;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddPetPhoto` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddPetPhoto`(
    IN p_PetID INT,
    IN p_PhotoURL VARCHAR(255),
    IN p_IsPrimary BOOLEAN,
    IN p_Description TEXT,
    IN p_AdminID INT
)
BEGIN
    DECLARE admin_exists INT;
    
    -- Verify admin exists
    SELECT COUNT(*) INTO admin_exists FROM Admin WHERE AdminID = p_AdminID;
    IF admin_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only admins can add photos';
    END IF;
    
    -- If setting as primary, first unset any existing primary photo
    IF p_IsPrimary THEN
        UPDATE PetPhoto SET IsPrimary = FALSE WHERE PetID = p_PetID;
    END IF;
    
    INSERT INTO PetPhoto (PetID, PhotoURL, IsPrimary, Description, UploadedByAdminID)
    VALUES (p_PetID, p_PhotoURL, p_IsPrimary, p_Description, p_AdminID);
    
    SELECT LAST_INSERT_ID() AS NewPhotoID;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddReview` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddReview`(
    IN p_ShelterID INT,
    IN p_AdopterID INT,
    IN p_Rating INT,
    IN p_Comments TEXT,
    IN p_IsAnonymous BOOLEAN)
BEGIN
    INSERT INTO Reviews (
        ShelterID, AdopterID, Rating, Comments, IsAnonymous
    ) VALUES (
        p_ShelterID, p_AdopterID, p_Rating, p_Comments, p_IsAnonymous
    );
    
    SELECT LAST_INSERT_ID() AS NewReviewID;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddReviewReply` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddReviewReply`(
    IN p_ReviewID INT,
    IN p_Reply TEXT)
BEGIN
    UPDATE Reviews
    SET Reply = p_Reply
    WHERE ReviewID = p_ReviewID;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddShelter` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddShelter`(
    IN p_Name VARCHAR(100),
    IN p_LicenseNumber VARCHAR(50),
    IN p_Address VARCHAR(200),
    IN p_Phone VARCHAR(15),
    IN p_Email VARCHAR(100))
BEGIN
    INSERT INTO Shelter (Shelter_name, LicenseNumber, Address, Phone, Email)
    VALUES (p_Name, p_LicenseNumber, p_Address, p_Phone, p_Email);
    
    SELECT LAST_INSERT_ID() AS NewShelterID;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddVetToShelter` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddVetToShelter`(
    IN p_FirstName VARCHAR(50),
    IN p_LastName VARCHAR(50),
    IN p_Specialization VARCHAR(100),
    IN p_Phone VARCHAR(15),
    IN p_Email VARCHAR(100),
    IN p_ShelterID INT,
    IN p_AdminID INT
)
BEGIN
    DECLARE admin_check INT;
    
    -- Verify admin exists
    SELECT COUNT(*) INTO admin_check FROM Admin WHERE AdminID = p_AdminID;
    IF admin_check = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Only admins can add vets';
    END IF;
    
    INSERT INTO Vet (
        FirstName, LastName, Specialization, Phone, Email, ShelterID
    ) VALUES (
        p_FirstName, p_LastName, p_Specialization, p_Phone, p_Email, p_ShelterID
    );
    
    SELECT LAST_INSERT_ID() AS NewVetID;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AdminAddHealthRecord` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AdminAddHealthRecord`(
    IN p_PetID INT,
    IN p_Vaccinations JSON,
    IN p_MedicalHistory TEXT,
    IN p_LastCheckup DATE,
    IN p_AdminID INT
)
BEGIN
    DECLARE admin_check INT;
    
    -- Verify admin exists
    SELECT COUNT(*) INTO admin_check FROM Admin WHERE AdminID = p_AdminID;
    IF admin_check = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Only admins can add health records';
    END IF;
    
    INSERT INTO HealthRecord (
        PetID, Vaccinations, MedicalHistory, LastCheckup
    ) VALUES (
        p_PetID, p_Vaccinations, p_MedicalHistory, p_LastCheckup
    );
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AdminUpdateHealthRecord` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AdminUpdateHealthRecord`(
    IN p_RecordID INT,
    IN p_Vaccinations JSON,
    IN p_MedicalHistory TEXT,
    IN p_LastCheckup DATE,
    IN p_AdminID INT
)
BEGIN
    DECLARE admin_check INT;
    
    -- Verify admin exists
    SELECT COUNT(*) INTO admin_check FROM Admin WHERE AdminID = p_AdminID;
    IF admin_check = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Only admins can update health records';
    END IF;
    
    UPDATE HealthRecord SET
        Vaccinations = p_Vaccinations,
        MedicalHistory = p_MedicalHistory,
        LastCheckup = p_LastCheckup
    WHERE RecordID = p_RecordID;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CreateAdoptionApplication` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateAdoptionApplication`(
    IN p_AdopterID INT,
    IN p_PetID INT,
    IN p_DOB DATE,
    IN p_ResidenceType ENUM('Apartment', 'House', 'Condo', 'Other'),
    IN p_OtherPets BOOLEAN,
    IN p_AdoptionReason TEXT,
    IN p_PreviouslyAdopted BOOLEAN,
    IN p_PrimaryCaregiver VARCHAR(100),
    IN p_ContactNumber VARCHAR(15),
    IN p_EmergencyContact VARCHAR(15),
    IN p_MeetupPreference TEXT,
    IN p_AnnualIncome DECIMAL(10, 2),
    IN p_StaffNotes TEXT
)
BEGIN
    -- Check if pet is available
    DECLARE pet_status VARCHAR(20);
    
    SELECT AdoptionStatus INTO pet_status FROM Pet WHERE PetID = p_PetID;
    
    IF pet_status != 'Available' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'This pet is not available for adoption';
    ELSE
        -- Create the application with all required fields
        INSERT INTO Application (
            AdopterID,
            PetID,
            DOB,
            ResidenceType,
            OtherPets,
            AdoptionReason,
            PreviouslyAdopted,
            PrimaryCaregiver,
            ContactNumber,
            EmergencyContact,
            MeetupPreference,
            AnnualIncome,
            StaffNotes
        ) VALUES (
            p_AdopterID,
            p_PetID,
            p_DOB,
            p_ResidenceType,
            p_OtherPets,
            p_AdoptionReason,
            p_PreviouslyAdopted,
            p_PrimaryCaregiver,
            p_ContactNumber,
            p_EmergencyContact,
            p_MeetupPreference,
            p_AnnualIncome,
            p_StaffNotes
        );
        
        -- Update pet status to pending
        UPDATE Pet SET AdoptionStatus = 'Pending' WHERE PetID = p_PetID;
        
        SELECT LAST_INSERT_ID() AS NewApplicationID;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `DeletePetPhoto` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `DeletePetPhoto`(
    IN p_PhotoID INT,
    IN p_AdminID INT
)
BEGIN
    DECLARE admin_exists INT;
    DECLARE is_primary BOOLEAN;
    DECLARE pet_id INT;
    
    -- Verify admin exists
    SELECT COUNT(*) INTO admin_exists FROM Admin WHERE AdminID = p_AdminID;
    IF admin_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only admins can delete photos';
    END IF;
    
    -- Get photo info before deletion
    SELECT IsPrimary, PetID INTO is_primary, pet_id 
    FROM PetPhoto 
    WHERE PhotoID = p_PhotoID;
    
    -- Delete the photo
    DELETE FROM PetPhoto WHERE PhotoID = p_PhotoID;
    
    -- If deleted photo was primary, set a new primary if others exist
    IF is_primary THEN
        UPDATE PetPhoto 
        SET IsPrimary = TRUE 
        WHERE PetID = pet_id 
        LIMIT 1;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `DeleteReviewComments` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteReviewComments`(
    IN p_ReviewID INT,
    IN p_AdminID INT
)
BEGIN
    DECLARE v_admin_check INT;
    
    -- Verify admin status
    SELECT COUNT(*) INTO v_admin_check 
    FROM Admin_staff 
    WHERE StaffID = p_AdminID;

    IF v_admin_check = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Only admin staff can modify reviews';
    END IF;

    UPDATE Reviews
    SET Comments = NULL,
        Reply = NULL
    WHERE ReviewID = p_ReviewID;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAdopterByEmail` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAdopterByEmail`(IN p_Email VARCHAR(100))
BEGIN
    SELECT AdopterID, Phone FROM Adopter WHERE Email = p_Email;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAdopterWithDecryptedSSN` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAdopterWithDecryptedSSN`(
    IN p_AdopterID INT
)
BEGIN
    DECLARE v_key VARBINARY(255);
    
    -- Get the active encryption key
    SELECT KeyValue INTO v_key 
    FROM EncryptionKeys 
    WHERE IsActive = TRUE 
    ORDER BY KeyVersion DESC 
    LIMIT 1;
    
    -- Return data with decrypted SSN
    SELECT 
        AdopterID,
        CAST(AES_DECRYPT(EncryptedSSN, v_key, IV) AS CHAR) AS SSN,
        FirstName,
        LastName,
        Email,
        Phone,
        Address,
        RegistrationDate
    FROM Adopter
    WHERE AdopterID = p_AdopterID;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAllShelters` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllShelters`()
BEGIN
    SELECT ShelterID, Shelter_name, Address, Phone, Email 
    FROM Shelter
    ORDER BY Shelter_name;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetApplicationHistory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetApplicationHistory`(IN p_ApplicationID INT)
BEGIN
    SELECT 
        ah.HistoryID,
        ah.App_Status,
        ah.ChangeDate,
        CONCAT(ss.FirstName, ' ', ss.LastName) AS ChangedBy,
        ah.Notes
    FROM ApplicationHistory ah
    LEFT JOIN ShelterStaff ss ON ah.ChangedByStaffID = ss.StaffID
    WHERE ah.ApplicationID = p_ApplicationID
    ORDER BY ah.ChangeDate DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetApplicationStatusStats` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetApplicationStatusStats`(IN p_ShelterID INT)
BEGIN
    SELECT 
        ah.App_Status,
        COUNT(*) AS TransitionCount,
        MIN(ah.ChangeDate) AS FirstOccurrence,
        MAX(ah.ChangeDate) AS LastOccurrence
    FROM ApplicationHistory ah
    JOIN Application a ON ah.ApplicationID = a.ApplicationID
    JOIN Pet p ON a.PetID = p.PetID
    WHERE p.ShelterID = p_ShelterID
    GROUP BY ah.App_Status
    ORDER BY TransitionCount DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetApplicationTimeline` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetApplicationTimeline`(IN p_ApplicationID INT)
BEGIN
    -- Application creation
    SELECT 
        ApplicationDate AS EventDate,
        'Application Submitted' AS EventType,
        NULL AS ChangedBy,
        CONCAT('Application received for pet ID: ', PetID) AS Details
    FROM Application
    WHERE ApplicationID = p_ApplicationID
    
    UNION ALL
    
    -- Status changes from history
    SELECT 
        ChangeDate AS EventDate,
        CONCAT('Status: ', App_Status) AS EventType,
        CONCAT(ss.FirstName, ' ', ss.LastName) AS ChangedBy,
        Notes AS Details
    FROM ApplicationHistory ah
    LEFT JOIN ShelterStaff ss ON ah.ChangedByStaffID = ss.StaffID
    WHERE ah.ApplicationID = p_ApplicationID
    
    UNION ALL
    
    -- Meetup events
    SELECT 
        m.Meet_DateTime AS EventDate,
        CONCAT('Meetup: ', m.meetUp_Status) AS EventType,
        CONCAT(ss.FirstName, ' ', ss.LastName) AS ChangedBy,
        CONCAT('Location: ', l.Location_Name) AS Details
    FROM Meetup m
    JOIN Location l ON m.LocationID = l.LocationID
    JOIN General_Staff gs ON m.GeneralStaffID = gs.StaffID
    JOIN ShelterStaff ss ON gs.StaffID = ss.StaffID
    WHERE m.ApplicationID = p_ApplicationID
    
    ORDER BY EventDate DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetHealthRecordByPetID` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetHealthRecordByPetID`(IN p_PetID INT)
BEGIN
    SELECT 
        RecordID,
        Vaccinations,
        MedicalHistory,
        LastCheckup
    FROM HealthRecord
    WHERE PetID = p_PetID;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetMeetupsByShelter` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetMeetupsByShelter`(IN p_ShelterID INT)
BEGIN
    SELECT 
        m.MeetupID,
        m.Meet_DateTime,
        m.meetUp_Status,
        l.Location_Name,
        l.Address,
        CONCAT(a.FirstName, ' ', a.LastName) AS AdopterName,
        p.Pet_name,
        CONCAT(ss.FirstName, ' ', ss.LastName) AS StaffName
    FROM Meetup m
    JOIN Location l ON m.LocationID = l.LocationID
    JOIN Application app ON m.ApplicationID = app.ApplicationID
    JOIN Adopter a ON app.AdopterID = a.AdopterID
    JOIN Pet p ON app.PetID = p.PetID
    JOIN General_Staff gs ON m.GeneralStaffID = gs.StaffID
    JOIN ShelterStaff ss ON gs.StaffID = ss.StaffID
    WHERE l.ShelterID = p_ShelterID
    ORDER BY m.Meet_DateTime;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetPetByID` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetPetByID`(IN p_PetID INT)
BEGIN
    SELECT 
        p.PetID,
        p.Pet_name,
        p.CategoryID,
        pc.Species,
        pc.Breed,
        p.Age,
        p.Gender,
        p.ArrivalDate,
        p.ShelterID,
        s.Shelter_name,
        p.Color,
        p.Weight,
        p.SpecialNeeds,
        p.AdoptionStatus,
        pc.SizeCategory,
        pc.Temperament,
        pc.LifeExpectancyMin,
        pc.LifeExpectancyMax,
        pc.GroomingNeeds,
        pc.ActivityLevel,
        pc.GoodWithChildren,
        pc.GoodWithOtherPets
    FROM Pet p
    JOIN PetCategory pc ON p.CategoryID = pc.CategoryID
    JOIN Shelter s ON p.ShelterID = s.ShelterID
    WHERE p.PetID = p_PetID;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetPetCountsByShelter` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetPetCountsByShelter`(IN p_ShelterID INT)
BEGIN
    SELECT 
        AdoptionStatus,
        COUNT(*) AS Count
    FROM Pet
    WHERE ShelterID = p_ShelterID
    GROUP BY AdoptionStatus;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetPetPhotos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetPetPhotos`(IN p_PetID INT)
BEGIN
    SELECT 
        PhotoID,
        PhotoURL,
        IsPrimary,
        Description,
        UploadDate,
        CONCAT(a.FirstName, ' ', a.LastName) AS UploadedBy
    FROM PetPhoto pp
    JOIN Admin a ON pp.UploadedByAdminID = a.AdminID
    WHERE PetID = p_PetID
    ORDER BY IsPrimary DESC, UploadDate DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetPetsByShelter` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetPetsByShelter`(IN p_ShelterID INT)
BEGIN
    SELECT 
        p.PetID,
        p.Pet_name,
        pc.Species,
        pc.Breed,
        p.Age,
        p.Gender,
        p.Color,
        p.Weight,
        p.ArrivalDate,
        p.AdoptionStatus,
        pc.SizeCategory,
        pc.Temperament
    FROM Pet p
    JOIN PetCategory pc ON p.CategoryID = pc.CategoryID
    WHERE p.ShelterID = p_ShelterID
    ORDER BY p.AdoptionStatus, p.Pet_name;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetRecentApplicationActivity` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetRecentApplicationActivity`(IN p_ShelterID INT)
BEGIN
    SELECT 
        ah.HistoryID,
        a.ApplicationID,
        p.Pet_name,
        CONCAT(ad.FirstName, ' ', ad.LastName) AS AdopterName,
        ah.App_Status,
        ah.ChangeDate,
        CONCAT(ss.FirstName, ' ', ss.LastName) AS ChangedBy
    FROM ApplicationHistory ah
    JOIN Application a ON ah.ApplicationID = a.ApplicationID
    JOIN Pet p ON a.PetID = p.PetID
    JOIN Adopter ad ON a.AdopterID = ad.AdopterID
    LEFT JOIN ShelterStaff ss ON ah.ChangedByStaffID = ss.StaffID
    WHERE p.ShelterID = p_ShelterID
    AND ah.ChangeDate >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
    ORDER BY ah.ChangeDate DESC
    LIMIT 50;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetReviewsByShelter` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetReviewsByShelter`(IN p_ShelterID INT)
BEGIN
    SELECT 
        r.ReviewID,
        r.Rating,
        r.Comments,
        r.Reply,
        r.ReviewDate,
        CASE 
            WHEN r.IsAnonymous THEN 'Anonymous'
            ELSE CONCAT(a.FirstName, ' ', a.LastName)
        END AS ReviewerName,
        r.IsAnonymous
    FROM Reviews r
    JOIN Adopter a ON r.AdopterID = a.AdopterID
    WHERE r.ShelterID = p_ShelterID
    ORDER BY r.ReviewDate DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetShelterApplicationHistory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetShelterApplicationHistory`(IN p_ShelterID INT)
BEGIN
    SELECT 
        ah.HistoryID,
        a.ApplicationID,
        p.Pet_name,
        CONCAT(ad.FirstName, ' ', ad.LastName) AS AdopterName,
        ah.App_Status,
        ah.ChangeDate,
        CONCAT(ss.FirstName, ' ', ss.LastName) AS ChangedBy,
        ah.Notes
    FROM ApplicationHistory ah
    JOIN Application a ON ah.ApplicationID = a.ApplicationID
    JOIN Pet p ON a.PetID = p.PetID
    JOIN Adopter ad ON a.AdopterID = ad.AdopterID
    LEFT JOIN ShelterStaff ss ON ah.ChangedByStaffID = ss.StaffID
    WHERE p.ShelterID = p_ShelterID
    ORDER BY ah.ChangeDate DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetShelterByID` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetShelterByID`(IN p_ShelterID INT)
BEGIN
    SELECT ShelterID, Shelter_name, LicenseNumber, Address, Phone, Email
    FROM Shelter
    WHERE ShelterID = p_ShelterID;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetVetsByShelter` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetVetsByShelter`(
    IN p_ShelterID INT
)
BEGIN
    SELECT 
        VetID,
        CONCAT(FirstName, ' ', LastName) AS VetName,
        Specialization,
        Phone,
        Email
    FROM Vet
    WHERE ShelterID = p_ShelterID
    ORDER BY LastName, FirstName;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `InsertAdopterWithEncryptedSSN` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertAdopterWithEncryptedSSN`(
    IN p_SSN VARCHAR(11),
    IN p_FirstName VARCHAR(50),
    IN p_LastName VARCHAR(50),
    IN p_Email VARCHAR(100),
    IN p_Phone VARCHAR(15),
    IN p_Address VARCHAR(200),
    IN p_PasswordHash VARCHAR(255)  -- Add password hash parameter
)
BEGIN
    DECLARE v_key VARBINARY(255);
    DECLARE v_iv VARBINARY(16);
    
    SELECT KeyValue INTO v_key 
    FROM EncryptionKeys 
    WHERE IsActive = TRUE 
    ORDER BY KeyVersion DESC 
    LIMIT 1;
    
    SET v_iv = RANDOM_BYTES(16);
    
    INSERT INTO Adopter (
        EncryptedSSN, 
        FirstName, 
        LastName, 
        Email, 
        Phone, 
        Address,
        IV,
        EncryptionKeyVersion,
        PasswordHash  -- Add password hash to insert
    )
    VALUES (
        AES_ENCRYPT(p_SSN, v_key, v_iv),
        p_FirstName,
        p_LastName,
        p_Email,
        p_Phone,
        p_Address,
        v_iv,
        1,
        p_PasswordHash
    );
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ProcessAdoptionApplication` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `ProcessAdoptionApplication`(
    IN p_ApplicationID INT,
    IN p_NewStatus ENUM('Approved', 'Rejected', 'Withdrawn'),
    IN p_StaffID INT,
    IN p_Notes TEXT,
    IN p_RejectionReason TEXT
)
BEGIN
    DECLARE v_pet_id INT;
    DECLARE v_current_status VARCHAR(20);
    
    -- Get current application and pet info
    SELECT PetID, App_Status INTO v_pet_id, v_current_status
    FROM Application 
    WHERE ApplicationID = p_ApplicationID;
    
    -- Validate transition
    IF v_current_status != 'Pending' AND p_NewStatus != 'Withdrawn' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Only pending applications can be approved/rejected';
    ELSE
        -- Update application
        UPDATE Application SET
            App_Status = p_NewStatus,
            ProcessedByAdminID = p_StaffID,
            StaffNotes = CONCAT(IFNULL(StaffNotes, ''), '\n', p_Notes),
            RejectionReason = IF(p_NewStatus = 'Rejected', p_RejectionReason, NULL),
            ApprovalDate = IF(p_NewStatus = 'Approved', NOW(), NULL)
        WHERE ApplicationID = p_ApplicationID;
        
        -- Update pet status accordingly
        IF p_NewStatus = 'Approved' THEN
            UPDATE Pet SET AdoptionStatus = 'Adopted' WHERE PetID = v_pet_id;
        ELSEIF p_NewStatus = 'Rejected' OR p_NewStatus = 'Withdrawn' THEN
            UPDATE Pet SET AdoptionStatus = 'Available' WHERE PetID = v_pet_id;
        END IF;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `RotateEncryptionKeys` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `RotateEncryptionKeys`(IN p_newKey VARCHAR(32))
BEGIN
    UPDATE EncryptionKeys SET IsActive = FALSE;
    INSERT INTO EncryptionKeys (KeyVersion, KeyValue)
    VALUES ((SELECT MAX(KeyVersion)+1 FROM EncryptionKeys), 
           UNHEX(SHA2(p_newKey, 256)));
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ScheduleMeetup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `ScheduleMeetup`(
    IN p_ApplicationID INT,
    IN p_LocationID INT,
    IN p_Meet_DateTime DATETIME,
    IN p_AdminID INT)
BEGIN
    DECLARE v_pet_status VARCHAR(20);
    DECLARE v_app_status VARCHAR(20);
    
    -- Check if application is approved
    SELECT App_Status INTO v_app_status 
    FROM Application 
    WHERE ApplicationID = p_ApplicationID;
    
    IF v_app_status != 'Approved' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot schedule meetup for non-approved application';
    ELSE
        -- Check if pet is still available
        SELECT p.AdoptionStatus INTO v_pet_status
        FROM Application a
        JOIN Pet p ON a.PetID = p.PetID
        WHERE a.ApplicationID = p_ApplicationID;
        
        IF v_pet_status != 'Pending' THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Pet is not available for meetup';
        ELSE
            INSERT INTO Meetup (
                ApplicationID, LocationID, Meet_DateTime, GeneralStaffID
            ) VALUES (
                p_ApplicationID, p_LocationID, p_Meet_DateTime, p_GeneralStaffID
            );
            
            SELECT LAST_INSERT_ID() AS NewMeetupID;
        END IF;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ScheduleVetForDay` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `ScheduleVetForDay`(
    IN p_VetID INT,
    IN p_ScheduleDate DATE,
    IN p_AdminID INT
)
BEGIN
    DECLARE admin_check INT;
    DECLARE vet_shelter INT;
    
    -- Verify admin exists
    SELECT COUNT(*) INTO admin_check FROM Admin WHERE AdminID = p_AdminID;
    IF admin_check = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Only admins can schedule vets';
    END IF;
    
    -- Get vet's shelter
    SELECT ShelterID INTO vet_shelter FROM Vet WHERE VetID = p_VetID;
    
    -- Schedule the vet
    INSERT INTO VetSchedule (
        VetID, ShelterID, ScheduleDate
    ) VALUES (
        p_VetID, vet_shelter, p_ScheduleDate
    )
    ON DUPLICATE KEY UPDATE IsAvailable = TRUE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SetPrimaryPhoto` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SetPrimaryPhoto`(
    IN p_PhotoID INT,
    IN p_AdminID INT
)
BEGIN
    DECLARE pet_id INT;
    DECLARE admin_exists INT;
    
    -- Verify admin exists
    SELECT COUNT(*) INTO admin_exists FROM Admin WHERE AdminID = p_AdminID;
    IF admin_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only admins can set primary photos';
    END IF;
    
    -- Get pet ID for the photo
    SELECT PetID INTO pet_id FROM PetPhoto WHERE PhotoID = p_PhotoID;
    
    -- First unset any existing primary photo
    UPDATE PetPhoto SET IsPrimary = FALSE WHERE PetID = pet_id;
    
    -- Set the specified photo as primary
    UPDATE PetPhoto SET IsPrimary = TRUE WHERE PhotoID = p_PhotoID;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateMeetupStatus` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateMeetupStatus`(
    IN p_MeetupID INT,
    IN p_NewStatus ENUM('Scheduled', 'Completed', 'Cancelled'))
BEGIN
    UPDATE Meetup
    SET meetUp_Status = p_NewStatus
    WHERE MeetupID = p_MeetupID;
    
    -- If completed, mark pet as adopted
    IF p_NewStatus = 'Completed' THEN
        UPDATE Pet p
        JOIN Application a ON p.PetID = a.PetID
        JOIN Meetup m ON a.ApplicationID = m.ApplicationID
        SET p.AdoptionStatus = 'Adopted'
        WHERE m.MeetupID = p_MeetupID;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdatePetAdoptionStatus` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdatePetAdoptionStatus`(
    IN p_PetID INT,
    IN p_NewStatus ENUM('Available', 'Pending', 'Adopted', 'Medical Hold'))
BEGIN
    UPDATE Pet
    SET AdoptionStatus = p_NewStatus
    WHERE PetID = p_PetID;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdatePetPhoto` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdatePetPhoto`(
    IN p_PhotoID INT,
    IN p_NewPhotoURL VARCHAR(255),
    IN p_IsPrimary BOOLEAN,
    IN p_Description TEXT,
    IN p_AdminID INT
)
BEGIN
    DECLARE admin_exists INT;
    DECLARE pet_id INT;
    
    -- Verify admin exists
    SELECT COUNT(*) INTO admin_exists FROM Admin WHERE AdminID = p_AdminID;
    IF admin_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only admins can update photos';
    END IF;
    
    -- Get pet ID for the photo
    SELECT PetID INTO pet_id FROM PetPhoto WHERE PhotoID = p_PhotoID;
    
    -- If setting as primary, first unset any existing primary photo
    IF p_IsPrimary THEN
        UPDATE PetPhoto SET IsPrimary = FALSE WHERE PetID = pet_id;
    END IF;
    
    UPDATE PetPhoto 
    SET PhotoURL = p_NewPhotoURL,
        IsPrimary = p_IsPrimary,
        Description = p_Description
    WHERE PhotoID = p_PhotoID;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateShelter` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateShelter`(
    IN p_ShelterID INT,
    IN p_Name VARCHAR(100),
    IN p_Address VARCHAR(200),
    IN p_Phone VARCHAR(15),
    IN p_Email VARCHAR(100))
BEGIN
    UPDATE Shelter
    SET Shelter_name = p_Name,
        Address = p_Address,
        Phone = p_Phone,
        Email = p_Email
    WHERE ShelterID = p_ShelterID;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateUserReview` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateUserReview`(
    IN p_ReviewID INT,
    IN p_AdopterID INT,
    IN p_Rating INT,
    IN p_Comments TEXT
)
BEGIN
    UPDATE Reviews
    SET Rating = p_Rating,
        Comments = p_Comments
    WHERE ReviewID = p_ReviewID AND AdopterID = p_AdopterID;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `WithdrawApplication` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `WithdrawApplication`(
    IN p_ApplicationID INT,
    IN p_AdopterID INT
)
BEGIN
    DECLARE v_current_status VARCHAR(20);
    DECLARE v_app_adopter INT;

    SELECT App_Status, AdopterID INTO v_current_status, v_app_adopter
    FROM Application WHERE ApplicationID = p_ApplicationID;

    IF v_app_adopter != p_AdopterID THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Application does not belong to this adopter';
    END IF;

    IF v_current_status NOT IN ('Pending', 'Approved') THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot withdraw application in current state';
    END IF;

    CALL ProcessAdoptionApplication(p_ApplicationID, 'Withdrawn', NULL, 
        'Withdrawn by adopter', NULL);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `adopterhistory`
--

/*!50001 DROP VIEW IF EXISTS `adopterhistory`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `adopterhistory` AS select `a`.`AdopterID` AS `AdopterID`,`p`.`PetID` AS `PetID`,`p`.`Pet_name` AS `Pet_name`,`a`.`App_Status` AS `App_Status`,`m`.`meetUp_Status` AS `meetUp_Status`,`m`.`Meet_DateTime` AS `Meet_DateTime`,(case when ((`a`.`App_Status` = 'Approved') and (`m`.`meetUp_Status` = 'Completed')) then 'Successfully Adopted' when ((`a`.`App_Status` = 'Approved') and (`m`.`meetUp_Status` = 'Cancelled')) then 'Adoption Cancelled' else `a`.`App_Status` end) AS `AdoptionStatus` from ((`application` `a` left join `meetup` `m` on((`a`.`ApplicationID` = `m`.`ApplicationID`))) join `pet` `p` on((`a`.`PetID` = `p`.`PetID`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `petdetailsview`
--

/*!50001 DROP VIEW IF EXISTS `petdetailsview`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `petdetailsview` AS select `p`.`PetID` AS `PetID`,`p`.`Pet_name` AS `Pet_name`,`p`.`Age` AS `Age`,`p`.`Gender` AS `Gender`,`p`.`ArrivalDate` AS `ArrivalDate`,`p`.`Color` AS `Color`,`p`.`Weight` AS `Weight`,`p`.`SpecialNeeds` AS `SpecialNeeds`,`p`.`ShelterID` AS `ShelterID`,`s`.`Shelter_name` AS `Shelter_name`,`pc`.`CategoryID` AS `CategoryID`,`pc`.`Species` AS `Species`,`pc`.`Breed` AS `Breed`,`pc`.`SizeCategory` AS `SizeCategory`,`pc`.`Temperament` AS `Temperament`,`pc`.`LifeExpectancyMin` AS `LifeExpectancyMin`,`pc`.`LifeExpectancyMax` AS `LifeExpectancyMax`,`pc`.`GroomingNeeds` AS `GroomingNeeds`,`pc`.`ActivityLevel` AS `ActivityLevel`,`pc`.`GoodWithChildren` AS `GoodWithChildren`,`pc`.`GoodWithOtherPets` AS `GoodWithOtherPets`,group_concat(`pp`.`PhotoURL` separator ',') AS `PhotoURLs` from (((`pet` `p` join `petcategory` `pc` on((`p`.`CategoryID` = `pc`.`CategoryID`))) join `shelter` `s` on((`p`.`ShelterID` = `s`.`ShelterID`))) left join `petphoto` `pp` on((`p`.`PetID` = `pp`.`PetID`))) group by `p`.`PetID` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-04-18  2:44:27
