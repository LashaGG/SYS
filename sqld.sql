CREATE TABLE dbo.Deposit (
    -- DepositID: 1-დან 5 000 000-მდე, არ შეიძლება იყოს ცარიელი (NOT NULL)
    DepositID INT NOT NULL,
    
    -- DepositAmount: თანხობრივი ველი, 2 ციფრი მძიმის შემდეგ
    DepositAmount DECIMAL(18, 2) NULL,
    
    -- DepositTypeKey: მნიშვნელობები 1, 2 ან 3
    DepositTypeKey TINYINT NULL,
    
    -- DepositInterestRate: მაქსიმუმ 50, 4 ციფრი მძიმის შემდეგ
    DepositInterestRate DECIMAL(6, 4) NULL,
    
    -- Isresident: ველი იღებს მხოლოდ 0 ან 1-ს
    Isresident BIT NULL,
    
    -- DepositProductKey: დასაშვები მნიშვნელობა 0-დან 50-მდე
    DepositProductKey TINYINT NULL,

    -- შეზღუდვების (Constraints) დამატება პირობების დასაცავად:
    CONSTRAINT CHK_DepositID CHECK (DepositID BETWEEN 1 AND 5000000),
    CONSTRAINT CHK_DepositTypeKey CHECK (DepositTypeKey IN (1, 2, 3)),
    CONSTRAINT CHK_DepositInterestRate CHECK (DepositInterestRate <= 50.0000),
    CONSTRAINT CHK_DepositProductKey CHECK (DepositProductKey BETWEEN 0 AND 50)
);


-- 1. ჯერ ვაშორებთ ძველ შეზღუდვას, რომელიც მაქსიმუმ 50-ს უშვებდა
ALTER TABLE dbo.Deposit 
DROP CONSTRAINT CHK_DepositProductKey;

-- 2. ვცვლით მონაცემთა ტიპს TINYINT-დან SMALLINT-ზე, რათა დაეტიოს 500
ALTER TABLE dbo.Deposit 
ALTER COLUMN DepositProductKey SMALLINT;

-- 3. ვამატებთ ახალ შეზღუდვას 0-დან 500-მდე მნიშვნელობებისთვის
ALTER TABLE dbo.Deposit 
ADD CONSTRAINT CHK_DepositProductKey_New CHECK (DepositProductKey BETWEEN 0 AND 500);




BEGIN TRY
    -- ტრანზაქციის დაწყება
    BEGIN TRANSACTION;

    -- პირველი ჩანაწერი
    INSERT INTO dbo.Deposit (DepositID, DepositAmount, DepositTypeKey, DepositInterestRate, Isresident, DepositProductKey)
    VALUES (105, 1500.50, 1, 8.5000, 1, 12);

    -- მეორე ჩანაწერი
    INSERT INTO dbo.Deposit (DepositID, DepositAmount, DepositTypeKey, DepositInterestRate, Isresident, DepositProductKey)
    VALUES (201, 25000.00, 2, 12.2500, 0, 450); -- შეგახსენებთ, წინა დავალებით მაქსიმუმი 500 გახდა

    -- მესამე ჩანაწერი
    INSERT INTO dbo.Deposit (DepositID, DepositAmount, DepositTypeKey, DepositInterestRate, Isresident, DepositProductKey)
    VALUES (310, 500.15, 3, 0.0000, 1, 5);

    -- თუ აქამდე კოდი უშეცდომოდ მოვიდა, ვინახავთ ცვლილებებს
    COMMIT TRANSACTION;
    PRINT 'მონაცემები წარმატებით ჩაიყარა და დაიქომითდა!';
END TRY
BEGIN CATCH
    -- შეცდომის შემთხვევაში ვაუქმებთ ყველაფერს, რაც ამ ტრანზაქციაში მოხდა
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END
    
    -- შეცდომის შეტყობინების გამოტანა
    PRINT 'დაფიქსირდა შეცდომა! ტრანზაქცია გაუქმდა (Rollback მოხდა).';
    PRINT ERROR_MESSAGE();
END CATCH;



BEGIN TRY
    BEGIN TRANSACTION;

    -- დავააფდეითოთ პროდუქტის პროცენტი (DepositInterestRate) კონკრეტული ID-სთვის
    UPDATE dbo.Deposit
    SET DepositInterestRate = 14.5000
    WHERE DepositID = 105;

    COMMIT TRANSACTION;
    PRINT 'მონაცემები წარმატებით განახლდა!';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END
    PRINT 'განახლებისას დაფიქსირდა შეცდომა! ტრანზაქცია გაუქმდა.';
    PRINT ERROR_MESSAGE();
END CATCH;


BEGIN TRY
    BEGIN TRANSACTION;

    -- წავშალოთ ჩანაწერი, სადაც DepositID არის 310
    DELETE FROM dbo.Deposit
    WHERE DepositID = 310;

    COMMIT TRANSACTION;
    PRINT 'ჩანაწერი წარმატებით წაიშალა!';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END
    PRINT 'წაშლისას დაფიქსირდა შეცდომა! ტრანზაქცია გაუქმდა.';
    PRINT ERROR_MESSAGE();
END CATCH;

--------------------------------------------------------------------

1)დაწერეთ T-SQL სკრიპტი, რომელიც ითვლის პირველი 10 ნატურალური რიცხვის ჯამს WHILE ლუპის გამოყენებით.

DECLARE @Counter INT = 1;
DECLARE @Sum     INT = 0;

WHILE @Counter <= 10
BEGIN
    SET @Sum = @Sum + @Counter;
    SET @Counter = @Counter + 1;
END

PRINT 'pirveli ' + CAST(@Counter - 1 as NVARCHAR) + ' naturaluri ricxvis jami: ' + CAST(@Sum AS NVARCHAR);

 
2) შექმენით T-SQL ფუნქცია, რომელიც იღებს მთელ რიცხვს ინფუთად და აბრუნებს მის კვადრატს.
CREATE FUNCTION dbo.fn_GetSquare (@Number INT)
RETURNS INT
AS
BEGIN
    RETURN @Number * @Number;
END;


SELECT dbo.fn_GetSquare(5) AS Result;

 
 

3) შექმენით T-SQL ფუნქცია, რომელიც იღებს ორ სტრინგს ინფუთად და აბრუნებს მათ შეერთებულ სტრინგს.
CREATE FUNCTION dbo.fn_ConcatStrings (@String1 NVARCHAR(100), @String2 NVARCHAR(100))
RETURNS NVARCHAR(200)
AS
BEGIN
    RETURN CONCAT(@String1, @String2);
END;


SELECT dbo.fn_ConcatStrings('Hello, ', 'World!') AS CombinedText;

 
 

4) შექმენით ტრიგერი, რომელიც აღრიცხავს კლიენტების ცხრილის ჩანაწერის წაშლას CustomerDeletions ცხრილში. (შექმენით ორივე ცხრილი თქვენი ფანტაზიით)
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100)
);

CREATE TABLE CustomerDeletions (
    DeletionID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT,
    CustomerName NVARCHAR(100),
    Email NVARCHAR(100),
    DeletedAt DATETIME DEFAULT GETDATE()
);



CREATE TRIGGER trg_AfterCustomerDelete
ON Customers
AFTER DELETE
AS
BEGIN 
