-- Q: How to extract first name from Contact Name?

-- A: Well, here is your problem...
-- CustomerName = Alejandra Camino -> Alejandra
-- Google search "How to extract first name from combined name tsql stack overflow"

SELECT t.ContactName
	FROM dbo.t_w3_schools_customers AS t
	ORDER BY 1;