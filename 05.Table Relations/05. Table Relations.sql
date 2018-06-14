CREATE DATABASE TableRelationsDB

USE TableRelationsDB

-- 01. --
CREATE TABLE Persons (
	PersonID INT IDENTITY,
	FirstName NVARCHAR(32) NOT NULL,
	Salary DECIMAL(15,2) NOT NULL,
	PassportID INT NOT NULL
)

CREATE TABLE Passports (
	PassportID INT IDENTITY(101,1),
	PassportNumber VARCHAR(8) NOT NULL
)

INSERT INTO Persons
VALUES
('Roberto', 43400.00, 102),
('Tom', 56100.00, 103),
('Yana', 60200.00, 101)

INSERT INTO Passports
VALUES
('N34FG21B'),
('K65LO4R7'),
('ZE657QP2')

ALTER TABLE Persons
ADD CONSTRAINT PK_PersonID PRIMARY KEY (PersonID)

ALTER TABLE Passports
ADD CONSTRAINT PK_PassportID PRIMARY KEY (PassportID)

ALTER TABLE Persons
ADD CONSTRAINT FK_Persons_Passports FOREIGN KEY (PassportID) REFERENCES Passports(PassportID)

-- 02. --
CREATE TABLE Manufacturers (
	ManufacturerID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL,
	EstablishedOn DATE
)

CREATE TABLE Models (
	ModelID INT PRIMARY KEY IDENTITY(101,1),
	[Name] VARCHAR(50) NOT NULL,
	ManufacturerID INT FOREIGN KEY REFERENCES Manufacturers(ManufacturerID)
)

INSERT INTO Manufacturers 
VALUES
('BMW', '1916-03-07'),
('Tesla', '2003-01-01'),
('Lada', '1966-05-01')

INSERT INTO Models 
VALUES
('X1', 1),
('i6', 1),
('Model S', 2),
('Model X', 2),
('Model 3', 2),
('Nova', 3)

-- 3. --
CREATE TABLE Students (
	StudentID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL
)

CREATE TABLE Exams (
	ExamID INT PRIMARY KEY IDENTITY(101,1),
	[Name] VARCHAR(30) NOT NULL
)

CREATE TABLE StudentsExams(
	StudentID INT CONSTRAINT FK_StudentsExams_Students FOREIGN KEY REFERENCES Students(StudentID),
	ExamID INT CONSTRAINT FK_StudentsExams_Exams FOREIGN KEY REFERENCES Exams(ExamID),
	CONSTRAINT PK_StudentsExams PRIMARY KEY (StudentID, ExamID)
)

INSERT INTO Students VALUES
('Mila'),
('Toni'),
('Ron')

INSERT INTO Exams VALUES
('SpringMVC'),
('Neo4j'),
('Oracle 11g')

INSERT INTO StudentsExams VALUES
(1, 101),
(1, 102),
(2, 101),
(3, 103),
(2, 102),
(2, 103)

-- 4. --
CREATE TABLE Teachers(
	TeacherID INT PRIMARY KEY IDENTITY(101,1),
	[Name] VARCHAR(30) NOT NULL,
	ManagerID INT FOREIGN KEY REFERENCES Teachers(TeacherID) 
)

INSERT INTO Teachers VALUES
('John', NULL),
('Maya', 106),
('Silvia', 106),
('Ted', 105),
('Mark', 101),
('Greta', 101)

-- 5. --
CREATE DATABASE TableRelations2

USE TableRelations2

CREATE TABLE Cities(
	CityID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Customers(
	CustomerID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	Birthday DATE,
	CityID INT FOREIGN KEY REFERENCES Cities(CityID)
)

CREATE TABLE Orders(
	OrderID INT PRIMARY KEY IDENTITY,
	CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID)
)

CREATE TABLE ItemTypes(
	ItemTypeID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Items(
	ItemID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	ItemTypeID INT FOREIGN KEY REFERENCES ItemTypes(ItemTypeID)
)

CREATE TABLE OrderItems(
	OrderID INT CONSTRAINT FK_OrderItems_Orders FOREIGN KEY REFERENCES Orders(OrderID),
	ItemID INT CONSTRAINT FK_OrderItems_Items FOREIGN KEY REFERENCES Items(ItemID)
	CONSTRAINT PK_OrderItems PRIMARY KEY (OrderID, ItemID)
)

-- 6. -- 
CREATE DATABASE University

USE University

CREATE TABLE Majors(
	MajorID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Students(
	StudentID INT PRIMARY KEY IDENTITY,
	StudentNumber INT NOT NULL,
	StudentName VARCHAR(50) NOT NULL,
	MajorID INT CONSTRAINT FK_Students_Majors 
		FOREIGN KEY REFERENCES Majors(MajorID)
)

CREATE TABLE Subjects(
	SubjectID INT PRIMARY KEY IDENTITY,
	SubjectName VARCHAR(50) NOT NULL
)

CREATE TABLE Payments(
	PaymentID INT PRIMARY KEY IDENTITY,
	PaymentDate DATE NOT NULL,
	PaymentAmount DECIMAL(7,2) NOT NULL,
	StudentID INT CONSTRAINT FK_Payments_Students
		FOREIGN KEY REFERENCES Students(StudentID)
)

CREATE TABLE Agenda(
	StudentID INT CONSTRAINT FK_Agenda_Students
		FOREIGN KEY REFERENCES Students(StudentID),
	SubjectID INT CONSTRAINT FK_Agenda_Subjects
		FOREIGN KEY REFERENCES Subjects(SubjectID),
	CONSTRAINT PK_Agenda PRIMARY KEY(StudentID, SubjectID)
)

-- 9. --
USE Geography

  SELECT m.MountainRange, p.PeakName, p.Elevation
    FROM Peaks AS p
	JOIN Mountains AS m ON m.Id = p.MountainID
   WHERE m.MountainRange = 'Rila'
ORDER BY p.Elevation DESC