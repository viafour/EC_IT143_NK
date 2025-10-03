-- Q: What is the overall average (baseline) of measurement values found in column2?

-- A: Let's ask SQL Server and find out...

TRUNCATE TABLE dbo.t_quantum_avg_baseline;

INSERT INTO dbo.t_quantum_avg_baseline (avg_baseline)
	SELECT v.avg_baseline
	FROM dbo.v_quantum_avg_baseline AS v;

	SELECT *
	FROM dbo.t_quantum_avg_baseline;
GO