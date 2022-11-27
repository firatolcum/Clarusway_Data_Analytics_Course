




CREATE DATABASE LibDatabase;

Use LibDatabase;


--Create Two Schemas
CREATE SCHEMA Book;
---
CREATE SCHEMA Person;



--create Book.Book table
CREATE TABLE [Book].[Book](
	[Book_ID] [int] PRIMARY KEY NOT NULL,
	[Book_Name] [nvarchar](50) NOT NULL,
	Author_ID INT NOT NULL,
	Publisher_ID INT NOT NULL

	);


--create Book.Author table

CREATE TABLE [Book].[Author](
	[Author_ID] [int],
	[Author_FirstName] [nvarchar](50) Not NULL,
	[Author_LastName] [nvarchar](50) Not NULL
	);



--create Publisher Table

CREATE TABLE [Book].[Publisher](
	[Publisher_ID] [int] PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[Publisher_Name] [nvarchar](100) NULL
	);




--create Person.Person table

CREATE TABLE [Person].[Person](
	[SSN] [bigint] PRIMARY KEY NOT NULL,
	[Person_FirstName] [nvarchar](50) NULL,
	[Person_LastName] [nvarchar](50) NULL
	);


--create Person.Loan table

CREATE TABLE [Person].[Loan](
	[SSN] BIGINT NOT NULL,
	[Book_ID] INT NOT NULL,
	PRIMARY KEY ([SSN], [Book_ID])
	);




--cretae Person.Person_Phone table

CREATE TABLE [Person].[Person_Phone](
	[Phone_Number] [bigint] PRIMARY KEY NOT NULL,
	[SSN] [bigint] NOT NULL	
	);


--cretae Person.Person_Mail table

CREATE TABLE [Person].[Person_Mail](
	[Mail_ID] INT PRIMARY KEY IDENTITY (1,1),
	[Mail] NVARCHAR(MAX) NOT NULL,
	[SSN] BIGINT UNIQUE NOT NULL	
	);


--Tablolarý yukarýdaki þekilde öncelikle create edip devam ediniz.
--Aþaðýda DML komutlarýný örneklendirip tablo constraintlerini sonradan tanýmlayacaðýz. 
--Örnek olarak insert ettiðimiz verileri sonradan sileceðiz. 
--Gerçek deðerlerin insert edilmesi iþlemini sizlere býkarýyor olacaðým.


----------INSERT

----!!! ilgili kolonun özelliklerine ve kýsýtlarýna uygun veri girilmeli !!!


-- Insert iþlemi yapacaðýnýz tablo sütunlarýný aþaðýdaki gibi parantez içinde belirtebilirsiniz.
-- Bu kullanýmda sadece belirttiðiniz sütunlara deðer girmek zorundasýnýz. Sütun sýrasý önem arz etmektedir.

INSERT INTO Person.Person (SSN, Person_FirstName, Person_LastName) VALUES (75056659595,'Zehra', 'Tekin')

INSERT INTO Person.Person (SSN, Person_FirstName) VALUES (889623212466,'Kerem')


--Eðer bir tablodaki tüm sütunlara insert etmeyecekseniz, seçtiðiniz sütunlarýn haricindeki sütunlar Nullable olmalý.
--Eðer Not Null constrainti uygulanmýþ sütun varsa hata verecektir.

--Aþaðýda Person_LastName sütununa deðer girilmemiþtir. 
--Person_LastName sütunu Nullable olduðu için Person_LastName yerine Null deðer atayarak iþlemi tamamlar.

INSERT INTO Person.Person (SSN, Person_FirstName) VALUES (78962212466,'Kerem')

--Insert edeceðim deðerler tablo kýsýtlarýna ve sütun veri tiplerine uygun olmazsa aþaðýdaki gibi iþlemi gerçekleþtirmez.


--Insert keywordunden sonra Into kullanmanýza gerek yoktur.
--Ayrýca Aþaðýda olduðu gibi insert etmek istediðiniz sütunlarý belirtmeyebilirsiniz. 
--Buna raðmen sütun sýrasýna ve yukarýdaki kurallara dikkat etmelisiniz.
--Bu kullanýmda tablonun tüm sütunlarýna insert edileceði farz edilir ve sizden tüm sütunlar için deðer ister.

INSERT Person.Person VALUES (15078893526,'Mert','Yetiþ')

--Eðer deðeri bilinmeyen sütunlar varsa bunlar yerine Null yazabilirsiniz. 
--Tabiki Null yazmak istediðiniz bu sütunlar Nullable olmalýdýr.

INSERT Person.Person VALUES (55556698752, 'Esra', Null)



--Ayný anda birden fazla kayýt insert etmek isterseniz;

INSERT Person.Person VALUES (35532888963,'Ali','Tekin');-- Tüm tablolara deðer atanacaðý varsayýlmýþtýr.
INSERT Person.Person VALUES (88232556264,'Metin','Sakin')


--Ayný tablonun ayný sütunlarýna birçok kayýt insert etmek isterseniz aþaðýdaki syntaxý kullanabilirsiniz.
--Burada dikkat edeceðiniz diðer bir konu Mail_ID sütununa deðer atanmadýðýdýr.
--Mail_ID sütunu tablo oluþturulurken identity olarak tanýmlandýðý için otomatik artan deðerler içerir.
--Otomatik artan bir sütuna deðer insert edilmesine izin verilmez.

INSERT INTO Person.Person_Mail (Mail, SSN) 
VALUES ('zehtek@gmail.com', 75056659595),
	   ('meyet@gmail.com', 15078893526),
	   ('metsak@gmail.com', 35532558963)

--Yukarýdaki syntax ile aþaðýdaki fonksiyonlarý çalýþtýrdýðýnýzda,
--Yaptýðýnýz son insert iþleminde tabloya eklenen son kaydýn identity' sini ve tabloda etkilenen kayýt sayýsýný getirirler.
--Not: fonksiyonlarý teker teker çalýþtýrýn.

SELECT @@IDENTITY--last process last identity number
SELECT @@ROWCOUNT--last process row count



--Aþaðýdaki syntax ile farklý bir tablodaki deðerleri daha önceden oluþturmuþ olduðunuz farklý bir tabloya insert edebilirsiniz.
--Sütun sýrasý, tipi, constraintler ve diðer kurallar yine önemli.

select * into Person.Person_2 from Person.Person-- Person_2 þeklinde yedek bir tablo oluþturun


INSERT Person.Person_2 (SSN, Person_FirstName, Person_LastName)
SELECT * FROM Person.Person where Person_FirstName like 'M%'


--Aþaðýdaki syntaxda göreceðiniz üzere hiçbir deðer belirtilmemiþ. 
--Bu þekilde tabloya tablonun default deðerleriyle insert iþlemi yapýlacaktýr.
--Tabiki sütun constraintleri buna elveriþli olmalý. 

INSERT Book.Publisher
DEFAULT VALUES


--Update


--Update iþleminde koþul tanýmlamaya dikkat ediniz. Eðer herhangi bir koþul tanýmlamazsanýz 
--Sütundaki tüm deðerlere deðiþiklik uygulanacaktýr.



UPDATE Person.Person_2 SET Person_FirstName = 'Default_Name'--burayý çalýþtýrmadan önce yukarýdaki scripti çalýþtýrýn

--Where ile koþul vererek 88963212466 SSN ' ye sahip kiþinin adýný Can þeklinde güncelliyoruz.
--Kiþinin önceki Adý Kerem' di.

UPDATE Person.Person_2 SET Person_FirstName = 'Can' WHERE SSN = 78962212466


select * from Person.Person_2




--Join ile update

----Aþaðýda Person_2 tablosunda person id' si 78962212466 olan þahsýn (yukarýdaki þahýs) adýný,
----Asýl tablomuz olan Person tablosundaki haliyle deðiþtiriyoruz.
----Bu iþlemi yaparken iki tabloyu SSN üzerinden Join ile birleþtiriyoruz
----Ve kaynak tablodaki SSN' ye istediðimiz þartý veriyoruz.

UPDATE Person.Person_2 SET Person_FirstName = B.Person_FirstName 
FROM Person.Person_2 A Inner Join Person.Person B ON A.SSN=B.SSN
WHERE B.SSN = 78962212466


--Subquery ile Update

--Aþaðýda Person_2 tablosundaki bir ismin deðerini bir sorgu neticesinde gelen bir deðere eþitleme iþlemi yapýlmaktadýr.

UPDATE Person.Person_2 SET Person_FirstName = (SELECT Person_FirstName FROM Person.Person where SSN = 78962212466) 
WHERE SSN = 78962212466



---
----delete
--Delete' nin ne anlama geldiðini artýk biliyor olmalýsýnýz.
--Delete kullanýmýnda, Delete ile tüm verilerini sildiðiniz bir tabloya yeni bir kayýt eklediðinizde,
--Eðer tablonuzda otomatik artan bir identity sütunu var ise eklenen yeni kaydýn identity'si, 
--silinen son kaydýn identity'sinden sonra devam edecektir.


--örneðin aþaðýda otomatik artan bir identity primary keye sahip Book.Publisher tablosuna örnek olarak veri ekleniyor.

insert Book.Publisher values ('Ýþ Bankasý Kültür Yayýncýlýk'), ('Can Yayýncýlýk'), ('Ýletiþim Yayýncýlýk')


--Delete ile Book.Publisher tablosunun içi tekrar boþaltýlýyor.

Delete from Book.Publisher 

--kontrol
select * from Book.Publisher 

--Book.Publisher tablosuna yeni bir veri insert ediliyor
insert Book.Publisher values ('ÝLETÝÞÝM')

--Tekrar kontrol ettiðimizde yeni insert edilen kaydýn identity'sinin eski tablodaki sýradan devam ettiði görülecektir.
select * from Book.Publisher



---/////////////////////////////

--//////////////////////////////


--Buradan sonraki kýsýmda Constraint ve Alter Table örnekleri yapýlacaktýr.
--Yapacaðýmýz iþlemlerin tutarlý olmasý için öncelikle yukarýda örnek olarak veri insert ettiðimiz tablolarýmýzý boþaltalým.


DROP TABLE Person.Person_2;--Artýk ihtiyacýmýz yok.

TRUNCATE TABLE Person.Person_Mail;
TRUNCATE TABLE Person.Person;
TRUNCATE TABLE Book.Publisher;





---------Book tablomuz bir primary key' e sahip

-- Foreign key konstraint' leri belirlememiz gerekiyor

ALTER TABLE Book.Book ADD CONSTRAINT FK_Author FOREIGN KEY (Author_ID) REFERENCES Book.Author (Author_ID)

ALTER TABLE Person.Book ADD CONSTRAINT FK_Publisher FOREIGN KEY (Publisher_ID) REFERENCES Book.Publisher (Publisher_ID)

---------Author

--Author tablomuza primary key atamamýz gerekli, çünkü oluþtururken atanmamýþ
--Burada bir hata alacaksýnýz ve tabloda bir düzenleme yapmanýz gerekecek, 
--Bu tecrübeyi yaþamanýzý ve sorunu çözmenizi bekliyorum. Aksi taktirde bir sonraki tabloda da hata alýrsýnýz. :)



ALTER TABLE Book.Author ADD CONSTRAINT pk_author PRIMARY KEY (Author_ID)


ALTER TABLE Book.Author ALTER COLUMN Author_ID INT NOT NULL


--publisher ve person tablolarý da primary key' e sahip.



--Person.Loan tablosuna Constraint eklemeliyiz.

---------Person.Loan tablosuna foreign key constraint eklemeliyiz


ALTER TABLE Person.Loan ADD CONSTRAINT FK_PERSON FOREIGN KEY (SSN) REFERENCES Person.Person (SSN)
ON UPDATE NO ACTION
ON DELETE NO ACTION


ALTER TABLE Person.Loan ADD CONSTRAINT FK_book FOREIGN KEY (Book_ID) REFERENCES Book.Book (Book_ID)
ON UPDATE NO ACTION
ON DELETE CASCADE


--Publisher tablosu normal.


---------Person.Person tablosundaki SSN sütununa 11 haneli olmasý gerektiði için check constraint ekleyelim.


Alter table Person.Person add constraint FK_PersonID_check Check (SSN between 9999999999 and 99999999999)

--Alttaki constraint' te check ile bir fonksiyonun doðrulanma durumunu sorguluyoruz.
--Fonksiyon gerçek hayatta kullanýlan TC kimlik no algoritmasýný çalýþtýrýyor.
--Yapýlan check kontrolu bu fonksiyonun süzgecinden geçiyor, eðer ID numarasý fonksiyona uyuyorsa fonksiyon 1 deðeri üretiyor ve
--iþlem gerçekleþtiriliyor. Fonksiyon 0 deðerini üretirse bu ID numarasýnýn istenen koþullarý saðlamadýðý anlamýna geliyor ve 
--Ýþlam yapýlmýyor.
--Fonksiyonu çalýþtýrabilmeniz için fonksiyonu bu database altýnda create etmeniz gerekmektedir.
--Fonksiyonun scriptini ayrýca göndereceðim.

Alter table Person.Person add constraint FK_PersonID_check2 Check (dbo.KIMLIKNO_KONTROL(SSN) = 1)



---------Person.Person_Phone

--Person_Phone tablosuna SSN için foreign key constraint oluþturmamýz gerekli.

Alter table Person.Person_Phone add constraint FK_Person2 Foreign key (SSN) References Person.Person(SSN)

--Phone_Number için check...

Alter table Person.Person_Phone add constraint FK_Phone_check Check (Phone_Number between 999999999 and 9999999999)

--

-------------Person.Person_Mail için Foreign key tanýmlamamýz gerekli

Alter table Person.Person_Mail add constraint FK_Person4 Foreign key (SSN) References Person.Person(SSN)


---Bu aþamada Database diagramýnýzý çizip tüm tablolar arasýndaki baðlantýlarýn oluþtuðundan emin olmanýzý bekliyorum.


--Insert iþlemlerini size býrakýyorum, hata alarak, constraintlerin ne anlama geldiðini kendiniz tecrübe ederek yapmanýz daha deðerli.
--Index konusuyla ilgili derste iþlediðimiz scripti ayrýca göndereceðim.
--Buradaki Tablolarýn indexlerini oluþturmanýz için Mentoring weekly agendaya not býrakýyorum. Birlikte veya bireysel olarak çalýþabilirsiniz.


--Herhangi bir probleminizde daima slackten ulaþabilirsiniz. 
--Saðlýcakla, iyi çalýþmalar.












