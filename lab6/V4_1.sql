/*Создайте хранимую процедуру, которая будет возвращать сводную таблицу (оператор PIVOT), 
отображающую данные о количестве работников в каждом отделе (HumanResources.Department) 
за определенный год (HumanResources.EmployeeDepartmentHistory.StartDate). 
Список лет передайте в процедуру через входной параметр.

Таким образом, вызов процедуры будет выглядеть следующим образом:

EXECUTE dbo.EmpCountByDep ‘[2003],[2004],[2005]’*/

IF OBJECT_ID ( 'dbo.NumberOfEmployeesByYear', 'P' ) IS NOT NULL
DROP PROCEDURE dbo.NumberOfEmployeesByYear;
GO

CREATE PROCEDURE dbo.NumberOfEmployeesByYear @listOfYears varchar(MAX)
AS
BEGIN DECLARE @query  AS nvarchar(MAX);
set @query =
            'SELECT Name, ' + @listOfYears + '
		FROM (
				SELECT D.Name,
				YEAR (ED.StartDate) as YearOfStartDate,
				D.DepartmentID
				FROM HumanResources.Department AS D
				JOIN HumanResources.EmployeeDepartmentHistory AS ED
				ON D.DepartmentID = ED.DepartmentID
			)
		AS DepartmentEmployees
		PIVOT (
			COUNT (DepartmentID)
			FOR YearOfStartDate IN (' + @listOfYears + ')
		) AS CountOfEmployees
		ORDER BY Name;'
execute
    (@ query)
    END;
GO

EXECUTE dbo.NumberOfEmployeesByYear '[2003],[2004],[2005]';
