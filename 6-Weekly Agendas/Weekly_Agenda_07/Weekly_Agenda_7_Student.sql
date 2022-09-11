---- RDB&SQL Exercise-2 Student

----1. By using view get the average sales by staffs and years using the AVG() aggregate function.

CREATE VIEW sale_staff AS
SELECT  
	ss.staff_id,
	ss.first_name,
	ss.last_name, 
	so.order_date,
	soi.quantity, 
	soi.list_price, 
	soi.discount
FROM 
	product.product pp, 
	sale.order_item soi, 
	sale.orders so, 
	sale.staff ss
WHERE 
	pp.product_id = soi.product_id 
	AND
	soi.order_id = so.order_id 
	AND
	so.staff_id = ss.staff_id


SELECT *
FROM sale_staff


SELECT 
	staff_id, first_name,
	last_name,
	YEAR(order_date) sale_year,
	AVG((list_price * (1 - discount)) * quantity) AS total_sale_price
FROM 
	sale_staff
GROUP BY 
	staff_id,
	YEAR(order_date), 
	first_name, 
	last_name
ORDER BY
	staff_id ASC,
	sale_year ASC



----2. Select the annual amount of product produced according to brands (use window functions).


----3. Select the least 3 products in stock according to stores.

SELECT ss.store_id, ss.store_name, pp.product_name, ps.quantity
FROM sale.store ss, product.stock ps, product.product pp
WHERE ss.store_id = ps.store_id AND ps.product_id = pp.product_id 
ORDER BY ps.quantity ASC


----4. Return the average number of sales orders in 2020 sales


----5. Assign a rank to each product by list price in each brand and get products with rank less than or equal to three.
