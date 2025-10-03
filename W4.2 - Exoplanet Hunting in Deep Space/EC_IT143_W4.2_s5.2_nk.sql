DROP TABLE IF EXISTS dbo.planetary_systems_count;
GO

CREATE TABLE dbo.planetary_systems_count
(
	row_id							INT IDENTITY (1,1) NOT NULL,
	confirmed_planetary_systems		INT				   NOT NULL,
	possible_planetary_systems		INT				   NOT NULL,

	CONSTRAINT PK_t_planetary_systems_count
		PRIMARY KEY CLUSTERED (row_id),
);
GO