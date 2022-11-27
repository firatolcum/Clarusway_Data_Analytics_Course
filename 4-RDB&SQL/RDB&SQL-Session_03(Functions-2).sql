


-----------------------------------------------
-- DS 11/22 EU -- RDB&SQL Session 3 (Part-2) --
----------- 06.06.2022 ------------------------
-----------------------------------------------


-- TRIM -- https://docs.microsoft.com/en-us/sql/t-sql/functions/trim-transact-sql
-- LTRIM -- https://docs.microsoft.com/en-us/sql/t-sql/functions/ltrim-transact-sql
-- RTIM -- https://docs.microsoft.com/en-us/sql/t-sql/functions/rtrim-transact-sql

SELECT TRIM(' CHARACTER');

SELECT ' CHARACTER';

SELECT TRIM(' CHARACTER ')

SELECT TRIM(      '          CHAR ACTER          ')

-- Trim yapmak istediğimiz birden fazla karakter var ise bunları aşağıdaki gibi belirtebiliriz.
-- Girdiğimiz ifadenin içindeki herhangi bir karakterle karşılaştığında bu karakter silinecektir. Ta ki bu karakterler dışında başka bir karakterle kaşılaşana kadar.
SELECT TRIM('ABC' FROM 'CCCCBBBAAAFRHGKDFKSLDFJKSDFACBBCACABACABCA')


SELECT	TRIM('X' FROM 'ABCXXDE')

SELECT	TRIM('x' FROM 'XXXXXXXXABCXXDEXXXXXXXX')

SELECT LTRIM ('     CHARACTER ')

SELECT RTRIM ('     CHARACTER ')


-- REPLACE -- https://docs.microsoft.com/en-us/sql/t-sql/functions/replace-transact-sql
-- STR -- https://docs.microsoft.com/en-us/sql/t-sql/functions/str-transact-sql


SELECT REPLACE('CHA   RACTER     STR   ING', ' ', '/')

SELECT REPLACE('CHARACTER STRING', 'CHARACTER STRING', 'CHARACTER')

SELECT STR (5454)

SELECT STR (2135454654)

SELECT STR (133215.654645, 11, 3)

SELECT len(STR(1234567823421341241290123456))


-- CAST -- CONVERT -- https://docs.microsoft.com/en-us/sql/t-sql/functions/cast-and-convert-transact-sql

SELECT CAST (12345 AS CHAR)

SELECT CAST (123.65 AS INT)


SELECT CONVERT(int, 30.60)

SELECT CONVERT (VARCHAR(10), '2020-10-10')

SELECT CONVERT (DATETIME, '2020-10-10' )

SELECT CONVERT (NVARCHAR, GETDATE(), 112 )

SELECT CAST ('20201010' AS DATE)

-- COALESCE -- https://docs.microsoft.com/en-us/sql/t-sql/language-elements/coalesce-transact-sql

SELECT COALESCE(NULL, 'Hi', 'Hello', NULL)


-- NULLIF -- https://docs.microsoft.com/en-us/sql/t-sql/language-elements/nullif-transact-sql

SELECT NULLIF (10,10)

SELECT NULLIF(10, 11)


-- ROUND -- https://docs.microsoft.com/en-us/sql/t-sql/functions/round-transact-sql
-- Üçüncü parametre sonucun aşağıya mı yukarıya mı yuvarlanacağını belirlemek için kullanılmaktadır.
-- Default olarak 0 (yani yukarıya yuvarlama) atanmıştır. Aşağı değere yuvarlamak için 1 yazılmalıdır.
SELECT ROUND (432.368, 2, 0)
SELECT ROUND (432.368, 2, 1)
SELECT ROUND (432.368, 2)

-- ISNULL -- https://docs.microsoft.com/en-us/sql/t-sql/functions/isnull-transact-sql

SELECT ISNULL(NULL, 'ABC')

SELECT ISNULL('', 'ABC')

-- ISNUMERIC -- https://docs.microsoft.com/en-us/sql/t-sql/functions/isnumeric-transact-sql


select ISNUMERIC(123)

select ISNUMERIC('ABC')

