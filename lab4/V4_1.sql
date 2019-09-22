/*a) �������� ������� Production.ProductModelHst, 
������� ����� ������� ���������� �� ���������� � ������� Production.ProductModel.
������������ ����, ������� ������ �������������� � �������: 
	ID � ��������� ���� IDENTITY(1,1);
	Action � ����������� �������� (insert, update ��� delete);
	ModifiedDate � ���� � �����, ����� ���� ��������� ��������; 
	SourceID � ��������� ���� �������� �������; 
	UserName � ��� ������������, ������������ ��������.
�������� ������ ����, ���� �������� �� �������.*/
CREATE TABLE Production.ProductModelHst
(
    ID [INT] IDENTITY(1,1) NOT NULL, [
    Action]
    VARCHAR
(
    10
) NOT NULL CHECK
(
    [
    Action]
    IN
(
    'insert',
    'update',
    'delete'
)),
    ModifiedDate DATETIME NOT NULL,
    SourceID [INT],
    UserName VARCHAR(256) NOT NULL
    );
GO

/*b) �������� ���� AFTER ������� ��� ���� �������� INSERT, UPDATE, DELETE
 ��� ������� Production.ProductModel. ������� ������ ��������� 
 ������� Production.ProductModelHst � ��������� ���� �������� 
 � ���� Action � ����������� �� ���������, ���������� �������.*/
CREATE TRIGGER onProductModelChanged
    ON Production.ProductModel
    AFTER
INSERT,
UPDATE,
DELETE
    AS
BEGIN DECLARE @eventType varchar(42);
DECLARE @sourceID int;
IF EXISTS(SELECT * FROM inserted)
BEGIN
SELECT @sourceID = ProductModelID
FROM inserted;
IF EXISTS(SELECT * FROM deleted)
BEGIN
SELECT @eventType = 'update';
END
ELSE
BEGIN
SELECT @eventType = 'insert';
END
END
ELSE
BEGIN IF EXISTS(SELECT * FROM deleted)
BEGIN
SELECT @eventType = 'delete';
END
SELECT @sourceID = ProductModelID
FROM deleted;
END
INSERT INTO Production.ProductModelHst([Action], ModifiedDate, SourceID, UserName)
VALUES (@eventType, GETDATE(), @sourceID, USER_NAME());
END;
GO

/*c) �������� ������������� VIEW, ������������ ��� ���� ������� Production.ProductModel.*/
CREATE VIEW ProductModelView AS
SELECT *
FROM Production.ProductModel;
GO

/*d) �������� ����� ������ � Production.ProductModel ����� �������������.
 �������� ����������� ������. ������� ����������� ������.
 ���������, ��� ��� ��� �������� ���������� � Production.ProductModelHst.*/
INSERT INTO Production.ProductModel(Name)
VALUES ('Glory Glory Man United');
UPDATE Production.ProductModel
SET Name = 'May the force be with you'
WHERE Name = 'Glory Glory Man United';
DELETE
FROM Production.ProductModel
WHERE Name = 'May the force be with you';
SELECT *
FROM Production.ProductModelHst;