DROP VIEW IF EXISTS dbo.v_planetary_systems_count;
GO

CREATE VIEW dbo.v_planetary_systems_count
AS

/*****************************************************************************************************************
NAME:    dbo.v_planetary_systems_count
PURPOSE: Create the dbo.v_planetary_systems_count view

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     10/02/2025   NKAYLOR       1. Built this script for EC IT143


RUNTIME: 
~1s


NOTES: 
This script selects the column LABEL and displays confirmed planetary systems (2) and possible planetary systems (1)
using the CASE WHEN operator.
 
******************************************************************************************************************/

-- Q: How many entries are labeled as confirmed planets (2) versus possible planets (1)?

-- A: Let's ask SQL Server and find out...

SELECT 
	COUNT(CASE WHEN LABEL = 2 THEN 1 END) AS confirmed_planetary_systems,
	COUNT(CASE WHEN LABEL = 1 THEN 1 END) AS possible_planetary_systems
FROM dbo.exoplanet_hunting;
GO