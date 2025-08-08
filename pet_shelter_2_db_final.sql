 -- drop database PET_SHELTER_2;
CREATE DATABASE IF NOT EXISTS PET_SHELTER_2;
use PET_SHELTER_2;

-- 1. Shelter Table
CREATE TABLE Shelter (
    ShelterID INT AUTO_INCREMENT PRIMARY KEY,
    Shelter_name VARCHAR(100) NOT NULL,
    LicenseNumber VARCHAR(50) UNIQUE NOT NULL,
    Address VARCHAR(200) NOT NULL,
    Phone VARCHAR(15) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Capacity INT NOT NULL DEFAULT 20
);

INSERT INTO Shelter (Shelter_name, LicenseNumber, Address, Phone, Email) 
VALUES ('Main Shelter', 'LIC-001', '123 Main St', '555-1234', 'main@shelter.com');



-- 2. Create admin table
CREATE TABLE Admin (
    AdminID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    ShelterID INT NOT NULL,
    FOREIGN KEY (ShelterID) REFERENCES Shelter(ShelterID)
);

-- Insert hardcoded admin (use hashed password in practice)
INSERT INTO Admin (FirstName, LastName, Email, PasswordHash, ShelterID)
VALUES ('Admin', 'User', 'admin@petshelter.com', 'hashed_password_here', 1);
    
-- Create table structure with encrypted SSN field
CREATE TABLE Adopter (
    AdopterID INT AUTO_INCREMENT PRIMARY KEY,
    EncryptedSSN VARBINARY(255) NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(15) NOT NULL,
    Address VARCHAR(200) NOT NULL,
    RegistrationDate DATE DEFAULT (CURDATE()),
    EncryptionKeyVersion INT DEFAULT 1,
    IV VARBINARY(16),  -- Initialization Vector for AES
    PasswordHash VARCHAR(255) NOT NULL
);

CREATE TABLE Vet (
    VetID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Specialization VARCHAR(100),
    Phone VARCHAR(15) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    ShelterID INT NOT NULL,
    FOREIGN KEY (ShelterID) REFERENCES Shelter(ShelterID)
);

CREATE TABLE VetSchedule (
    ScheduleID INT AUTO_INCREMENT PRIMARY KEY,
    VetID INT NOT NULL,
    ShelterID INT NOT NULL,
    ScheduleDate DATE NOT NULL,
    IsAvailable BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (VetID) REFERENCES Vet(VetID),
    FOREIGN KEY (ShelterID) REFERENCES Shelter(ShelterID),
    UNIQUE KEY (VetID, ScheduleDate)
);

-- Add index on encrypted field (for joins if needed)
CREATE INDEX idx_encrypted_ssn ON Adopter(EncryptedSSN);

-- Table to manage encryption keys (store securely)
CREATE TABLE EncryptionKeys (
    KeyID INT AUTO_INCREMENT PRIMARY KEY,
    KeyVersion INT NOT NULL,
    KeyValue VARBINARY(255) NOT NULL,
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    IsActive BOOLEAN DEFAULT TRUE
);

-- Insert a sample encryption key (in practice, rotate keys periodically)
INSERT INTO EncryptionKeys (KeyVersion, KeyValue)
VALUES (1, UNHEX(SHA2('YourSecretMasterKey123!', 512)));
DELIMITER //

DELIMITER //

CREATE PROCEDURE InsertAdopterWithEncryptedSSN(
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
END //


-- Procedure to decrypt SSN (restrict access to this!)
CREATE PROCEDURE GetAdopterWithDecryptedSSN(
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
END //

DELIMITER ;

DELIMITER //

DELIMITER //

CREATE PROCEDURE RotateEncryptionKeys(IN p_newKey VARCHAR(32))
BEGIN
    UPDATE EncryptionKeys SET IsActive = FALSE;
    INSERT INTO EncryptionKeys (KeyVersion, KeyValue)
    VALUES ((SELECT MAX(KeyVersion)+1 FROM EncryptionKeys), 
           UNHEX(SHA2(p_newKey, 256)));
END //

DELIMITER ;

-- pet category 
CREATE TABLE PetCategory (
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    Species VARCHAR(50) NOT NULL,
    Breed VARCHAR(50) NOT NULL,
    SizeCategory ENUM('Small', 'Medium', 'Large', 'Giant') NOT NULL,
    Temperament VARCHAR(100),
    LifeExpectancyMin INT,
    LifeExpectancyMax INT,
    GroomingNeeds ENUM('Low', 'Medium', 'High'),
    ActivityLevel ENUM('Low', 'Moderate', 'High', 'Very High'),
    GoodWithChildren BOOLEAN DEFAULT NULL,
    GoodWithOtherPets BOOLEAN DEFAULT NULL,
    UNIQUE KEY (Species, Breed)  -- Ensure each species/breed combination is unique
);

-- pet table 

CREATE TABLE Pet (
    PetID INT AUTO_INCREMENT PRIMARY KEY,
    Pet_name VARCHAR(50) NOT NULL,
    CategoryID INT NOT NULL,  -- Reference to PetCategory instead of Species/Breed
    Age varchar(50),
    Gender ENUM('Male', 'Female', 'Unknown') NOT NULL,
    ArrivalDate DATE NOT NULL,
    ShelterID INT NOT NULL,
    Color VARCHAR(50),
    Weight DECIMAL(5,2) COMMENT 'Weight in kg',
    SpecialNeeds TEXT,
    AdoptionStatus ENUM('Available', 'Pending', 'Adopted', 'Medical Hold') DEFAULT 'Available',
    FOREIGN KEY (ShelterID) REFERENCES Shelter(ShelterID),
    FOREIGN KEY (CategoryID) REFERENCES PetCategory(CategoryID),
    CHECK (Weight > 0)
);


-- 9. HealthRecord Table
CREATE TABLE HealthRecord (
    RecordID INT AUTO_INCREMENT PRIMARY KEY,
    PetID INT UNIQUE NOT NULL,
    Vaccinations JSON,
    MedicalHistory TEXT,
    LastCheckup DATE,
    FOREIGN KEY (PetID) REFERENCES Pet(PetID) ON DELETE CASCADE
);

CREATE TABLE Blog (
    BlogID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    Content TEXT NOT NULL,
    AdminID INT NOT NULL,
    PublishDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    IsPublished BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (AdminID) REFERENCES Admin(AdminID)
);

 -- create application table along with the application form (include other fields in the application form)
CREATE TABLE Application (
    ApplicationID INT AUTO_INCREMENT PRIMARY KEY,
    AdopterID INT NOT NULL,
    PetID INT NOT NULL,
    EmailID VARCHAR(100),
    ApplicationDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    DOB DATE NOT NULL,
    ResidenceType ENUM('Apartment', 'House', 'Condo', 'Other') NOT NULL,
    OtherPets BOOLEAN NOT NULL,
    AdoptionReason TEXT NOT NULL,
    PreviouslyAdopted BOOLEAN NOT NULL,
    PrimaryCaregiver VARCHAR(100) NOT NULL,
    ContactNumber VARCHAR(15) NOT NULL,
    EmergencyContact VARCHAR(15) NOT NULL,
    MeetupPreference TEXT,
    AnnualIncome DECIMAL(10, 2) NOT NULL,
    App_Status ENUM('Pending', 'Approved', 'Rejected', 'Withdrawn') DEFAULT 'Pending',
    StaffNotes TEXT,
    ProcessedByAdminID INT,
    ApprovalDate DATETIME NULL,
    RejectionReason TEXT,
    FOREIGN KEY (AdopterID) REFERENCES Adopter(AdopterID),
    FOREIGN KEY (PetID) REFERENCES Pet(PetID),
    FOREIGN KEY (ProcessedByAdminID) REFERENCES Admin(AdminID),
    CHECK ((App_Status = 'Approved' AND ApprovalDate IS NOT NULL) OR 
          (App_Status != 'Approved' AND ApprovalDate IS NULL))
);

ALTER TABLE Application ADD Age int;
Alter table Application Drop column ContactNumber;
-- procedures for processing the APPLICATION 
DELIMITER //

CREATE PROCEDURE CreateAdoptionApplication(
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
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE ProcessAdoptionApplication(
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
END //

DELIMITER ;

-- create Application History 
CREATE TABLE ApplicationHistory (
    HistoryID INT AUTO_INCREMENT PRIMARY KEY,
    ApplicationID INT NOT NULL,
    App_Status ENUM('Pending', 'Approved', 'Rejected', 'Withdrawn') NOT NULL,
    ChangeDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    Notes TEXT,
    FOREIGN KEY (ApplicationID) REFERENCES Application(ApplicationID)
);
select *from ApplicationHistory;



-- creating application history 
DELIMITER //

CREATE TRIGGER after_application_status_change
AFTER UPDATE ON Application
FOR EACH ROW
BEGIN
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
END //

DELIMITER ;

-- 11. Location Table
CREATE TABLE Location (
    LocationID INT AUTO_INCREMENT PRIMARY KEY,
    Location_Name VARCHAR(100) NOT NULL,
    Address VARCHAR(200) NOT NULL,
    Location_Type ENUM('Shelter', 'Park', 'Partner_Store') NOT NULL,
    IsIndoor BOOLEAN NOT NULL,
    ShelterID INT,
    FOREIGN KEY (ShelterID) REFERENCES Shelter(ShelterID)
);

-- 12. Meetup Table
CREATE TABLE Meetup (
    MeetupID INT AUTO_INCREMENT PRIMARY KEY,
    ApplicationID INT NOT NULL,
    LocationID INT NOT NULL,
    Meet_DateTime DATETIME NOT NULL,
    meetUp_Status ENUM('Scheduled', 'Completed', 'Cancelled') DEFAULT 'Scheduled',
    AdminID INT NOT NULL,
    FOREIGN KEY (ApplicationID) REFERENCES Application(ApplicationID),
    FOREIGN KEY (LocationID) REFERENCES Location(LocationID),
    FOREIGN KEY (AdminID) REFERENCES Admin(AdminID)
   
);




-- 13. Reviews Table
CREATE TABLE Reviews (
    ReviewID INT AUTO_INCREMENT PRIMARY KEY,
    ShelterID INT NOT NULL,
    AdopterID INT NOT NULL,
    Rating INT NOT NULL,
    Comments TEXT,
    Reply TEXT, 
    ReviewDate DATE DEFAULT (CURDATE()),
    IsAnonymous BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (ShelterID) REFERENCES Shelter(ShelterID),
    FOREIGN KEY (AdopterID) REFERENCES Adopter(AdopterID),
    CHECK (Rating BETWEEN 1 AND 5)
);

-- Pet Adoption History Table
CREATE TABLE PetAdoptionHistory (
    HistoryID INT AUTO_INCREMENT PRIMARY KEY,
    PetID INT ,
    AdopterID INT NOT NULL,
    AdoptionDate DATE NOT NULL,
    StaffID INT NOT NULL,
    MeetupID INT NOT NULL,
    FOREIGN KEY (PetID) REFERENCES Pet(PetID) ON DELETE SET NULL,
    FOREIGN KEY (AdopterID) REFERENCES Adopter(AdopterID),
    FOREIGN KEY (StaffID) REFERENCES Admin(AdminID),
    FOREIGN KEY (MeetupID) REFERENCES Meetup(MeetupID)
);

ALTER TABLE PetAdoptionHistory
DROP FOREIGN KEY PetAdoptionHistory_ibfk_3; -- replace with actual constraint name if different

-- Drop the column
ALTER TABLE PetAdoptionHistory
DROP COLUMN StaffID;





-- Health Record History Table
CREATE TABLE HealthRecordHistory (
    HistoryID INT AUTO_INCREMENT PRIMARY KEY,
    RecordID INT NOT NULL,
    PetID INT NOT NULL,
    Vaccinations JSON,
    MedicalHistory TEXT,
    LastCheckup DATE,
    VetID INT NOT NULL,
    ArchiveDate DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ALL THE PROCEDURES 

-- SHELTER MANAGEMENT PROCEDURES 
DELIMITER //

-- Add new shelter
CREATE PROCEDURE AddShelter(
    IN p_Name VARCHAR(100),
    IN p_LicenseNumber VARCHAR(50),
    IN p_Address VARCHAR(200),
    IN p_Phone VARCHAR(15),
    IN p_Email VARCHAR(100))
BEGIN
    INSERT INTO Shelter (Shelter_name, LicenseNumber, Address, Phone, Email)
    VALUES (p_Name, p_LicenseNumber, p_Address, p_Phone, p_Email);
    
    SELECT LAST_INSERT_ID() AS NewShelterID;
END //

-- Update shelter information
CREATE PROCEDURE UpdateShelter(
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
END //

-- Get all shelters
CREATE PROCEDURE GetAllShelters()
BEGIN
    SELECT ShelterID, Shelter_name, Address, Phone, Email 
    FROM Shelter
    ORDER BY Shelter_name;
END //

-- Get shelter by ID
CREATE PROCEDURE GetShelterByID(IN p_ShelterID INT)
BEGIN
    SELECT ShelterID, Shelter_name, LicenseNumber, Address, Phone, Email
    FROM Shelter
    WHERE ShelterID = p_ShelterID;
END //

DELIMITER ;

DELIMITER //
CREATE TRIGGER before_pet_insert
BEFORE INSERT ON Pet
FOR EACH ROW
BEGIN
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
END //
DELIMITER ;

DELIMITER //

-- PET MANAGEMENT 

-- Add new pet category
CREATE PROCEDURE AddPetCategory(
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
END //

-- Add new pet
CREATE PROCEDURE AddPet(
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
END //

-- Add health record for pet
CREATE PROCEDURE AdminAddHealthRecord(
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
END //

-- Get all pets by shelter
CREATE PROCEDURE GetPetsByShelter(IN p_ShelterID INT)
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
END //

-- Get pet details by ID
CREATE PROCEDURE GetPetByID(IN p_PetID INT)
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
END //

-- Get health record for pet

CREATE PROCEDURE GetHealthRecordByPetID(IN p_PetID INT)
BEGIN
    SELECT 
        RecordID,
        Vaccinations,
        MedicalHistory,
        LastCheckup
    FROM HealthRecord
    WHERE PetID = p_PetID;
END //

CREATE PROCEDURE AdminUpdateHealthRecord(
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
END //

CREATE PROCEDURE AddVetToShelter(
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
END //

CREATE PROCEDURE ScheduleVetForDay(
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
END //

CREATE PROCEDURE GetVetsByShelter(
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
END //

-- Update pet adoption status
CREATE PROCEDURE UpdatePetAdoptionStatus(
    IN p_PetID INT,
    IN p_NewStatus ENUM('Available', 'Pending', 'Adopted', 'Medical Hold'))
BEGIN
    UPDATE Pet
    SET AdoptionStatus = p_NewStatus
    WHERE PetID = p_PetID;
END //

-- LOCATION AND MEETUP PROCEDURES 

DELIMITER //

-- Add new location
CREATE PROCEDURE AddLocation(
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
END //

-- Schedule meetup
CREATE PROCEDURE ScheduleMeetup(
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
END //

-- Update meetup status
CREATE PROCEDURE UpdateMeetupStatus(
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
END //

-- Get meetups by shelter
CREATE PROCEDURE GetMeetupsByShelter(IN p_ShelterID INT)
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
END //

DELIMITER ;

-- REVIEW MANAGEMENET PROCEDURES 

DELIMITER //

-- Add review
CREATE PROCEDURE AddReview(
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
END //

-- Add reply to review
CREATE PROCEDURE AddReviewReply(
    IN p_ReviewID INT,
    IN p_Reply TEXT)
BEGIN
    UPDATE Reviews
    SET Reply = p_Reply
    WHERE ReviewID = p_ReviewID;
END //

-- Get reviews by shelter
CREATE PROCEDURE GetReviewsByShelter(IN p_ShelterID INT)
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
END //

-- Get shelter average rating
CREATE FUNCTION GetShelterAverageRating(p_ShelterID INT) 
RETURNS DECIMAL(3,2)
DETERMINISTIC
BEGIN
    DECLARE avg_rating DECIMAL(3,2);
    
    SELECT AVG(Rating) INTO avg_rating
    FROM Reviews
    WHERE ShelterID = p_ShelterID;
    
    RETURN IFNULL(avg_rating, 0);
END //

DELIMITER ;

DELIMITER //
CREATE PROCEDURE UpdateUserReview(
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
END //
DELIMITER ;


-- UTILITY FUNCTION 
DELIMITER //

-- Check if email exists
CREATE FUNCTION EmailExists(p_Email VARCHAR(100)) 
RETURNS BOOLEAN
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
END //

-- Get pets count by status
CREATE PROCEDURE GetPetCountsByShelter(IN p_ShelterID INT)
BEGIN
    SELECT 
        AdoptionStatus,
        COUNT(*) AS Count
    FROM Pet
    WHERE ShelterID = p_ShelterID
    GROUP BY AdoptionStatus;
END //

DELIMITER ;

DELIMITER //

-- Trigger to prevent duplicate adopter emails
CREATE TRIGGER prevent_duplicate_adopter_email
BEFORE INSERT ON Adopter
FOR EACH ROW
BEGIN
    IF EmailExists(NEW.Email) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Email already exists in system';
    END IF;
END //

-- Trigger to update pet status when application is approved
CREATE TRIGGER after_application_approval
AFTER UPDATE ON Application
FOR EACH ROW
BEGIN
    IF NEW.App_Status = 'Approved' AND OLD.App_Status != 'Approved' THEN
        UPDATE Pet
        SET AdoptionStatus = 'Pending'
        WHERE PetID = NEW.PetID;
    END IF;
END //

DELIMITER ;
 
 -- Application History procedures

DELIMITER //

-- Get full history for an application
CREATE PROCEDURE GetApplicationHistory(IN p_ApplicationID INT)
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
END //

-- Get all application history for a shelter
CREATE PROCEDURE GetShelterApplicationHistory(IN p_ShelterID INT)
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
END //

-- Get recent activity (last 30 days)
CREATE PROCEDURE GetRecentApplicationActivity(IN p_ShelterID INT)
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
END //

-- Get status transition statistics
CREATE PROCEDURE GetApplicationStatusStats(IN p_ShelterID INT)
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
END //

DELIMITER ;

DELIMITER //

-- Get complete timeline for an application
CREATE PROCEDURE GetApplicationTimeline(IN p_ApplicationID INT)
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
END //

DELIMITER ;

-- completed adoption trigger 
DELIMITER //
CREATE TRIGGER after_pet_adoption
AFTER UPDATE ON Meetup
FOR EACH ROW
BEGIN
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
END//
DELIMITER ;

-- application withdrawal procedure : 

DELIMITER //
CREATE PROCEDURE WithdrawApplication(
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
END//
DELIMITER ;

-- review management 
-- delete review 

DELIMITER //
CREATE PROCEDURE DeleteReviewComments(
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
END//
DELIMITER ;

-- adoption history view : 
CREATE VIEW AdopterHistory AS
SELECT 
    a.AdopterID,
    p.PetID,
    p.Pet_name,
    a.App_Status,
    m.meetUp_Status,
    m.Meet_DateTime,
    CASE 
        WHEN a.App_Status = 'Approved' AND m.meetUp_Status = 'Completed' 
            THEN 'Successfully Adopted'
        WHEN a.App_Status = 'Approved' AND m.meetUp_Status = 'Cancelled' 
            THEN 'Adoption Cancelled'
        ELSE a.App_Status
    END AS AdoptionStatus
FROM Application a
LEFT JOIN Meetup m ON a.ApplicationID = m.ApplicationID
JOIN Pet p ON a.PetID = p.PetID;

CREATE TABLE PetPhoto (
    PhotoID INT AUTO_INCREMENT PRIMARY KEY,
    PetID INT NOT NULL,
    PhotoURL VARCHAR(255) NOT NULL,
    UploadDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    IsPrimary BOOLEAN DEFAULT FALSE,
    Description TEXT,
    UploadedByAdminID INT NOT NULL,
    FOREIGN KEY (PetID) REFERENCES Pet(PetID) ON DELETE CASCADE,
    FOREIGN KEY (UploadedByAdminID) REFERENCES Admin(AdminID),
    CONSTRAINT OnlyOnePrimaryPhoto UNIQUE (PetID, IsPrimary),
    CHECK (IsPrimary IN (0, 1))
);

CREATE VIEW PetDetailsView AS
SELECT 
    p.PetID,
    p.Pet_name,
    p.Age,
    p.Gender,
    p.ArrivalDate,
    p.Color,
    p.Weight,
    p.SpecialNeeds,
    p.ShelterID,
    s.Shelter_name,
    pc.CategoryID,
    pc.Species,
    pc.Breed,
    pc.SizeCategory,
    pc.Temperament,
    pc.LifeExpectancyMin,
    pc.LifeExpectancyMax,
    pc.GroomingNeeds,
    pc.ActivityLevel,
    pc.GoodWithChildren,
    pc.GoodWithOtherPets,
    GROUP_CONCAT(pp.PhotoURL) AS PhotoURLs
FROM 
    Pet p
JOIN 
    PetCategory pc ON p.CategoryID = pc.CategoryID
JOIN 
    Shelter s ON p.ShelterID = s.ShelterID
LEFT JOIN 
    PetPhoto pp ON p.PetID = pp.PetID
GROUP BY 
    p.PetID;
    

-- Pet-photo procedures
DELIMITER //
CREATE PROCEDURE AddPetPhoto(
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
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE UpdatePetPhoto(
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
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE DeletePetPhoto(
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
END //
DELIMITER ;

-- Triggers to prevent non-admin modifications

-- Trigger for INSERT operations
DELIMITER //
CREATE TRIGGER before_petphoto_insert
BEFORE INSERT ON PetPhoto
FOR EACH ROW
BEGIN
    DECLARE is_admin INT;
    
    SELECT COUNT(*) INTO is_admin 
    FROM Admin 
    WHERE AdminID = NEW.UploadedByAdminID;
    
    IF is_admin = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Only admins can add pet photos';
    END IF;
END //
DELIMITER ;

-- Trigger for UPDATE operations
DELIMITER //
CREATE TRIGGER before_petphoto_update
BEFORE UPDATE ON PetPhoto
FOR EACH ROW
BEGIN
    DECLARE is_admin INT;
    
    SELECT COUNT(*) INTO is_admin 
    FROM Admin 
    WHERE AdminID = NEW.UploadedByAdminID;
    
    IF is_admin = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Only admins can update pet photos';
    END IF;
END //
DELIMITER ;

-- Trigger for DELETE operations
DELIMITER //
CREATE TRIGGER before_petphoto_delete
BEFORE DELETE ON PetPhoto
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Use DeletePetPhoto procedure to delete photos';
END //
DELIMITER ;

-- Utility procedure
DELIMITER //
CREATE PROCEDURE GetPetPhotos(IN p_PetID INT)
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
END //
DELIMITER ;

-- Set one primary photo for a pet
DELIMITER //
CREATE PROCEDURE SetPrimaryPhoto(
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
END //
DELIMITER ;

INSERT INTO Vet (FirstName, LastName, Specialization, Phone, Email, ShelterID)
VALUES 
('Sarah', 'Wilson', 'Canine Medicine', '555-1001', 'sarah.vet@shelter.com', 1),
('Michael', 'Brown', 'Feline Medicine', '555-1002', 'michael.vet@shelter.com', 1);

-- 3. Add Vet Schedules
INSERT INTO VetSchedule (VetID, ShelterID, ScheduleDate, IsAvailable)
VALUES
(1, 1, CURDATE() + INTERVAL 1 DAY, TRUE),
(2, 1, CURDATE() + INTERVAL 2 DAY, FALSE);

-- 4. Add Pet Categories
INSERT INTO PetCategory (Species, Breed, SizeCategory, Temperament, LifeExpectancyMin, LifeExpectancyMax, GroomingNeeds, ActivityLevel, GoodWithChildren, GoodWithOtherPets)
VALUES
('Dog', 'Golden Retriever', 'Large', 'Friendly', 10, 12, 'Medium', 'High', TRUE, TRUE),
('Cat', 'Domestic Shorthair', 'Medium', 'Independent', 12, 15, 'Low', 'Moderate', TRUE, FALSE),
('Dog', 'Dachshund', 'Small', 'Playful', 12, 16, 'Low', 'High', TRUE, TRUE);

-- 5. Add Pets
INSERT INTO Pet (Pet_name, CategoryID, Age, Gender, ArrivalDate, ShelterID, Color, Weight, SpecialNeeds, AdoptionStatus)
VALUES
('Max', 1, '3 years', 'Male', '2024-01-15', 1, 'Golden', 28.5, 'None', 'Available'),
('Luna', 2, '2 years', 'Female', '2024-02-01', 1, 'Tabby', 4.2, 'Allergy medication', 'Available'),
('Buddy', 3, '5 years', 'Male', '2024-03-01', 1, 'Black/Tan', 8.7, 'Joint supplements', 'Pending');

-- 6. Add Health Records
INSERT INTO HealthRecord (PetID, Vaccinations, MedicalHistory, LastCheckup)
VALUES
(1, '["Rabies", "Distemper"]', 'Healthy weight, no issues', '2024-03-15'),
(2, '["FVRCP"]', 'Mild seasonal allergies', '2024-03-10'),
(3, '["Bordetella"]', 'Previous knee surgery', '2024-03-05');

-- 7. Add Blog Posts
INSERT INTO Blog (Title, Content, AdminID, IsPublished)
VALUES
('Adoption Success Stories', 'Read our heartwarming adoption stories...', 1, TRUE),
('Pet Care Tips', 'Essential tips for new pet owners...', 1, FALSE);

-- 10. Add Locations
INSERT INTO Location (Location_Name, Address, Location_Type, IsIndoor, ShelterID)
VALUES
('Main Shelter Lobby', '123 Main St', 'Shelter', TRUE, 1),
('Central Park Spot', '456 Park Ave', 'Park', FALSE, 1);

INSERT INTO PetPhoto (PetID, PhotoURL, IsPrimary, UploadedByAdminID)
VALUES
(1, 'https://images.pexels.com/photos/1108099/pexels-photo-1108099.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2', TRUE, 1),
(2, 'https://images.pexels.com/photos/1805164/pexels-photo-1805164.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2', TRUE, 1),
(3, 'https://images.pexels.com/photos/45201/kitty-cat-kitten-pet-45201.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2', TRUE, 1);

show tables;
select* from Pet ;
select * from blog;

DELIMITER //

CREATE PROCEDURE GetAdopterByEmail(IN p_Email VARCHAR(100))
BEGIN
    SELECT AdopterID, Phone FROM Adopter WHERE Email = p_Email;
END //

DELIMITER ;

select *from Application;

select *from Adopter;

INSERT INTO Location (Location_Name, Address, Location_Type, IsIndoor, ShelterID)
VALUES 
('Main Shelter HQ', '123 Main St', 'Shelter', TRUE, 1),
('Greenwood Park', '45 Park Ave', 'Park', FALSE, NULL),
('PetZone Partner Store', '89 Retail St', 'Partner_Store', TRUE, NULL);

INSERT INTO Admin (FirstName, LastName, Email, PasswordHash, ShelterID)
VALUES 
('John', 'Doe', 'john.doe@shelter.com', 'hashed_password_1', 1),
('Jane', 'Smith', 'jane.smith@shelter.com', 'hashed_password_2', 1);


-- Inserting Application Data

INSERT INTO Meetup (ApplicationID, LocationID, Meet_DateTime, meetUp_Status, AdminID)
VALUES 
(1, 1, '2024-06-01 10:00:00', 'Scheduled', 1);

INSERT INTO PetAdoptionHistory (PetID, AdopterID, AdoptionDate, MeetupID) 
VALUES (1, 1, '2024-06-01', 1), 
       (1, 1, '2024-06-03', 1);
       
       ALTER TABLE application DROP FOREIGN KEY application_ibfk_2;

-- 1. Drop the existing foreign key constraint
ALTER TABLE application DROP FOREIGN KEY application_ibfk_2;

-- 2. Re-add the foreign key with ON DELETE CASCADE
ALTER TABLE application 
ADD CONSTRAINT application_ibfk_2 
FOREIGN KEY (PetID) REFERENCES pet(PetID) 
ON DELETE CASCADE;

ALTER TABLE applicationhistory DROP FOREIGN KEY applicationhistory_ibfk_1;

ALTER TABLE applicationhistory
ADD CONSTRAINT applicationhistory_ibfk_1
FOREIGN KEY (ApplicationID) REFERENCES application(ApplicationID)
ON DELETE CASCADE;

ALTER TABLE application DROP FOREIGN KEY application_ibfk_2;

ALTER TABLE application
ADD CONSTRAINT application_ibfk_2
FOREIGN KEY (PetID) REFERENCES pet(PetID)
ON DELETE CASCADE;

-- ApplicationHistory depends on Application
ALTER TABLE ApplicationHistory DROP FOREIGN KEY applicationhistory_ibfk_1;
ALTER TABLE ApplicationHistory
ADD CONSTRAINT applicationhistory_ibfk_1
FOREIGN KEY (ApplicationID) REFERENCES Application(ApplicationID)
ON DELETE CASCADE;

-- Meetup depends on Application
ALTER TABLE Meetup DROP FOREIGN KEY meetup_ibfk_1;
ALTER TABLE Meetup
ADD CONSTRAINT meetup_ibfk_1
FOREIGN KEY (ApplicationID) REFERENCES Application(ApplicationID)
ON DELETE CASCADE;

-- Application depends on Pet
ALTER TABLE Application DROP FOREIGN KEY application_ibfk_2;
ALTER TABLE Application
ADD CONSTRAINT application_ibfk_2
FOREIGN KEY (PetID) REFERENCES Pet(PetID)
ON DELETE CASCADE;

-- Optional: PetAdoptionHistory depends on Pet
ALTER TABLE PetAdoptionHistory DROP FOREIGN KEY PetAdoptionHistory_ibfk_1;
ALTER TABLE PetAdoptionHistory
ADD CONSTRAINT PetAdoptionHistory_ibfk_1
FOREIGN KEY (PetID) REFERENCES Pet(PetID)
ON DELETE SET NULL;

ALTER TABLE meetup DROP FOREIGN KEY meetup_ibfk_1;

ALTER TABLE meetup
ADD CONSTRAINT meetup_ibfk_1
FOREIGN KEY (ApplicationID) REFERENCES application(ApplicationID)
ON DELETE CASCADE;

ALTER TABLE petadoptionhistory DROP FOREIGN KEY petadoptionhistory_ibfk_4;

ALTER TABLE petadoptionhistory
ADD CONSTRAINT petadoptionhistory_ibfk_4
FOREIGN KEY (MeetupID) REFERENCES meetup(MeetupID)
ON DELETE CASCADE;
