--SQL Advance Case Study


--Q1--BEGIN 
	
SELECT 
	[State],
	[Date]                                             --added it, to display the result w.r.t. date

FROM FACT_TRANSACTIONS AS T1
	INNER JOIN DIM_LOCATION AS T2
		ON T1.IDLocation = T2.IDLocation
	WHERE YEAR(DATE) BETWEEN 2005 AND YEAR(DATE)

ORDER BY [Date] DESC



--Q1--END

--Q2--BEGIN
	
SELECT TOP 1
	[State],
	Manufacturer_Name,                                --added it, to display the result w.r.t. Manufacturer name
	Qty = SUM(Quantity)								  --added it to display the result to show qty

FROM FACT_TRANSACTIONS AS TR

	INNER JOIN DIM_LOCATION AS LO
			ON TR.IDLocation = LO.IDLocation
	INNER JOIN DIM_MODEL AS MO
			ON MO.IDModel = TR.IDModel
	INNER JOIN DIM_MANUFACTURER AS MN
			ON MO.IDManufacturer = MN.IDManufacturer
	
	WHERE Country = 'US' AND 
	Manufacturer_Name = 'Samsung'

GROUP BY [State], 
	Manufacturer_Name

ORDER BY SUM(Quantity) DESC



--Q2--END

--Q3--BEGIN      
	
SELECT * 
FROM FACT_TRANSACTIONS AS FT

	INNER JOIN DIM_LOCATION AS LO
		ON FT.IDLocation = LO.IDLocation

ORDER BY IDModel, [State], ZipCode



--Q3--END

--Q4--BEGIN

SELECT TOP 1
	IDModel,
	Model_Name,
	Unit_price

FROM DIM_MODEL

ORDER BY Unit_price 



--Q4--END

--Q5--BEGIN

SELECT 
	Model_Name,
	Manufacturer_Name,
	Avg_Price = AVG(Unit_price)

FROM DIM_MODEL AS MO	
	
	INNER JOIN DIM_MANUFACTURER AS MN
		ON MO.IDManufacturer = MN.IDManufacturer

WHERE Manufacturer_Name IN
(
	SELECT TOP 5
		Manufacturer_Name

	FROM FACT_TRANSACTIONS AS TR
	
		INNER JOIN DIM_MODEL AS MO
			ON TR.IDModel = MO.IDModel
		INNER JOIN DIM_MANUFACTURER AS MN
			ON MN.IDManufacturer = MO.IDManufacturer

	GROUP BY Manufacturer_Name
	ORDER BY SUM(Quantity) 
)

GROUP BY Model_Name, Manufacturer_Name

ORDER BY AVG(Unit_price) DESC



--Q5--END

--Q6--BEGIN

SELECT 
	Customer_Name,
	Avg_Spending = AVG(TotalPrice)

FROM DIM_CUSTOMER AS T1
	
	INNER JOIN FACT_TRANSACTIONS AS T2
		ON T1.IDCustomer = T2.IDCustomer

WHERE YEAR(Date) = 2009

GROUP BY Customer_Name
HAVING AVG(TotalPrice) > 500

ORDER BY Avg_Spending 




--Q6--END
	
--Q7--BEGIN  
	
SELECT * 
FROM 
(
	SELECT TOP 5
		IDModel,
		QTY = SUM(Quantity),
		[YEAR] = YEAR(Date)
		
	FROM FACT_TRANSACTIONS
	WHERE YEAR(Date) = 2008

	GROUP BY IDModel, Date
	ORDER BY SUM(Quantity) DESC								--For Year 2008

UNION ALL

	SELECT TOP 5
		IDModel,
		QTY = SUM(Quantity),
		[YEAR] = YEAR(Date)
		
	FROM FACT_TRANSACTIONS
	WHERE YEAR(Date) = 2009

	GROUP BY IDModel, Date
	ORDER BY SUM(Quantity) DESC								--For Year 2009

UNION ALL

	SELECT TOP 5
		IDModel,
		QTY = SUM(Quantity),
		[YEAR] = YEAR(Date)
		
	FROM FACT_TRANSACTIONS
	WHERE YEAR(Date) = 2010

	GROUP BY IDModel, Date
	ORDER BY SUM(Quantity) DESC								--For Year 2010
) A	

-- other method

SELECT TOP 5 MODEL_NAME,
SUM(QUANTITY) AS QUANTITY

FROM FACT_TRANSACTIONS AS A 

INNER JOIN DIM_MODEL AS B 
ON A.IDMODEL=B.IDMODEL 

WHERE YEAR(DATE) IN ('2008','2009','2010')

GROUP BY MODEL_NAME

ORDER BY QUANTITY DESC


--Q7--END	
--Q8--BEGIN

SELECT TOP 1 *
FROM 
(
	SELECT TOP 2
		Manufacturer_Name,
		Top2nd_Sales = SUM(TotalPrice)
		
	FROM DIM_MANUFACTURER AS T1
		INNER JOIN DIM_MODEL AS T2
			ON T1.IDManufacturer = T2.IDManufacturer

		INNER JOIN FACT_TRANSACTIONS AS T3
			ON T2.IDModel = T3.IDModel
	WHERE YEAR(Date) = 2009 

	GROUP BY Manufacturer_Name 
	ORDER BY Top2nd_Sales DESC
)A,

(
	SELECT TOP 2
		Manufacturer_Name,
		Top2nd_Sales = SUM(TotalPrice)
		
	FROM DIM_MANUFACTURER AS T1
		INNER JOIN DIM_MODEL AS T2
			ON T1.IDManufacturer = T2.IDManufacturer

		INNER JOIN FACT_TRANSACTIONS AS T3
			ON T2.IDModel = T3.IDModel
	WHERE YEAR(Date) = 2010

	GROUP BY Manufacturer_Name 
	ORDER BY Top2nd_Sales DESC
)B




--Q8--END
--Q9--BEGIN
	
SELECT 
Manufacturer_Name
		
FROM DIM_MANUFACTURER AS T1
	INNER JOIN DIM_MODEL AS T2
		ON T1.IDManufacturer = T2.IDManufacturer

	INNER JOIN FACT_TRANSACTIONS AS T3
		ON T2.IDModel = T3.IDModel
WHERE YEAR(Date) = 2010

EXCEPT

SELECT 
Manufacturer_Name
		
FROM DIM_MANUFACTURER AS T1
	INNER JOIN DIM_MODEL AS T2
		ON T1.IDManufacturer = T2.IDManufacturer

	INNER JOIN FACT_TRANSACTIONS AS T3
		ON T2.IDModel = T3.IDModel
WHERE YEAR(Date) = 2009



--Q9--END

--Q10--BEGIN
	
WITH Average AS
			(
			SELECT 
			Customer_Name,	
			Y_Date = YEAR(Date),
			Avg_Spend = AVG(TotalPrice),
			Avg_Qty= AVG(Quantity)
			
			FROM FACT_TRANSACTIONS AS T1
			INNER JOIN DIM_CUSTOMER AS T2
				ON T1.IDCustomer = T2.IDCustomer
			WHERE T1.IDCustomer IN 
				(SELECT TOP 10 IDCustomer FROM FACT_TRANSACTIONS GROUP BY IDCustomer ORDER BY AVG(TotalPrice) DESC, AVG(Quantity) DESC)
			GROUP BY Customer_Name, YEAR(Date)
			)

SELECT 
A.Customer_Name,
A.Avg_Qty,
A.Avg_Spend,
A.Y_Date,
P_Change_Spending = 
			CASE
				WHEN B.Y_Date IS NOT NULL 
				THEN 
				FORMAT(CONVERT(float,(A.Avg_Spend-B.Avg_Spend))/CONVERT(float,B.Avg_Spend),'P') ELSE NULL 
				END 
    
FROM Average A 		
LEFT JOIN Average B
	ON A.Customer_Name = B.Customer_Name AND
		A.Y_Date = B.Y_Date-1



--Q10--END
	


---Q10 -- With windows ()function

--Q10--BEGIN


CREATE VIEW TBL11 AS 
(SELECT  TOP 100 Customer_Name,SUM(TOTALPRICE)[PRICE],A.IDCustomer
FROM FACT_TRANSACTIONS AS A 
INNER  JOIN DIM_CUSTOMER AS B 
ON A.IDCUSTOMER=B.IDCUSTOMER
GROUP BY Customer_Name,A.IDCustomer
ORDER BY SUM(TOTALPRICE)DESC)

CREATE VIEW TBL3 AS
(SELECT CUSTOMER_NAME,AVG(TOTALPRICE) AS AVG_SPEND,AVG(QUANTITY) AS AVG_QUANTITY,
LAG(SUM(TOTALPRICE)) OVER (PARTITION BY tbl11.CUSTOMER_NAME ORDER BY YEAR(DATE)) AS PREVIOUS_SPEND
FROM FACT_TRANSACTIONS AS A INNER JOIN tbl11  ON A.IDCUSTOMER=tbl11.IDCUSTOMER
GROUP BY tbl11. CUSTOMER_NAME,year(date))

CREATE VIEW TBL5 AS
(SELECT TBL11.CUSTOMER_NAME,AVG_SPEND,PREVIOUS_SPEND,AVG_QUANTITY,
([Price]-[PREVIOUS_SPEND])*0.1/[previous_spend] AS PERCENT_OF_CHANGE
FROM TBL3 INNER JOIN TBL11 ON TBL3.CUSTOMER_NAME=TBL11.CUSTOMER_NAME)
