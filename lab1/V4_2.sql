RESTORE DATABASE AdventureWorks2012
FROM "AdventureWorks2012"
WITH MOVE 'AdventureWorks2012_Data' TO 'D:\Programs\SQL_Server\MSSQL11.YAHOR_STS\MSSQL\DATA\AdventureWorks2012.mdf',
	MOVE 'AdventureWorks2012_Log' TO 'D:\Programs\SQL_Server\MSSQL11.YAHOR_STS\MSSQL\Log\AdventureWorks2012.mdf'
GO

USE AdventureWorks2012;
GO

/* ������� �� ����� ������ �������, ������������� ������ �Executive General and Administration�.*/
SELECT Name, GroupNAme
FROM HumanResources.Department
WHERE GroupName = 'Executive General and Administration';


/* ������� �� ����� ������������ ���������� ���������� ����� �������
 � �����������. �������� ������� � ����������� �MaxVacationHours�.*/
SELECT MAX(VacationHours) AS MaxVacationHours
FROM HumanResources.Employee;

/*������� �� ����� �����������, �������� ������� ������� �������� ����� �Engineer�.*/
SELECT E.BusinessEntityID, E.JobTitle, E.Gender, E.BirthDate, E.HireDate
FROM HumanResources.Employee AS E
WHERE E.JobTitle LIKE '%Engineer%';