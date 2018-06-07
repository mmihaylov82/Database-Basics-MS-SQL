USE SoftUni

-- 1. --
SELECT FirstName, LastName
  FROM Employees
 WHERE LEFT(FirstName, 2) = 'SA'

 -- 2. --
 SELECT FirstName, LastName
  FROM Employees
 WHERE CHARINDEX('ei', LastName, 0) != 0

 -- 3. --
 SELECT FirstName
   FROM Employees
  WHERE DepartmentID IN (3, 10) AND DATEPART(YEAR, HireDate) BETWEEN 1995 AND 2005

 -- 4. --
SELECT FirstName, LastName
  FROM Employees
 WHERE CHARINDEX('engineer', JobTitle, 0) = 0

 -- 5. --
 SELECT [Name]
   FROM Towns
  WHERE LEN(Name) IN (5,6)
ORDER BY [Name]

-- 6. --
SELECT * 
  FROM Towns
 WHERE LEFT([Name], 1) IN ('M', 'K', 'B', 'E')
ORDER BY [Name]

-- 7. --
SELECT * 
  FROM Towns
 WHERE [Name] LIKE '[^RBD]%'
ORDER BY [Name]
GO

-- 8. --
CREATE VIEW V_EmployeesHiredAfter2000 AS
SELECT FirstName, LastName
  FROM Employees
 WHERE DATEPART(YEAR, HireDate) > 2000
GO

-- 9. --
SELECT FirstName, LastName
  FROM Employees
 WHERE LEN(LastName) = 5

-- 10. --
USE Geography

SELECT CountryName AS [Country Name], IsoCode AS [ISO Code]
  FROM Countries
 WHERE CountryName LIKE '%a%a%a%'
 ORDER BY IsoCode

 -- 11. --
SELECT p.PeakName, r.RiverName, LOWER(p.PeakName + SUBSTRING(r.RiverName, 2, LEN(r.RiverName) - 1)) AS Mix
  FROM Peaks AS p
  JOIN Rivers AS r
    ON RIGHT(p.PeakName, 1) = LEFT(r.RiverName, 1)
ORDER BY Mix

-- 12. --
USE Diablo

SELECT TOP(50) [Name], FORMAT([Start], 'yyyy-MM-dd') AS [Start]
  FROM Games
 WHERE DATEPART(YEAR, [Start]) IN (2011, 2012)
ORDER BY [Start] ASC, [Name] ASC

-- 13. --
SELECT Username, SUBSTRING(Email, CHARINDEX('@', Email, 1) + 1, LEN(Email)) AS [Email Provider]
  FROM Users
ORDER BY [Email Provider], Username

-- 14. --
SELECT Username, IpAddress AS [IP Address]
  FROM Users
 WHERE IpAddress LIKE '___.1%.%.___'
ORDER BY Username

-- 15. --
USE Diablo

SELECT [Name] AS Game,
	   CASE
			WHEN DATEPART(HOUR, [Start]) >= 0 AND DATEPART(HOUR, [Start]) < 12 THEN 'Morning'
			WHEN DATEPART(HOUR, [Start]) >= 12 AND DATEPART(HOUR, [Start]) < 18 THEN 'Afternoon'
	   ELSE 'Evening'
	   END AS [Part of the Day],

	   CASE
			WHEN Duration <= 3 THEN 'Extra Short'
			WHEN Duration BETWEEN 4 AND 6 THEN 'Short'
			WHEN Duration > 6 THEN 'Long'
			ELSE 'Extra Long'
	   END AS [Duration]
    FROM Games
ORDER BY [Name], [Duration]

-- 16. --
USE Orders

SELECT * FROM Orders

SELECT ProductName,
	   OrderDate,
	   DATEADD(DAY, 3, OrderDate) AS [Pay Due],
	   DATEADD(MONTH, 1, OrderDate) AS [Deliver Due]
  FROM Orders

-- 17. --
CREATE TABLE People (
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(50) NOT NULL,
	Birthdate DATETIME NOT NULL
)

INSERT INTO People VALUES
('Viktor', '2000-12-07'),
('Steven', '1992-09-10'),
('Stephen', '1910-09-19'),
('John', '2010-01-06')

SELECT [Name],
	DATEDIFF(YEAR, Birthdate, GETDATE()) AS [Age in Years],
	DATEDIFF(MONTH, Birthdate, GETDATE()) AS [Age in Months],
	DATEDIFF(DAY, Birthdate, GETDATE()) AS [Age in Days],
	DATEDIFF(MINUTE, Birthdate, GETDATE()) AS [Age in Minutes]
 FROM People