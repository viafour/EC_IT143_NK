DROP VIEW IF EXISTS dbo.v_quantum_avg_baseline;
GO

CREATE VIEW dbo.v_quantum_avg_baseline
AS

/*****************************************************************************************************************
NAME:    dbo.v_quantum_avg_baseline
PURPOSE: To create a baseline average

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     10/2/2025   NKAYLOR       1. Built this script for EC IT143


RUNTIME: 
~1s

NOTES: 
This script creates a view!
 
******************************************************************************************************************/

SELECT CAST(AVG(CAST(column2 AS FLOAT)) AS FLOAT) AS avg_baseline
FROM dbo.quantum_vacuum_fluctuations;
GO