

--------------------------------------
-- DS 11/22 EU -- RDB&SQL Session 6 --
----------- 09.06.2022 ---------------
--------------------------------------

-- Charlotte şehrindeki müşteriler ile Aurora şehrindeki müşterilerin soyisimlerini listeleyin
select	last_name
from	sale.customer
where	city = 'Charlotte'
union
select	last_name
from	sale.customer
where	city = 'Aurora'
;

-- Set operatörlerinde değişkenlerin sırası ve sayısı önemlidir

-- Çalışanların ve müşterilerin eposta adreslerinin unique olacak şekilde listeleyiniz.
select	email
from	sale.staff
union
select	email
from	sale.customer
;

-- Adı Thomas olan ya da soyadı Thomas olan müşterilerin isim soyisimlerini listeleyiniz.
-- where bloğu içinde koşul belirterek yazabilirsiniz.
select	first_name, last_name
from	sale.customer
where	first_name = 'Thomas' or last_name = 'Thomas'
;

-- Ya da iki farklı sorgu yapıp UNION ALL ile sonuçları birleştirebilirsiniz.
SELECT first_name, last_name
FROM sale.customer
WHERE first_name = 'Thomas'
UNION ALL
SELECT first_name, last_name
from sale.customer
WHERE last_name = 'Thomas'
;

-- Write a query that returns brands that have products for both 2018 and 2019.
select	A.brand_id, B.brand_name
from	product.product A, product.brand B
where	a.brand_id = b.brand_id and
		a.model_year = 2018
INTERSECT
select	A.brand_id, B.brand_name
from	product.product A, product.brand B
where	a.brand_id = b.brand_id and
		a.model_year = 2019

-- Write a query that returns customers who have orders for both 2018, 2019, and 2020
select	A.first_name, A.last_name, B.customer_id
from	sale.customer A , sale.orders B
where	A.customer_id = B.customer_id and
		YEAR(B.order_date) = 2018
INTERSECT
select	A.first_name, A.last_name, B.customer_id
from	sale.customer A, sale.orders B
where	A.customer_id = B.customer_id and
		YEAR(B.order_date) = 2019
INTERSECT
select	A.first_name, A.last_name, B.customer_id
from	sale.customer A , sale.orders B
where	A.customer_id = B.customer_id and
		YEAR(B.order_date) = 2020
;


-- Charlotte şehrindeki müşterilerden Aurora şehrindeki müşterilerle ortak soyisme sahip olan kişilerin soy isimlerini listeleyin
select	last_name
from	sale.customer
where	city = 'Charlotte'
intersect
select	last_name
from	sale.customer
where	city = 'Aurora'
;

-- Müşterilerden ve çalışanlardan aynı email adresini kullanan var mı? Varsa bu mail adreslerini listeyin.
select	email
from	sale.staff
intersect
select	email
from	sale.customer
;


-- Write a query that returns brands that have a 2018 model product but not a 2019 model product.
SELECT A.brand_id, B.brand_name
FROM product.product A, product.brand B
WHERE A.brand_id = B.brand_id
    AND A.model_year = 2018
EXCEPT
SELECT A.brand_id, B.brand_name
FROM product.product A, product.brand B
WHERE A.brand_id = B.brand_id
    AND A.model_year = 2019
;


--Sadece 2019 yılında sipariş verilen diğer yıllarda sipariş verilmeyen ürünleri getiriniz.
-- Bu sorguyu 2 farklı şekilde yapalım.
-- ilk olarak tüm sorgularda ürün bilgilerini getirip son olarak INTERSECT kullanalım.
-- İkinci olarak ürün id leri üzerinden intersect yapalım ve son olarak ürün tablosuna join yapıp ürün bilgilerini getirelim.
-- Büyük verilerin bulunduğu Databaselerde ikinci yöntem daha performanslı olacaktır. Çünkü product tablosuna toplamda 1 kez join yapmış oluyoruz.
-- ilk yöntem
select	B.product_id, C.product_name
from	sale.orders A, sale.order_item B, product.product C
where	Year(A.order_date) = 2019 AND
		A.order_id = B.order_id AND
		B.product_id = C.product_id
except
select	B.product_id, C.product_name
from	sale.orders A, sale.order_item B, product.product C
where	Year(A.order_date) <> 2019 AND
		A.order_id = B.order_id AND
		B.product_id = C.product_id
;

-- ikinci yöntem
select	C.product_id, D.product_name
from	
	(
	select	B.product_id
	from	sale.orders A, sale.order_item B
	where	Year(A.order_date) = 2019 AND
			A.order_id = B.order_id
	except
	select	B.product_id
	from	sale.orders A, sale.order_item B
	where	Year(A.order_date) <> 2019 AND
			A.order_id = B.order_id
	) C, product.product D
where	C.product_id = D.product_id
;

-- Yukarıdaki sorguda bizden isteneni tam anlayabilmek için ürünlerin hangi yıllarda kaçar defa sipariş edildiğine dair bir PIVOT tablo oluşturalım.
-- Pivot tabloyu aşağıdaki gibi oluşturabilirsiniz.
-- Pivot tabloda aggregate functionda parantez içinde kesinlikle bir sütun yer almak zorundadır.
-- Count(*) ya da sum(1) gibi ifadeler hata vermektedir.
-- Aşağıdaki sorguda count(item_id) yerine count(*) yazarak bunu test edebilirsiniz.
SELECT *
FROM
			(
			SELECT	b.product_id, year(a.order_date) OrderYear, B.item_id
			FROM	SALE.orders A, sale.order_item B
			where	A.order_id = B.order_id
			) A
PIVOT
(
	count(item_id)
	FOR OrderYear IN
	(
	[2018], [2019], [2020], [2021]
	)
) AS PIVOT_TABLE
order by 1


-- Hem 2018 hem de 2019 model ürünü bulunan 35 marka vardı.
-- Envanterimizde de toplam 40 marka olduğunu biliyordurk.
-- Hem 2018 hem de 2019 model ürünü bulunmayan bu 5 markayı listeleyiniz.
select	brand_id, brand_name
from	product.brand
except
select	*
from	(
		select	A.brand_id, B.brand_name
		from	product.product A, product.brand B
		where	a.brand_id = b.brand_id and
				a.model_year = 2018
		INTERSECT
		select	A.brand_id, B.brand_name
		from	product.product A, product.brand B
		where	a.brand_id = b.brand_id and
				a.model_year = 2019
		) A


-- CASE
-- simple case
select	order_id, order_status,
		case order_status
			when 1 then 'Pending'
			when 2 then 'Processing'
			when 3 then 'Rejected'
			when 4 then 'Completed'
		end order_status_desc
from	sale.orders
;

--Staff tablosuna çalışanların mağaza isimlerini ekleyin.
SELECT first_name, last_name, store_id,
	CASE store_id
		WHEN 1 THEN 'Davi techno Retail'
		WHEN 2 THEN 'The BFLO Store'
		WHEN 3 THEN 'Burkes Outlet'
	END AS store_name
FROM sale.staff
;

-- searched case
--Order_Status isimli alandaki değerlerin ne anlama geldiğini içeren yeni bir alan oluşturun.
select	order_id, order_status,
		case 
			when order_status = 1 then 'Pending'
			when order_status = 2 then 'Processing'
			when order_status = 3 then 'Rejected'
			when order_status = 4 then 'Completed'
			else 'other'
		end order_status_desc
from	sale.orders
;

--Müşterilerin e-mail adreslerindeki servis sağlayıcılarını yeni bir sütun oluşturarak belirtiniz.
SELECT first_name, last_name, email,
	CASE
		WHEN email LIKE '%gmail%' THEN 'Gmail'
		WHEN email LIKE '%hotmail%' THEN 'Hotmail'
		WHEN email LIKE '%yahoo%' THEN 'Yahoo'
		ELSE 'Other'
	END AS email_service_provider
FROM sale.customer
;


-- Aynı siparişte hem mp4 player, hem Computer Accessories hem de Speakers kategorilerinde ürün sipariş veren müşterileri bulunuz.
-- Bu sorguyu birkaç farklı yolla yapabiliriz.
-- 1. yöntem: Derste yaptığımız için group by ile yapabiliriz.
-- 2. yöntem: Case ile yeni bir alan oluşturup daha sonra group by ile yapabiliriz.

-- 1. yöntem:
select	C.first_name, C.last_name
from	(
		select	c.order_id, count(distinct a.category_id) uniqueCategory
		from	product.category A, product.product B, sale.order_item C
		where	A.category_name in ('Computer Accessories', 'Speakers', 'mp4 player') AND
				A.category_id = B.category_id AND
				B.product_id = C.product_id
		group by C.order_id
		having	count(distinct a.category_id) = 3
		) A, sale.orders B, sale.customer C
where	A.order_id = B.order_id AND
		B.customer_id = C.customer_id
;

-- 2. yöntem:
SELECT	first_name, last_name
FROM
	(
	SELECT	A.customer_id, A.first_name, A.last_name, C.order_id, 
			SUM(CASE WHEN E.category_name = 'Computer Accessories' THEN 1 ELSE 0 END) AS  C1,
			SUM(CASE WHEN E.category_name = 'Speakers' THEN 1 ELSE 0 END) AS C2,
			SUM(CASE WHEN E.category_name = 'mp4 player' THEN 1 ELSE 0 END) AS C3
	FROM	SALE.customer A, SALE.orders B, SALE.order_item C, product.product D, product.category E
	WHERE	A.customer_id = B.customer_id
			AND B.order_id = C.order_id
			AND C.product_id =D.product_id
			AND D.category_id = E.category_id
	GROUP BY A.customer_id, A.first_name, A.last_name, C.order_id
	) A
WHERE C1 > 0 AND C2 > 0 AND C3 > 0
;


-- Aşağıdaki sorguların cevapları akabinde yer almaktadır.
-- İlk olarak kendiniz soruyu cevaplamaya çalışın. Daha sonra cevap ile kontrol ediniz.
/*
Question 1 : Create a new column that contains labels of the shipping speed of products.

If the product has not been shipped yet, it will be marked as "Not Shipped",
If the product was shipped on the day of order, it will be labeled as "Fast".
If the product is shipped no later than two days after the order day, it will be labeled as "Normal"
If the product was shipped three or more days after the day of order, it will be labeled as "Slow"
*/

SELECT	*,
		CASE WHEN shipped_date IS NULL THEN 'Not Shipped'
			 WHEN order_date = shipped_date THEN 'Fast' -- DATEDIFF (DAY, ORDER_DATE, SHIPPED_DATE) = 0
			 WHEN DATEDIFF (DAY, order_date, shipped_date) BETWEEN 1 AND 2 THEN 'Normal'
			 ELSE 'Slow'
		END AS ORDER_LABEL,
		DATEDIFF (DAY, ORDER_DATE, shipped_date) datedif
FROM	sale.orders
order by datedif
;

/*
Question 1 : Write a query that returns the number distributions of the orders in the previous query result, according to the days of the week.
--Yukarıdaki siparişlerin haftanın günlerine göre dağılımını hesaplayınız.
*/

SELECT	SUM(CASE WHEN DATENAME (DW, order_date) = 'Monday' THEN 1 ELSE 0 END) AS Monday,
		SUM(CASE WHEN DATENAME (DW, order_date) = 'Tuesday' THEN 1 ELSE 0 END) AS Tuesday,
		SUM(CASE WHEN DATENAME (DW, order_date) = 'Wednesday' THEN 1 ELSE 0 END) AS Wednesday,
		SUM(CASE WHEN DATENAME (DW, order_date) = 'Thursday' THEN 1 ELSE 0 END) AS Thursday,
		SUM(CASE WHEN DATENAME (DW, order_date) = 'Friday' THEN 1 ELSE 0 END) AS Friday,
		SUM(CASE WHEN DATENAME (DW, order_date) = 'Saturday' THEN 1 ELSE 0 END) AS Saturday,
		SUM(CASE WHEN DATENAME (DW, order_date) = 'Sunday' THEN 1 ELSE 0 END) AS Sunday
FROM	sale.orders
WHERE	DATEDIFF(DAY, order_date, shipped_date) > 2
;

-- Bu soruyu PIVOT fonksiyonu ile yapabilir misiniz? Tabi ki EVET :)




