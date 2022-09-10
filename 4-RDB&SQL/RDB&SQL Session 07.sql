

--------------------------------------
-- DS 11/22 EU -- RDB&SQL Session 7 --
----------- 11.06.2022 ---------------
--------------------------------------

-- Subquerylerin kullanım yerleri (select, where, from)
-- select clause
select	order_id,
		list_price,
		(
		select	avg(list_price)
		from	product.product
		) AS avg_price
from	sale.order_item
;

-- where clause
select	order_id, order_date
from	sale.orders
where	order_date in (
					select distinct top 5 order_date
					from	sale.orders
					order by order_date desc
					)
;

-- from clause (subquery alias almak zorunda)
select	order_id, order_date
from	(
		select	top 5 *
		from	sale.orders
		order by order_date desc
		) A
;


-- Single Row Subqueries --

-- Herbir siparişin toplam fiyatını hesaplayınız. (Ürünlerin liste fiyatını baz alınız)
-- subquery kullanmadan tek bir sorgu ile yapabilirsiniz elbette.
select	order_id, sum(list_price) sum_list_price
from	sale.order_item
group by order_id
;

-- subquery kullanacağınız zaman çözüm şu şekilde olacaktır:
select	so.order_id,
		(
		select	sum(list_price)
		from	sale.order_item
		where	order_id=so.order_id
		) AS sum_price
from	sale.order_item so
group by so.order_id
;


/* Aşağıda iki SQL kodu bulunmaktadır. 
İkisi arasında sadece aliasların kullanımı açısından farklılık bulunmaktadır.
İlk sorguda outer query de ki tabloda alias vardır, ikinci sorguda ise sadece subquery deki tabloda alias vardır.
Genel yaklaşımımız mümkün mertebe farklı isimler kullanrak alias kullanmak olmalıdır.
Eğer alias kullanmazsak SQL server ilk olarak parantez içinde söz konusu sütunu aramaya başlayacaktır.
Eğer bulabilirse aynı sütun parantez dışında var mı yok mu diye kontrol etmez.
Yok eğer parantez içinde söz konusu sütun yoksa outer query de bu sütunu arayacaktır.
Fakat bu durumda alias kullanmak gerekecektir.
Bu durumdan dolayı aşağıdaki sorguların sonuçları farklı olmaktadır.
Sadece parantez içindeki sorguyu çalıştırarak hata durumunu kontrol edebilisiniz ve hangi durumlarda subquery ile outer query nin bağımlı olup olmadığını test etmiş olursunuz.
*/

--1. KOD
SELECT  B.order_id, (SELECT SUM(list_price*quantity*(1-discount)) FROM sale.order_item WHERE order_id = B.order_id ) AS TOTAL
FROM sale.order_item B
GROUP BY B.order_id
--2. KOD
SELECT  order_id, (SELECT SUM(B.list_price*B.quantity*(1-B.discount)) FROM sale.order_item B WHERE B.order_id = order_id ) AS TOTAL
FROM sale.order_item
GROUP BY order_id
;


-- subquery ile outerquerynin birbirlerine bağımlı olup olmaması
-- Eğer bir subquery içinde outer queryden bir sütun varsa bu durumda iki sorgu birbirne bağımlıdır.
-- Bu durumlarda aliaslar daha da önemli olmaktadır.


-- Multiple Rows Subqueries --

-- Davis Thomas'nın çalıştığı mağazadaki tüm personelleri listeleyin.
select	*
from	sale.staff
where	store_id = (
					select	store_id
					from	sale.staff
					where	first_name = 'Davis' and last_name = 'Thomas'
					)
;

-- Charles Cussona 'ın yöneticisi olduğu personelleri listeleyin.
select	*
from	sale.staff
where	manager_id = (
					select	staff_id
					from	sale.staff
					where	first_name = 'Charles' and last_name = 'Cussona'
					)
;

-- 'Pro-Series 49-Class Full HD Outdoor LED TV (Silver)' isimli üründen pahalı olan ürünleri listeleyin.
-- Product id, product name, model_year, fiyat, marka adı ve kategori adı alanlarına ihtiyaç duyulmaktadır.
select A.product_id, a.product_name, a.model_year, a.list_price, b.brand_name, c.category_name
from product.product A, product.brand B, product.category C
where list_price > 
	(select list_price
	from product.product 
	where product_name='Pro-Series 49-Class Full HD Outdoor LED TV (Silver)')
	and A.brand_id = B.brand_id
	and A.category_id = C.category_id
;



-- Laurel Goldammer isimli müşterinin alışveriş yaptığı tarihte/tarihlerde alışveriş yapan tüm müşterileri listeleyin.
SELECT *
FROM sale.customer AS SC, sale.orders AS SO
WHERE order_date IN (
				SELECT SO.order_date
				FROM sale.customer AS SC, sale.orders AS SO
				WHERE first_name = 'Laurel' AND last_name='Goldammer'
				AND SC.customer_id=SO.customer_id
				)
				AND SC.customer_id=SO.customer_id
				AND SO.order_status = 4
;




--List products made in 2021 and their categories other than Game, GPS, or Home Theater.
select	*
from	product.product
where	model_year = 2021 and
		category_id NOT IN (
						select	category_id
						from	product.category
						where	category_name in ('Game', 'GPS', 'Home Theater')
						) 
;


-- 2020 model ürünleri listeleyin. Fakat bu ürünler Receivers Amplifiers kategorisindeki tüm ürünlerden daha pahalı olmalıdır.
-- Ürün adı, model_yılı ve fiyat bilgilerini yüksek fiyattan düşük fiyata doğru sıralayınız.
-- 1. yöntem: single row subquery
select	*
from	product.product
where	model_year = 2020 and
		list_price > (
			select	max(B.list_price)
			from	product.category A, product.product B
			where	A.category_name = 'Receivers Amplifiers' and
					A.category_id = B.category_id
		)
;

-- 2. yöntem: multiple rows subquery
select	*
from	product.product
where	model_year = 2020 and
		list_price > ALL (
			select	B.list_price
			from	product.category A, product.product B
			where	A.category_name = 'Receivers Amplifiers' and
					A.category_id = B.category_id
			)
;

-- 2020 model ürünleri listeleyin. Fakat bu ürünler Receivers Amplifiers kategorisindeki herhangi bir ürün daha pahalı olmalıdır.
-- Ürün adı, model_yılı ve fiyat bilgilerini yüksek fiyattan düşük fiyata doğru sıralayınız.
-- 1. yöntem: single row subquery
select	*
from	product.product
where	model_year = 2020 and
		list_price > (
			select	min(B.list_price)
			from	product.category A, product.product B
			where	A.category_name = 'Receivers Amplifiers' and
					A.category_id = B.category_id
		)
;

-- 2. yöntem: multiple rows subquery
select	*
from	product.product
where	model_year = 2020 and
		list_price > ANY (
			select	B.list_price
			from	product.category A, product.product B
			where	A.category_name = 'Receivers Amplifiers' and
					A.category_id = B.category_id
			)
;


-- Multiple rows subquery sonucunda min, max gibi sorgu sonucunu tek bir değer ile ifade edebiliyorsanız
-- bu durumda subquery içinde group by min, max almak daha performanslı olacaktır.
-- Yok eğer multiple rows subquery sonucunda text bir veri dönüyorsa multiple rows subquery kullanmak kaçınılmaz olacaktır.

