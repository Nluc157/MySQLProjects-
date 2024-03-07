
-- ------------------------------------------- Data Exploration in MySQL ------------------------------------------- --

-- ----------- Data Preparation ----------- --

-- Select datasets --

SELECT * 
FROM Business_Data.business_monthly_sales;

SELECT *
FROM Business_Data.business_retail_sales;

-- Row total --

SELECT COUNT(*) AS Row_Total 
FROM Business_Data.business_retail_sales;

-- Number of unique products --

SELECT `Product Type`, COUNT(DISTINCT `Product Type`) AS Product_Count
FROM Business_Data.business_retail_sales
GROUP BY 1;

-- Validate that Gross Sales is equal between tables --

SELECT ROUND(SUM(`Gross Sales`), 2) AS Total_Sales 
FROM Business_Data.business_monthly_sales;

SELECT ROUND(SUM(`Gross Sales`), 2) AS Total_Sales 
FROM Business_Data.business_retail_sales;

-- -------------------------------------------------------------------------------------------------------------------- --

-- Monthly Sales Table Preparation --

-- Validate data for Gross Sales, Discounts, Returns and Net Sales --
    
SELECT 
	Month, 
    `Gross Sales`, 
    `Net Sales`,
	ROUND(SUM(`Gross Sales` + (Discounts + Returns)), 2) AS Calculated_Net,
    CASE 
		WHEN ROUND(SUM(`Gross Sales` + (Discounts + Returns)),2) = `Net Sales` THEN 'True' 
        ELSE 'False' 
	END AS Sales_Equal
FROM Business_Data.business_monthly_sales
GROUP BY 1,2,3;

-- Validate data for Total Sales with Shipping included --

SELECT 
		Month,
		`Net Sales`, 
		Shipping, 
	   `Total Sales`,
        ROUND(SUM(`Net Sales` + Shipping), 2) AS Caclulated_Sales_Total,
        CASE 
			WHEN ROUND(SUM(`Net Sales` + Shipping), 2) = `Total Sales` THEN 'True'
            ELSE 'False'
		END AS Total_Sales_Equal
FROM Business_Data.business_monthly_sales
GROUP BY 1,2,3,4;

-- Updating table with correct Total Sales value for January, 2019 --

UPDATE Business_Data.business_monthly_sales
SET `Total Sales` = 7613.21
WHERE 
    Month = 'January'
    AND `Net Sales` = 6299.43;
 
 
-- -------------------------------------------------------------------------------------------------------------------- --

-- Retail Sales Table Preparation --

SELECT *
FROM Business_Data.business_retail_sales;

-- Check for missing Product Types --

SELECT `Net Quantity`, `Gross Sales`, COUNT(*) AS `Empty Rows`
FROM Business_Data.business_retail_sales
WHERE `Product Type` = ''
GROUP BY 1,2;

-- Update missing Product Types to Unknown --

UPDATE Business_Data.business_retail_sales
SET `Product Type` = 'Unknown'
WHERE `Product Type` = '';

SELECT *
FROM Business_Data.business_retail_sales
ORDER BY `Product Type` DESC;

-- Validate Total Net Sales calculation --

SELECT 
	`Product Type`, 
    `Net Quantity`,
	`Gross Sales`,
    `Discounts`,
     Returns,
    `Total Net Sales`,
	ROUND(`Gross Sales` + (Discounts + Returns),2) AS Calculated_Net,
    CASE 
		WHEN ROUND(`Gross Sales` + (Discounts + Returns),2)  = `Total Net Sales` THEN 'True' 
        ELSE 'False' 
	END AS Sales_Equal
FROM Business_Data.business_retail_sales
WHERE ROUND(`Gross Sales` + (Discounts + Returns),2) <> `Total Net Sales`
GROUP BY 1,2,3,4,5,6;

SELECT 
    `Product Type`, 
    `Net Quantity`,
    `Gross Sales`,
    `Discounts`,
    Returns,
    `Total Net Sales`,
    CASE 
        WHEN ROUND(`Gross Sales` + (Discounts + Returns), 2) = `Total Net Sales` THEN 'True' 
        ELSE 'False' 
    END AS Sales_Equal
FROM Business_Data.business_retail_sales
GROUP BY 1,2,3,4,5,6;

-- Update table with correct Total Net Sales values --

UPDATE Business_Data.business_retail_sales
SET `Total Net Sales` = ROUND(`Gross Sales` + (Discounts + Returns), 2);

-- Correct data inconsistencies when Net Quantity is 0 and item is returned --

SELECT *
FROM Business_Data.business_retail_sales
WHERE `Net Quantity` = ' ' OR `Net Quantity` IS NULL;

-- Update table -- 

UPDATE Business_Data.business_retail_sales
SET `Discounts` = 0
WHERE `Net Quantity` = 0;

UPDATE Business_Data.business_retail_sales
SET `Returns` = -`Gross Sales`
WHERE `Net Quantity` = 0;

UPDATE Business_Data.business_retail_sales
SET `Total Net Sales` = 0
WHERE `Net Quantity` = 0;


-- -------------------------------------------------------------------------------------------------------------------- --

-- -------------------- Data Exploration ---------------------- -- 


-- 1) Which product types have generated the highest total net sales? -- 

SELECT
    `Product Type`,
    CONCAT('$', FORMAT(ROUND(SUM(`Total Net Sales`), 0), 0)) AS `Total Net Sales`
FROM
    Business_Data.business_retail_sales
GROUP BY
    `Product Type`
ORDER BY
    ROUND(SUM(`Total Net Sales`), 0) DESC;
    
-- The highest total net sales by products are found in the basket, art & sculpture and jewelry types. 


-- -------------------------------------------------------------------------------------------------------------------- --


-- 2) Which months have generated the most in net sales over the three year period? -- 

SELECT
    Month,
    CONCAT('$', FORMAT(ROUND(SUM(`Net Sales`)), 0)) AS `Net Sales`
FROM
    Business_Data.business_monthly_sales
GROUP BY
    Month
ORDER BY
    `Net Sales` DESC;
    
-- The months that have generated the most in net sales include December, November and June. 


-- -------------------------------------------------------------------------------------------------------------------- --


--  3) What percentage growth or decline is seen in total sales over the years? -- 

SELECT
    Year,
    CONCAT('$', FORMAT(ROUND(SUM(`Total Sales`)), 0)) AS `Sales Total`,
    CONCAT(ROUND(((SUM(`Total Sales`) - LAG(SUM(`Total Sales`)) OVER (ORDER BY Year)) / LAG(SUM(`Total Sales`)) 
    OVER (ORDER BY Year)) * 100, 0), '%') AS `Percentage Change`
FROM
    Business_Data.business_monthly_sales
GROUP BY
    Year
ORDER BY 
    `Sales Total` DESC;
    
-- Between 2017 and 2018 the business achieved a 19% increase in total sales. From 2018 until 2019 the company grew total sales by 26%.


-- -------------------------------------------------------------------------------------------------------------------- --


-- 4) What is the average net sales generated per unit for each product type sold? -- 

SELECT
    `Product Type`,
    CONCAT('$', FORMAT(ROUND(SUM(`Total Net Sales` / `Net Quantity`), 0), 0)) AS `Average Sales Per Unit`
FROM
    Business_Data.business_retail_sales
GROUP BY
    `Product Type`
ORDER BY ROUND(SUM(`Total Net Sales` / `Net Quantity`), 0) DESC;

-- The product types with the highest average sales per unit include the basket, art & sculpture, and home decor types. 


-- -------------------------------------------------------------------------------------------------------------------- --


-- 5) What is the average revenue per order across the months? --

SELECT
    Month,
    CONCAT('$', FORMAT(ROUND(AVG(`Net Sales` / `Total Orders`), 0), 0)) AS `Average Revenue Per Order`,
    SUM(`Total Orders`) AS `Total Orders`,
    CONCAT('$', FORMAT(ROUND(SUM(`Net Sales`), 0), 0)) AS `Net Sales`
FROM
    Business_Data.business_monthly_sales
GROUP BY
    Month
ORDER BY
    ROUND(AVG(`Net Sales` / `Total Orders`), 0) DESC, Month;
    
-- The months of September, August and June have the highest average revenue per order. 


-- -------------------------------------------------------------------------------------------------------------------- --


-- 6) Which product type has the highest total return amount? --

SELECT 
	`Product Type`,
    CONCAT('$', FORMAT(SUM(Returns), 0)) AS `Returns`
FROM Business_Data.business_retail_sales
GROUP BY `Product Type`
ORDER BY SUM(Returns);

-- The top categories with the highest total return amounts include baskets, art & sculptures, and Christmas products.


-- -------------------------------------------------------------------------------------------------------------------- --


-- 7) What is the percentage of returns compared to gross sales for each month in 2019? --

SELECT
    Month,
    Year,
    CONCAT(ROUND((SUM(-Returns) / SUM(`Gross Sales`)) * 100, 0), '%') AS `Return Percentage`
FROM
    Business_Data.business_monthly_sales
WHERE 
	Year = 2019
GROUP BY
    Month, Year 
ORDER BY 
	SUM(-Returns) / SUM(`Gross Sales`) DESC;
    
-- The months with the highest return percentage in 2019 include October and January with the other months below a 10% return rate. 


-- -------------------------------------------------------------------------------------------------------------------- --


-- 8) Identify the specific month and corresponding year that have the highest and lowest order counts over the three-year period? --

SELECT
  Month,
  Year,
  `Total Orders`
FROM
  Business_Data.business_monthly_sales
WHERE
  `Total Orders` = (SELECT MAX(`Total Orders`) FROM Business_Data.business_monthly_sales)
  OR `Total Orders` = (SELECT MIN(`Total Orders`) FROM Business_Data.business_monthly_sales);

-- May 2017 had the lowest order count at 54, while December 2019 marked the peak with 342 orders.  


-- -------------------------------------------------------------------------------------------------------------------- --


-- 9) How much has shipping cost contributed to overall sales? --

SELECT
    CONCAT('$', FORMAT(SUM(Shipping), 0)) AS `Total Shipping Cost`,
    CONCAT('$', FORMAT(SUM(`Total Sales`), 0)) AS `Total Sales`,
    CONCAT(FORMAT((SUM(Shipping) / SUM(`Total Sales`)) * 100, 2), '%') AS `Shipping Contribution`
FROM
    Business_Data.business_monthly_sales;
    
-- The business achieved a total sales revenue of $382,963, encompassing both net and shipping profits. 
-- Notably, shipping contributed $56,858, accounting for 14.85% of overall profits.


-- -------------------------------------------------------------------------------------------------------------------- --


-- 10) Which months experienced the highest percentage growth in net sales compared to the previous month? -- 

SELECT
    Month,
    Year,
    CONCAT('$', FORMAT(`Net Sales`, 0)) AS `Net Sales`,
    CONCAT('$', FORMAT(LAG(`Net Sales`) OVER (ORDER BY STR_TO_DATE(CONCAT(Month, ' ', Year), '%M %Y')), 0)) AS `Previous Month`,
    CONCAT(FORMAT(((`Net Sales` - LAG(`Net Sales`) OVER (ORDER BY STR_TO_DATE(CONCAT(Month, ' ', Year), '%M %Y'))) / LAG(`Net Sales`) 
    OVER (ORDER BY STR_TO_DATE(CONCAT(Month, ' ', Year), '%M %Y')) * 100), 0), '%') AS `Growth Rate`
FROM
    Business_Data.business_monthly_sales
ORDER BY
    ((`Net Sales` - LAG(`Net Sales`) OVER (ORDER BY STR_TO_DATE(CONCAT(Month, ' ', Year), '%M %Y'))) 
    / LAG(`Net Sales`) OVER (ORDER BY STR_TO_DATE(CONCAT(Month, ' ', Year), '%M %Y')) * 100) DESC;

-- November 2019, November 2017, and June 2018 exhibited the highest growth rates at 214%, 136%, and 96%, respectively.


-- -------------------------------------------------------------------------------------------------------------------- --
-- -------------------------------------------------------------------------------------------------------------------- --







    



    




































    

    
    
















