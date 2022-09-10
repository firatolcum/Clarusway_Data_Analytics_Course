


--------- Session 10 (Window Functions-2) - 16-06-2022 --------------


--cnt of product by each category and brand

SELECT	brand_id, category_id, COUNT (product_id) CNT_PROD
FROM	product.product
GROUP BY brand_id, category_id


SELECT	DISTINCT brand_id, category_id,
		COUNT (product_id) OVER (PARTITION BY brand_id, category_id) CNT_PROD
FROM	product.product

---Analytic Navigation Functions


--First_Value

--Write a query that returns most stocked product in each store.


--STORE	PRODUCT


SELECT	DISTINCT store_id, 
		FIRST_VALUE(product_id) OVER (PARTITION BY store_id ORDER BY quantity DESC) most_stocked_prod
		--,FIRST_VALUE(product_id) OVER (ORDER BY quantity DESC) MSP_WT
FROM	product.stock



SELECT * FROM product.stock ORDER BY 3 DESC



----//////////////////


-- Write a query that returns customers and their most valuable order with total amount of it.


SELECT	B.customer_id, A.*, quantity * list_price* (1-discount) net_price
FROM	sale.order_item A, sale.orders B
WHERE	A.order_id = B.order_id
ORDER BY 1,2





SELECT	customer_id, B.order_id, SUM(quantity * list_price* (1-discount)) net_price
FROM	sale.order_item A, sale.orders B
WHERE	A.order_id = B.order_id
GROUP BY customer_id, B.order_id
ORDER BY 1,3 DESC;




WITH T1 AS
(
SELECT	customer_id, B.order_id, SUM(quantity * list_price* (1-discount)) net_price
FROM	sale.order_item A, sale.orders B
WHERE	A.order_id = B.order_id
GROUP BY customer_id, B.order_id
)
SELECT	DISTINCT customer_id, 
		FIRST_VALUE(order_id) OVER (PARTITION BY customer_id ORDER BY net_price DESC) MV_ORDER,
		FIRST_VALUE(net_price) OVER (PARTITION BY customer_id ORDER BY net_price DESC) MVORDER_NET_PRICE
FROM	T1



---Write a query that returns first order date by month.


SELECT	DISTINCT YEAR(order_date) ord_year, 
		MONTH(order_date) ord_month,
		FIRST_VALUE(order_date) OVER (PARTITION BY YEAR(order_date), MONTH(order_date) ORDER BY order_date) first_ord_date
FROM	sale.orders



----LAST_VALUE

--Write a query that returns most stocked product in each store.


--STORE	PRODUCT


SELECT *
FROM	product.stock
ORDER BY 1,3 ASC


SELECT	DISTINCT store_id, 
		LAST_VALUE(product_id) OVER (PARTITION BY store_id ORDER BY quantity ASC, product_id DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) most_stocked_prod
FROM	product.stock


-------

SELECT	DISTINCT store_id, 
		LAST_VALUE(product_id) OVER (PARTITION BY store_id ORDER BY quantity ASC, product_id DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) most_stocked_prod
FROM	product.stock




--Write a query that returns the order date of the one previous sale of each staff (use the LAG function)


SELECT	A.staff_id, B.first_name, B.last_name, A.order_id, A.order_date,
		LAG(order_date) OVER (PARTITION BY A.staff_id ORDER BY A.order_id) prev_order
FROM	sale.orders A, sale.staff B
WHERE	A.staff_id = B.staff_id




--Write a query that returns the order date of the one next sale of each staff (use the LEAD function)


SELECT	DISTINCT A.order_id, B.staff_id, B.first_name, B.last_name, order_date, 
		LEAD(order_date, 1) OVER(PARTITION BY B.staff_id ORDER BY order_id) next_order_date
FROM	sale.orders A, sale.staff B
WHERE	A.staff_id = B.staff_id
;



select ss.staff_id, ss.first_name,ss.last_name,so.order_id,so.order_date,
	   LAG(order_date) OVER(ORDER BY so.order_id) previous_order_date
from sale.orders so, sale.staff ss
where so.staff_id = ss.staff_id
order by staff_id





select distinct A.staff_id,first_name,last_name, avg(A.order_diff) over(partition by A.staff_id) avg_order_diff
from
(
select distinct order_id, ss.staff_id,first_name,last_name,order_date,
		lag(order_date) over(partition by ss.staff_id order by order_id) prev_order
		, datediff(d,lag(order_date,1,order_date) over(partition by ss.staff_id order by order_id),order_date) order_diff
from [sale].[orders] so,[sale].[staff] ss
where so.[staff_id] = ss.[staff_id]
) A


