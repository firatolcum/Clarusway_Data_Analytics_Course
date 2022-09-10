


CREATE TABLE #T1 
(
id int,
adv_type char,
[action] varchar(10)
)


SELECT *
FROM #T1

INSERT INTO #T1 VALUES
(1,'A', 'Left'),
(2,'A', 'Order'),
(3,'B', 'Left'),
(4,'A', 'Order'),
(5,'A', 'Review'),
(6,'A', 'Left'),
(7,'B', 'Left'),
(8,'B', 'Order'),
(9,'B', 'Review'),
(10,'A', 'Review')


--A		0.00
--B		0.000


SELECT adv_type, 
		COUNT (*) total_action
FROM	#T1
GROUP BY adv_type



WITH CTE1 AS
(
SELECT adv_type, 
		COUNT (*) total_action
FROM	#T1
GROUP BY adv_type
), CTE2 AS
(
SELECT adv_type, COUNT (*) order_action
FROM	#T1
WHERE action = 'Order'
GROUP BY adv_type
)
SELECT	CTE1.adv_type, CTE1.total_action, CTE2.order_action, cast(1.0*order_action/total_action as decimal(3,2)) AS conversion_rate
FROM	CTE1, CTE2
WHERE	CTE1.adv_type = CTE2.adv_type




CREATE OR ALTER VIEW actions_and_orders as
SELECT Adv_Type
	,COUNT(Action) as total_Action
	,SUM (CASE Action WHEN 'Order' THEN 1 ELSE 0 END) as total_Order
FROM Actions
GROUP BY Adv_Type





SELECT	Adv_Type, 
		CAST((total_Order*1.0/total_Order) AS NUMERIC(10,2)) as Conversion_Rate
FROM	actions_and_orders
























