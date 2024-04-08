# Automated Data Cleaning Project
SELECT *
FROM project.ushouseholdincome;

SELECT *
FROM project.ushouseholdincome_cleaned;

# Data Cleaning Steps
# Remove Duplicates
DELETE FROM us_household_income_clean 
WHERE 
	row_id IN (
	SELECT row_id
FROM (
	SELECT row_id, id,
		ROW_NUMBER() OVER (
			PARTITION BY id
			ORDER BY id) AS row_num
	FROM 
		us_household_income_clean
) duplicates
WHERE 
	row_num > 1
);

# Fixing some data quality issues by fixing typos and general standardization
UPDATE us_household_income_clean
SET State_Name = 'Georgia'
WHERE State_Name = 'georia';

UPDATE us_household_income_clean
SET County = UPPER(County);

UPDATE us_household_income_clean
SET City = UPPER(City);

UPDATE us_household_income_clean
SET Place = UPPER(Place);

UPDATE us_household_income_clean
SET State_Name = UPPER(State_Name);

UPDATE us_household_income_clean
SET `Type` = 'CDP'
WHERE `Type` = 'CPD';

UPDATE us_household_income_clean
SET `Type` = 'Borough'
WHERE `Type` = 'Boroughs';


DELIMITER $$
DROP PROCEDURE IF EXISTS Copy_and_Clean_Data;
CREATE PROCEDURE Copy_and_Clean_Date()
BEGIN
#Creating the table
	CREATE TABLE IF NOT EXISTS `ushouseholdincome_cleaned` (
		  `row_id` int DEFAULT NULL,
		  `id` int DEFAULT NULL,
		  `State_Code` int DEFAULT NULL,
		  `State_Name` text,
		  `State_ab` text,
		  `County` text,
		  `City` text,
		  `Place` text,
		  `Type` text,
		  `Primary` text,
		  `Zip_Code` int DEFAULT NULL,
		  `Area_Code` int DEFAULT NULL,
		  `ALand` int DEFAULT NULL,
		  `AWater` int DEFAULT NULL,
		  `Lat` double DEFAULT NULL,
		  `Lon` double DEFAULT NULL,
		  `TimeStamp` TIMESTAMP DEFAULT NULL
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
    
# Copy data to new table
	INSERT INTO project.ushouseholdincome_cleaned
    SELECT *, CURRENT_TIMESTAMP
	FROM project.ushouseholdincome;

# 1. Remove Duplicates
DELETE FROM project.ushouseholdincome_cleaned
WHERE 
	row_id IN (
	SELECT row_id
FROM (
	SELECT row_id, id,
		ROW_NUMBER() OVER (
			PARTITION BY id, `TimeStamp`
			ORDER BY id, `TimeStamp`) AS row_num
	FROM 
		project.ushouseholdincome_cleaned
) duplicates
WHERE 
	row_num > 1
);

# 2. Fixing some data quality issues by fixing typos and general standardization
	UPDATE project.ushouseholdincome_cleaned
	SET State_Name = 'Georgia'
	WHERE State_Name = 'georia';

	UPDATE project.ushouseholdincome_cleaned
	SET County = UPPER(County);

	UPDATE project.ushouseholdincome_cleaned
	SET City = UPPER(City);

	UPDATE project.ushouseholdincome_cleaned
	SET Place = UPPER(Place);

	UPDATE project.ushouseholdincome_cleaned
	SET State_Name = UPPER(State_Name);

	UPDATE project.ushouseholdincome_cleaned
	SET `Type` = 'CDP'
	WHERE `Type` = 'CPD';

	UPDATE project.ushouseholdincome_cleaned
	SET `Type` = 'Borough'
	WHERE `Type` = 'Boroughs';
    
END $$
DELIMITER ;

CALL Copy_and_Clean_Date();

# Create Event
DROP EVENT run_data_cleaning;
CREATE EVENT run_data_cleaning
	ON SCHEDULE EVERY 2 MINUTE
    DO CALL Copy_and_Clean_Data();

# CREATE TRIGGER
DELIMITER $$
CREATE TRIGGER Transfer_clean_date
	AFTER INSERT ON project.ushouseholdincome
    FOR EACH ROW
BEGIN
	CALL Copy_and_and_Clean_Date();
END $$
DELIMITER ;


# DEBUIGGING
# Checking original
	SELECT row_id, id, row_num
FROM (
	SELECT row_id, id,
		ROW_NUMBER() OVER (
			PARTITION BY id
			ORDER BY id) AS row_num
	FROM 
		ushouseholdincome
) duplicates
WHERE 
	row_num > 1;

SELECT COUNT(row_id)
FROM ushouseholdincome;

SELECT State_Name, COUNT(State_Name)
FROM ushouseholdincome
GROUP BY State_Name;

# Checking cleaned
	SELECT row_id, id, row_num
FROM (
	SELECT row_id, id,
		ROW_NUMBER() OVER (
			PARTITION BY id
			ORDER BY id) AS row_num
	FROM 
		ushouseholdincome_cleaned
) duplicates
WHERE 
	row_num > 1;

SELECT COUNT(row_id)
FROM ushouseholdincome_cleaned;

SELECT State_Name, COUNT(State_Name)
FROM ushouseholdincome_cleaned
GROUP BY State_Name;