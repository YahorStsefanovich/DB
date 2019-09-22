/*�������� �������� ���������, ������� ����� ���������� ������� ������� (�������� PIVOT), 
������������ ������ � ���������� ���������� � ������ ������ (HumanResources.Department) 
�� ������������ ��� (HumanResources.EmployeeDepartmentHistory.StartDate). 
������ ��� ��������� � ��������� ����� ������� ��������.

����� �������, ����� ��������� ����� ��������� ��������� �������:

EXECUTE dbo.EmpCountByDep �[2003],[2004],[2005]�*/

IF OBJECT_ID ( 'dbo.NumberOfEmployeesByYear', 'P' ) IS NOT NULL
DROP PROCEDURE dbo.NumberOfEmployeesByYear;
GO
CREATE PROCEDURE dbo.NumberOfEmployeesByYear @listOfYears nvarchar(255)
AS
BEGIN
SELECT Name, [2003], [2004], [2005]
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
    FOR YearOfStartDate IN ([2003], [2004], [2005])
    ) AS CountOfEmployees
ORDER BY Name;
END;
GO


