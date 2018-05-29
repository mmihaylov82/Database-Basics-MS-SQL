CREATE DATABASE Minions

USE Minions

CREATE TABLE Towns(
	Id INT PRIMARY KEY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
)

CREATE TABLE Minions(
	Id INT PRIMARY KEY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
	Age INT,
	TownId INT CONSTRAINT FK_Minions_Towns FOREIGN KEY REFERENCES Towns(Id) NOT NULL
) 

INSERT INTO Towns (Id, [Name]) VALUES
(1, 'Sofia'),
(2, 'Plovdiv'),
(3, 'Varna')

INSERT INTO Minions (Id, [Name], Age, TownId) VALUES
(1,'Kevin', 22, 1),
(2,'Bob', 15, 3),
(3,'Steward', NULL, 2)

SELECT * FROM Towns
SELECT * FROM Minions

-- Problem 5.
TRUNCATE TABLE Minions

-- Problem 6. --

DROP TABLE Minions
DROP TABLE Towns

-- Problem 7. --

CREATE TABLE People (
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(200) NOT NULL,
	Picture VARBINARY(MAX) CHECK (DATALENGTH(Picture) < 2 * 1024 * 1024),
	Height DECIMAL(3,2),
	[Weight] DECIMAL(5,2),
	Gender CHAR(1) CHECK (Gender = 'm' OR Gender = 'f') NOT NULL,
	Birthdate DATE NOT NULL,
	Biography NVARCHAR(MAX)
)

INSERT INTO People ([Name], Picture, Height, [Weight], Gender, Birthdate, Biography) VALUES
('Zdravko Zdravkov', NULL, 1.90, 85.5, 'm', CONVERT(datetime, '28/02/2000', 103), 'Fitness Instructor'),
('Kiril Kirilov', NULL, 1.80, 90.5, 'm', CONVERT(datetime, '05/06/1980', 103), '.NET Developer'),
('Pesho Petkov', NULL, 1.90, 110.8, 'm', CONVERT(datetime, '28/06/1970', 103), 'Driver'),
('Penka Miteva', NULL, 1.70, 82.5, 'f', CONVERT(datetime, '08/01/1991', 103), 'Office Manager'),
('Georgi Mihov', NULL, 1.76, 85.7, 'm', CONVERT(datetime, '14/05/1982', 103), 'Sales Assistant')

SELECT * FROM People

-- Problem 8.--

CREATE TABLE Users (
	Id BIGINT UNIQUE IDENTITY,
	Username VARCHAR(30) UNIQUE NOT NULL,
	[Password] BINARY(26) NOT NULL,
	ProfilePicture VARBINARY(MAX) CHECK (DATALENGTH(ProfilePicture) <= 900 * 1024),
	LastLoginTime DATETIME,
	IsDeleted BIT,
	CONSTRAINT PK_Users PRIMARY KEY (Id)
)

INSERT INTO Users (Username, [Password], ProfilePicture, LastLoginTime, IsDeleted) VALUES
('Mincho98', HASHBYTES('SHA1', '12345'), NULL, NULL, 0),
('Milen88', HASHBYTES('SHA1', 'asdk11'), NULL, NULL, 1),
('Mitko_', HASHBYTES('SHA1', 'adsja9'), NULL, NULL, 0),
('predator', HASHBYTES('SHA1', 'jekrfjre4'), NULL, NULL, 1),
('vanko66', HASHBYTES('SHA1', 'kajsda91'), NULL, NULL, 0)

SELECT * FROM Users

-- Problem 9. --

ALTER TABLE Users
DROP CONSTRAINT PK_Users

ALTER TABLE Users
ADD CONSTRAINT PK_Users PRIMARY KEY (Id, Username)

-- Problem 10. --

ALTER TABLE Users
ADD CONSTRAINT CHK_Password_Length CHECK (LEN([Password]) >= 5)

-- Problem 11. --

ALTER TABLE Users
ADD DEFAULT GETDATE() FOR LastLoginTime


-- Problem 12. --

ALTER TABLE Users
DROP CONSTRAINT PK_Users

ALTER TABLE Users
ADD CONSTRAINT PK_Id PRIMARY KEY (Id)

ALTER TABLE Users
ADD CONSTRAINT uq_Username UNIQUE (Username)

ALTER TABLE Users
ADD CONSTRAINT CHK_UsernameLength CHECK (LEN(Username) >= 3)

-- Problem 13. --

CREATE DATABASE Movies

CREATE TABLE Directors (
	Id INT PRIMARY KEY IDENTITY,
	DirectorName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
)

CREATE TABLE Genres (
	Id INT PRIMARY KEY IDENTITY,
	GenreName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
)

CREATE TABLE Categories (
	Id INT PRIMARY KEY IDENTITY,
	CategoryName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
)

CREATE TABLE Movies (
	Id INT PRIMARY KEY IDENTITY,
	Title NVARCHAR(MAX) NOT NULL,
	DirectorId INT FOREIGN KEY REFERENCES Directors(Id),
	CopyrightYear INT NOT NULL,
	[Length] time,
	GenreId INT FOREIGN KEY REFERENCES Genres(Id),
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id),
	Rating DECIMAL(2,1),
	Notes NVARCHAR(MAX)
)

INSERT INTO Directors (DirectorName, Notes) VALUES
('Steven Spielberg', NULL),
('James Cameron', NULL),
('Quentin Tarantino', NULL),
('George Atanasov', 'Oscar Winner'),
('Dimitar Mitovski', NULL)

INSERT INTO Genres (GenreName, Notes) VALUES
('Comedy', 'Funny movies'),
('Thriller', 'Lots of suspension'),
('Horror', 'Scary Movies'),
('Action', 'No brainers, heavy shooting'),
('Drama', 'Not for the faint-hearted')

INSERT INTO Categories (CategoryName, Notes) VALUES
('Best Music', NULL),
('Best Director', NULL),
('Best Main Role', NULL),
('Best Supporting Role', NULL),
('Best Movie', NULL)

INSERT INTO Movies (Title, DirectorId, CopyrightYear, [Length], GenreId, CategoryId, Rating, Notes) VALUES
('The Town', 1, 2010, '2:10:40', 2, 5, 7.6, NULL),
('Godzilla', 5, 1996, '1:55:30', 3, 1, 6.4, NULL),
('Kill Bill', 3, 1992, '2:15:00', 5, 2, 8.6, NULL),
('Two and a half men', 4, 2000, '0:40:10', 1, 3, 9.2, NULL),
('Wind River', 2, 2017, '1:49:25', 4, 4, 8.0, NULL)

-- Problem 14. --

CREATE DATABASE CarRental

CREATE TABLE Categories (
	Id INT PRIMARY KEY IDENTITY,
	CategoryName NVARCHAR(50) NOT NULL,
	DailyRate INT NOT NULL,
	WeeklyRate INT NOT NULL,
	MonthlyRate INT NOT NULL,
	WeekendRate INT NOT NULL
)

CREATE TABLE Cars (
	Id INT PRIMARY KEY IDENTITY,
	PlateNumber NVARCHAR(7) UNIQUE NOT NULL,
	Manufacturer NVARCHAR(20) NOT NULL, 
	Model NVARCHAR(20) NOT NULL, 
	CarYear INT NOT NULL, 
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id), 
	Doors INT, 
	Picture VARBINARY(MAX), 
	Condition NVARCHAR(300), 
	Available BIT NOT NULL
)

CREATE TABLE Employees (
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(20) NOT NULL, 
	LastName NVARCHAR(20) NOT NULL,
	Title NVARCHAR(30) NOT NULL, 
	Notes NVARCHAR(300)
)

CREATE TABLE Customers (
	Id INT PRIMARY KEY IDENTITY,
	DriverLicenceNumber NVARCHAR(50) NOT NULL UNIQUE, 
	FullName NVARCHAR(50) NOT NULL, 
	[Address] NVARCHAR(40) NOT NULL, 
	City NVARCHAR(20) NOT NULL, 
	ZIPCode INT, 
	Notes NVARCHAR(300)
)

CREATE TABLE RentalOrders (
	Id INT PRIMARY KEY IDENTITY,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id),
	CustomerId INT FOREIGN KEY REFERENCES Customers(Id),
	CarId INT FOREIGN KEY REFERENCES Cars(Id),
	TankLevel INT NOT NULL,
	KilometrageStart INT NOT NULL,
	KilometrageEnd INT NOT NULL,
	TotalKilometrage AS KilometrageEnd - KilometrageStart,
	StartDate DATE NOT NULL,
	EndDate DATE NOT NULL,
	TotalDays AS DATEDIFF(DAY, StartDate, EndDate),
	RateApplied INT NOT NULL,
	TaxRate AS RateApplied * 0.2,
	OrderStatus BIT NOT NULL,
	Notes NVARCHAR(1000)
)

INSERT INTO Categories VALUES
('Compact', 65, 350, 1350, 120),
('SUV', 85, 500, 1800, 160),
('Intermediate', 40, 230, 850, 70)

INSERT INTO Cars VALUES
('B4011BP', 'Nissan', 'Qashqai', 2015, 2, 5, NULL, 'Excellent', 1),
('B0419BA', 'Opel', 'Astra', 2018, 1, 5, NULL, 'Small number of scratches', 0),
('B7077BM', 'VW', 'Passat', 2013, 3, 4, NULL, 'Brand New', 1)

INSERT INTO Employees VALUES
('Mincho', 'Minchev', 'General Manager', NULL),
('Petar', 'Petkov', 'Supervisor', NULL),
('Jivko', 'Jelev', 'Technician', NULL)

INSERT INTO Customers(DriverLicenceNumber, FullName, [Address], City) VALUES
('LS128811', 'Michelle Dewar', '30 Rou de Bouvar', 'Paris'),
('JDF12931JD', 'Anthony Joshua', '15 Kensington Drive', 'London'),
('LA12934641', 'John Silver', '15 Bendjamin Ave', 'Los Angeles')

INSERT INTO RentalOrders(EmployeeId, CustomerId, CarId, TankLevel, KilometrageStart, KilometrageEnd, 
StartDate, EndDate, RateApplied, OrderStatus) VALUES
(1, 2, 3, 30, 13200, 19855, '2007-08-08', '2007-08-10', 250, 1),
(3, 2, 1, 45, 53200, 56984, '2009-09-06', '2009-09-28', 1500, 0),
(2, 2, 1, 18, 0, 1200, '2017-05-08', '2017-06-09', 850, 0)


-- Problem 15. -- 

CREATE DATABASE Hotel

CREATE TABLE Employees (
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(20) NOT NULL,
	LastName NVARCHAR(20) NOT NULL,
	Title NVARCHAR(30),
	Notes NVARCHAR(500)
)

CREATE TABLE Customers (
	AccountNumber INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(20) NOT NULL,
	LastName NVARCHAR(20) NOT NULL,
	PhoneNumber NVARCHAR(30),
	EmergencyName NVARCHAR(30),
	EmergencyNumber NVARCHAR(30),
	Notes NVARCHAR(500) 
)

CREATE TABLE RoomStatus (
	RoomStatus NVARCHAR(30) PRIMARY KEY NOT NULL,
	Notes NVARCHAR(500)
)

CREATE TABLE RoomTypes (
	RoomType NVARCHAR(30) PRIMARY KEY NOT NULL,
	Notes NVARCHAR(500)
)

CREATE TABLE BedTypes (
	BedType NVARCHAR(30) PRIMARY KEY NOT NULL,
	Notes NVARCHAR(500)
)

CREATE TABLE Rooms (
	RoomNumber INT PRIMARY KEY NOT NULL,
	RoomType NVARCHAR(30) FOREIGN KEY REFERENCES RoomTypes(RoomType) NOT NULL,
	BedType NVARCHAR(30) FOREIGN KEY REFERENCES BedTypes(BedType) NOT NULL,
	Rate DECIMAL(6,2) NOT NULL,
	RoomStatus BIT NOT NULL,
	Notes NVARCHAR(500)
)

CREATE TABLE Payments (
	Id INT PRIMARY KEY IDENTITY,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL,
	PaymentDate DATETIME NOT NULL,
	AccountNumber INT FOREIGN KEY REFERENCES Customers(AccountNumber) NOT NULL,
	FirstDateOccupied DATE NOT NULL,
	LastDateOccupied DATE NOT NULL,
	TotalDays AS DATEDIFF(DAY, FirstDateOccupied, LastDateOccupied),
	AmountCharged DECIMAL(7, 2) NOT NULL,
	TaxRate DECIMAL(6,2) NOT NULL,
	TaxAmount AS AmountCharged * TaxRate,
	PaymentTotal AS AmountCharged + AmountCharged * TaxRate,
	Notes NVARCHAR(1500)
)

CREATE TABLE Occupancies (
	Id INT PRIMARY KEY IDENTITY,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL,
	DateOccupied DATE NOT NULL,
	AccountNumber INT FOREIGN KEY REFERENCES Customers(AccountNumber) NOT NULL,
	RoomNumber INT FOREIGN KEY REFERENCES Rooms(RoomNumber) NOT NULL,
	RateApplied DECIMAL(7, 2) NOT NULL,
	PhoneCharge DECIMAL(8, 2) NOT NULL,
	Notes NVARCHAR(500)
)

INSERT INTO Employees(FirstName, LastNAme) VALUES
('Milen', 'Mihaylov'),
('Georgi', 'Ivanov'),
('Petar', 'Nikolov')

INSERT INTO Customers(FirstName, LastName, PhoneNumber) VALUES
('Petar', 'Petkov', '+359879548045'),
('Mincho', 'Praznikov', '+359883223423'),
('Yavor', 'Donkov', '+3598823400217')

INSERT INTO RoomStatus(RoomStatus) VALUES
('Occupied'),
('Available'),
('In Maintenance')

INSERT INTO RoomTypes(RoomType) VALUES
('Single'),
('Double'),
('Appartment')

INSERT INTO BedTypes(BedType) VALUES
('Single bed'),
('Twin beds'),
('King size')

INSERT INTO Rooms(RoomNumber, RoomType, BedType, Rate, RoomStatus) VALUES
(101, 'Single', 'Single bed', 60.0, 1),
(102, 'Double', 'Twin beds', 70.0, 0),
(103, 'Appartment', 'King size', 100.0, 1)

INSERT INTO Payments(EmployeeId, PaymentDate, AccountNumber, FirstDateOccupied, LastDateOccupied, AmountCharged, TaxRate) VALUES
(1, '2008-08-25', 2, '2008-08-10', '2008-08-15', 350.0, 0.2),
(3, '2011-06-04', 3, '2014-06-06', '2014-06-09', 240.0, 0.2),
(3, '2012-02-26', 2, '2012-02-20', '2012-02-24', 250.0, 0.11)

INSERT INTO Occupancies(EmployeeId, DateOccupied, AccountNumber, RoomNumber, RateApplied, PhoneCharge) VALUES
(2, '2011-02-04', 3, 101, 60.0, 10.50),
(2, '2015-04-09', 1, 102, 70.0, 40.30),
(3, '2012-06-08', 2, 103, 100.0, 12.80)

-- Problem 16. --

CREATE DATABASE Softuni

CREATE TABLE Towns (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	Name VARCHAR(30) NOT NULL
)

CREATE TABLE Addresses (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	AddressText NVARCHAR(50) NOT NULL,
	TownId INT FOREIGN KEY REFERENCES Towns(Id) NOT NULL
)

CREATE TABLE Departments (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	Name VARCHAR(30) NOT NULL
)

CREATE TABLE Employees (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName NVARCHAR(30) NOT NULL,
	MiddleName NVARCHAR(30) NOT NULL,
	LastName NVARCHAR(30) NOT NULL,
	JobTitle NVARCHAR(80) NOT NULL,
	DepartmentId INT FOREIGN KEY REFERENCES Departments(Id) NOT NULL,
	HireDate DATE,
	Salary DECIMAL(7,2),
	AddressId INT FOREIGN KEY REFERENCES Addresses(Id)
)

-- Problem 17. --

BACKUP DATABASE Softuni TO DISK = 'C:\DB\Softuni_backup.bak'

RESTORE DATABASE Softuni FROM DISK = 'C:\DB\Softuni_backup.bak'

USE Softuni

-- Problem 18. --

--•	Towns (Id, Name)
--•	Addresses (Id, AddressText, TownId)
--•	Departments (Id, Name)
--•	Employees (Id, FirstName, MiddleName, LastName, JobTitle, DepartmentId, HireDate, Salary, AddressId)


INSERT INTO Towns ([Name]) VALUES
('Sofia'),
('Plovdiv'),
('Varna'),
('Burgas')

INSERT INTO Departments ([Name]) VALUES
('Engineering'), 
('Sales'), 
('Marketing'), 
('Software Development'), 
('Quality Assurance')

INSERT INTO Employees (FirstName, MiddleName, LastName, JobTitle, DepartmentId, HireDate, Salary) VALUES
('Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 4, '2013-02-01', 3500.00),
('Petar', 'Petrov', 'Petrov', 'Senior Engineer', 1, '2004-03-02', 4000.00),
('Maria', 'Petrova', 'Ivanova', 'Intern', 5, '2016-08-28', 525.25),
('Georgi', 'Teziev', 'Ivanov', 'CEO', 2, '2007-12-09', 3000.00),
('Peter', 'Pan', 'Pan', 'Intern', 3, '2016-08-28', 599.88)

-- Problem 19. --

SELECT * FROM Towns

SELECT * FROM Departments

SELECT * FROM Employees

-- Problem 20. --

SELECT * FROM Towns
ORDER BY [Name]

SELECT * FROM Departments
ORDER BY [Name]

SELECT * FROM Employees
ORDER BY Salary DESC

-- Problem 21. --

SELECT [Name] FROM Towns
ORDER BY [Name]

SELECT [Name] FROM Departments
ORDER BY [Name]

SELECT FirstName, LastName, JobTitle, Salary FROM Employees
ORDER BY Salary DESC

-- Problem 22. --

UPDATE Employees

SET Salary *= 1.1

SELECT Salary FROM Employees

-- Problem 23. --

USE Hotel

UPDATE Payments
SET TaxRate -= TaxRate * 0.03

SELECT Taxrate FROM Payments

-- Problem 24. --

USE Hotel

TRUNCATE TABLE Occupancies