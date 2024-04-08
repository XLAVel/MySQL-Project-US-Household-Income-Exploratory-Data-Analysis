#US HouseHold Income Exploratory Data Analysis
# Data Exploration
SELECT *
FROM project.ushouseholdincome;
SELECT *
FROM project.ushouseholdincome_statistics;

# Top 10 Area of Land by State
SELECT State_Name, SUM(ALand) AS land_area
FROM project.ushouseholdincome
GROUP BY State_name
ORDER BY land_area DESC
LIMIT 10; 
# Top 10 Area of Water by State
SELECT State_Name, SUM(AWater) as water_area
FROM project.ushouseholdincome
GROUP BY State_name
ORDER BY water_area DESC
LIMIT 10; 

# Joining the two tables
SELECT u.State_Name, County, Type, `Primary`, Mean, Median
FROM project.ushouseholdincome u
# Inner join to filter out missing data from the ushouseholdincome table
INNER JOIN project.ushouseholdincome_statistics us
	ON u.id = us.id
# To Filter out missing values from ushouseholdincome_statistics table
WHERE Mean <> 0
;

# Top 10 Average Income by States
SELECT u.State_Name, ROUND(AVG(Mean),1) as avg, ROUND(AVG(Median),1) as median
FROM project.ushouseholdincome u
INNER JOIN project.ushouseholdincome_statistics us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY u.State_Name
ORDER BY avg DESC
LIMIT 10
;

# Top 10 Average Income by Type
SELECT Type, COUNT(Type) as count, ROUND(AVG(Mean),1) as avg, ROUND(AVG(Median),1) as median
FROM project.ushouseholdincome u
INNER JOIN project.ushouseholdincome_statistics us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY Type
# To filter out outliers
HAVING COUNT(Type) > 100
ORDER BY avg DESC
LIMIT 20
;

# To check the community type
SELECT *
FROM ushouseholdincome
WHERE TYPE = 'Community';

# To check the average salaries by City
SELECT u.State_Name, City, ROUND(AVG(mean),1) as avg, ROUND(AVG(Median),1) as median
FROM project.ushouseholdincome u
INNER JOIN project.ushouseholdincome_statistics us
	ON u.id = us.id
GROUP BY u.State_Name, City
HAVING avg <> 0 OR median <> 0
ORDER BY avg DESC
    ;