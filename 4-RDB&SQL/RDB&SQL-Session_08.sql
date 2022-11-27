


--------------------------------------
-- DS 11/22 EU -- RDB&SQL Session 8 --
----------- 13.06.2022 ---------------
--------------------------------------

-- EXISTS -- NOT EXISTS --
-- Apple - Pre-Owned iPad 3 - 32GB - White ürününü satın alan müşterilerin eyalet listesini getiriniz.
-- Bu sorgu normal join ile de yapılabilir NOT EXISTS ile de yapılabilir.
-- 1. çözüm: join ile
select	distinct C.state
from	product.product P,
		sale.order_item I,
		sale.orders O,
		sale.customer C
where	P.product_name = 'Apple - Pre-Owned iPad 3 - 32GB - White' and
		P.product_id = I.product_id and
		I.order_id = O.order_id and
		O.customer_id = C.customer_id
;

-- 2. çözüm
select	distinct [state]
from	sale.customer C2
where	not exists (
			select	1
			from	product.product P,
					sale.order_item I,
					sale.orders O,
					sale.customer C
			where	P.product_name = 'Apple - Pre-Owned iPad 3 - 32GB - White' and
					P.product_id = I.product_id and
					I.order_id = O.order_id and
					O.customer_id = C.customer_id
					and C2.state = C.state
		)
;



-- Burkes Outlet mağaza stoğunda bulunmayıp,
-- Davi techno mağazasında bulunan ürünlerin stok bilgilerini döndüren bir sorgu yazın.

SELECT
	PC.product_id, PC.store_id, PC.quantity, SS.store_name
FROM
	product.stock PC, sale.store SS
WHERE
	PC.store_id = SS.store_id AND SS.store_name = 'Davi techno Retail' AND
	NOT EXISTS (SELECT 1
				FROM
					product.stock A, sale.store B
				WHERE
					A.store_id = B.store_id AND B.store_name = 'Burkes Outlet' AND
					PC.product_id = A.product_id AND A.quantity>0
		)
;

-- Stok miktarlarının veritabanında nasıl tutulduğunu bilmek önemlidir.
-- Stoğu bitmiş ürünlerin stok tablosundaki ilgili satırında quantity alanı 0 olmaktadır (veritabanımızdaki durum)
-- Dolayısıyla aşağıdaki sorgu da yukarıdaki ile aynı sonucu vermektedir.
-- Eğer stoğu bitmiş ürünler stok tablosundan siliniyor olsaydı aşağıdaki sorgu eksik sonuç getirecekti.
SELECT PC.product_id, PC.store_id, PC.quantity
FROM product.stock PC, sale.store SS
WHERE PC.store_id = SS.store_id AND SS.store_name = 'Davi techno Retail' AND
	 EXISTS ( SELECT DISTINCT A.product_id, A.store_id, A.quantity
			FROM product.stock A, sale.store B
			WHERE A.store_id = B.store_id AND B.store_name = 'Burkes Outlet' AND
				PC.product_id = A.product_id AND A.quantity=0
	)
;



-- Brukes Outlet storedan alınıp The BFLO Store mağazasından hiç alınmayan ürün var mı?
-- Varsa bu ürünler nelerdir?
-- Ürünlerin satış bilgileri istenmiyor, sadece ürün listesi isteniyor.

SELECT P.product_name, p.list_price, p.model_year
FROM product.product P
WHERE NOT EXISTS (
		SELECt	I.product_id
		FROM	sale.order_item I,
				sale.orders O,
				sale.store S
		WHERE	I.order_id = O.order_id AND S.store_id = O.store_id 
				AND S.store_name = 'The BFLO Store' 
				and P.product_id = I.product_id)
	AND
	EXISTS (
		SELECt	I.product_id
		FROM	sale.order_item I,
				sale.orders O,
				sale.store S
		WHERE	I.order_id = O.order_id AND S.store_id = O.store_id 
				AND S.store_name = 'Burkes Outlet' 
				and P.product_id = I.product_id)
;

-- Yukarıdaki sorguyu EXCEPT ile de yapabilirdik:
		SELECt	distinct I.product_id
		FROM	sale.order_item I,
				sale.orders O,
				sale.store S
		WHERE	I.order_id = O.order_id AND S.store_id = O.store_id 
				AND S.store_name = 'Burkes Outlet' 
except
		SELECt	distinct I.product_id
		FROM	sale.order_item I,
				sale.orders O,
				sale.store S
		WHERE	I.order_id = O.order_id AND S.store_id = O.store_id 
				AND S.store_name = 'The BFLO Store' 
;



-- Common Table Expressions (CTE) --
-- Jerald Berray isimli müşterinin son siparişinden önce sipariş vermiş 
--ve Austin şehrinde ikamet eden müşterileri listeleyin.
-- Sorguyu çalıştırırken with clause başlangıcından sorgunun bittiği yere kadar seçip çalıştırmalısınız

with tbl AS (
	select	max(b.order_date) JeraldLastOrderDate
	from	sale.customer a, sale.orders b
	where	a.first_name = 'Jerald' and a.last_name = 'Berray'
			and a.customer_id = b.customer_id
)

select	distinct a.first_name, a.last_name
from	sale.customer a,
		Sale.orders b,
		tbl c
where	a.city = 'Austin' and a.customer_id = b.customer_id and
		b.order_date < c.JeraldLastOrderDate
;


-- Herbir markanın satıldığı en son tarihi bir CTE sorgusunda,
-- Yine herbir markaya ait kaç farklı ürün bulunduğunu da ayrı bir CTE sorgusunda tanımlayınız.
-- Bu sorguları kullanarak  Logitech ve Sony markalarına ait son satış tarihini ve
-- toplam ürün sayısını (product tablosundaki) aynı sql sorgusunda döndürünüz.
with tbl as(
	select	br.brand_id, br.brand_name, max(so.order_date) LastOrderDate
	from	sale.orders so, sale.order_item soi, product.product pr, product.brand br
	where	so.order_id=soi.order_id and
			soi.product_id = pr.product_id and
			pr.brand_id = br.brand_id
	group by br.brand_id, br.brand_name
), 
tbl2 as(
	select	pb.brand_id, pb.brand_name, count(*) count_product
	from	product.brand pb, product.product pp
	where	pb.brand_id=pp.brand_id
	group by pb.brand_id, pb.brand_name

)
select	* 
from	tbl a, tbl2 b
where	a.brand_id=b.brand_id and
		a.brand_name in ('Logitech', 'Sony')
;



-- Recursive CTE
-- 0'dan 9'a kadar herbir rakam bir satırda olacak şekide bir tablo oluşturun.
-- Parantez içindeki sorguda ilk satırı manuel olarak tanımlıyoruz.
-- Döngü ise union all dan sonraki WHERE şartı sağlandığı müddetçe devam ediyor
-- Ne zamanki where şartı sağlanmadı o noktada döngü bitiyor
with cte AS (
	select 0 rakam
	union all
	select rakam + 1
	from cte
	where rakam < 9
)

select * from cte;

-- 2020 ocak ayının herbir tarihi bir satır olacak şekilde 31 satırlı bir tablo oluşturunuz.
with ocak as (
	select	cast('2020-01-01' as date) tarih
	union all
	select	cast(DATEADD(DAY, 1, tarih) as date) tarih
	from ocak
	where tarih < '2020-01-31'
)

select * from ocak;


with cte AS (
	select cast('2020-01-01' as date) AS gun
	union all
	select DATEADD(DAY,1,gun)
	from cte
	where gun < EOMONTH('2020-01-01')
)
select gun tarih, day(gun) gun, month(gun) ay, year(gun) yil,
	EOMONTH(gun) ayinsongunu
from cte;



-- 
--Write a query that returns all staff with their manager_ids. (use recursive CTE)
-- Bu sorgu sonucunu direkt olarak tablodan da çekebilirdik.
-- Burada dikkat edilmesi gereken nokta hiyrerarşik olarak en üst düzeydeki kişiden başlayıp en alta doğru gittiğimizdir.
with cte as (
	select	staff_id, first_name, manager_id
	from	sale.staff
	where	staff_id = 1
	union all
	select	a.staff_id, a.first_name, a.manager_id
	from	sale.staff a, cte b
	where	a.manager_id = b.staff_id
)

select *
from	cte
;


--2018 yılında tüm mağazaların ortalama cirosunun altında ciroya sahip mağazaları listeleyin.
--List the stores their earnings are under the average income in 2018.

WITH T1 AS (
SELECT	c.store_name, SUM(list_price*quantity*(1-discount)) Store_earn
FROM	sale.orders A, SALE.order_item B, sale.store C
WHERE	A.order_id = b.order_id
AND		A.store_id = C.store_id
AND		YEAR(A.order_date) = 2018
GROUP BY C.store_name
),

T2 AS (
SELECT	AVG(Store_earn) Avg_earn
FROM	T1
)

SELECT *
FROM T1, T2
WHERE T2.Avg_earn > T1.Store_earn
;


-- Sunuda bulunan diğer sorgular:

--List the products ordered the last 10 orders in Buffalo city.
-- Buffalo şehrinden sipariş verilen son 10 siparişteki ürünlerin isimlerini listeleyin.
-- Şehir olarak müşteri adresi baz alınacaktır.
SELECT	distinct b.product_name
FROM	sale.order_item A, product.product B
WHERE	A.product_id = B.product_id
AND		a.order_id IN (SELECT	TOP 10 B.order_id 
						FROM	sale.customer A, sale.orders B
						WHERE	city = 'Buffalo'
						AND		A.customer_id = B.customer_id
						ORDER BY B.order_id DESC
						)
;

-- List all customers their orders are on the same dates with Laurel Goldammer.
-- Laurel Goldammer isimli müşterinin alışveriş yaptığı tarihte/tarihlerde alışveriş yapan tüm müşterileri listeleyin.
-- Müşteri adı, soyadı ve sipariş tarihi bilgilerini listeleyin.

WITH T1 AS 
(
SELECT	B.order_date
FROM	sale.customer A, sale.orders B
WHERE	A.first_name = 'Laurel' AND
		A.last_name = 'Goldammer' AND
		A.customer_id = B.customer_id
)
SELECT	A.first_name, A.last_name, B.order_date
FROM	sale.customer A, sale.orders B, T1 C
WHERE	A.customer_id = B.customer_id AND
		B.order_date = C.order_date
ORDER BY B.order_date
;



--İlk siparişini 2019-10-01 tarihinden sonra veren müşterilerin ilk siparişlerinin net tutarını döndürünüz.
--List the customers and their first order's net price. The first orders after 2019-10-01.

WITH T1 AS (
SELECT	A.customer_id, A.first_name , A.last_name, MIN(order_date) first_order_date
FROM	sale.customer A, sale.orders B
WHERE	A.customer_id = B.customer_id
GROUP BY A.customer_id, A.first_name, A.last_name
HAVING	MIN(order_date) > '2019-10-01'
)
SELECT	T1.customer_id, T1.first_name, T1.last_name, A.order_id, SUM(B.list_price*B.quantity* (1-B.discount)) net_price
FROM	sale.orders A, sale.order_item B, T1
WHERE	A.order_id = B.order_id
AND		A.order_date = T1.first_order_date
AND		A.customer_id = T1.customer_id
GROUP BY T1.customer_id, T1.first_name, T1.last_name, A.order_id
ORDER BY customer_id