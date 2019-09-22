/*a) Создайте таблицу Production.ProductModelHst, 
которая будет хранить информацию об изменениях в таблице Production.ProductModel.
Обязательные поля, которые должны присутствовать в таблице: 
	ID — первичный ключ IDENTITY(1,1);
	Action — совершенное действие (insert, update или delete);
	ModifiedDate — дата и время, когда была совершена операция; 
	SourceID — первичный ключ исходной таблицы; 
	UserName — имя пользователя, совершившего операцию.
Создайте другие поля, если считаете их нужными.*/
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

/*b) Создайте один AFTER триггер для трех операций INSERT, UPDATE, DELETE
 для таблицы Production.ProductModel. Триггер должен заполнять 
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

/*c) Создайте представление VIEW, отображающее все поля таблицы Production.ProductModel.*/
CREATE VIEW ProductModelView AS
SELECT *
FROM Production.ProductModel;
GO

/*d) Вставьте новую строку в Production.ProductModel через представление.
 Обновите вставленную строку. Удалите вставленную строку.
 Убедитесь, что все три операции отображены в Production.ProductModelHst.*/
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