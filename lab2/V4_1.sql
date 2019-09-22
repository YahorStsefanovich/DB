/*������� �� ����� ��������������� ������ ���������� � ������ ������, ��������������� �� �������� ������.
 ���������� ���������� �����������, ���������� � ������ ������.*/ 
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

/*������� �� ����� �����������, ������� �������� � ������ �����.*/ 
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

/*������� �� ����� ��������� ������ �����������. 
�������� ������� � ����������� � ���������� ��������� ������ ��� ������� ����������. 
�������� ��� ���� ������� � ��������� ������� ����� ������� ������� � ���������� ������� ��� ������� ����������.*/
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