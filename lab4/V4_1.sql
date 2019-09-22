/*a) —оздайте таблицу Production.ProductModelHst, 
котора€ будет хранить информацию об изменени€х в таблице Production.ProductModel.
ќб€зательные пол€, которые должны присутствовать в таблице: 
	ID Ч первичный ключ IDENTITY(1,1);
	Action Ч совершенное действие (insert, update или delete);
	ModifiedDate Ч дата и врем€, когда была совершена операци€; 
	SourceID Ч первичный ключ исходной таблицы; 
	UserName Ч им€ пользовател€, совершившего операцию.
—оздайте другие пол€, если считаете их нужными.*/
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

/*b) —оздайте один AFTER триггер дл€ трех операций INSERT, UPDATE, DELETE
 дл€ таблицы Production.ProductModel. “риггер должен заполн€ть 
 таблицу Production.ProductModelHst с указанием типа операции 
 в поле Action в зависимости от оператора, вызвавшего триггер.*/
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

/*c) —оздайте представление VIEW, отображающее все пол€ таблицы Production.ProductModel.*/
CREATE VIEW ProductModelView AS
SELECT *
FROM Production.ProductModel;
GO

/*d) ¬ставьте новую строку в Production.ProductModel через представление.
 ќбновите вставленную строку. ”далите вставленную строку.
 ”бедитесь, что все три операции отображены в Production.ProductModelHst.*/
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