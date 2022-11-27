

--------------------------------------
-- DS 11/22 EU -- RDB&SQL Session 9 --
----------- 15.06.2022 ---------------
--------------------------------------

--ürünlerin stock sayılarını bulunuz
-- ilk olarak group by ile yapalım
select	pp.product_id, sum(quantity)
from	product.product pp, product.stock ps
where	pp.product_id = ps.product_id
group by	pp.product_id
;

-- product tablosu ile join yapmak zorunda değiliz. Çünkü istenen bilgilerin hepsi stock tablosunda mevcut.
-- yani şu şekilde daha sade olacaktır sorgumuz. (tabi ki sonuç her iki sorguda da aynı)
SELECT product_id, SUM(quantity) as total_stock
FROM product.stock
GROUP BY product_id
;

-- aynı sorguyu şimdi window function ile yapalım
select	*, sum(quantity) over(partition by product_id) sumWF
from	product.stock
order by product_id
;

-- Şimdi de window function sonucunda gelen resultı distinct ile group by sonucundaki gibi tekilleştirelim
select	distinct product_id,
		sum(quantity) over(partition by product_id) sumWF
from	product.stock
order by product_id
;

-- Markalara göre ortalama ürün fiyatlarını hem Group By hem de Window Functions ile hesaplayınız.
-- group by ile
select	brand_id, avg(list_price) AS avg_price
from	product.product
group by brand_id
;

-- WF ile
select	distinct brand_id, avg(list_price) over(partition by brand_id) AS avg_price
from	product.product
;

-- Aynı sorguda birden fazla aggregate function yazabiliyoruz (count, max ...)
-- Fakat her ikisinde de ayrı ayrı partition belirlememiz gerekiyor. Bu durum aslında bize esneklik sağlıyor.
-- Çünkü herbir aggregate functionı farklı bir partition için hesaplama imkanımız oluyor. (Group by da bu esneklik yok)
select	*,
		count(*) over(partition by brand_id) CountOfProduct,
		max(list_price) over(partition by brand_id) MaxListPrice
from	product.product
order by brand_id, product_id
;

-- Aşağıdaki sorguda da farklı partitionlarda aggregate function hesaplanmış
select	*,
		count(*) over(partition by brand_id) CountOfProductinBrand,
		count(*) over(partition by category_id) CountOfProductinCategory
from	product.product
order by brand_id, product_id
;


-- Window function ile oluşturduğunuz kolonlar birbirinden bağımsız hesaplanır.
-- Dolayısıyla aynı select bloğu içinde farklı partitionlar tanımlayarak yeni kolonlar oluşturabilirsiniz.
-- Örneğin:
select	product_id, brand_id, category_id, model_year,
		count(*) over(partition by brand_id) CountOfProductinBrand,
		count(*) over(partition by category_id) CountOfProductinCategory
from	product.product
order by category_id, brand_id, model_year
;

select	DISTINCT brand_id, category_id,
		count(*) over(partition by brand_id) CountOfProductinBrand,
		count(*) over(partition by category_id) CountOfProductinCategory
from	product.product
order by category_id, brand_id
;


-- Window Frames

-- Windows frame i anlamak için birkaç örnek:
-- Herbir satırda işlem yapılacak olan frame in büyüklüğünü (satır sayısını) tespit edip window frame in nasıl oluştuğunu aşağıdaki sorgu sonucuna göre konuşalım.


SELECT	category_id, product_id,
		COUNT(*) OVER() NOTHING,
		COUNT(*) OVER(PARTITION BY category_id) countofprod_by_cat,
		COUNT(*) OVER(PARTITION BY category_id ORDER BY product_id) countofprod_by_cat_2,
		COUNT(*) OVER(PARTITION BY category_id ORDER BY product_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) prev_with_current,
		COUNT(*) OVER(PARTITION BY category_id ORDER BY product_id ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) current_with_following,
		COUNT(*) OVER(PARTITION BY category_id ORDER BY product_id ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) whole_rows,
		COUNT(*) OVER(PARTITION BY category_id ORDER BY product_id ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) specified_columns_1,
		COUNT(*) OVER(PARTITION BY category_id ORDER BY product_id ROWS BETWEEN 2 PRECEDING AND 3 FOLLOWING) specified_columns_2
FROM	product.product
ORDER BY category_id, product_id
;



-- Cheapest product price in each category
-- Herbir kategorideki en ucuz ürünün fiyatı

select	distinct category_id, min(list_price) over(partition by category_id) cheapest_by_cat
from	product.product
;


-- How many different product in the product table?
-- Product tablosunda toplam kaç faklı product bulunduğu hesaplayınız.
select distinct count(*) over() as num_of_product
from product.product
;

-- How many different product in the order_item table?
-- Order_item tablosunda kaç farklı ürün bulunmaktadır?
-- Aşağıdaki sorgu herbir ürünün kaç farklı siparişte bulunduğunu getirmektedir. Dolayısıyla sorgumuzu başka bir şekilde yazmalıyız.
SELECT DISTINCT product_id, count(*) OVER (PARTITION BY product_id) number_of_product
FROM sale.order_item
;

-- Bu şekilde istenen cevabı bulmuş oluruz.
select	count(distinct product_id) UniqueProduct
from	sale.order_item
;

-- WF da count(distinct ...) e izin verilmemektedir.
select	count(distinct product_id) over() UniqueProduct
from	sale.order_item
;


-- Write a query that returns how many different products are in each order?
-- Her siparişte kaç farklı ürün olduğunu döndüren bir sorgu yazın?
-- Bir her bir siparişte kaç farklı ürünün bulunduğunu ve ayrıca toplam kaç parça ürünün bulunduğunu hesaplayalım.
select	order_id, count(distinct product_id) UniqueProduct,
		sum(quantity) TotalProduct
from	sale.order_item
group by order_id
;

select distinct [order_id]
	,count(product_id) over(partition by [order_id]) count_of_Uniqueproduct
	,sum(quantity) over(partition by [order_id]) count_of_product
from [sale].[order_item]
;



-- How many different product are in each brand in each category?
-- Herbir kategorideki herbir markada kaç farklı ürünün bulunduğu
-- Sorgu sonucunun category_id ASC, bran_id ASC kuralına uygun sıralandığını gözlemleyin.
-- Bunun nedeni distinct fonksiyonudur. SQL Server veriyi ilk olarak bu şekilde sıralar (ORDER BY 1, 2) daha sonra distinct kayıtları getirir.
select	distinct category_id, brand_id,
		count(*) over(partition by brand_id, category_id) CountOfProduct
from	product.product
;

-- Yukarıdaki sorguya bir de marka isimlerini eklemek isteseydik:
-- Subquery ile şu şekilde yapabiliriz:
select	A.*, B.brand_name
from	(
		select	distinct category_id, brand_id,
				count(*) over(partition by brand_id, category_id) CountOfProduct
		from	product.product
		) A, product.brand B
where	A.brand_id = B.brand_id
;

-- Her iki tabloyu joinleyerek şu şekilde yapabiliriz:
select	distinct category_id, A.brand_id,
		count(*) over(partition by A.brand_id, A.category_id) CountOfProduct,
		B.brand_name
from	product.product A, product.brand B
where	A.brand_id = B.brand_id
;


-- Bir sonraki derste Analytic Navigation Function konusundan devam edeceğiz