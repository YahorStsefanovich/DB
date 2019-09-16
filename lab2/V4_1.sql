/*������� �� ����� ��������������� ������ ���������� � ������ ������, ��������������� �� �������� ������.
 ���������� ���������� �����������, ���������� � ������ ������.*/
SELECT DISTINCT	D.Name, 
				E.JobTitle, 
				COUNT(E.BusinessEntityID) OVER (PARTITION BY edh.DepartmentID) AS EmpCount
FROM HumanResources.Department AS D 
	JOIN HumanResources.EmployeeDepartmentHistory AS EDH 
		ON D.DepartmentID=EDH.DepartmentID 
	JOIN HumanResources.Employee AS E 
		ON EDH.BusinessEntityID=E.BusinessEntityID
	ORDER BY D.Name ASC;

/*������� �� ����� �����������, ������� �������� � ������ �����.*/
SELECT E.BusinessEntityID, E.JobTitle, S.Name, S.StartTime, S.EndTime FROM HumanResources.Employee AS E 
	JOIN HumanResources.EmployeeDepartmentHistory AS EDH
		ON E.BusinessEntityID=EDH.BusinessEntityID
	JOIN HumanResources.Shift AS S 
		ON S.ShiftID=EDH.ShiftID
	WHERE S.Name='Night';

/*������� �� ����� ��������� ������ �����������.
�������� ������� � ����������� � ���������� ��������� ������ ��� ������� ����������.
�������� ��� ���� ������� � ��������� ������� ����� ������� ������� � ���������� ������� ��� ������� ����������.*/
SELECT E.BusinessEntityID,
	   E.JobTitle, 
	   EPH.Rate, 
	   ISNULL(PrevEPH.Rate, 0.00) AS PrevRate
FROM HumanResources.Employee AS E
	JOIN HumanResources.EmployeePayHistory AS EPH 
		ON E.BusinessEntityID=EPH.BusinessEntityID AND EPH.RateChangeDate>=E.HireDate
	LEFt JOIN HumanResources.EmployeePayHistory AS PrevEPH 
		ON E.BusinessEntityID=PrevEPH.BusinessEntityID AND PrevEPH.RateChangeDate<EPH.RateChangeDate;