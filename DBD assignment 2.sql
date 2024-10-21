--QUESTION 1--
USE AdventureWorks2019
SELECT DISTINCT 
		HumanResources.Employee.BusinessEntityID,
		NationalIDNumber AS 'NationalID',
		Person.Person.FirstName,
		Person.Person.LastName,
		HumanResources.Department.Name AS 'Department',
		JobTitle
FROM HumanResources.EmployeeDepartmentHistory
JOIN HumanResources.Department
	ON HumanResources.Department.DepartmentID = HumanResources.EmployeeDepartmentHistory.DepartmentID
JOIN Person.Person
	ON Person.Person.BusinessEntityID = HumanResources.EmployeeDepartmentHistory.BusinessEntityID
JOIN HumanResources.Employee
	ON HumanResources.Employee.BusinessEntityID = Person.Person.BusinessEntityID
WHERE HumanResources.Employee.OrganizationLevel = 1

--QUESTION 2---
USE AdventureWorks2019
GO
WITH PurchaseOrders AS (
SELECT	soh.ShipMethodID, 
		SUM(soh.TotalDue) AS PurchaseTotal
FROM	Purchasing.PurchaseOrderHeader poh
JOIN	Purchasing.ShipMethod sm 
		ON poh.ShipMethodID = sm.ShipMethodID
JOIN Sales.SalesOrderHeader soh 
		ON sm.ShipMethodID = soh.ShipMethodID
GROUP BY soh.ShipMethodID),

WITH SalesOrders AS (
SELECT	soh.ShipMethodID, 
		SUM(soh.TotalDue) AS SalesTotal
FROM	Sales.SalesOrderHeader soh
JOIN	Purchasing.ShipMethod sm 
		ON soh.ShipMethodID = sm.ShipMethodID
LEFT JOIN Purchasing.PurchaseOrderHeader poh 
		ON sm.ShipMethodID = poh.ShipMethodID
GROUP BY
      soh.ShipMethodID
  )
SELECT 
  pm.ShipMethodID, 
  pm.Name, 
  ROUND(ISNULL(po.PurchaseTotal, 0), 2) AS PurchaseTotal, 
  ROUND(ISNULL(so.SalesTotal, 0), 2) AS SalesTotal
FROM		Purchasing.ShipMethod pm
LEFT JOIN	PurchaseOrders po 
		ON	pm.ShipMethodID = po.ShipMethodID
LEFT JOIN SalesOrders so 
		ON	pm.ShipMethodID = so.ShipMethodID;
GO

--QUESTION 3--

SELECT	Title,
		FirstName,
		LastName,
CASE PersonType 
	WHEN 'SC' THEN 'Store Contact'
	WHEN 'IN' THEN 'Individual Customer'
	WHEN 'SP' THEN 'Sales Person'
	WHEN 'EM' THEN 'Employee'
	WHEN 'VC' THEN 'Vendor Contact'
	WHEN 'GC' THEN 'General Contact'
ELSE ''
END AS 'PersonType'
FROM Person.Person

--QUESTION 4--
USE AdventureWorks2019
GO
DECLARE @productId INT = 707;

SELECT 
    p.ProductNumber AS 'Product Number',
    p.Name AS 'Product Name',
    soh.Description AS 'Special Offers'
FROM 
    Production.Product AS p
    JOIN Sales.SpecialOfferProduct AS sop ON p.ProductID = sop.ProductID
    JOIN Sales.SpecialOffer AS so ON sop.SpecialOfferID = so.SpecialOfferID
    JOIN Sales.SpecialOffer AS soh ON so.SpecialOfferID = soh.SpecialOfferID
WHERE 
    p.ProductID = @productId
ORDER BY 
    soh.StartDate;
GO


--QUESTION 5--
USE AdventureWorks2019;
GO
CREATE VIEW vwStoreSales
AS
SELECT	s.CustomerID, 
		st.Name AS StoreName, 
		YEAR(o.OrderDate) AS OrderYear,
		ROUND(SUM(o.TotalDue), 2) AS TotalSales
FROM Sales.Customer s
JOIN Sales.Store st 
		ON s.StoreID = st.BusinessEntityID
JOIN Sales.SalesOrderHeader o 
		ON s.CustomerID = o.CustomerID
GROUP BY s.CustomerID, st.Name, YEAR(o.OrderDate);
GO
SELECT CustomerID, StoreName, OrderYear, TotalSales
FROM vwStoreSales
WHERE TotalSales > 100000
ORDER BY CustomerID ASC, OrderYear DESC;