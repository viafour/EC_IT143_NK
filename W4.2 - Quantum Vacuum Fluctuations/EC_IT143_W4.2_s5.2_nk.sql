DROP TABLE IF EXISTS dbo.t_quantum_avg_baseline;
GO

CREATE TABLE dbo.t_quantum_avg_baseline
(
    row_id       INT IDENTITY(1,1) NOT NULL,
    avg_baseline FLOAT             NOT NULL,
    CONSTRAINT PK_t_quantum_avg_baseline
        PRIMARY KEY CLUSTERED (row_id)
);
GO