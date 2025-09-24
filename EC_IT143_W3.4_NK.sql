/*****************************************************************************************************************
NAME:    EC_IT143_W3.4_NK
PURPOSE: This script's purpose is to showcase 8 examples of various real-world questions, curated from myself
and fellow classmates in order to produce working results and practice problem solving across the Adventure Works 2022 database.

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     09/23/2022   NKAYLOR       1. Built this script for EC IT143


RUNTIME: 
~0m 1s

NOTES: Not much to note here! This is my script that was created from the 8 questions, six of which belong to fellow classmates
and two of which belong to me! Oh! And run each block independantly (select the section with cursor then F5).
 
******************************************************************************************************************/

-- Q1: What should go here?
-- A1: Question goes on the previous line, intoduction to the answer goes on this line...

SELECT GETDATE() AS my_date;

--------------------------------------------------------------
-- MARGINAL COMPLEXITY
--------------------------------------------------------------

-- Thandile Mayekiso - Q1. What is the list price of the ten cheapest products in AdventureWorks 2022?

/* A1. In order to provide a list of the ten cheapest products in Adventureworks 2022, we would start by selecting the top 10
Products by ProductID, then ordsering them by ListPrice and ProductIDs in ascending order.
*/
SELECT TOP (10)
       p.ProductID,
       p.Name,
       p.ProductNumber,
       p.ListPrice
FROM Production.Product AS p
ORDER BY p.ListPrice ASC, p.ProductID ASC;
GO

-- Thandile Mayekiso - Q2. How many employees are currently working in the Sales department?

/* A2. In order to determine the active (currently so) employees in the Sales department, we want to select distinct 
from the HUmanResources.EmployeeDepartmentHistory (holds current and previous employees) and joining it to HumanResources.Department
to use the DepartmentID. Then, we filter by DepartmentID and IS NULL .
*/

SELECT * FROM HumanResources.EmployeeDepartmentHistory ORDER BY DepartmentID;

SELECT COUNT(DISTINCT edh.BusinessEntityID) AS SalesEmployeeCount
FROM HumanResources.EmployeeDepartmentHistory AS edh
JOIN HumanResources.Department AS d
  ON d.DepartmentID = edh.DepartmentID
WHERE d.Name = 'Sales'
  AND edh.EndDate IS NULL;      
GO


--------------------------------------------------------------
-- MODERATE COMPLEXITY
--------------------------------------------------------------

-- Nathan Kaylor (me!) Q3. I'm putting together a review on several of our products. Can you provide me five of our most
-- expensive products to see if a sale would be valuable?

/* A3. Similar to A1, we're going to select the top 5 results and then order them by price, this time descneding to 
show the most expensive products.
*/

SELECT TOP (5)
       p.ProductID,
       p.Name,
       p.ProductNumber,
       p.ListPrice
FROM Production.Product AS p
WHERE p.ListPrice > 0
ORDER BY p.ListPrice DESC, p.ProductID DESC;
GO

-- Q4. Nathan Kaylor (me!) Q4. We're evaluating sales by store location. Can you show which stores have the greatest amount of customers?

/* A4. The question is a bit vague here--it could be interpreted as either a TOP question, or simply an ORDER BY question.
In this case, I answered by ORDER BY with CustomerCount descending (highest) and SoreName ASC (alphabetical). There's
quite a few duplicate entries, with data that isn't super varied.
*/

SELECT s.BusinessEntityID        AS StoreID,
       s.Name                    AS StoreName,
       COUNT(c.CustomerID)       AS CustomerCount
FROM Sales.Store AS s
JOIN Sales.Customer AS c
  ON c.StoreID = s.BusinessEntityID
GROUP BY s.BusinessEntityID, s.Name
ORDER BY CustomerCount DESC, StoreName ASC;
GO


--------------------------------------------------------------
-- INCREASED COMPEXITY
--------------------------------------------------------------

-- Q5. Clayton Duncan Campbell - Q5: I want to analyze bike orders in Q1 2022. 
-- For each bike model, show quantity sold, list price, standard cost, and estimated net revenue by month.

/* A5. This one was interesting! I may have misunderstood it, but at least the data that I have in my AdventureWorks2022 only goes to 2014!
As such, the query returns no values unless the AND soh.OrderDate >= '2012-01-01' (2014 at a max) is used in place of '2022-01-01'. This query
uses joins in order to display the ProductModelID and then showing the overarching productmodel as the BikeModel iteself (to provide an
aggregate of readable data, rather than hunmdreds or thousands of near-duplicate entries).
*/

SELECT 
    pm.Name AS BikeModel,
    DATEFROMPARTS(YEAR(soh.OrderDate), MONTH(soh.OrderDate), 1) AS MonthStart,
    SUM(sod.OrderQty)                                           AS QtySold,
    AVG(p.ListPrice)                                            AS AvgListPrice,
    AVG(p.StandardCost)                                         AS AvgStandardCost,
    SUM(sod.UnitPrice * (1.0 - sod.UnitPriceDiscount) * sod.OrderQty) AS NetRevenue
FROM Sales.SalesOrderDetail AS sod
JOIN Sales.SalesOrderHeader AS soh
  ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product AS p
  ON p.ProductID = sod.ProductID
LEFT JOIN Production.ProductModel AS pm
  ON pm.ProductModelID = p.ProductModelID
JOIN Production.ProductSubcategory AS psc
  ON psc.ProductSubcategoryID = p.ProductSubcategoryID
JOIN Production.ProductCategory AS pc
  ON pc.ProductCategoryID = psc.ProductCategoryID
WHERE pc.Name = 'Bikes'
  AND soh.OrderDate >= '2012-01-01'
  AND soh.OrderDate <  '2022-04-01'
GROUP BY pm.Name,
         DATEFROMPARTS(YEAR(soh.OrderDate), MONTH(soh.OrderDate), 1)
ORDER BY BikeModel, MonthStart;
GO

-- Clayton Duncan Campbell - Q6: We want to identify employees who manage more than three active projects.
-- Provide employee's name, title, department, and the number of projects they manage.

/* A6. I think this question is unsolvable! So I will not have a formal answer. Instead, I'm going to provide a query to prove
the lack of Project, Task, or Assignment related entries. By using the LIKE operator we search for key words that could
be used to identiy potential project management. The results are empty!

Additionally, I looked through various tables such as Production.WorkOrderRouting, Sales.SalesOrderDetail, Sales.SalesPerson,
and so on, with none of them indicating employees managing active projects.

*/

SELECT s.name AS SchemaName, t.name AS TableName
FROM sys.tables t
JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE t.name LIKE '%Project%' OR t.name LIKE '%Task%' OR t.name LIKE '%Assignment%';

--------------------------------------------------------------
-- METADATA QUESTIONS
--------------------------------------------------------------

-- Gregory Rowe - Q7: You are inspecting the Production.Product table.
-- What is the name of the column that serves as the primary key, what is its data type, and what does it represent?

/* A7. For this answer we setup the variables with AS statements, then poll for PrimaryKeyColumn and DataType, then 
use CAST to convert an expression of one data type to another, in order to produce a value for "what it represents"! (see resource:
https://learn.microsoft.com/en-us/sql/t-sql/functions/cast-and-convert-transact-sql?view=sql-server-ver17)
*/

SELECT 
    c.name AS PrimaryKeyColumn,
    t.name AS DataType,
    CAST(ep.value AS NVARCHAR(500)) AS ColumnDescription
FROM sys.key_constraints AS kc
JOIN sys.index_columns  AS ic
  ON ic.object_id = kc.parent_object_id
 AND ic.index_id  = kc.unique_index_id
JOIN sys.columns AS c
  ON c.object_id = ic.object_id
 AND c.column_id = ic.column_id
JOIN sys.types AS t
  ON t.user_type_id = c.user_type_id
LEFT JOIN sys.extended_properties AS ep
  ON ep.major_id = c.object_id 
 AND ep.minor_id = c.column_id 
 AND ep.name = 'MS_Description'
WHERE kc.parent_object_id = OBJECT_ID('Production.Product')
  AND kc.type = 'PK';
GO

-- Gregory Rowe - Q8: How would you query the database's extended properties or business metadata to find a 
-- human-readable description explaining the difference between the DueDate and ShipDate in each table?

/* A8. For question 8's metadata query, we'll poll similarly to A7 and focus on the MS_Descrption.After settings up variables, we'll check
The SchemaName, TableName, and ColumnName then populate their descriptions! Also same use as CAST in order to do so.
*/

SELECT 
    sch.name AS SchemaName,
    tbl.name AS TableName,
    col.name AS ColumnName,
    CAST(ep.value AS NVARCHAR(599)) AS Description
FROM sys.columns AS col
JOIN sys.tables  AS tbl ON tbl.object_id = col.object_id
JOIN sys.schemas AS sch ON sch.schema_id = tbl.schema_id
LEFT JOIN sys.extended_properties AS ep
  ON ep.major_id = col.object_id 
 AND ep.minor_id = col.column_id 
 AND ep.name = 'MS_Description'
WHERE col.name IN ('DueDate', 'ShipDate')
ORDER BY SchemaName, TableName, ColumnName;
GO