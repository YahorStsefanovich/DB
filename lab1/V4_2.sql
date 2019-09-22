RESTORE DATABASE AdventureWorks2012
FROM "AdventureWorks2012"
WITH MOVE 'AdventureWorks2012_Data' TO 'D:\Programs\SQL_Server\MSSQL11.YAHOR_STS\MSSQL\DATA\AdventureWorks2012.mdf',
	MOVE 'AdventureWorks2012_Log' TO 'D:\Programs\SQL_Server\MSSQL11.YAHOR_STS\MSSQL\Log\AdventureWorks2012.mdf'
GO

USE AdventureWorks2012;
GO

/* Вывести на экран список отделов, принадлежащих группе ‘Executive General and Administration’.*/
SELECT Name, GroupNAme
FROM HumanResources.Department
WHERE GroupName = 'Executive General and Administration';


/* Вывести на экран максимальное количество оставшихся часов отпуска
 у сотрудников. Назовите столбец с результатом ‘MaxVacationHours’.*/
SELECT MAX(VacationHours) AS MaxVacationHours
FROM HumanResources.Employee;

/*Вывести на экран сотрудников, название позиции которых включает слово ‘Engineer’.*/
SELECT E.BusinessEntityID, E.JobTitle, E.Gender, E.BirthDate, E.HireDate
FROM HumanResources.Employee AS E
WHERE E.JobTitle LIKE '%Engineer%';