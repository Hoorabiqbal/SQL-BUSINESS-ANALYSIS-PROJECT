-- CREATE DATABASE

CREATE DATABASE  pizzahut;
USE  pizzahut;

-- CREATE Table Then Import Data from CSV FILE
create table orders (
order_id INT NOT NULL,
order_date  DATE NOT NULL,
order_time time NOT NULL,
primary key (order_id ));

SELECT * FROM orders;

-- Create Seacond Table Then Import Csv File
create table order_details (
order_details_id INT NOT NULL,
order_id  INT NOT NULL,
pizza_id VARCHAR(50) NOT NULL,
quantity INT Not Null,
primary key (order_id ));

SELECT * FROM order_details;
SELECT * FROM orders;
SELECT * FROM pizzas;
SELECT * FROM pizza_types;
-- Basic:
-- Retrieve the total number of orders placed.
SELECT 
    COUNT(DISTINCT order_id) AS total_orders
FROM
    orders;

-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(o.quantity * p.price), 2) AS total_revenue
FROM
    order_details AS o
        JOIN
    pizzas AS p ON p.pizza_id = o.pizza_id;

-- Identify the highest-priced pizza.
SELECT 
    pt.name
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;


-- Identify the most common pizza size ordered.
SELECT 
    p.size, COUNT(o.quantity)
FROM
    order_details AS o
        JOIN
    pizzas AS p ON p.pizza_id = o.pizza_id
GROUP BY size
ORDER BY COUNT(o.quantity) DESC
LIMIT 1;


-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pt.name, COUNT(o.quantity) AS total_quantity
FROM
    pizzas AS p
        JOIN
    pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS o ON o.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;

-- Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category ordered.
 SELECT 
pt.category,
COUNT(o.quantity) as total_quantity
FROM
    pizzas AS p
        JOIN
    pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS o ON o.pizza_id = p.pizza_id
GROUP BY category 
ORDER BY total_quantity ;

-- Determine the distribution of orders by hour of the day.
SELECT
    HOUR(o.order_time) AS order_hour,
    COUNT(od.order_id) AS order_count
FROM
    orders as o
JOIN order_details as od
on od.order_id = o.order_id
GROUP BY
    order_hour 
ORDER BY
    order_count desc;

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT
    pt.category AS category, 
    COUNT(p.pizza_id) AS total_pizzas, 
    ROUND(COUNT(p.pizza_id) * 100.0 / (SELECT COUNT(*) FROM pizzas), 2) AS percentage_of_total
FROM
    pizza_types AS pt
JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id 
GROUP BY
    pt.category 
ORDER BY
    total_pizzas DESC; 

-- Group the orders by date and calculate the average number of pizzas ordered per day.
select o.order_date ,
ROUND(AVG(od.order_id), 2)
from orders as o
join order_details as od
on od.order_id = o.order_id
group by o.order_date
order by o.order_date;
-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.name,
    ROUND(SUM(o.quantity * p.price), 2) AS total_revenue
FROM
    pizzas AS p
        JOIN
    order_details AS o ON p.pizza_id = o.pizza_id
        JOIN
    pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 3;

-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.
-- Calculate the percentage contribution of each pizza type to total revenue
SELECT
    pt.name AS pizza_type,
    SUM(od.quantity * p.price) AS total_revenue,
    Concat(Round((SUM(od.quantity * p.price) * 100.0 / (SELECT SUM(o2.quantity * p2.price) FROM order_details o2 JOIN pizzas p2 ON o2.pizza_id = p2.pizza_id)),2), '%')
    AS percentage_of_total_revenue
FROM
    pizza_types pt
JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY
    pt.name
ORDER BY
    percentage_of_total_revenue DESC;

-- Analyze the cumulative revenue generated over time.
SELECT
    order_date,
    ROUND(SUM(daily_revenue) OVER (ORDER BY order_date), 2) AS cumulative_revenue
FROM
    (
    SELECT
        o.order_date,
        SUM(od.quantity * p.price) AS daily_revenue
    FROM
        orders as o
    JOIN
        order_details as od ON o.order_id = od.order_id
    JOIN
        pizzas as  p ON od.pizza_id = p.pizza_id
    GROUP BY
        o.order_date
    ) AS sales_by_date
ORDER BY
    order_date;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
WITH CategoryRevenue AS (
    -- Calculate total revenue for each pizza type within its category
    SELECT
        pt.category,
        pt.name AS pizza_name,
        SUM(od.quantity * p.price) AS revenue
    FROM
        pizza_types pt
    JOIN
        pizzas p ON pt.pizza_type_id = p.pizza_type_id
    JOIN
        order_details od ON od.pizza_id = p.pizza_id
    GROUP BY
        pt.category, pt.name
),
RankedPizzas AS (
    -- Rank pizza types by revenue within each category
    SELECT
        category,
        pizza_name,
        revenue,
        RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rank_num
    FROM
        CategoryRevenue
)
-- Select the top 3 ranked pizza types for each category
SELECT
    category,
    pizza_name,
    revenue
FROM
    RankedPizzas
WHERE
    rank_num <= 3
ORDER BY
    category,
    revenue DESC;






