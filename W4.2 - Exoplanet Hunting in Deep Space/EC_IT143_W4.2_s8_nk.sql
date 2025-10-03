-- Q: How many entries are labeled as confirmed planets (2) versus possible planets (1)?

-- A: Let's ask SQL Server and find out...

EXEC dbo.usp_planetary_systems_count;