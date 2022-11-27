


--------------------------------------
-- DS 11/22 EU -- RDB&SQL Session 4 --
----------- 06.06.2022 ---------------
--------------------------------------


-- JOINS -- https://docs.microsoft.com/en-us/sql/relational-databases/performance/joins

------ INNER JOIN ------

-- Ürünleri kategori isimleri ile birlikte listeleyin
-- Ürün IDsi, ürün adı, kategori IDsi ve kategori adlarını seçin

SELECT	A.product_id, A.product_name, A.category_id, B.category_name
FROM	product.product A
INNER JOIN	product.category B
	ON	A.category_id = B.category_id
;

-- or
SELECT	A.product_id, A.product_name, A.category_id, B.category_name
FROM	product.product A,
		product. category B
WHERE	A.category_id = B.category_id
;


--///////

-- Mağaza çalışanlarını çalıştıkları mağaza bilgileriyle birlikte listeleyin
-- Çalışan adı, soyadı, mağaza adlarını seçin

SELECT	A.first_name, A.last_name, B.store_name
FROM	sale.staff A
INNER JOIN sale.store B
	ON	A.store_id = B.store_id
;




------ LEFT JOIN ------

-- Hiç sipariş verilmemiş ürünleri listeleyin

SELECT	A.product_id, A.product_name, B.order_id
FROM	product.product A
LEFT JOIN	sale.order_item B ON A.product_id = B.product_id
WHERE	order_id IS NULL
;


-- Ürün bilgilerini stok miktarları ile birlikte listeleyin
---beklenen: product tablosunda olup stok bilgisi olmayan ürünleri de görmek.

SELECT	A.product_id, A.product_name, B.*
FROM	product.product A
LEFT JOIN product.stock B ON A.product_id = B.product_id
WHERE	A.product_id > 310
;



------ RIGHT JOIN ------

-- Stok miktarları ile ilgili LEFT JOIN ile yaptığınız sorguyu RIGHT JOIN ile yapın
--bu sefer stock tablosu solda olmalı. çünkü sağdaki tablo temel alınıyor.

SELECT	B.product_id, B.product_name, A.*
FROM	product.stock A
RIGHT JOIN product.product B ON	A.product_id = B.product_id
WHERE	B.product_id > 310
;


------ FULL OUTER JOIN ------

-- Ürünlerin stok miktarları ve sipariş bilgilerini birlikte listeleyin
--HER İKİ TABLODAKİ PRODUCT ID LERİ GETİRMEK ÖNEMLİ. 

SELECT TOP 20 A.Product_id, A.store_id, A.quantity, B.product_id, B.order_id, B.list_price
FROM	product.stock A
FULL OUTER JOIN	sale.order_item B ON A.product_id = B.product_id
ORDER BY A.product_id, B.order_id
;


SELECT TOP 100 A.Product_id, B.store_id, B.quantity, C.order_id, C.list_price
FROM	
product.product A
FULL OUTER JOIN 
product.stock B  ON A.product_id = B.product_id
FULL OUTER JOIN	sale.order_item C ON A.product_id = C.product_id
ORDER BY B.store_id 
;


------ CROSS JOIN ------

--stock tablosunda olmayıp product tablosunda mevcut olan ürünlerin stock tablosuna tüm storelar için kayıt edilmesi gerekiyor. 
--stoğu olmadığı için quantity leri 0 olmak zorunda
--Ve bir product id tüm store' ların stockuna eklenmesi gerektiği için cross join yapmamız gerekiyor.

SELECT	B.store_id, A.product_id, 0 quantity
FROM	product.product A
CROSS JOIN sale.store B
WHERE	A.product_id NOT IN (SELECT product_id FROM product.stock)
ORDER BY A.product_id, B.store_id



------ SELF JOIN ------

-- Personelleri ve şeflerini listeleyin
-- Çalışan adı ve yönetici adı bilgilerini getirin

SELECT	A.first_name staff_name, B.first_name manager_name
FROM	sale.staff A
JOIN	sale.staff B ON	A.manager_id = B.staff_id
ORDER BY B.first_name
;

-- or
SELECT	A.first_name, B.first_name manager_name
FROM	sale.staff A, sale.staff B
WHERE	A.manager_id = B.staff_id
ORDER BY B.first_name
;


-- VIEWS -- https://docs.microsoft.com/en-us/sql/relational-databases/views/views



