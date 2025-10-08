/*****************************************************************************************************************
NAME:    Quantum Fluctuation Review
PURPOSE: Quantify data held within dbo.quantum_vacuum_fluctuations and provide answers to questions.

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     10/04/2025   NKAYLOR       1. Built this script for EC IT143


RUNTIME: 
~2s

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

-- Nathan Kaylor Q5: How random are the fluctuation values across all fields when measured with entropy tests?

/* 
    A5:
    This question ended up being far beyond my ability, to the point that I will not be answering it as I felt
    incapable of either doing it alone or with the help of resources/generative AI. Most of what is used I'm able
    to effectively read and identify, especially portions that were used previously. However the amount of dynamic SQL
    used to complete the prompt was more than I could follow well.

    I did end up looking into Shannon entropy and other methods of testing which was very interesting--hope to come back to 
    them in future math or data science classes, though I realize now that basing a question off of industry experience may not
    always be the best course of action! We've talked about NIST SP 800-90B at work, which I assumed was something more replicable.

    All said, generative AI was able to produce a functional result which I will include COMMENTED OUT,
    then select a new question that is more feasible for myself.

            DECLARE @bins int = 64;  -- Try 32/64/128 depending on how many rows you have
            DECLARE @col_list  nvarchar(max);
            DECLARE @cast_list nvarchar(max);
            DECLARE @sql       nvarchar(max);

            -- Build lists of the fluctuation columns and a CAST-to-float projection
            SELECT
              @col_list  = STRING_AGG(QUOTENAME(name), ','),
              @cast_list = STRING_AGG('TRY_CONVERT(float,' + QUOTENAME(name) + ') AS ' + QUOTENAME(name), ',')
            FROM sys.columns
            WHERE object_id = OBJECT_ID(N'dbo.quantum_vacuum_fluctuations')
              AND name LIKE N'column%';

            -- Tall table of all values (sample_id, field, value) with consistent float types
            IF OBJECT_ID('tempdb..#qvf') IS NOT NULL DROP TABLE #qvf;
            CREATE TABLE #qvf
            (
              sample_id int     NOT NULL,
              field     sysname NOT NULL,
              value     float   NULL
            );

            SET @sql = N'
            WITH typed AS (
              SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS sample_id, ' + @cast_list + N'
              FROM dbo.quantum_vacuum_fluctuations
            ),
            u AS (
              SELECT sample_id, field, value
              FROM typed
              UNPIVOT (value FOR field IN (' + @col_list + N')) AS up
            )
            INSERT INTO #qvf(sample_id, field, value)
            SELECT sample_id, field, value
            FROM u
            WHERE value IS NOT NULL;  -- discard non-numeric / failed converts
            ';
            EXEC sys.sp_executesql @sql;

            ----------------------------------------------------------------------
            -- Entropy per field (each column separately)
            ----------------------------------------------------------------------

            DROP TABLE IF EXISTS #field_stats;
            SELECT
              field,
              COUNT(*) AS n,
              MIN(value) AS vmin,
              MAX(value) AS vmax
            INTO #field_stats
            FROM #qvf
            GROUP BY field;

            DROP TABLE IF EXISTS #binned_field;
            SELECT
              q.field,
              q.sample_id,
              CASE
                WHEN fs.vmax = fs.vmin THEN 0
                WHEN q.value = fs.vmax THEN @bins-1
                ELSE CAST(FLOOR( (q.value - fs.vmin) / NULLIF(fs.vmax - fs.vmin,0) * @bins ) AS int)
              END AS bin
            INTO #binned_field
            FROM #qvf AS q
            JOIN #field_stats AS fs
              ON fs.field = q.field;

            DROP TABLE IF EXISTS #bin_counts_field;
            SELECT field, bin, COUNT(*) AS cnt
            INTO #bin_counts_field
            FROM #binned_field
            GROUP BY field, bin;

            DROP TABLE IF EXISTS #entropy_field;
            SELECT
              bc.field,
              fs.n AS samples,
              SUM( - (bc.cnt * 1.0 / fs.n) * (LOG(bc.cnt * 1.0 / fs.n) / LOG(2.0)) ) AS H_bits,
              MAX(   bc.cnt * 1.0 / fs.n )                                             AS p_max
            INTO #entropy_field
            FROM #bin_counts_field AS bc
            JOIN #field_stats      AS fs ON fs.field = bc.field
            GROUP BY bc.field, fs.n;

            -- Per-field results
            SELECT
              'PER_FIELD' AS scope,
              field,
              samples,
              H_bits,
              H_bits / (LOG(@bins)/LOG(2.0)) AS H_norm_0_1,     -- 1.0 ≈ uniform (more random)
              -LOG(p_max)/LOG(2.0)           AS H_min_bits      -- conservative lower bound
            FROM #entropy_field
            ORDER BY field;

            ----------------------------------------------------------------------
            -- Entropy across all fields combined (global distribution)
            ----------------------------------------------------------------------

            DECLARE @N    float, @Vmin float, @Vmax float;
            SELECT @N = COUNT(*), @Vmin = MIN(value), @Vmax = MAX(value) FROM #qvf;

            DROP TABLE IF EXISTS #binned_all;
            SELECT
              q.sample_id,
              q.field,
              CASE
                WHEN @Vmax = @Vmin THEN 0
                WHEN q.value = @Vmax THEN @bins-1
                ELSE CAST(FLOOR( (q.value - @Vmin) / NULLIF(@Vmax - @Vmin,0) * @bins ) AS int)
              END AS bin
            INTO #binned_all
            FROM #qvf AS q;

            DROP TABLE IF EXISTS #bin_counts_all;
            SELECT bin, COUNT(*) AS cnt
            INTO #bin_counts_all
            FROM #binned_all
            GROUP BY bin;

            -- Global entropy summary
            SELECT
              'GLOBAL' AS scope,
              @N       AS samples,
              SUM( - (cnt*1.0/@N) * (LOG(cnt*1.0/@N)/LOG(2.0)) ) AS H_bits,
              SUM( - (cnt*1.0/@N) * (LOG(cnt*1.0/@N)/LOG(2.0)) )/(LOG(@bins)/LOG(2.0)) AS H_norm_0_1,
              -LOG( (SELECT MAX(cnt*1.0/@N) FROM #bin_counts_all) )/LOG(2.0) AS H_min_bits
            FROM #bin_counts_all;

*/

--  Nathan Kaylor Q5.1 (redone): How many distinct vacuum fluctuations are there across column2?

-- A5.1: this creates a temporary table, then counts the distinct entries and showcases the total occurences

DROP TABLE IF EXISTS #dst_fluctuations;

SELECT
    COUNT(DISTINCT column2) AS unique_fluctuations,
    COUNT(*) As occurrences
INTO #dst_fluctuations
FROM dbo.quantum_vacuum_fluctuations
WHERE column2 IS NOT NULL;

SELECT * FROM #dst_fluctuations;

-- Nathan Kaylor Q6: When clustered together, how many unique fluctuation values appear across all fields in column2?

-- A6: This builds off of Q5 and adds an additional column for the cluster as a ratio.

SELECT
  COUNT(DISTINCT column2)    AS unqiue_fluctuations,
  COUNT(*)                   AS occurences,
  COUNT(DISTINCT column2)*1.0 / NULLIF(COUNT(*),0) AS distinct_ratio
FROM dbo.quantum_vacuum_fluctuations
WHERE TRY_CONVERT(float, column2) IS NOT NULL;

-- Nathan Kaylor Q7: Can we quantify the average variance across all entries in column2 and then compare
-- those results to the highest and lowest observed values?

/* 
    Another ddrop table! What's used here has been used elsewhere, calling operators to find average,
    max, min, and mix-min to showcase a range. Each one is idenitified with its AS statement.

    I ended up reailizing after committing to the dataset that is was rather... inoperable?
    This was determined after reviewing the columns, metadata, and otehr parts that don't describe what column1
    or column2 truly represent. After some digging into the author of the dataset, I've determined that it's
    mostly just noise machine-generated and made to look prevalent. 

    Regardless! We push on with the queries.
*/

DROP TABLE IF EXISTS #avg_variance;
SELECT
  ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn,
  column2 AS c2
INTO #avg_variance
FROM dbo.quantum_vacuum_fluctuations
WHERE column2 IS NOT NULL;

SELECT
  COUNT(*)                  AS occurrences,
  AVG(c2)                   AS mean_value,
  VAR(c2)                   AS variance_sample,      
  STDEV(c2)                 AS stddev_sample,       
  VARP(c2)                  AS variance_population,  
  STDEVP(c2)                AS stddev_population,    
  MIN(c2)                   AS min_value,           
  MAX(c2)                   AS max_value,   
  MAX(c2) - MIN(c2)         AS value_range
FROM #avg_variance;

-- Nathan Kaylor Q8: Is there evidence that these vacuum fluctuations can be modeled
-- or predicted using basic regression or correlation analysis?

/*
    A8: lots of math in this one! This ended up being rathful helpful at work were one of our internal websites that pulls
    from a SQL Server DB ran into an arithmetic overflow error for using smallint and exceeding the maxium value.
    While not directly used in this response, it was something I read about and felt more prepared to handle as a result!
*/

WITH base AS (
  SELECT
    TRY_CONVERT(float, column1) AS time_maybe,
    TRY_CONVERT(float, column2) AS vacuum_fluctuation
  FROM dbo.quantum_vacuum_fluctuations
  WHERE TRY_CONVERT(float, column1) IS NOT NULL
    AND TRY_CONVERT(float, column2) IS NOT NULL
),
stats AS (
  SELECT
    AVG(time_maybe)   AS atm,
    AVG(vacuum_fluctuation)   AS avc,
    STDEV(time_maybe) AS sdtm,
    STDEV(vacuum_fluctuation) AS stvf,
    COUNT(*) AS n
  FROM base
),
sums AS (
  SELECT
    SUM( (b.time_maybe - s.atm) * (b.vacuum_fluctuation - s.avc) )        AS Sxy,  -- covariance numerator
    SUM( (b.time_maybe - s.atm) * (b.time_maybe - s.atm) )        AS Sxx
  FROM base b CROSS JOIN stats s
)
SELECT
  CAST(Sxy / NULLIF(Sxx,0) AS float)                          AS trend_rate,
  CAST(s.avc - (Sxy / NULLIF(Sxx,0)) * s.atm AS float)          AS baseline_value,
  CAST( (Sxy / NULLIF((s.sdtm*s.stvf*(s.n-1)),0)) AS float)       AS correlation_score,
  CAST( POWER((Sxy / NULLIF((s.sdtm*s.stvf*(s.n-1)),0)),2) AS float) AS predictability_score,
  s.n AS n_points
FROM sums CROSS JOIN stats s;