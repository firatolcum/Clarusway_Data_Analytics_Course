


---------------------------------------
-- DS 11/22 EU -- RDB&SQL Session 12 --
----------- 20.06.2022 ----------------
---------------------------------------


-- SQL Server da index tiplerini, execution plan ları incelemek için bir demo tablo oluşturuyoruz.
-- Tablodaki veriler rastgele oluşturulmuştur.
-- Dikkat edilmesi gereken noktalar index yapıları ve execution planlardır.

-- Önce tabloyu oluşturuyoruz
create table website_visitor 
(
visitor_id int,
ad varchar(50),
soyad varchar(50),
phone_number bigint,
city varchar(50)
)
;

-- Temsili olarak 200 bin satır insert ediyoruz.
-- Bu scriptte yer alan declare komutu ve @ ile gösterilen değişkenleri bir sonraki derste göreceğiz.
-- Şimdilik bunlara takılmayın.
DECLARE @i int = 1
DECLARE @RAND AS INT
WHILE @i<200000
BEGIN
	SET @RAND = RAND()*81
	INSERT website_visitor
		SELECT @i , 'visitor_name' + cast (@i as varchar(20)), 'visitor_surname' + cast (@i as varchar(20)),
		5326559632 + @i, 'city' + cast(@RAND as varchar(2))
	SET @i +=1
END
;


--Tabloyu kontrol edelim.
SELECT top 10*
FROM	website_visitor
;

--İstatistikleri (Process ve time) açıyoruz, bunu açmak zorunda değilsiniz sadece yapılan işlemlerin detayını görmek için açtık.
SET STATISTICS IO on
SET STATISTICS TIME on



--herhangi bir index olmadan visitor_id' ye şart verip tüm tabloyu çağırıyoruz
-- Aşağıdaki sorguyu seçip CTRL+L kısayol tuşuna basıp execution planı görebilirsiniz.
-- Tablomuzda henüz index create edilmediği için Full Scan yaptığını görebilirsiniz.
SELECT *
FROM
website_visitor
where
visitor_id = 100
;

-- Şimdi tablomuza create index edip tekrar execution planı çalıştırın.
Create CLUSTERED INDEX CLS_INX_1 ON website_visitor (visitor_id);

-- Artık indexin kullanıldığını ve SCAN yerine SEEK yapıldığı görebilirsiniz.
SELECT *
FROM
website_visitor
where
visitor_id = 100
;

-- Ad sütununa index olmadan aşağıdaki sorgunun execution planını çıkaralım.
-- Bu planda da SQL Server ın tüm satırları okuduğunu (estimated number of rows to be read) göreceksiniz.
SELECT ad
FROM
website_visitor
where
ad = 'visitor_name17'
;

-- Ad sütunu üzerine conclustered index create edelim.
-- Tablomuzda clustered index olduğu için ikinci bir clustered index oluşturamayız.
CREATE NONCLUSTERED INDEX ix_NoN_CLS_1 ON website_visitor (ad);

-- Tekrar execution plan a baktığımızda ikinci oluşturduğumuz indexin kullanıldığını göreceksiniz.
SELECT ad
FROM
website_visitor
where
ad = 'visitor_name17'
;

-- Ad ve soyad birlikte çağırıldığında execution planı tekrar inceleyin.
SELECT ad, soyad
FROM
website_visitor
where
ad = 'visitor_name17'
;

-- Şimdi ad ve soyad ikilisi çağırıldığında sorgunun hızlı çalışması için yeni bir index create edelim.
Create unique NONCLUSTERED INDEX ix_NoN_CLS_2 ON website_visitor (ad) include (soyad)
;


-- Tekrar execution plan a bakıldığında her iki alanında indexten geldiğini göreceksiniz.
SELECT ad, soyad
FROM
website_visitor
where
ad = 'visitor_name17'
;

-- clustered index (visitor_id)
-- nonclustered index (ad)
-- nonclustered index (ad) include (soyad)

-- Soyad sütununda tek olarak index oluşturulmamıştı.
-- Bundan dolayı sadece soyad istendiğinde sorgunun hızlı olmasını istiyorsanız ayrıca bir index daha tanımlamamız gerekecek.
SELECT soyad
FROM
website_visitor
where
soyad = 'visitor_surname17'
;

-- Aşağıdaki indexi oluşturup execution plan a tekrar bakınız.
CREATE NONCLUSTERED INDEX ix_NoN_CLS_3 ON website_visitor (soyad);
