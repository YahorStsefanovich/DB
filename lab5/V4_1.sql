/*�������� scalar-valued �������, ������� ����� ��������� � �������� ��������
 ��������� id ������ (Sales.SalesOrderHeader.SalesOrderID) � ���������� ������������
  ���� �������� �� ������ (Sales.SalesOrderDetail.UnitPrice).*/
CREATE FUNCTION dbo.GetMaxCost (@SalesOrderID [int])
  RETURNS money
  WITH
EXECUTE AS CALLER
  AS
BEGIN DECLARE @resultValue money;
SET @resultValue = (SELECT MAX(SOD.UnitPrice)
                    FROM Sales.SalesOrderHeader AS SOH
                             JOIN Sales.SalesOrderDetail AS SOD
                                  ON SOH.SalesOrderID = SOD.SalesOrderID
                    WHERE @SalesOrderID = SOH.SalesOrderID);
RETURN
    (@resultValue);
END;
GO

/*�������� inline table-valued �������, ������� ����� ���������
  � �������� ������� ���������� id �������� (Production.Product.ProductID) 
  � ���������� �����, ������� ���������� �������.

  ������� ������ ���������� ������������ ���������� ������������������ �������
  � �������� � ���������� ��� ����������� (�� Quantity) �� 
  Production.ProductInventory. ������� ������ ���������� 
  ������ ��������, ���������� � ������ � (Production.ProductInventory.Shelf).*/
CREATE FUNCTION dbo.GetRowsByIdAndCount ( @ProductID [int],
	@rowCount [int]
 )
 RETURNS TABLE
 AS RETURN(
	SELECT ProductID, LocationID, Quantity, Bin,
		   Shelf, rowguid, ModifiedDate
	FROM (
		SELECT
			ProductID, LocationID,
			MAX(Quantity) OVER(PARTITION BY ProductID) AS Quantity,
			Bin, Shelf, rowguid, ModifiedDate,
			ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY ProductID) AS countOfRows
		FROM Production.ProductInventory
		WHERE ProductID = @ProductID 
			  AND Shelf = 'A'
	) AS Result WHERE countOfRows <= @rowCount
 );
GO

  /*�������� ������� ��� ������� ��������, �������� �������� CROSS APPLY.
   �������� ������� ��� ������� ��������, �������� �������� OUTER APPLY.*/
SELECT *
FROM Production.Product AS P
    CROSS APPLY dbo.GetRowsByIdAndCount(P.ProductID, 2);

SELECT *
FROM Production.Product AS P OUTER APPLY dbo.GetRowsByIdAndCount(P.ProductID, 2);

/*�������� ��������� inline table-valued �������, ������ �� multistatement 
table-valued (�������������� �������� ��� �������� ��� �������� inline table-valued �������).*/
IF object_id('GetRowsByIdAndCount', 'FN') IS NOT NULL
DROP FUNCTION GetRowsByIdAndCount
    GO

CREATE FUNCTION dbo.GetRowsByIdAndCount ( @ProductID [int],
	@rowCount [int]
 )
 RETURNS @ProductInventary TABLE(
			ProductID int, 
			LocationID smallint, 
			Quantity int,
			Bin tinyint,
			Shelf nvarchar,
			rowguid uniqueidentifier,
			ModifiedDate datetime
		)
 AS
BEGIN
INSERT INTO @ProductInventary
SELECT ProductID, LocationID, Quantity, Bin, Shelf, rowguid, ModifiedDate
FROM (
         SELECT ProductID,
                LocationID,
                MAX(Quantity) OVER (PARTITION BY ProductID)                   AS Quantity,
                Bin,
                Shelf,
                rowguid,
                ModifiedDate,
                ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY ProductID) AS countOfRows
         FROM Production.ProductInventory
         WHERE ProductID = @ProductID
           AND Shelf = 'A'
     ) AS Result
WHERE countOfRows <= @rowCount
    RETURN;
END;
GO