USE walmart;

SELECT *
FROM walmartsalesdata
WHERE invoice_id IS NULL
   OR branch IS NULL
   OR customer_type IS NULL
   OR gender IS NULL
   OR product_line IS NULL
   OR unit_price IS NULL
   OR Quantity IS NULL
   OR tax_5percent IS NULL
   ;
   
SELECT *
FROM walmartsalesdata;

describe walmartsalesdata;

--  ---------------------------- Creating a different table for city -----------------------------------------------
CREATE TABLE city (
	Branch CHAR(1) PRIMARY KEY,
    city VARCHAR(15)
);

-- ------------------------ Inserting vales for the city table from the main wholesales table ------------------------------
INSERT INTO city (Branch, city) 
SELECT Branch, city
FROM walmart.walmartsalesdata
GROUP BY Branch, city
ORDER BY Branch;

-- -------- USING CASE STATEMENT TO GROUP THE TIME FOR EASY MANIPULATION --------------------------
SELECT time,
	CASE
		WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END AS time_of_day
FROM walmartsalesdata;

-- ---------------- ADDING AN EXTRA COLUMN TO THE TABLE ---------------------
ALTER TABLE walmartsalesdata
ADD COLUMN time_of_day VARCHAR(20);

ALTER TABLE walmartsalesdata
DROP COLUMN time_of_day;

-- -------------------------- FILLING THE NEW COLUMN WITH DATA ------------------------
UPDATE walmartsalesdata
SET time_of_day = (
	CASE
		WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);

SET sql_safe_updates = 0;
-- -------------------------- ADDING A COLUMN FOR THE DAY OF THE WEEK ---------------
 SELECT date, DAYNAME(Date)
 FROM walmartsalesdata;
 
 ALTER TABLE walmartsalesdata
ADD COLUMN day_of_week VARCHAR(20);

UPDATE walmartsalesdata
SET day_of_week = DAYNAME(date);

-- -------------------------- ADDING A COLUMN FOR THE MONTHS ---------------
 SELECT date, MONTHNAME(Date)
 FROM walmartsalesdata;
 
ALTER TABLE walmartsalesdata
ADD COLUMN month VARCHAR(20);

UPDATE walmartsalesdata
SET month = MONTHNAME(date);

-- ------------------------------------------------------------------------------
-- -------------------------- GENERIC QUESTIONS ---------------------------------

-- HOW MANY UNIQUE CITIES DOES THE DATA HAVE
SELECT COUNT(DISTINCT(city)) AS no_cities
FROM city;

-- -------------------------- IN WHICH CITY IS EACH BRANCH LOCATED --------------------
-- A DIFFERENT TABLE HAS ALREADY BEEN CREATED FOR BRANCH AND CITY ---------------
SELECT *
FROM city;

-- --------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------
-- -------------------------- PRODUCT QUESTIONS ---------------------------------

-- -------------------- How many unique product lines does the data have? --------
SELECT COUNT(DISTINCT(product_line)) AS no_product_line
FROM walmartsalesdata;

-- -------------------- What is the most common payment method? -------------------
SELECT payment, COUNT(*) AS no_times_used
from walmartsalesdata
GROUP BY payment;

-- -------------------- What is the most selling product line? -------------------
SELECT product_line, SUM(QUANTITY) AS no_items_sold
from walmartsalesdata
GROUP BY product_line
ORDER BY no_items_sold DESC;

-- -------------------- What is the total revenue by month? -------------------
SELECT month, SUM(total) AS total_revenue
FROM walmartsalesdata
GROUP BY month
ORDER BY total_revenue DESC;

-- -------------------- What month had the largest COGS? -------------------
SELECT month, MAX(`SUM(cogs)`) AS sum_cogs
FROM (
	SELECT month, SUM(cogs)
	FROM walmartsalesdata
	GROUP BY month) AS b
GROUP BY month
ORDER BY sum_cogs DESC
-- LIMIT 1
;

-- -------------------- What product line had the largest revenue? -------------------
SELECT product_line, SUM(total) AS total_revenue
FROM walmartsalesdata
GROUP BY product_line
ORDER BY total_revenue DESC;

-- -------------------- What is the city with the largest revenue? -------------------
 SELECT c.branch, city, SUM(total) AS total_revenue
 FROM walmartsalesdata AS w
 JOIN city AS c
	ON w.branch = c.branch
GROUP BY c.branch, city
ORDER BY total_revenue DESC;

-- -------------------- What product line had the largest VAT? -------------------
SELECT product_line, MAX(tax_5percent) max_VAT
FROM walmartsalesdata
GROUP BY product_line
ORDER BY max_VAT DESC;

-- -------- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales ----------

SELECT product_line, AVG(quantity) AS quantity_avg,
       CASE 
           WHEN AVG(quantity) > (SELECT AVG(quantity) FROM walmartsalesdata) 
           THEN 'Good'
           ELSE 'Bad'
       END AS quantity_status
FROM walmartsalesdata
GROUP BY product_line;


-- -------------------- Which branch sold more products than average product sold? -------------------
SELECT branch, avg(quantity) AS quantity_avg
FROM walmartsalesdata
GROUP BY branch
HAVING quantity_avg > (
SELECT avg(Quantity)
FROM walmartsalesdata);

-- -------------------- What is the most common product line by gender? -------------------
SELECT gender, product_line, COUNT(gender) AS gender_count
FROM walmartsalesdata
GROUP BY gender, product_line
ORDER BY gender, gender_count DESC;

-- -------------------- What is the average rating of each product line? -------------------
SELECT product_line, substring(AVG(Rating),1,4) AS AVG_rating
FROM walmartsalesdata
GROUP BY product_line
ORDER BY AVG_rating DESC;


-- ------------------------------------------------------------------------------
-- -------------------------- SALES QUESTIONS ---------------------------------

-- -------------------- Number of sales made in each time of the day per weekday -------------------
SELECT day_of_week, SUM(quantity) AS total_sales
FROM walmartsalesdata
GROUP BY day_of_week
ORDER BY total_sales DESC;

-- -------------------- Which of the customer types brings the most revenue? -------------------
SELECT customer_type, SUM(total) AS total_revenue
FROM walmartsalesdata
GROUP BY customer_type
ORDER BY total_revenue;

-- -------------------- Which city has the largest tax percent/ VAT (Value Added Tax)? -------------------
SELECT city, SUBSTRING(SUM(tax_5percent),1,7) as total_vat
FROM walmartsalesdata AS w
JOIN city AS c
	ON w.branch = c.branch
GROUP BY city
ORDER BY total_vat DESC
LIMIT 1;


-- ------------------------------------ Which customer type pays the most in VAT? --------------------------------------------------------
SELECT customer_type, SUM(tax_5percent) AS total_VAT
FROM walmartsalesdata
GROUP BY customer_type
ORDER BY total_VAT
LIMIT 1;


-- ------------------------------------------------------------------------------
-- -------------------------- CUSTOMER QUESTIONS ---------------------------------

-- -------------------- How many unique customer types does the data have? -------------------
SELECT COUNT(DISTINCT(customer_type))
FROM walmartsalesdata;

-- -------------------- How many unique payment methods does the data have? -------------------
SELECT COUNT(DISTINCT(payment))
FROM walmartsalesdata;

-- -------------------- What is the most common customer type? -------------------
SELECT customer_type, COUNT(customer_type) AS no_of_customers
FROM walmartsalesdata
GROUP BY customer_type;

-- -------------------- Which customer type buys the most? -------------------
SELECT customer_type, SUM(quantity) AS total_items_bought
FROM walmartsalesdata
GROUP BY customer_type
ORDER BY total_items_bought;

-- -------------------- What is the gender of most of the customers? -------------------
SELECT gender, COUNT(gender) AS gender_count
FROM walmartsalesdata
GROUP BY gender
ORDER BY gender_count DESC;

-- -------------------- What is the gender distribution per branch? -------------------
SELECT branch, gender,  COUNT(branch) AS gender_count
FROM walmartsalesdata
GROUP BY branch, gender
ORDER BY branch, gender_count DESC;

-- -------------------- Which time of the day do customers give most ratings? -------------------
SELECT *
FROM walmartsalesdata;

SELECT time_of_day, SUBSTRING(AVG(rating),1,4) AS avg_rating
FROM walmartsalesdata
GROUP BY time_of_day;

-- -------------------- Which time of the day do customers give most ratings per branch? -------------------
SELECT branch, time_of_day, avg_rating
FROM (
    SELECT branch, time_of_day, SUBSTRING(AVG(rating),1,4) AS avg_rating
    FROM walmartsalesdata
    GROUP BY branch, time_of_day
) AS B
WHERE (branch, avg_rating) IN (
    SELECT branch, MAX(avg_rating)
    FROM (
        SELECT branch, time_of_day, SUBSTRING(AVG(rating),1,4) AS avg_rating
        FROM walmartsalesdata
        GROUP BY branch, time_of_day
    ) AS A
    GROUP BY branch
);
-- -------------------- Which day of the week has the best avg ratings? -------------------
SELECT day_of_week, SUBSTRING(AVG(rating),1,4) AS avg_rating
FROM walmartsalesdata
GROUP BY day_of_week
ORDER BY avg_rating DESC;

-- -------------------- Which day of the week has the best average ratings per branch? -------------------
SELECT branch, day_of_week, avg_rating
FROM (
    SELECT branch, day_of_week, SUBSTRING(AVG(rating),1,4) AS avg_rating
    FROM walmartsalesdata
    GROUP BY branch, day_of_week
) AS B
WHERE (branch, avg_rating) IN (
    SELECT branch, MAX(avg_rating)
    FROM (
        SELECT branch, day_of_week, SUBSTRING(AVG(rating),1,4) AS avg_rating
        FROM walmartsalesdata
        GROUP BY branch, day_of_week
    ) AS A
    GROUP BY branch
);
