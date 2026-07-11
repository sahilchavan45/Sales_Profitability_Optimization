-- Sales Profitability Optimization Project 

create database sales;

use sales;

create table products (
Order_ID int primary key,
Order_Date varchar(50),
Month varchar(50),
Region varchar(50),
State varchar(50),
Category varchar(50),
Sub_Category varchar(50),
Product_Name varchar(50),
Sales DECIMAL(10,2),
Quantity int,
Discount varchar(50),
Profit DECIMAL(10,2),
Customer_ID varchar(50),
Segment varchar(50));


SHOW VARIABLES LIKE 'local_infile';

LOAD DATA LOCAL INFILE "C:\Users\SAHIL CHAVHAN\Downloads\Sales_Profitability_Optimization.csv"
INTO TABLE sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


-- 1. Which regions have high sales but poor profitability?
-- Business Problem: Find regions where revenue is strong but profits are weak.

SELECT
    Region,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    ROUND((SUM(Profit)/SUM(Sales))*100,2) AS Profit_Margin
FROM products
GROUP BY Region
ORDER BY Profit_Margin asc;

-- 2. Does a higher discount reduce profit?
-- Business Problem: Evaluate the relationship between discounts and profitability.

SELECT
    Discount,
    COUNT(*) AS Orders,
    SUM(Sales) AS Sales,
    SUM(Profit) AS Profit
FROM products
GROUP BY Discount
ORDER BY Discount asc;

-- 3. Which category has the highest profit margin?
-- Business Problem: Identify the most profitable product categories

SELECT
    Category,
    SUM(Sales) AS Sales,
    SUM(Profit) AS Profit,
    ROUND((SUM(Profit)/SUM(Sales))*100,2) AS Profit_Margin
FROM products
GROUP BY Category
ORDER BY Profit_Margin DESC;

-- 4. Which months generated the highest losses?
-- Business Problem: Detect seasonal patterns affecting profit.

SELECT
	Month,
    SUM(Sales) AS Sales,
    SUM(Profit) AS Profit
FROM Products
GROUP BY Month
ORDER BY profit asc;

-- 5. Which customers generate the most profit?
-- Business Problem: Identify high-value customers.

SELECT
    Customer_ID,
    SUM(Sales) AS Sales,
    SUM(Profit) AS Profit
FROM products
GROUP BY Customer_ID
ORDER BY Profit DESC
LIMIT 10;

-- 6. Which customers generate losses?
-- Business Problem: Identify customers whose purchases consistently lose money.

SELECT
    Customer_ID,
    SUM(Profit) AS Total_Profit
FROM products
GROUP BY Customer_ID
HAVING SUM(Profit) < 0
ORDER BY Total_Profit;

-- 7. Which products receive the highest average discount?
-- Business Problem: Find products that are frequently discounted.

SELECT
    Product_Name,
    ROUND(AVG(Discount)*100,2) AS Avg_Discount
FROM products
GROUP BY Product_Name
ORDER BY Avg_Discount DESC
LIMIT 10;

-- 8. Which products have high sales but low profit?
-- Business Problem: Identify products that sell well but don't contribute much profit.

SELECT
    Product_Name,
    SUM(Sales) AS Sales,
    SUM(Profit) AS Profit
FROM products
GROUP BY Product_Name
ORDER BY Sales DESC;

-- 9. Which region contributes the largest share of total profit?
-- Business Problem: Determine the most profitable region.

SELECT
    Region,
    SUM(Profit) AS Profit
FROM products
GROUP BY Region
ORDER BY Profit DESC;

-- 10. Which products have the highest profit margin?
-- Business Problem: Find products that deliver the greatest return.

SELECT
    Product_Name,
    ROUND((SUM(Profit)/SUM(Sales))*100,2) AS Profit_Margin
FROM products
GROUP BY Product_Name
HAVING SUM(Sales) > 0
ORDER BY Profit_Margin DESC
LIMIT 10;

-- 11. Rank products by profit within each category (Window Function)
-- Business Problem: Compare products against others in the same category.

SELECT
    Category,
    Product_Name,
    SUM(Profit) AS Total_Profit,
    RANK() OVER(
        PARTITION BY Category
        ORDER BY SUM(Profit) DESC
    ) AS Profit_Rank
FROM products
GROUP BY Category, Product_Name;

-- 12. Which products perform above the category average? (CTE)
-- Business Problem: Identify products outperforming their category.

WITH CategoryAvg AS (
    SELECT
        Category,
        AVG(Profit) AS Avg_Profit
    FROM products
    GROUP BY Category
)
SELECT
    p.Category,
    p.Product_Name,
    SUM(p.Profit) AS Product_Profit,
    c.Avg_Profit
FROM products p
JOIN CategoryAvg c
    ON p.Category = c.Category
GROUP BY
    p.Category,
    p.Product_Name,
    c.Avg_Profit
HAVING SUM(p.Profit) > c.Avg_Profit;

-- 13. Executive Summary Query
-- Business Problem: Produce key business KPIs in one result.

SELECT
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    ROUND((SUM(Profit)/SUM(Sales))*100,2) AS Profit_Margin,
    ROUND(AVG(Discount)*100,2) AS Avg_Discount,
    SUM(CASE WHEN Profit < 0 THEN 1 ELSE 0 END) AS Loss_Making_Orders
FROM products;

