USE Diablo

-- 1. -- Number of Users for Email Provider
SELECT SUBSTRING(Email, CHARINDEX('@', Email, 1) + 1, LEN(Email)) AS [Email Provider],
	   COUNT(*) AS [Number of Users]
  FROM Users
GROUP BY SUBSTRING(Email, CHARINDEX('@', Email, 1) + 1, LEN(Email))
ORDER BY [Number of Users] DESC, [Email Provider]

-- 2. -- All User in Games
SELECT g.[Name], gt.[Name], u.Username, ug.[Level], ug.Cash, c.[Name]
  FROM Users AS u
  JOIN UsersGames AS ug ON ug.UserId = u.Id
  JOIN Games AS g ON g.Id = ug.GameId
  JOIN GameTypes AS gt ON gt.Id = g.GameTypeId
  JOIN Characters AS c ON c.Id = ug.CharacterId
ORDER BY ug.[Level] DESC, u.Username, g.[Name]

-- 3. -- Users in Games with Their Items
SELECT u.Username, 
	   g.[Name] AS Game, 
	   COUNT(ugi.ItemId) AS [Items Count],
	   SUM(i.Price) AS [Items Price]
  FROM Users AS u
  JOIN UsersGames AS ug ON ug.UserId = u.Id
  JOIN Games AS g ON g.Id = ug.GameId
  JOIN UserGameItems AS ugi ON ugi.UserGameId = ug.Id
  JOIN Items AS i ON i.Id = ugi.ItemId
GROUP BY u.Username, g.[Name]
HAVING COUNT(ugi.ItemId) >= 10
ORDER BY [Items Count] DESC, [Items Price] DESC ,u.Username

-- 4. -- User in Games with Their Statistics
SELECT u.Username, g.Name AS Game, MAX(c.Name) AS Character, 
	   MAX(cs.Strength) + MAX(gts.Strength) + SUM(gis.Strength) AS Strength, 
	   MAX(cs.Defence) + MAX(gts.Defence) + SUM(gis.Defence) AS Defence, 
	   MAX(cs.Speed) + MAX(gts.Speed) + SUM(gis.Speed) AS Speed, 
	   MAX(cs.Mind) + MAX(gts.Mind) + SUM(gis.Mind) AS Mind, 
	   MAX(cs.Luck) + MAX(gts.Luck) + SUM(gis.Luck) AS Luck
  FROM UsersGames AS ug
  JOIN Users AS u ON ug.UserId = u.Id
  JOIN Games AS g ON ug.GameId = g.Id
  JOIN Characters AS c ON ug.CharacterId = c.Id
  JOIN [Statistics] AS cs ON c.StatisticId = cs.Id
  JOIN GameTypes AS gt ON gt.Id = g.GameTypeId
  JOIN [Statistics] AS gts ON gts.Id = gt.BonusStatsId
  JOIN UserGameItems AS ugi ON ugi.UserGameId = ug.Id
  JOIN Items AS i ON i.Id = ugi.ItemId
  JOIN [Statistics] AS gis ON gis.Id = i.StatisticId
GROUP BY u.Username, g.Name
ORDER BY Strength DESC, Defence DESC, Speed DESC, Mind DESC, Luck DESC


-- 5. -- All Items with Greater than Average Statistics
WITH CTE_AboveAverageStats (Id) AS (  
  SELECT Id 
    FROM [Statistics]
   WHERE Mind > (SELECT AVG(Mind) FROM [Statistics]) AND
         Luck > (SELECT AVG(Luck) FROM [Statistics]) AND
         Speed > (SELECT AVG(Speed) FROM [Statistics]))

SELECT i.[Name], i.Price, i.MinLevel, 
       s.Strength, s.Defence, s.Speed, s.Luck, s.Mind
  FROM CTE_AboveAverageStats AS av
  JOIN [Statistics] AS s ON av.Id = s.Id
  JOIN Items AS i ON i.StatisticId = s.Id
ORDER BY i.[Name]

-- 6. -- Display All Items with Information about Forbidden Game Type
SELECT i.[Name], i.Price, i.MinLevel,
	   gt.[Name] AS [Forbidden Game Type]
  FROM Items AS i
LEFT JOIN GameTypeForbiddenItems AS gtfi ON gtfi.ItemId = i.Id
LEFT JOIN GameTypes AS gt ON gt.Id = gtfi.GameTypeId
ORDER BY gt.[Name] DESC, i.[Name]

-- 7. -- Buy Items for User in Game
DECLARE @gameName NVARCHAR(50) = 'Edinburgh';
DECLARE @userName NVARCHAR(50) = 'Alex';
DECLARE @userGameId INT = (
  SELECT ug.Id 
    FROM UsersGames AS ug
    JOIN Users AS u ON ug.UserId = u.Id
    JOIN Games AS g ON ug.GameId = g.Id
   WHERE u.Username = @userName AND g.Name = @gameName)

DECLARE @availableCash MONEY = (SELECT Cash FROM UsersGames WHERE Id = @userGameId);
DECLARE @purchasePrice MONEY = (
  SELECT SUM(Price) 
    FROM Items 
   WHERE Name IN ('Blackguard', 'Bottomless Potion of Amplification', 'Eye of Etlich (Diablo III)',
				  'Gem of Efficacious Toxin', 'Golden Gorget of Leoric', 'Hellfire Amulet')); 

UPDATE UsersGames 
   SET Cash -= @purchasePrice 
 WHERE Id = @userGameId; 

INSERT INTO UserGameItems (ItemId, UserGameId) (
     SELECT Id, @userGameId 
	   FROM Items 
	  WHERE Name IN ('Blackguard', 'Bottomless Potion of Amplification', 'Eye of Etlich (Diablo III)',
					 'Gem of Efficacious Toxin', 'Golden Gorget of Leoric', 'Hellfire Amulet')) 

SELECT u.Username, g.[Name], ug.Cash, i.[Name] AS [Item Name]
  FROM UsersGames AS ug
  JOIN Games AS g ON ug.GameId = g.Id
  JOIN Users AS u ON ug.UserId = u.Id
  JOIN UserGameItems AS ugi ON ug.Id = ugi.UserGameId
  JOIN Items AS i ON i.Id = ugi.ItemId
 WHERE g.[Name] = @gameName

-- 8. -- Peaks and Mountains
USE Geography

SELECT p.PeakName, m.MountainRange AS Mountain, p.Elevation
  FROM Peaks AS p
  JOIN Mountains AS m ON m.Id = p.MountainId
ORDER BY p.Elevation DESC, p.PeakName

-- 9. -- Peaks with Their Mountain, Country and Continent
SELECT p.PeakName, 
	   m.MountainRange AS Mountain,
	   c.CountryName,
	   cont.ContinentName
  FROM Peaks AS p
  JOIN Mountains AS m ON m.Id = p.MountainId
  JOIN MountainsCountries AS mc ON mc.MountainId = m.Id
  JOIN Countries AS c ON c.CountryCode = mc.CountryCode
  JOIN Continents AS cont ON cont.ContinentCode = c.ContinentCode
ORDER BY p.PeakName, c.CountryName

-- 10. -- Rivers by Country
SELECT c.CountryName, 
   	   cont.ContinentName, 
   	   ISNULL(COUNT(r.Id), 0) AS RiversCount,
   	   ISNULL(SUM(r.Length), 0) AS TotalLength
FROM Countries AS c
LEFT JOIN CountriesRivers AS cr ON cr.CountryCode = c.CountryCode
LEFT JOIN Rivers AS r ON r.Id = cr.RiverId
LEFT JOIN Continents AS cont ON cont.ContinentCode = c.ContinentCode
GROUP BY c.CountryName, cont.ContinentName
ORDER BY COUNT(r.Id) DESC, SUM(r.Length) DESC, c.CountryName

-- 11. -- Count of Countries by Currency
SELECT cu.CurrencyCode, 
	   cu.[Description] AS Currency, 
       COUNT(c.CountryCode) AS NumberOfCountries
  FROM Currencies AS cu
LEFT JOIN Countries AS c ON c.CurrencyCode = cu.CurrencyCode
GROUP BY cu.CurrencyCode, cu.[Description]
ORDER BY NumberOfCountries DESC, Currency

-- 12. -- Population and Area by Continent
SELECT cont.ContinentName, 
       SUM(c.AreaInSqKm) AS CountriesArea, 
	   SUM(CAST(c.[Population] AS float)) AS CountriesPopulation
  FROM Continents AS cont
  JOIN Countries AS c ON c.ContinentCode = cont.ContinentCode
GROUP BY cont.ContinentName
ORDER BY CountriesPopulation DESC

-- 13. -- Monasteries by Country
CREATE TABLE Monasteries(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(200) NOT NULL,
	CountryCode CHAR(2) FOREIGN KEY REFERENCES Countries(CountryCode)
)

INSERT INTO Monasteries(Name, CountryCode) VALUES
('Rila Monastery “St. Ivan of Rila”', 'BG'), 
('Bachkovo Monastery “Virgin Mary”', 'BG'),
('Troyan Monastery “Holy Mother''s Assumption”', 'BG'),
('Kopan Monastery', 'NP'),
('Thrangu Tashi Yangtse Monastery', 'NP'),
('Shechen Tennyi Dargyeling Monastery', 'NP'),
('Benchen Monastery', 'NP'),
('Southern Shaolin Monastery', 'CN'),
('Dabei Monastery', 'CN'),
('Wa Sau Toi', 'CN'),
('Lhunshigyia Monastery', 'CN'),
('Rakya Monastery', 'CN'),
('Monasteries of Meteora', 'GR'),
('The Holy Monastery of Stavronikita', 'GR'),
('Taung Kalat Monastery', 'MM'),
('Pa-Auk Forest Monastery', 'MM'),
('Taktsang Palphug Monastery', 'BT'),
('Sümela Monastery', 'TR');

ALTER TABLE Countries
ADD IsDeleted BIT NOT NULL DEFAULT 0

WITH CTE_CountriesWithMoreThanThreeRivers (CountryCode) AS (
	SELECT c.CountryCode
	  FROM Countries AS c
	  JOIN CountriesRivers AS cr ON cr.CountryCode = c.CountryCode
  GROUP BY c.CountryCode
    HAVING COUNT(cr.RiverId) > 3
)

UPDATE Countries
   SET IsDeleted = 1
 WHERE CountryCode IN (SELECT * FROM CTE_CountriesWithMoreThanThreeRivers)

 SELECT m.[Name] AS Monastery,
        c.CountryName AS Country
   FROM Monasteries AS m
   JOIN Countries AS c ON c.CountryCode = m.CountryCode
  WHERE c.IsDeleted = 0
 ORDER BY Monastery

-- 14. -- Monasteries by Continents and Countries
UPDATE Countries
   SET CountryName = 'Burma'
 WHERE CountryName = 'Myanmar'

INSERT INTO Monasteries (Name, CountryCode)
(SELECT 'Hanga Abbey', CountryCode 
   FROM Countries AS c
  WHERE CountryName = 'Tanzania')

INSERT INTO Monasteries (Name, CountryCode)
(SELECT 'Myin-Tin-Daik', CountryCode 
   FROM Countries
  WHERE CountryName = 'Myanmar')

SELECT cont.ContinentName, 
       c.CountryName, 
       COUNT(m.Id) AS MonasteriesCount
FROM Continents AS cont
LEFT JOIN Countries AS c ON c.ContinentCode = cont.ContinentCode
LEFT JOIN Monasteries AS m ON m.CountryCode = c.CountryCode
WHERE c.IsDeleted = 0
GROUP BY cont.ContinentName, c.CountryName
ORDER BY MonasteriesCount DESC, c.CountryName