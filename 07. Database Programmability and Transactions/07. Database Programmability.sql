USE SoftUni
GO

-- 1. -- Employees with Salary Above 35000
CREATE PROC usp_GetEmployeesSalaryAbove35000 AS
BEGIN
	SELECT FirstName, LastName
	  FROM Employees
	 WHERE Salary > 35000
END
GO

-- 2. -- Employees with Salary Above Number
CREATE PROC usp_GetEmployeesSalaryAboveNumber (@inputNumber DECIMAL(18,4)) AS
BEGIN
	SELECT FirstName, LastName
	  FROM Employees
	 WHERE Salary >= @inputNumber
END
GO

-- 3. -- Town Names Starting With
CREATE PROC usp_GetTownsStartingWith (@inputText VARCHAR(50)) AS 
BEGIN
	SELECT [Name]
	FROM Towns
	WHERE [Name] LIKE @inputText + '%'
END

EXEC usp_GetTownsStartingWith 'b'
GO

-- 4. -- Employees from Town
CREATE PROC usp_GetEmployeesFromTown (@townName VARCHAR(20)) AS
BEGIN
	SELECT FirstName, LastName
	  FROM Employees AS e
	  JOIN Addresses AS a ON a.AddressID = e.AddressID
	  JOIN Towns AS t ON t.TownID = a.TownID
	 WHERE t.[Name] = @townName
END
GO

EXEC usp_GetEmployeesFromTown 'Sofia'
GO

-- 5. -- Salary Level Function
CREATE FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4))
RETURNS VARCHAR(7)
AS
BEGIN
	DECLARE @salaryLevel VARCHAR(7);

	IF (@salary < 30000) 
		SET @salaryLevel = 'Low'
	ELSE IF (@salary BETWEEN 30000 AND 50000)
		SET @salaryLevel = 'Average'
	ELSE
		SET @salaryLevel = 'High' 

	RETURN @salaryLevel;
END
GO

SELECT Salary, dbo.ufn_GetSalaryLevel(Salary) AS [Salary Level]
  FROM Employees
  GO

-- 6. -- Employees by Salary Level
CREATE PROCEDURE usp_EmployeesBySalaryLevel (@salaryLevel VARCHAR(7)) AS
BEGIN
	SELECT FirstName, LastName
	  FROM Employees
	 WHERE dbo.ufn_GetSalaryLevel(Salary) = @salaryLevel
END

EXEC usp_EmployeesBySalaryLevel 'High'
GO

-- 7. -- Define Function
CREATE FUNCTION ufn_IsWordComprised(@setOfLetters VARCHAR(MAX), @word VARCHAR(MAX))
RETURNS BIT
BEGIN
	DECLARE @index INT = 1;
	DECLARE @currentChar CHAR(1);
	DECLARE @isContained INT;

	WHILE (@index <= LEN(@word))
	BEGIN
		SET @currentChar = SUBSTRING(@word,@index,1);
		SET @isContained = CHARINDEX(@currentChar, @setOfLetters)

		IF (@isContained = 0) 
			RETURN 0

		SET @index += 1;
	END

	RETURN 1;
END
GO

-- 8. -- Delete Employees and Departments
CREATE PROC usp_DeleteEmployeesFromDepartment (@departmentId INT) AS
BEGIN
	DELETE FROM EmployeesProjects
	WHERE EmployeeID IN (SELECT EmployeeID FROM Employees WHERE DepartmentID = @departmentId)

	ALTER TABLE Departments
	ALTER COLUMN ManagerID INT

	UPDATE Employees
	SET ManagerID = NULL
	WHERE ManagerID IN (SELECT EmployeeID FROM Employees WHERE DepartmentID = @departmentId)

	UPDATE Departments
	SET ManagerID = NULL
	WHERE ManagerID IN (SELECT EmployeeID FROM Employees WHERE DepartmentID = @departmentId)

	DELETE FROM Employees
	WHERE DepartmentID = @departmentId

	DELETE FROM Departments
	WHERE DepartmentID = @departmentId

	SELECT COUNT(*)
	FROM Employees
	WHERE DepartmentID = @departmentId
END

-- 9. -- Find Full Name
USE Bank
GO

CREATE PROC usp_GetHoldersFullName AS
BEGIN
	SELECT FirstName + ' ' + LastName AS [Full Name]
	  FROM AccountHolders
END
GO

-- 10. -- People with Balance Higher Than
CREATE PROC usp_GetHoldersWithBalanceHigherThan (@referenceBalance DECIMAL(15,4)) AS
BEGIN
	WITH CTE_AccoutHolderBalance (AccountHolderId, Balance) AS (
		SELECT AccountHolderId, SUM(Balance) AS TotalBalance
		  FROM Accounts
	  GROUP BY AccountHolderId)

	SELECT FirstName, LastName
	  FROM AccountHolders AS ah
	  JOIN CTE_AccoutHolderBalance AS ahb ON ahb.AccountHolderId = ah.Id
	 WHERE ahb.Balance > @referenceBalance
  ORDER BY ah.LastName, ah.FirstName 
END
GO

-- 11. -- Future Value Function
CREATE FUNCTION ufn_CalculateFutureValue (@sum DECIMAL(15,2), @interestRate FLOAT, @years INT)
RETURNS DECIMAL(15,4)
BEGIN
	RETURN @sum * POWER((1 + @interestRate), @years)
END

SELECT dbo.ufn_CalculateFutureValue(1000, 0.1, 5)
GO

-- 12. -- Calculating Interest
USE Bank
GO

CREATE PROCEDURE usp_CalculateFutureValueForAccount (@accountId INT, @interestRate FLOAT) AS
BEGIN
	SELECT a.Id, ah.FirstName, ah.LastName, a.Balance, 
		   dbo.ufn_CalculateFutureValue(Balance, @interestRate, 5) AS [Balance in 5 years]
	  FROM Accounts AS a
	  JOIN AccountHolders AS ah ON ah.Id = a.AccountHolderId
	 WHERE a.Id = @accountId
END

EXEC usp_CalculateFutureValueForAccount 1, 0.1
GO

-- 13. -- Scalar Function: Cash in User Games Odd Rows
USE Diablo

CREATE FUNCTION ufn_CashInUsersGames (@gameName VARCHAR(50))
RETURNS TABLE
AS
RETURN
	(
	SELECT SUM(e.Cash) AS SumCash
	  FROM (
		SELECT g.Id, ug.Cash,  ROW_NUMBER() OVER(ORDER BY ug.Cash DESC) AS [RowNumber]
		  FROM Games AS g
          JOIN UsersGames AS ug ON ug.GameId = g.Id
         WHERE g.[Name] = @gameName) AS e
     WHERE e.RowNumber % 2 = 1
	)

-- 14. -- Create Table Logs
USE Bank

CREATE TABLE Logs
(
	LogID INT PRIMARY KEY IDENTITY,
	AccountID INT FOREIGN KEY REFERENCES Accounts(Id),
	OldSum DECIMAL(7,2) NOT NULL,
	NewSum DECIMAL(7,2) NOT NULL
)
GO

CREATE TRIGGER tr_AccountsUpdate ON Accounts FOR UPDATE
AS
  INSERT INTO Logs
  SELECT inserted.Id, deleted.Balance, inserted.Balance 
    FROM inserted
    JOIN deleted ON inserted.Id = deleted.Id

UPDATE Accounts
   SET Balance -= 5
 WHERE Id = 1

SELECT * FROM Logs

-- 15. -- Create Table Emails
CREATE TABLE NotificationEmails(
	Id INT PRIMARY KEY IDENTITY,
	Recipient INT FOREIGN KEY REFERENCES Accounts(Id),
	[Subject] VARCHAR(50) NOT NULL,
	Body VARCHAR(100) NOT NULL 
	)
GO

CREATE TRIGGER tr_LogsInsertNotifications ON Logs FOR INSERT
AS
	INSERT INTO NotificationEmails
	SELECT AccountId,  
		'Balance change for account: ' + CAST(AccountID AS varchar(10)),
		'On ' + CONVERT(VARCHAR(50), GETDATE(), 100) + ' your balance was changed from ' + 
		CAST(OldSum AS varchar(20)) + ' to ' + CAST(NewSum AS varchar(20))
		FROM inserted

UPDATE Accounts
   SET Balance -= 5
 WHERE Id = 1

SELECT * FROM NotificationEmails
GO

-- 16. -- Deposit Money
CREATE PROC usp_DepositMoney (@AccountId INT, @MoneyAmount DECIMAL(17,4)) AS
BEGIN
	IF (@MoneyAmount > 0)
	BEGIN
		UPDATE Accounts
		   SET Balance += @MoneyAmount
		 WHERE Id = @AccountId
	END
END

EXEC usp_DepositMoney 1, 10
SELECT * FROM Accounts
GO

-- 17. -- Withdraw Money
CREATE PROC usp_WithdrawMoney (@AccountId INT, @MoneyAmount DECIMAL(17,4)) AS
BEGIN
	IF (@MoneyAmount > 0)
	BEGIN
		UPDATE Accounts
		   SET Balance -= @MoneyAmount
		 WHERE Id = @AccountId
	END
END

EXEC usp_WithdrawMoney 5, 25

SELECT * 
  FROM Accounts 
 WHERE Id = 5
 
 GO

-- 18. -- Money Transfer
CREATE PROC usp_TransferMoney (@SenderId INT, @ReceiverId INT, @Amount DECIMAL(17,4)) AS
BEGIN
	BEGIN TRAN
		IF (@Amount > 0)
		BEGIN
			EXEC usp_WithdrawMoney @SenderId, @Amount
			EXEC usp_DepositMoney @ReceiverId, @Amount
		END
	COMMIT
END
GO

-- 19. -- Trigger
USE Diablo
GO

CREATE TRIGGER tr_UserGameItems ON UserGameItems INSTEAD OF INSERT AS
BEGIN
	INSERT INTO UserGameItems
	SELECT i.Id, ug.Id
	  FROM inserted
	  JOIN UserGames AS ug ON ug.Id = UserGameId
	  JOIN Items AS i ON i.Id = ItemId
	 WHERE ug.Level >= i.MinLevel
END
GO

UPDATE UsersGames
   SET Cash += 50000
  FROM UsersGames AS ug
  JOIN Users AS u ON ug.UserId = u.Id
  JOIN Games AS g ON ug.GameId = g.Id
 WHERE g.Name = 'Bali' AND u.Username IN('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos')
GO

CREATE PROC usp_BuyItems(@Username VARCHAR(50)) AS
BEGIN
	DECLARE @UserId INT = (SELECT Id FROM Users WHERE Username = @Username)
	DECLARE @GameId INT = (SELECT Id FROM Games WHERE Name = 'Bali')
	DECLARE @UserGameId INT = (SELECT Id FROM UsersGames WHERE UserId = @UserId AND GameId = @GameId)
	DECLARE @UserGameLevel INT = (SELECT Level FROM UsersGames WHERE Id = @UserGameId)

	DECLARE @counter INT = 251

	WHILE(@counter <= 539)
	BEGIN
		DECLARE @ItemId INT = @counter
		DECLARE @ItemPrice MONEY = (SELECT Price FROM Items WHERE Id = @ItemId)
		DECLARE @ItemLevel INT = (SELECT MinLevel FROM Items WHERE Id = @ItemId)
		DECLARE @UserGameCash MONEY = (SELECT Cash FROM UsersGames WHERE Id = @UserGameId)

		IF(@UserGameCash >= @ItemPrice AND @UserGameLevel >= @ItemLevel)
		BEGIN
			UPDATE UsersGames
			   SET Cash -= @ItemPrice
			 WHERE Id = @UserGameId

			INSERT INTO UserGameItems VALUES
			(@ItemId, @UserGameId)
		END

		SET @counter += 1
		
		IF(@counter = 300)
		BEGIN
			SET @counter = 501
		END
	END
END

EXEC usp_BuyItems 'baleremuda'
EXEC usp_BuyItems 'loosenoise'
EXEC usp_BuyItems 'inguinalself'
EXEC usp_BuyItems 'buildingdeltoid'
EXEC usp_BuyItems 'monoxidecos'
GO

SELECT u.Username, g.Name, ug.Cash, i.Name 
  FROM Users AS u
  JOIN UsersGames AS ug ON u.Id = ug.UserId
  JOIN Games AS g ON ug.GameId = g.Id
  JOIN UserGameItems AS ugi ON ug.Id = ugi.UserGameId
  JOIN Items AS i ON ugi.ItemId = i.Id
 WHERE g.Name = 'Bali'
ORDER BY u.Username, i.Name
GO

-- 20. -- Massive Shopping
DECLARE @UserId INT = (SELECT Id FROM Users WHERE Username = 'Stamat')
DECLARE @GameId INT = (SELECT Id FROM Games WHERE Name = 'Safflower')
DECLARE @UserGameId INT = (SELECT Id FROM UsersGames WHERE UserId = @UserId AND GameId = @GameId)
DECLARE @UserGameLevel INT = (SELECT [Level] FROM UsersGames WHERE Id = @UserGameId)
DECLARE @ItemStartLevel INT = 11
DECLARE @ItemEndLevel INT = 12
DECLARE @AllItemsPrice MONEY = (SELECT SUM(Price) FROM Items WHERE (MinLevel BETWEEN @ItemStartLevel AND @ItemEndLevel)) 
DECLARE @StamatCash MONEY = (SELECT Cash FROM UsersGames WHERE Id = @UserGameId)

IF(@StamatCash >= @AllItemsPrice)
BEGIN
	BEGIN TRAN	
		UPDATE UsersGames
		   SET Cash -= @AllItemsPrice
		 WHERE Id = @UserGameId
	
		INSERT INTO UserGameItems
		SELECT i.Id, @UserGameId  
		  FROM Items AS i
		 WHERE (i.MinLevel BETWEEN @ItemStartLevel AND @ItemEndLevel)
	COMMIT
END

SET @ItemStartLevel = 19
SET @ItemEndLevel = 21
SET @AllItemsPrice = (SELECT SUM(Price) FROM Items WHERE (MinLevel BETWEEN @ItemStartLevel AND @ItemEndLevel)) 
SET @StamatCash = (SELECT Cash FROM UsersGames WHERE Id = @UserGameId)

IF(@StamatCash >= @AllItemsPrice)
BEGIN
	BEGIN TRAN
		UPDATE UsersGames
		SET Cash -= @AllItemsPrice
		WHERE Id = @UserGameId
	
		INSERT INTO UserGameItems
		SELECT i.Id, @UserGameId  FROM Items AS i
		WHERE (i.MinLevel BETWEEN @ItemStartLevel AND @ItemEndLevel)
	COMMIT
END

SELECT i.[Name] AS [Item Name] 
  FROM Users AS u
  JOIN UsersGames AS ug ON u.Id = ug.UserId
  JOIN Games AS g ON ug.GameId = g.Id
  JOIN UserGameItems AS ugi ON ug.Id = ugi.UserGameId
  JOIN Items AS i ON ugi.ItemId = i.Id
 WHERE u.Username = 'Stamat' AND g.[Name] = 'Safflower'
ORDER BY i.Name

-- 21. -- Employees with Three Projects
USE SoftUni
GO

CREATE PROC usp_AssignProject(@employeeId INT, @projectID INT) AS
BEGIN
	BEGIN TRAN
		INSERT INTO EmployeesProjects VALUES
		(@employeeId, @projectID)

		DECLARE @EmployeeProjectsCount INT = (SELECT COUNT(*) 
		                                        FROM EmployeesProjects 
											   WHERE EmployeeId = @employeeId)
		IF(@EmployeeProjectsCount > 3)
		BEGIN
			ROLLBACK
			RAISERROR('The employee has too many projects!', 16, 1)
			RETURN
		END
	COMMIT
END 

-- 22. -- Delete Employees
CREATE TABLE Deleted_Employees
(
	EmployeeId INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	MiddleName VARCHAR(50),
	JobTitle VARCHAR(50) NOT NULL,
	DepartmentID INT NOT NULL,
	Salary MONEY NOT NULL
)
GO

CREATE TRIGGER tr_DeleteEmployees ON Employees AFTER DELETE AS
	INSERT INTO Deleted_Employees
	SELECT FirstName, LastName, MiddleName, JobTitle, DepartmentID, Salary 
	  FROM deleted