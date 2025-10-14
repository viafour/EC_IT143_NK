-- Q2: How do you extract the last name from the contact name?
-- A2: Let's ask SQL (and web search a metric ton!
-- Most likely reading from the last name side or maybe using some sort of variable string?
-- https://learn.microsoft.com/en-us/answers/questions/778734/separating-name-to-first-name-last-name-and-middle
-- https://www.sqlservercentral.com/forums/topic/get-last-name-first-name-and-middle-name-from-full-name
-- https://stackoverflow.com/questions/5145791/extracting-first-name-and-last-name
-- https://learn.microsoft.com/en-us/sql/t-sql/functions/reverse-transact-sql?view=sql-server-ver17
-- https://learn.microsoft.com/en-us/sql/t-sql/functions/left-transact-sql?view=sql-server-ver17

WITH s2
            AS (SELECT ContactName,
                REVERSE(LEFT(REVERSE(LTRIM(RTRIM(ContactName)))
                ,            CHARINDEX(' ', REVERSE(LTRIM(RTRIM(ContactName))) + ' ') - 1)) AS last_name
                , dbo.udf_parse_last_name(ContactName) AS last_name2
            FROM dbo.t_w3_schools_customers)
        SELECT s2.*
    FROM s2
WHERE s2.last_name <> s2.last_name2;
