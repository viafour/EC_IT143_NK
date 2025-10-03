-- Q: How many entries are labeled as confirmed planets (2) versus possible planets (1)?

-- A: Let's ask SQL Server and find out...


-- 1) Reload data

TRUNCATE TABLE dbo.planetary_systems_count;

INSERT INTO dbo.planetary_systems_count
	SELECT v.confirmed_planetary_systems
		 , v.possible_planetary_systems
	FROM dbo.v_planetary_systems_count AS v;

-- 2) Review results

SELECT t.*
	FROM dbo.planetary_systems_count AS t;