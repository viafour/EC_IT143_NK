-- Q: How many entries are labeled as confirmed planets (2) versus possible planets (1)?

-- A: Let's ask SQL Server and find out...

SELECT 
	COUNT(CASE WHEN LABEL = 2 THEN 1 END) AS confirmed_planetary_systems,
	COUNT(CASE WHEN LABEL = 1 THEN 1 END) AS possible_planetary_systems
FROM dbo.exoplanet_hunting;
GO