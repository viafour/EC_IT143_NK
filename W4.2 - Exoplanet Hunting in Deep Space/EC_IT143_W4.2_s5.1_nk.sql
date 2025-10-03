-- Q: How many entries are labeled as confirmed planets (2) versus possible planets (1)?

-- A: Let's ask SQL Server and find out...

SELECT v.confirmed_planetary_systems
	 , v.possible_planetary_systems
INTO dbo.t_planetary_systems_count
FROM dbo.v_planetary_systems_count AS v;
GO