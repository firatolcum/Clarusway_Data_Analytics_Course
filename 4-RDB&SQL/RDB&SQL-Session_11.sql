

---------------------------------------
-- DS 11/22 EU -- RDB&SQL Session 11 --
----------- 15.06.2022 ----------------
---------------------------------------


-- row_number()
select	product_id, category_id, list_price,
		ROW_NUMBER() over(partition by category_id order by list_price ASC) RowNum
from	product.product
-- order by 2, 3
;


-- rank() ve dense_rank()
select	product_id, category_id, list_price,
		ROW_NUMBER() over(partition by category_id order by list_price ASC) RowNum,
		RANK() over(partition by category_id order by list_price ASC) [Rank],
		DENSE_RANK() over(partition by category_id order by list_price ASC) Dense_Rank
from	product.product
;

-- Herbir model_yili içinde ürünlerin fiyat sıralamasını yapınız (artan fiyata göre 1'den başlayıp birer birer artacak)
-- row_number(), rank(), dense_rank()
SELECT product_id, model_year,list_price,
		ROW_NUMBER() OVER(PARTITION BY model_year ORDER BY list_price ASC) RowNum,
		RANK() OVER(PARTITION BY model_year ORDER BY list_price ASC) RankNum,
		DENSE_RANK() OVER(PARTITION BY model_year ORDER BY list_price ASC) DenseRankNum
FROM product.product;


-- Write a query that returns the cumulative distribution of the list price in product table by brand.
-- product tablosundaki list price' ların kümülatif dağılımını marka kırılımında hesaplayınız
SELECT brand_id, list_price,
		round(CUME_DIST() OVER(PARTITION BY brand_id ORDER BY list_price), 3) AS CUM_DIST
FROM product.product
;


--Write the same query that returns the relative standing of the list price in product table by brand.
-- Ayni sorguyu PERCENT_RANK fonksiyonu ile de yapıp sonuçları karşılaştırınız.
SELECT brand_id, list_price,
		round(CUME_DIST() OVER(PARTITION BY brand_id ORDER BY list_price), 3) AS CumDist,
		round(PERCENT_RANK() OVER(PARTITION BY brand_id ORDER BY list_price), 3) AS PercentRank
FROM product.product
;


-- Yukarıdaki sorguda CumDist alanını CUME_DIST fonksiyonunu kullanmadan hesaplayınız.
-- CUME_DIST fonksiyonunun formulünü kabaca ROW_NUMBER() / TOTAL COUNT olarak düşünebiliriz. Fakat bazı istisnalar vardır.
-- Örneğin ORDER BY da belirttiğimiz sıralama göre ard arda aynı değerler gelirse CUME_DIST fonksiyonu hepsi için aynı sonucu döndürmektedir.
-- Bu tip durumlarda CUME_DIST fonksiyonu maksimum olan ROW_NUMBER değerini baz alııyor.
-- Örneğin yukarıdaki sorgudaki CUME_DIST değerlerini CUME_DIST fonksiyonu olmadan kullanmak istediğimizde ilk olarak
-- herbir partition daki toplam satır sayısını hesaplamamız gerekiyor.
-- Daha sonra row_number değerlerini hesaplıyoruz.
-- Ardarda gelen satırlar varsa bunları da belirleyebilmek için bir de rank() değerlerini hesaplıyoruz.
	with tbl1 as (
		select	brand_id, list_price,
				count(*) over(partition by brand_id) TotalProductInBrand,
				row_number() over(partition by brand_id order by list_price) RowNum,
				rank() over(partition by brand_id order by list_price) RankNum
		from	product.product
	),

	-- tbl1 tablosu yukarıdaki açıklamada yer alan değerleri içermektedir.
	-- Şimdi sıra aynı rank değerlerini alan satırlarda CUME_DIST değerini hesaplamak için maksiumum olan ROW_NUMBER değerini almaya
	-- Bunu da tbl2 isminde oluşturduğumuz ikinci CTE ile tanımlıyoruz.
	-- Aynı Rank değerlerinde maksimum olan RowNum alan yeni bir sütun oluşturup adınıa RowNum2 diyoruz.
	-- RowNum, RankNum ve RowNum2 değerlerini kıyaslayabilirsiniz.
	tbl2 as (
	select *,
		max(RowNum) over(partition by brand_id, RankNum) RankNum2
	from tbl1
	)

	-- Son olarak Cume_Dist değerini aşağıdaki sorguda hem manuel hem de window function ile hesapladık ve
	-- her iki değerin de aynı olduğunu gördük.
	select *,
		cast(RankNum2 as float) / TotalProductInBrand CumeDistManuel,
		cume_dist() over(partition by brand_id order by list_price) CumeDistWindowFunction
	from tbl2
	;



--Siparişlerde yer alan ürünlerin liste fiyatlarının ortalaması.
--Tüm ürünlerin siparişlerdeki net fiyatlarının (indirim sonrası) ortalaması.
SELECT
	DISTINCT order_id,
	AVG(list_price) OVER(PARTITION BY order_id ) avg_price,
	AVG(list_price * quantity* (1-discount)) OVER() avg_net_amount
FROM sale.order_item
;

--List orders for which the average product price is higher than the average net amount.
--Ortalama ürün fiyatının ortalama net tutardan yüksek olduğu siparişleri listeleyin.
select distinct order_id, a.Avg_price,a.Avg_net_amount
from (
	select *,
	avg(list_price*quantity*(1-discount))  over() Avg_net_amount,
	avg(list_price)  over(partition by order_id) Avg_price
	from [sale].[order_item]
) A
where  a.Avg_price > a.Avg_net_amount
order by 2
;


--Calculate the stores' weekly cumulative number of orders for 2018
--mağazaların 2018 yılına ait haftalık kümülatif sipariş sayılarını hesaplayınız
-- Haftanın ilk gününün Pazar ya da Pazartesi olmasına göre hafta numarasını farklı şekilllerde hesaplayabilirsiniz.
-- Bunun için datepart() fonksiyonu içindeki parametrelerin açıklamalarına göz atabilirsiniz: https://docs.microsoft.com/en-us/sql/t-sql/functions/datepart-transact-sql
select distinct a.store_id, a.store_name, -- b.order_date,
	datepart(ISO_WEEK, b.order_date) WeekOfYear,
	COUNT(*) OVER(PARTITION BY a.store_id, datepart(ISO_WEEK, b.order_date)) weeks_order,
	COUNT(*) OVER(PARTITION BY a.store_id ORDER BY datepart(ISO_WEEK, b.order_date)) cume_total_order
from sale.store A, sale.orders B
where a.store_id=b.store_id and year(order_date)='2018'
ORDER BY 1, 3
;


--Calculate 7-day moving average of the number of products sold between '2018-03-12' and '2018-04-12'.
--'2018-03-12' ve '2018-04-12' arasında satılan ürün sayısının 7 günlük hareketli ortalamasını hesaplayın.
with tbl as (
	select	B.order_date, sum(A.quantity) SumQuantity --A.order_id, A.product_id, A.quantity
	from	sale.order_item A, sale.orders B
	where	A.order_id = B.order_id
	group by B.order_date
)

select	*,
	avg(SumQuantity*1.0) over(order by order_date rows between 6 preceding and current row) sales_moving_average_7
from	tbl
where	order_date between '2018-03-12' and '2018-04-12'
order by 1

-- Yukarıdaki sorguda dikkat edilmesi gereken birkaç husus var:
-- 1. Ortalamada virgülden sonraki değerler önem arz ediyorsa SumQuantity değerini ortalamaya dahil etmeden önce float yapmalıyız.
-- Sayıyı 1.0 ile çarparak ya da cast(SumQuantity as float) ile float yapabilirsiniz.
-- 2. Bazı günlerde hiç sipariş verilmediği için o tarihler sonuçta gelmemektedir.
-- Eğer bu tarihlerin de sonuçta gelmesini istiyorsanız ilk olarak tüm tarihlerin satır bazında yer aldığı bir tablo oluşturursunuz.
-- Daha sonra bu tabloya left join ile biraz önce yaptığımız sorguyu join yaparsınız. Sonuçta sipariş verilmeyen tarihlerdeki değerler boş olacaktır.
-- 3. Geriye dönük 7 günlük ortalama hesaplanırken ilk olarak WHERE bloğundaki kriter çalışır. Daha sonra window function çalışır.
-- Eğer hesaplamada bir eksiklik olmasını istemiyorsanız ilk olarak window function ile tüm tarihlerdeki doğru değerleri hesaplayıp,
-- daha sonra outer query de where bloğunda filtreleme yapabilirsiniz.
-- Aşağıdaki örnekte olduğu gibi:
with tbl as (
	select	B.order_date, sum(A.quantity) SumQuantity --A.order_id, A.product_id, A.quantity
	from	sale.order_item A, sale.orders B
	where	A.order_id = B.order_id
	group by B.order_date
)

select	*
from	(
	select	*,
		avg(SumQuantity*1.0) over(order by order_date rows between 6 preceding and current row) sales_moving_average_7
	from	tbl
) A
where	A.order_date between '2018-03-12' and '2018-04-12'
order by 1

