
CREATE FUNCTION [dbo].[udf_parse_last_name]
(@v_combined_name AS VARCHAR(500)
)
RETURNS VARCHAR(100)
AS

/*****************************************************************************************************************
NAME:    dbo.udf_parse_last_name
PURPOSE: Parse last Name from combined name

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     10/13/2025   NKAYLOR       1. Built this script for EC IT143


RUNTIME: 
1s

NOTES: 
Researched and created from a variety of resources.
https://learn.microsoft.com/en-us/answers/questions/778734/separating-name-to-first-name-last-name-and-middle
https://www.sqlservercentral.com/forums/topic/get-last-name-first-name-and-middle-name-from-full-name
https://stackoverflow.com/questions/5145791/extracting-first-name-and-last-name
https://learn.microsoft.com/en-us/sql/t-sql/functions/reverse-transact-sql?view=sql-server-ver17
https://learn.microsoft.com/en-us/sql/t-sql/functions/left-transact-sql?view=sql-server-ver17
 
******************************************************************************************************************/

BEGIN
  DECLARE @s NVARCHAR(200) = LTRIM(RTRIM(@v_combined_name));
  IF @s IS NULL OR @s = '' RETURN NULL;

  DECLARE @rev NVARCHAR(200) = REVERSE(@s);
  DECLARE @pos INT = CHARINDEX(' ', @rev + ' ');
  RETURN REVERSE(LEFT(@rev, @pos - 1));
END;
GO