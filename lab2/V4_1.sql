/*Вывести на экран неповторяющийся список должностей в каждом отделе, отсортированный по названию отдела.
 Посчитайте количество сотрудников, работающих в каждом отделе.*/
SELECT DISTINCT	D.Name, 
				E.JobTitle, 
				COUNT(E.BusinessEntityID) OVER (PARTITION BY edh.DepartmentID) AS EmpCount
FROM HumanResources.Department AS D 
	JOIN HumanResources.EmployeeDepartmentHistory AS EDH 
		ON D.DepartmentID=EDH.DepartmentID 
	JOIN HumanResources.Employee AS E 
		ON EDH.BusinessEntityID=E.BusinessEntityID
	ORDER BY D.Name ASC;

/*Вывести на экран сотрудников, которые работают в ночную смену.*/
SELECT E.BusinessEntityID, E.JobTitle, S.Name, S.StartTime, S.EndTime FROM HumanResources.Employee AS E 
	JOIN HumanResources.EmployeeDepartmentHistory AS EDH
		ON E.BusinessEntityID=EDH.BusinessEntityID
	JOIN HumanResources.Shift AS S 
		ON S.ShiftID=EDH.ShiftID
	WHERE S.Name='Night';

/*Вывести на экран почасовые ставки сотрудников.
Добавить столбец с информацией о предыдущей почасовой ставке для каждого сотрудника.
Добавить еще один столбец с указанием разницы между текущей ставкой и предыдущей ставкой для каждого сотрудника.*/
SELECT E.BusinessEntityID,
	   E.JobTitle, 
	   EPH.Rate, 
	   ISNULL(PrevEPH.Rate, 0.00) AS PrevRate
FROM HumanResources.Employee AS E
	JOIN HumanResources.EmployeePayHistory AS EPH 
		ON E.BusinessEntityID=EPH.BusinessEntityID AND EPH.RateChangeDate>=E.HireDate
	LEFt JOIN HumanResources.EmployeePayHistory AS PrevEPH 
		ON E.BusinessEntityID=PrevEPH.BusinessEntityID AND PrevEPH.RateChangeDate<EPH.RateChangeDate;