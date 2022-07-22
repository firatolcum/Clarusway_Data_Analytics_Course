

USE SampleRetail

--1. Report cumulative total turnover by months in each year in pivot table format.

--Solution 1:
WITH temp_table AS
(
SELECT 
	order_date, MONTH(order_date) order_month ,
	(quantity * list_price ) total_price
FROM
	sale.order_item soi, 
	sale.orders so
WHERE 
	soi.order_id = so.order_id
)
SELECT
	DISTINCT YEAR(order_date) [Year], order_month,
	SUM(total_price) OVER(PARTITION BY YEAR(order_date), order_month ) monthly_total
INTO #table1
FROM
	temp_table


SELECT 
	[Year], order_month,
	SUM(monthly_total) OVER(PARTITION BY [Year] ORDER BY order_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) cumulative_sum
INTO
	#table2
FROM 
	#table1


SELECT *
FROM #table2
PIVOT
(
SUM(cumulative_sum) FOR [Year] IN ([2018], [2019], [2020])
) piv
ORDER BY order_month

--Solution 2:
SELECT * 
FROM
	(
	SELECT	DISTINCT YEAR (A.order_date) ord_year, MONTH(A.order_date) ord_month, 
	SUM(quantity*list_price) OVER (PARTITION BY YEAR (A.order_date) ORDER BY YEAR (A.order_date), MONTH(A.order_date)) turnover
	FROM	sale.orders A, sale.order_item B
	WHERE	A.order_id = B.order_id
	) A
PIVOT
	(
	MAX(turnover)
	FOR ord_year
	IN ([2018], [2019],[2020])
	)
PIVOT_TA


-------------------------------------------------------------------------------------------

--2. What percentage of customers purchasing a product have purchased the same product again?

--Solution 1
SELECT  so.order_id, product_id, customer_id
INTO #table4
FROM sale.order_item soi, sale.orders so
WHERE soi.order_id = so.order_id
ORDER BY customer_id, product_id

SELECT 
	DISTINCT product_id,
	COUNT(*) OVER(PARTITION BY product_id ) TotalCountOfProduct,
	COUNT(customer_id) OVER(PARTITION BY product_id, customer_id ) Buy_Repeat
INTO #table5
FROM #table4

SELECT 
	DISTINCT product_id,
	CASE WHEN Buy_Repeat = 2 THEN CAST((1.0 * 2 / TotalCountOfProduct) AS DECIMAL(10, 2))  ELSE 0  END AS rate
INTO #table6
FROM #table5

SELECT product_id, SUM(rate) rate
FROM #table6
GROUP BY product_id

--Solution 2
SELECT	
	soi.product_id,
	CAST(1.0*(COUNT(so.customer_id) - COUNT(DISTINCT so.customer_id))/COUNT(so.customer_id) AS DECIMAL(3,2)) per_of_cust_pur
FROM
	sale.order_item soi, sale.orders so
WHERE	
	soi.order_id = so.order_id		
GROUP BY
	soi.product_id
--------------------------------------------------------------------------------------------------
--From the following table of user IDs, actions, and dates, write a query to return the publication and cancellation rate for each user.

CREATE TABLE week8
(
[User_id] INT,
[Action] VARCHAR(20),
[Date] DATE
)


INSERT INTO week8
VALUES
(1,'Start','1-1-22'),
(1,'Cancel','1-2-22'),
(2,'Start','1-3-22'),
(2,'Publish','1-4-22'),
(3,'Start','1-5-22'),
(3,'Cancel','1-6-22'),
(1,'Start','1-7-22'),
(1,'Publish','1-8-22')

--Solution 1
SELECT *
FROM week8

SELECT *
INTO #table3
FROM
	(SELECT User_id, [Action]
	 FROM week8) T
PIVOT
(COUNT(Action) FOR [action] IN (Cancel, Publish, Start)) AS piv


SELECT  
	[User_id], 
	CAST((1.0 * Publish / [Start]) AS DECIMAL(10,1)) Publish_rate,
	CAST((1.0 * Cancel / [Start]) AS DECIMAL(10,1)) Cancel_rate
FROM 
	#table3

--Solution 2
SELECT [user_id],
 CAST(1.0*SUM (CASE WHEN [action] = 'Publish' THEN 1 ELSE 0 END)
 /SUM(CASE WHEN [action]= 'Start' THEN 1 ELSE 0 END) AS NUMERIC (2,1)) AS  Publish_rate,

 CAST(1.0*SUM (CASE when [action]= 'Cancel'  then 1 else 0 end) /
 SUM(CASE WHEN [action]= 'Start' THEN 1 ELSE 0 END) AS NUMERIC (2,1)) AS Cancel_rate
 FROM week8
 GROUP BY [user_id]