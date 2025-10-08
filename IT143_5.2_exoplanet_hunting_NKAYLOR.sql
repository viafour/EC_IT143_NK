/*****************************************************************************************************************
NAME:    Exoplanet Hunting Review
PURPOSE: Quantify data found in dbo.exoplanet_hunting and provide answers to questions.

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     10/04/2025   NKAYLOR       1. Built this script for EC IT143


RUNTIME: 
~1s

NOTES: 
The following answers to each SQL Community question pulled on my own personal knowledge, required research, as was developed
with the assistance of generative AI (also, thanks Ciarelle for mentoring!).

Resources used:
Resource 1: https://learn.microsoft.com/en-us/sql/t-sql/queries/from-using-pivot-and-unpivot?view=sql-server-ver17
Resource 2: https://www.youtube.com/watch?v=15xcvVDwfrw
Resource 3: https://www.youtube.com/watch?v=1QdXGxaA-Jo
Resource 4: https://learn.microsoft.com/en-us/sql/t-sql/functions/stdev-transact-sql?view=sql-server-ver17
Resource 5: https://www.youtube.com/watch?v=Eoids7JSPPc
Resource 6: https://learn.microsoft.com/en-us/sql/t-sql/functions/string-agg-transact-sql?view=sql-server-ver17
Resource 7: https://learn.microsoft.com/en-us/sql/t-sql/functions/ntile-transact-sql?view=sql-server-ver17
 
******************************************************************************************************************/

-- SELECT * FROM dbo.exoplanet_hunting;

-- Nathan Kaylor Q1: Which observed stars show the most consistent light curve dips across all measurements?
/*
   A1: This ended up being quite a complex answer for my skill level! The answer
was achieved using the following resources, in addition to AI generation (ChatGPT) to help produce the results.

The hardest part was combining each of the aspects used after understanding them. Other difficulties involved general syntax errors
(and my many typos) and not fully comprehending how each part fit together at first.

DECLARE sets up the variables col_list and @sql, using the max nvarchar which isn't actually 66535, it's 2GB!
Then, for this specific dataset because it's only imported and untouched (no manual INSERT adjustments for clarity)
we needed to set row_id--especially since there's no primary key. This was done with an AS star_id. SELECT ROW_NUMNER() 
generates row_IDs which lets us then assign a random value via (OVER BY (SELECT NULL)). The one caveat/downside to 
utilizing this method is that future data INSERTs can change star_IDs!

UNPIVOT then converts each column's entry into a row for better clarity and to match the use case. Had to learn about this tool,
which seems very useful when a dataset is non-standard.

STRING_AGG takes matching columns (for which the dataset has 100 FLUX_(x) entries) and makes them a singular string
to avoid repitious typing. BIG time saver.

Then we start the overall string, which begins at N' (row 57) and ends at '; (row 87). This was a major "ah-ha!" moment for me
as I was learning, because N sets it up as nvarchar and then allows the entire string to exedcute as a single command to run.

I next renamed the LABEL AS planetary_system_indication as LABEL isn't super clear. A value of (1) means no star or orbiting planets,
a value of (2) means the light FLUX was indicative of a confirmed star or planetary system.

STDEV is a numeric expression used to aproxximate numeric data types, which is PERFECT for this dataset type.

TO READ THIS DATA:
-- mean_flux:
    this is the overall dip structure for stars, showing roughly 
    where the star's brightness sits on average.
-- standard_flux:
    This shows "how steady are the dips of mean_flux," which helps to view whether it's clean
    and repeatable, or if it is bouncing and inconsistent (variability of the FLUX).
    Confirmed planets (2) will have higher standard_flux
    Unconfirmed planets (1) will have lower standard_flux
-- pct_below_zero:
    This is FLUX relative to the baseline of 0, where the value is calculated as time spent
    below 0 which would indicate a dip or possible planet passing in front of the star 
    producing the light.
    Higher pct_below_zero shows frequent dimming and possible multiple large planets (or just an active system).
    Lower pct_below_zero shows steadier light curves, where it's unlikely there's planets or orbital events.

*/

DECLARE @col_list nvarchar(max);
DECLARE @sql      nvarchar(max);

SELECT @col_list = STRING_AGG(QUOTENAME(name), ',')
FROM sys.columns
WHERE object_id = OBJECT_ID(N'dbo.exoplanet_hunting')
  AND name LIKE N'FLUX[_]%'   
;

SET @sql = N'
WITH curves AS (
  SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS star_id, 
  LABEL AS planetary_system_indication,
  *
  FROM dbo.exoplanet_hunting
),
unpivoted AS (
  SELECT star_id, planetary_system_indication, u.flux
  FROM
  (
      SELECT star_id, planetary_system_indication, ' + @col_list + N'
      FROM curves
  ) AS src
  UNPIVOT (flux FOR flux_col IN (' + @col_list + N')) AS u
),
stats AS (
  SELECT
      star_id,
      MIN(planetary_system_indication) AS planetary_system_indication,
      AVG(CAST(flux AS float))    AS mean_flux,
      STDEV(CAST(flux AS float))  AS standard_flux,
      SUM(CASE WHEN flux < 0 THEN 1 ELSE 0 END)*1.0/COUNT(*) AS pct_below_zero
  FROM unpivoted
  GROUP BY star_id
)
SELECT TOP (10)
    star_id, planetary_system_indication, mean_flux, standard_flux, pct_below_zero
FROM stats
WHERE mean_flux < 0                
ORDER BY standard_flux ASC,             
         mean_flux ASC;           
';

EXEC sys.sp_executesql @sql;

-- Nathan Kaylor Q2: Can we identify the highest peaks and lowest valleys of flux variations across all 100 rows in the dataset?

-- A2: Pretty straight forward! This one used a temp table and drops IF EXISTS before hand for reapeatability.

DECLARE @col_list_1 nvarchar(max);
DECLARE @sql_1      nvarchar(max);

SELECT @col_list_1 = STRING_AGG(QUOTENAME(name), ',')
FROM sys.columns
WHERE object_id = OBJECT_ID(N'dbo.exoplanet_hunting')
  AND name LIKE N'FLUX[_]%';

DROP TABLE IF EXISTS #flux;
CREATE TABLE #flux
(
  star_id                        int       NOT NULL,
  planetary_system_indication    int       NOT NULL,
  flux_col                       sysname   NOT NULL,
  flux                           float     NOT NULL
);

SET @sql_1 = N'
WITH curves AS (
  SELECT
      ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS star_id,
      LABEL AS planetary_system_indication,
      ' + @col_list_1 + N'
  FROM dbo.exoplanet_hunting
),
unpivoted AS (
  SELECT star_id, planetary_system_indication, flux_col, flux
  FROM (SELECT star_id, planetary_system_indication, ' + @col_list_1 + N' FROM curves) AS src
  UNPIVOT (flux FOR flux_col IN (' + @col_list_1 + N')) AS u
)
INSERT INTO #flux (star_id, planetary_system_indication, flux_col, flux)
SELECT star_id, planetary_system_indication, flux_col, flux
FROM unpivoted;
';

EXEC sys.sp_executesql @sql_1;

SELECT TOP (10)
    'PEAK' AS kind, star_id, planetary_system_indication, flux_col, flux
FROM #flux
ORDER BY flux DESC;

SELECT TOP (10)
    'VALLEY' AS kind, star_id, planetary_system_indication, flux_col, flux
FROM #flux
ORDER BY flux ASC;

SELECT
    MIN(flux) AS min_flux,
    MAX(flux) AS max_flux,
    AVG(flux) AS avg_flux
FROM #flux;

-- Nathan Kaylor Q3: Which flux entries showcase the widest variations across observations
-- and how do these compare to flux entries that remain mostly stable?

DECLARE @topN int = 10;

DROP TABLE IF EXISTS #var_col;
SELECT
    flux_col,
    STDEV(CAST(flux AS float)) AS standard_flux_col,
    AVG(CAST(flux AS float))   AS mean_flux_col,
    MIN(CAST(flux AS float))   AS min_flux_col,
    MAX(CAST(flux AS float))   AS max_flux_col,
    COUNT(*)                   AS n
INTO #var_col
FROM #flux
GROUP BY flux_col;

SELECT TOP (@topN)
    'MOST_VARIABLE' AS kind,
    flux_col,
    standard_flux_col,
    mean_flux_col,
    min_flux_col,
    max_flux_col,
    n
FROM #var_col
ORDER BY standard_flux_col DESC;

SELECT TOP (@topN)
    'MOST_STABLE' AS kind,
    flux_col,
    standard_flux_col,
    mean_flux_col,
    min_flux_col,
    max_flux_col,
    n
FROM #var_col
ORDER BY standard_flux_col ASC;

-- Q4: Are there correlations between stellar brightness categories and frequency of light curve anomalies?

/*
    A4: creates the table #per_star, then finds average state using STDEV. Casting as float was required for functionality,
    performing the script with cast AS float removed causes some math errors otherwise. This is plottable as a graph
    which is why the variables used refer to x and y, with s pulling from the overall values of the temp tables.

*/

DROP TABLE IF EXISTS #per_star;
SELECT
    star_id,
    AVG(CAST(flux AS float))   AS mean_flux_star,
    STDEV(CAST(flux AS float)) AS standard_flux_star,
    SUM(CASE WHEN flux < 0 THEN 1 ELSE 0 END)*1.0/COUNT(*) AS anomaly_rate
INTO #per_star
FROM #flux
GROUP BY star_id;

DROP TABLE IF EXISTS #labeled;
SELECT
    star_id,
    mean_flux_star,
    standard_flux_star,
    anomaly_rate,
    CASE NTILE(3) OVER (ORDER BY mean_flux_star)
        WHEN 1 THEN 'Dim'
        WHEN 2 THEN 'Medium'
        ELSE 'Bright'
    END AS brightness_category
INTO #labeled
FROM #per_star;

SELECT
    'CATEGORY_SUMMARY' AS result,
    brightness_category,
    COUNT(*)                        AS total_star_aggregate,
    AVG(mean_flux_star)             AS avg_mean_flux,
    AVG(standard_flux_star)         AS avg_standard_flux,
    AVG(anomaly_rate)               AS avg_anomaly_rate
FROM #labeled
GROUP BY brightness_category
ORDER BY CASE brightness_category WHEN 'Dim' THEN 1 WHEN 'Medium' THEN 2 ELSE 3 END;

SELECT
    'PEARSON_R' AS result,
    CAST( (s.n*s.sum_xy - s.sum_x*s.sum_y)
          / NULLIF(
                SQRT( (s.n*s.sum_x2 - s.sum_x*s.sum_x)
                    * (s.n*s.sum_y2 - s.sum_y*s.sum_y) ), 0) AS float) AS r
FROM (
    SELECT
        COUNT(*)*1.0                      AS n,
        SUM(mean_flux_star)               AS sum_x,
        SUM(anomaly_rate)                 AS sum_y,
        SUM(mean_flux_star*anomaly_rate)  AS sum_xy, 
        SUM(mean_flux_star*mean_flux_star) AS sum_x2,
        SUM(anomaly_rate*anomaly_rate)     AS sum_y2
    FROM #per_star
) AS s;
