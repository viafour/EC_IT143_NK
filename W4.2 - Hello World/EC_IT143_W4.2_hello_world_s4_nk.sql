DROP VIEW IF EXISTS dbo.v_hello_world_load;
GO

CREATE VIEW dbo.v_hello_world_load
AS

/*****************************************************************************************************************
NAME:    dbo.v_hello_world_load
PURPOSE: Create the Hello World - Load view

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     10/02/2025   NKAYLOR       1. Built this script for EC IT143


RUNTIME: 
~1s

NOTES: 
This script is a part of the assignment 4.2 Final Project, and creates the view dbo.v_hello_world_load
 
******************************************************************************************************************/

-- Q: What is the current date and time?

-- A: Let's ask SQL Server and find out...

SELECT 'Hello World' AS my_message
	, GETDATE() AS current_date_time;