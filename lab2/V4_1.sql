/*Вывести на экран неповторяющийся список должностей в каждом отделе, отсортированный по названию отдела.
 Посчитайте количество сотрудников, работающих в каждом отделе.*/ 
SELECT DISTINCT D.NAME, 
                E.jobtitle, 
                Count(E.businessentityid) 
                  OVER ( 
                    partition BY edh.departmentid) AS EmpCount 
FROM   humanresources.department AS D 
       JOIN humanresources.employeedepartmenthistory AS EDH 
         ON D.departmentid = EDH.departmentid 
       JOIN humanresources.employee AS E 
         ON EDH.businessentityid = E.businessentityid 
ORDER  BY D.NAME ASC;

/*Вывести на экран сотрудников, которые работают в ночную смену.*/ 
SELECT E.businessentityid, 
       E.jobtitle, 
       S.NAME, 
       S.starttime, 
       S.endtime 
FROM   humanresources.employee AS E 
       JOIN humanresources.employeedepartmenthistory AS EDH 
         ON E.businessentityid = EDH.businessentityid 
       JOIN humanresources.shift AS S 
         ON S.shiftid = EDH.shiftid 
WHERE  S.NAME = 'Night'; 

/*Вывести на экран почасовые ставки сотрудников. 
Добавить столбец с информацией о предыдущей почасовой ставке для каждого сотрудника. 
Добавить еще один столбец с указанием разницы между текущей ставкой и предыдущей ставкой для каждого сотрудника.*/
SELECT E.businessentityid, 
       E.jobtitle, 
       EPH.rate, 
       Isnull(PrevEPH.rate, 0.00)            AS PrevRate, 
       EPH.rate - Isnull(PrevEPH.rate, 0.00) AS Increased 
FROM   humanresources.employee AS E 
       JOIN humanresources.employeepayhistory AS EPH 
         ON E.businessentityid = EPH.businessentityid 
       LEFT JOIN humanresources.employeepayhistory AS PrevEPH 
              ON E.businessentityid = PrevEPH.businessentityid 
                 AND PrevEPH.ratechangedate < EPH.ratechangedate; 