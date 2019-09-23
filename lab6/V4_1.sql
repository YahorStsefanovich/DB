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
	DECLARE @itemYear INT, 
			@endYear INT;

	IF OBJECT_ID('tempdb.dbo.#everyYearEmployeesHistory', 'U') IS NOT NULL
		DROP TABLE #everyYearEmployeesHistory;

	CREATE TABLE #everyYearEmployeesHistory (currentYear INT, departmentID INT, name NVARCHAR(MAX));
		
	SET @itemYear = SUBSTRING(@listOfYears, 2, 4);
	SET @endYear = SUBSTRING(@listOfYears, LEN(@listOfYears) - 4, 4);

	WHILE (@itemYear <= @endYear)
	BEGIN
		INSERT INTO #everyYearEmployeesHistory
		SELECT  @itemYear,
				D.DepartmentID,
				D.Name
		FROM HumanResources.Department AS D
		JOIN HumanResources.EmployeeDepartmentHistory AS ED
		ON D.DepartmentID = ED.DepartmentID 
		-- if endDate null then get 2019;
		-- minus 1: if employee was sacked in currentYear, then we don't count him) 
		WHERE @itemYear BETWEEN YEAR(ED.StartDate) AND ((ISNULL(YEAR(ED.EndDate), YEAR(GETDATE()))) - 1)
		SET @itemYear = @itemYear + 1; 
	END;

    set @query ='
					SELECT Name,' + @listOfYears + ' 
					FROM #everyYearEmployeesHistory
					AS DepartmentEmployees
					PIVOT (
						COUNT (DepartmentID)
						FOR currentYear IN (' + @listOfYears + ')
					) AS CountOfEmployees
					ORDER BY Name;
				'
    execute(@query);
END;
GO

EXECUTE dbo.NumberOfEmployeesByYear '[2003],[2004],[2005]';
