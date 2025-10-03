CREATE PROCEDURE dbo.usp_planetary_systems_count
AS

/*****************************************************************************************************************
NAME:    dbo.usp_planetary_systems_count
PURPOSE: Create the dbo.v_planetary_systems_count stored procedure

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     10/02/2025   NKAYLOR       1. Built this script for EC IT143


RUNTIME: 
~1s


NOTES: 
Loads two aggregate counts (LABEL=2 confirmed, LABEL=1 possible) from the view into the table.
 
******************************************************************************************************************/

BEGIN

	-- 1) Reload data

	TRUNCATE TABLE dbo.planetary_systems_count;

	INSERT INTO dbo.planetary_systems_count
		SELECT v.confirmed_planetary_systems
			 , v.possible_planetary_systems
		FROM dbo.v_planetary_systems_count AS v;

	-- 2) Review results

	SELECT t.*
		FROM dbo.planetary_systems_count AS t;
END
GO