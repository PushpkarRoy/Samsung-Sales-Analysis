CREATE DATABASE sumsung_analysis  

-- File name  Sumsung_sales_Analysis 
-- Location new volume (D) Data analysis project Power BI folder Sumsung_sales_Analysis 

CREATE TABLE calendar (
    date_key INT PRIMARY KEY,
    date DATE,
    year INT,
    quarter INT,
    month INT,
    month_name VARCHAR(20),
    week INT,
    day INT,
    day_of_week INT,
    day_name VARCHAR(20),
    is_weekend SMALLINT
)


COPY calendar
FROM 'D:/Data Analysis Project/POWER-BI/Sumsung_Sales_Analysis/dim_date.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM calendar 


CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_key VARCHAR(50),
    customer_name VARCHAR(100),
    country VARCHAR(50),
    channel_type VARCHAR(50),
    size VARCHAR(20),
    annual_volume_usd NUMERIC
)

SELECT * FROM customers 

CREATE TABLE facilities (
    facility_id INT PRIMARY KEY,
    facility_key VARCHAR(50),
    facility_name VARCHAR(100),
    country VARCHAR(50),
    city VARCHAR(50),
    facility_type VARCHAR(50),
    specialization VARCHAR(100),
    annual_capacity INT
)

SELECT * FROM facilities 

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_key VARCHAR(50),
    product_name VARCHAR(100),
    category VARCHAR(50),
    product_line VARCHAR(50),
    spec VARCHAR(100),
    color VARCHAR(20),
    unit_price NUMERIC,
    unit_cost NUMERIC,
    weight_kg NUMERIC,
    img_url TEXT
)

SELECT * FROM products 

CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY,
    supplier_key VARCHAR(50),
    supplier_name VARCHAR(100),
    country VARCHAR(50),
    city VARCHAR(50),
    specialty VARCHAR(100),
    tier VARCHAR(20),
    avg_quality_score NUMERIC
)

SELECT * FROM suppliers 

CREATE TABLE inventory (
    inventory_id INT PRIMARY KEY,
    date_key INT REFERENCES calendar(date_key),
    product_id INT REFERENCES products(product_id),
    facility_id INT REFERENCES facilities(facility_id),
    stock_level INT,
    safety_stock_level INT,
    reorder_point INT
)

SELECT * FROM inventory 

CREATE TABLE procurement (
    procurement_id INT PRIMARY KEY,
    order_date_key INT REFERENCES calendar(date_key),
    product_id INT REFERENCES products(product_id),
    supplier_id INT REFERENCES suppliers(supplier_id),
    order_quantity INT,
    unit_cost NUMERIC,
    total_cost NUMERIC,
    lead_time_days INT,
    delivery_date_key INT REFERENCES calendar(date_key),
    quality_score NUMERIC,
    po_number VARCHAR(50)
)

SELECT * FROM procurement 

CREATE TABLE production (
    production_id INT PRIMARY KEY,
    date_key INT REFERENCES calendar(date_key),
    product_id INT REFERENCES products(product_id),
    facility_id INT REFERENCES facilities(facility_id),
    quantity_produced INT,
    defective_units INT,
    defect_rate_pct NUMERIC,
    batch_number VARCHAR(50)
)


SELECT * FROM production


CREATE TABLE sales (
    sales_id INT PRIMARY KEY,
    date_key INT REFERENCES calendar(date_key),
    product_id INT REFERENCES products(product_id),
    customer_id INT REFERENCES customers(customer_id),
    quantity_sold INT,
    unit_price NUMERIC,
    discount_pct NUMERIC,
    discount_amount NUMERIC,
    gross_revenue NUMERIC,
    net_revenue NUMERIC,
    total_cost NUMERIC,
    profit NUMERIC,
    profit_margin_pct NUMERIC,
    order_number VARCHAR(50)
)

SELECT * FROM sales 

CREATE TABLE shipments (
    shipment_id INT PRIMARY KEY,
    ship_date_key INT REFERENCES calendar(date_key),
    delivery_date_key INT REFERENCES calendar(date_key),
    product_id INT REFERENCES products(product_id),
    facility_id INT REFERENCES facilities(facility_id),
    customer_id INT REFERENCES customers(customer_id),
    quantity INT,
    carrier VARCHAR(50),
    status VARCHAR(50),
    shipping_cost NUMERIC,
    total_weight_kg NUMERIC,
    tracking_number VARCHAR(100),
    delay_reason TEXT
)


ALTER TABLE shipments DROP CONSTRAINT shipments_product_id_fkey;

INSERT INTO products (product_id, product_name)
SELECT DISTINCT product_id, 'Unknown Product'
FROM (VALUES (17),(18),(19),(20),(21),(22),(23),(24),(25),(26),(27),(28),(29),(30),(31),(32),(33),(34),(35),(36)) AS missing(product_id);

COPY shipments
FROM 'D:/Data Analysis Project/POWER-BI/Sumsung_Sales_Analysis/fact_shipment.csv'
DELIMITER ','
CSV HEADER;


SELECT * FROM shipments


-- 1. Add missing Facilities (IDs 10 to 16)
INSERT INTO facilities (facility_id, facility_name)
SELECT id, 'Unknown Facility'
FROM generate_series(10, 16) AS id;

-- 2. Add missing Customers (IDs 6 to 17)
INSERT INTO customers (customer_id, customer_name)
SELECT id, 'Unknown Customer'
FROM generate_series(6, 17) AS id;

-- 3. Add missing Products (IDs 17 to 36)
INSERT INTO products (product_id, product_name)
SELECT id, 'Unknown Product'
FROM generate_series(17, 36) AS id;


SELECT * FROM shipments 


SELECT * FROM calendar 
SELECT * FROM customers 
SELECT * FROM facilities
SELECT * FROM inventory 
SELECT * FROM procurement
SELECT * FROM production 
SELECT * FROM products 
SELECT * FROM sales 
SELECT * FROM shipments 
SELECT * FROM suppliers 

-- 1. Overview Page

-- Total Net Revenue: 

SELECT ROUND(SUM(net_revenue)::NUMERIC,2) AS total_net_revenue 
FROM sales 

-- Total Profit:  

SELECT ROUND(SUM(profit)::NUMERIC,2) AS total_profit 
FROM sales 

-- Total Quantity Sold: 


SELECT ROUND(SUM(quantity_sold)::NUMERIC,2) AS total_quantity_sold
FROM sales 

-- Average Profit Margin %: 

SELECT ROUND(AVG(profit_margin_pct)::NUMERIC,2) || '%' AS profit_margin 
FROM sales 


-- Totla shipment quantity 

SELECT SUM(quantity) AS total_shipment_quantity 
FROM shipments 

-- Totla Delivered Quantity 

SELECT COUNT(status) AS total_delivered_quantity 
FROM shipments 
WHERE status = 'Delivered'

-- Which Supplier has best Lead time ?

SELECT su.supplier_name, ROUND(AVG(pro.lead_time_days)::NUMERIC,2) AS avg_lead_time 
FROM suppliers AS su 
JOIN procurement  AS pro 
ON su.supplier_id = pro.supplier_id 
GROUP BY su.supplier_name 
ORDER BY avg_lead_time DESC 

-- Total Profit: What is the sum of profit across all Products ?

SELECT pr.product_name, SUM(s.profit) AS total_profit 
FROM products AS pr
JOIN sales AS s
ON s.product_id = pr.product_id 
GROUP BY pr.product_name 
ORDER BY total_profit DESC 

-- Profit Margin: What is the average profit_margin_pct for all product? 

SELECT pr.product_name, ROUND(AVG(s.profit_margin_pct)::NUMERIC,2) || '%' AS avg_profit_margin 
FROM products AS pr
JOIN sales AS s
ON pr.product_id = s.product_id 
GROUP BY pr.product_name 
ORDER BY avg_profit_margin DESC 

-- Stock in Inventory by Products ?

SELECT pr.product_name, SUM(i.stock_level) AS total_product_in_stock
FROM products AS pr
JOIN inventory AS i 
ON pr.product_id = i.product_id 
GROUP BY pr.product_name 
ORDER BY total_product_in_stock DESC 

-- Which carrier Delay most Shipments ?

SELECT carrier, COUNT(status) AS total_delay 
FROM shipments 
WHERE status = 'Delayed'
GROUP BY carrier
ORDER BY total_delay DESC 

-- Which platform gives highest revenue ?

SELECT  pr.product_name, 
		ROUND(SUM(gross_revenue)::NUMERIC,2) AS total_gross_revenue, 
		ROUND(SUM(net_revenue)::NUMERIC,2) AS total_net_revenue
FROM sales AS s
JOIN products AS pr
ON pr.product_id = s.product_id  
GROUP BY pr.product_name
ORDER BY total_net_revenue DESC 

-- 2. Supplier Page (Procurement & Quality)

-- Total Spend by Supplier:

SELECT  su.supplier_id,su.supplier_name, SUM(pro.total_cost) AS total_cost
FROM procurement AS pro
JOIN suppliers AS su
ON su.supplier_id = pro.supplier_id
GROUP BY su.supplier_id, su.supplier_name  
ORDER BY total_cost DESC 

-- Average Quality Score:

SELECT ROUND(AVG(quality_score)::NUMERIC,2) AS avg_quality_score 
FROM procurement 


-- Avg Lead Time: SELECT supplier_id, AVG(lead_time_days) FROM fact_procurement GROUP BY supplier_id;

SELECT ROUND(AVG(lead_time_days)::NUMERIC,2) AS avg_lead_time 
FROM procurement 

-- Supplier Performance: Which Supplier has the highest avg_quality_score?

SELECT supplier_name, ROUND(AVG(avg_quality_score)::NUMERIC,2) AS avg_quality_score 
FROM suppliers 
GROUP BY supplier_name 
ORDER BY avg_quality_score DESC 

-- Procurement Cost: What is the total total_cost spent per Supplier in the Procurement table?

SELECT su.supplier_name, SUM(pro.total_cost) AS total_cost
FROM suppliers AS su
JOIN procurement AS pro 
ON su.supplier_id = pro.supplier_id 
GROUP BY su.supplier_name 
ORDER BY total_cost DESC 

-- Lead Times: What is the average lead_time_days for each supplier?

SELECT su.supplier_name, ROUND(AVG(pro.lead_time_days)::NUMERIC,2) AS avg_lead_time_days 
FROM suppliers AS su
JOIN procurement AS pro 
ON su.supplier_id = pro.supplier_id 
GROUP BY  su.supplier_name
ORDER BY avg_lead_time_days

-- 3. Inventory Page  

-- Total Current Stock: 

SELECT SUM(stock_level) AS total_stock_level
FROM inventory 

-- Stock-to-Safety Ratio:

SELECT  pr.product_name, 
		SUM(i.stock_level) AS total_stock, 
		SUM(i.safety_stock_level) AS total_safety_stock,
		ROUND(SUM(i.stock_level) / SUM(i.safety_stock_level)::NUMERIC,2) AS stock_ratio 
FROM products AS pr
JOIN inventory AS i 
ON i.product_id = pr.product_id 
GROUP BY pr.product_name 
ORDER BY stock_ratio DESC 

-- Total Quantity Produced: SELECT SUM(quantity_produced) FROM fact_production;

SELECT SUM(quantity_produced) AS total_quantity_produced 
FROM production 

-- Overall Defect Rate %: 

SELECT ROUND(AVG(defect_rate_pct)::NUMERIC,2) AS avg_defect_rate 
FROM production

-- Stock Status: Which products in the Inventory table have a stock_level below their reorder_point?

SELECT  pr.product_name, 
		SUM(i.stock_level) total_stock, 
		SUM(i.reorder_point) AS reorder_point
FROM products AS pr
JOIN inventory AS i 
ON pr.product_id = i.product_id 
WHERE stock_level < reorder_point
GROUP BY pr.product_name 
ORDER BY total_stock 

-- Safety Stock: What is the total safety_stock_level required across all Facilities?

SELECT  pr.product_name, 
		SUM(i.stock_level) AS total_stock, 
		SUM(i.safety_stock_level) AS total_safety_stock,
		ROUND(SUM(i.stock_level) / SUM(i.safety_stock_level)::NUMERIC,2) AS stock_ratio 
FROM products AS pr
JOIN inventory AS i 
ON i.product_id = pr.product_id 
GROUP BY pr.product_name 
ORDER BY stock_ratio DESC

-- Production Volume: How much quantity_produced is recorded in the Production table per product?

SELECT pr.product_name, SUM(pro.quantity_produced) AS total_quantity_produces 
FROM products AS pr 
JOIN production AS pro 
ON pr.product_id = pro.product_id 
GROUP BY pr.product_name 
ORDER BY total_quantity_produces DESC 

-- 4. Shipment Page (Logistics)

-- Total Shipping Cost: 

SELECT SUM(shipping_cost) AS total_shipping_cost
FROM shipments

-- On-Time vs Delayed: 

SELECT status, COUNT(status) AS status_count
FROM shipments 
WHERE 	status = 'Delivered' OR status = 'Delayed'
GROUP BY status 
ORDER BY status_count DESC 

-- Avg Delay Days: (Requires a date diff between ship_date_key and delivery_date_key in your SQL flavor).

SELECT (avg_delivery_date_key - avg_ship_date_key) AS avg_delay_days
FROM (
	SELECT  ROUND(AVG(ship_date_key)::NUMERIC,2) AS avg_ship_date_key,
			ROUND(AVG(delivery_date_key)::NUMERIC,2) AS avg_delivery_date_key
	FROM shipments
) AS x

-- Shipping Reliability: What is the count of Shipments with a status of 'Delayed' vs 'Delivered'?

SELECT 
    status,
    COUNT(*) AS shipment_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 
        2
    ) AS percentage_ratio
FROM shipments
WHERE status IN ('Delayed', 'Delivered')
GROUP BY status;

-- Carrier Costs: Which carrier has the highest total shipping_cost?

SELECT carrier, SUM(shipping_cost) AS total_shipping_cost
FROM shipments 
GROUP BY carrier 
ORDER BY total_shipping_cost DESC 

-- Delay Reasons: What are the top 3 delay_reason categories in the Shipment table?

SELECT delay_reason, COUNT(delay_reason) AS total_delay_reason 
FROM shipments 
WHERE delay_reason IS NOT NULL 
GROUP BY delay_reason 
ORDER BY total_delay_reason DESC 

-- 5. Customers Page

-- Revenue by Channel: 

SELECT cu.channel_type, SUM(s.net_revenue) AS total_revenue 
FROM customers AS cu 
JOIN sales AS s 
ON cu.customer_id = s.customer_id 
GROUP BY cu.channel_type 
ORDER BY total_revenue DESC 

-- Top 5 Customers by Profit: 

SELECT cu.customer_name, SUM(profit) AS total_profit 
FROM customers AS cu 
JOIN sales AS s 
ON cu.customer_id = s.customer_id 
GROUP BY cu.customer_name 
ORDER BY total_profit DESC
LIMIT 5 

-- Top Customers: Who are the top 5 customers by net_revenue?

SELECT cu.customer_name, SUM(net_revenue) AS net_revenue 
FROM customers AS cu 
JOIN sales AS s 
ON cu.customer_id = s.customer_id 
GROUP BY cu.customer_name 
ORDER BY net_revenue DESC
LIMIT 5 

-- Channel Analysis: What is the total sales volume (quantity_sold) broken down by channel_type?

SELECT cu.channel_type, SUM(s.quantity_sold) AS total_quantity_sold 
FROM customers AS cu
JOIN sales AS s 
ON cu.customer_id = s.customer_id 
GROUP BY cu.channel_type 
ORDER BY total_quantity_sold DESC 


-- Geographic Spread: Which country has the highest number of unique customers? 
 
SELECT country, COUNT(DISTINCT(customer_name)) AS unique_customer 
FROM customers 
GROUP BY country 
ORDER BY unique_customer DESC 


SELECT *,
	ROW_NUMBER() OVER( PARTITION BY country) AS counting 
FROM (
		SELECT  DISTINCT(customer_name), customer_id, country
		FROM customers
		GROUP BY customer_id , country ) AS x 



"INVESTORS (Profit & Growth Focus)"

-- 1. What is our YoY revenue growth?
SELECT *, 
	SUM(total_profit) OVER(ORDER BY total_profit) AS YoY_growth
FROM (
	SELECT DISTINCT(ca.year) AS year, SUM(s.profit) AS total_profit
	FROM calendar AS ca
	JOIN sales AS s
	ON ca.date_key = s.date_key
	GROUP BY ca.year
) AS x
	
-- 2. What is net profit margin trend?

SELECT ROUND(((net_profit/ revenue) * 100)::NUMERIC, 2) || '%' AS net_profit_margin
FROM (
	SELECT  SUM(net_revenue) AS revenue,
			SUM(profit) AS net_profit 
	FROM sales ) AS x 


-- 3. Which product contributes most to revenue?

SELECT pr.product_name, SUM(s.net_revenue) AS total_revenue 
FROM products AS pr 
JOIN sales AS s
ON pr.product_id = s.product_id 
GROUP BY pr.product_name 
ORDER BY total_revenue DESC 

-- 4. Which region generates highest profit?

SELECT fa.country, SUM(s.profit) AS total_profit 
FROM facilities AS fa 
JOIN inventory AS i 
ON i.facility_id = fa.facility_id 
JOIN sales AS s 
ON s.product_id = i.product_id 
GROUP BY fa.country
ORDER BY total_profit DESC 

-- 5. Are we improving profitability despite rising production cost?

SELECT *,
	(running_profit - differ) AS profit_difference_by_month 
FROM (
	SELECT *,
		LAG(running_profit) OVER() AS differ 
	FROM (
		SELECT *,
			SUM(total_profit) OVER(PARTITION BY year ORDER BY month ASC) AS running_profit 
		FROM (
				SELECT   ca.month, ca.month_name,ca.year,
						SUM(s.profit) AS total_profit,
						ROUND(SUM(s.profit) * 100 / SUM(net_revenue)::NUMERIC,2) AS net_profit_margin 
				FROM calendar AS ca
				JOIN sales AS s
				ON s.date_key = ca.date_key 
				JOIN procurement AS pro 
				ON pro.product_id = s.product_id 
				GROUP BY ca.year, ca.month_name, ca.month 
			) AS x 
		) AS y  
	) AS z 

-- 6. What is the ROI of procurement spending?

SELECT 	ROUND(((total_profit/ total_cost) * 100)::NUMERIC,2) AS ROI 
FROM (
	SELECT  SUM(pro.total_cost) AS total_cost, 
			SUM(s.profit) AS total_profit 
	FROM procurement AS pro 
	JOIN sales AS s
	ON s.product_id = pro.product_id
) AS x

-- 7. Is our supply chain affecting shareholder value?

 "Is the way we manage suppliers, production, inventory, 
 and delivery increasing or decreasing the company’s profit and long-term growth? 
 The supply chain includes everything from buying raw materials to delivering finished products to customers. 
 If the supply chain works efficiently, costs stay controlled, products are delivered on time, 
 and customers remain satisfied. This leads to higher sales, better profit margins, 
 and stronger financial performance — which increases shareholder value."

-- Customers happy
SELECT *, 
	CASE 
		WHEN total_orders >= 80000 THEN 'Happy'
		WHEN total_orders BETWEEN 70000 AND 80000 THEN 'Mid'
		ELSE 'Try to improve'
	END AS sales_level
FROM (
			SELECT 	cu.customer_name,
					COUNT(s.sales_id) AS total_orders, 
					SUM(s.profit) AS total_profit, 
					COUNT(sh.status) AS total_delivered_product_rate 
			FROM sales AS s
			JOIN shipments AS sh
			ON sh.product_id = s.product_id
			JOIN customers AS cu 
			ON cu.customer_id = sh.customer_id
			WHERE status = 'Delivered' AND customer_name != 'Unknown Customer'
			GROUP BY cu.customer_name
			ORDER BY total_orders DESC 
	) AS x


-- Costs are controlled
SELECT *, (total_cost - total_unit_cost) AS cost_difference 
FROM (
	SELECT  ca.year, 
			SUM(pro.unit_cost) AS total_unit_cost,
			SUM(pro.total_cost) AS total_cost
	FROM calendar AS ca 
	JOIN production AS pr
	ON pr.date_key = ca.date_key 
	JOIN procurement AS pro 
	ON pro.product_id = pr.product_id 
	GROUP BY ca.year 
	ORDER BY year ASC 
) AS x

-- Products delivered on time
SELECT  sh.status, 
		COUNT(sh.status) AS status_count, 
		ROUND(((COUNT(sh.status) * 100.00) / 
		(SELECT COUNT(status) FROM shipments))::NUMERIC,2) || '%' AS status_percentage 
FROM shipments AS sh
GROUP BY  status
ORDER BY status_count DESC 


-- Profit increases
SELECT *,
	(running_profit - differ) AS profit_difference_by_month 
FROM (
	SELECT *,
		LAG(running_profit) OVER() AS differ 
	FROM (
		SELECT *,
			SUM(total_profit) OVER(PARTITION BY year ORDER BY month ASC) AS running_profit 
		FROM (
				SELECT   ca.month, ca.month_name,ca.year,
						SUM(s.profit) AS total_profit,
						ROUND(SUM(s.profit) * 100 / SUM(net_revenue)::NUMERIC,2) AS net_profit_margin 
				FROM calendar AS ca
				JOIN sales AS s
				ON s.date_key = ca.date_key 
				JOIN procurement AS pro 
				ON pro.product_id = s.product_id 
				GROUP BY ca.year, ca.month_name, ca.month 
			) AS x 
		) AS y  
	) AS z 

-- 8. Which product has high revenue but low profit? Why?

SELECT p.product_name,
       ROUND(AVG(p.unit_price)::NUMERIC,2) AS unit_price,
       SUM(s.net_revenue) AS revenue, 
       SUM(s.profit) AS total_profit,
       ROUND((SUM(s.profit) * 100.0 / SUM(s.net_revenue))::NUMERIC,2) AS profit_margin
	   FROM products p 
JOIN sales s 
ON s.product_id = p.product_id 
GROUP BY p.product_name 
ORDER BY revenue DESC, profit_margin ASC

-- 9. If sales increased by 15% but profit only increased by 3%, what went wrong?

-- CEO (Overall Performance)
 
-- 1. Is the company growing sustainably?

SELECT *, 
(total_profit - running_total) AS monthly_profit_difference 
FROM (
	SELECT *, 
	LAG(total_profit) OVER(PARTITION BY year ORDER BY month ASC ) AS running_total
	FROM (
		SELECT ca.month, ca.month_name, ca.year, SUM(s.profit) AS Total_profit
		FROM calendar AS ca 
		JOIN sales AS s 
		ON ca.date_key = s.date_key 
		GROUP BY ca.month, ca.month_name, ca.year
	) AS x 
) AS y

"Red Flag company Continus record Loss during every 2-3 month"

-- 2. Which part of supply chain is weakest?

-- Customers happy
SELECT *, 
	CASE 
		WHEN total_orders >= 80000 THEN 'Happy'
		WHEN total_orders BETWEEN 70000 AND 80000 THEN 'Mid'
		ELSE 'Try to improve'
	END AS sales_level
FROM (
			SELECT 	cu.customer_name,
					COUNT(s.sales_id) AS total_orders, 
					SUM(s.profit) AS total_profit, 
					COUNT(sh.status) AS total_delivered_product_rate 
			FROM sales AS s
			JOIN shipments AS sh
			ON sh.product_id = s.product_id
			JOIN customers AS cu 
			ON cu.customer_id = sh.customer_id
			WHERE status = 'Delivered' AND customer_name != 'Unknown Customer'
			GROUP BY cu.customer_name
			ORDER BY total_orders DESC 
	) AS x


-- Costs are controlled
SELECT *, (total_cost - total_unit_cost) AS cost_difference 
FROM (
	SELECT  ca.year, 
			SUM(pro.unit_cost) AS total_unit_cost,
			SUM(pro.total_cost) AS total_cost
	FROM calendar AS ca 
	JOIN production AS pr
	ON pr.date_key = ca.date_key 
	JOIN procurement AS pro 
	ON pro.product_id = pr.product_id 
	GROUP BY ca.year 
	ORDER BY year ASC 
) AS x

-- Products delivered on time
SELECT  sh.status, 
		COUNT(sh.status) AS status_count, 
		ROUND(((COUNT(sh.status) * 100.00) / 
		(SELECT COUNT(status) FROM shipments))::NUMERIC,2) || '%' AS status_percentage 
FROM shipments AS sh
GROUP BY  status
ORDER BY status_count DESC 


-- Profit increases
SELECT *, 
(total_profit - running_total) AS monthly_profit_difference 
FROM (
	SELECT *, 
	LAG(total_profit) OVER(PARTITION BY year ORDER BY month ASC ) AS running_total
	FROM (
		SELECT ca.month, ca.month_name, ca.year, SUM(s.profit) AS Total_profit
		FROM calendar AS ca 
		JOIN sales AS s 
		ON ca.date_key = s.date_key 
		GROUP BY ca.month, ca.month_name, ca.year
	) AS x 
) AS y

"Proit is the weakest link in whole supply chain"
"We also give some focus to increae the delivery rate"

-- 3. What is biggest operational risk right now?
-- 1. Too much inventory

SELECT  i.product_id, p.product_name,
		SUM(i.stock_level) AS total_satock_level, 
		SUM(i.safety_stock_level) AS safety_stock_level,
		ROUND(((SUM(i.stock_level) * 1.0) / SUM(i.safety_stock_level))::NUMERIC,2) AS stock_ratio
FROM inventory  AS i
JOIN products AS p
ON p.product_id = i.product_id
GROUP BY i.product_id, p.product_name
ORDER BY safety_stock_level DESC 

-- 2. Delayed shipments

SELECT  status, 
		COUNT(status) AS total_count,
		ROUND(((COUNT(status) * 100.0) / (SELECT COUNT(status) FROM shipments))::NUMERIC,2) || '%' AS status_percentage 
FROM shipments
GROUP BY status 
ORDER BY total_count DESC 

-- 3. High procurement cost

SELECT  SUM(s.profit) AS total_profit, 
		SUM(pro.unit_cost * pro.order_quantity) AS procurement_cost,
		ROUND((SUM(profit) *100.0 / SUM(pro.unit_cost * pro.order_quantity))::NUMERIC,2) AS procurement_ratio
FROM procurement AS pro 
JOIN sales AS s 
ON s.product_id = pro.product_id
ORDER BY procurement_cost DESC 

-- 4. Low-profit products

SELECT p.product_name, SUM(s.profit) AS total_profit , ROUND(AVG(s.profit)::NUMERIC,2) AS avg_profit 
FROM products AS p 
JOIN sales AS s
ON s.product_id = p.product_id 
GROUP BY p.product_name 
ORDER BY avg_profit

-- 5. Dependence on one supplier

SELECT  su.supplier_name,
		COUNT(pro.supplier_id) AS total_count,
		ROUND(((COUNT(pro.supplier_id) * 100.0) / (SELECT COUNT(supplier_id) FROM procurement))::NUMERIC,2) || '%' AS supplier_percentage
FROM suppliers AS su
JOIN procurement AS pro
ON pro.supplier_id = su.supplier_id 
GROUP BY su.supplier_name 
ORDER BY total_count DESC 

-- 7. High-revenue but low profit 

SELECT 
    p.product_name,
    SUM(s.net_revenue) AS revenue,
    SUM(s.profit) AS profit,
    ROUND((SUM(s.profit) * 100.0 / SUM(s.net_revenue)),2) AS profit_margin
FROM products p
JOIN sales s
ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY profit_margin ASC

-- 8. If we expand production 20%, can supply chain support it?

"Yes we saw in are past query Supply chain work properly without any type of mis management. 
So, they support easly expandation of 20% of production"


-- 9. If competitor reduces price by 10%, how exposed are we?
"Now we are assume are profit will also reduce by 10%"

SELECT *, (new_profit - real_profit ) AS profit_difference 
FROM (
	SELECT 
		product_id, 
		total_net_revenue, 
		profit_after_10_percentage_loss, 
		total_profit AS real_profit,
		(total_net_revenue - profit_after_10_percentage_loss) AS new_profit
	FROM (
		SELECT *, (total_profit- profit_10_percentage) AS profit_after_10_percentage_loss 
		FROM (
			SELECT  product_id,
					SUM(Net_revenue) AS total_net_revenue,
					SUM(profit) AS total_profit, 
					ROUND(((SUM(profit) * 10.0) / 100)::NUMERIC,2) AS profit_10_percentage 
			FROM sales 
			GROUP BY product_id 
		) AS x 
	) AS y 
) AS z

-- CFO (Finance Head)

-- 1. Gross Margin by product?

SELECT p.product_name,
		SUM(s.net_revenue) AS revenue,
		SUM(s.profit) AS total_profit,
		ROUND(((SUM(s.profit) * 100.0) / SUM(s.net_revenue))::NUMERIC,2) || '%' AS gross_margin 
FROM products AS p
JOIN sales AS s
ON s.product_id = p.product_id 
GROUP BY p.product_name 
ORDER BY gross_margin DESC 

-- 2. Contribution Margin per unit?
-- Seprate product and by the time or per unit
SELECT 
    p.product_name,
    pro.total_cost,
    pro.unit_cost,
    (pro.total_cost - pro.unit_cost) AS contribution_margin_per_unit
FROM products AS p 
JOIN procurement AS pro 
ON pro.product_id = p.product_id 
ORDER BY contribution_margin_per_unit DESC;

-- Total contribution margin total unit

SELECT p.product_name,
		SUM(pro.total_cost) AS total_cost,
		SUM(pro.unit_cost) AS total_unit_cost,
		(SUM(pro.total_cost) - SUM(pro.unit_cost)) AS contribution_margin 
FROM products AS p 
JOIN procurement AS pro 
ON pro.product_id = p.product_id 
GROUP BY p.product_name 
ORDER BY contribution_margin 

-- 3. Cost trend (production + procurement)? 

SELECT *,
SUM(total_cost) OVER(PARTITION BY year ORDER BY month ASC) AS cost_trend 
FROM (
	SELECT
		c.year, c.month, c.month_name,
		SUM(pro.total_cost) AS total_cost
	FROM calendar AS c 
	JOIN sales AS s 
	ON s.date_key = c.date_key
	JOIN procurement AS pro 
	ON pro.product_id = s.product_id
	GROUP BY c.year, c.month, c.month_name 
) AS x

-- 4. Revenue leakage due to discount?

SELECT SUM(discount_amount) AS total_discount_amount
FROM sales 

-- 5. What % of profit is lost due to delayed shipments?

-- Sub query total Delayed percentage

-- (
SELECT 
	ROUND(((COUNT(status) * 100.0) / (SELECT COUNT(status) FROM shipments))::NUMERIC,2) AS status_percentage
FROM shipments
WHERE status = 'Delayed'
GROUP BY status
-- )

-- Using Sub query to find total Delayed loss

SELECT ROUND(((SUM(net_revenue) * (SELECT 
									ROUND(((COUNT(status) * 100.0) /
									(SELECT COUNT(status) FROM shipments))::NUMERIC,2) AS status_percentage
							FROM shipments
							WHERE status = 'Delayed'
							GROUP BY status )) / 100.0)::NUMERIC,2) AS total_loss_revenue
FROM sales 
 

"6. Inventory holding cost impact?"__________________________

SELECT 
	product_id, 
	SUM(stock_level) AS total_stock_level, 
	SUM(safety_stock_level) AS total_safety_stock_level, 
	ROUND(((SUM(safety_stock_level) * 100.0) / SUM(stock_level))::NUMERIC,2) AS safety_stock_level_ratio
FROM inventory 
GROUP BY product_id 
ORDER BY total_safety_stock_level DESC  


-- 7. Which facility has highest cost inefficiency?

SELECT 	
	ROUND((SUM(pro.total_cost) / SUM(s.net_revenue))::NUMERIC,2) AS cost_inefficiency_ratio 
FROM procurement AS pro 
JOIN sales AS s 
ON s.product_id = pro.product_id 

"COO (Operations Head)"_________________________

-- 1. Production vs Sales alignment?

SELECT 
	p.product_name,
	SUM(pr.quantity_produced) AS total_quantity_produced,
	SUM(s.quantity_sold) AS total_quantity_sold, 
	SUM(pr.quantity_produced) - SUM(s.quantity_sold) AS production_gap 
FROM products AS p 
JOIN sales AS s 
ON p.product_id = s.product_id 
JOIN production AS pr
ON pr.product_id = p.product_id 
GROUP BY p.product_name 
ORDER BY production_gap DESC

-- 2. Is overproduction happening?

"Yes according to the last query we see over production is big consering problem."

-- 3. Facility utilization rate?

SELECT 
	pr.facility_id, 
	f.facility_name, 
	c.year, 
	SUM(i.safety_stock_level)  AS total_products,
	f.annual_capacity
FROM facilities AS f
JOIN production AS pr 
ON f.facility_id = pr.facility_id
JOIN inventory AS i
ON i.product_id = pr.product_id
JOIN calendar AS c 
ON pr.date_key = c.date_key
GROUP BY pr.facility_id, f.facility_name, c.year, f.annual_capacity

"Business Meaning

1. 80–90% utilization → healthy and efficient
2. Below 60% → facility is underutilized (wasting resources)
3. Above 95% → risk of overload and operational issues"


-- 4. Production cost per unit trend?

SELECT *,
SUM(total_unit_cost) OVER(PARTITION BY year ORDER BY month ASC) AS production_cost_unit_trend
FROM (
	SELECT 
		c.month, c.month_name, c.year, 
		SUM(pro.unit_cost) AS total_unit_cost
	FROM production AS pr 
	JOIN calendar AS c
	ON c.date_key = pr.date_key
	JOIN procurement AS pro 
	ON pro.product_id = pr.product_id 
	GROUP BY  c.month, c.month_name, c.year
) AS x 

"Supply Chain Manager"______________________

-- 1. Shipping reliability %?

SELECT 
	ROUND(((COUNT(status) * 100.0) / (SELECT COUNT(status) FROM shipments))::NUMERIC,2) || '%' AS Shipping_percentage 
FROM shipments
WHERE status = 'Delivered'

"Business Meaning

95% – 98% → Excellent delivery performance
90% – 94% → Acceptable
Below 90% → Supply chain problem"
"Delivered product percentage is bellow 90 because we are not conceder on the way product and just ordered product"

-- If we conceder all type of status accept Delayed then we see percentage is 92.36 so this is acceptable 
SELECT 
	ROUND(((COUNT(status) * 100.0) / (SELECT COUNT(status) FROM shipments))::NUMERIC,2) || '%' AS Shipping_percentage 
FROM shipments
WHERE status != 'Delayed'

-- 2. Supplier performance ranking?

SELECT *, 
RANK() OVER(ORDER BY total_sales DESC) AS ranking 
FROM (	
	SELECT 
		su.supplier_name, COUNT(s.sales_id) AS total_sales
	FROM sales AS s
	JOIN procurement AS pro 
	ON pro.product_id = s.product_id 
	JOIN suppliers  AS su
	ON su.supplier_id = pro.supplier_id 
	GROUP BY su.supplier_name 
	ORDER BY total_sales DESC 
) AS x

-- 3. Lead time analysis?

SELECT 
    pro.product_id,
    c1.date AS order_date,
    c2.date AS delivery_date,
    (c2.date - c1.date) AS lead_time_days
FROM procurement pro
JOIN calendar c1
    ON pro.order_date_key = c1.date_key
JOIN calendar c2
    ON pro.delivery_date_key = c2.date_key;

-- 4. Delay pattern by region?

SELECT 
	delay_reason, 
	COUNT(delay_reason) AS total_delay_reason_count,
	ROUND(((COUNT(delay_reason) * 100.0) / ( SELECT COUNT(delay_reason) 
											FROM shipments))::NUMERIC,2) || '%' AS delay_reason_percentage
FROM shipments
WHERE status = 'Delayed'
GROUP BY delay_reason 
ORDER BY total_delay_reason_count DESC 

-- 5. Does supplier delay increase production cost?

SELECT 
    pro.supplier_id,
    ROUND(AVG(c2.date - c1.date),2) AS avg_lead_time,
    ROUND(AVG(pro.total_cost),2) AS avg_production_cost
FROM procurement pro
JOIN calendar c1
ON pro.order_date_key = c1.date_key
JOIN calendar c2
ON pro.delivery_date_key = c2.date_key
GROUP BY pro.supplier_id
ORDER BY avg_lead_time DESC

-- 6. Which supplier causes maximum revenue loss?

"Don't Run this query"
SELECT 
	su.supplier_name, 
	COUNT(sales_id) AS total_sales,
	SUM(net_revenue) AS loss_revenue 
FROM sales AS s
JOIN shipments AS sh
ON sh.product_id = s.product_id 
JOIN procurement AS pro 
ON pro.product_id = sh.product_id 
JOIN suppliers AS su 
ON su.supplier_id = pro.supplier_id 
WHERE sh.status = 'Delayed'
GROUP BY su.supplier_name 
ORDER BY loss_revenue DESC 

"Production Manager"___________________________________

-- 1. Daily production variance?

"Daily production"

SELECT c.date, SUM(pr.quantity_produced) AS daily_production 
FROM calendar AS c
JOIN production AS pr
ON pr.date_key = c.date_key 
GROUP BY c.date 
ORDER BY c.date 

"Daily Avg Production"
SELECT  ROUND(AVG(quantity_produced)::NUMERIC,2) AS Daily_avg_production 
FROM production 

-- 2. Cost per batch?

SELECT ROUND(AVG(unit_cost)::NUMERIC,2) AS avg_batch_value 
FROM procurement 

-- 3. Defect rate (if available)?

"Avf defect rate pct"
SELECT ROUND(AVG(defect_rate_pct)::NUMERIC,2) AS avg_defect_rate
FROM production

"Defective unit ratio"
SELECT 
	SUM(quantity_produced) AS total_quantity,
	SUM(defective_units) AS total_defective_units,
	ROUND(((SUM(defective_units) * 100.0 )/ SUM(quantity_produced))::NUMERIC,2) AS defective_ratio
FROM production 

-- 4. Idle capacity?

SELECT *, 
annual_capacity - total_products AS idle_capacity
FROM (
	SELECT 	f.facility_name,
			(SUM(i.stock_level) + SUM(i.safety_stock_level))  AS total_products, 
			f.annual_capacity
	FROM inventory AS i 
	JOIN facilities AS f 
	ON i.facility_id = i.facility_id
	WHERE facility_name != 'Unknown Facility'
	GROUP BY f.facility_name, f.annual_capacity )
ORDER BY idle_capacity DESC 


-- 5. Which product consumes highest cost but low demand?

SELECT 
	pro.product_id, 
	ROUND(AVG(pro.unit_cost)::NUMERIC,2) AS avg_unit_cost, 
	COUNT(s.sales_id) AS total_sales 
FROM procurement AS pro 
JOIN sales AS s
ON s.product_id = pro.product_id 
GROUP BY pro.product_id
ORDER BY total_sales , avg_unit_cost DESC 

"Procurement Manager"________________________

-- 1. Which supplier offers best cost efficiency?

SELECT su.supplier_name, ROUND(AVG(unit_cost)::NUMERIC,2) AS avg_cost
FROM suppliers AS su 
JOIN procurement AS pro 
ON su.supplier_id = pro.supplier_id 
GROUP BY su.supplier_name
ORDER BY avg_cost DESC

-- 2. Purchase price variance?

SELECT 
    product_id,
    order_quantity,
    unit_cost AS actual_price,
    total_cost AS standard_price,
    (total_cost - unit_cost) * order_quantity AS purchase_price_variance
FROM procurement;

-- 3. Volume discount utilization?

SELECT 
	ROUND(AVG(discount_pct)::NUMERIC,2) AS avg_discoutn_percentage, 
	SUM(discount_amount) AS total_discount_amount 
FROM sales 

	
-- 4. Procurement cost trend?

SELECT c.month, c.month_name, 
	SUM(total_cost) AS procurement_cost 
FROM calendar AS c
JOIN procurement AS pro 
ON c.date_key = pro.order_date_key 
GROUP BY c.month, c.month_name 
ORDER BY c.month ASC 

"Sales & Marketing Head"________________

-- 1. Top performing product?

SELECT 
	p.product_name, 
	SUM(s.quantity_sold) AS total_quantity_sold, 
	SUM(s.net_revenue) AS total_revenue, 
	SUM(s.profit) AS total_profit
FROM products AS p 
JOIN sales AS s
ON s.product_id = p.product_id
GROUP BY p.product_name 
ORDER BY total_profit DESC 

-- 2. Discount effectiveness?

SELECT 
	discount_pct || '%' AS dicount_percentage, 
	COUNT(discount_pct) AS discount_count,
	ROUND(((COUNT(discount_pct) * 100.0) / (SELECT COUNT(discount_pct) FROM sales))::NUMERIC,2) || '%' AS dicount_effectiveness_percentage
FROM sales 
GROUP BY discount_pct 
ORDER BY discount_count DESC 

-- 3. Region-wise sales trend?

SELECT 
	cu.country, 
	COUNT(s.sales_id) AS total_sales,
	ROUND(((COUNT(s.sales_id) * 100.0 )/ (SELECT COUNT(sales_id)
										FROM sales ))::NUMERIC,2) || '%'  AS sales_percentage 
FROM sales AS s
JOIN customers AS cu 
ON cu.customer_id = s.customer_id 
GROUP BY cu.country
ORDER BY sales_percentage DESC 

-- 5. Is discount increasing revenue or reducing margin?

SELECT 
	discount_pct || '%' AS dicount_percentage, 
	COUNT(discount_pct) AS discount_count,
	ROUND(((COUNT(discount_pct) * 100.0) / (SELECT COUNT(discount_pct) 
													FROM sales))::NUMERIC,2) || '%' AS dicount_effectiveness_percentage,
	SUM(net_revenue) AS total_revenue,
	SUM(profit) AS total_profit
FROM sales 
GROUP BY discount_pct 
ORDER BY total_profit DESC 

-- 6. Customer lifetime value?

SELECT 
    customer_id,
    SUM(net_revenue) AS customer_lifetime_value
FROM sales
GROUP BY customer_id
ORDER BY customer_lifetime_value DESC

"Regional Managers"____________________

-- 1. Why some country underperforming?

SELECT cu.country, SUM(net_revenue) AS total_revenue, SUM(profit) AS total_profit 
FROM customers AS cu 
JOIN sales AS s
ON s.customer_id = cu.customer_id 
GROUP BY cu.country
ORDER BY total_profit DESC

-- 2. Regional profit variance?
SELECT 
    cu.country,
    SUM(profit) AS region_profit,
    ROUND(SUM(profit) - AVG(SUM(profit)) OVER()::NUMERIC,2) AS profit_variance
FROM sales s
JOIN customers cu
ON s.customer_id = cu.customer_id
GROUP BY  cu.country;

-- 3. Logistics cost impact by region?

SELECT 
	cu.country, 
	SUM(sh.shipping_cost) AS total_shipping_cost, 
	SUM(s.profit) AS total_profit 
FROM customers AS cu 
JOIN sales AS s
ON s.customer_id = cu.customer_id 
JOIN shipments AS sh 
ON s.product_id = sh.product_id 
GROUP BY cu.country 
ORDER BY total_shipping_cost DESC 

-- 4. Demand forecasting accuracy? 

SELECT 
    c.year,
    c.month,
	c.month_name,
    SUM(s.quantity_sold) AS monthly_demand
FROM sales s
JOIN calendar c
ON s.date_key = c.date_key
GROUP BY c.year, c.month, c.month_name
ORDER BY c.year, c.month;


"For India"____________________________________

-- 1. Geographic Mismatch: Why India’s Offer Efficiency is Low.
SELECT su.supplier_name, ROUND(AVG(unit_cost)::NUMERIC,2) AS avg_cost
FROM suppliers AS su 
JOIN procurement AS pro 
ON su.supplier_id = pro.supplier_id 
GROUP BY su.supplier_name
ORDER BY avg_cost DESC


-- 2. Seasonal Profitability & Market Trends
		
SELECT 
	c.year, c.month, c.month_name, 
	SUM(gross_revenue) AS total_gross_revenue,
	SUM(s.profit) AS total_profit
FROM calendar AS c
JOIN sales AS s
ON s.date_key = c.date_key
GROUP BY c.year, c.month, c.month_name 
ORDER BY total_profit DESC 



-- 3. Discount Percentage in India.
SELECT 
	s.discount_pct || '%' AS dicount_percentage, 
	COUNT(s.discount_pct) AS discount_count,
	ROUND(((COUNT(s.discount_pct) * 100.0) / (SELECT COUNT(s.discount_pct) 
													FROM sales AS s
													JOIN customers AS cu
													ON cu.customer_id = s.customer_id
													WHERE cu.country = 'India'
														))::NUMERIC,2 ) || '%' AS dicount_effectiveness_percentage,
	SUM(s.net_revenue) AS total_revenue,
	SUM(s.profit) AS total_profit
FROM sales AS s
JOIN customers AS cu
ON s.customer_id = cu.customer_id
WHERE cu.country = 'India'
GROUP BY s.discount_pct 
ORDER BY total_profit DESC 

SELECT * FROM customers 

-- 4. Data Integrity Alert: Indian Market Channel Reporting

SELECT cu.channel_type, COUNT(s.sales_id) AS total_count 
FROM customers AS cu 
JOIN sales AS s 
ON cu.customer_id = s.customer_id 
GROUP BY cu.channel_type 
ORDER BY total_count DESC 
 

SELECT cu.channel_type, COUNT(s.sales_id) AS total_count 
FROM customers AS cu 
JOIN sales AS s 
ON cu.customer_id = s.customer_id
WHERE cu.country = 'India'
GROUP BY cu.channel_type  
ORDER BY total_count DESC
