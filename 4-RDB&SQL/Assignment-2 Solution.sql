


/*

'2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD' 

�simli �r�n� sat�n alan m��terilerin a�a��daki �� �r�n� sat�n al�p almad�klar�n� g�steren bir rapor haz�rlay�n�z.

'Polk Audio - 50 W Woofer - Black' 
'SB-2000 12 500W Subwoofer (Piano Gloss Black)' 
'Virtually Invisible 891 In-Wall Speakers (Pair)'

*/


SELECT	DISTINCT A.customer_id, A.first_name, A.last_name, D.product_id, D.product_name
FROM	sale.customer A, sale.orders B, sale.order_item C, product.product D
WHERE	A.customer_id = B.customer_id
AND		B.order_id = C.order_id
AND		C.product_id = D.product_id
AND		D.product_name = '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD' 


---

customer_id, isim, soyisim, 1. �r�n bilgisi, 2. �r�n bilgisi, 3. �r�n bilgisi




--'Polk Audio - 50 W Woofer - Black' isimli �r�n� sat�n alan m��teriler


SELECT	DISTINCT A.customer_id, A.first_name, A.last_name, D.product_id, D.product_name
FROM	sale.customer A, sale.orders B, sale.order_item C, product.product D
WHERE	A.customer_id = B.customer_id
AND		B.order_id = C.order_id
AND		C.product_id = D.product_id
AND		D.product_name = 'Polk Audio - 50 W Woofer - Black'


---

CREATE VIEW CUSTOMER_PRODUCT1 AS 
SELECT	DISTINCT A.customer_id, A.first_name, A.last_name, D.product_id, D.product_name
FROM	sale.customer A, sale.orders B, sale.order_item C, product.product D
WHERE	A.customer_id = B.customer_id
AND		B.order_id = C.order_id
AND		C.product_id = D.product_id




'SB-2000 12 500W Subwoofer (Piano Gloss Black)' 
'Virtually Invisible 891 In-Wall Speakers (Pair)'

--customer_id, isim, soyisim, 1. �r�n bilgisi, 2. �r�n bilgisi, 3. �r�n bilgisi

---nullif , isnull

SELECT A.customer_id, A.first_name, A.last_name,
		ISNULL (NULLIF (ISNULL(B.product_name, 'NO') , B.product_name), 'YES') First_product,
		ISNULL (NULLIF (ISNULL(C.product_name, 'NO') , C.product_name), 'YES') Second_product,
		ISNULL (NULLIF (ISNULL(D.product_name, 'NO') , D.product_name), 'YES') Third_product
FROM
	(
	SELECT *
	FROM CUSTOMER_PRODUCT1
	WHERE product_name = '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD'
	) A LEFT JOIN
	(
	SELECT *
	FROM CUSTOMER_PRODUCT1
	WHERE product_name =  'Polk Audio - 50 W Woofer - Black'
	) B
ON A.customer_id = B.customer_id
	LEFT JOIN
	(
	SELECT *
	FROM CUSTOMER_PRODUCT1
	WHERE product_name =  'SB-2000 12 500W Subwoofer (Piano Gloss Black)' 
	) C
ON A.customer_id = C.customer_id
	LEFT JOIN
	(
	SELECT *
	FROM CUSTOMER_PRODUCT1
	WHERE product_name =  'Virtually Invisible 891 In-Wall Speakers (Pair)'
	) D
ON A.customer_id = D.customer_id








