#US HouseHold Income Data Cleaning
# Data Exploration
SELECT *
FROM project.ushouseholdincome;
SELECT *
FROM project.ushouseholdincome_statistics;

# Renamed `ï»¿id` to `id`
ALTER TABLE project.ushouseholdincome_statistics RENAME COLUMN ï»¿id TO `id`;

# Count both tables for verification
SELECT count(id)
FROM project.ushouseholdincome;

SELECT count(id)
FROM project.ushouseholdincome_statistics;

# To check for duplicates
SELECT id, count(id)
FROM project.ushouseholdincome
GROUP BY id
HAVING COUNT(id) > 1
;
SELECT id, count(id)
FROM project.ushouseholdincome_statistics
GROUP BY id
HAVING COUNT(id) > 1
;

#To remove duplicates
DELETE FROM project.ushouseholdincome
WHERE row_id IN (
	SELECT row_id
	FROM ( 
		SELECT row_id,
		id,
		ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num
		FROM project.ushouseholdincome
		) duplicates
	WHERE row_num > 1)
;

# To check for inconsistencies
SELECT DISTINCT State_Name, COUNT(State_Name)
FROM project.ushouseholdincome
GROUP BY State_Name
;
SELECT DISTINCT State_ab, COUNT(State_ab)
FROM project.ushouseholdincome
GROUP BY State_ab
;
SELECT Type, Count(Type)
FROM project.ushouseholdincome
GROUP BY Type
;

# To replace the wrong names with the correct names and format
UPDATE project.ushouseholdincome
SET State_Name = 'Georgia'
WHERE STATE_Name = 'georia'
;

UPDATE project.ushouseholdincome
SET State_Name = 'Alabama'
WHERE STATE_Name = 'alabama'
;

UPDATE project.ushouseholdincome
SET Type = 'Borough'
WHERE Type = 'Boroughs'
;

# To check for missing values and nulls
SELECT *
FROM project.ushouseholdincome
WHERE place = '' OR place IS NULL
;

SELECT ALand, Awater
FROM project.ushouseholdincome
WHERE (AWater = 0 OR AWater = '' OR Awater IS NULL)
AND (ALand = 0 OR ALand= '' OR ALand IS NULL)
;

# To replace the missing values in place
UPDATE project.ushouseholdincome
SET place = 'Autaugaville'
WHERE County = 'Autauga County'
AND City = 'Vinemont'
;


# Data Cleaning Formats
# To check for inconsistencies
#SELECT column_name, COUNT(column_name)
#FROM table_name
#GROUP BY column_name
#;

# To check for missing values and nulls
#SELECT *
#FROM table_name
#WHERE column_name = '' OR column_name IS NULL
#;