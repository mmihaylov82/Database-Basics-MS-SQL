USE SoftUni

-- 1. --
SELECT TOP(5) e.EmployeeID, e.JobTitle, e.AddressID, a.AddressText
  FROM Employees AS e
  JOIN Addresses AS a ON e.AddressID = a.AddressID
ORDER BY e.AddressID

-- 2. --
SELECT TOP(50) e.FirstName, e.LastName, t.Name AS Town, a.AddressText
  FROM Employees AS e
  JOIN Addresses AS a ON e.AddressID = a.AddressID
  JOIN Towns AS t ON a.TownID = t.TownID
ORDER BY e.FirstName, e.LastName

-- 3. --
SELECT e.EmployeeID, e.FirstName, e.LastName, d.Name AS DepartmentName
  FROM Employees AS e
  JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
 WHERE d.Name = 'Sales'
ORDER BY e.EmployeeID

-- 4. --
SELECT TOP(5) e.EmployeeID, e.FirstName, e.Salary, d.Name AS DepartmentName
  FROM Employees AS e
  JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
 WHERE e.Salary > 15000
ORDER BY e.DepartmentID

-- 5. --
SELECT DISTINCT TOP(3) e.EmployeeID, e.FirstName 
  FROM Employees as e
  JOIN EmployeesProjects AS ep ON e.EmployeeID NOT IN (
				SELECT DISTINCT EmployeeID 
				  FROM EmployeesProjects)
ORDER BY e.EmployeeID

-- 6. --
SELECT e.FirstName, e.LastName, e.HireDate, d.Name AS DeptName
  FROM Employees AS e
  JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
 WHERE e.HireDate > '1-1-1999' AND d.Name IN ('Sales','Finance')
 ORDER BY e.HireDate

 -- 7. --
SELECT TOP(5) e.EmployeeID, e.FirstName, p.[Name] AS [ProjectName]
  FROM Employees AS e
  JOIN EmployeesProjects AS ep ON ep.EmployeeID = e.EmployeeID
  JOIN Projects AS p ON (p.ProjectID = ep.ProjectID AND p.EndDate IS NULL AND p.StartDate > '08-13-2002')
ORDER BY e.EmployeeID

-- 8. --
SELECT e.EmployeeID,
	   e.FirstName,
	   CASE
			WHEN p.StartDate >= '01-01-2005' THEN NULL
			ELSE p.Name
	   END AS ProjectName	   
  FROM Employees AS e
  JOIN EmployeesProjects AS ep ON ep.EmployeeID = e.EmployeeID AND e.EmployeeID = 24
  JOIN Projects AS p ON p.ProjectID = ep.ProjectID

-- 9. --
SELECT e.EmployeeID, e.FirstName, e.ManagerID, mng.FirstName AS ManagerName
  FROM Employees AS e
  JOIN Employees AS mng ON (mng.EmployeeID = e.ManagerID AND e.ManagerID IN (3, 7))
ORDER BY e.EmployeeID

-- 10. --
SELECT TOP(50) e.EmployeeID,
	   e.FirstName + ' ' + e.LastName AS EmployeeName,
	   m.FirstName + ' ' + m.LastName AS ManagerName,
	   d.Name AS DepartmentName
  FROM Employees AS e
  JOIN Employees AS m ON m.EmployeeID = e.ManagerID
  JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
ORDER BY e.EmployeeID

-- 11. --
SELECT MIN(AvgSalaries.AvgSalary) AS MinAverageSalary
  FROM (
		SELECT AVG(e.Salary) AS AvgSalary
		FROM Employees AS e
		GROUP BY e.DepartmentID
	   ) AS AvgSalaries

-- 12. --
USE Geography

SELECT c.CountryCode, m.MountainRange, p.PeakName, p.Elevation 
  FROM Countries as c
  JOIN MountainsCountries as mc ON (mc.CountryCode = c.CountryCode AND c.CountryCode = 'BG')
  JOIN Mountains as m ON m.Id = mc.MountainId
  JOIN Peaks as P ON (p.MountainId = m.Id AND p.Elevation > 2835)
ORDER BY p.Elevation DESC

-- 13. --
SELECT c.CountryCode, COUNT(m.MountainRange)
  FROM Countries as c
  JOIN MountainsCountries as mc ON (mc.CountryCode = c.CountryCode AND c.CountryCode IN ('BG', 'RU', 'US'))
  JOIN Mountains as m ON m.Id = mc.MountainId
GROUP BY c.CountryCode

-- 14. --
SELECT TOP(5) c.CountryName, r.RiverName
  FROM Countries as c
  LEFT JOIN CountriesRivers as cr ON (cr.CountryCode = c.CountryCode)
  LEFT JOIN Rivers as r ON r.Id = cr.RiverId
  JOIN Continents AS cont ON cont.ContinentCode = c.ContinentCode AND cont.ContinentCode = 'AF'
ORDER BY c.CountryName

-- 15. --
WITH CTE_CountriesInfo (ContinentCode, CurrencyCode, CurrencyUsage) AS 
(
	SELECT ContinentCode, CurrencyCode, COUNT(CurrencyCode) AS CurrencyUsage
      FROM Countries
  GROUP BY ContinentCode, CurrencyCode
   HAVING COUNT(CurrencyCode) > 1
)

SELECT e.ContinentCode, cci.CurrencyCode, e.MaxCurrency AS CurrencyUsage
  FROM (
		 SELECT ContinentCode, MAX(CurrencyUsage) AS MaxCurrency 
		 FROM CTE_CountriesInfo
		 GROUP BY ContinentCode 
	   ) AS e
  JOIN CTE_CountriesInfo AS cci ON (cci.ContinentCode = e.ContinentCode AND cci.CurrencyUsage = e.MaxCurrency)

-- 16. --
SELECT COUNT(*) AS CountryCode
  FROM Countries AS c
  LEFT JOIN MountainsCountries AS mc ON mc.CountryCode = c.CountryCode
  WHERE mc.MountainId IS NULL

-- 17. --
SELECT TOP(5) c.CountryName, MAX(p.Elevation) AS HighestPeakElevation, MAX(r.[Length]) AS LongestRiverLength
  FROM Countries AS c
LEFT JOIN MountainsCountries AS mc ON mc.CountryCode = c.CountryCode
LEFT JOIN Peaks AS p ON p.MountainId = mc.MountainId
LEFT JOIN CountriesRivers AS cr ON cr.CountryCode = c.CountryCode
LEFT JOIN Rivers AS r ON r.Id = cr.RiverId
GROUP BY c.CountryName
ORDER BY HighestPeakElevation DESC, LongestRiverLength DESC, c.CountryName
  
-- 18. --
WITH CTE_CountriesInfo (CountryName, PeakName, Elevation, Mountain) AS (
SELECT c.CountryName, p.PeakName, MAX(p.Elevation), m.MountainRange
  FROM Countries AS c
LEFT JOIN MountainsCountries AS mc ON mc.CountryCode = c.CountryCode
LEFT JOIN Mountains AS m ON m.Id = mc.MountainId
LEFT JOIN Peaks AS p ON p.MountainId = m.Id
GROUP BY c.CountryName, p.PeakName, m.MountainRange)

SELECT TOP(5) e.CountryName, 
	   ISNULL(cci.PeakName,'(no highest peak)'), 
	   ISNULL(cci.Elevation,0), 
	   ISNULL(cci.Mountain,'(no mountain)')
  FROM (
		SELECT CountryName, MAX(Elevation) AS MaxElevation
		FROM CTE_CountriesInfo
        GROUP BY CountryName) AS e 
LEFT JOIN CTE_CountriesInfo AS cci ON cci.CountryName = e.CountryName AND cci.Elevation = e.MaxElevation
ORDER BY e.CountryName, cci.PeakName