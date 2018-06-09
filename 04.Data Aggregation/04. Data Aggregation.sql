USE Gringotts

SELECT * FROM WizzardDeposits

-- 1. --
SELECT COUNT(w.Id) AS Count
  FROM WizzardDeposits AS w

-- 2. --
SELECT MAX(w.MagicWandSize) AS LongestMagicWand
  FROM WizzardDeposits AS w

-- 3. --
SELECT (w.DepositGroup) AS DepositGroup,
	   MAX(w.MagicWandSize) AS LongestMagicWand
  FROM WizzardDeposits AS w
GROUP BY w.DepositGroup

-- 4. --
SELECT TOP (2) DepositGroup
  FROM WizzardDeposits
GROUP BY DepositGroup
ORDER BY AVG(MagicWandSize)

-- 5. --
SELECT DepositGroup,
	   SUM(DepositAmount) AS TotalSum
  FROM WizzardDeposits
GROUP BY DepositGroup

-- 6. --
SELECT DepositGroup,
	   SUM(DepositAmount) AS TotalSum
  FROM WizzardDeposits
 WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup

-- 7. --
SELECT DepositGroup,
	   SUM(DepositAmount) AS TotalSum
  FROM WizzardDeposits
 WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup
HAVING SUM(DepositAmount) < 150000
ORDER BY TotalSum DESC

-- 8. --
SELECT DepositGroup,
	   MagicWandCreator,
	   MIN(DepositCharge) AS MinDepositCharge
  FROM WizzardDeposits
GROUP BY DepositGroup, MagicWandCreator
ORDER BY MagicWandCreator, DepositGroup

-- 9. --
SELECT *,
	   COUNT(*) AS WizardCount
  FROM (
		SELECT
			CASE
				WHEN Age BETWEEN 0 AND 10 THEN '[0-10]'
				WHEN Age BETWEEN 11 AND 20 THEN '[11-20]'
				WHEN Age BETWEEN 21 AND 30 THEN '[21-30]'
				WHEN Age BETWEEN 31 AND 40 THEN '[31-40]'
				WHEN Age BETWEEN 41 AND 50 THEN '[41-50]'
				WHEN Age BETWEEN 51 AND 60 THEN '[51-60]'
				ELSE '[61+]'
			END AS AgeGroup
			FROM WizzardDeposits 
		) AS AgeGroupsTable
GROUP BY AgeGroup
ORDER BY AgeGroup

-- 10. --
SELECT LEFT(FirstName, 1) AS FirstLetter
  FROM WizzardDeposits
 WHERE DepositGroup = 'Troll Chest'
GROUP BY LEFT(FirstName, 1)
ORDER BY FirstLetter

-- 11. --
SELECT DepositGroup, IsDepositExpired, AVG(DepositInterest) AS AverageInterest
  FROM WizzardDeposits
 WHERE DepositStartDate > '01-01-1985'
GROUP BY DepositGroup, IsDepositExpired
ORDER BY DepositGroup DESC, IsDepositExpired

-- 12. --
SELECT SUM(Difference)
  FROM (
		SELECT w1.FirstName AS [Host Wizard],
			   w1.DepositAmount AS [Host Wizard Deposit],
			   w2.FirstName AS [Guest Wizard],
			   w2.DepositAmount AS [Guest Wizard Deposit],
			   w1.DepositAmount - w2.DepositAmount AS Difference
		  FROM WizzardDeposits as w1
		INNER JOIN WizzardDeposits AS w2
		ON w1.Id = w2.Id -1) AS t

-- 13. --
USE SoftUni

SELECT DepartmentID, SUM(Salary) AS TotalSalary
  FROM Employees
GROUP BY DepartmentID
ORDER BY DepartmentID

-- 14. --
SELECT * FROM Employees

SELECT DepartmentID,
	   MIN(Salary) AS MinimumSalary
  FROM Employees
 WHERE DepartmentID IN (2, 5, 7) AND HireDate > '01-01-2000'
GROUP BY DepartmentID

-- 15. --
SELECT *
  INTO EmployeesWithHigherThan30000
  FROM Employees
 WHERE Salary > 30000

DELETE FROM EmployeesWithHigherThan30000
WHERE ManagerID = 42

UPDATE EmployeesWithHigherThan30000
   SET Salary += 5000
 WHERE DepartmentID = 1

SELECT DepartmentID, 
	   AVG(Salary) AS AverageSalary
  FROM EmployeesWithHigherThan30000
GROUP BY DepartmentID

-- 16. --
SELECT DepartmentID,
       MAX(Salary) AS MaxSalary
  FROM Employees
GROUP BY DepartmentID
HAVING MAX(Salary) NOT BETWEEN 30000 AND 70000

-- 17. --
SELECT COUNT(*) AS [Count]
  FROM Employees
 WHERE ManagerID IS NULL

 -- 18. --
SELECT DISTINCT DepartmentID, Salary
  FROM (
		SELECT DepartmentID, Salary,
			   DENSE_RANK() OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS SalaryRank
		  FROM Employees
	   ) AS e
 WHERE SalaryRank = 3

-- 19. --
SELECT TOP (10) FirstName, LastName, DepartmentID
  FROM Employees AS e1
 WHERE Salary > (
		SELECT AVG(Salary)
		FROM Employees AS e2
		WHERE e1.DepartmentID = e2.DepartmentID
	    GROUP BY DepartmentID
 )