-- Q: What is the overall average (baseline) of measurement values found in column2?

-- A: Let's ask SQL Server and find out...

SELECT v.avg_baseline
	INTO dbo.t_quantum_avg_baseline
	FROM dbo.v_quantum_avg_baseline AS v;
GO