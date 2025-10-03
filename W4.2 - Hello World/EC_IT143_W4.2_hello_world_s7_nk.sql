CREATE PROCEDURE dbo.usp_hello_world_load
AS

/*****************************************************************************************************************
NAME:    dbo.usp_hello_world_load
PURPOSE: Hello World - Load user stored procedure

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     10/02/2025   NKAYLOR       1. Built this script for EC IT143


RUNTIME: 
~1s

NOTES: 
This script exists to help me learn step 7 of 8 in the Answer Focused Approcah for T-SQL Data Manipulation
 
******************************************************************************************************************/

	BEGIN

		TRUNCATE TABLE dbo.t_hello_world;

		INSERT INTO dbo.t_hello_world
			SELECT v.my_message
				 , v.current_date_time
			FROM dbo.v_hello_world_load AS v;

		-- 2) Review results

		SELECT t.*
			FROM dbo.t_hello_world AS t;
	END;
GO