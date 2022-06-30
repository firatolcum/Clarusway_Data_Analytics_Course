
USE [E-CommerceData]
---------------------------------CUST_DIMEN------------------------------------------
SELECT *
FROM cust_dimen

UPDATE cust_dimen
SET Cust_id =  TRIM('Cust_'  FROM Cust_id)

ALTER TABLE cust_dimen
ALTER COLUMN Cust_id INTEGER NOT NULL

---------------------------------------MARKET_FACT-----------------------------
SELECT *
FROM market_fact

UPDATE market_fact
SET Ord_id = TRIM('Ord_' FROM Ord_id), 
	Prod_id = TRIM('Prod_' FROM Prod_id), 
	Ship_id = TRIM('SHP_' FROM Ship_id), 
	Cust_id = TRIM('Cust_' FROM Cust_id) 

ALTER TABLE market_fact
ALTER COLUMN Ord_id INTEGER NOT NULL

ALTER TABLE market_fact
ALTER COLUMN Prod_id INTEGER NOT NULL 

ALTER TABLE market_fact
ALTER COLUMN Ship_id INTEGER NOT NULL

ALTER TABLE market_fact
ALTER COLUMN Cust_id INTEGER NOT NULL

-----------------------------------------------------ORDERS_DIMEN-----------------------------
SELECT *
FROM orders_dimen

UPDATE orders_dimen
SET Ord_id = TRIM('Ord_' FROM Ord_id)

ALTER TABLE orders_dimen
ALTER COLUMN Ord_id INTEGER NOT NULL

-----------------------------------------------------PROD_DIMEN-----------------------------

SELECT *
FROM prod_dimen

UPDATE prod_dimen
SET Prod_id = TRIM('Prod_' FROM Prod_id)

ALTER TABLE prod_dimen
ALTER COLUMN Prod_id INTEGER NOT NULL

-----------------------------------------------------SHIPPING_DIMEN-----------------------------
SELECT *
FROM shipping_dimen

UPDATE shipping_dimen
SET Ship_id = TRIM('SHP_' FROM Ship_id)

ALTER TABLE shipping_dimen
ALTER COLUMN Ship_id INTEGER NOT NULL

------------------------------------------------------------------------------------------------------

----------------------------------CONSTRAINTS-----------------------------
---CUST_DIMEN
SELECT *
FROM cust_dimen

ALTER TABLE cust_dimen
ADD CONSTRAINT PK_custdimen PRIMARY KEY(Cust_id)


--ORDERS_DIMEN
SELECT *
FROM orders_dimen

ALTER TABLE orders_dimen
ADD CONSTRAINT PK_orders_dimen PRIMARY KEY(Ord_id)


---PROD_DIMEN
SELECT *
FROM prod_dimen

ALTER TABLE prod_dimen
ADD CONSTRAINT PK_prod_dimen PRIMARY KEY(Prod_id)


--SHIPPING_DIMEN
SELECT *
FROM shipping_dimen

ALTER TABLE shipping_dimen
ADD CONSTRAINT PK_shipping_dimen PRIMARY KEY(Ship_id)


--MARKET_FACT
ALTER TABLE market_fact
ADD CONSTRAINT FK_Ord_id FOREIGN KEY(Ord_id)
REFERENCES orders_dimen(Ord_id)

ALTER TABLE market_fact
ADD CONSTRAINT FK_Prod_id FOREIGN KEY(Prod_id)
REFERENCES prod_dimen(Prod_id)

ALTER TABLE market_fact
ADD CONSTRAINT FK_Ship_id FOREIGN KEY(Ship_id)
REFERENCES shipping_dimen(Ship_id)


ALTER TABLE market_fact
ADD CONSTRAINT FK_Customer_id FOREIGN KEY(Cust_id)
REFERENCES cust_dimen(Cust_id)


--------------------------------------------------------------------------------------------------------------------------------
--Analyze the data by finding the answers to the questions.
--1. Using the columns of “market_fact”, “cust_dimen”, “orders_dimen”, “prod_dimen”, “shipping_dimen”, Create a new table, named as “combined_table”.

SELECT mf.*,pd.Product_Category, pd.Product_Sub_Category, cd.Customer_Name, cd.Customer_Segment, cd.Province, cd.Region,
	sd.Order_ID, sd.Ship_Mode, sd.Ship_Date, od.Order_Date, od.Order_Priority
INTO combined_table
FROM market_fact mf
LEFT JOIN prod_dimen pd
ON mf.prod_id = pd.prod_id
LEFT JOIN cust_dimen cd
ON mf.cust_id = cd.Cust_id
LEFT JOIN shipping_dimen sd
ON mf.ship_id = sd.ship_id
LEFT JOIN orders_dimen od
ON mf.ord_id =od.ord_id


---2. Find the top 3 customers who have the maximum count of orders.

SELECT TOP(3) 
	Cust_id, Customer_Name,
	COUNT(DISTINCT Ord_id) total_orders
FROM
	combined_table
GROUP BY 
	cust_id, 
	Customer_Name
ORDER BY
	total_orders DESC


--3. Create a new column at combined_table as DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.

ALTER TABLE 
	combined_table
ADD 
	DaysTakenForDelivery INT


UPDATE 
	combined_table
SET 
	DaysTakenForDelivery = DATEDIFF(DAY, Order_Date, Ship_Date)


--4. Find the customer whose order took the maximum time to get delivered.

SELECT TOP(1) 
	cust_id, 
	Customer_name, 
	DaysTakenForDelivery
FROM 
	combined_table
ORDER BY 
	DaysTakenForDelivery DESC


--5. Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011.

SELECT 
	MONTH(Order_Date) Order_month, 
	COUNT(DISTINCT cust_id) MonthlyCustomerCounts
FROM 
	combined_table
WHERE 
	cust_id IN (SELECT DISTINCT cust_id 
				FROM combined_table
				WHERE YEAR(Order_Date) = 2011 AND MONTH(Order_Date) = 1) AND YEAR(Order_Date) = 2011
GROUP BY 
	MONTH(Order_Date)


--6. Write a query to return for each user the time elapsed between the first purchasing and the third purchasing, in ascending order by Customer ID.

SELECT DISTINCT cust_id, Customer_Name, ord_id, order_date
INTO #table1
FROM combined_table	
ORDER BY cust_id, order_date


WITH T AS
(
SELECT 
	*,
	FIRST_VALUE(Order_Date) OVER(PARTITION BY cust_id ORDER BY order_date) first_order,
	ROW_NUMBER() OVER(PARTITION BY cust_id ORDER BY Order_Date) order_number
FROM #table1
)
SELECT *,DATEDIFF(DAY,first_order, order_date ) Dayelapsed
FROM T
WHERE order_number = 3
order by Cust_id
--7. Write a query that returns customers who purchased both product 11 and product 14, as well as the ratio of these products to the total number of products purchased by the customer.

WITH  T AS
(
SELECT
	cust_id,
	SUM(CASE WHEN prod_id = 11 THEN order_quantity ELSE 0 END) TotalQuantity11,
	SUM(CASE WHEN prod_id = 14 THEN order_quantity ELSE 0 END) TotalQuantity14,
	SUM(Order_quantity) TotalQuantityAll 
FROM 
	combined_table
WHERE 
	cust_id IN (SELECT cust_id
				FROM combined_table
				WHERE Prod_id = 11
				INTERSECT
				SELECT cust_id
				FROM combined_table
				WHERE Prod_id = 14)
GROUP BY 
	cust_id
)
SELECT *, 
	CAST((1.0 * TotalQuantity11 / TotalQuantityAll) AS DECIMAL(10,2)) RatioOf11,
	CAST((1.0 * TotalQuantity14 / TotalQuantityAll) AS DECIMAL(10,2)) RatioOf14
FROM T

--------------------------------------------------------------------------------------------------------------------------------
--CUSTOMER SEGMENTATION 
--1. Create a “view” that keeps visit logs of customers on a monthly basis. (For each log, three field is kept: Cust_id, Year, Month)

CREATE VIEW visit_logs AS
SELECT 
	Cust_id, 
	YEAR(Order_Date) [Year], 
	MONTH(Order_Date) [Month]
FROM 
	combined_table


--2. Create a “view” that keeps the number of monthly visits by users. (Show separately all months from the beginning business)

CREATE VIEW monthly_visit_logs AS
SELECT 
	DISTINCT *, 
	COUNT(*) OVER(PARTITION BY Cust_id, [Year], [Month]) MonthlyVisitCount
FROM 
	visit_logs


--3. For each visit of customers, create the next month of the visit as a separate column.

CREATE VIEW Consecutive_visits AS
WITH T1 AS
(
SELECT 
	Cust_id, 
	[Year], 
	[Month], 
	DENSE_RANK() OVER(ORDER BY [Year], [Month]) VisitMonthNum
FROM
	monthly_visit_logs
)
SELECT *, LEAD(VisitMonthNum, 1) OVER(PARTITION BY Cust_id ORDER BY VisitMonthNum) NextVisitMonthNum
FROM T1


--4. Calculate the monthly time gap between two consecutive visits by each customer.

CREATE VIEW VisitGaps AS
SELECT 
	*,
	(NextVisitMonthNum - VisitMonthNum) AS ConsecutiveVisitGap
FROM 
	Consecutive_visits


--5. Categorise customers using average time gaps. Choose the most fitted labeling model for you.

CREATE VIEW customer_type AS
WITH T2 AS
(
SELECT Cust_id, AVG(ConsecutiveVisitGap) AvgVisitGap
FROM VisitGaps
GROUP BY Cust_id
)
SELECT *,
	CASE
		WHEN AvgVisitGap IS NULL THEN 'New Customer'
		WHEN AvgVisitGap = 1 THEN 'Loyal Customer'
		WHEN AvgVisitGap > 1 AND AvgVisitGap <= 6 THEN 'Regular Customer'
		WHEN AvgVisitGap > 6 AND AvgVisitGap <=12 THEN 'Need Based Customer'
		WHEN AvgVisitGap > 12 THEN 'Irregular Customer'
	END AS CustomerType
FROM T2

--------------------------------------------------------------------------------------------------------------------------------
--MONTH-WISE RETENTION RATE
--Find month-by-month customer retention rate since the start of the business.

--1. Find the number of customers retained month-wise. (You can use time gaps)

SELECT 
	DISTINCT VisitMonthNum, NextVisitMonthNum,
	COUNT(Cust_id) OVER(PARTITION BY  VisitMonthNum) MonthWiseRetain
FROM VisitGaps
WHERE ConsecutiveVisitGap = 1


--2. Calculate the month-wise retention rate.

--Step-1
CREATE VIEW MonthlyVisit AS
SELECT
	DISTINCT Cust_id, [Year], [Month], VisitMonthNum,
	COUNT(Cust_id) OVER(PARTITION BY VisitMonthNum) MonthlyTotalVisit
FROM VisitGaps
order by VisitMonthNum


--Step-2
CREATE VIEW RetainedVisit AS
SELECT 
	DISTINCT Cust_id, [Year], [Month], VisitMonthNum, NextVisitMonthNum,
	COUNT(Cust_id) OVER(PARTITION BY NextVisitMonthNum) RetainedTotalVisit
FROM
	VisitGaps
WHERE
	ConsecutiveVisitGap = 1 AND VisitMonthNum >1


--Step-3
SELECT 
	DISTINCT rv.[Year], rv.[Month], 
	CAST((100.0 * RetainedTotalVisit / MonthlyTotalVisit) AS DECIMAL(10,2)) MonthlyRetentionPercentageRate
FROM 
	MonthlyVisit mv
INNER JOIN 
	RetainedVisit rv
ON 
	mv.VisitMonthNum + 1 = rv.NextVisitMonthNum

-----------------------------------------------------------------------------------------------------END------------------------------------------------------------------------



