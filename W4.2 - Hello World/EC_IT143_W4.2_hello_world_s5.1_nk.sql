-- Q: What is the current date and time?

-- A: Let's ask SQL Server and find out...

SELECT v.my_message
	, v.current_date_time
	INTO dbo.t_hello_world
FROM dbo.v_hello_world_load AS v;