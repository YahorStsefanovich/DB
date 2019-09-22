RESTORE DATABASE AdventureWorks2012
FROM "AdventureWorks2012"
WITH MOVE 'AdventureWorks2012_Data' TO 'D:\Programs\SQL_Server\MSSQL11.YAHOR_STS\MSSQL\DATA\AdventureWorks2012.mdf',
	MOVE 'AdventureWorks2012_Log' TO 'D:\Programs\SQL_Server\MSSQL11.YAHOR_STS\MSSQL\Log\AdventureWorks2012.mdf'
GO

USE AdventureWorks2012;
GO

/* ¬ывести на экран список отделов, принадлежащих группе СExecutive General and AdministrationТ.*/
SELECT Name, GroupNAme
FROM HumanResources.Department
WHERE GroupName = 'Executive General and Administration';


/* ¬ывести на экран максимальное количество оставшихс€ часов отпуска
 у сотрудников. Ќазовите столбец с результатом СMaxVacationHoursТ.*/
SELECT MAX(VacationHours) AS MaxVacationHours
FROM HumanResources.Employee;

/*¬ывести на экран сотрудников, название позиции которых включает слово СEngineerТ.*/
SELECT E.BusinessEntityID, E.JobTitle, E.Gender, E.BirthDate, E.HireDate
FROM HumanResources.Employee AS E
WHERE E.JobTitle LIKE '%Engineer%';