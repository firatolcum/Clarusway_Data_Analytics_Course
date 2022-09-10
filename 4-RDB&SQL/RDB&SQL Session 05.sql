

--------------------------------------
-- DS 11/22 EU -- RDB&SQL Session 5 --
----------- 08.06.2022 ---------------
--------------------------------------

-- https://docs.microsoft.com/en-us/sql/t-sql/queries/select-group-by-transact-sql

-- Toplam kaç farklı marka bulunmaktadır?
-- Bu sorguda GROUP BY syntax kullanmadık böylece tablomuzun tamamını tek bir grup olarak değerlendirdik.
select	count(*)
from	product.brand
;


-- Herbir markaya ait kaç ürün bulunmaktadır?
-- Select bloğunda brand_id yazmazsanız ne olur?
select	brand_id, count(*) AS CountOfProduct
from	product.product
group by brand_id
;

-- Aggregate function lar NULL kayıtları değerlendirmez.
-- Yani satır sayısını saydırmak için en iyi yol count(*) yazmaktadır.
-- Count(column_name) yazarsanız bu sütundaki NULL değerler hesaba katılayacaktır.

-- Herbir kategorideki toplam ürünü sayısını yazdırınız.
select	category_id, count(*) CountOfProduct
from	product.product
group by category_id
;

-- Herbir kategorideki toplam ürünü sayısını yazdırınız.
-- Sonuç olarak Category_id, Category_name ve Ürün miktarı bulunsun
select	a.category_id, b.category_name, count(*) CountOfProduct
from	product.product a
inner join product.category b
on	a.category_id = b.category_id
group by a.category_id, b.category_name
;


-- Model yılı 2016 dan büyük olan ürünlerinin liste fiyatları ortalaması 1000 den fazla olan markaları listeleyin.
-- https://docs.microsoft.com/en-us/sql/t-sql/queries/select-having-transact-sql
select	b.brand_name, avg(a.list_price) AS AvgPrice
from	product.product a, product.brand b
where	a.brand_id = b.brand_id
		and a.model_year > 2016
group by b.brand_name
having avg(a.list_price) > 1000
order by 2 DESC
;

-- Having clause içinde aggregate functionın tamamını yazmanız gerekiyor. Select bloğunda yazıldığı gibi
-- Order by clause içinde ALIAS kullanabilirsiniz, ya da sütun sırasını da yazabilirsiniz


--maximum list price' ı 4000' in üzerinde olan veya minimum list price' ı 500' ün altında olan categori id' leri getiriniz
--category name' e gerek yok.
select	category_id, max(list_price), min(list_price)
from	product.product
group by category_id
having max(list_price) > 4000 or
		min(list_price) < 500
;

--bir siparişin toplam net tutarını getiriniz. (müşterinin sipariş için ödediği tutar)
--discount' ı ve quantity' yi ihmal etmeyiniz.
select [order_id], sum([list_price]*[quantity]*(1-[discount]))
from [sale].[order_item]
group by [order_id]
;


-- grouping sets
-- Custom olarak grupları belirleyebilirsiniz.
-- Group setlerini değiştirip sorgu sonuçlarını karşılaştırınız.
select	category_id, model_year, count(*) CountOfProducts
from	product.product
group by
	grouping sets (
				(category_id), -- 1. group
				(model_year), -- 2. group
				(category_id, model_year) -- 3. group
	)
-- having model_year is null
order by 1, 2
;


-- rollup
select	category_id, model_year, count(*) CountOfProducts
from	product.product
group by 
	rollup (category_id, model_year)
;

select	category_id, brand_id, model_year, count(*) CountOfProducts
from	product.product
group by
	rollup(category_id, brand_id, model_year)
;


-- cube
select	brand_id, category_id, model_year, count(*) CountOfProducts
from	product.product
group by 
	cube (brand_id, category_id, model_year)
;


-- PIVOT table
-- SQL Server da pivot table scriptini hazırlamak biraz zahmetli olabilir.
-- İleri aşamalarda prosedürler yazıp PIVOT table scripti üreten prosedürler yazabilirsiniz.
-- Bu prosedürün çıktısındaki SQL sorgusunu da execute edip amaca ulaşmış olursunuz.
-- https://docs.microsoft.com/en-us/sql/t-sql/queries/from-using-pivot-and-unpivot
-- model yıllarına göre toplam ürün sayısı
SELECT *
FROM
			(
			SELECT Model_Year, product_id
			FROM product.product
			) A
PIVOT
(
	count(product_id)
	FOR Model_Year IN
	(
	[2018], [2019], [2020], [2021]
	)
) AS PIVOT_TABLE
;

-- Herbir kategori altında model yıllarına göre toplam ürün sayısı
-- Bir üstteki sorgu ile bu sorguyu karşılaştırınız
SELECT *
FROM
			(
			SELECT category_id, Model_Year, product_id
			FROM product.product
			) A
PIVOT
(
	count(product_id)
	FOR Model_Year IN
	(
	[2018], [2019], [2020], [2021]
	)
) AS PIVOT_TABLE
;
