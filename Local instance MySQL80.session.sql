use food_app_project;

-- phase 1: Exploratory Data Analysis (EDA)
-- 1.1 total revenue by restaurants
select sum(order_amount-discount) as total_revenue
from orders; 

-- 1.2 total orders per city
select r.city,count(o.order_id) as total_orders
from orders o 
join restaurants r on o.restaurant_id=r.restaurant_id
GROUP BY r.city;

-- 1.3 Top 10 Customers by Spending
select c.customer_id,c.name, sum(o.order_amount-o.discount) as total_spent
from orders o
join customers c on o.customer_id=c.customer_id
GROUP BY c.customer_id,c.name
ORDER BY total_spent DESC
limit 10;

-- PHASE 2 — CUSTOMER SEGMENTATION
-- 2.1 Customer Category (Gold/Silver/Bronze)
select c.customer_id,c.name,
case
    when sum(o.order_amount-o.discount) >= 1000 then 'GOLD'
    when sum(o.order_amount-o.discount) >= 500 then 'SILVER'
    else 'BRONZE'
    end as customer_category
    from orders O
    join customers c on o.customer_id=c.customer_id
GROUP BY c.customer_id,c.name;

-- phase 3  PHASE 3 — RESTAURANT PERFORMANCE
-- 3.1 Top 10 Restaurants by Revenue
select r.restaurant_id,r.restaurant_name, sum(o.order_amount-o.discount) AS total_revenue
from orders o
join restaurants r ON o.restaurant_id=r.restaurant_id
GROUP BY r.restaurant_id,r.restaurant_name
ORDER BY total_revenue DESC
LIMIT 10;

-- 3.2 Average Rating vs Revenue
SELECT r.restaurant_id, r.restaurant_name, AVG(r.rating) AS avg_rating, SUM(o.order_amount-o.discount) AS total_revenue
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_id, r.restaurant_name
ORDER BY total_revenue DESC;

--PHASE 4 — DELIVERY ANALYSIS
-- 4.1 Average Delivery Time by City
SELECT r.city, AVG(o.delivery_time) AS avg_delivery_time
from orders o
join restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY r.city;

-- 4.2.Late Deliveries (Above 45 Minutes)
SELECT r.city, COUNT(o.delivery_time) AS late_deliveries
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE o.delivery_time > 45
GROUP BY r.city;

--PHASE 5 — PAYMENT & DISCOUNT ANALYSIS
-- 5.1 Payment Method Distribution
SELECT payment_method, COUNT(order_id) AS count
FROM orders
GROUP BY payment_method;

-- 5.2. Discount Impact on Revenue
SELECT
    CASE
        WHEN discount > 0 THEN 'with_discount'
        ELSE 'without_discount'
    END AS discount_status,
    COUNT(order_id) AS order_count,
    SUM(order_amount) AS total_revenue,
    ROUND(AVG(order_amount), 2) AS avg_order_value
FROM orders
GROUP BY discount_status;

-- PHASE 6 — ADVANCED SQL
-- 6.1 Monthly Revenue Using CTE
WITH MonthlyRevenue AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(order_amount - discount) AS total_revenue
    FROM orders o
    GROUP BY month
)
SELECT * FROM MonthlyRevenue;

-- 6.2 Rank Restaurants by Revenue (Window Function)
SELECT
    r.restaurant_id,
    r.restaurant_name,
    sum(o.order_amount - o.discount) AS total_revenue,
    RANK() OVER (ORDER BY sum(o.order_amount - o.discount) DESC) AS revenue_rank
    FROM orders o
    JOIN restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_id, r.restaurant_name
ORDER BY total_revenue DESC;\

--6.3 Above Average Revenue Restaurants (Subquery)
SELECT
r.restaurant_id,
r.restaurant_name,
sum(o.order_amount - o.discount) AS total_revenue
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_id, r.restaurant_name 
HAVING total_revenue > (SELECT AVG(total_revenue) FROM (
    SELECT sum(o2.order_amount - o2.discount) AS total_revenue
    FROM orders o2
    JOIN restaurants r2 ON o2.restaurant_id = r2.restaurant_id
    GROUP BY r2.restaurant_id, r2.restaurant_name
) AS avg_revenue);

-- PHASE 7 — DATABASE OBJECTS
-- 7.1 1.Create Revenue View
CREATE VIEW restaurant_revenue AS
SELECT 
    r.restaurant_id,
    r.restaurant_name, 
    SUM(o.order_amount - o.discount) AS total_revenue
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_id, r.restaurant_name;

select * from restaurant_revenue;


-- Creating a Procedure to get top n restaurants
create procedure GET_TOP_N_RESTAURANTS(IN top_n INT)
begin
    select restaurant_id, restaurant_name, total_revenue
    from restaurant_revenue
    order by total_revenue desc
    limit top_n;
end;
call GET_TOP_N_RESTAURANTS(5);

--PHASE 8-- Performance Optimization
-- 8.1 Index on order_date (for monthly reports)
CREATE INDEX order_date_idx ON orders(order_date);

-- 8.2 Index on customer_name 
CREATE INDEX customer_name_idx ON customers(name);

-- 8.3 Index on restaurant_name
CREATE INDEX restaurant_name_idx ON restaurants(restaurant_name);

--PHASE 9 —Automation Logic
create table high_value_orders_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    customer_id INT,
    restaurant_id INT,
    order_amount DECIMAL(10,2),
    log_date datetime DEFAULT CURRENT_TIMESTAMP);


--9.0 Auto log for highh_value_orders
create trigger trg_high_value_orders
after insert on orders
for each row
begin
    if new.order_amount > 1000 then
        insert into high_value_orders_log(
            order_id, customer_id, restaurant_id, order_amount)
        values(new.order_id, new.customer_id, 
        new.restaurant_id, new.order_amount);
    end if;
end;

-- Check the trigger by inserting a high value order
insert into orders (order_id, customer_id, restaurant_id, order_amount, discount, order_date, delivery_time, payment_method)
values
(1003, 232, 253, 800.00, 50.00, '2024-06-02', 40, 'Cash');

-- 9.1 TRIGGER 2 — Prevent Negative Discounts

create table ne_discount_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    order_amount DECIMAL(10,2),
    discount DECIMAL(10,2),
    log_date datetime DEFAULT CURRENT_TIMESTAMP
);

-- Trigger to log negative discounts
CREATE trigger trg_negative_discount
before insert on orders 
for each row
begin
    if new.discount < 0 then
        set new.discount = 0;
        insert into ne_discount_log(order_id, order_amount, discount)
        values(new.order_id, new.order_amount, new.discount);
    end if;
end;

-- Check the trigger by inserting an order with negative discount
insert into orders(order_id, customer_id, restaurant_id, order_amount, discount, order_date, delivery_time, payment_method) 
values
(1004, 233, 254, 500.00, -20.00, '2024-06-03', 30, 'Card');
 
 --9.2 TRIGGER 2 — Delivery Delay Warning
create table delivery_delay_log(
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    restaurant_id INT,
    delivery_time INT,
    log_date datetime DEFAULT CURRENT_TIMESTAMP
);

-- Trigger to log delivery delays
CREATE trigger trg_delivery_delay   
after update on orders
for each row
begin
    if new.delivery_time > 45 then
        insert into delivery_delay_log(order_id, restaurant_id, delivery_time)
        values(new.order_id, new.restaurant_id, new.delivery_time);
    end if;
end;

-- Check the trigger by updating an order with a delivery time above 45 minutes
update orders
set delivery_time = 50
where order_id = 1003;
