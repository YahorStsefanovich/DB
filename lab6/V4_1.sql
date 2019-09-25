/*Создайте хранимую процедуру, которая будет возвращать сводную таблицу (оператор PIVOT), 
отображающую данные о количестве работников в каждом отделе (HumanResources.Department) 
за определенный год (HumanResources.EmployeeDepartmentHistory.StartDate). 
Список лет передайте в процедуру через входной параметр.

Таким образом, вызов процедуры будет выглядеть следующим образом:

EXECUTE dbo.EmpCountByDep ‘[2003],[2004],[2005]’*/
IF OBJECT_ID('dbo.NumberOfEmployeesByYear', 'P') IS NOT NULL
    DROP PROCEDURE dbo.NumberOfEmployeesByYear;
GO

CREATE PROCEDURE dbo.NumberOfEmployeesByYear @listOfYears varchar(MAX)
AS
BEGIN
    DECLARE @query AS nvarchar(MAX);
    set @query =
        '
            DECLARE @itemYear INT,
                @endYear INT;

            SET @itemYear = ' + SUBSTRING(@listOfYears, 2, 4) + ';
			SET @endYear = ' + SUBSTRING(@listOfYears, LEN(@listOfYears) - 4, 4) + ';
			WITH unitedDepartmentHistTable(currentYear, DepartmentID, Name, StartYear, EndYear)
			AS 
			(
				SELECT @itemYear,
					D.DepartmentID,
					D.Name,
					YEAR(ED.StartDate) as StartYear,
					ISNULL(YEAR(ED.EndDate), YEAR(GETDATE())) as EndYear
				FROM HumanResources.Department AS D
						JOIN HumanResources.EmployeeDepartmentHistory AS ED
							ON D.DepartmentID = ED.DepartmentID
				UNION ALL
				SELECT currentYear+1,
						DepartmentID,
						Name,
						StartYear,
						EndYear
				FROM unitedDepartmentHistTable
				WHERE currentYear < @endYear 
			)
			SELECT Name,' + @listOfYears + ' 
			FROM (
				SELECT name, currentYear, DepartmentID
				FROM unitedDepartmentHistTable 
				WHERE currentYear between StartYear AND EndYear - 1
			)
			AS DepartmentEmployees
			PIVOT (
				COUNT (DepartmentID)
				FOR currentYear IN (' + @listOfYears + ')
			) AS CountOfEmployees
			ORDER BY Name;
		'
    execute (@query);
END;
GO

EXECUTE dbo.NumberOfEmployeesByYear '[2003],[2004],[2005]';
