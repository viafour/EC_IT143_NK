CREATE PROCEDURE dbo.usp_quantum_avg_baseline_load
AS

/*****************************************************************************************************************
NAME:    dbo.usp_quantum_avg_baseline_load
PURPOSE: To create a baseline average procedure

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     10/2/2025   NKAYLOR       1. Built this script for EC IT143


RUNTIME: 
~1s

NOTES: 
This script creates a procedure!
 
******************************************************************************************************************/

BEGIN
    TRUNCATE TABLE dbo.t_quantum_avg_baseline;

	INSERT INTO dbo.t_quantum_avg_baseline (avg_baseline)
		SELECT v.avg_baseline
		FROM dbo.v_quantum_avg_baseline AS v;

		SELECT *
		FROM dbo.t_quantum_avg_baseline;
END
GO