
---- RDB&SQL Exercise-2 Student
-- ////////////////////////////////////////////////////////////////// --

----1. By using view get the average sales by staffs and years using the AVG() aggregate function.


-- sales by price
CREATE VIEW vWStaffData1
AS
SELECT B.staff_id, (first_name + ' ' + last_name) AS [Name], store_name, 
	   YEAR(order_date) AS [Year], 
	   CONVERT(DECIMAL(18,2), AVG((C.quantity*C.list_price)*(1-C.discount))) AS AvgSalesAmount
FROM sale.orders AS A 
	   INNER JOIN sale.staff AS B ON A.staff_id=B.staff_id 
	   INNER JOIN sale.order_item AS C ON A.order_id=C.order_id
	   INNER JOIN sale.store AS S ON  B.store_id=S.store_id
GROUP BY B.staff_id, (first_name + ' ' + last_name), store_name, YEAR(order_date) 
--ORDER BY 1,5; (The ORDER BY clause is invalid in views)


-- sales by quantity  
CREATE VIEW vWStaffData2
AS
SELECT O.staff_id, (first_name + ' ' + last_name) AS [Name], store_name, 
	   YEAR(order_date) AS [Year],
	   COUNT(O.staff_id) AS TotalOrders 
FROM sale.orders AS O
	   LEFT JOIN sale.staff AS S1 ON S1.staff_id=O.staff_id
	   LEFT JOIN sale.store AS S2 ON S2.store_id=O.store_id
GROUP BY O.staff_id, (first_name + ' ' + last_name), store_name, YEAR(order_date);


-- ////////////////////////////////////////////////////////////////// --

----2. Select the annual amount of product produced according to brands (use window functions).

-- solution-1 (with window function)
SELECT DISTINCT(brand_name), model_year, SUM(quantity) OVER(PARTITION BY brand_name, model_year)
FROM(SELECT brand_name, model_year, quantity
     FROM product.brand AS B 
			INNER JOIN product.product AS P ON B.brand_id=P.brand_id 
			INNER JOIN product.stock AS S ON P.product_id=S.product_id) as SUBQ;


-- solution-2
SELECT brand_name, model_year, SUM(S.quantity) AS TotalAmountPerYear
FROM product.brand AS B 
     INNER JOIN product.product AS P ON B.brand_id=P.brand_id 
     INNER JOIN product.stock AS S ON P.product_id=S.product_id
GROUP BY brand_name, model_year
ORDER BY brand_name, model_year


-- ////////////////////////////////////////////////////////////////// --

----3. Select the least 3 products in stock according to stores.


-- solution-1
SELECT store_id, product_name, TotalQuantity
FROM(SELECT *, ROW_NUMBER() OVER(PARTITION BY store_id ORDER BY store_id, TotalQuantity) AS RowNumber 
     FROM(SELECT store_id, s.product_id, product_name, SUM(quantity) as TotalQuantity 
          FROM product.stock AS s JOIN product.product AS p ON s.product_id=p.product_id
	      GROUP BY store_id, s.product_id, product_name
		  HAVING SUM(quantity) > 0) AS SUBQ1) AS SUBQ2
WHERE RowNumber BETWEEN 1 AND 3;


-- solution-2
WITH CTE1 AS
     (SELECT *
      FROM(SELECT *, ROW_NUMBER() OVER(PARTITION BY store_id ORDER BY store_id, quantity) AS RowNumber
	       FROM product.stock) AS SUBQ1
      WHERE RowNumber BETWEEN 1 AND 3)
SELECT CTE1.store_id, B.store_name, P.product_id, P.product_name, CTE1.quantity
FROM CTE1 INNER JOIN sale.store AS B ON CTE1.store_id=B.store_id
	      INNER JOIN product.product AS P ON CTE1.product_id=P.product_id


-- ////////////////////////////////////////////////////////////////// --

----4. Return the average number of sales orders in 2020 sales


SELECT AVG(NumOfOrders)
FROM(SELECT O1.order_id, COUNT(O1.order_id) AS NumOfOrders
	 FROM sale.order_item AS O1 
		  JOIN sale.orders AS O2 ON O1.order_id=O2.order_id 
		  AND YEAR(order_date)=2020 
		  GROUP BY O1.order_id) AS SUBQ;


-- ////////////////////////////////////////////////////////////////// --

----5. Assign a rank to each product by list price in each brand and get products with rank less than or equal to three.

-- NOTE: RANK and DENSE_RANK will assign the grades the same rank depending on how they fall compared to the other values. 
-- However, RANK will then skip the next available ranking value whereas DENSE_RANK would still use the next chronological ranking value.


-- with dense_rank
SELECT * 
FROM(SELECT *, DENSE_RANK() OVER (PARTITION BY brand_id ORDER BY list_price) AS [rank] 
	 FROM product.product) AS SUBQ1
WHERE [rank] <= 3; 


-- with rank
SELECT * 
FROM(SELECT *, RANK() OVER (PARTITION BY brand_id ORDER BY list_price) AS [rank] 
	 FROM product.product) AS SUBQ1
WHERE [rank] <= 3;